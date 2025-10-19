#!/usr/bin/env python3
"""
OpenVAS XML Report Parser
Parses OpenVAS XML reports and generates human-readable summaries
"""

import sys
import xml.etree.ElementTree as ET
from collections import defaultdict
from datetime import datetime
import os

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    BOLD = '\033[1m'
    NC = '\033[0m'  # No Color

def parse_report(xml_file):
    """Parse a single OpenVAS XML report"""
    try:
        if not os.path.exists(xml_file):
            print(f"Warning: File not found: {xml_file}", file=sys.stderr)
            return None
        
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        report_data = {
            'filename': os.path.basename(xml_file),
            'scan_start': 'Unknown',
            'scan_end': 'Unknown',
            'host': 'Unknown',
            'high': 0,
            'medium': 0,
            'low': 0,
            'log': 0,
            'vulnerabilities': []
        }
        
        # Try to get scan metadata
        report_elem = root.find('.//report')
        if report_elem is not None:
            scan_start = report_elem.find('.//creation_time')
            scan_end = report_elem.find('.//modification_time')
            if scan_start is not None:
                report_data['scan_start'] = scan_start.text
            if scan_end is not None:
                report_data['scan_end'] = scan_end.text
        
        # Parse results
        for result in root.findall('.//result'):
            threat_elem = result.find('threat')
            if threat_elem is None:
                continue
            
            threat_level = threat_elem.text.lower()
            
            # Count by severity
            if threat_level in ['high', 'medium', 'low', 'log']:
                report_data[threat_level] += 1
            
            # Extract details for high/medium vulnerabilities
            if threat_level in ['high', 'medium']:
                nvt = result.find('nvt')
                host = result.find('host')
                port = result.find('port')
                description = result.find('description')
                
                vuln = {
                    'threat': threat_level,
                    'name': nvt.find('name').text if nvt is not None and nvt.find('name') is not None else 'Unknown',
                    'host': host.text if host is not None else report_data['host'],
                    'port': port.text if port is not None else 'Unknown',
                    'cvss': nvt.find('cvss_base').text if nvt is not None and nvt.find('cvss_base') is not None else 'N/A',
                    'description': description.text[:200] if description is not None and description.text else 'No description'
                }
                
                # Update host if we found it
                if vuln['host'] != 'Unknown':
                    report_data['host'] = vuln['host']
                
                report_data['vulnerabilities'].append(vuln)
        
        return report_data
    
    except ET.ParseError as e:
        print(f"Error parsing XML {xml_file}: {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Error processing {xml_file}: {e}", file=sys.stderr)
        return None

def print_header():
    """Print report header"""
    print("=" * 100)
    print(f"{Colors.BOLD}OpenVAS Vulnerability Scan Summary Report{Colors.NC}")
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 100)
    print()

def print_report_summary(reports):
    """Print summary of all reports"""
    total_high = 0
    total_medium = 0
    total_low = 0
    total_log = 0
    
    print(f"{Colors.BOLD}Individual Report Summaries{Colors.NC}")
    print("-" * 100)
    
    for report in reports:
        if report is None:
            continue
        
        print(f"\nFile: {report['filename']}")
        print(f"Host: {report['host']}")
        print(f"Scan Period: {report['scan_start']} to {report['scan_end']}")
        print(f"  {Colors.RED}High:{Colors.NC}   {report['high']:>4}")
        print(f"  {Colors.YELLOW}Medium:{Colors.NC} {report['medium']:>4}")
        print(f"  {Colors.BLUE}Low:{Colors.NC}    {report['low']:>4}")
        print(f"  Log:    {report['log']:>4}")
        
        total_high += report['high']
        total_medium += report['medium']
        total_low += report['low']
        total_log += report['log']
    
    print("\n" + "=" * 100)
    print(f"{Colors.BOLD}TOTAL SUMMARY{Colors.NC}")
    print("=" * 100)
    print(f"{Colors.RED}High Severity:  {Colors.NC} {total_high:>4}")
    print(f"{Colors.YELLOW}Medium Severity:{Colors.NC} {total_medium:>4}")
    print(f"{Colors.BLUE}Low Severity:   {Colors.NC} {total_low:>4}")
    print(f"Informational:   {total_log:>4}")
    print(f"Total Findings:  {total_high + total_medium + total_low + total_log:>4}")
    print()
    
    # Risk assessment
    if total_high > 0:
        print(f"{Colors.RED}{Colors.BOLD}⚠ CRITICAL: {total_high} high severity vulnerabilities found!{Colors.NC}")
    elif total_medium > 5:
        print(f"{Colors.YELLOW}{Colors.BOLD}⚠ WARNING: {total_medium} medium severity vulnerabilities found!{Colors.NC}")
    elif total_medium > 0 or total_low > 0:
        print(f"{Colors.YELLOW}⚠ Some vulnerabilities found, review recommended{Colors.NC}")
    else:
        print(f"{Colors.GREEN}✓ No significant vulnerabilities found{Colors.NC}")
    print()

def print_vulnerabilities(reports):
    """Print detailed vulnerability list"""
    all_vulns = []
    
    for report in reports:
        if report is None:
            continue
        all_vulns.extend(report['vulnerabilities'])
    
    if not all_vulns:
        print("No high or medium severity vulnerabilities found.")
        return
    
    # Sort by threat level (high first) and CVSS score
    all_vulns.sort(key=lambda x: (
        0 if x['threat'] == 'high' else 1,
        -float(x['cvss']) if x['cvss'] != 'N/A' else 0
    ))
    
    print("=" * 100)
    print(f"{Colors.BOLD}CRITICAL & HIGH RISK VULNERABILITIES{Colors.NC}")
    print("=" * 100)
    print()
    
    # Show top 50 vulnerabilities
    for i, vuln in enumerate(all_vulns[:50], 1):
        color = Colors.RED if vuln['threat'] == 'high' else Colors.YELLOW
        
        print(f"{i}. {color}{Colors.BOLD}[{vuln['threat'].upper()}]{Colors.NC} {vuln['name']}")
        print(f"   Host: {vuln['host']} | Port: {vuln['port']} | CVSS Score: {vuln['cvss']}")
        print(f"   Description: {vuln['description']}")
        print()
    
    if len(all_vulns) > 50:
        print(f"... and {len(all_vulns) - 50} more vulnerabilities")
        print()

def print_footer():
    """Print report footer"""
    print("=" * 100)
    print("END OF REPORT")
    print("=" * 100)
    print()
    print("For detailed information, review the full XML reports.")
    print("Remediation should be prioritized based on CVSS scores and threat levels.")

def main():
    if len(sys.argv) < 2:
        print("Usage: openvas-parser.py <report1.xml> [report2.xml ...]")
        print()
        print("Example:")
        print("  openvas-parser.py /path/to/report-*.xml")
        sys.exit(1)
    
    # Parse all reports
    reports = []
    for xml_file in sys.argv[1:]:
        report = parse_report(xml_file)
        if report is not None:
            reports.append(report)
    
    if not reports:
        print("Error: No valid reports could be parsed", file=sys.stderr)
        sys.exit(1)
    
    # Generate summary
    print_header()
    print_report_summary(reports)
    print_vulnerabilities(reports)
    print_footer()

if __name__ == "__main__":
    main()
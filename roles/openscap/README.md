# OpenSCAP Compliance Role

## 📌 Overview

Automated security compliance scanning với **OpenSCAP** - CIS Benchmarks, STIG, và PCI-DSS compliance checking.

## 🚀 Quick Start

```bash
# Run compliance scan
ansible-playbook playbooks/openscap.yml

# View reports
ls -la /tmp/openscap-reports/
```

## ⚙️ Variables

```yaml
openscap_profile: "xccdf_org.ssgproject.content_profile_cis"
openscap_policy: "ssg-rhel8-ds.xml"
openscap_report_dir: "/tmp/openscap-reports"
openscap_remediate: no  # Set to yes for auto-remediation
```

## 🔧 Operations

```bash
# Available profiles
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

# Run scan
sudo oscap xccdf eval --profile cis /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

# Generate HTML report
sudo oscap xccdf generate report scan-results.xml > report.html

# Remediate
sudo oscap xccdf eval --remediate --profile cis /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

## 📊 Compliance Profiles

- **CIS Benchmark**: Industry best practices
- **STIG**: DoD security requirements
- **PCI-DSS**: Payment card industry standards
- **HIPAA**: Healthcare compliance

**Last Updated**: 2025-12-27

# OpenVAS Scan Reports

Created: 2025-10-18 16:55:42 UTC
User: root
Location: /home/ansible/ansible/roles/openvas/reports

## Directory Structure

- **xml/** - Raw XML scan reports from OpenVAS
- **summaries/** - Human-readable summary reports
- **archive/** - Archived old reports (>30 days)

## Quick View Commands

```bash
# View latest summary
cat summaries/summary-*.txt | tail -100

# List all XML reports
ls -lht xml/

# Use helper script
openvas-helper reports

# Open in file manager
openvas-helper open-reports
```

## Report Format

Each scan generates:
1. XML report: `xml/report-<IP>-<timestamp>.xml`
2. Summary text: `summaries/summary-<date>.txt`

## Automatic Cleanup

Reports older than 30 days are automatically moved to `archive/`

# OpenVAS Vulnerability Scanner Role

## 📌 Overview

Triển khai **OpenVAS (GVM)** vulnerability scanner cho security assessment và penetration testing.

## 🚀 Quick Start

```bash
# Deploy OpenVAS
ansible-playbook playbooks/deploy-openvas.yml

# Access: https://<SERVER_IP>:9392
# Credentials from deployment output
```

## ⚙️ Variables

```yaml
openvas_admin_password: "Admin123!"
openvas_feed_update: yes
openvas_scanner_preference: "medium"
```

## 🔧 Operations

```bash
# Check services
sudo systemctl status gvmd ospd-openvas

# Update feeds
sudo greenbone-feed-sync

# Create scan target via CLI
gvm-cli socket --xml "<create_target><name>Test</name><hosts>192.168.1.0/24</hosts></create_target>"

# View reports
# Via Web UI: Scans > Reports
```

## 📊 Scan Types

- **Full and fast**: Comprehensive scan
- **Full and deep**: Deep inspection
- **Discovery**: Host discovery only
- **Web Application**: Web-focused scan

**Last Updated**: 2025-12-27

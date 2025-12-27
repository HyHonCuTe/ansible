# DNS Server Role

## 📌 Overview

Cấu hình **DNS Server** trên Windows hoặc Linux với zone management và forwarders.

## 🚀 Quick Start

```bash
# Windows DNS
ansible-playbook playbooks/install_dns_win.yml

# Linux BIND
ansible-playbook playbooks/install_dns_li.yml
```

## ⚙️ Variables

```yaml
# DNS Configuration
dns_domain: "example.local"
dns_forwarders:
  - "8.8.8.8"
  - "8.8.4.4"

# Zones
dns_zones:
  - name: "example.local"
    type: "primary"
  
  - name: "1.168.192.in-addr.arpa"
    type: "primary"
```

## 🔧 Operations (Windows)

```powershell
# Check DNS service
Get-Service DNS

# List zones
Get-DnsServerZone

# Add record
Add-DnsServerResourceRecordA -Name "web" -ZoneName "example.local" -IPv4Address "192.168.1.100"

# Flush cache
Clear-DnsServerCache

# Test resolution
nslookup web.example.local
```

## 🔧 Operations (Linux)

```bash
# Check BIND
sudo systemctl status named

# Test config
sudo named-checkconf

# Reload zones
sudo rndc reload

# Query
dig @localhost example.local
```

**Last Updated**: 2025-12-27

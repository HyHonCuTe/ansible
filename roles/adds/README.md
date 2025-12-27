# Active Directory Domain Services Role

## 📌 Overview

Triển khai **Active Directory Domain Services (AD DS)** trên Windows Server với DNS integration.

## 🚀 Quick Start

```bash
# Deploy AD DS
ansible-playbook playbooks/deploy_adds.yml

# Configure AD + DNS
ansible-playbook playbooks/configure_adds_dns.yml

# Validate
ansible-playbook playbooks/validate_adds_dns.yml
```

## ⚙️ Variables

```yaml
# Domain Configuration
adds_domain_name: "example.local"
adds_domain_netbios: "EXAMPLE"
adds_safe_mode_password: "P@ssw0rd123!"

# Forest Level
adds_forest_level: "WinThreshold"
adds_domain_level: "WinThreshold"

# DNS
adds_dns_forwarders:
  - "8.8.8.8"
  - "8.8.4.4"
```

## 🔧 Operations

```powershell
# Check AD DS service
Get-Service NTDS

# Verify domain controller
Get-ADDomainController

# Check replication
repadmin /showrepl

# DNS zones
Get-DnsServerZone

# Users
Get-ADUser -Filter *

# Computers
Get-ADComputer -Filter *
```

## 🐛 Troubleshooting

```powershell
# Test AD connectivity
Test-ComputerSecureChannel -Repair

# Check DNS
nslookup example.local

# Verify LDAP
ldp.exe

# Replication issues
repadmin /syncall
```

**Last Updated**: 2025-12-27

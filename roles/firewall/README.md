# Firewall Configuration Role

## 📌 Overview

Cấu hình **firewalld** trên Linux systems với predefined zones và rules.

## 🚀 Quick Start

```bash
ansible-playbook playbooks/install_firewall_li.yml
```

## ⚙️ Variables

```yaml
firewall_enabled: yes
firewall_default_zone: "public"

firewall_allowed_services:
  - ssh
  - http
  - https

firewall_allowed_ports:
  - "8080/tcp"
  - "9090/tcp"

firewall_rich_rules:
  - 'rule family="ipv4" source address="192.168.1.0/24" accept'
```

## 🔧 Operations

```bash
# Check status
sudo firewall-cmd --state

# List all rules
sudo firewall-cmd --list-all

# Add service
sudo firewall-cmd --add-service=http --permanent

# Add port
sudo firewall-cmd --add-port=8080/tcp --permanent

# Reload
sudo firewall-cmd --reload

# Remove rule
sudo firewall-cmd --remove-service=http --permanent
```

**Last Updated**: 2025-12-27

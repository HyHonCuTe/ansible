# Common Tasks Role

## 📌 Overview

Shared tasks và utilities được sử dụng across multiple roles - connectivity checks, package installation, common configurations.

## 🚀 Usage

```yaml
# Include in playbook
- hosts: all
  roles:
    - common
```

## ⚙️ Tasks Included

### System Preparation
- Update package cache
- Install common utilities (vim, curl, wget, net-tools)
- Configure timezone
- Set hostname
- Disable SELinux (optional)

### Network Configuration
- Configure DNS resolvers
- Set static IP (optional)
- Configure network interfaces

### Security Baseline
- Configure SSH (disable root login, key-only auth)
- Install fail2ban
- Basic firewall rules
- Update system packages

### Monitoring Setup
- Install monitoring agents
- Configure logging
- Setup NTP

## 🔧 Variables

```yaml
# Timezone
common_timezone: "Asia/Ho_Chi_Minh"

# DNS
common_dns_servers:
  - "8.8.8.8"
  - "8.8.4.4"

# Packages
common_packages:
  - vim
  - curl
  - wget
  - git
  - htop
  - net-tools

# SSH
common_ssh_port: 22
common_ssh_permit_root: no
common_ssh_password_auth: no
```

## 📋 Example Playbook

```yaml
---
- name: Apply common configuration
  hosts: all
  become: yes
  roles:
    - role: common
      vars:
        common_timezone: "Asia/Ho_Chi_Minh"
        common_packages:
          - vim
          - htop
          - curl
```

**Last Updated**: 2025-12-27

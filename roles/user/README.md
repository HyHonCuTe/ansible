# User Management Role

## 📌 Overview

Automated user account creation, management, và SSH key deployment.

## 🚀 Quick Start

```bash
ansible-playbook playbooks/install_user_li.yml
```

## ⚙️ Variables

```yaml
users_to_create:
  - name: "john"
    uid: 1001
    groups: "wheel"
    shell: "/bin/bash"
    ssh_key: "ssh-rsa AAAA..."
  
  - name: "jane"
    uid: 1002
    groups: "developers"
    shell: "/bin/bash"

users_to_remove:
  - "olduser"

sudo_users:
  - "john"
  - "ansible"
```

## 🔧 Operations

```bash
# List users
cat /etc/passwd | grep -E "john|jane"

# Check sudo access
sudo -l -U john

# Verify SSH key
cat /home/john/.ssh/authorized_keys

# Remove user
sudo userdel -r username

# Lock user
sudo usermod -L username
```

**Last Updated**: 2025-12-27

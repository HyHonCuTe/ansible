# Commvault Backup Role

## 📌 Overview

Integration với **Commvault** enterprise backup solution - automated backup deployment và configuration.

## 🚀 Quick Start

```bash
ansible-playbook playbooks/deploy_commvault_backup.yml
```

## ⚙️ Variables

```yaml
commvault_server: "backup-server.example.com"
commvault_client_name: "{{ ansible_hostname }}"
commvault_subclient_name: "default"

# Backup sets
commvault_backup_sets:
  - name: "FileSystem"
    paths:
      - "/etc"
      - "/var/www"
      - "/home"
  
  - name: "Database"
    paths:
      - "/var/lib/mysql"

# Schedule
commvault_schedule: "daily"
commvault_retention_days: 30
```

## 🔧 Operations

```bash
# Check Commvault service
sudo systemctl status commvault

# View backup jobs
# Via Commvault Command Center

# Manual backup
/opt/commvault/Base/cvbackup -subclient <name>

# Restore
/opt/commvault/Base/cvrestore -subclient <name>

# View logs
sudo tail -f /var/log/commvault/Base/Log.txt
```

**Last Updated**: 2025-12-27

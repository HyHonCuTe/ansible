# Backup Automation Role

## 📌 Overview

Automated backup solution cho Linux systems với compression và rotation.

## 🚀 Quick Start

```bash
ansible-playbook playbooks/install_backup_li.yml
```

## ⚙️ Variables

```yaml
backup_dir: "/backup"
backup_source_dirs:
  - "/etc"
  - "/var/www"
  - "/home"

backup_retention_days: 7
backup_schedule: "0 2 * * *"  # 2 AM daily

backup_compression: yes
backup_log_file: "/var/log/ansible_backup.log"
```

## 🔧 Operations

```bash
# Manual backup
sudo /usr/local/bin/backup.sh

# Check backups
ls -lh /backup/

# Restore
sudo tar -xzf /backup/backup-YYYYMMDD.tar.gz -C /

# View logs
sudo tail -f /var/log/ansible_backup.log

# Test backup
sudo tar -tzf /backup/backup-YYYYMMDD.tar.gz | head -20
```

**Last Updated**: 2025-12-27

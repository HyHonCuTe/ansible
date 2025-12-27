# Commvault Backup System for HA Infrastructure

## Overview

This role deploys a comprehensive backup solution for the High Availability infrastructure, with support for both **Commvault** (commercial) and **native MariaBackup** (open-source).

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    BACKUP ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────┘

    Web1 (192.168.1.27)              Web2 (192.168.1.30)
    ┌─────────────────┐              ┌─────────────────┐
    │   MariaDB       │              │   MariaDB       │
    │   WordPress DB  │              │   WordPress DB  │
    └────────┬────────┘              └────────┬────────┘
             │                                │
             │ Backup Agent                   │ Backup Agent
             │                                │
             └────────────┬───────────────────┘
                          │
                          ▼
            ┌─────────────────────────────┐
            │   Commvault Backup Server   │
            │      (192.168.1.9)          │
            │                             │
            │  • CommServe                │
            │  • MediaAgent               │
            │  • Storage Pool             │
            └─────────────────────────────┘
                          │
                          ▼
                 ┌────────────────┐
                 │ Backup Storage │
                 │  /backup/...   │
                 └────────────────┘
```

## Components

### 1. Commvault Server (192.168.1.9)
- **CommServe**: Central management console
- **MediaAgent**: Backup data mover
- **Storage**: `/backup/storage` (expandable)

### 2. Commvault Agents (Web1, Web2)
- Installed on database servers
- Communicates with CommServe
- Handles database-aware backups

### 3. Native Backup (Fallback)
- **MariaBackup**: Physical backup tool
- Works independently of Commvault
- Scheduled via cron

## Installation

### Prepare Inventory

Add backup server to `inventory/hosts.yml`:

```yaml
all:
  children:
    backup_server:
      hosts:
        Backup-Server:
          ansible_host: 192.168.1.9
          ansible_user: root
```

### Deploy

```bash
# Full deployment
ansible-playbook -i inventory/hosts.yml playbooks/deploy_commvault_backup.yml

# Server only
ansible-playbook -i inventory/hosts.yml playbooks/deploy_commvault_backup.yml --tags commvault-serverAdmin123

# Agents only
ansible-playbook -i inventory/hosts.yml playbooks/deploy_commvault_backup.yml --tags commvault-client,database-backup
```

## Configuration

### Variables (`roles/commvault/defaults/main.yml`)

```yaml
# Commvault Server
commvault_server_ip: "192.168.1.9"
commvault_storage_path: "/backup/storage"

# Backup Settings
mysql_backup_dir: "/backup/mysql"
mysql_backup_retention_days: 7
mysql_backup_compress: yes

# Databases to backup
mysql_backup_databases:
  - wordpress
  - mysql
```

## Using Commvault (Commercial)

### 1. Install Commvault

```bash
# On backup server (192.168.1.9)
cd /opt/commvault
# Upload Commvault installer
./cvpkgadd

# Follow installation wizard
# Access web console: https://192.168.1.9:8403
```

### 2. Configure MySQL Backup

1. Login to Commvault Web Console
2. Navigate to **Protect > Databases > MySQL**
3. Click **Add Client**
4. Configure:
   - **Client Name**: Web1 (or Web2)
   - **MySQL Host**: 192.168.1.27
   - **Port**: 3306
   - **Username**: backup_user
   - **Password**: BackupP@ss123

5. Select databases:
   - `wordpress`
   - `mysql`

6. Set backup schedule:
   - **Full Backup**: Daily 2:00 AM
   - **Retention**: 30 days

7. Run test backup

### 3. Monitor Backups

- **Web Console**: https://192.168.1.9:8403
- **Job Monitor**: View backup jobs
- **Reports**: Backup success/failure
- **Alerts**: Email notifications

## Using Native Backup (Open-Source)

### Manual Backup

```bash
# On Web1 or Web2
sudo /usr/local/bin/mariadb_backup.sh full
```

### View Backups

```bash
# List local backups
ls -lh /backup/mysql/full/

# View backup metadata
cat /backup/mysql/full/backup_20250126_020000.metadata
```

### Restore Database

```bash
# Stop application first
sudo systemctl stop httpd

# Restore from backup
sudo /usr/local/bin/mariadb_restore.sh /backup/mysql/full/backup_20250126_020000.xbstream.gz

# Restart application
sudo systemctl start httpd
```

### Automated Backups

Backups run automatically via cron:

```bash
# View cron jobs
crontab -l

# Daily backup: 2:00 AM
0 2 * * * /usr/local/bin/mariadb_backup.sh full

# Cleanup old backups: 3:30 AM
30 3 * * * find /backup/mysql/full -name '*.xbstream.gz' -mtime +7 -delete
```

## Backup to Commvault Server

### Setup SSH Key Auth

```bash
# On Web1/Web2, copy SSH public key
cat /root/.ssh/id_rsa.pub

# On Backup Server (192.168.1.9)
mkdir -p /root/.ssh
echo "<paste-public-key>" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```

### Sync Backups

```bash
# Manual sync
/usr/local/bin/sync_to_commvault.sh /backup/mysql/full/backup_latest.xbstream.gz

# Automatic: runs after each backup
```

### Verify Sync

```bash
# On Backup Server
ls -lh /backup/storage/Web1/
ls -lh /backup/storage/Web2/
```

## Demo Scenarios

### Demo 1: Full Backup and Verify

```bash
# 1. Create test data
ansible Web1 -i inventory/hosts.yml -m shell -a "mysql -e 'CREATE DATABASE test_backup; USE test_backup; CREATE TABLE demo (id INT, data VARCHAR(100)); INSERT INTO demo VALUES (1, \"Test data\");'" -b

# 2. Run backup
ansible Web1 -i inventory/hosts.yml -m shell -a "/usr/local/bin/mariadb_backup.sh full" -b

# 3. Check backup files
ansible Web1 -i inventory/hosts.yml -m shell -a "ls -lh /backup/mysql/full/" -b

# 4. Verify on Backup Server
ansible Backup-Server -i inventory/hosts.yml -m shell -a "ls -lh /backup/storage/Web1/" -b
```

### Demo 2: Disaster Recovery

```bash
# 1. Simulate data loss
ansible Web1 -i inventory/hosts.yml -m shell -a "mysql -e 'DROP DATABASE test_backup;'" -b

# 2. Verify data is gone
ansible Web1 -i inventory/hosts.yml -m shell -a "mysql -e 'SHOW DATABASES;' | grep test_backup" -b

# 3. Find latest backup
LATEST_BACKUP=$(ansible Web1 -i inventory/hosts.yml -m shell -a "ls -t /backup/mysql/full/*.xbstream.gz | head -1" -b | grep xbstream)

# 4. Restore
ansible Web1 -i inventory/hosts.yml -m shell -a "/usr/local/bin/mariadb_restore.sh $LATEST_BACKUP" -b

# 5. Verify restoration
ansible Web1 -i inventory/hosts.yml -m shell -a "mysql -e 'SELECT * FROM test_backup.demo;'" -b
```

### Demo 3: Replication Recovery

```bash
# 1. Break replication
ansible Web2 -i inventory/hosts.yml -m shell -a "mysql -e 'STOP SLAVE;'" -b

# 2. Restore from Web1 backup to Web2
ansible Web2 -i inventory/hosts.yml -m shell -a "/usr/local/bin/mariadb_restore.sh /backup/mysql/full/backup_latest.xbstream.gz" -b

# 3. Reconfigure replication
# (see MariaDB replication docs)
```

## Monitoring

### Check Backup Status

```bash
# View backup logs
ansible web_servers -i inventory/hosts.yml -m shell -a "tail -50 /backup/mysql/logs/backup-*.log" -b

# Check disk usage
ansible web_servers -i inventory/hosts.yml -m shell -a "df -h /backup" -b

# Count backups
ansible web_servers -i inventory/hosts.yml -m shell -a "ls /backup/mysql/full/*.xbstream.gz | wc -l" -b
```

### Backup Metrics

```bash
# Latest backup size
ansible web_servers -i inventory/hosts.yml -m shell -a "du -sh /backup/mysql/full/backup_*.xbstream.gz | tail -1" -b

# Total backup storage
ansible web_servers -i inventory/hosts.yml -m shell -a "du -sh /backup/mysql/full/" -b
```

## Troubleshooting

### Backup Fails

```bash
# Check MariaDB status
systemctl status mariadb

# Verify backup user
mysql -u backup_user -p -e "SELECT 1;"

# Check disk space
df -h /backup

# Review logs
tail -100 /backup/mysql/logs/backup-$(date +%Y%m%d).log
```

### Restore Fails

```bash
# Ensure MariaDB is stopped
systemctl stop mariadb

# Check backup file integrity
file /backup/mysql/full/backup_*.xbstream.gz

# Verify permissions
ls -l /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
```

### Sync to Commvault Fails

```bash
# Test SSH connection
ssh root@192.168.1.9 "echo Connection successful"

# Check network
ping -c 3 192.168.1.9

# Verify storage path
ssh root@192.168.1.9 "ls -ld /backup/storage"
```

## Expansion: Backup Additional Components

### Web Application Files

```yaml
# Add to playbook
- name: Backup web files
  ansible.builtin.archive:
    path: /var/www/html
    dest: /backup/web/html_{{ ansible_date_time.date }}.tar.gz
```

### System Configuration

```yaml
- name: Backup /etc
  ansible.builtin.archive:
    path: /etc
    dest: /backup/config/etc_{{ ansible_date_time.date }}.tar.gz
    exclude_path:
      - /etc/shadow
      - /etc/gshadow
```

### HAProxy + Keepalived Config

```yaml
- name: Backup HA configuration
  ansible.builtin.copy:
    src: "{{ item }}"
    dest: /backup/ha/
    remote_src: yes
  loop:
    - /etc/haproxy/haproxy.cfg
    - /etc/keepalived/keepalived.conf
```

### Suricata Rules and Logs

```yaml
- name: Backup Suricata
  ansible.builtin.archive:
    path:
      - /etc/suricata/rules
      - /var/log/suricata
    dest: /backup/security/suricata_{{ ansible_date_time.date }}.tar.gz
```

## Security Best Practices

1. **Encrypt Backups**: Enable `commvault_encrypt_backup: yes`
2. **Secure Credentials**: Store passwords in Ansible Vault
3. **Restrict Access**: Limit backup directory permissions
4. **Audit Logs**: Review `/backup/mysql/logs/` regularly
5. **Test Restores**: Monthly restore tests

## Performance Tuning

```yaml
# For large databases
mysql_backup_compress: yes  # Enable compression
mariabackup_parallel: 4     # Use 4 threads
mariabackup_use_memory: 4G  # Increase buffer
```

## License

This role supports both:
- **Commvault**: Commercial license required
- **MariaBackup**: GPL v2 (open-source)

## Support

- Commvault docs: https://documentation.commvault.com
- MariaBackup docs: https://mariadb.com/kb/en/mariabackup/
- Role issues: Create issue in repository

---

**Ready to deploy? Run:**

```bash
ansible-playbook -i inventory/hosts.yml playbooks/deploy_commvault_backup.yml
```

# Database Server Role

## 📌 Overview

Triển khai **SQL Server** trên Windows hoặc **PostgreSQL/MySQL** trên Linux với automated configuration.

## 🚀 Quick Start

```bash
# SQL Server (Windows)
ansible-playbook playbooks/install_database_win.yml

# MySQL/MariaDB (Linux)
ansible-playbook playbooks/install_database_li.yml
```

## ⚙️ Variables (SQL Server)

```yaml
sqlserver_version: "2019"
sqlserver_instance_name: "MSSQLSERVER"
sqlserver_sa_password: "P@ssw0rd123!"
sqlserver_port: 1433

sqlserver_databases:
  - name: "AppDB"
    collation: "SQL_Latin1_General_CP1_CI_AS"

sqlserver_logins:
  - name: "app_user"
    password: "AppP@ss123"
    database: "AppDB"
    role: "db_owner"
```

## 🔧 Operations (SQL Server)

```powershell
# Check service
Get-Service MSSQLSERVER

# Connect
Invoke-Sqlcmd -Query "SELECT @@VERSION"

# List databases
Invoke-Sqlcmd -Query "SELECT name FROM sys.databases"

# Backup
Backup-SqlDatabase -ServerInstance "localhost" -Database "AppDB" -BackupFile "C:\Backup\AppDB.bak"
```

## 🔧 Operations (MySQL/MariaDB)

```bash
# Check service
sudo systemctl status mariadb

# Connect
mysql -u root -p

# List databases
mysql -u root -p -e "SHOW DATABASES;"

# Backup
mysqldump -u root -p AppDB > AppDB_backup.sql
```

**Last Updated**: 2025-12-27

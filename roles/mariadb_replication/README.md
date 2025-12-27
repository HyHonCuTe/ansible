# MariaDB Replication Role

## 📌 Overview

Triển khai **MariaDB Master-Slave Replication** cho high availability và read scalability.

## 🚀 Quick Start

```bash
# Deploy replication
./deploy_mariadb.sh

# Or using playbook
ansible-playbook playbooks/deploy_mariadb_replication.yml

# Verify
ansible-playbook playbooks/verify_mariadb_replication.yml
```

## ⚙️ Variables

```yaml
# Master Configuration
mariadb_server_id: 1
mariadb_bind_address: "0.0.0.0"
mariadb_log_bin: "mysql-bin"

# Replication User
mariadb_repl_user: "repl_user"
mariadb_repl_password: "secure_password"

# Databases to Replicate
mariadb_binlog_do_db:
  - "app_db"
  - "web_db"
```

## 🔧 Operations

```bash
# On Master - check status
mysql -u root -p -e "SHOW MASTER STATUS\G"

# On Slave - check status
mysql -u root -p -e "SHOW SLAVE STATUS\G"

# Check replication lag
mysql -u root -p -e "SHOW SLAVE STATUS\G" | grep Seconds_Behind_Master

# Test replication
# On Master:
mysql -u root -p
> CREATE DATABASE test_repl;
> USE test_repl;
> CREATE TABLE test (id INT);
> INSERT INTO test VALUES (1);

# On Slave:
mysql -u root -p
> USE test_repl;
> SELECT * FROM test;  # Should show the inserted row
```

## 🐛 Troubleshooting

**Replication stopped:**
```bash
# On Slave
mysql -u root -p -e "SHOW SLAVE STATUS\G" | grep -E "Slave_IO_Running|Slave_SQL_Running|Last_Error"

# Common errors:

# 1. Duplicate key error
mysql -u root -p
> STOP SLAVE;
> SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;
> START SLAVE;

# 2. Connection error
> SHOW SLAVE STATUS\G  # Check Last_IO_Error
# Verify network, firewall (port 3306)

# 3. Reset replication
> STOP SLAVE;
> RESET SLAVE;
> CHANGE MASTER TO
  MASTER_HOST='192.168.1.50',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='password',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=154;
> START SLAVE;
```

**High replication lag:**
```bash
# Check slave load
mysql -u root -p -e "SHOW PROCESSLIST;"

# Optimize queries
mysql -u root -p -e "SHOW FULL PROCESSLIST;"

# Consider parallel replication
sudo vi /etc/my.cnf.d/server.cnf
# Add:
slave-parallel-threads=4
```

## 📊 Monitoring

```bash
# Replication status
mysql -u root -p -e "SHOW SLAVE STATUS\G" | grep -E "Slave_IO|Slave_SQL|Behind_Master"

# Binary log position
mysql -u root -p -e "SHOW MASTER STATUS;"

# Connected slaves (on Master)
mysql -u root -p -e "SHOW SLAVE HOSTS;"
```

**Last Updated**: 2025-12-27

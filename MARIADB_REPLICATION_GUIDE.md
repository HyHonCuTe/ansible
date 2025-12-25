# MariaDB Replication - Quick Start Guide

Hệ thống MariaDB Primary-Replica Replication trên Web Servers với tích hợp HA Load Balancer.

## 📋 Mô Hình Hệ Thống

```
            HAProxy + Keepalived (VIP: 192.168.1.100)
                           |
                    Load Balancing
                           |
            ┌──────────────┴──────────────┐
            |                             |
    ┌───────▼────────┐           ┌───────▼────────┐
    │    Web1        │◄─────────►│    Web2        │
    │  192.168.1.27  │Replication│  192.168.1.30  │
    ├────────────────┤           ├────────────────┤
    │  Apache HTTPD  │           │  Apache HTTPD  │
    │  + PHP         │           │  + PHP         │
    ├────────────────┤           ├────────────────┤
    │  MariaDB       │           │  MariaDB       │
    │  PRIMARY       │─ Binlog ─>│  REPLICA       │
    │  Server ID: 1  │  Sync     │  Server ID: 2  │
    └────────────────┘           └────────────────┘
          Write                       Read-Only
       (Insert/Update)               (Synced Data)
```

## 🎯 Tính Năng

- ✅ MariaDB Primary-Replica replication
- ✅ Tự động đồng bộ dữ liệu (< 1 giây)
- ✅ Demo web application với PHP
- ✅ Tích hợp với HAProxy load balancer
- ✅ Database high availability
- ✅ Binary logging enabled
- ✅ Health check và monitoring

## 🚀 Triển Khai Nhanh

### 1. Kiểm tra môi trường

```bash
cd /home/ansible/Desktop/ansible

# Verify web servers are accessible
ansible web_servers -i inventory/hosts.yml -m ping
```

### 2. Deploy MariaDB Replication

```bash
# Deploy MariaDB on both servers
ansible-playbook -i inventory/hosts.yml playbooks/deploy_mariadb_replication.yml
```

Quá trình này sẽ:
- Cài đặt MariaDB trên Web1 (Primary) và Web2 (Replica)
- Cấu hình replication
- Tạo demo database `webapp_db`
- Tạo user `webapp_user`
- Thêm sample data

### 3. Deploy Web Demo

```bash
# Deploy PHP web interface
ansible-playbook -i inventory/hosts.yml playbooks/demo_mariadb_web.yml
```

### 4. Verify Replication

```bash
# Run verification tests
ansible-playbook -i inventory/hosts.yml playbooks/verify_mariadb_replication.yml
```

## 🌐 Truy Cập Hệ Thống

### Web Demo Application
- **Via VIP**: http://192.168.1.100/db-demo/
- **Primary Direct**: http://192.168.1.27/db-demo/
- **Replica Direct**: http://192.168.1.30/db-demo/

### Database Credentials

```bash
# Root access
User: root
Password: RootP@ssw0rd2025

# Application access
User: webapp_user
Password: WebApp123!
Database: webapp_db
```

## 🧪 Demo Kịch Bản

### Demo 1: Kiểm Tra Đồng Bộ Qua Web

1. **Mở 2 browser tabs:**
   - Tab 1: http://192.168.1.100/db-demo/ → Refresh cho đến thấy **WEB-1 (PRIMARY)**
   - Tab 2: http://192.168.1.100/db-demo/ → Refresh cho đến thấy **WEB-2 (REPLICA)**

2. **Thêm user trên PRIMARY:**
   - Ở tab PRIMARY, nhập username và email
   - Click "Add User"

3. **Kiểm tra REPLICA:**
   - Refresh tab REPLICA
   - User mới xuất hiện trong bảng!

4. **Xác nhận:**
   - Cột "Created On Server" hiển thị WEB-1
   - Dữ liệu đồng bộ trong < 1 giây

### Demo 2: Kiểm Tra Qua MySQL CLI

```bash
# Trên PRIMARY (Web1)
ssh ansible@192.168.1.27
mysql -u root -p'RootP@ssw0rd2025'

MariaDB> USE webapp_db;
MariaDB> INSERT INTO users (username, email, server_name) 
         VALUES ('cli_test', 'cli@test.com', 'CLI-Primary');
MariaDB> SELECT * FROM users ORDER BY id DESC LIMIT 3;
MariaDB> exit;

# Trên REPLICA (Web2)
ssh ansible@192.168.1.30
mysql -u root -p'RootP@ssw0rd2025'

MariaDB> USE webapp_db;
MariaDB> SELECT * FROM users ORDER BY id DESC LIMIT 3;
# User 'cli_test' xuất hiện!
```

### Demo 3: Kiểm Tra Replication Status

```bash
# PRIMARY Status
ssh ansible@192.168.1.27
mysql -u root -p'RootP@ssw0rd2025' -e "SHOW MASTER STATUS\G"

# Output:
# File: mysql-bin.000001
# Position: 12345

# REPLICA Status
ssh ansible@192.168.1.30
mysql -u root -p'RootP@ssw0rd2025' -e "SHOW SLAVE STATUS\G"

# Key fields:
# Slave_IO_Running: Yes
# Slave_SQL_Running: Yes
# Seconds_Behind_Master: 0
# Master_Log_File: mysql-bin.000001
```

## 🔧 Cấu Hình Chi Tiết

### MariaDB Configuration

Cấu hình được lưu tại: `/etc/my.cnf.d/server.cnf`

```ini
# PRIMARY (Web1)
server-id=1
log-bin=mysql-bin
binlog_format=ROW

# REPLICA (Web2)
server-id=2
log-bin=mysql-bin
relay-log=mysql-relay-bin
read_only=0
```

### Database Schema

```sql
-- Database: webapp_db

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    server_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE visits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    visitor_ip VARCHAR(45),
    page_url VARCHAR(255),
    server_name VARCHAR(50),
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 📊 Monitoring & Troubleshooting

### Check Service Status

```bash
# MariaDB service
ansible web_servers -i inventory/hosts.yml -m shell \
  -a "systemctl status mariadb" -b

# Replication status
ansible web_servers[1] -i inventory/hosts.yml -m shell \
  -a "mysql -u root -p'RootP@ssw0rd2025' -e 'SHOW SLAVE STATUS\G'" -b
```

### View Logs

```bash
# MariaDB logs
sudo tail -f /var/log/mariadb/mariadb.log

# Slow query log
sudo tail -f /var/log/mariadb/mariadb-slow.log

# Apache error log
sudo tail -f /var/log/httpd/error_log
```

### Common Issues

#### Replication Not Running

```bash
# On REPLICA
mysql -u root -p'RootP@ssw0rd2025'

# Stop and reset replica
STOP SLAVE;
RESET SLAVE;

# Reconfigure
CHANGE MASTER TO
  MASTER_HOST='192.168.1.27',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='Repl!c@t10n2025',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=4;

START SLAVE;
SHOW SLAVE STATUS\G;
```

#### Check Lag

```bash
# On REPLICA
mysql -u root -p'RootP@ssw0rd2025' -e "SHOW SLAVE STATUS\G" | grep Seconds_Behind_Master

# Should be 0 or very low
```

## 🎯 Performance Tuning

### Buffer Pool Size

```bash
# Edit /etc/my.cnf.d/server.cnf
innodb_buffer_pool_size = 512M  # Increase for more RAM

# Restart MariaDB
sudo systemctl restart mariadb
```

### Connection Limits

```bash
# Edit /etc/my.cnf.d/server.cnf
max_connections = 500

# Restart MariaDB
sudo systemctl restart mariadb
```

## 🔒 Security Best Practices

1. **Change default passwords** sau khi deploy
2. **Restrict network access** - chỉ cho phép traffic từ các servers cần thiết
3. **Enable SSL** cho replication traffic (advanced)
4. **Regular backups** của cả PRIMARY và REPLICA

## 📚 Tài Liệu Tham Khảo

- MariaDB Replication: https://mariadb.com/kb/en/replication/
- Binary Log: https://mariadb.com/kb/en/binary-log/
- GTID Replication: https://mariadb.com/kb/en/gtid/

## 🆘 Support

### Quick Commands

```bash
# Re-deploy everything
ansible-playbook -i inventory/hosts.yml playbooks/deploy_mariadb_replication.yml

# Re-deploy web demo only
ansible-playbook -i inventory/hosts.yml playbooks/demo_mariadb_web.yml

# Verify replication
ansible-playbook -i inventory/hosts.yml playbooks/verify_mariadb_replication.yml

# Check database content
ansible web_servers -i inventory/hosts.yml -m shell \
  -a "mysql -u root -p'RootP@ssw0rd2025' -e 'SELECT COUNT(*) FROM webapp_db.users'" -b
```

---

**Note**: Hệ thống này được thiết kế cho demo và development. Cho production, cân nhắc thêm SSL, monitoring tools (PMM), và backup automation.

# MariaDB Replication Role

Role này triển khai MariaDB với Primary-Replica replication để đảm bảo tính sẵn sàng cao cho database layer.

## Mô Tả

Role này thực hiện:
- Cài đặt MariaDB server và client
- Cấu hình Primary server với binary logging
- Cấu hình Replica server với relay logging
- Thiết lập replication user và permissions
- Tạo demo database và tables
- Deploy PHP web demo application

## Requirements

- AlmaLinux/RHEL/CentOS 8+
- Python 3
- Apache HTTPD đã được cài đặt (từ webserver_ha role)
- Firewalld service running
- Ít nhất 2 servers

## Role Variables

### defaults/main.yml

```yaml
# Replication configuration
mariadb_replication_role: ""  # "primary" or "replica"
mariadb_server_id: 1          # Must be unique per server
mariadb_primary_host: "192.168.1.27"
mariadb_replica_host: "192.168.1.30"

# Passwords
mariadb_root_password: "RootP@ssw0rd2025"
mariadb_replication_user: "replication_user"
mariadb_replication_password: "Repl!c@t10n2025"

# Demo database
demo_database_name: "webapp_db"
demo_database_user: "webapp_user"
demo_database_password: "WebApp123!"

# Performance
mariadb_innodb_buffer_pool_size: "256M"
mariadb_max_connections: 200
```

### Inventory Variables

**Quan trọng**: Phải set trong playbook khi gọi role:

```yaml
- hosts: web_servers[0]
  vars:
    mariadb_replication_role: "primary"
    mariadb_server_id: 1

- hosts: web_servers[1]
  vars:
    mariadb_replication_role: "replica"
    mariadb_server_id: 2
```

## Dependencies

- `webserver_ha` role (Apache HTTPD)
- `community.mysql` collection

## Example Playbook

```yaml
- name: Deploy MariaDB Primary
  hosts: web_servers[0]
  become: yes
  vars:
    mariadb_replication_role: "primary"
    mariadb_server_id: 1
  roles:
    - role: mariadb_replication

- name: Deploy MariaDB Replica
  hosts: web_servers[1]
  become: yes
  vars:
    mariadb_replication_role: "replica"
    mariadb_server_id: 2
  roles:
    - role: mariadb_replication
```

## Features

### Primary Server
- ✅ Binary logging enabled
- ✅ Replication user created
- ✅ Write operations allowed
- ✅ Demo database with sample data

### Replica Server
- ✅ Relay logging enabled
- ✅ Automatic sync from Primary
- ✅ Read operations
- ✅ Data consistency with Primary

### Web Demo
- ✅ PHP web interface
- ✅ Real-time data display
- ✅ Add user functionality
- ✅ Visual verification of replication

## Tasks Files

- `main.yml` - Orchestration
- `install.yml` - Install MariaDB
- `configure_primary.yml` - Setup Primary server
- `configure_replica.yml` - Setup Replica server
- `create_demo_db.yml` - Create demo database
- `deploy_web_demo.yml` - Deploy PHP web app

## Templates

- `mariadb.cnf.j2` - MariaDB server configuration
- `index_db.php.j2` - Web demo interface

## Files

- `add_user.php` - PHP script to add users
- `index.php` - Main PHP page

## Testing

### Verify Replication

```bash
# On PRIMARY
mysql -u root -p'RootP@ssw0rd2025' -e "SHOW MASTER STATUS"

# On REPLICA
mysql -u root -p'RootP@ssw0rd2025' -e "SHOW SLAVE STATUS\G"
```

### Test Data Sync

```bash
# Insert on PRIMARY
mysql -u root -p'RootP@ssw0rd2025' webapp_db \
  -e "INSERT INTO users (username, email) VALUES ('test', 'test@example.com')"

# Check on REPLICA (should appear within 1 second)
mysql -u root -p'RootP@ssw0rd2025' webapp_db \
  -e "SELECT * FROM users WHERE username='test'"
```

### Web Demo Test

1. Access: http://192.168.1.100/db-demo/
2. Refresh until you see WEB-1 (PRIMARY)
3. Add a user
4. Refresh until you see WEB-2 (REPLICA)
5. Verify user appears

## Troubleshooting

### Replication Stopped

```bash
# Check status
mysql -u root -p -e "SHOW SLAVE STATUS\G" | grep Running

# If not running
mysql -u root -p
> STOP SLAVE;
> START SLAVE;
> SHOW SLAVE STATUS\G;
```

### Sync Lag

```bash
# Check lag
mysql -u root -p -e "SHOW SLAVE STATUS\G" | grep Seconds_Behind_Master

# Should be 0 or very low
```

### Connection Issues

```bash
# Test connectivity
telnet 192.168.1.27 3306

# Check firewall
firewall-cmd --list-ports
```

## Security Notes

- Passwords are stored in defaults - **change before production**
- Replication user has minimal required permissions
- Consider SSL for replication traffic
- Root access restricted to localhost by default

## Performance Tips

- Increase `innodb_buffer_pool_size` for more RAM
- Monitor slow query log
- Use GTID replication for advanced setups
- Consider multi-master for write scaling

## License

MIT

## Author

Ansible Automation Team

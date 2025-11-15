# Grafana Role

Role Ansible để cài đặt và cấu hình Grafana với tích hợp dashboard cho các dịch vụ giám sát.

**Author:** HyHonCuTe  
**Date:** 2025-11-15  
**Version:** 1.0.0

## Mô tả

Role này tự động hóa việc cài đặt và cấu hình Grafana bao gồm:
- Cài đặt Grafana từ repository chính thức
- Cấu hình datasources (Prometheus, Zabbix)
- Cài đặt plugins cần thiết
- Import dashboards tự động
- Cấu hình bảo mật và alerting

## Yêu cầu hệ thống

- **OS:** Ubuntu 20.04+, Debian 10+, CentOS/RHEL 7+
- **RAM:** Tối thiểu 1GB
- **CPU:** Tối thiểu 1 core
- **Disk:** 5GB trống
- **Python:** 3.6+
- **Ansible:** 2.9+

## Dependencies

Roles này cần các dịch vụ sau đang chạy:
- Prometheus (cho datasource Prometheus)
- Zabbix Server (cho datasource Zabbix)
- Node Exporter (cho metrics hệ thống)

## Cấu trúc thư mục

```
grafana/
├── defaults/
│   └── main.yml              # Biến mặc định
├── files/
│   └── dashboards/           # Dashboard JSON files
│       ├── node-exporter-full.json
│       ├── prometheus-overview.json
│       ├── zabbix-server.json
│       ├── system-monitoring.json
│       └── security-monitoring.json
├── handlers/
│   └── main.yml              # Handlers cho service
├── tasks/
│   ├── main.yml              # Task chính
│   ├── install.yml           # Cài đặt Grafana
│   ├── configure.yml         # Cấu hình Grafana
│   ├── datasources.yml       # Cấu hình datasources
│   ├── plugins.yml           # Cài đặt plugins
│   └── dashboards.yml        # Import dashboards
├── templates/
│   ├── grafana.ini.j2        # Template cấu hình chính
│   ├── datasources.yml.j2    # Template datasources
│   └── dashboard-provider.yml.j2
└── README.md
```

## Biến cấu hình

### Biến cơ bản

```yaml
# Grafana version
grafana_version: "10.2.2"

# Service configuration
grafana_http_port: 3000
grafana_domain: "localhost"
grafana_root_url: "http://{{ grafana_domain }}:{{ grafana_http_port }}"

# Admin credentials
grafana_admin_user: "admin"
grafana_admin_password: "admin@123"  # ⚠️ Nên thay đổi trong production
```

### Datasources

```yaml
grafana_datasources:
  - name: "Prometheus"
    type: "prometheus"
    access: "proxy"
    url: "http://localhost:9090"
    is_default: true
    
  - name: "Zabbix"
    type: "alexanderzobnin-zabbix-datasource"
    url: "http://localhost/zabbix/api_jsonrpc.php"
    is_default: false
```

### Plugins

```yaml
grafana_plugins:
  - alexanderzobnin-zabbix-app
  - grafana-piechart-panel
  - grafana-worldmap-panel
  - grafana-clock-panel
```

## Sử dụng

### 1. Cấu hình Inventory

```yaml
# inventory/hosts.yml
monitoring_servers:
  hosts:
    grafana-server:
      ansible_host: 192.168.1.100
      ansible_user: ubuntu
```

### 2. Tạo vars file (tùy chọn)

```yaml
# host_vars/grafana-server.yml
grafana_admin_password: "MySecurePassword@2025"
grafana_domain: "grafana.example.com"
grafana_http_port: 3000

# Tùy chỉnh datasources
grafana_datasources:
  - name: "Prometheus"
    type: "prometheus"
    url: "http://prometheus.example.com:9090"
    is_default: true
  
  - name: "Zabbix"
    type: "alexanderzobnin-zabbix-datasource"
    url: "http://zabbix.example.com/api_jsonrpc.php"
    json_data:
      username: "Admin"
    secure_json_data:
      password: "zabbix_password"
```

### 3. Chạy Playbook

```bash
# Deploy Grafana
ansible-playbook playbooks/deploy-grafana.yml

# Deploy với tags cụ thể
ansible-playbook playbooks/deploy-grafana.yml --tags install
ansible-playbook playbooks/deploy-grafana.yml --tags configure
ansible-playbook playbooks/deploy-grafana.yml --tags dashboards

# Deploy với biến override
ansible-playbook playbooks/deploy-grafana.yml \
  -e "grafana_admin_password=NewPassword@123"

# Chỉ cài đặt plugins
ansible-playbook playbooks/deploy-grafana.yml --tags plugins

# Dry-run
ansible-playbook playbooks/deploy-grafana.yml --check
```

### 4. Sử dụng trong Playbook khác

```yaml
---
- name: Setup Monitoring Stack
  hosts: monitoring_servers
  become: yes
  
  roles:
    - role: prometheus
    - role: zabbix
    - role: grafana
      vars:
        grafana_admin_password: "SecurePass@2025"
```

## Dashboards được cung cấp

### 1. Node Exporter Full
- **File:** `node-exporter-full.json`
- **Mô tả:** Dashboard chi tiết cho Node Exporter metrics
- **Metrics:**
  - CPU Usage (by mode, per core)
  - Memory Usage (detailed breakdown)
  - Disk I/O & IOPS
  - Network Traffic & Packets
  - System Load & Processes
  - Filesystem Usage

### 2. Prometheus Overview
- **File:** `prometheus-overview.json`
- **Mô tả:** Tổng quan Prometheus server
- **Metrics:**
  - Target status
  - Scrape duration
  - Query rate
  - Time series count

### 3. Zabbix Server Monitoring
- **File:** `zabbix-server.json`
- **Mô tả:** Giám sát Zabbix server
- **Metrics:**
  - Monitored hosts
  - Active triggers & items
  - Problems by severity
  - Zabbix queue

### 4. System Monitoring Overview
- **File:** `system-monitoring.json`
- **Mô tả:** Tổng quan hệ thống
- **Metrics:**
  - Resource gauges (CPU, Memory, Disk)
  - Service availability
  - Performance metrics

### 5. Security Monitoring
- **File:** `security-monitoring.json`
- **Mô tả:** Dashboard bảo mật
- **Metrics:**
  - Security alerts
  - Network connections
  - Process status
  - Compliance status

## Post-Installation

### 1. Truy cập Grafana

```bash
# URL mặc định
http://your-server:3000

# Thông tin đăng nhập mặc định
Username: admin
Password: admin@123
```

### 2. Thay đổi mật khẩu admin

```bash
# Qua Web UI
1. Đăng nhập với tài khoản admin
2. Profile > Change Password

# Qua CLI
grafana-cli admin reset-admin-password <new-password>

# Qua Ansible
ansible-playbook playbooks/deploy-grafana.yml \
  -e "grafana_admin_password=NewPassword" \
  --tags configure
```

### 3. Kiểm tra datasources

```bash
# Via API
curl -u admin:admin@123 http://localhost:3000/api/datasources

# Via Web UI
Configuration > Data Sources
```

### 4. Verify dashboards

```bash
# Via API
curl -u admin:admin@123 http://localhost:3000/api/search?type=dash-db

# Via Web UI
Dashboards > Browse
```

## Bảo mật

### 1. Thay đổi mật khẩu mặc định

⚠️ **QUAN TRỌNG:** Luôn thay đổi mật khẩu mặc định trong môi trường production!

```yaml
grafana_admin_password: "StrongPassword@2025"
```

### 2. Cấu hình HTTPS

```yaml
grafana_protocol: "https"
grafana_cert_file: "/etc/grafana/grafana.crt"
grafana_cert_key: "/etc/grafana/grafana.key"
```

### 3. Cấu hình Firewall

```bash
# UFW
sudo ufw allow 3000/tcp

# Firewalld
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload

# Chỉ cho phép từ subnet cụ thể
sudo ufw allow from 192.168.1.0/24 to any port 3000
```

### 4. Cấu hình Authentication

```yaml
# LDAP/Active Directory
grafana_ldap_enabled: true
grafana_ldap_config_file: "/etc/grafana/ldap.toml"

# OAuth
grafana_oauth_enabled: true
grafana_oauth_provider: "google"  # google, github, gitlab, etc.
```

## Backup & Restore

### Backup

```bash
# Backup Grafana database
sudo cp /var/lib/grafana/grafana.db /backup/grafana.db.$(date +%Y%m%d)

# Backup cấu hình
sudo tar -czf /backup/grafana-config-$(date +%Y%m%d).tar.gz \
  /etc/grafana \
  /var/lib/grafana/plugins \
  /var/lib/grafana/dashboards

# Via Ansible
ansible-playbook playbooks/backup-grafana.yml
```

### Restore

```bash
# Stop Grafana
sudo systemctl stop grafana-server

# Restore database
sudo cp /backup/grafana.db.20251115 /var/lib/grafana/grafana.db

# Restore config
sudo tar -xzf /backup/grafana-config-20251115.tar.gz -C /

# Start Grafana
sudo systemctl start grafana-server
```

## Troubleshooting

### 1. Grafana không start

```bash
# Check logs
sudo journalctl -u grafana-server -f
sudo tail -f /var/log/grafana/grafana.log

# Check service status
sudo systemctl status grafana-server

# Check port
sudo netstat -tlnp | grep 3000
```

### 2. Datasource connection failed

```bash
# Test Prometheus
curl http://localhost:9090/-/ready

# Test Zabbix API
curl -X POST http://localhost/zabbix/api_jsonrpc.php \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"apiinfo.version","params":[],"id":1}'

# Check Grafana logs
sudo grep -i "datasource" /var/log/grafana/grafana.log
```

### 3. Dashboard không hiển thị data

```bash
# Kiểm tra datasource
curl -u admin:password http://localhost:3000/api/datasources

# Test query trực tiếp
curl -u admin:password http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up

# Check dashboard JSON
cat /var/lib/grafana/dashboards/node-exporter-full.json
```

### 4. Plugin không load

```bash
# List installed plugins
grafana-cli plugins ls

# Reinstall plugin
grafana-cli plugins uninstall alexanderzobnin-zabbix-app
grafana-cli plugins install alexanderzobnin-zabbix-app

# Restart Grafana
sudo systemctl restart grafana-server
```

## Maintenance

### Cập nhật Grafana

```bash
# Backup trước
ansible-playbook playbooks/backup-grafana.yml

# Update qua Ansible
ansible-playbook playbooks/deploy-grafana.yml \
  -e "grafana_version=10.3.0"

# Manual update (Ubuntu/Debian)
sudo apt update
sudo apt install --only-upgrade grafana
```

### Dọn dẹp old data

```bash
# Cleanup dashboard versions
grafana-cli admin data-migration cleanup-dashboard-versions

# Vacuum database
sqlite3 /var/lib/grafana/grafana.db "VACUUM;"
```

## Tags hỗ trợ

```bash
# Available tags
install         # Cài đặt Grafana
configure       # Cấu hình Grafana
datasources     # Cấu hình datasources
plugins         # Cài đặt plugins
dashboards      # Import dashboards
grafana         # Tất cả tasks
```

## Examples

### Example 1: Production deployment với SSL

```yaml
---
- hosts: grafana-prod
  become: yes
  roles:
    - role: grafana
      vars:
        grafana_admin_password: "{{ vault_grafana_password }}"
        grafana_domain: "grafana.company.com"
        grafana_protocol: "https"
        grafana_cert_file: "/etc/ssl/certs/grafana.crt"
        grafana_cert_key: "/etc/ssl/private/grafana.key"
        grafana_smtp_enabled: true
        grafana_smtp_host: "smtp.company.com:587"
```

### Example 2: Multi-datasource setup

```yaml
---
- hosts: monitoring
  become: yes
  roles:
    - role: grafana
      vars:
        grafana_datasources:
          - name: "Prometheus-DC1"
            type: "prometheus"
            url: "http://prom-dc1.local:9090"
          - name: "Prometheus-DC2"
            type: "prometheus"
            url: "http://prom-dc2.local:9090"
          - name: "Zabbix-Main"
            type: "alexanderzobnin-zabbix-datasource"
            url: "http://zabbix.local/api_jsonrpc.php"
```

## License

MIT

## Support

- **Issues:** Tạo issue trên GitHub repository
- **Documentation:** https://grafana.com/docs/
- **Community:** https://community.grafana.com/

## Changelog

### Version 1.0.0 (2025-11-15)
- Initial release
- Support Ubuntu/Debian/CentOS
- Prometheus & Zabbix datasources
- 5 pre-configured dashboards
- Auto plugin installation
- Security hardening options

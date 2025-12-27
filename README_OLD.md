# 🚀 Enterprise Ansible Automation Platform

[![Ansible](https://img.shields.io/badge/Ansible-2.14+-red.svg)](https://www.ansible.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![RHEL](https://img.shields.io/badge/RHEL-8%2B-red.svg)](https://www.redhat.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)

## 📌 Tổng quan dự án

**Enterprise Ansible Automation Platform** là giải pháp tự động hóa toàn diện cho doanh nghiệp, bao gồm triển khai, cấu hình, giám sát, bảo mật và quản lý vòng đời hạ tầng IT. Dự án hỗ trợ đầy đủ các thành phần từ infrastructure, security, monitoring đến compliance.

### 🎯 Mục tiêu chính

- **Tự động hóa 100%** quy trình triển khai và cấu hình hạ tầng
- **Security-first approach** với Wazuh, Suricata IDS/IPS, OpenSCAP
- **High Availability** cho các dịch vụ critical (HAProxy + Keepalived)
- **Comprehensive Monitoring** với Prometheus, Grafana, Zabbix
- **Compliance & Auditing** tự động với OpenSCAP và Wazuh
- **Disaster Recovery** với backup tự động và replication

### ✨ Tính năng nổi bật

- ✅ **Security Operations Center (SOC)**: Wazuh SIEM/XDR + Suricata IDS/IPS
- ✅ **High Availability Infrastructure**: HAProxy + Keepalived với VIP failover
- ✅ **Database Replication**: MariaDB Master-Slave replication
- ✅ **Full Stack Monitoring**: Prometheus + Grafana + Zabbix + OpenVAS
- ✅ **Windows Infrastructure**: Active Directory, DNS, SQL Server, IIS
- ✅ **Compliance Automation**: OpenSCAP CIS benchmarks, automated remediation
- ✅ **Backup & Recovery**: Commvault integration, automated backups
- ✅ **Patch Management**: Automated OS patching cho Linux và Windows

---

## 🏗️ Kiến trúc hệ thống

```
┌─────────────────────────────────────────────────────────────────┐
│                    ANSIBLE CONTROL NODE                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Playbooks  │  │    Roles     │  │  Inventory   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│   SECURITY    │     │ INFRASTRUCTURE│     │  MONITORING   │
├───────────────┤     ├───────────────┤     ├───────────────┤
│ • Wazuh SIEM  │     │ • HAProxy LB  │     │ • Prometheus  │
│ • Suricata IDS│     │ • Keepalived  │     │ • Grafana     │
│ • OpenSCAP    │     │ • MariaDB Rep │     │ • Zabbix      │
│ • OpenVAS     │     │ • Web Servers │     │ • OpenVAS     │
└───────────────┘     │ • Active Dir  │     └───────────────┘
                      │ • DNS/DHCP    │
                      └───────────────┘
```

### 🔧 Các thành phần chính

#### 1. **Security & Compliance** 🔒
- **Wazuh** (v4.7+): SIEM, XDR, File Integrity Monitoring, Vulnerability Detection
- **Suricata** (v7.0+): Network IDS/IPS với Emerging Threats ruleset
- **OpenSCAP**: CIS Benchmark compliance scanning và remediation
- **OpenVAS**: Vulnerability scanning và security assessment

#### 2. **High Availability Infrastructure** ⚡
- **HAProxy**: Layer 4/7 load balancer với health checks
- **Keepalived**: VRRP failover với Virtual IP
- **MariaDB Replication**: Master-Slave database replication
- **Web HA**: Multi-backend web servers với session persistence

#### 3. **Monitoring & Observability** 📊
- **Prometheus**: Metrics collection và time-series database
- **Grafana**: Visualization dashboards với alerting
- **Zabbix**: Infrastructure monitoring với auto-discovery
- **Custom Dashboards**: Pre-configured cho từng dịch vụ

#### 4. **Windows Infrastructure** 🪟
- **Active Directory**: Domain Controller deployment và configuration
- **DNS Server**: Integrated DNS với AD
- **SQL Server**: Database server với backup automation
- **IIS Web Server**: Application hosting và deployment

#### 5. **Backup & Disaster Recovery** 💾
- **Commvault Integration**: Enterprise backup solution
- **Automated Backups**: Scheduled backups cho databases và filesystems
- **Point-in-time Recovery**: Database replication và snapshots

#### 6. **Patch Management** 🔄
- **Linux Patching**: DNF/YUM automated updates với rollback
- **Windows Patching**: Windows Update automation
- **Security Updates**: Priority patching cho CVEs

---

## 🚀 Quick Start Guide

### Prerequisites

```bash
# Kiểm tra Ansible version
ansible --version  # Requires: 2.14+

# Kiểm tra Python version
python3 --version  # Requires: 3.8+

# Kiểm tra SSH key
ssh-keygen -t rsa -b 4096  # Nếu chưa có
ssh-copy-id user@target-host
```

### Cài đặt môi trường

```bash
# Clone repository
cd /home/ansible/Desktop
git clone <repository-url> ansible
cd ansible

# Cài đặt Ansible collections
ansible-galaxy collection install -r requirements.yml

# Hoặc cài thủ công
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
ansible-galaxy collection install community.windows

# Kiểm tra cấu hình
ansible --version
cat ansible.cfg
```

### Cấu hình Inventory

Xem và chỉnh sửa file `inventory/hosts.yml`:

```yaml
all:
  children:
    # Security Infrastructure
    wazuh_servers:
      hosts:
        wazuh-manager:
          ansible_host: 192.168.1.100
    
    wazuh_agents:
      hosts:
        web-server-01:
          ansible_host: 192.168.1.101
        web-server-02:
          ansible_host: 192.168.1.102
    
    security_servers:
      hosts:
        ids-server:
          ansible_host: 192.168.1.26
    
    # High Availability
    haproxy_servers:
      hosts:
        haproxy-01:
          ansible_host: 192.168.1.8
          haproxy_priority: 101
        haproxy-02:
          ansible_host: 192.168.1.25
          haproxy_priority: 100
    
    web_backends:
      hosts:
        web-01:
          ansible_host: 192.168.1.27
        web-02:
          ansible_host: 192.168.1.30
    
    # Database
    mariadb_masters:
      hosts:
        db-master:
          ansible_host: 192.168.1.50
    
    mariadb_slaves:
      hosts:
        db-slave:
          ansible_host: 192.168.1.51
    
    # Monitoring
    monitoring_servers:
      hosts:
        monitor-01:
          ansible_host: 192.168.1.200
```

### Test kết nối

```bash
# Test tất cả hosts
ansible all -m ping

# Test specific group
ansible wazuh_servers -m ping
ansible haproxy_servers -m ping

# Test với verbose
ansible all -m ping -vvv
```

---

## 📖 Deployment Scenarios

### 🔐 Scenario 1: Security Operations Center (SOC)

Triển khai full security stack với Wazuh + Suricata + OpenSCAP

#### Bước 1: Deploy Wazuh Server

```bash
# Cleanup nếu cần reinstall
ansible-playbook playbooks/cleanup_wazuh_server.yml

# Deploy Wazuh Manager, Indexer, Dashboard (10-15 phút)
ansible-playbook playbooks/deploy_wazuh_server_official.yml

# Kiểm tra credentials
cat wazuh-credentials-*.txt

# Access dashboard
# https://<WAZUH_IP>
# Username: admin
# Password: <from credentials file>
```

**Kết quả:**
- ✅ Wazuh Manager: Port 1514, 1515, 55000
- ✅ Wazuh Indexer: Port 9200
- ✅ Wazuh Dashboard: Port 443
- ✅ SSL Certificates: Auto-generated
- ✅ Credentials: Saved to file

**Kiểm tra:**
```bash
# SSH vào Wazuh server
ssh ansible@<WAZUH_IP>

# Check services
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-indexer
sudo systemctl status wazuh-dashboard

# View logs
sudo tail -f /var/ossec/logs/ossec.log
sudo journalctl -fu wazuh-manager

# Check cluster status
sudo /var/ossec/bin/cluster_control -l
```

#### Bước 2: Deploy Wazuh Agents

```bash
# Deploy agents trên tất cả servers
ansible-playbook playbooks/deploy_wazuh_agent.yml

# Hoặc chỉ Linux agents
ansible-playbook playbooks/deploy_wazuh_agent.yml --limit linux_agents

# Hoặc chỉ Windows agents
ansible-playbook playbooks/deploy_wazuh_agent.yml --limit windows_agents
```

**Kiểm tra agents:**
```bash
# Trên Wazuh Manager
sudo /var/ossec/bin/agent_control -l

# View agent details
sudo /var/ossec/bin/agent_control -i <AGENT_ID>

# Restart agent (nếu cần)
sudo /var/ossec/bin/agent_control -R <AGENT_ID>
```

#### Bước 3: Deploy Suricata IDS

```bash
# Deploy Suricata với automated script
./deploy_suricata.sh

# Hoặc dùng playbook trực tiếp
ansible-playbook playbooks/deploy_suricata_ids.yml

# Verify installation
ansible-playbook playbooks/verify_suricata_ids.yml
```

**Access Suricata Dashboard:**
- URL: `http://<IDS_SERVER>:8080/`
- Real-time alerts dashboard
- EVE JSON log viewer

**Kiểm tra Suricata:**
```bash
# SSH vào IDS server
ssh ansible@<IDS_SERVER>

# Check service
sudo systemctl status suricata

# View real-time alerts
sudo tail -f /var/log/suricata/fast.log

# View EVE JSON logs
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'

# Count alerts
sudo grep -c '"event_type":"alert"' /var/log/suricata/eve.json

# Check rules loaded
sudo suricatasc -c "ruleset-stats"

# Reload rules
sudo suricatasc -c "reload-rules"
```

**Demo attacks (testing):**
```bash
# Run attack simulations
ansible-playbook playbooks/demo_suricata_attacks.yml
```

#### Bước 4: Deploy OpenSCAP Compliance

```bash
# Run compliance scan
ansible-playbook playbooks/openscap.yml

# View reports
ls -la /tmp/openscap-reports/
```

**Kiểm tra OpenSCAP:**
```bash
# View scan results
sudo oscap info /tmp/openscap-reports/scan-report.xml

# Generate HTML report
sudo oscap xccdf generate report /tmp/openscap-reports/scan-report.xml > report.html

# Remediate issues
sudo oscap xccdf eval --remediate --profile <profile> /usr/share/xml/scap/...
```

---

### ⚡ Scenario 2: High Availability Web Infrastructure

Triển khai web infrastructure với HA load balancer + backend servers

#### Bước 1: Deploy HAProxy + Keepalived

```bash
# Deploy full HA stack với script
./deploy_ha.sh

# Hoặc dùng playbook
ansible-playbook playbooks/deploy_ha_loadbalancer.yml

# Verify deployment
ansible-playbook playbooks/verify_ha_loadbalancer.yml
```

**Kết quả:**
- ✅ HAProxy Active: 192.168.1.8
- ✅ HAProxy Standby: 192.168.1.25
- ✅ Virtual IP (VIP): 192.168.1.100
- ✅ Backend Servers: 192.168.1.27, 192.168.1.30
- ✅ HAProxy Stats: http://192.168.1.100:8888/stats

**Kiểm tra HA:**
```bash
# Kiểm tra VIP
ip addr show | grep 192.168.1.100

# Test failover
curl http://192.168.1.100

# View HAProxy stats
curl -u admin:admin http://192.168.1.100:8888/stats

# Check keepalived
sudo systemctl status keepalived
sudo tail -f /var/log/messages | grep VRRP

# Check HAProxy
sudo systemctl status haproxy
sudo tail -f /var/log/haproxy.log

# Test backend health
echo "show stat" | sudo socat stdio /run/haproxy/admin.sock
```

**Test failover:**
```bash
# Stop HAProxy trên master
sudo systemctl stop haproxy

# VIP sẽ chuyển sang backup server
# Kiểm tra VIP đã chuyển
ip addr show | grep 192.168.1.100

# Website vẫn accessible
curl http://192.168.1.100
```

#### Bước 2: Deploy Backend Web Servers

```bash
# Deploy web backends
ansible-playbook playbooks/deploy_mariadb_web.yml

# Hoặc deploy manual
ansible-playbook playbooks/install_web_win.yml --limit web_backends
```

**Kiểm tra web servers:**
```bash
# Test directly
curl http://192.168.1.27
curl http://192.168.1.30

# Test via load balancer
for i in {1..10}; do curl http://192.168.1.100; done
```

---

### 🗄️ Scenario 3: Database Replication

Triển khai MariaDB Master-Slave replication

#### Deploy MariaDB Replication

```bash
# Deploy với automated script
./deploy_mariadb.sh

# Hoặc dùng playbook
ansible-playbook playbooks/deploy_mariadb_replication.yml

# Verify replication
ansible-playbook playbooks/verify_mariadb_replication.yml
```

**Kiểm tra replication:**
```bash
# Trên Master
mysql -u root -p -e "SHOW MASTER STATUS\G"

# Trên Slave
mysql -u root -p -e "SHOW SLAVE STATUS\G"

# Test replication
# Trên Master
mysql -u root -p -e "CREATE DATABASE test_repl; USE test_repl; CREATE TABLE test (id INT); INSERT INTO test VALUES (1);"

# Trên Slave
mysql -u root -p -e "USE test_repl; SELECT * FROM test;"
```

**Troubleshooting replication:**
```bash
# Nếu Slave bị lỗi
mysql -u root -p

# Stop slave
STOP SLAVE;

# Reset slave
RESET SLAVE;

# Re-configure
CHANGE MASTER TO MASTER_HOST='<master_ip>', 
  MASTER_USER='repl_user', 
  MASTER_PASSWORD='<password>',
  MASTER_LOG_FILE='<binlog_file>',
  MASTER_LOG_POS=<position>;

# Start slave
START SLAVE;

# Check status
SHOW SLAVE STATUS\G
```

---

### 📊 Scenario 4: Full Monitoring Stack

Triển khai Prometheus + Grafana + Zabbix

#### Deploy Monitoring

```bash
# Deploy Prometheus
ansible-playbook playbooks/deploy-prometheus.yml

# Deploy Grafana
ansible-playbook playbooks/deploy-grafana.yml

# Deploy Zabbix
ansible-playbook playbooks/deploy-zabbix-server.yml
ansible-playbook playbooks/deploy-zabbix-agent.yml

# Deploy OpenVAS
ansible-playbook playbooks/deploy-openvas.yml
```

**Access Dashboards:**

**Prometheus:**
- URL: `http://<PROMETHEUS_IP>:9090`
- Targets: http://<IP>:9090/targets
- Queries: PromQL

**Grafana:**
- URL: `http://<GRAFANA_IP>:3000`
- Username: admin
- Password: (from deployment output)
- Pre-configured dashboards imported

**Zabbix:**
- URL: `http://<ZABBIX_IP>/zabbix`
- Username: Admin  
- Password: zabbix (change on first login)

**OpenVAS:**
- URL: `https://<OPENVAS_IP>:9392`
- Username: admin
- Password: (from deployment output)

**Kiểm tra Monitoring:**
```bash
# Prometheus
curl http://localhost:9090/-/healthy
curl http://localhost:9090/api/v1/targets

# Grafana
sudo systemctl status grafana-server
sudo tail -f /var/log/grafana/grafana.log

# Zabbix
sudo systemctl status zabbix-server
sudo tail -f /var/log/zabbix/zabbix_server.log

# Check agents
zabbix_agentd -t system.cpu.load[all,avg1]
```

---

### 🪟 Scenario 5: Windows Infrastructure

Triển khai Active Directory + DNS + SQL Server + IIS

#### Deploy Windows Infrastructure

```bash
# Deploy Active Directory
ansible-playbook playbooks/deploy_adds.yml

# Configure AD + DNS
ansible-playbook playbooks/configure_adds_dns.yml

# Validate deployment
ansible-playbook playbooks/validate_adds_dns.yml

# Deploy SQL Server
ansible-playbook playbooks/install_database_win.yml

# Deploy IIS Web Server
ansible-playbook playbooks/install_web_win.yml

# Deploy Backup
ansible-playbook playbooks/install_backupDBwin.yml
```

**Kiểm tra Windows Services:**
```powershell
# Check AD DS
Get-Service NTDS
Get-ADDomainController

# Check DNS
Get-Service DNS
Get-DnsServerZone

# Check SQL Server
Get-Service MSSQLSERVER
Invoke-Sqlcmd -Query "SELECT @@VERSION"

# Check IIS
Get-Service W3SVC
Get-Website
```

---

### 🔄 Scenario 6: Patch Management

Automated patching cho Linux và Windows

#### Patch Linux Systems

```bash
# Patch tất cả Linux servers
ansible-playbook playbooks/patch_linux.yml

# Patch specific group
ansible-playbook playbooks/patch_linux.yml --limit web_servers

# Dry-run (check only)
ansible-playbook playbooks/patch_linux.yml --check

# Verbose mode
ansible-playbook playbooks/patch_linux.yml -vvv
```

**Kiểm tra updates:**
```bash
# Check available updates
sudo dnf check-update

# View installed packages
sudo dnf list installed

# View update history
sudo dnf history

# Rollback if needed
sudo dnf history undo <transaction_id>
```

#### Patch Windows Systems

```bash
# Patch tất cả Windows servers
ansible-playbook playbooks/patch_window.yaml

# Patch specific servers
ansible-playbook playbooks/patch_window.yaml --limit windows_servers
```

**Kiểm tra Windows Updates:**
```powershell
# Check update history
Get-HotFix | Sort-Object -Property InstalledOn -Descending

# Check pending updates
Get-WindowsUpdate

# View Windows Update log
Get-WindowsUpdateLog
```

---

### 💾 Scenario 7: Backup & Recovery

Automated backup deployment

#### Deploy Backup Solutions

```bash
# Linux backup
ansible-playbook playbooks/install_backup_li.yml

# Windows DB backup
ansible-playbook playbooks/install_backupDBwin.yml

# Commvault backup (Enterprise)
ansible-playbook playbooks/deploy_commvault_backup.yml

# Demo backup
ansible-playbook playbooks/demo_backup.yml
```

**Kiểm tra backups:**
```bash
# Linux backups
ls -lh /backup/
sudo systemctl status backup.service

# View backup logs
sudo tail -f /var/log/ansible_backup.log

# Test restore
tar -tzf /backup/backup-<date>.tar.gz
```

---

## ⚙️ Chức năng chính

### 1. Wazuh Deployment ⭐ NEW: Deploy Wazuh Server (Official Script) và Agents (Ansible) cho security monitoring và threat detection.
- **Backup**: Sao lưu và phục hồi dữ liệu cho Linux và SQL Server.
- **Common**: Các tác vụ chung như kiểm tra kết nối.
- **Database**: Cài đặt SQL Server, tạo cơ sở dữ liệu, cấu hình ban đầu.
- **DHCP**: Cài đặt và cấu hình dịch vụ DHCP, bao gồm failover, chính sách, bảo mật.
- **DNS**: Cài đặt và cấu hình DNS Server, tạo các zone, flush cache.
- **Firewall**: Cấu hình tường lửa (Firewalld) để bảo vệ hệ thống.
- **Monitoring**: Deploy Prometheus, Grafana, Zabbix, OpenVAS cho giám sát và vulnerability scanning.
- **Patching**: Cập nhật và vá bảo mật cho Linux và Windows.
- **Suricata**: Cài đặt và cấu hình IDS Suricata.
- **User**: Quản lý người dùng và quyền truy cập.
- **Webserver**: Triển khai Web Server (IIS, HTML site, ứng dụng zip).
- **Security Compliance**: OpenSCAP scanning cho CIS compliance checking.
- **Security & Threat Detection**: Tích hợp script Python để phát hiện mối đe dọa qua Suricata log và VirusTotal API.

---

## 🚀 QUICK START - WAZUH DEPLOYMENT (RECOMMENDED)

### 🎯 Hybrid Approach: Official Script + Ansible

**Best Practice:** Dùng Official Wazuh Script cho Server, Ansible cho Agents

#### Bước 1: Cleanup (nếu cần)
```bash
ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml
```

#### Bước 2: Deploy Wazuh Server (10-15 phút) ⭐
```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml
```

**Kết quả:**
- ✅ Wazuh Manager, Indexer, Dashboard đã cài đặt
- ✅ SSL certificates tự động generate
- ✅ Credentials được lưu tại: `./wazuh-credentials-<hostname>.txt`
- 🌐 Dashboard: `https://<SERVER_IP>`

#### Bước 3: Deploy Wazuh Agents
```bash
# Cập nhật wazuh_manager_ip trong inventory.ini
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml
```

📖 **Chi tiết:** Xem [QUICKSTART.md](QUICKSTART.md)

---

## 📂 Cấu trúc thư mục

```plaintext
.
├── ansible.cfg                 # Cấu hình Ansible
├── README.md                   # Tài liệu dự án (BẠN ĐANG Ở ĐÂY)
├── QUICKSTART.md               # Hướng dẫn nhanh Wazuh deployment
├── WAZUH_DEPLOYMENT_GUIDE.md   # Chi tiết triển khai Wazuh
├── inventory.ini               # Inventory chính
├── config.yml                  # Cấu hình dự án
├── .vscode/                    # Cấu hình VS Code
├── host_vars/                  # Biến dành cho từng host
├── inventory/                  # Danh sách host
│   └── hosts.yml
├── log/
│   └── ansible_backup.log      # Log sao lưu
├── playbooks/                  # Playbooks chính
│   ├── deploy_wazuh_server_official.yml  ⭐ NEW
│   ├── deploy_wazuh_server.yml          (deprecated)
│   ├── deploy_wazuh_agent.yml
│   ├── cleanup_wazuh_server.yml
│   ├── deploy-prometheus.yml
│   ├── deploy-grafana.yml
│   ├── deploy-zabbix.yml
│   ├── deploy-openvas.yml
│   ├── openscap.yml
│   ├── patch_linux.yml
│   ├── patch_window.yaml
│   ├── install_backup_li.yml
│   ├── install_backupDBwin.yml
│   ├── install_database_win.yml
│   ├── install_dns_win.yml
│   ├── install_firewall_li.yml
│   ├── install_suricata_li.yml
│   ├── install_user_li.yml
│   ├── install_web_win.yml
│   └── ping.yml
├── py_script/                  # Script Python hỗ trợ
│   ├── detect_threats_vt.py
│   └── get_suricata_logs.py
└── roles/                      # Các role của Ansible
    ├── wazuh/                  ⭐ Wazuh Security Platform
    ├── prometheus/             # Prometheus monitoring
    ├── grafana/                # Grafana dashboards
    ├── zabbix/                 # Zabbix monitoring
    ├── openvas/                # OpenVAS vulnerability scanner
    ├── openscap/               # OpenSCAP compliance scanning
    ├── backup/                 # Sao lưu và phục hồi
    ├── common/                 # Tác vụ chung
    ├── database/               # SQL Server deployment
    ├── dhcp/                   # DHCP configuration
    ├── dns/                    # DNS configuration
    ├── firewall/               # Firewall rules
    ├── patching/               # System patching
    ├── suricata/               # Suricata IDS
    ├── user/                   # User management
    └── webserver/              # Web server deployment
```

---

## 🚀 Cách sử dụng

### 1. Setup Ansible Environment
```bash
# Clone repository
cd /home/server_ansible/Desktop/ansible

# Cài đặt Ansible (nếu chưa có)
sudo dnf install -y ansible

# Cài đặt collections cần thiết
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

### 2. Cấu hình Inventory
```bash
# Sửa file inventory.ini
nano inventory.ini

# Thêm hosts và cấu hình
[wazuh_server]
wazuh-server ansible_host=192.168.1.100

[wazuh_agents]
web-server ansible_host=192.168.1.101
db-server ansible_host=192.168.1.102
```

### 3. Test Connectivity
```bash
ansible all -i inventory.ini -m ping
```

### 4. Deploy Services

#### Wazuh (Security Monitoring) ⭐
```bash
# Server
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml

# Agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml
```

#### Monitoring Stack
```bash
# Prometheus + Grafana
ansible-playbook -i inventory.ini playbooks/deploy-prometheus.yml
ansible-playbook -i inventory.ini playbooks/deploy-grafana.yml

# Zabbix
ansible-playbook -i inventory.ini playbooks/deploy-zabbix.yml

# OpenVAS
ansible-playbook -i inventory.ini playbooks/deploy-openvas.yml
```

#### Security & Compliance
```bash
# OpenSCAP scanning
ansible-playbook -i inventory.ini playbooks/openscap.yml

# Suricata IDS
ansible-playbook -i inventory.ini playbooks/install_suricata_li.yml

# Firewall
ansible-playbook -i inventory.ini playbooks/install_firewall_li.yml
```

#### Infrastructure
```bash
# DNS Server
ansible-playbook -i inventory.ini playbooks/install_dns_win.yml

# Web Server
ansible-playbook -i inventory.ini playbooks/install_web_win.yml

# Database
ansible-playbook -i inventory.ini playbooks/install_database_win.yml
```

#### Patching
```bash
# Linux
ansible-playbook -i inventory.ini playbooks/patch_linux.yml

# Windows
ansible-playbook -i inventory.ini playbooks/patch_window.yaml
```

#### Backup
```bash
# Linux backup
ansible-playbook -i inventory.ini playbooks/install_backup_li.yml

# Windows DB backup
ansible-playbook -i inventory.ini playbooks/install_backupDBwin.yml
```

---

## 📊 Available Playbooks

| Playbook | Mô tả | Thời gian |
|----------|-------|-----------|
| `deploy_wazuh_server_official.yml` ⭐ | Deploy Wazuh Server (Official Script) | 10-15 min |
| `deploy_wazuh_agent.yml` | Deploy Wazuh Agents | 5-10 min/agent |
| `cleanup_wazuh_server.yml` | Cleanup Wazuh installation | 2-3 min |
| `deploy-prometheus.yml` | Deploy Prometheus | 5-10 min |
| `deploy-grafana.yml` | Deploy Grafana | 5-10 min |
| `deploy-zabbix.yml` | Deploy Zabbix | 10-15 min |
| `deploy-openvas.yml` | Deploy OpenVAS | 15-20 min |
| `openscap.yml` | Run OpenSCAP compliance scan | 5-10 min |
| `install_suricata_li.yml` | Install Suricata IDS | 10-15 min |
| `install_firewall_li.yml` | Configure firewall | 2-5 min |
| `patch_linux.yml` | Patch Linux systems | 10-30 min |
| `patch_window.yaml` | Patch Windows systems | 15-40 min |

---

## 🔒 Security Features

### 1. Wazuh Security Platform
- **SIEM**: Security Information and Event Management
- **XDR**: Extended Detection and Response
- **File Integrity Monitoring**: Detect unauthorized file changes
- **Vulnerability Detection**: Scan for CVEs
- **Log Analysis**: Centralized log management
- **Compliance**: PCI-DSS, GDPR, HIPAA, NIST 800-53

### 2. Suricata IDS
- **Network Intrusion Detection**
- **Real-time threat detection**
- **Integration với VirusTotal API**

### 3. OpenSCAP
- **CIS Benchmarks compliance**
- **OVAL vulnerability scanning**
- **Automated remediation**

### 4. OpenVAS
- **Vulnerability scanning**
- **Network security assessment**
- **Report generation**

---

## 📈 Monitoring Features

### Prometheus
- Metrics collection
- Time-series database
- Alerting

### Grafana
- Beautiful dashboards
- Visualization
- Multi-source data

### Zabbix
- Infrastructure monitoring
- Auto-discovery
- Problem detection

---

## 🐍 Python Scripts

### detect_threats_vt.py
Phát hiện mối đe dọa từ Suricata logs qua VirusTotal API

```bash
python3 py_script/detect_threats_vt.py --log-file /var/log/suricata/eve.json
```

### get_suricata_logs.py
Lấy và phân tích Suricata logs

```bash
python3 py_script/get_suricata_logs.py --output /tmp/suricata_analysis.json
```

---

## 📖 Documentation

- **Quick Start**: [QUICKSTART.md](QUICKSTART.md) - Hướng dẫn nhanh Wazuh
- **Deployment Guide**: [WAZUH_DEPLOYMENT_GUIDE.md](WAZUH_DEPLOYMENT_GUIDE.md) - Chi tiết triển khai
- **Official Wazuh Docs**: https://documentation.wazuh.com/
- **Ansible Docs**: https://docs.ansible.com/

---

## 🆘 Troubleshooting

### Wazuh Issues
```bash
# Xem service status
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard

# Xem logs
sudo journalctl -fu wazuh-manager.service
sudo tail -f /var/ossec/logs/ossec.log

# List agents
sudo /var/ossec/bin/agent_control -l
```

### Ansible Issues
```bash
# Test connectivity
ansible all -i inventory.ini -m ping

# Verbose mode
ansible-playbook -i inventory.ini playbooks/<playbook>.yml -vvv

# Syntax check
ansible-playbook --syntax-check playbooks/<playbook>.yml
```

---

## 🎯 Use Cases

### 1. Security Operations Center (SOC)
```bash
# Deploy Wazuh for centralized security monitoring
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml

# Deploy Suricata for network monitoring
ansible-playbook -i inventory.ini playbooks/install_suricata_li.yml

# Integrate with VirusTotal
python3 py_script/detect_threats_vt.py
```

### 2. Infrastructure Monitoring
```bash
# Deploy full monitoring stack
ansible-playbook -i inventory.ini playbooks/deploy-prometheus.yml
ansible-playbook -i inventory.ini playbooks/deploy-grafana.yml
ansible-playbook -i inventory.ini playbooks/deploy-zabbix.yml
```

### 3. Compliance & Vulnerability Management
```bash
# OpenSCAP compliance scanning
ansible-playbook -i inventory.ini playbooks/openscap.yml

# OpenVAS vulnerability scanning
ansible-playbook -i inventory.ini playbooks/deploy-openvas.yml
```

### 4. Patch Management
```bash
# Automated patching
ansible-playbook -i inventory.ini playbooks/patch_linux.yml
ansible-playbook -i inventory.ini playbooks/patch_window.yaml
```

---

## 📜 Ghi chú

* **Wazuh Deployment**: Khuyến nghị dùng `deploy_wazuh_server_official.yml` (Official Script) cho production
* Thư mục `py_script/` chứa các script Python có thể chạy độc lập hoặc tích hợp vào playbook
* Log sao lưu được lưu trong `log/ansible_backup.log`
* Mỗi role có thể tái sử dụng cho nhiều môi trường khác nhau bằng cách thay đổi biến trong `vars/`
* Credentials được lưu an toàn trong các file riêng biệt với mode 0600

---

## 🔧 Requirements

- **Ansible**: >= 2.12
- **Python**: >= 3.8
- **OS Support**:
  - Linux: RHEL/CentOS/AlmaLinux 8+, Ubuntu 20.04+, Debian 11+
  - Windows: Server 2019, 2022
- **Minimum Hardware** (cho Wazuh Server):
  - RAM: 4GB (8GB recommended)
  - CPU: 2 cores (4 cores recommended)
  - Disk: 50GB free space

---

## 👨‍💻 Tác giả

**Võ Đào Huy Hoàng**  
Tự động hóa hạ tầng và bảo mật với Ansible

📧 Contact: [Your email]  
🔗 GitHub: [Your GitHub]

---

## 📝 License

MIT License - Tự do sử dụng và chỉnh sửa

---

**⭐ Star this project if you find it useful!**
````


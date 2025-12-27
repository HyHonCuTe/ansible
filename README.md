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

## 📂 Cấu trúc dự án

```plaintext
ansible/
├── README.md                          # Tài liệu chính
├── ansible.cfg                        # Cấu hình Ansible
├── requirements.yml                   # Ansible collections
│
├── inventory/                         # Inventory files
│   └── hosts.yml                      # Main inventory
│
├── playbooks/                         # Ansible playbooks
│   ├── deploy_wazuh_server_official.yml
│   ├── deploy_wazuh_agent.yml
│   ├── cleanup_wazuh_server.yml
│   ├── deploy_ha_loadbalancer.yml
│   ├── verify_ha_loadbalancer.yml
│   ├── deploy_mariadb_replication.yml
│   ├── verify_mariadb_replication.yml
│   ├── deploy_suricata_ids.yml
│   ├── verify_suricata_ids.yml
│   ├── demo_suricata_attacks.yml
│   ├── deploy_adds.yml
│   ├── configure_adds_dns.yml
│   ├── validate_adds_dns.yml
│   ├── deploy-prometheus.yml
│   ├── deploy-grafana.yml
│   ├── deploy-zabbix-server.yml
│   ├── deploy-openvas.yml
│   ├── openscap.yml
│   ├── patch_linux.yml
│   ├── patch_window.yaml
│   ├── install_backup_li.yml
│   ├── deploy_commvault_backup.yml
│   └── ping.yml
│
├── roles/                             # Ansible roles
│   ├── wazuh/                         # Wazuh SIEM/XDR
│   ├── suricata/                      # Suricata IDS/IPS
│   ├── haproxy_lb/                    # HAProxy Load Balancer
│   ├── keepalived_ha/                 # Keepalived HA
│   ├── mariadb_replication/           # MariaDB Replication
│   ├── webserver_ha/                  # HA Web Servers
│   ├── adds/                          # Active Directory
│   ├── dns/                           # DNS Server
│   ├── database/                      # SQL Server
│   ├── webserver/                     # IIS Web Server
│   ├── prometheus/                    # Prometheus monitoring
│   ├── grafana/                       # Grafana dashboards
│   ├── zabbix/                        # Zabbix monitoring
│   ├── openvas/                       # OpenVAS scanner
│   ├── openscap/                      # OpenSCAP compliance
│   ├── patching/                      # Patch management
│   ├── backup/                        # Backup automation
│   ├── commvault/                     # Commvault integration
│   ├── firewall/                      # Firewall configuration
│   ├── dhcp/                          # DHCP server
│   ├── user/                          # User management
│   └── common/                        # Common tasks
│
├── py_script/                         # Python utilities
│   ├── detect_threats_vt.py           # VirusTotal threat detection
│   └── get_suricata_logs.py           # Suricata log parser
│
├── log/                               # Log files
│   └── ansible_backup.log
│
├── deploy_ha.sh                       # HA deployment script
├── deploy_mariadb.sh                  # MariaDB deployment script
├── deploy_suricata.sh                 # Suricata deployment script
│
└── Documentation/                     # Additional docs
    ├── QUICKSTART.md
    ├── WAZUH_DEPLOYMENT_GUIDE.md
    ├── WAZUH_TROUBLESHOOTING.md
    ├── WAZUH_USAGE.md
    ├── HA_LOADBALANCER_QUICKSTART.md
    ├── HA_ARCHITECTURE.md
    ├── MARIADB_REPLICATION_GUIDE.md
    ├── SURICATA_IDS_GUIDE.md
    ├── SURICATA_DEPLOYMENT_SUMMARY.md
    ├── ADDS_DNS_QUICKSTART.md
    └── ADDS_DNS_SUMMARY.md
```

---

## 🚀 Quick Start Guide

### Prerequisites

**Control Node Requirements:**
- OS: RHEL/CentOS/AlmaLinux 8+ hoặc Ubuntu 20.04+
- Ansible: 2.14+
- Python: 3.8+
- SSH access đến tất cả managed nodes
- Internet connection (để download packages)

**Managed Nodes Requirements:**
- Linux: RHEL/CentOS/AlmaLinux 8+, Ubuntu 20.04+, Debian 11+
- Windows: Server 2019, Server 2022
- SSH/WinRM configured
- Sudo/Administrator privileges

### Cài đặt môi trường

#### 1. Clone Repository

```bash
cd /home/ansible/Desktop
git clone <repository-url> ansible
cd ansible
```

#### 2. Cài đặt Ansible

```bash
# RHEL/CentOS/AlmaLinux
sudo dnf install -y ansible-core

# Ubuntu/Debian
sudo apt update
sudo apt install -y ansible

# Verify installation
ansible --version
```

#### 3. Cài đặt Collections

```bash
# Install từ requirements file
ansible-galaxy collection install -r requirements.yml

# Hoặc cài thủ công
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
ansible-galaxy collection install community.windows
ansible-galaxy collection install community.mysql
ansible-galaxy collection install community.postgresql
```

#### 4. Setup SSH Keys

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "ansible@control"

# Copy to managed nodes
ssh-copy-id user@192.168.1.100
ssh-copy-id user@192.168.1.101

# Test SSH
ssh user@192.168.1.100 'echo "SSH OK"'
```

#### 5. Configure Inventory

Edit `inventory/hosts.yml`:

```yaml
all:
  vars:
    ansible_user: ansible
    ansible_python_interpreter: /usr/bin/python3
  
  children:
    # Security Infrastructure
    wazuh_servers:
      hosts:
        wazuh-manager:
          ansible_host: 192.168.1.100
    
    wazuh_agents:
      children:
        linux_agents:
          hosts:
            web-01: {ansible_host: 192.168.1.101}
            web-02: {ansible_host: 192.168.1.102}
        
        windows_agents:
          hosts:
            win-server:
              ansible_host: 192.168.1.103
              ansible_connection: winrm
              ansible_winrm_server_cert_validation: ignore
    
    security_servers:
      hosts:
        ids-server:
          ansible_host: 192.168.1.26
          suricata_interface: ens192
    
    # High Availability
    haproxy_servers:
      hosts:
        haproxy-01:
          ansible_host: 192.168.1.8
          haproxy_priority: 101  # Master
          haproxy_state: MASTER
        haproxy-02:
          ansible_host: 192.168.1.25
          haproxy_priority: 100  # Backup
          haproxy_state: BACKUP
      vars:
        haproxy_vip: 192.168.1.100
        haproxy_vip_interface: ens192
    
    web_backends:
      hosts:
        web-01: {ansible_host: 192.168.1.27}
        web-02: {ansible_host: 192.168.1.30}
    
    # Database Replication
    mariadb_masters:
      hosts:
        db-master: {ansible_host: 192.168.1.50}
    
    mariadb_slaves:
      hosts:
        db-slave: {ansible_host: 192.168.1.51}
    
    # Monitoring
    monitoring_servers:
      hosts:
        prometheus: {ansible_host: 192.168.1.200}
        grafana: {ansible_host: 192.168.1.201}
        zabbix: {ansible_host: 192.168.1.202}
```

#### 6. Test Connectivity

```bash
# Test all hosts
ansible all -m ping

# Test specific groups
ansible wazuh_servers -m ping
ansible haproxy_servers -m ping
ansible web_backends -m ping

# Verbose output
ansible all -m ping -vvv

# Check Python
ansible all -m setup -a "filter=ansible_python_version"
```

---

## 📖 Deployment Guides

### 🔐 Security Stack

Xem documentation chi tiết:
- [WAZUH_DEPLOYMENT_GUIDE.md](WAZUH_DEPLOYMENT_GUIDE.md) - Full Wazuh deployment guide
- [SURICATA_IDS_GUIDE.md](SURICATA_IDS_GUIDE.md) - Suricata IDS/IPS setup
- [Quick Start - Wazuh](QUICKSTART.md) - Wazuh quick start

**Deploy Security Stack:**

```bash
# 1. Deploy Wazuh Server
ansible-playbook playbooks/deploy_wazuh_server_official.yml

# 2. Deploy Wazuh Agents
ansible-playbook playbooks/deploy_wazuh_agent.yml

# 3. Deploy Suricata IDS
./deploy_suricata.sh

# 4. Run Compliance Scan
ansible-playbook playbooks/openscap.yml

# 5. Deploy OpenVAS
ansible-playbook playbooks/deploy-openvas.yml
```

### ⚡ High Availability Stack

Xem documentation chi tiết:
- [HA_LOADBALANCER_QUICKSTART.md](HA_LOADBALANCER_QUICKSTART.md) - HAProxy + Keepalived guide
- [HA_ARCHITECTURE.md](HA_ARCHITECTURE.md) - HA architecture overview
- [MARIADB_REPLICATION_GUIDE.md](MARIADB_REPLICATION_GUIDE.md) - Database replication

**Deploy HA Stack:**

```bash
# 1. Deploy HAProxy + Keepalived
./deploy_ha.sh

# 2. Verify HA
ansible-playbook playbooks/verify_ha_loadbalancer.yml

# 3. Deploy MariaDB Replication
./deploy_mariadb.sh

# 4. Verify Replication
ansible-playbook playbooks/verify_mariadb_replication.yml

# 5. Deploy Web Backends
ansible-playbook playbooks/demo_mariadb_web.yml
```

### 📊 Monitoring Stack

**Deploy Monitoring:**

```bash
# 1. Deploy Prometheus
ansible-playbook playbooks/deploy-prometheus.yml

# 2. Deploy Grafana
ansible-playbook playbooks/deploy-grafana.yml

# 3. Deploy Zabbix
ansible-playbook playbooks/deploy-zabbix-server.yml
ansible-playbook playbooks/deploy-zabbix-agent.yml

# 4. Deploy OpenVAS
ansible-playbook playbooks/deploy-openvas.yml
```

### 🪟 Windows Infrastructure

Xem documentation chi tiết:
- [ADDS_DNS_QUICKSTART.md](ADDS_DNS_QUICKSTART.md) - Active Directory deployment
- [ADDS_DNS_SUMMARY.md](ADDS_DNS_SUMMARY.md) - AD DS architecture

**Deploy Windows Stack:**

```bash
# 1. Deploy Active Directory
ansible-playbook playbooks/deploy_adds.yml

# 2. Configure AD + DNS
ansible-playbook playbooks/configure_adds_dns.yml

# 3. Validate
ansible-playbook playbooks/validate_adds_dns.yml

# 4. Deploy SQL Server
ansible-playbook playbooks/install_database_win.yml

# 5. Deploy IIS
ansible-playbook playbooks/install_web_win.yml
```

---

## 🛠️ Operations & Maintenance

### Daily Operations

#### Check System Health

```bash
# Wazuh
ansible wazuh_servers -m shell -a "systemctl status wazuh-manager" -b
ansible wazuh_agents -m shell -a "systemctl status wazuh-agent" -b

# HAProxy
ansible haproxy_servers -m shell -a "systemctl status haproxy keepalived" -b

# Suricata
ansible security_servers -m shell -a "systemctl status suricata" -b

# Databases
ansible mariadb_masters,mariadb_slaves -m shell -a "systemctl status mariadb" -b
```

#### View Logs

```bash
# Wazuh logs
ansible wazuh_servers -m shell -a "tail -50 /var/ossec/logs/ossec.log" -b

# HAProxy logs
ansible haproxy_servers -m shell -a "tail -50 /var/log/haproxy.log" -b

# Suricata alerts
ansible security_servers -m shell -a "tail -50 /var/log/suricata/fast.log" -b

# MariaDB logs
ansible mariadb_masters -m shell -a "tail -50 /var/log/mariadb/mariadb.log" -b
```

#### Monitor Resources

```bash
# CPU, Memory, Disk
ansible all -m shell -a "top -bn1 | head -20"
ansible all -m shell -a "free -h"
ansible all -m shell -a "df -h"

# Network
ansible all -m shell -a "ss -tulnp"
ansible all -m shell -a "netstat -i"
```

### Weekly Maintenance

```bash
# Update systems
ansible-playbook playbooks/patch_linux.yml --check
ansible-playbook playbooks/patch_window.yaml --check

# Run backups
ansible-playbook playbooks/install_backup_li.yml

# Compliance scan
ansible-playbook playbooks/openscap.yml

# Vulnerability scan
# Access OpenVAS UI and run scans
```

### Monthly Tasks

```bash
# Full system audit
ansible all -m setup > system-audit-$(date +%Y%m%d).json

# Review logs
ansible all -m shell -a "journalctl --since '1 month ago' --priority=err | wc -l"

# Capacity planning
ansible all -m shell -a "df -h | grep -v tmpfs"
ansible all -m shell -a "free -h"

# Security review
# Review Wazuh alerts
# Review Suricata logs  
# Review OpenSCAP results
```

---

## 🆘 Troubleshooting

### Common Issues

#### Ansible Connection Issues

**Problem:** Cannot connect to managed nodes

**Solution:**
```bash
# Test SSH manually
ssh user@target-host

# Check SSH config
cat ~/.ssh/config

# Test with verbose
ansible all -m ping -vvv

# Check inventory
ansible-inventory --list

# Verify Python
ansible all -m shell -a "which python3"
```

#### Wazuh Issues

**Problem:** Wazuh Manager không start

**Solution:**
```bash
# Check service status
sudo systemctl status wazuh-manager

# View logs
sudo tail -100 /var/ossec/logs/ossec.log
sudo journalctl -fu wazuh-manager

# Check configuration
sudo /var/ossec/bin/ossec-logtest

# Restart service
sudo systemctl restart wazuh-manager

# Check cluster
sudo /var/ossec/bin/cluster_control -l
```

**Problem:** Agents không kết nối

**Solution:**
```bash
# On Manager - list agents
sudo /var/ossec/bin/agent_control -l

# Check agent details
sudo /var/ossec/bin/agent_control -i AGENT_ID

# On Agent - check status
sudo systemctl status wazuh-agent
sudo tail -50 /var/ossec/logs/ossec.log

# Check firewall
sudo firewall-cmd --list-all

# Restart agent
sudo systemctl restart wazuh-agent
```

#### HAProxy Issues

**Problem:** VIP không failover

**Solution:**
```bash
# Check Keepalived
sudo systemctl status keepalived
sudo tail -50 /var/log/messages | grep VRRP

# Check VIP
ip addr show | grep 192.168.1.100

# Check priority
cat /etc/keepalived/keepalived.conf | grep priority

# Force failover
sudo systemctl stop keepalived  # On master

# Test
curl http://192.168.1.100
```

**Problem:** Backends không healthy

**Solution:**
```bash
# Check HAProxy stats
echo "show stat" | sudo socat stdio /run/haproxy/admin.sock

# Check backend health
curl http://192.168.1.27
curl http://192.168.1.30

# View HAProxy logs
sudo tail -100 /var/log/haproxy.log

# Reload configuration
sudo systemctl reload haproxy
```

#### Suricata Issues

**Problem:** Không có alerts

**Solution:**
```bash
# Check service
sudo systemctl status suricata

# Check EVE log
sudo tail -50 /var/log/suricata/eve.json

# Count alerts
sudo grep -c '"event_type":"alert"' /var/log/suricata/eve.json

# Check rules
sudo suricatasc -c "ruleset-stats"

# Reload rules
sudo suricatasc -c "reload-rules"

# Check SELinux
sudo restorecon -Rv /var/log/suricata/
```

#### MariaDB Replication Issues

**Problem:** Replication lag hoặc stopped

**Solution:**
```bash
# On Slave - check status
mysql -u root -p -e "SHOW SLAVE STATUS\G"

# Check errors
mysql -u root -p -e "SHOW SLAVE STATUS\G" | grep -i error

# Stop and reset
mysql -u root -p
> STOP SLAVE;
> RESET SLAVE;

# Get Master status
# On Master:
mysql -u root -p -e "SHOW MASTER STATUS\G"

# Reconfigure Slave
> CHANGE MASTER TO 
  MASTER_HOST='192.168.1.50',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='password',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=154;
> START SLAVE;

# Verify
> SHOW SLAVE STATUS\G
```

### Logging & Debugging

#### Enable Verbose Mode

```bash
# Ansible verbose levels
ansible-playbook playbook.yml -v      # Basic
ansible-playbook playbook.yml -vv     # More details
ansible-playbook playbook.yml -vvv    # Maximum verbosity
ansible-playbook playbook.yml -vvvv   # Connection debugging
```

#### Check Ansible Logs

```bash
# Enable logging in ansible.cfg
log_path = /var/log/ansible.log

# View logs
tail -f /var/log/ansible.log

# Search for errors
grep -i error /var/log/ansible.log
```

#### Service-specific Logs

```bash
# System logs
sudo journalctl -u <service-name>
sudo journalctl -fu <service-name>  # Follow

# Application logs
# Wazuh
/var/ossec/logs/ossec.log

# HAProxy
/var/log/haproxy.log

# Suricata
/var/log/suricata/suricata.log
/var/log/suricata/fast.log
/var/log/suricata/eve.json

# MariaDB
/var/log/mariadb/mariadb.log

# Prometheus
/var/log/prometheus/prometheus.log

# Grafana
/var/log/grafana/grafana.log
```

---

## 📊 Monitoring & Alerting

### Access Dashboards

| Service | URL | Default Credentials | Port |
|---------|-----|---------------------|------|
| **Wazuh Dashboard** | https://IP | admin / <from credentials file> | 443 |
| **Suricata UI** | http://IP:8080 | N/A | 8080 |
| **HAProxy Stats** | http://IP:8888/stats | admin / admin | 8888 |
| **Prometheus** | http://IP:9090 | N/A | 9090 |
| **Grafana** | http://IP:3000 | admin / <from output> | 3000 |
| **Zabbix** | http://IP/zabbix | Admin / zabbix | 80 |
| **OpenVAS** | https://IP:9392 | admin / <from output> | 9392 |

### Metrics to Monitor

#### System Metrics
- CPU usage (target: < 80%)
- Memory usage (target: < 85%)
- Disk usage (target: < 80%)
- Network throughput
- Load average

#### Service Metrics
- **Wazuh**: Agents connected, Events/sec, Alert rate
- **HAProxy**: Backend health, Request rate, Response time
- **MariaDB**: Replication lag, Queries/sec, Connections
- **Suricata**: Packets/sec, Alerts/sec, Drop rate

#### Security Metrics
- Failed login attempts
- Critical alerts
- Compliance score
- Vulnerability count
- Firewall blocks

---

## 📚 Role Documentation

Mỗi role có documentation riêng trong thư mục `roles/<role>/README.md`:

- [wazuh/README.md](roles/wazuh/README.md) - Wazuh SIEM/XDR
- [suricata/README.md](roles/suricata/README.md) - Suricata IDS/IPS  
- [haproxy_lb/README.md](roles/haproxy_lb/README.md) - HAProxy Load Balancer
- [keepalived_ha/README.md](roles/keepalived_ha/README.md) - Keepalived HA
- [mariadb_replication/README.md](roles/mariadb_replication/README.md) - MariaDB Replication
- [webserver_ha/README.md](roles/webserver_ha/README.md) - HA Web Servers
- [adds/README.md](roles/adds/README.md) - Active Directory
- [grafana/README.md](roles/grafana/README.md) - Grafana Dashboards
- [commvault/README.md](roles/commvault/README.md) - Commvault Backup

---

## 🔧 Requirements

### Control Node
- **OS**: RHEL/CentOS/AlmaLinux 8+, Ubuntu 20.04+, Debian 11+
- **Ansible**: >= 2.14
- **Python**: >= 3.8
- **Disk Space**: 10GB free
- **Network**: Internet access cho package download

### Managed Nodes

#### Linux Servers
- **OS**: RHEL/CentOS/AlmaLinux 8+, Ubuntu 20.04+, Debian 11+
- **Python**: 3.6+
- **SSH**: Configured với key-based auth
- **Sudo**: Access for ansible user

#### Windows Servers
- **OS**: Windows Server 2019, 2022
- **WinRM**: Enabled và configured
- **PowerShell**: 5.1+
- **Administrator**: Access required

### Hardware Requirements

#### Wazuh Server (Minimum)
- **RAM**: 4GB (8GB recommended)
- **CPU**: 2 cores (4 cores recommended)
- **Disk**: 50GB free (100GB+ for production)
- **Network**: 1Gbps NIC

#### HAProxy Server (Minimum)
- **RAM**: 2GB (4GB recommended)
- **CPU**: 2 cores
- **Disk**: 20GB free
- **Network**: 1Gbps NIC (2 NICs recommended)

#### Database Server (Minimum)
- **RAM**: 4GB (8GB+ recommended)
- **CPU**: 2 cores (4 cores+ recommended)
- **Disk**: 100GB free (SSD recommended)
- **Network**: 1Gbps NIC

#### Monitoring Server (Minimum)
- **RAM**: 4GB (8GB recommended)
- **CPU**: 2 cores (4 cores recommended)
- **Disk**: 100GB free (for metrics retention)
- **Network**: 1Gbps NIC

---

## 🔒 Security Best Practices

### Secrets Management

```bash
# Use Ansible Vault for sensitive data
ansible-vault create secrets.yml
ansible-vault edit secrets.yml

# Run playbook with vault
ansible-playbook playbook.yml --ask-vault-pass

# Use vault password file
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

### SSH Key Management

```bash
# Use separate keys for different environments
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_prod
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_dev

# Configure in ansible.cfg
private_key_file = ~/.ssh/ansible_prod
```

### Firewall Configuration

```bash
# Allow only necessary ports
# Wazuh Manager
firewall-cmd --add-port=1514/tcp --permanent  # Agent connection
firewall-cmd --add-port=1515/tcp --permanent  # Agent connection
firewall-cmd --add-port=55000/tcp --permanent # API
firewall-cmd --add-port=443/tcp --permanent   # Dashboard

# HAProxy
firewall-cmd --add-port=80/tcp --permanent    # HTTP
firewall-cmd --add-port=443/tcp --permanent   # HTTPS
firewall-cmd --add-port=8888/tcp --permanent  # Stats

# Reload
firewall-cmd --reload
```

### Audit Logging

```bash
# Enable Ansible logging
# In ansible.cfg
log_path = /var/log/ansible/ansible.log

# Rotate logs
cat > /etc/logrotate.d/ansible << EOF
/var/log/ansible/ansible.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
EOF
```

---

## 📝 Changelog

### Version 2.0.0 (2025-12-27)
- ✅ Added comprehensive main README with full documentation
- ✅ Fixed Suricata EVE log SELinux permissions issue
- ✅ Improved Wazuh deployment with official installer
- ✅ Enhanced HA architecture documentation
- ✅ Added automated deployment scripts
- ✅ Updated all playbooks với verification steps

### Version 1.5.0 (Previous)
- Added Suricata IDS/IPS support
- Implemented HAProxy + Keepalived HA
- Added MariaDB replication
- Enhanced monitoring với Grafana dashboards

---

## 👨‍💻 Contributors

**Võ Đào Huy Hoàng**  
Enterprise Infrastructure Automation

📧 Email: [your-email@example.com]  
🔗 GitHub: [your-github]  
💼 LinkedIn: [your-linkedin]

---

## 📜 License

MIT License

Copyright (c) 2025 Võ Đào Huy Hoàng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## 🙏 Acknowledgments

- **Wazuh Team** - For the excellent SIEM/XDR platform
- **Suricata Project** - For the powerful IDS/IPS engine
- **Ansible Community** - For automation tools and modules
- **HAProxy Team** - For the robust load balancer
- **Prometheus & Grafana** - For monitoring and visualization

---

## 📞 Support

### Documentation
- [Quick Start Guide](QUICKSTART.md)
- [Deployment Guides](#-deployment-guides)
- [Troubleshooting](#-troubleshooting)
- [Role Documentation](#-role-documentation)

### Community
- GitHub Issues: [Report bugs and feature requests]
- Discussions: [Ask questions and share ideas]

### Commercial Support
Contact us for enterprise support, training, and custom development.

---

**⭐ Star this project if you find it useful!**

**🔄 Keep your infrastructure automated, secure, and highly available!**

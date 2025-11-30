---

````markdown
# Ansible Automation Project

## 📌 Giới thiệu
Dự án này sử dụng **Ansible** để tự động hóa việc cấu hình và quản trị hệ thống.  
Bao gồm các playbook và role để triển khai, cấu hình, sao lưu, bảo mật và giám sát nhiều dịch vụ như cơ sở dữ liệu, DHCP, DNS, Firewall, Web Server, Suricata, **Wazuh Security Platform**, quản lý người dùng, vá lỗi hệ thống, v.v.

---

## ⚙️ Chức năng chính

- **Wazuh Deployment** ⭐ NEW: Deploy Wazuh Server (Official Script) và Agents (Ansible) cho security monitoring và threat detection.
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


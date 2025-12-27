# ╔════════════════════════════════════════════════════════════════╗
# ║              WAZUH ANSIBLE ROLE - DEPLOYMENT GUIDE             ║
# ╚════════════════════════════════════════════════════════════════╝

## 📦 CẤU TRÚC ĐÃ TẠO

```
ansible/
├── roles/wazuh/                          ✅ WAZUH ROLE
│   ├── defaults/main.yml                 ✅ Biến mặc định
│   ├── vars/main.yml                     ✅ Biến bổ sung
│   ├── handlers/main.yml                 ✅ Service handlers
│   ├── meta/main.yml                     ✅ Metadata
│   ├── tasks/
│   │   ├── main.yml                      ✅ Entry point
│   │   ├── install_server.yml            ✅ Cài Wazuh Server
│   │   ├── install_agent_linux.yml       ✅ Cài Agent Linux
│   │   ├── install_agent_windows.yml     ✅ Cài Agent Windows
│   │   └── install_agent_macos.yml       ✅ Cài Agent macOS
│   ├── templates/
│   │   ├── wazuh_manager_ossec.conf.j2   ✅ Config Manager
│   │   ├── wazuh_agent_linux_ossec.conf.j2    ✅ Config Agent Linux
│   │   ├── wazuh_agent_windows_ossec.conf.j2  ✅ Config Agent Windows
│   │   ├── wazuh_agent_macos_ossec.conf.j2    ✅ Config Agent macOS
│   │   ├── wazuh_indexer_opensearch.yml.j2    ✅ Config Indexer
│   │   └── wazuh_dashboard_opensearch_dashboards.yml.j2  ✅ Config Dashboard
│   └── README.md                         ✅ Hướng dẫn chi tiết
│
├── playbooks/
│   ├── deploy_wazuh_server.yml           ✅ Playbook triển khai Server
│   └── deploy_wazuh_agent.yml            ✅ Playbook triển khai Agent
│
└── inventory.ini                         ✅ Inventory file

TỔNG CỘNG: 16 files đã được tạo thành công!
```

## 🚀 HƯỚNG DẪN SỬ DỤNG NHANH

### BƯỚC 1: Cấu hình Inventory

Chỉnh sửa file `inventory.ini` với IP thực tế của bạn:

```bash
nano inventory.ini
```

Thay đổi:
- `wazuh_manager_ip=192.168.1.10` → IP thực của Wazuh Server
- `192.168.1.11`, `192.168.1.12` → IP các máy Linux client
- `192.168.1.20` → IP máy Windows client
- `192.168.1.30` → IP máy macOS client

### BƯỚC 2: Test Kết Nối

```bash
# Test kết nối đến Wazuh Server (localhost)
ansible wazuh_server -i inventory.ini -m ping

# Test kết nối đến các Agents
ansible wazuh_agents -i inventory.ini -m ping
```

### BƯỚC 3: Triển Khai Wazuh Server

```bash
# Chạy playbook để cài Wazuh Server trên localhost
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server.yml

# Hoặc với verbose để xem chi tiết
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server.yml -vv
```

**Thời gian dự kiến:** 10-15 phút

**Sau khi hoàn tất:**
- Dashboard: https://<SERVER_IP>:443
- Username: wazuh-wui
- Password: MyS3cr37P450r.*-

### BƯỚC 4: Triển Khai Wazuh Agent

**Lưu ý:** Trước khi chạy, cập nhật `wazuh_manager_ip` trong file `playbooks/deploy_wazuh_agent.yml`

```bash
# Deploy Agent trên tất cả các máy client
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml

# Deploy chỉ trên Linux agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit linux_agents

# Deploy chỉ trên Windows agents  
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit windows_agents

# Deploy chỉ trên macOS agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit macos_agents
```

**Thời gian dự kiến mỗi agent:** 5-10 phút

## ⚙️ CẤU HÌNH QUAN TRỌNG

### File: `roles/wazuh/defaults/main.yml`

```yaml
# Chọn mode deployment
wazuh_mode: "agent"  # hoặc "server"

# Wazuh version
wazuh_version: "4.7"

# Manager IP (thay đổi theo môi trường)
wazuh_manager_ip: "192.168.1.10"
wazuh_manager_port: 1514

# Agent configuration
wazuh_agent_group: "default"
```

## 🎯 CÁC TÍNH NĂNG CHÍNH

### ✅ Wazuh Server Mode
- Cài đặt Wazuh Manager (quản lý agents)
- Cài đặt Wazuh Indexer (lưu trữ dữ liệu)
- Cài đặt Wazuh Dashboard (giao diện web)
- Tự động mở firewall ports
- Enable và start tất cả services

### ✅ Wazuh Agent Mode - Linux
- Hỗ trợ: Ubuntu, Debian, CentOS, RHEL, Rocky, AlmaLinux
- Thêm Wazuh repository
- Cài đặt wazuh-agent
- Cấu hình kết nối đến Manager
- Tự động start service

### ✅ Wazuh Agent Mode - Windows
- Download Wazuh Agent MSI
- Cài đặt qua win_package
- Cấu hình ossec.conf
- Mở Windows Firewall
- Start Wazuh service

### ✅ Wazuh Agent Mode - macOS
- Download Wazuh Agent PKG
- Cài đặt qua installer
- Cấu hình ossec.conf
- Start LaunchDaemon

## 🔍 XÁC MINH SAU KHI CÀI ĐẶT

### Trên Wazuh Server

```bash
# Kiểm tra services
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-indexer
sudo systemctl status wazuh-dashboard

# Kiểm tra danh sách agents
sudo /var/ossec/bin/agent_control -l

# Xem logs
sudo tail -f /var/ossec/logs/ossec.log
```

### Trên Linux Agent

```bash
# Kiểm tra service
sudo systemctl status wazuh-agent

# Kiểm tra cấu hình
sudo cat /var/ossec/etc/ossec.conf | grep address

# Xem logs
sudo tail -f /var/ossec/logs/ossec.log
```

### Trên Windows Agent

```powershell
# Kiểm tra service
Get-Service WazuhSvc

# Xem logs
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 50
```

### Trên macOS Agent

```bash
# Kiểm tra status
sudo /Library/Ossec/bin/wazuh-control status

# Xem logs
sudo tail -f /Library/Ossec/logs/ossec.log
```

## 🔧 TROUBLESHOOTING

### Agent không kết nối được Manager

**Kiểm tra:**

1. **Firewall trên Manager:**
   ```bash
   # RHEL/CentOS
   sudo firewall-cmd --list-all | grep 1514
   
   # Ubuntu
   sudo ufw status | grep 1514
   ```

2. **Network connectivity:**
   ```bash
   # Từ Agent ping đến Manager
   ping <MANAGER_IP>
   
   # Test port 1514
   nc -zvu <MANAGER_IP> 1514
   ```

3. **Manager có chạy không:**
   ```bash
   sudo systemctl status wazuh-manager
   ```

4. **Restart agent:**
   ```bash
   # Linux
   sudo systemctl restart wazuh-agent
   
   # Windows
   Restart-Service WazuhSvc
   
   # macOS
   sudo /Library/Ossec/bin/wazuh-control restart
   ```

### Dashboard không truy cập được

```bash
# Kiểm tra service
sudo systemctl status wazuh-dashboard

# Kiểm tra port
sudo ss -tulpn | grep 443

# Kiểm tra logs
sudo tail -f /var/log/wazuh-dashboard/wazuh-dashboard.log

# Restart service
sudo systemctl restart wazuh-dashboard
```

## 📊 PORTS CẦN MỞ

### Wazuh Server

| Port  | Protocol | Service          | Mô tả                    |
|-------|----------|------------------|--------------------------|
| 1514  | UDP      | Wazuh Manager    | Agent communication      |
| 1515  | TCP      | Wazuh Manager    | Agent enrollment         |
| 55000 | TCP      | Wazuh API        | RESTful API              |
| 9200  | TCP      | Wazuh Indexer    | Indexer HTTP             |
| 9300  | TCP      | Wazuh Indexer    | Indexer transport        |
| 443   | TCP      | Wazuh Dashboard  | Web interface (HTTPS)    |

### Wazuh Agent

| Port  | Protocol | Direction | Mô tả                    |
|-------|----------|-----------|--------------------------|
| 1514  | UDP      | Outbound  | To Manager               |
| 1515  | TCP      | Outbound  | To Manager (enrollment)  |

## 🔐 BẢO MẬT

### Thay đổi mật khẩu mặc định

```bash
# Trên Wazuh Server
sudo /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -a

# Hoặc thay đổi cho user cụ thể
sudo /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -a -au admin
```

### Backup cấu hình

```bash
# Backup Wazuh configuration
sudo tar -czf wazuh-backup-$(date +%Y%m%d).tar.gz /var/ossec/etc/

# Backup Indexer configuration
sudo tar -czf indexer-backup-$(date +%Y%m%d).tar.gz /etc/wazuh-indexer/
```

## 📚 TÀI LIỆU THAM KHẢO

- **Wazuh Documentation:** https://documentation.wazuh.com/
- **Ansible Documentation:** https://docs.ansible.com/
- **Role README:** `roles/wazuh/README.md`

## 🎉 HOÀN TẤT!

Bạn đã có một Wazuh Ansible Role hoàn chỉnh với:

✅ Support đa OS (Linux, Windows, macOS)
✅ Idempotent và production-ready
✅ Template cấu hình đầy đủ
✅ Handlers tự động restart services
✅ Firewall configuration
✅ Pre-check và post-check
✅ Logging và debugging
✅ Documentation đầy đủ

**Chúc bạn triển khai thành công! 🚀**

# Wazuh Deployment with Ansible

Ansible Role hoàn chỉnh để triển khai Wazuh Server và Wazuh Agent trên nhiều hệ điều hành.

## 📋 Mục lục

- [Tổng quan](#tổng-quan)
- [Yêu cầu](#yêu-cầu)
- [Cấu trúc Role](#cấu-trúc-role)
- [Cài đặt](#cài-đặt)
- [Sử dụng](#sử-dụng)
- [Cấu hình](#cấu-hình)
- [Ví dụ](#ví-dụ)
- [Troubleshooting](#troubleshooting)

## 🎯 Tổng quan

Role **wazuh** cho phép bạn:

- ✅ Triển khai **Wazuh Server** (Manager + Indexer + Dashboard)
- ✅ Triển khai **Wazuh Agent** trên nhiều OS:
  - Linux (Ubuntu, Debian, CentOS, RHEL, Rocky, AlmaLinux)
  - Windows Server
  - macOS
- ✅ Tự động cấu hình firewall
- ✅ Idempotent và production-ready
- ✅ Hỗ trợ clustering (sẵn sàng mở rộng)

## 📦 Yêu cầu

### Control Node (máy chạy Ansible)

- Ansible >= 2.10
- Python >= 3.6

```bash
# Cài đặt Ansible
sudo dnf install ansible -y  # RHEL/CentOS/Rocky
# hoặc
sudo apt install ansible -y  # Ubuntu/Debian
```

### Managed Nodes

#### Linux
- SSH access với sudo privileges
- Python >= 2.7

#### Windows
- WinRM enabled
- PowerShell >= 5.0

```powershell
# Cấu hình WinRM trên Windows
winrm quickconfig
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```

#### macOS
- SSH access với sudo privileges
- Python >= 2.7

### Hardware Requirements

#### Wazuh Server
- **CPU:** 4 cores minimum
- **RAM:** 8 GB minimum (16 GB recommended)
- **Disk:** 50 GB minimum
- **Network:** 1 Gbps

#### Wazuh Agent
- **CPU:** 1 core
- **RAM:** 512 MB minimum
- **Disk:** 1 GB

## 📂 Cấu trúc Role

```
roles/wazuh/
├── defaults/
│   └── main.yml                          # Biến mặc định
├── handlers/
│   └── main.yml                          # Service handlers
├── meta/
│   └── main.yml                          # Role metadata
├── tasks/
│   ├── main.yml                          # Entry point
│   ├── install_server.yml                # Cài Wazuh Server
│   ├── install_agent_linux.yml           # Cài Agent Linux
│   ├── install_agent_windows.yml         # Cài Agent Windows
│   └── install_agent_macos.yml           # Cài Agent macOS
├── templates/
│   ├── wazuh_manager_ossec.conf.j2       # Config Manager
│   ├── wazuh_agent_linux_ossec.conf.j2   # Config Agent Linux
│   ├── wazuh_agent_windows_ossec.conf.j2 # Config Agent Windows
│   ├── wazuh_agent_macos_ossec.conf.j2   # Config Agent macOS
│   ├── wazuh_indexer_opensearch.yml.j2   # Config Indexer
│   └── wazuh_dashboard_opensearch_dashboards.yml.j2  # Config Dashboard
└── vars/
    └── main.yml                          # Biến bổ sung
```

## 🚀 Cài đặt

### Bước 1: Clone hoặc tạo Role

Role đã được tạo trong thư mục `roles/wazuh/`

### Bước 2: Cấu hình Inventory

Chỉnh sửa file `inventory.ini`:

```ini
[wazuh_server]
localhost ansible_connection=local

[wazuh_agents]
192.168.1.11 ansible_user=root
192.168.1.20 ansible_connection=winrm ansible_user=Administrator

[wazuh_agents:vars]
wazuh_manager_ip=192.168.1.10
```

### Bước 3: Test kết nối

```bash
# Test kết nối đến tất cả hosts
ansible all -i inventory.ini -m ping

# Test kết nối đến Wazuh Server
ansible wazuh_server -i inventory.ini -m ping

# Test kết nối đến Wazuh Agents
ansible wazuh_agents -i inventory.ini -m ping
```

## 💻 Sử dụng

### Triển khai Wazuh Server

```bash
# Deploy Wazuh Server (Manager + Indexer + Dashboard)
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server.yml

# Với verbose output
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server.yml -v
```

### Triển khai Wazuh Agent

```bash
# Deploy Wazuh Agent trên tất cả agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml

# Deploy chỉ trên Linux agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit linux_agents

# Deploy chỉ trên Windows agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit windows_agents

# Deploy chỉ trên một host cụ thể
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit 192.168.1.11
```

## ⚙️ Cấu hình

### Biến quan trọng

Chỉnh sửa trong `roles/wazuh/defaults/main.yml`:

```yaml
# Mode: "server" hoặc "agent"
wazuh_mode: "agent"

# Wazuh version
wazuh_version: "4.7"

# Manager configuration
wazuh_manager_ip: "192.168.1.10"
wazuh_manager_port: 1514
wazuh_manager_protocol: "udp"

# Agent configuration
wazuh_agent_name: "{{ ansible_hostname }}"
wazuh_agent_group: "default"

# Firewall
wazuh_firewall_enabled: true
```

### Override biến trong Playbook

```yaml
---
- name: Deploy Wazuh Server
  hosts: wazuh_server
  roles:
    - wazuh
  vars:
    wazuh_mode: "server"
    wazuh_manager_ip: "10.0.0.100"
    wazuh_version: "4.7"
```

## 📝 Ví dụ

### Ví dụ 1: Deploy Server và Agents cùng lúc

```bash
# Tạo playbook all-in-one
cat > playbooks/deploy_wazuh_all.yml << 'EOF'
---
- import_playbook: deploy_wazuh_server.yml
- import_playbook: deploy_wazuh_agent.yml
EOF

# Chạy
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_all.yml
```

### Ví dụ 2: Deploy với custom variables

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml \
  -e "wazuh_manager_ip=10.0.0.100" \
  -e "wazuh_agent_group=webservers"
```

### Ví dụ 3: Deploy chỉ trên Ubuntu servers

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml \
  --limit "ubuntu_agents"
```

## 🔧 Troubleshooting

### ⚠️ QUAN TRỌNG: Agent "Never connected" hoặc "Duplicate agent name"

**Triệu chứng:**
- Dashboard hiển thị agent với status "Never connected"
- Logs hiện: `ERROR: Duplicate agent name: xxx (from manager)`

**Nguyên nhân:**
- Agent đã được đăng ký trên Manager nhưng key không khớp
- Agent cũ chưa bị xóa trước khi deploy lại

**Giải pháp tự động (đã tích hợp trong playbook):**
- Playbook mới sẽ tự xóa agent duplicate trước khi register
- Biến `wazuh_remove_duplicate_agent: true` (mặc định) sẽ kích hoạt

**Giải pháp thủ công:**
```bash
# 1. Trên Manager - Xem danh sách agents
sudo /var/ossec/bin/agent_control -l

# 2. Xóa agent bị duplicate (thay ID)
sudo /var/ossec/bin/manage_agents -r <AGENT_ID>
# Nhập 'y' để xác nhận

# 3. Restart Manager
sudo systemctl restart wazuh-manager

# 4. Trên Agent - Xóa key cũ và restart
sudo rm -f /var/ossec/etc/client.keys
sudo systemctl restart wazuh-agent

# 5. Hoặc chạy lại playbook
ansible-playbook playbooks/deploy_wazuh_agent.yml --limit <agent_name>
```

### 1. Kiểm tra logs

#### Wazuh Server
```bash
sudo tail -f /var/ossec/logs/ossec.log
sudo tail -f /var/log/wazuh-indexer/wazuh-cluster.log
sudo tail -f /var/log/wazuh-dashboard/wazuh-dashboard.log
```

#### Wazuh Agent (Linux)
```bash
sudo tail -f /var/ossec/logs/ossec.log
sudo systemctl status wazuh-agent
```

#### Wazuh Agent (Windows)
```powershell
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 50
Get-Service WazuhSvc
```

### 2. Kiểm tra kết nối Manager-Agent

Trên **Wazuh Server**:
```bash
# Liệt kê tất cả agents
sudo /var/ossec/bin/agent_control -l

# Kiểm tra agent cụ thể
sudo /var/ossec/bin/agent_control -i <AGENT_ID>
```

### 3. Agent không kết nối được Manager

**Kiểm tra:**
- Firewall trên Manager có mở port 1514/udp không?
- Agent có cấu hình đúng IP Manager không?
- Network có kết nối được không?

```bash
# Trên Agent (Linux)
sudo cat /var/ossec/etc/ossec.conf | grep address

# Test kết nối
nc -zvu <MANAGER_IP> 1514

# Restart agent
sudo systemctl restart wazuh-agent
```

### 4. Wazuh Dashboard không truy cập được

```bash
# Kiểm tra services
sudo systemctl status wazuh-dashboard
sudo systemctl status wazuh-indexer

# Kiểm tra ports
sudo ss -tulpn | grep -E "443|9200"

# Kiểm tra firewall
sudo firewall-cmd --list-all  # RHEL/CentOS
sudo ufw status               # Ubuntu
```

### 5. Reset password Wazuh Dashboard

```bash
# Trên Wazuh Server
sudo /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -a -au admin
```

## 🔐 Security Best Practices

1. **Thay đổi passwords mặc định:**
   ```bash
   sudo /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -a
   ```

2. **Cấu hình SSL/TLS certificates** cho production

3. **Firewall rules:**
   - Chỉ cho phép agents kết nối đến Manager
   - Restrict Dashboard access

4. **Regular backups:**
   ```bash
   # Backup Wazuh configuration
   sudo tar -czf wazuh-backup-$(date +%Y%m%d).tar.gz /var/ossec/etc/
   ```

5. **Keep Wazuh updated:**
   ```bash
   # Update Wazuh components
   sudo yum update wazuh-*     # RHEL/CentOS
   sudo apt update && sudo apt upgrade wazuh-*  # Ubuntu
   ```

## 📚 Tài liệu tham khảo

- [Wazuh Official Documentation](https://documentation.wazuh.com/)
- [Wazuh GitHub](https://github.com/wazuh/wazuh)
- [Ansible Documentation](https://docs.ansible.com/)

## 🆘 Hỗ trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra logs
2. Xem lại cấu hình inventory và variables
3. Test kết nối network
4. Tham khảo Wazuh documentation

## 📄 License

MIT License

## 👨‍💻 Tác giả

Server Ansible Team

---

**Chúc bạn triển khai thành công! 🎉**

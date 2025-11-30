# 🔧 Wazuh Troubleshooting Guide

Hướng dẫn xử lý các lỗi thường gặp khi deploy Wazuh với Ansible.

---

## 📋 Mục lục

- [Agent "Never connected"](#1-agent-never-connected)
- [Duplicate agent name](#2-duplicate-agent-name)
- [sshpass not found](#3-sshpass-not-found)
- [SSH Permission denied](#4-ssh-permission-denied)
- [Manager không listening](#5-manager-không-listening)
- [Firewall blocking](#6-firewall-blocking)
- [Quick Commands](#quick-commands)

---

## 1. Agent "Never connected"

**Triệu chứng:**
- Dashboard hiển thị agent với status `Never connected`
- Agent đã cài nhưng không kết nối được Manager

**Kiểm tra:**
```bash
# Trên Agent - xem logs
sudo tail -20 /var/ossec/logs/ossec.log

# Trên Agent - test kết nối đến Manager
nc -zv <MANAGER_IP> 1514
telnet <MANAGER_IP> 1514

# Trên Manager - xem agent list
sudo /var/ossec/bin/agent_control -l
```

**Nguyên nhân thường gặp:**
1. Firewall chặn port 1514
2. Agent key không khớp với Manager
3. Manager IP sai trong config agent

**Giải pháp:**
```bash
# Trên Agent - kiểm tra manager IP
grep -A 3 '<server>' /var/ossec/etc/ossec.conf

# Nếu sai IP, sửa và restart
sudo nano /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-agent
```

---

## 2. Duplicate agent name

**Triệu chứng:**
- Logs hiện: `ERROR: Duplicate agent name: xxx (from manager)`
- Agent không thể register

**Nguyên nhân:**
- Agent đã tồn tại trên Manager với cùng tên
- Deploy lại agent mà chưa xóa agent cũ

**Giải pháp (đã tích hợp trong playbook mới):**

Playbook đã được cập nhật để tự động xóa agent duplicate. Chỉ cần chạy:
```bash
ansible-playbook playbooks/deploy_wazuh_agent.yml --limit <agent_name>
```

**Giải pháp thủ công:**
```bash
# 1. Trên Manager - xem agents
sudo /var/ossec/bin/agent_control -l

# Output:
# ID: 001, Name: wazuh-agent-01, IP: any, Never connected
# ID: 002, Name: wazuh-agent-02, IP: any, Active

# 2. Xóa agent duplicate (thay 001 bằng ID cần xóa)
sudo /var/ossec/bin/manage_agents -r 001
# Nhập 'y' để xác nhận

# 3. Restart Manager
sudo systemctl restart wazuh-manager

# 4. Trên Agent - xóa key cũ
sudo rm -f /var/ossec/etc/client.keys

# 5. Restart Agent
sudo systemctl restart wazuh-agent

# Agent sẽ tự động register lại
```

---

## 3. sshpass not found

**Triệu chứng:**
```
fatal: [hostname]: FAILED! => msg: to use the 'ssh' connection type with passwords, you must install the sshpass program
```

**Giải pháp:**
```bash
# RHEL/CentOS/Rocky/AlmaLinux
sudo dnf install -y sshpass

# Ubuntu/Debian
sudo apt-get install -y sshpass

# macOS
brew install sshpass
```

---

## 4. SSH Permission denied

**Triệu chứng:**
```
fatal: [hostname]: UNREACHABLE! => msg: Permission denied (publickey,password)
```

**Giải pháp:**

1. **Kiểm tra inventory có đúng user/password:**
```yaml
# inventory/hosts.yml
wazuh-agent-01:
  ansible_host: 192.168.1.xxx
  ansible_user: root
  ansible_ssh_pass: "your_password"
```

2. **Hoặc dùng SSH key:**
```yaml
wazuh-agent-01:
  ansible_host: 192.168.1.xxx
  ansible_user: root
  ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

3. **Copy SSH key đến target:**
```bash
ssh-copy-id root@192.168.1.xxx
```

---

## 5. Manager không listening

**Triệu chứng:**
- Agent không kết nối được Manager
- Port 1514 không mở

**Kiểm tra:**
```bash
# Trên Manager
sudo ss -tlnp | grep 1514
sudo netstat -tlnp | grep 1514

# Output expected:
# LISTEN 0 128 0.0.0.0:1514 0.0.0.0:* users:(("wazuh-remoted",...))
```

**Giải pháp:**
```bash
# Restart wazuh-manager
sudo systemctl restart wazuh-manager

# Kiểm tra status
sudo systemctl status wazuh-manager

# Xem logs nếu có lỗi
sudo journalctl -fu wazuh-manager.service
```

---

## 6. Firewall blocking

**Triệu chứng:**
- Agent không kết nối được dù Manager đang chạy

**Kiểm tra và fix (firewalld - RHEL/CentOS):**
```bash
# Xem ports đã mở
sudo firewall-cmd --list-ports

# Mở port 1514
sudo firewall-cmd --permanent --add-port=1514/tcp
sudo firewall-cmd --permanent --add-port=1514/udp
sudo firewall-cmd --permanent --add-port=1515/tcp
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```

**Kiểm tra và fix (ufw - Ubuntu):**
```bash
# Xem status
sudo ufw status

# Mở ports
sudo ufw allow 1514/tcp
sudo ufw allow 1514/udp
sudo ufw allow 1515/tcp
sudo ufw reload
```

---

## Quick Commands

### Manager Commands
```bash
# Status tất cả services
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard

# Restart tất cả
sudo systemctl restart wazuh-manager wazuh-indexer wazuh-dashboard

# Xem agent list
sudo /var/ossec/bin/agent_control -l

# Xóa agent (thay ID)
sudo /var/ossec/bin/manage_agents -r <ID>

# Xem logs
sudo tail -f /var/ossec/logs/ossec.log
```

### Agent Commands (Linux)
```bash
# Status
sudo systemctl status wazuh-agent

# Restart
sudo systemctl restart wazuh-agent

# Xem logs
sudo tail -f /var/ossec/logs/ossec.log

# Xem config
sudo cat /var/ossec/etc/ossec.conf | grep -A 5 "<server>"

# Xem client key
sudo cat /var/ossec/etc/client.keys
```

### Ansible Commands
```bash
# Test kết nối
ansible all -m ping
ansible wazuh-agent-01 -m ping

# Deploy agent
ansible-playbook playbooks/deploy_wazuh_agent.yml

# Deploy specific agent
ansible-playbook playbooks/deploy_wazuh_agent.yml --limit wazuh-agent-01

# Verbose mode (debug)
ansible-playbook playbooks/deploy_wazuh_agent.yml -vvv

# Syntax check
ansible-playbook --syntax-check playbooks/deploy_wazuh_agent.yml
```

---

## 📝 Workflow Deploy Agent Mới

**Bước 1:** Thêm host vào inventory
```yaml
# inventory/hosts.yml
wazuh_agents:
  hosts:
    wazuh-agent-new:
      ansible_host: 192.168.1.xxx
      ansible_user: root
      ansible_ssh_pass: "password"
```

**Bước 2:** Test kết nối
```bash
ansible wazuh-agent-new -m ping
```

**Bước 3:** Deploy
```bash
ansible-playbook playbooks/deploy_wazuh_agent.yml --limit wazuh-agent-new
```

**Bước 4:** Verify trên Dashboard
- Mở `https://<MANAGER_IP>`
- Xem Agents → Status = Active

---

## 🔄 Biến quan trọng

| Biến | Mặc định | Mô tả |
|------|----------|-------|
| `wazuh_manager_ip` | `127.0.0.1` | IP của Wazuh Manager |
| `wazuh_agent_group` | `default` | Group cho agent |
| `wazuh_remove_duplicate_agent` | `true` | Tự động xóa agent duplicate |

---

**Cập nhật:** 2025-11-30

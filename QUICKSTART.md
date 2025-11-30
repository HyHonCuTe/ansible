# 🚀 WAZUH ANSIBLE DEPLOYMENT - QUICKSTART GUIDE

## ✨ PHƯƠNG PHÁP MỚI: HYBRID APPROACH (RECOMMENDED)

```
✅ Wazuh Server:  Official Installation Script (Stable, Fast, Production-Ready)
✅ Wazuh Agents:  Ansible Role (Automation, Scale, Management)
✅ Best of both worlds!
```

---

## 📋 3 BƯỚC TRIỂN KHAI

### BƯỚC 1: Cleanup (nếu đã cài Wazuh trước đó)

```bash
cd /home/server_ansible/Desktop/ansible

# Xóa Wazuh cũ nếu có
ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml
```

### BƯỚC 2: Deploy Wazuh Server (10-15 phút) ⭐ NEW!

```bash
# Sử dụng Official Script thông qua Ansible
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml

# Playbook sẽ:
# 1. ✅ Download Official Wazuh Installation Script
# 2. ✅ Chạy script tự động cài đặt
# 3. ✅ Verify tất cả services
# 4. ✅ Lưu credentials vào file local
# 5. ✅ Configure firewall
```

**Sau khi hoàn tất:**
- 📄 Credentials được lưu tại: `./wazuh-credentials-<hostname>.txt`
- 🌐 Truy cập Dashboard: `https://<SERVER_IP>`
- 👤 Username: `admin`
- 🔑 Password: Xem trong file credentials

### BƯỚC 3: Deploy Wazuh Agents (5-10 phút/agent)

```bash
# Cập nhật IP Manager trong inventory
nano inventory.ini
# Tìm và sửa dòng:
# wazuh_manager_ip=<SERVER_IP_FROM_STEP2>

# Deploy agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml

# Hoặc deploy theo group:
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit linux_agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml --limit windows_agents
```

---

## 🔍 XÁC MINH SAU KHI CÀI

### Trên Server:
```bash
# Kiểm tra tất cả services
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard filebeat

# Xem credentials
cat ./wazuh-credentials-<hostname>.txt

# Xem danh sách agents
sudo /var/ossec/bin/agent_control -l

# Xem logs
sudo tail -f /var/ossec/logs/ossec.log
```

### Trên Agent (Linux):
```bash
sudo systemctl status wazuh-agent
sudo tail -f /var/ossec/logs/ossec.log
```

### Trên Dashboard:
1. Mở browser: `https://<SERVER_IP>`
2. Login với credentials từ file
3. Kiểm tra Agents đã kết nối

---

## ⚡ SO SÁNH 2 PHƯƠNG PHÁP

| Tiêu chí | Official Script (NEW) ⭐ | Ansible Role (OLD) |
|----------|------------------------|-------------------|
| **Thời gian cài** | 10-15 phút | 30-60 phút (nhiều lỗi) |
| **Độ ổn định** | ✅ Production-ready | ⚠️ Nhiều edge cases |
| **SSL/Certificates** | ✅ Auto-generate | ⚠️ Manual config |
| **Troubleshooting** | ✅ Minimal | ❌ Complex |
| **Wazuh Support** | ✅ Official | ❌ Community |
| **Idempotent** | ✅ Yes | ✅ Yes |
| **Use Case** | **Server deployment** | Agent deployment |

**Kết luận:** Dùng **Official Script cho Server**, **Ansible cho Agents**

---

## 📚 CẤU TRÚC FILES MỚI

```
ansible/
├── QUICKSTART.md                           ← BẠN ĐANG Ở ĐÂY
├── inventory.ini                           ← Cấu hình hosts
├── playbooks/
│   ├── deploy_wazuh_server_official.yml    ← ⭐ NEW: Dùng Official Script
│   ├── deploy_wazuh_server.yml             ← OLD: Ansible pure (deprecated)
│   ├── deploy_wazuh_agent.yml              ← Deploy agents (recommended)
│   └── cleanup_wazuh_server.yml            ← Cleanup tool
└── roles/wazuh/                            ← Wazuh role (cho agents)
```

---

## 🆘 TROUBLESHOOTING

### 1. Lỗi download script

```bash
# Kiểm tra internet
ping packages.wazuh.com

# Download thủ công
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh -a
```

### 2. Script fails - Already installed

```bash
# Cleanup trước
ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml

# Hoặc manual cleanup:
sudo systemctl stop wazuh-manager wazuh-indexer wazuh-dashboard
sudo yum remove -y wazuh-manager wazuh-indexer wazuh-dashboard
sudo rm -rf /var/ossec /etc/wazuh-indexer /var/lib/wazuh-indexer
```

### 3. RAM không đủ (< 4GB)

Official script yêu cầu tối thiểu 4GB RAM. Nếu không đủ:

```bash
# Option 1: Upgrade RAM server
# Option 2: Dùng Wazuh agent-only trên máy này
#          và kết nối tới Wazuh server khác
```

### 4. Không thấy credentials

```bash
# Xem lại installation log
sudo cat /tmp/wazuh-installation/wazuh-install.log | grep -A 20 "credentials"

# Hoặc tìm file passwords
sudo find / -name "wazuh-passwords.txt" 2>/dev/null
sudo find / -name "wazuh-install-files.tar" 2>/dev/null
```

### 5. Dashboard không truy cập được

```bash
# Kiểm tra firewall
sudo firewall-cmd --list-all

# Mở port 443
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Kiểm tra service
sudo systemctl status wazuh-dashboard
sudo journalctl -fu wazuh-dashboard.service
```

---

## ⚙️ CẤU HÌNH NÂNG CAO

### Thay đổi Dashboard port (mặc định 443)

```bash
# Trước khi chạy playbook, thêm vào inventory.ini:
[wazuh_server:vars]
wazuh_dashboard_port=8443

# Sau khi cài, sửa thủ công:
sudo nano /etc/wazuh-dashboard/opensearch_dashboards.yml
# Sửa: server.port: 8443
sudo systemctl restart wazuh-dashboard
```

### Custom Manager IP cho Agents

```bash
# Sửa trong inventory.ini
[wazuh_agents:vars]
wazuh_manager_ip=192.168.1.100
wazuh_manager_port=1514
```

### Deploy specific agent group

```bash
# Chỉ Linux agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml \
  --limit linux_agents

# Chỉ Windows agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml \
  --limit windows_agents

# Chỉ một host cụ thể
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml \
  --limit web-server-01
```

---

## 📊 MONITORING VÀ MAINTENANCE

### Kiểm tra trạng thái định kỳ

```bash
# Tất cả services
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard filebeat

# Disk usage
df -h | grep -E 'wazuh|ossec'
du -sh /var/ossec /var/lib/wazuh-indexer

# Memory usage
free -h
ps aux | grep -E 'wazuh|opensearch' | awk '{print $4, $11}'
```

### Backup quan trọng

```bash
# Backup configuration
sudo tar -czf wazuh-config-backup-$(date +%Y%m%d).tar.gz \
  /var/ossec/etc \
  /etc/wazuh-indexer \
  /etc/wazuh-dashboard

# Backup agents list
sudo /var/ossec/bin/manage_agents -l > agents-list-$(date +%Y%m%d).txt
```

### Update Wazuh

```bash
# Wazuh cung cấp upgrade script
curl -sO https://packages.wazuh.com/4.7/wazuh-upgrade.sh
sudo bash wazuh-upgrade.sh
```

---

## 🎯 COMMANDS NHANH

```bash
# Deploy Server (NEW - Recommended)
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml

# Deploy Agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml

# Cleanup
ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml

# Test connectivity
ansible all -i inventory.ini -m ping

# Check services
ansible wazuh_server -i inventory.ini -m shell \
  -a "systemctl status wazuh-manager wazuh-indexer wazuh-dashboard --no-pager"

# List agents
ansible wazuh_server -i inventory.ini -m shell \
  -a "/var/ossec/bin/agent_control -l"

# Restart services
ansible wazuh_server -i inventory.ini -m systemd \
  -a "name=wazuh-manager state=restarted" --become
```

---

## 📖 TÀI LIỆU THAM KHẢO

- **Official Wazuh Docs**: https://documentation.wazuh.com/
- **Installation Guide**: https://documentation.wazuh.com/current/installation-guide/
- **Agent Deployment**: https://documentation.wazuh.com/current/installation-guide/wazuh-agent/
- **Ansible Galaxy Role**: https://galaxy.ansible.com/wazuh/ansible-wazuh
- **Wazuh GitHub**: https://github.com/wazuh/wazuh

---

## 🎉 SUMMARY

**✅ RECOMMENDED WORKFLOW:**

1. **Cleanup** (nếu cần): `ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml`
2. **Deploy Server**: `ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml` ⭐
3. **Save Credentials**: Check `./wazuh-credentials-<hostname>.txt`
4. **Deploy Agents**: `ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml`
5. **Verify**: Login to Dashboard và check agents

**Thời gian tổng:** ~20-30 phút (Server + vài Agents)

**Ưu điểm:**
- ✅ Ổn định, production-ready
- ✅ Tự động hóa hoàn toàn
- ✅ Dễ troubleshoot
- ✅ Scale agents dễ dàng

---

**🚀 Ready to deploy? Start with Step 1!**

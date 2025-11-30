# 🎯 WAZUH DEPLOYMENT - CÁCH SỬ DỤNG NHANH

## ✅ PHƯƠNG PHÁP MỚI: HYBRID APPROACH

```
Server:  Official Wazuh Script (qua Ansible wrapper)
Agents:  Ansible Role (tự động hóa)
```

---

## 🚀 3 LỆNH ĐỂ DEPLOY HOÀN CHỈNH

```bash
# 1. Cleanup (nếu đã cài Wazuh trước đó)
ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml

# 2. Deploy Server (10-15 phút)
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml

# 3. Deploy Agents
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml
```

**Xong! Truy cập:** `https://<SERVER_IP>`  
**Credentials:** Xem file `./wazuh-credentials-<hostname>.txt`

---

## 📋 CẤU HÌNH TRƯỚC KHI DEPLOY

### inventory.ini

```ini
[wazuh_server]
localhost ansible_connection=local

[wazuh_agents]
web-server ansible_host=192.168.1.101 ansible_user=admin
db-server ansible_host=192.168.1.102 ansible_user=admin

[wazuh_agents:vars]
wazuh_manager_ip=<ĐIỀN_IP_SERVER_SAU_KHI_DEPLOY>
ansible_become=yes
ansible_become_method=sudo
```

---

## 🎬 WORKFLOW CHI TIẾT

### Bước 1: Kiểm tra kết nối

```bash
ansible all -i inventory.ini -m ping
```

### Bước 2: Deploy Wazuh Server

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml
```

**Output mẫu:**
```
TASK [📊 Display Installation Summary]
✅ Wazuh Manager:   Running
✅ Wazuh Indexer:   Running
✅ Wazuh Dashboard: Running
✅ Filebeat:        Running

Dashboard URL:  https://192.168.1.100
Credentials:    ./wazuh-credentials-localhost.txt
```

### Bước 3: Lưu và kiểm tra credentials

```bash
cat ./wazuh-credentials-*.txt
```

### Bước 4: Cập nhật Manager IP cho Agents

```bash
nano inventory.ini
# Sửa dòng: wazuh_manager_ip=192.168.1.100
```

### Bước 5: Deploy Agents

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml
```

### Bước 6: Verify trên Dashboard

1. Mở browser: `https://<SERVER_IP>`
2. Login với credentials
3. Navigate: **Server management → Endpoints Summary**
4. Kiểm tra agents đã kết nối

---

## 🔍 VERIFY DEPLOYMENT

### Trên Server

```bash
# Service status
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard

# List agents
sudo /var/ossec/bin/agent_control -l

# Test API
curl -k -u admin:YourPassword https://localhost:55000
```

### Trên Agent

```bash
# Agent status
sudo systemctl status wazuh-agent

# Check connection
sudo tail -f /var/ossec/logs/ossec.log | grep "Connected to"
```

---

## ⚡ ADVANCED OPTIONS

### Deploy specific agent group

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml \
  --limit web-servers
```

### Deploy với custom variables

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml \
  -e "wazuh_version=4.8"
```

### Dry run (check only)

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml \
  --check
```

### Verbose output

```bash
ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml \
  -vvv
```

---

## 🆘 QUICK TROUBLESHOOTING

### Lỗi: Cannot download script

```bash
# Manual download
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
sudo bash wazuh-install.sh -a
```

### Lỗi: Already installed

```bash
ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml
```

### Lỗi: Connection refused

```bash
# Kiểm tra firewall
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### Lỗi: Agent not connecting

```bash
# Trên agent, kiểm tra config
sudo cat /var/ossec/etc/ossec.conf | grep -A5 "server"

# Restart agent
sudo systemctl restart wazuh-agent
```

---

## 📊 WHAT GETS DEPLOYED

### Server Components

| Component | Port | Description |
|-----------|------|-------------|
| Wazuh Manager | 1514/udp, 1515/tcp | Agent communication |
| Wazuh API | 55000/tcp | REST API |
| Wazuh Indexer | 9200/tcp | OpenSearch |
| Wazuh Dashboard | 443/tcp | Web UI |
| Filebeat | - | Log forwarder |

### Agent Components

- Wazuh Agent daemon
- Log collectors
- File integrity monitoring
- Rootkit detection
- Vulnerability scanner

---

## 🎯 NEXT STEPS AFTER DEPLOYMENT

1. **Change default password**
   ```bash
   # Trên server
   sudo /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -u admin -p NewPassword
   ```

2. **Configure agent groups**
   - Dashboard → Management → Groups
   - Tạo groups theo environment (prod, dev, test)
   - Assign agents to groups

3. **Setup alerts**
   - Dashboard → Management → Rules
   - Configure email notifications
   - Integrate with SIEM/SOAR

4. **Enable file integrity monitoring**
   - Edit `/var/ossec/etc/ossec.conf` on agents
   - Add directories to monitor

5. **Setup compliance scanning**
   - Dashboard → Compliance
   - Enable CIS, PCI-DSS rules

---

## 📚 RELATED FILES

- **Full docs**: [QUICKSTART.md](QUICKSTART.md)
- **Deployment guide**: [WAZUH_DEPLOYMENT_GUIDE.md](WAZUH_DEPLOYMENT_GUIDE.md)
- **Main README**: [README.md](README.md)

---

## 💡 TIPS

- **Production**: Dùng separate machines cho Indexer, Manager, Dashboard
- **Testing**: All-in-one deployment OK (như guide này)
- **Scale**: Deploy agents in batches of 10-20
- **Monitoring**: Setup Prometheus/Grafana để monitor Wazuh itself
- **Backup**: Backup `/var/ossec/etc` và `/etc/wazuh-indexer` định kỳ

---

**🚀 Workflow tóm tắt:**
```bash
cleanup → deploy_server → save_credentials → update_inventory → deploy_agents → verify
```

**⏱️ Tổng thời gian:** 20-30 phút (1 server + 5 agents)

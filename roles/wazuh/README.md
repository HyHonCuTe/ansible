# Wazuh SIEM/XDR Role

## 📌 Overview

Triển khai **Wazuh Security Platform** - SIEM/XDR mã nguồn mở cho security monitoring, threat detection, và compliance management.

## 🚀 Quick Start

```bash
# Deploy Server
ansible-playbook playbooks/deploy_wazuh_server_official.yml

# Deploy Agents
ansible-playbook playbooks/deploy_wazuh_agent.yml

# Access: https://<SERVER_IP>
# Credentials: ./wazuh-credentials-<hostname>.txt
```

## ⚙️ Variables

```yaml
wazuh_version: "4.7.0"
wazuh_manager_ip: "192.168.1.100"
wazuh_manager_port: 1514
wazuh_dashboard_port: 443
```

## 🔧 Operations

```bash
# List agents
sudo /var/ossec/bin/agent_control -l

# Restart agent
sudo /var/ossec/bin/agent_control -R <ID>

# View logs
sudo tail -f /var/ossec/logs/ossec.log
```

## 🐛 Troubleshooting

**Agent not connecting:**
```bash
# Check config
sudo vi /var/ossec/etc/ossec.conf

# Verify firewall
sudo firewall-cmd --add-port=1514/tcp --permanent

# Restart
sudo systemctl restart wazuh-agent
```

**Last Updated**: 2025-12-27

# Zabbix Monitoring Role

## 📌 Overview

Triển khai **Zabbix Server** và **Zabbix Agent** cho comprehensive infrastructure monitoring với auto-discovery.

## 🚀 Quick Start

```bash
# Deploy Zabbix Server
ansible-playbook playbooks/deploy-zabbix-server.yml

# Deploy Zabbix Agents
ansible-playbook playbooks/deploy-zabbix-agent.yml

# Access: http://<SERVER_IP>/zabbix
# Default: Admin / zabbix
```

## ⚙️ Variables

```yaml
# Server
zabbix_server_version: "6.4"
zabbix_server_dbname: "zabbix"
zabbix_server_dbuser: "zabbix"
zabbix_server_dbpassword: "zabbix_password"

# Agent
zabbix_agent_server: "192.168.1.202"
zabbix_agent_hostname: "{{ ansible_hostname }}"
```

## 🔧 Operations

```bash
# Server
sudo systemctl status zabbix-server
sudo tail -f /var/log/zabbix/zabbix_server.log

# Agent
sudo systemctl status zabbix-agent
zabbix_agentd -t system.cpu.load[all,avg1]

# Database
mysql -u zabbix -p zabbix
> SELECT * FROM hosts;
```

## 📊 Features

- Auto-discovery of hosts
- Template-based monitoring
- Problem detection
- Alerting (Email, SMS, Slack)
- Custom dashboards
- Network maps

**Last Updated**: 2025-12-27

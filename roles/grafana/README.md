# Grafana Dashboards Role

## 📌 Overview

Triển khai **Grafana** visualization platform với pre-configured dashboards cho Prometheus, Zabbix, và các data sources khác.

## 🚀 Quick Start

```bash
# Deploy Grafana
ansible-playbook playbooks/deploy-grafana.yml

# Access: http://<SERVER_IP>:3000
# Default: admin / admin (change on first login)
```

## ⚙️ Variables

```yaml
grafana_version: "10.0.0"
grafana_port: 3000
grafana_domain: "grafana.example.com"
grafana_root_url: "http://grafana.example.com"

# Security
grafana_admin_user: "admin"
grafana_admin_password: "admin"  # Change this!

# Data Sources
grafana_datasources:
  - name: "Prometheus"
    type: "prometheus"
    url: "http://localhost:9090"
    is_default: yes
```

## 🔧 Operations

```bash
# Check status
sudo systemctl status grafana-server

# Reset admin password
sudo grafana-cli admin reset-admin-password <new_password>

# Install plugins
sudo grafana-cli plugins install <plugin-name>

# View logs
sudo tail -f /var/log/grafana/grafana.log

# Restart
sudo systemctl restart grafana-server
```

## 📊 Pre-configured Dashboards

- **Node Exporter Full**: System metrics
- **HAProxy**: Load balancer stats
- **MariaDB**: Database performance
- **Suricata**: IDS metrics

**Last Updated**: 2025-12-27

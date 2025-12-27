# Prometheus Monitoring Role

## 📌 Overview

Triển khai **Prometheus** time-series database và metrics collector cho infrastructure monitoring.

## 🚀 Quick Start

```bash
# Deploy Prometheus
ansible-playbook playbooks/deploy-prometheus.yml

# Access: http://<SERVER_IP>:9090
```

## ⚙️ Variables

```yaml
prometheus_version: "2.45.0"
prometheus_listen_address: "0.0.0.0:9090"
prometheus_data_dir: "/var/lib/prometheus"
prometheus_retention: "15d"

# Scrape targets
prometheus_scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node'
    static_configs:
      - targets: 
        - '192.168.1.101:9100'
        - '192.168.1.102:9100'
```

## 🔧 Operations

```bash
# Check status
sudo systemctl status prometheus

# View targets
curl http://localhost:9090/api/v1/targets

# Query metrics
curl 'http://localhost:9090/api/v1/query?query=up'

# Reload config (no downtime)
sudo systemctl reload prometheus

# View logs
sudo journalctl -fu prometheus
```

## 📊 PromQL Queries

```promql
# CPU usage
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

# Disk usage
100 - ((node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100)

# Network traffic
rate(node_network_receive_bytes_total[5m])
```

**Last Updated**: 2025-12-27

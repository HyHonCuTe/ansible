# HAProxy Load Balancer Role

## 📌 Overview

Triển khai **HAProxy** load balancer với health checks, statistics dashboard, và integration với Keepalived cho High Availability.

## 🚀 Quick Start

```bash
# Deploy HA stack
./deploy_ha.sh

# Or using playbook
ansible-playbook playbooks/deploy_ha_loadbalancer.yml

# Verify
ansible-playbook playbooks/verify_ha_loadbalancer.yml
```

## ⚙️ Variables

```yaml
# VIP Configuration
haproxy_vip: "192.168.1.100"
haproxy_vip_interface: "ens192"

# Backend Servers
haproxy_backends:
  - name: "web-01"
    ip: "192.168.1.27"
    port: 80
  - name: "web-02"
    ip: "192.168.1.30"
    port: 80

# Stats
haproxy_stats_enabled: yes
haproxy_stats_port: 8888
haproxy_stats_user: "admin"
haproxy_stats_password: "admin"
```

## 🔧 Operations

```bash
# Check status
sudo systemctl status haproxy

# View stats
curl -u admin:admin http://192.168.1.100:8888/stats

# Check backends
echo "show stat" | sudo socat stdio /run/haproxy/admin.sock

# Reload config (no downtime)
sudo systemctl reload haproxy

# Test VIP
curl http://192.168.1.100
```

## 🐛 Troubleshooting

**VIP not accessible:**
```bash
# Check HAProxy
sudo systemctl status haproxy

# Check Keepalived
sudo systemctl status keepalived

# Verify VIP
ip addr show | grep 192.168.1.100

# Check logs
sudo tail -f /var/log/haproxy.log
sudo tail -f /var/log/messages | grep VRRP
```

**Backend down:**
```bash
# Test backend directly
curl http://192.168.1.27

# Check HAProxy logs
sudo grep "web-01" /var/log/haproxy.log

# View health checks
echo "show servers state" | sudo socat stdio /run/haproxy/admin.sock
```

## 📊 Monitoring

**Access Stats Dashboard:**
- URL: `http://192.168.1.100:8888/stats`
- Username: admin
- Password: admin

**Metrics to Monitor:**
- Backend status (UP/DOWN)
- Request rate
- Response time
- Session count
- Error rate

**Last Updated**: 2025-12-27

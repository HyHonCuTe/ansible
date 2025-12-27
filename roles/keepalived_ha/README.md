# Keepalived High Availability Role

## 📌 Overview

Triển khai **Keepalived** với VRRP để cung cấp Virtual IP failover cho HAProxy load balancers.

## 🚀 Quick Start

```bash
# Deploy (usually with HAProxy)
./deploy_ha.sh

# Or separate
ansible-playbook playbooks/deploy_ha_loadbalancer.yml
```

## ⚙️ Variables

```yaml
# VRRP Configuration
haproxy_vip: "192.168.1.100"
haproxy_vip_interface: "ens192"
haproxy_router_id: 51
haproxy_auth_pass: "secure_password"

# Priority (Master has higher)
haproxy_priority: 101  # Master
haproxy_priority: 100  # Backup

# State
haproxy_state: "MASTER"  # or "BACKUP"
```

## 🔧 Operations

```bash
# Check status
sudo systemctl status keepalived

# View VIP
ip addr show | grep 192.168.1.100

# Check VRRP state
sudo journalctl -fu keepalived
sudo tail -f /var/log/messages | grep VRRP

# Test failover
# On Master:
sudo systemctl stop keepalived
# VIP should move to Backup

# Verify on Backup:
ip addr show | grep 192.168.1.100
```

## 🐛 Troubleshooting

**Split Brain (both have VIP):**
```bash
# Check VRRP communication
sudo tcpdump -i ens192 vrrp

# Verify multicast
ping 224.0.0.18

# Check firewall
sudo firewall-cmd --add-protocol=vrrp --permanent
sudo firewall-cmd --reload
```

**VIP not moving on failover:**
```bash
# Check priority
cat /etc/keepalived/keepalived.conf | grep priority

# Verify state
sudo journalctl -u keepalived | grep -i state

# Check track script
sudo /etc/keepalived/check_haproxy.sh
```

**Last Updated**: 2025-12-27

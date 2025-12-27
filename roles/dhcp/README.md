# DHCP Server Role

## 📌 Overview

Triển khai **DHCP Server** với scope configuration, reservations, và failover support.

## 🚀 Quick Start

```bash
ansible-playbook playbooks/install_dhcp_li.yml
```

## ⚙️ Variables

```yaml
dhcp_domain: "example.local"
dhcp_nameservers:
  - "192.168.1.10"
  - "192.168.1.11"

dhcp_scopes:
  - subnet: "192.168.1.0"
    netmask: "255.255.255.0"
    range_start: "192.168.1.100"
    range_end: "192.168.1.200"
    router: "192.168.1.1"
    lease_time: 86400

dhcp_reservations:
  - mac: "00:11:22:33:44:55"
    ip: "192.168.1.50"
    hostname: "server01"
```

## 🔧 Operations

```bash
# Check service
sudo systemctl status dhcpd

# View leases
sudo cat /var/lib/dhcpd/dhcpd.leases

# Test configuration
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# View active leases
sudo dhcp-lease-list

# Restart
sudo systemctl restart dhcpd
```

**Last Updated**: 2025-12-27

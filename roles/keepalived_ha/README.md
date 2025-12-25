# Keepalived High Availability Role

Role này cài đặt và cấu hình Keepalived để tạo Virtual IP (VIP) và High Availability cho HAProxy load balancers.

## Mô Tả

Role này thực hiện:
- Cài đặt Keepalived
- Cấu hình VRRP protocol
- Setup Virtual IP (VIP)
- Tạo health check script cho HAProxy
- Configure kernel parameters (IP forwarding, nonlocal bind)
- Firewall configuration cho VRRP

## Requirements

- AlmaLinux/RHEL/CentOS 8+
- Python 3
- HAProxy đã được cài đặt
- Firewalld service running
- Network interface hỗ trợ multicast

## Role Variables

### defaults/main.yml

```yaml
# VRRP configuration
keepalived_virtual_router_id: 51
keepalived_virtual_ip: 192.168.1.100
keepalived_interface: "{{ ansible_default_ipv4.interface }}"

# State and priority (định nghĩa trong inventory)
keepalived_state: BACKUP
keepalived_priority: 90

# VRRP settings
keepalived_advert_int: 1  # Advertisement interval
keepalived_auth_type: PASS
keepalived_auth_pass: "HA_SECRET_2025"

# Health check script
keepalived_check_script: "/usr/local/bin/check_haproxy.sh"
keepalived_check_interval: 2
keepalived_check_weight: -10
```

### Inventory Variables

**Quan trọng**: Phải định nghĩa `keepalived_state` và `keepalived_priority` trong inventory:

```yaml
ha_servers:
  hosts:
    HA1:
      ansible_host: 192.168.1.8
      keepalived_state: MASTER
      keepalived_priority: 100
    HA2:
      ansible_host: 192.168.1.25
      keepalived_state: BACKUP
      keepalived_priority: 90
  vars:
    virtual_ip: 192.168.1.100
    virtual_router_id: 51
```

## Dependencies

- HAProxy phải được cài đặt và chạy
- Socat package (cho health check script)

## Example Playbook

```yaml
- name: Deploy Keepalived
  hosts: ha_servers
  become: yes
  vars:
    keepalived_virtual_ip: "{{ virtual_ip }}"
    keepalived_virtual_router_id: "{{ virtual_router_id }}"
  roles:
    - role: keepalived_ha
```

## Features

- ✅ VRRP protocol cho failover tự động
- ✅ Virtual IP management
- ✅ HAProxy health check integration
- ✅ Priority-based master election
- ✅ Sub-second failover
- ✅ Kernel parameter optimization

## VRRP Configuration

### Master Node
- Priority cao hơn (100)
- Giữ VIP khi healthy
- Quảng bá VRRP advertisements

### Backup Node
- Priority thấp hơn (90)
- Standby mode
- Tự động nhận VIP khi Master fail

## Health Check Script

Script `/usr/local/bin/check_haproxy.sh` kiểm tra:
1. HAProxy process đang chạy
2. HAProxy listening trên port 80
3. HAProxy stats socket responsive

Nếu check fail: priority giảm 10 → VIP failover sang backup

## Testing

### Kiểm tra VIP Assignment

```bash
# Trên MASTER - VIP phải xuất hiện
ip addr show | grep 192.168.1.100

# Trên BACKUP - VIP không xuất hiện
ip addr show | grep 192.168.1.100
```

### Test Failover

```bash
# Terminal 1: Monitor VIP
watch -n 1 'ip addr | grep 192.168.1.100'

# Terminal 2: Stop HAProxy trên MASTER
sudo systemctl stop haproxy

# Quan sát VIP chuyển sang BACKUP trong vài giây
```

### Verify VRRP Communication

```bash
# Capture VRRP packets
sudo tcpdump -i ens192 vrrp -n

# Should see advertisements every 1 second
```

## Logs và Monitoring

```bash
# Keepalived logs
sudo journalctl -u keepalived -f

# Check VRRP state transitions
sudo journalctl -u keepalived | grep VRRP

# Health check script manual test
sudo /usr/local/bin/check_haproxy.sh
echo $?  # 0 = healthy, 1 = failed
```

## Kernel Parameters

Role tự động cấu hình:

```bash
net.ipv4.ip_forward = 1
net.ipv4.ip_nonlocal_bind = 1
```

## Firewall Rules

VRRP protocol (IP protocol 112) được allow:

```bash
firewall-cmd --list-rich-rules
# Should show: rule protocol value="vrrp" accept
```

## Troubleshooting

### VIP không xuất hiện

```bash
# Check Keepalived status
systemctl status keepalived

# Check logs
journalctl -u keepalived -n 50

# Verify VRRP traffic
tcpdump -i ens192 vrrp
```

### Failover không hoạt động

```bash
# Test health check script
/usr/local/bin/check_haproxy.sh
echo $?

# Check priority
grep priority /etc/keepalived/keepalived.conf

# Verify authentication match trên cả 2 nodes
grep auth_pass /etc/keepalived/keepalived.conf
```

### Split-brain (cả 2 nodes đều MASTER)

Kiểm tra:
- Firewall blocking VRRP
- Network connectivity giữa nodes
- Authentication password match

## License

MIT

## Author

Ansible Automation Team

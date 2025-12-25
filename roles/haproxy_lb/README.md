# HAProxy Load Balancer Role

Role này cài đặt và cấu hình HAProxy load balancer cho hệ thống High Availability.

## Mô Tả

Role này thực hiện:
- Cài đặt HAProxy
- Cấu hình load balancing với Round Robin algorithm
- Setup health check cho backend servers
- Cấu hình statistics page với authentication
- Configure logging với rsyslog
- Firewall configuration

## Requirements

- AlmaLinux/RHEL/CentOS 8+
- Python 3
- Firewalld service running
- Backend web servers đã được cài đặt và chạy

## Role Variables

### defaults/main.yml

```yaml
# HAProxy configuration
haproxy_listen_port: 80
haproxy_stats_port: 8080
haproxy_stats_user: admin
haproxy_stats_password: admin123

# Load balancing algorithm
haproxy_balance_algorithm: roundrobin

# Backend servers
haproxy_backend_servers:
  - name: web1
    ip: 192.168.1.27
    port: 80
  - name: web2
    ip: 192.168.1.30
    port: 80

# Health check configuration
haproxy_check_interval: 3000  # milliseconds
haproxy_check_rise: 2
haproxy_check_fall: 3

# Connection limits
haproxy_max_connections: 4000
haproxy_timeout_connect: 5s
haproxy_timeout_client: 50s
haproxy_timeout_server: 50s
```

## Dependencies

- Backend web servers phải có endpoint `/health.html` trả về status 200

## Example Playbook

```yaml
- name: Deploy HAProxy
  hosts: ha_servers
  become: yes
  vars:
    haproxy_backend_servers:
      - name: web1
        ip: 192.168.1.27
        port: 80
      - name: web2
        ip: 192.168.1.30
        port: 80
  roles:
    - role: haproxy_lb
```

## Features

- ✅ Round Robin load balancing
- ✅ Health check tự động với HTTP method
- ✅ Statistics page tại port 8080
- ✅ Custom error pages
- ✅ Request logging
- ✅ Config validation trước khi reload

## Testing

```bash
# Test HAProxy service
systemctl status haproxy

# Access statistics page
curl -u admin:admin123 http://192.168.1.8:8080/stats

# Test load balancing
for i in {1..10}; do curl http://192.168.1.8/; done

# Check backend status
echo "show stat" | socat stdio /var/lib/haproxy/stats
```

## HAProxy Stats Page

Access tại: `http://<ha_server_ip>:8080/stats`
- Username: `admin`
- Password: `admin123`

## Logs

HAProxy logs được lưu tại: `/var/log/haproxy.log`

```bash
# Monitor logs
tail -f /var/log/haproxy.log

# View statistics
echo "show info" | socat stdio /var/lib/haproxy/stats
```

## Troubleshooting

### Config Syntax Check

```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
```

### Backend Health Status

```bash
echo "show stat" | socat stdio /var/lib/haproxy/stats | column -t -s,
```

## License

MIT

## Author

Ansible Automation Team

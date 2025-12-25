# Web Server HA Role

Role này cài đặt và cấu hình Apache web server cho hệ thống High Availability Load Balancing.

## Mô Tả

Role này thực hiện:
- Cài đặt Apache HTTPD và mod_ssl
- Tạo custom index.html page với server identification
- Tạo health check endpoint cho HAProxy
- Cấu hình firewall rules
- Khởi động và enable Apache service

## Requirements

- AlmaLinux/RHEL/CentOS 8+
- Python 3
- Firewalld service running
- SELinux enforcing mode

## Role Variables

### defaults/main.yml

```yaml
# Web server configuration
web_server_port: 80
document_root: /var/www/html

# Server identification
server_name: "{{ ansible_hostname }}"
server_color: "#2ecc71"  # Default green

# Apache packages
apache_packages:
  - httpd
  - mod_ssl

# Firewall configuration
firewall_enabled: true
firewall_ports:
  - 80/tcp
  - 443/tcp

# SELinux configuration
selinux_mode: enforcing
```

### Inventory Variables

Cần định nghĩa trong inventory:

```yaml
web_servers:
  hosts:
    Web1:
      ansible_host: 192.168.1.27
      server_name: WEB-1
      server_color: "#3498db"  # Blue
    Web2:
      ansible_host: 192.168.1.30
      server_name: WEB-2
      server_color: "#e74c3c"  # Red
```

## Dependencies

Không có dependencies bên ngoài.

## Example Playbook

```yaml
- name: Deploy Web Servers
  hosts: web_servers
  become: yes
  roles:
    - role: webserver_ha
```

## Features

- ✅ Custom HTML page với server identification
- ✅ Health check endpoint tại `/health.html`
- ✅ Color-coded UI để dễ phân biệt servers
- ✅ Firewall configuration tự động
- ✅ Service verification sau khi cài đặt

## Testing

```bash
# Test Apache service
curl http://192.168.1.27/

# Test health check
curl http://192.168.1.27/health.html

# Verify service
ansible web_servers -m shell -a "systemctl status httpd" -b
```

## License

MIT

## Author

Ansible Automation Team

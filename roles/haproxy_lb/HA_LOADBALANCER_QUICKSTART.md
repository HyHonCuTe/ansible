# High Availability Load Balancer - Quick Start Guide

Hệ thống High Availability Load Balancing với HAProxy, Keepalived và Apache trên AlmaLinux.

## 📋 Mô Hình Hệ Thống

```
                    ┌─────────────────────┐
                    │   Client Access     │
                    │   192.168.1.100     │ 
                    │   (Virtual IP)      │
                    └──────────┬──────────┘
                               │
                ┌──────────────┴───────────────┐
                │                              │
         ┌──────▼──────┐              ┌───────▼─────┐
         │    HA1      │              │    HA2      │
         │ 192.168.1.8 │◄────VRRP────►│192.168.1.25 │
         │  (MASTER)   │              │  (BACKUP)   │
         │  Priority:  │              │  Priority:  │
         │    100      │              │     90      │
         └──────┬──────┘              └───────┬─────┘
                │         HAProxy             │
                │      Load Balancing         │
                └──────────┬───────────────────┘
                           │
                ┌──────────┴──────────┐
                │                     │
         ┌──────▼──────┐      ┌──────▼──────┐
         │    WEB-1    │      │    WEB-2    │
         │192.168.1.27 │      │192.168.1.30 │
         │   Apache    │      │   Apache    │
         └─────────────┘      └─────────────┘
```

## 🚀 Triển Khai Nhanh

### 1. Kiểm tra kết nối

```bash
cd /home/ansible/Desktop/ansible
ansible ha_servers,web_servers -i inventory/hosts.yml -m ping
```

### 2. Triển khai toàn bộ hệ thống

```bash
ansible-playbook -i inventory/hosts.yml playbooks/deploy_ha_loadbalancer.yml
```

### 3. Xác minh triển khai

```bash
ansible-playbook -i inventory/hosts.yml playbooks/verify_ha_loadbalancer.yml
```

## 📊 Kiểm Tra Hệ Thống

### Truy cập dịch vụ

- **Web Application**: http://192.168.1.100
- **HAProxy Stats (HA1)**: http://192.168.1.8:8080/stats
- **HAProxy Stats (HA2)**: http://192.168.1.25:8080/stats
  - Username: `admin`
  - Password: `admin123`

### Test Load Balancing

```bash
# Test 10 requests
for i in {1..10}; do
    curl -s http://192.168.1.100 | grep "server-badge" | grep -o "WEB-[12]"
done
```

Kết quả mong đợi: Luân phiên giữa WEB-1 và WEB-2

### Kiểm tra VIP

```bash
# Trên HA1 hoặc HA2
ip addr show ens192 | grep 192.168.1.100

# Kiểm tra trạng thái Keepalived
sudo systemctl status keepalived
```

## 🔄 Test High Availability (Failover)

### Kịch bản 1: Stop HAProxy trên MASTER

```bash
# Terminal 1: Monitor traffic
watch -n 1 'curl -s http://192.168.1.100 | grep "server-badge"'

# Terminal 2: Stop HAProxy trên HA1 (MASTER)
ssh ansible@192.168.1.8
sudo systemctl stop haproxy

# Quan sát:
# - VIP tự động chuyển sang HA2
# - Terminal 1 tiếp tục hoạt động không gián đoạn
```

### Kịch bản 2: Stop Keepalived trên MASTER

```bash
# Terminal 1: Monitor VIP
watch -n 1 'ip addr | grep 192.168.1.100'

# Terminal 2: Stop Keepalived trên HA1
ssh ansible@192.168.1.8
sudo systemctl stop keepalived

# Quan sát:
# - VIP xuất hiện trên HA2 trong vòng 3 giây
```

### Khôi phục dịch vụ

```bash
# Trên HA1
sudo systemctl start haproxy
sudo systemctl start keepalived

# Kiểm tra
sudo systemctl status haproxy keepalived
```

## 📈 Monitoring và Logs

### HAProxy Logs

```bash
# Real-time logs
sudo tail -f /var/log/haproxy.log

# Check backend health
echo "show stat" | sudo socat stdio /var/lib/haproxy/stats
```

### Keepalived Logs

```bash
# Check Keepalived logs
sudo journalctl -u keepalived -f

# Check VRRP messages
sudo journalctl -u keepalived | grep VRRP
```

### Service Status

```bash
# Check all services
ansible ha_servers -i inventory/hosts.yml -m shell \
  -a "systemctl status haproxy keepalived" -b

ansible web_servers -i inventory/hosts.yml -m shell \
  -a "systemctl status httpd" -b
```

## 🔧 Troubleshooting

### VIP không hoạt động

```bash
# Kiểm tra VRRP traffic
sudo tcpdump -i ens192 vrrp

# Kiểm tra firewall
sudo firewall-cmd --list-all
```

### HAProxy không phân phối traffic

```bash
# Kiểm tra HAProxy config
sudo haproxy -c -f /etc/haproxy/haproxy.cfg

# Kiểm tra backend health
curl http://192.168.1.27/health.html
curl http://192.168.1.30/health.html
```

### Keepalived không failover

```bash
# Kiểm tra health check script
sudo /usr/local/bin/check_haproxy.sh
echo $?  # Should return 0 if healthy

# Check logs
sudo journalctl -u keepalived -n 50
```

## 📝 Cấu Trúc Thư Mục

```
ansible/
├── inventory/
│   └── hosts.yml              # Inventory với ha_servers và web_servers
├── roles/
│   ├── webserver_ha/          # Apache web server role
│   │   ├── defaults/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── handlers/
│   ├── haproxy_lb/            # HAProxy load balancer role
│   │   ├── defaults/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── handlers/
│   └── keepalived_ha/         # Keepalived HA role
│       ├── defaults/
│       ├── tasks/
│       ├── templates/
│       └── handlers/
└── playbooks/
    ├── deploy_ha_loadbalancer.yml    # Deployment playbook
    └── verify_ha_loadbalancer.yml    # Verification playbook
```

## 🎯 Các Tính Năng Chính

### HAProxy
- ✅ Load balancing với thuật toán Round Robin
- ✅ Health check tự động cho backend servers
- ✅ Statistics page với authentication
- ✅ Custom error pages
- ✅ Request logging

### Keepalived
- ✅ VRRP protocol cho HA
- ✅ Virtual IP failover tự động
- ✅ HAProxy health check integration
- ✅ Priority-based master election
- ✅ Sub-second failover time

### Web Servers
- ✅ Apache HTTPD với custom pages
- ✅ Health check endpoint
- ✅ Unique identification (WEB-1, WEB-2)
- ✅ Color-coded UI
- ✅ SELinux và Firewall configured

## 🔒 Security

- Firewall rules configured tự động
- SELinux enforcing mode
- HAProxy stats với authentication
- Minimal exposed ports
- Health check scripts với proper permissions

## 📚 Tài Liệu Tham Khảo

- HAProxy Documentation: https://www.haproxy.org/
- Keepalived Documentation: https://www.keepalived.org/
- VRRP RFC 3768: https://tools.ietf.org/html/rfc3768

## 🤝 Support

Để được hỗ trợ hoặc báo lỗi, vui lòng:
1. Kiểm tra logs trên các servers
2. Chạy playbook verify để xem trạng thái chi tiết
3. Kiểm tra connectivity giữa các nodes

---

**Lưu ý**: Đảm bảo tất cả servers đã được cấu hình đúng trong inventory và có thể kết nối qua SSH trước khi triển khai.

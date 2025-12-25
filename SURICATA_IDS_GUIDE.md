# SURICATA IDS DEPLOYMENT GUIDE
Hệ thống giám sát xâm nhập (IDS) cho infrastructure High Availability

## 📋 Tổng quan hệ thống

### Kiến trúc hiện tại
```
┌─────────────────────────────────────────────────────────────┐
│                    HA Load Balancer                         │
│  ┌──────────────┐              ┌──────────────┐            │
│  │   HAProxy1   │              │   HAProxy2   │            │
│  │ 192.168.1.8  │◄────────────►│ 192.168.1.25 │            │
│  │   (MASTER)   │              │   (BACKUP)   │            │
│  └──────────────┘              └──────────────┘            │
│         │                             │                     │
│         └─────────────┬───────────────┘                     │
│                       │ VIP: 192.168.1.100                  │
└───────────────────────┼─────────────────────────────────────┘
                        │
            ┌───────────┴───────────┐
            │                       │
    ┌───────▼────────┐      ┌──────▼─────────┐
    │    Web1        │      │     Web2       │
    │ 192.168.1.27   │◄────►│ 192.168.1.30   │
    │   (PRIMARY)    │      │   (REPLICA)    │
    └────────────────┘      └────────────────┘
            │                       │
            └───────────┬───────────┘
                        │
                        │ MariaDB Replication
                        │
    ┌───────────────────▼────────────────────┐
    │        Suricata IDS Server             │
    │         192.168.1.26                   │
    │    Interface: ens192 (PROMISC)         │
    │    Giám sát: TOÀN BỘ traffic           │
    └────────────────────────────────────────┘
```

### Thông tin Server IDS

**Server:** IDS-Server  
**IP:** 192.168.1.26  
**Interface giám sát:** ens192  
**Network giám sát:** 192.168.1.0/24  
**Vai trò:** Passive IDS (không can thiệp traffic)

## 🚀 Triển khai Suricata IDS

### Bước 1: Kiểm tra kết nối

```bash
# Kiểm tra kết nối đến IDS server
ansible security_servers -m ping

# Kiểm tra interface ens192 tồn tại
ansible security_servers -m shell -a "ip link show ens192"
```

### Bước 2: Deploy Suricata

```bash
# Triển khai Suricata IDS
ansible-playbook playbooks/deploy_suricata_ids.yml

# Quá trình bao gồm:
# - Cài đặt Suricata
# - Cấu hình interface ens192 (promiscuous mode)
# - Cập nhật rules (Emerging Threats + Custom)
# - Deploy Web UI
# - Cấu hình firewall
```

### Bước 3: Verify triển khai

```bash
# Kiểm tra cài đặt
ansible-playbook playbooks/verify_suricata_ids.yml

# Verify sẽ kiểm tra:
# - Service đang chạy
# - Interface promiscuous mode
# - Rules đã load
# - Log files tồn tại
# - Web UI accessible
```

### Bước 4: Test với Demo attacks

```bash
# Chạy kịch bản demo tấn công
ansible-playbook playbooks/demo_suricata_attacks.yml

# Demo sẽ simulate:
# - Port scanning
# - SQL injection
# - XSS attacks
# - Directory traversal
# - Suspicious User-Agent
```

## 🌐 Truy cập Web Dashboard

**URL:** http://192.168.1.26:8080/

### Tính năng Dashboard:
- ✅ Hiển thị alerts real-time (auto-refresh 5s)
- ✅ Thống kê theo severity (High/Medium/Low)
- ✅ Filter theo IP, signature, severity
- ✅ Hiển thị chi tiết: timestamp, source, destination, protocol
- ✅ Responsive design

### Screenshot features:
- **Total Alerts:** Tổng số cảnh báo
- **High Severity:** Cảnh báo mức cao
- **Recent Alerts Table:** Bảng alerts chi tiết
- **Demo Instructions:** Hướng dẫn test

## 📊 Giám sát & Logging

### Log Files

```bash
# EVE JSON log (structured, for web UI)
tail -f /var/log/suricata/eve.json

# Fast log (one line per alert)
tail -f /var/log/suricata/fast.log

# Main Suricata log
tail -f /var/log/suricata/suricata.log
```

### Xem alerts bằng command line

```bash
# SSH vào IDS server
ssh ansible@192.168.1.26

# Đếm tổng alerts
grep '"event_type":"alert"' /var/log/suricata/eve.json | wc -l

# Xem 10 alerts mới nhất
tail -100 /var/log/suricata/eve.json | grep '"event_type":"alert"' | tail -10 | jq .

# Top signatures
grep '"event_type":"alert"' /var/log/suricata/eve.json | \
  jq -r '.alert.signature' | sort | uniq -c | sort -rn | head -10
```

### Suricata Commands

```bash
# Kiểm tra status
systemctl status suricata

# Reload rules (không restart service)
suricatasc -c reload-rules

# Xem stats real-time
suricatasc -c dump-counters

# Test configuration
suricata -T -c /etc/suricata/suricata.yaml
```

## 🎯 Kịch bản Demo cho Đồ án

### Demo 1: Suricata đang hoạt động

```bash
# 1. Mở web dashboard: http://192.168.1.26:8080/
# 2. Truy cập website HA: http://192.168.1.100/
# 3. Refresh dashboard → thấy HTTP traffic được log
```

### Demo 2: Phát hiện Port Scan

```bash
# Từ máy khác trong mạng:
nmap -sS 192.168.1.27

# Kết quả:
# - Suricata phát hiện port scan
# - Alert xuất hiện trên dashboard
# - Signature: "DEMO: Possible Port Scan Detected"
```

### Demo 3: Phát hiện SQL Injection

```bash
# Test SQL injection trên web:
curl "http://192.168.1.100/?id=1' OR '1'='1"
curl "http://192.168.1.100/?id=1' UNION SELECT * FROM users--"

# Kết quả:
# - Alert: "DEMO: SQL Injection Attempt"
# - Hiển thị source IP, destination IP
# - Severity: HIGH
```

### Demo 4: Phát hiện Suspicious Scanner

```bash
# Sử dụng sqlmap user-agent:
curl -A "sqlmap/1.0" http://192.168.1.100/

# Hoặc Nikto scanner:
curl -A "Nikto/2.1.6" http://192.168.1.100/

# Kết quả:
# - Alert: "DEMO: [Scanner] Detected"
# - Signature hiển thị loại scanner
```

### Demo 5: Giám sát toàn hệ thống HA

```bash
# 1. Cho HA Load Balancer hoạt động
ansible-playbook playbooks/verify_haproxy_keepalived.yml

# 2. Truy cập qua VIP nhiều lần
for i in {1..10}; do curl http://192.168.1.100/; sleep 1; done

# 3. Kiểm tra dashboard Suricata
# → Thấy traffic từ:
#    - VIP 192.168.1.100
#    - HAProxy nodes
#    - Web backend nodes
#    - Database replication traffic

# 4. Verify traffic patterns
ssh ansible@192.168.1.26
grep '"event_type":"http"' /var/log/suricata/eve.json | tail -20 | jq .
```

## 🛡️ Custom Rules Demo

Suricata đã được cấu hình với 20+ custom rules:

| SID      | Signature | Mô tả |
|----------|-----------|-------|
| 1000001  | Port Scan | Phát hiện 10+ SYN trong 60s |
| 1000002  | Suspicious User-Agent | sqlmap, Nikto, Burp |
| 1000003  | SQL Injection - UNION | UNION SELECT pattern |
| 1000004  | SQL Injection - OR 1=1 | OR 1=1 pattern |
| 1000008  | Directory Traversal | ..%2f, ../ |
| 1000010  | XSS Attempt | `<script>` tag |
| 1000016  | MySQL Access | External MySQL connection |

**Custom rules location:** `/etc/suricata/rules/custom.rules`

## 📈 Monitoring Best Practices

### 1. Real-time Monitoring
```bash
# Terminal 1: Watch eve.json
tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'

# Terminal 2: Generate traffic
curl http://192.168.1.100/

# Terminal 3: Web dashboard
firefox http://192.168.1.26:8080/
```

### 2. Alert Analysis
```bash
# Alerts by severity
jq -r 'select(.event_type=="alert") | .alert.severity' /var/log/suricata/eve.json | \
  sort | uniq -c

# Alerts by category
jq -r 'select(.event_type=="alert") | .alert.category' /var/log/suricata/eve.json | \
  sort | uniq -c

# Top source IPs
jq -r 'select(.event_type=="alert") | .src_ip' /var/log/suricata/eve.json | \
  sort | uniq -c | sort -rn | head -10
```

### 3. Performance Monitoring
```bash
# CPU & Memory usage
top -p $(pgrep suricata)

# Packet drop statistics
suricatasc -c dump-counters | grep -i drop

# Interface statistics
ip -s link show ens192
```

## 🔧 Troubleshooting

### Issue: Service không start

```bash
# Kiểm tra logs
journalctl -u suricata -n 50

# Test config
suricata -T -c /etc/suricata/suricata.yaml

# Kiểm tra interface
ip link show ens192
```

### Issue: Không có alerts

```bash
# Kiểm tra rules loaded
suricatasc -c ruleset-stats

# Force reload rules
suricatasc -c reload-rules

# Kiểm tra promiscuous mode
ip link show ens192 | grep PROMISC
```

### Issue: Web UI không hiển thị

```bash
# Kiểm tra httpd
systemctl status httpd

# Kiểm tra permissions
ls -la /var/log/suricata/eve.json
ls -la /var/www/html/suricata-ui/

# Kiểm tra SELinux
getsebool httpd_can_network_connect_db
```

### Issue: Promiscuous mode tắt sau reboot

```bash
# Kiểm tra systemd service
systemctl status suricata-promisc

# Enable service
systemctl enable suricata-promisc
systemctl start suricata-promisc
```

## 📚 Cấu trúc Files

```
roles/suricata/
├── defaults/
│   └── main.yml              # Variables mặc định
├── files/
│   ├── custom.rules          # 20+ custom detection rules
│   └── style.css             # Web UI stylesheet
├── handlers/
│   └── main.yml              # Service handlers
├── tasks/
│   ├── main.yml              # Main orchestration
│   ├── install.yml           # Cài đặt Suricata
│   ├── configure_network.yml # Cấu hình ens192, promiscuous
│   └── deploy_webui.yml      # Deploy web dashboard
├── templates/
│   ├── suricata.yaml.j2      # Main config
│   ├── index.php.j2          # Web UI main page
│   ├── api.php.j2            # API endpoint
│   └── suricata-ui.conf.j2   # Apache config
└── vars/
    └── main.yml              # Role variables

playbooks/
├── deploy_suricata_ids.yml   # Triển khai IDS
├── verify_suricata_ids.yml   # Kiểm tra cài đặt
└── demo_suricata_attacks.yml # Demo attack scenarios
```

## 🎓 Điểm nổi bật cho Demo/Báo cáo

1. **Passive IDS:** Không ảnh hưởng traffic production
2. **Web Dashboard:** Trực quan, real-time, responsive
3. **Custom Rules:** 20+ rules phát hiện tấn công phổ biến
4. **HA Integration:** Giám sát toàn bộ infrastructure
5. **EVE JSON:** Structured logging, dễ phân tích
6. **Auto-refresh:** Dashboard tự động cập nhật
7. **Demo scenarios:** Kịch bản test đầy đủ
8. **Promiscuous mode:** Bắt tất cả traffic trên subnet

## 🔗 Tích hợp với hệ thống

- **HAProxy Monitoring:** Traffic qua VIP 192.168.1.100
- **Web Backend:** HTTP requests đến Web1/Web2
- **Database Replication:** MySQL traffic giữa Web1-Web2
- **Management:** SSH, monitoring traffic

## 📞 Support Commands

```bash
# Quick health check
ansible security_servers -m shell -a "systemctl is-active suricata"

# Restart Suricata
ansible security_servers -m systemd -a "name=suricata state=restarted" --become

# View live alerts
ansible security_servers -m shell -a "tail -20 /var/log/suricata/fast.log" --become

# Clean old logs (nếu cần)
ansible security_servers -m shell -a "truncate -s 0 /var/log/suricata/eve.json" --become
```

---

**Deployment date:** {{ ansible_date_time.iso8601 }}  
**Maintained by:** Security Team  
**Infrastructure:** HA Load Balancer + Web Backend + MariaDB Replication  
**Monitoring:** Suricata IDS 7.0+

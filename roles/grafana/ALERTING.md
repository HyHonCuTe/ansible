# Grafana Email Alerting Configuration Guide

## Tổng quan

Role Grafana đã được cấu hình để gửi email alert khi các metrics vượt ngưỡng 80%.

## Cấu hình Email trong `defaults/main.yml`

### 1. Cấu hình SMTP Server

```yaml
# SMTP/Email Settings for Alerting
grafana_smtp_enabled: true                          # Bật/tắt email alerting
grafana_smtp_host: "smtp.gmail.com:587"            # SMTP server và port
grafana_smtp_user: "your-email@gmail.com"          # Email đăng nhập SMTP
grafana_smtp_password: "your-app-password"         # Mật khẩu hoặc App Password
grafana_smtp_from_address: "grafana-alerts@example.com"  # Email người gửi
grafana_smtp_from_name: "Grafana Monitoring System"     # Tên người gửi
grafana_smtp_skip_verify: false                    # Bỏ qua verify SSL (không khuyến nghị)
```

#### Ví dụ cấu hình cho các SMTP phổ biến:

**Gmail:**
```yaml
grafana_smtp_host: "smtp.gmail.com:587"
grafana_smtp_user: "your-email@gmail.com"
grafana_smtp_password: "your-app-password"  # Tạo App Password tại https://myaccount.google.com/apppasswords
```

**Office 365:**
```yaml
grafana_smtp_host: "smtp.office365.com:587"
grafana_smtp_user: "your-email@company.com"
grafana_smtp_password: "your-password"
```

**Custom SMTP Server:**
```yaml
grafana_smtp_host: "mail.company.com:25"
grafana_smtp_user: "alerts@company.com"
grafana_smtp_password: "secure-password"
```

### 2. Cấu hình Notification Channels

```yaml
# Alert Notification Channels
grafana_notification_channels:
  - name: "Email Alerts - High Priority"
    type: "email"
    is_default: true                               # Kênh mặc định
    send_reminder: true                            # Gửi reminder nếu chưa resolve
    frequency: "30m"                               # Tần suất gửi reminder
    settings:
      addresses: "admin@example.com;ops-team@example.com"  # Danh sách email (phân cách bởi ;)
      autoResolve: true                            # Tự động gửi email khi alert resolved
      uploadImage: false                           # Không đính kèm screenshot
```

**Thay đổi email nhận alert:**
```yaml
settings:
  addresses: "your-email@gmail.com;team@company.com;oncall@company.com"
```

### 3. Cấu hình Alert Thresholds

```yaml
# Alert Rules Thresholds
grafana_alert_thresholds:
  cpu_warning: 80        # Cảnh báo khi CPU > 80%
  cpu_critical: 90       # Nghiêm trọng khi CPU > 90%
  memory_warning: 80     # Cảnh báo khi RAM > 80%
  memory_critical: 90    # Nghiêm trọng khi RAM > 90%
  disk_warning: 80       # Cảnh báo khi Disk > 80%
  disk_critical: 90      # Nghiêm trọng khi Disk > 90%
```

**Thay đổi ngưỡng cảnh báo:**
- Muốn alert sớm hơn → giảm giá trị (vd: `cpu_warning: 70`)
- Muốn alert ít hơn → tăng giá trị (vd: `cpu_warning: 85`)

### 4. Cấu hình Alert Timing

```yaml
grafana_alert_evaluation_interval: "30s"      # Kiểm tra alert mỗi 30 giây
grafana_alert_notification_timeout: "30s"     # Timeout khi gửi notification
```

## Alert Rules đã được cấu hình

### 1. High CPU Usage (>80%)
- **Điều kiện:** CPU usage > 80% trong 5 phút
- **Severity:** Warning
- **Message:** "CPU usage is above 80% on {instance}"

### 2. High Memory Usage (>80%)
- **Điều kiện:** Memory usage > 80% trong 5 phút
- **Severity:** Warning
- **Message:** "Memory usage is above 80% on {instance}"

### 3. High Disk Usage (>80%)
- **Điều kiện:** Disk usage > 80% trong 5 phút
- **Severity:** Warning
- **Message:** "Disk usage is above 80% on {instance}"

### 4. Node Down
- **Điều kiện:** Node không phản hồi trong 2 phút
- **Severity:** Critical
- **Message:** "Node {instance} is down or unreachable"

## Deployment

### Bước 1: Cấu hình email trong `defaults/main.yml`

```bash
vi roles/grafana/defaults/main.yml
```

Cập nhật các giá trị:
- `grafana_smtp_user`
- `grafana_smtp_password`
- `grafana_notification_channels[0].settings.addresses`

### Bước 2: Deploy Grafana với alerting

```bash
# Deploy toàn bộ Grafana
ansible-playbook -i inventory/hosts.yml playbooks/deploy-grafana.yml

# Hoặc chỉ deploy alerting configuration
ansible-playbook -i inventory/hosts.yml playbooks/deploy-grafana.yml --tags grafana_alerting
```

### Bước 3: Kiểm tra cấu hình

```bash
# Kiểm tra SMTP configuration
ansible monitoring_servers -m shell -a "grep -A 10 '\[smtp\]' /etc/grafana/grafana.ini" --become

# Kiểm tra Grafana service
ansible monitoring_servers -m systemd -a "name=grafana-server state=started" --become
```

## Kiểm tra Alert hoạt động

### 1. Test SMTP Connection trong Grafana UI

1. Đăng nhập Grafana: `http://192.168.1.29:3000`
2. Menu: **Alerting** → **Contact points**
3. Click **Test** ở contact point "Email Alerts"
4. Kiểm tra email inbox

### 2. Test Alert Rule

Tạo tải giả để trigger alert:

```bash
# Test CPU alert
ansible monitoring_servers -m shell -a "stress-ng --cpu 4 --timeout 60s" --become

# Test Memory alert  
ansible monitoring_servers -m shell -a "stress-ng --vm 2 --vm-bytes 1G --timeout 60s" --become
```

### 3. Kiểm tra Alert Status

1. Grafana UI: **Alerting** → **Alert rules**
2. Xem trạng thái: **Normal**, **Pending**, **Firing**
3. Khi **Firing** → Email sẽ được gửi

## Troubleshooting

### Không nhận được email

1. **Kiểm tra SMTP config:**
```bash
ansible monitoring_servers -m shell -a "grep smtp /etc/grafana/grafana.ini | grep -v '^#'" --become
```

2. **Kiểm tra Grafana logs:**
```bash
ansible monitoring_servers -m shell -a "journalctl -u grafana-server -n 100 | grep -i smtp" --become
```

3. **Test SMTP từ server:**
```bash
ansible monitoring_servers -m shell -a "echo 'Test email' | mail -s 'Test' your-email@gmail.com"
```

### Gmail App Password

Nếu dùng Gmail, cần tạo App Password:
1. Truy cập: https://myaccount.google.com/apppasswords
2. Tạo password mới cho "Grafana"
3. Dùng password này thay cho mật khẩu thông thường

### Alert không trigger

1. **Kiểm tra datasource:**
   - Grafana UI → Configuration → Data sources
   - Test connection với Prometheus

2. **Kiểm tra query:**
   - Grafana UI → Alerting → Alert rules
   - Click vào rule → View query → Kiểm tra data

3. **Kiểm tra threshold:**
   - Xem giá trị hiện tại có vượt ngưỡng không
   - Grafana UI → Dashboards → Prometheus System Monitoring

## Tùy chỉnh Alert Rules

Alert rules được định nghĩa trong file:
```
roles/grafana/files/alert-rules.yml
```

Để thêm/sửa alert rules:
1. Chỉnh sửa file `alert-rules.yml`
2. Chạy playbook với tag `grafana_alerting`
3. Restart Grafana hoặc đợi provisioning reload (30s)

## Security Best Practices

1. **Không commit passwords vào Git:**
   ```bash
   # Dùng ansible-vault để encrypt
   ansible-vault encrypt_string 'your-smtp-password' --name 'grafana_smtp_password'
   ```

2. **Sử dụng App Password thay vì password chính**

3. **Giới hạn email recipients:**
   - Chỉ gửi tới địa chỉ cần thiết
   - Tạo distribution list/group email

4. **Enable TLS/SSL:**
   ```yaml
   grafana_smtp_skip_verify: false
   ```

## Monitoring Alert Performance

Theo dõi hiệu suất alerting:
- Grafana UI → Alerting → **Admin** tab
- Xem notification history
- Kiểm tra error rate

---

**Lưu ý:** 
- Alert sẽ trigger sau khi metric vượt ngưỡng **liên tục trong 5 phút**
- Email reminder được gửi mỗi **30 phút** nếu alert chưa resolve
- Tất cả cấu hình có thể thay đổi trong `roles/grafana/defaults/main.yml`

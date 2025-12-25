# DNS Role - Validation & Health Check Guide

## Tính năng mới đã thêm

### ✅ DNS Service Validation

Role DNS đã được cải thiện với validation tasks để đảm bảo deployment thành công.

## Validation Tests

### 1. Service Status Check
- Kiểm tra DNS service đang running
- Verify start type (Automatic)
- Check service health

### 2. Feature Installation Check
- Verify DNS feature installed
- Check installation state
- Validate management tools

### 3. DNS Zones Check
- List tất cả zones
- Check zone types (Primary/Secondary)
- Verify zone count

### 4. DNS Forwarders Check
- List configured forwarders
- Verify external DNS resolution

### 5. DNS Resolution Tests

**Internal Resolution:**
- Test resolve hostname local
- Verify internal zone records

**External Resolution:**
- Test google.com
- Test microsoft.com
- Verify forwarders hoạt động

### 6. Port Status Check
- Verify port 53 TCP listening
- Check UDP port 53
- Validate network bindings

### 7. DNS Statistics
- Total queries
- Total responses
- Recursive queries
- Secure update count

## Usage

### Run validation during deployment

```bash
# Full deployment with validation
ansible-playbook playbooks/install_dns_win.yml
```

### Run validation only

```bash
# Chỉ run validation tasks
ansible-playbook playbooks/install_dns_win.yml --tags validate,dns_validate
```

### Manual validation

```bash
# Run ad-hoc validation
ansible windows_servers -m include_role -a "name=dns tasks_from=validate.yml"
```

## Validation Reports

Validation sẽ tạo report tại:
```
C:\DNS_Validation_Report.txt
```

### Report format:

```
╔════════════════════════════════════════════════════════╗
║         DNS Service Validation Report                 ║
║         Generated: 2025-12-25 10:30:00                ║
╠════════════════════════════════════════════════════════╣
║  Server: WIN-SERVER01
║  Service Status: Running ✅
║  Feature Installed: Yes ✅
║  Zones Configured: Yes ✅
║  Internal Resolution: Working ✅
║  External Resolution: Working ✅
║  Port 53 Listening: Yes ✅
╠════════════════════════════════════════════════════════╣
║  Overall Status: HEALTHY ✅
╚════════════════════════════════════════════════════════╝
```

## Validation Output

### Successful Validation

```
TASK [dns : Display final validation report]
ok: [dc01] => {
    "msg": [
        "╔════════════════════════════════════════════════════════╗",
        "║         DNS Service Validation Report                 ║",
        "╠════════════════════════════════════════════════════════╣",
        "║  Overall Status: HEALTHY ✅",
        "╚════════════════════════════════════════════════════════╝"
    ]
}
```

### Failed Validation

Nếu validation fail, playbook sẽ hiển thị chi tiết lỗi:

```
TASK [dns : Check DNS service status]
failed: [dc01] => {
    "msg": "VALIDATION: FAILED - DNS service not running"
}
```

## Troubleshooting

### DNS Service not running

```bash
# Check service status
ansible windows_servers -m win_service -a "name=DNS"

# Start service
ansible windows_servers -m win_service -a "name=DNS state=started"

# Check logs
ansible windows_servers -m win_shell -a "Get-EventLog -LogName DNS-Server -Newest 20"
```

### External DNS resolution failed

```bash
# Check forwarders
ansible windows_servers -m win_shell -a "Get-DnsServerForwarder"

# Add forwarders
ansible windows_servers -m win_shell -a "Add-DnsServerForwarder -IPAddress 8.8.8.8"

# Test resolution
ansible windows_servers -m win_shell -a "Resolve-DnsName google.com"
```

### Port 53 not listening

```bash
# Check firewall
ansible windows_servers -m win_shell -a "Get-NetFirewallRule -DisplayName '*DNS*' | Select-Object DisplayName,Enabled"

# Check bindings
ansible windows_servers -m win_shell -a "Get-NetTCPConnection -LocalPort 53"

# Restart service
ansible windows_servers -m win_service -a "name=DNS state=restarted"
```

### No zones configured

```bash
# List zones
ansible windows_servers -m win_shell -a "Get-DnsServerZone"

# Check variables
# Đảm bảo dns_zone_name đã set trong vars/main.yml
```

## Integration with ADDS

Khi deploy ADDS, DNS sẽ được cài tự động. Validation DNS cũng chạy sau khi ADDS deployment:

```yaml
# Deploy ADDS (includes DNS)
- hosts: dc01
  vars:
    adds_install_dns: true
  roles:
    - adds
    - dns  # Optional: thêm validation cho DNS
```

## Best Practices

1. **Luôn run validation sau deployment**
   ```bash
   ansible-playbook playbooks/install_dns_win.yml
   ```

2. **Save validation reports**
   ```bash
   # Fetch report về local
   ansible windows_servers -m fetch \
     -a "src=C:\\DNS_Validation_Report.txt dest=./reports/"
   ```

3. **Monitor DNS health định kỳ**
   ```bash
   # Tạo cron job chạy validation hàng ngày
   ansible-playbook playbooks/dns_health_check.yml --tags validate
   ```

4. **Check logs khi có issue**
   ```bash
   ansible windows_servers -m win_shell \
     -a "Get-EventLog -LogName DNS-Server -EntryType Error -Newest 50"
   ```

## Files Updated

- `roles/dns/tasks/validate.yml` - NEW: Validation tasks
- `roles/dns/tasks/main.yml` - UPDATED: Include validation

## Tags

- `validate` - Run validation tasks
- `dns_validate` - DNS specific validation

## Author

HyHonCuTe - 2025-12-25

# Active Directory Domain Services (ADDS) Role

Ansible role để deploy Active Directory Domain Services trên Windows Server 2016/2019/2022.

## Tính năng

- ✅ Cài đặt AD DS features và management tools
- ✅ Promote server thành Domain Controller
- ✅ Tạo new forest và domain
- ✅ Cấu hình DNS server tự động
- ✅ Tạo Organizational Units (OUs)
- ✅ Tạo default users và groups
- ✅ Validation và health checks đầy đủ
- ✅ Firewall configuration cho AD DS
- ✅ Tự động reboot và wait for services

## Requirements

### Target Server
- **OS:** Windows Server 2016/2019/2022
- **RAM:** Tối thiểu 2GB (khuyến nghị 4GB+)
- **Disk:** Tối thiểu 10GB free space
- **Network:** Static IP address configured
- **WinRM:** Enabled và configured

### Ansible Controller
- **Ansible:** 2.9+
- **Collections:** 
  - `ansible.windows`
  - `community.windows`

## Role Variables

### Cấu hình Domain (bắt buộc)

```yaml
# Domain FQDN
adds_domain_name: "company.local"

# NetBIOS name (max 15 ký tự)
adds_domain_netbios_name: "COMPANY"

# SafeMode Administrator Password (DSRM)
adds_safe_mode_password: "P@ssw0rd123!"
```

### Cấu hình Domain/Forest Mode

```yaml
# Domain functional level
adds_domain_mode: "WinThreshold"  # Windows Server 2016

# Forest functional level  
adds_forest_mode: "WinThreshold"

# Options: Win2012R2, Win2016, WinThreshold
```

### Cấu hình DNS

```yaml
# Cài DNS server cùng AD DS
adds_install_dns: true

# DNS forwarders cho external resolution
adds_dns_forwarders:
  - "8.8.8.8"
  - "8.8.4.4"
```

### Cấu hình Paths

```yaml
adds_database_path: "C:\\Windows\\NTDS"
adds_log_path: "C:\\Windows\\NTDS"
adds_sysvol_path: "C:\\Windows\\SYSVOL"
```

### Organizational Units

```yaml
adds_create_default_ous: true

adds_organizational_units:
  - name: "Departments"
    path: ""
    description: "Root OU for departments"
  - name: "IT"
    path: "OU=Departments"
    description: "IT Department"
  - name: "Servers"
    path: ""
    description: "Server computers"
```

### Default Users

```yaml
adds_create_default_users: true

adds_default_users:
  - username: "admin.it"
    password: "P@ssw0rd123!"
    firstname: "IT"
    lastname: "Administrator"
    ou: "OU=IT,OU=Departments"
    description: "IT Administrator"
    groups:
      - "Domain Admins"
```

### Validation & Health Check

```yaml
# Enable validation sau khi deploy
adds_validate_installation: true

# Timeout cho validation (seconds)
adds_validation_timeout: 300

# Wait for AD Web Services
adds_wait_for_adws: true
adds_adws_timeout: 600
```

### Firewall Configuration

```yaml
# Configure Windows Firewall
adds_configure_firewall: true

# Tự động mở các ports cần thiết:
# - LDAP: 389 (TCP/UDP)
# - LDAPS: 636 (TCP)
# - Kerberos: 88 (TCP/UDP)
# - DNS: 53 (TCP/UDP)
# - SMB: 445 (TCP)
# - RPC: 135 (TCP)
```

## Playbook Usage

### Basic Deployment

```yaml
---
- name: Deploy ADDS
  hosts: windows_servers
  roles:
    - adds
```

### Custom Configuration

```yaml
---
- name: Deploy ADDS with custom settings
  hosts: dc01
  vars:
    adds_domain_name: "mycompany.local"
    adds_domain_netbios_name: "MYCOMPANY"
    adds_safe_mode_password: "YourSecurePassword123!"
    adds_install_dns: true
    adds_create_default_ous: true
    adds_dns_forwarders:
      - "1.1.1.1"
      - "8.8.8.8"
  roles:
    - adds
```

### Using Playbook

```bash
# Run full deployment
ansible-playbook playbooks/deploy_adds.yml

# Chỉ install features (không promote)
ansible-playbook playbooks/deploy_adds.yml --tags install

# Chỉ validation
ansible-playbook playbooks/deploy_adds.yml --tags validate

# Skip post-configuration
ansible-playbook playbooks/deploy_adds.yml --skip-tags post_config
```

## Inventory Configuration

```ini
[windows_servers]
dc01 ansible_host=192.168.1.50

[windows_servers:vars]
ansible_user=Administrator
ansible_password=YourPassword
ansible_connection=winrm
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
ansible_port=5985
```

## Deployment Steps

Role sẽ thực hiện các bước sau:

1. **Pre-checks**
   - Kiểm tra OS version
   - Kiểm tra system requirements (RAM, Disk)
   - Validate WinRM connectivity

2. **Installation**
   - Install AD DS features
   - Install management tools
   - Install DNS (nếu enabled)
   - Reboot nếu cần

3. **Domain Configuration**
   - Promote to Domain Controller
   - Create new forest
   - Configure domain/forest mode
   - Set DSRM password
   - Configure DNS forwarders
   - Configure firewall rules
   - Reboot server

4. **Validation**
   - Wait for AD Web Services
   - Verify domain controller
   - Test DNS resolution
   - Check critical services
   - Run DCDiag tests
   - Verify SYSVOL/NTDS

5. **Post-Configuration** (optional)
   - Create OUs
   - Create users
   - Create groups

## Validation Tests

Role thực hiện các validation tests:

### Service Checks
- ✅ Active Directory Web Services (ADWS)
- ✅ DNS Server
- ✅ Netlogon
- ✅ NT Directory Services (NTDS)
- ✅ Kerberos Key Distribution Center (KDC)
- ✅ Windows Time Service

### Functionality Tests
- ✅ DCDiag connectivity test
- ✅ DNS registration test
- ✅ SYSVOL share test
- ✅ NTDS database test
- ✅ Domain controller query
- ✅ Forest/domain mode verification

### Reports Generated
- `C:\AD_Validation_Report.txt` - Validation summary
- `C:\ADDS_Deployment_Log.txt` - Deployment log

## Troubleshooting

### Server không reboot sau promotion

```yaml
# Đảm bảo auto_reboot enabled
adds_auto_reboot: true
```

### AD Web Services không start

```bash
# Check service manually
ansible windows_servers -m win_service -a "name=ADWS state=started"

# Increase timeout
adds_adws_timeout: 900
```

### DNS forwarders không apply

```bash
# Check DNS forwarders
ansible windows_servers -m win_shell -a "Get-DnsServerForwarder"

# Manually add forwarder
ansible windows_servers -m win_shell -a "Add-DnsServerForwarder -IPAddress 8.8.8.8"
```

### Validation failed

```bash
# Run validation only
ansible-playbook playbooks/deploy_adds.yml --tags validate

# Check validation report
ansible windows_servers -m win_shell -a "Get-Content C:\AD_Validation_Report.txt"

# Check logs
ansible windows_servers -m win_shell -a "Get-EventLog -LogName 'Directory Service' -Newest 50"
```

## Security Considerations

1. **DSRM Password**
   ```yaml
   # Sử dụng ansible-vault để encrypt password
   ansible-vault encrypt_string 'YourSecurePassword' --name 'adds_safe_mode_password'
   ```

2. **WinRM Security**
   - Sử dụng HTTPS (port 5986) thay vì HTTP
   - Enable certificate validation
   - Sử dụng CredSSP cho multi-hop scenarios

3. **Firewall**
   - Role tự động configure firewall rules
   - Review và customize `adds_firewall_rules` nếu cần

4. **Backup**
   - Backup domain sau khi deploy
   - Document DSRM password an toàn

## Advanced Examples

### Deploy với custom OUs và users

```yaml
---
- hosts: dc01
  vars:
    adds_domain_name: "example.local"
    adds_create_default_ous: true
    adds_organizational_units:
      - name: "Corporate"
        path: ""
        description: "Corporate users"
      - name: "Contractors"
        path: ""
        description: "Contractor accounts"
      - name: "ServiceAccounts"
        path: ""
        description: "Service accounts"
    
    adds_create_default_users: true
    adds_default_users:
      - username: "svc.backup"
        password: "ComplexP@ss123!"
        firstname: "Backup"
        lastname: "Service"
        ou: "OU=ServiceAccounts"
        groups:
          - "Backup Operators"
  
  roles:
    - adds
```

### Deploy multiple DCs (additional DC)

```yaml
# Note: Role hiện tại chỉ support new forest
# Để add additional DC, cần customize hoặc dùng win_domain_controller module
```

## Testing

```bash
# Test inventory connectivity
ansible windows_servers -m win_ping

# Test WinRM
ansible windows_servers -m win_shell -a "hostname"

# Dry run (check mode)
ansible-playbook playbooks/deploy_adds.yml --check

# Verbose output
ansible-playbook playbooks/deploy_adds.yml -vvv
```

## Files Structure

```
roles/adds/
├── defaults/
│   └── main.yml          # Default variables
├── tasks/
│   ├── main.yml          # Main tasks
│   ├── install.yml       # Feature installation
│   ├── configure_domain.yml  # DC promotion
│   ├── validate.yml      # Validation tests
│   └── post_config.yml   # OU/User/Group creation
├── handlers/
│   └── main.yml          # Service handlers
└── README.md             # This file
```

## Dependencies

None

## License

MIT

## Author

HyHonCuTe - 2025-12-25

## Tags

- `install` - Chỉ install features
- `configure` - Chỉ configure domain
- `validate` - Chỉ validation
- `post_config` - Chỉ post-configuration
- `adds` - Run tất cả

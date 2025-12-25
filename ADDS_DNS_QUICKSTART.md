# ADDS & DNS Deployment - Quick Start Guide

## 📋 Tổng quan

Hướng dẫn nhanh để deploy Active Directory Domain Services và DNS Server trên Windows Server 2016.

## 🎯 Prerequisites

### 1. Windows Server
```bash
# Target server requirements:
- OS: Windows Server 2016/2019/2022
- RAM: >= 2GB (recommended 4GB+)
- Disk: >= 10GB free space
- Static IP configured
- Administrator credentials
```

### 2. Ansible Controller
```bash
# Install required collections
ansible-galaxy collection install ansible.windows
ansible-galaxy collection install community.windows

# Verify installation
ansible-galaxy collection list | grep windows
```

### 3. WinRM Configuration

**On target Windows Server:**
```powershell
# Enable WinRM (run as Administrator)
winrm quickconfig -q
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true

# Check WinRM listener
winrm enumerate winrm/config/listener
```

## 🚀 Quick Deployment

### Step 1: Configure Inventory

**Create/Edit inventory file:**
```ini
# inventory.ini
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

### Step 2: Test Connectivity

```bash
# Test WinRM connection
ansible windows_servers -i inventory.ini -m win_ping

# Expected output:
# dc01 | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### Step 3: Configure Variables

**Option A: Edit defaults/main.yml**
```yaml
# roles/adds/defaults/main.yml
adds_domain_name: "mycompany.local"
adds_domain_netbios_name: "MYCOMPANY"
adds_safe_mode_password: "P@ssw0rd123!"
```

**Option B: Use extra vars**
```bash
# Create vars file
cat > adds_vars.yml << 'EOF'
adds_domain_name: "mycompany.local"
adds_domain_netbios_name: "MYCOMPANY"
adds_safe_mode_password: "P@ssw0rd123!"
adds_install_dns: true
adds_create_default_ous: true
EOF
```

### Step 4: Deploy ADDS

```bash
# Full deployment with confirmation prompt
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml

# Or with extra vars
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml \
  -e @adds_vars.yml

# Skip confirmation (automated deployment)
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml \
  -e "confirm_deployment=yes"
```

**⏱️ Deployment time:** ~15-30 minutes (includes server reboots)

### Step 5: Validate Deployment

```bash
# Run comprehensive validation
ansible-playbook -i inventory.ini playbooks/validate_adds_dns.yml

# Or validate specific component
ansible-playbook -i inventory.ini playbooks/validate_adds_dns.yml \
  --tags validate_dns
```

## 📊 Deployment Stages

### Stage 1: Pre-checks (2-3 min)
- ✅ Verify Windows Server OS
- ✅ Check RAM >= 2GB
- ✅ Check disk space >= 10GB
- ✅ Validate WinRM connectivity

### Stage 2: Feature Installation (5-10 min)
- ✅ Install AD-Domain-Services
- ✅ Install RSAT tools
- ✅ Install DNS Server
- ⚠️ **Server reboot #1**

### Stage 3: Domain Promotion (5-10 min)
- ✅ Promote to Domain Controller
- ✅ Create new forest
- ✅ Configure DNS forwarders
- ✅ Configure firewall rules
- ⚠️ **Server reboot #2**

### Stage 4: Validation (2-5 min)
- ✅ Verify AD services
- ✅ Test DNS resolution
- ✅ Check domain functionality
- ✅ Run DCDiag tests

### Stage 5: Post-Configuration (1-2 min)
- ✅ Create OUs
- ✅ Create default users
- ✅ Create security groups

## 🔍 Verification

### Check Domain Status
```bash
# Via Ansible
ansible windows_servers -i inventory.ini -m win_shell \
  -a "Get-ADDomain | Select-Object DNSRoot,NetBIOSName,DomainMode"

# Expected output:
# DNSRoot         NetBIOSName  DomainMode
# -------         -----------  ----------
# mycompany.local MYCOMPANY    Windows2016Domain
```

### Check DNS Status
```bash
# Via Ansible
ansible windows_servers -i inventory.ini -m win_shell \
  -a "Get-Service DNS | Select-Object Name,Status"

# Expected output:
# Name Status
# ---- ------
# DNS  Running
```

### Check Critical Services
```bash
ansible windows_servers -i inventory.ini -m win_shell -a @'
$services = @('ADWS', 'DNS', 'Netlogon', 'NTDS', 'kdc')
foreach ($svc in $services) {
  Get-Service $svc | Select-Object Name,Status
}
'@
```

### View Validation Reports
```bash
# Fetch reports from server
ansible windows_servers -i inventory.ini -m fetch \
  -a "src=C:\\Windows_Server_Validation.txt dest=./reports/ flat=yes"

# View report
cat reports/Windows_Server_Validation.txt
```

## 🎓 Common Scenarios

### Scenario 1: Basic Domain with DNS
```bash
# Minimal configuration
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml \
  -e "adds_domain_name=company.local" \
  -e "adds_domain_netbios_name=COMPANY" \
  -e "adds_safe_mode_password=SecurePass123!" \
  -e "confirm_deployment=yes"
```

### Scenario 2: With Organizational Units
```bash
# Create OUs during deployment
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml \
  -e "adds_create_default_ous=true" \
  -e "confirm_deployment=yes"
```

### Scenario 3: Validation Only
```bash
# Check existing deployment
ansible-playbook -i inventory.ini playbooks/validate_adds_dns.yml
```

## 🔧 Troubleshooting

### Issue: WinRM connection failed

**Solution:**
```bash
# Test basic connectivity
ping 192.168.1.50

# Test WinRM port
telnet 192.168.1.50 5985

# Verify credentials
ansible windows_servers -i inventory.ini -m win_shell -a "whoami"
```

### Issue: Feature installation failed

**Solution:**
```bash
# Check Windows Update
ansible windows_servers -i inventory.ini -m win_shell -a @'
Get-WindowsUpdateLog
'@

# Retry installation
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml \
  --tags install
```

### Issue: Domain promotion failed

**Solution:**
```bash
# Check promotion logs
ansible windows_servers -i inventory.ini -m win_shell -a @'
Get-Content C:\Windows\debug\dcpromo.log -Tail 50
'@

# Check event logs
ansible windows_servers -i inventory.ini -m win_shell -a @'
Get-EventLog -LogName System -Source DCPromo -Newest 20
'@
```

### Issue: Server not rebooting

**Solution:**
```bash
# Manual reboot
ansible windows_servers -i inventory.ini -m win_reboot

# Or via playbook with longer timeout
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml \
  -e "adds_auto_reboot=true"
```

### Issue: DNS not working

**Solution:**
```bash
# Run DNS validation
ansible-playbook -i inventory.ini playbooks/validate_adds_dns.yml \
  --tags validate_dns

# Check DNS service
ansible windows_servers -i inventory.ini -m win_service \
  -a "name=DNS state=started"

# Test DNS resolution
ansible windows_servers -i inventory.ini -m win_shell -a @'
Resolve-DnsName google.com
'@
```

## 📁 Generated Files

### On Windows Server:
```
C:\AD_Validation_Report.txt           - AD validation summary
C:\DNS_Validation_Report.txt          - DNS validation summary
C:\Windows_Server_Validation.txt      - Combined validation
C:\ADDS_Deployment_Log.txt            - Deployment log
```

### On Ansible Controller:
```
./validation_reports/dc01/            - Fetched validation reports
./reports/                            - Additional reports
```

## 🔐 Security Best Practices

### 1. Encrypt Sensitive Variables
```bash
# Create encrypted vars file
ansible-vault create adds_secrets.yml

# Content:
adds_safe_mode_password: "YourSecurePassword"
ansible_password: "AdminPassword"

# Use in playbook
ansible-playbook -i inventory.ini playbooks/deploy_adds.yml \
  -e @adds_secrets.yml --ask-vault-pass
```

### 2. Use HTTPS for WinRM
```ini
# inventory.ini
[windows_servers:vars]
ansible_port=5986
ansible_connection=winrm
ansible_winrm_transport=certificate
ansible_winrm_server_cert_validation=validate
```

### 3. Change DSRM Password Regularly
```bash
# After deployment, change DSRM password
ansible windows_servers -i inventory.ini -m win_shell -a @'
Set-ADAccountPassword -Identity "CN=Administrator,CN=Users,DC=company,DC=local" `
  -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "NewPassword" -Force)
'@
```

## 📚 Next Steps

After successful deployment:

1. **Join computers to domain**
   ```powershell
   Add-Computer -DomainName mycompany.local -Credential (Get-Credential)
   ```

2. **Create users and groups**
   - Via playbook: Enable `adds_create_default_users`
   - Via GUI: Active Directory Users and Computers
   - Via PowerShell: `New-ADUser`, `New-ADGroup`

3. **Configure Group Policy**
   - Open Group Policy Management Console
   - Create and link GPOs

4. **Set up DNS zones**
   - Forward lookup zones
   - Reverse lookup zones
   - Conditional forwarders

5. **Configure Sites and Services**
   - Define AD sites
   - Configure site links
   - Set up replication

## 🆘 Support

### Documentation
- ADDS Role: `roles/adds/README.md`
- DNS Validation: `roles/dns/VALIDATION.md`

### Get Help
```bash
# View role documentation
cat roles/adds/README.md

# Check playbook syntax
ansible-playbook playbooks/deploy_adds.yml --syntax-check

# Dry run (no changes)
ansible-playbook playbooks/deploy_adds.yml --check
```

---

**Author:** HyHonCuTe  
**Date:** 2025-12-25  
**Version:** 1.0

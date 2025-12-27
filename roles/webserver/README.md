# Web Server Role

## 📌 Overview

Triển khai **IIS Web Server** trên Windows hoặc **Apache/Nginx** trên Linux với application deployment.

## 🚀 Quick Start

```bash
# IIS (Windows)
ansible-playbook playbooks/install_web_win.yml

# Apache (Linux)
ansible-playbook playbooks/install_web_li.yml
```

## ⚙️ Variables (IIS)

```yaml
iis_sites:
  - name: "Default Web Site"
    port: 80
    physical_path: "C:\\inetpub\\wwwroot"
    app_pool: "DefaultAppPool"
  
  - name: "MyApp"
    port: 8080
    physical_path: "C:\\inetpub\\myapp"
    app_pool: "MyAppPool"

iis_applications:
  - name: "App1"
    site: "Default Web Site"
    physical_path: "C:\\inetpub\\apps\\app1"
```

## 🔧 Operations (IIS)

```powershell
# Check IIS
Get-Service W3SVC

# List sites
Get-Website

# Start/Stop site
Start-Website -Name "Default Web Site"
Stop-Website -Name "Default Web Site"

# Application pools
Get-IISAppPool

# Restart pool
Restart-WebAppPool -Name "DefaultAppPool"
```

## 🔧 Operations (Apache)

```bash
# Check service
sudo systemctl status httpd

# Test config
sudo httpd -t

# List virtual hosts
httpd -S

# View logs
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
```

**Last Updated**: 2025-12-27

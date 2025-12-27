# HA Web Server Role

## 📌 Overview

Triển khai **High Availability Web Servers** làm backend cho HAProxy load balancer với health checks.

## 🚀 Quick Start

```bash
# Deploy HA web stack
./deploy_ha.sh

# Or separate
ansible-playbook playbooks/demo_mariadb_web.yml
```

## ⚙️ Variables

```yaml
webserver_document_root: "/var/www/html"
webserver_port: 80

# Application
webserver_app_name: "myapp"
webserver_db_host: "192.168.1.50"
webserver_db_name: "app_db"
webserver_db_user: "app_user"
webserver_db_password: "password"

# Health check endpoint
webserver_health_check_path: "/health"
```

## 🔧 Operations

```bash
# Check service
sudo systemctl status httpd

# Test application
curl http://localhost/

# Health check
curl http://localhost/health

# View logs
sudo tail -f /var/log/httpd/access_log

# Database connection test
mysql -h 192.168.1.50 -u app_user -p app_db -e "SELECT 1"
```

## 📊 Monitoring

```bash
# Test from load balancer
curl http://192.168.1.100/

# Check which backend served request
for i in {1..10}; do curl -s http://192.168.1.100/ | grep -o "Server: [^<]*"; done

# Backend health
echo "show servers state" | sudo socat stdio /run/haproxy/admin.sock
```

**Last Updated**: 2025-12-27

# Suricata IDS/IPS Role

## 📌 Overview

Role này tự động triển khai và cấu hình **Suricata Network IDS/IPS** với web dashboard để giám sát real-time alerts và phát hiện các mối đe dọa mạng.

### Features

- ✅ **Suricata 7.0+ Installation**: Latest version với AF_PACKET support
- ✅ **Emerging Threats Rules**: Tự động cập nhật ruleset
- ✅ **Web Dashboard**: PHP-based real-time alert viewer
- ✅ **IDS & IPS Modes**: Hỗ trợ cả passive monitoring và active blocking
- ✅ **EVE JSON Logging**: Structured logging cho SIEM integration
- ✅ **Custom Rules**: Deployment của custom detection rules
- ✅ **Promiscuous Mode**: Tự động cấu hình interface
- ✅ **SELinux Compatible**: Full SELinux support với httpd_log_t context
- ✅ **Firewall Auto-config**: Tự động mở ports cần thiết

---

## 🚀 Quick Deployment

### Using Automated Script (Recommended)

```bash
./deploy_suricata.sh
```

### Using Playbook

```bash
# Deploy IDS mode
ansible-playbook playbooks/deploy_suricata_ids.yml

# Deploy IPS mode
ansible-playbook playbooks/deploy_suricata_ips.yml

# Verify installation
ansible-playbook playbooks/verify_suricata_ids.yml

# Run demo attacks
ansible-playbook playbooks/demo_suricata_attacks.yml
```

### Access Web Dashboard

- **URL**: `http://<IDS_SERVER>:8080/`
- **Features**: Real-time alerts, statistics, severity filtering, auto-refresh

---

## ⚙️ Configuration Variables

```yaml
# Network
suricata_interface: "ens192"
suricata_home_net: "[192.168.1.0/24]"
suricata_external_net: "!$HOME_NET"

# Logging
suricata_log_dir: "/var/log/suricata"
suricata_eve_log_enabled: yes

# Rules
suricata_enable_rule_update: yes
suricata_custom_rules_enabled: yes

# Web UI
suricata_web_ui_enabled: yes
suricata_web_ui_port: 8080

# IPS Mode
suricata_ips_enabled: no  # Change to yes for IPS
```

---

## 🔧 Operations

### View Alerts

```bash
# Real-time alerts
sudo tail -f /var/log/suricata/fast.log

# EVE JSON alerts
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'

# Count alerts
sudo grep -c '"event_type":"alert"' /var/log/suricata/eve.json

# Top alerts
sudo jq -r 'select(.event_type=="alert") | .alert.signature' /var/log/suricata/eve.json | sort | uniq -c | sort -rn | head -10
```

### Manage Service

```bash
# Status
sudo systemctl status suricata

# Restart
sudo systemctl restart suricata

# Reload rules (no downtime)
sudo suricatasc -c "reload-rules"
```

### Update Rules

```bash
# Update Emerging Threats rules
sudo suricata-update

# Reload rules
sudo suricatasc -c "reload-rules"

# Verify
sudo suricatasc -c "ruleset-stats"
```

---

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check logs
sudo journalctl -xeu suricata
sudo tail -100 /var/log/suricata/suricata.log

# Test configuration
sudo suricata -T -c /etc/suricata/suricata.yaml

# Check interface
ip link show ens192

# Verify sysconfig
cat /etc/sysconfig/suricata
# Should have: OPTIONS="-i ens192 --user suricata"
```

### No Alerts

```bash
# Check promiscuous mode
ip link show ens192 | grep PROMISC

# Enable if needed
sudo ip link set ens192 promisc on

# Check rules loaded
sudo suricatasc -c "ruleset-stats"

# Generate test alert
curl -A "sqlmap" http://<target>
```

### Web Dashboard Empty

```bash
# Check SELinux context (CRITICAL)
ls -laZ /var/log/suricata/eve.json

# Fix if needed
sudo semanage fcontext -a -t httpd_log_t '/var/log/suricata/.*'
sudo restorecon -Rv /var/log/suricata/

# Restart Apache
sudo systemctl restart httpd

# Test API
curl http://localhost:8080/api.php?action=get_alerts
```

### High CPU Usage

```yaml
# Tune threads in /etc/suricata/suricata.yaml
af-packet:
  - interface: ens192
    threads: 4  # Match CPU cores

# Increase memory
stream:
  memcap: 256mb
flow:
  memcap: 256mb
```

---

## 📊 Monitoring

```bash
# Runtime stats
sudo suricatasc -c "dump-counters"

# Dropped packets
sudo suricatasc -c "dump-counters" | grep -i drop

# Memory usage
sudo suricatasc -c "memcap-show"

# Uptime
sudo suricatasc -c "uptime"
```

---

## 🔒 Security Best Practices

1. **Regular Updates**: `sudo suricata-update` weekly
2. **Log Rotation**: Monitor `/var/log/suricata` disk usage
3. **Rule Tuning**: Disable false positive rules
4. **Web UI Auth**: Add Apache authentication
5. **Firewall**: Restrict port 8080 access
6. **SELinux**: Keep enforcing mode enabled

---

## 📚 Resources

- **Official Docs**: https://suricata.io/
- **Rules**: https://rules.emergingthreats.net/
- **User Guide**: https://suricata.readthedocs.io/

---

**Last Updated**: 2025-12-27 - Fixed SELinux permissions for Web UI

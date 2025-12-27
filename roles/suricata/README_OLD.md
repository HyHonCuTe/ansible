# Suricata IDS Ansible Role

## Description

Ansible role để triển khai và cấu hình Suricata IDS (Intrusion Detection System) cho giám sát an ninh mạng. Role này cung cấp:

- ✅ Cài đặt Suricata IDS tự động
- ✅ Cấu hình network interface monitoring (promiscuous mode)
- ✅ Quản lý detection rules (Emerging Threats + Custom)
- ✅ Web UI dashboard để hiển thị alerts
- ✅ Structured logging (EVE JSON format)
- ✅ Tích hợp với firewall

## Requirements

- AlmaLinux / RHEL 8+ / Rocky Linux 8+
- Ansible 2.9+
- Collections:
  - ansible.posix
  - community.general
- Network interface để giám sát (default: ens192)
- Minimum 2GB RAM
- Root/sudo access

## Role Variables

### Network Configuration

```yaml
suricata_interface: "ens192"              # Interface giám sát
suricata_home_net: "[192.168.1.0/24]"     # Mạng nội bộ
suricata_external_net: "!$HOME_NET"       # Mạng bên ngoài
```

### Service Configuration

```yaml
suricata_service_state: "started"         # started | stopped | restarted
suricata_service_enabled: yes             # yes | no
```

### Logging

```yaml
suricata_log_dir: "/var/log/suricata"
suricata_eve_log_enabled: yes
suricata_eve_log_types:
  - alert
  - http
  - dns
  - tls
  - files
  - ssh
```

### Rules

```yaml
suricata_enable_rule_update: yes
suricata_rule_sources:
  - "et/open"
suricata_custom_rules_enabled: yes
```

### Web UI

```yaml
suricata_web_ui_enabled: yes
suricata_web_ui_port: 8080
suricata_web_ui_path: "/var/www/html/suricata-ui"
```

### Performance

```yaml
suricata_af_packet_threads: 2
suricata_detect_threads: 2
suricata_stream_memcap: "128mb"
suricata_flow_memcap: "128mb"
```

## Dependencies

None

## Example Playbook

### Basic Usage

```yaml
---
- name: Deploy Suricata IDS
  hosts: security_servers
  become: yes
  roles:
    - role: suricata
```

### Advanced Usage

```yaml
---
- name: Deploy Suricata with custom config
  hosts: ids_servers
  become: yes
  vars:
    suricata_interface: "ens224"
    suricata_home_net: "[10.0.0.0/8]"
    suricata_web_ui_port: 9090
    suricata_af_packet_threads: 4
  roles:
    - role: suricata
```

### With Tags

```yaml
# Chỉ install
ansible-playbook playbook.yml --tags install

# Chỉ deploy web UI
ansible-playbook playbook.yml --tags webui

# Skip web UI
ansible-playbook playbook.yml --skip-tags webui
```

## Features

### 1. Network Monitoring
- Promiscuous mode trên interface monitoring
- AF_PACKET capture mode (high performance)
- Tự động enable promiscuous mode khi boot (systemd service)
- Disable offloading features để capture chính xác

### 2. Detection Rules
- **Emerging Threats Rules:** Tự động update từ Proofpoint
- **Custom Rules (20+ signatures):**
  - Port scanning detection
  - SQL injection attempts
  - XSS attacks
  - Directory traversal
  - Suspicious user-agents (sqlmap, Nikto, Burp)
  - SSH brute force
  - Database access attempts
  - Reverse shell detection

### 3. Web Dashboard
- Real-time alert display (auto-refresh 5s)
- Statistics: Total alerts, High/Medium/Low severity
- Filter by IP, signature, severity
- Responsive design
- REST API endpoint for alerts
- Beautiful UI with color coding

### 4. Logging
- **EVE JSON Log:** Structured logging cho automation
- **Fast Log:** One-line alerts
- **HTTP Log:** Detailed HTTP traffic
- Log rotation configured
- Proper permissions cho web UI access

### 5. Integration
- SELinux configuration
- Firewall rules (firewalld)
- Apache/httpd cho Web UI
- NetworkManager compatibility
- Systemd service management

## Directory Structure

```
roles/suricata/
├── defaults/
│   └── main.yml              # Default variables
├── files/
│   ├── custom.rules          # 20+ custom detection rules
│   └── style.css             # Web UI CSS
├── handlers/
│   └── main.yml              # Service handlers
├── tasks/
│   ├── main.yml              # Main orchestration
│   ├── install.yml           # Suricata installation
│   ├── configure_network.yml # Network config & promiscuous
│   └── deploy_webui.yml      # Web dashboard deployment
├── templates/
│   ├── suricata.yaml.j2      # Main Suricata config
│   ├── index.php.j2          # Web UI HTML/JS
│   ├── api.php.j2            # REST API for alerts
│   └── suricata-ui.conf.j2   # Apache virtual host
└── vars/
    └── main.yml              # Role variables
```

## Usage Examples

### Deploy IDS

```bash
ansible-playbook -i inventory/hosts.yml playbooks/deploy_suricata_ids.yml
```

### Verify Installation

```bash
ansible-playbook -i inventory/hosts.yml playbooks/verify_suricata_ids.yml
```

### Run Demo Attacks

```bash
ansible-playbook playbooks/demo_suricata_attacks.yml
```

## Accessing Web Dashboard

After deployment, access the web dashboard at:

```
http://<ids-server-ip>:8080/
```

Default: http://192.168.1.26:8080/

Features:
- Live alert feed
- Alert filtering
- Statistics dashboard
- Demo instructions

## Monitoring & Management

### View Live Alerts

```bash
# Fast log (one line per alert)
tail -f /var/log/suricata/fast.log

# EVE JSON log (structured)
tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'

# Web dashboard
firefox http://192.168.1.26:8080/
```

### Service Management

```bash
# Status check
systemctl status suricata

# Restart service
systemctl restart suricata

# Reload rules (no downtime)
suricatasc -c reload-rules

# View statistics
suricatasc -c dump-counters
```

### Rule Management

```bash
# Update rules
suricata-update

# Force update
suricata-update --force

# List rule sources
suricata-update list-sources

# Test configuration
suricata -T -c /etc/suricata/suricata.yaml
```

## Custom Rules

Custom rules are located in `/etc/suricata/rules/custom.rules`

Example rule format:

```
alert tcp any any -> $HOME_NET any (msg:"Test Alert"; sid:1000001; rev:1;)
```

To add new rules:

1. Edit `roles/suricata/files/custom.rules`
2. Redeploy role hoặc manually copy file
3. Reload rules: `suricatasc -c reload-rules`

## Troubleshooting

### Service Won't Start

```bash
# Check logs
journalctl -u suricata -n 50

# Test config
suricata -T -c /etc/suricata/suricata.yaml

# Check interface
ip link show ens192
```

### No Alerts Generated

```bash
# Check rules loaded
suricatasc -c ruleset-stats

# Check promiscuous mode
ip link show ens192 | grep PROMISC

# Generate test traffic
ping -c 10 192.168.1.100
```

### Web UI Not Accessible

```bash
# Check httpd service
systemctl status httpd

# Check firewall
firewall-cmd --list-ports

# Check SELinux booleans
getsebool httpd_can_network_connect_db

# Check log permissions
ls -la /var/log/suricata/eve.json
```

### Promiscuous Mode Disabled After Reboot

```bash
# Check systemd service
systemctl status suricata-promisc

# Enable if needed
systemctl enable suricata-promisc
systemctl start suricata-promisc
```

## Performance Tuning

For high-traffic environments, adjust these variables:

```yaml
# Increase threads
suricata_af_packet_threads: 4
suricata_detect_threads: 4

# Increase memory
suricata_stream_memcap: "512mb"
suricata_flow_memcap: "512mb"
```

## Security Considerations

- Suricata runs as passive IDS (không can thiệp traffic)
- Promiscuous mode chỉ capture, không modify packets
- Web UI chỉ đọc logs (read-only)
- SELinux enabled và configured properly
- Firewall rules cho phép access Web UI

## Integration with Other Systems

### Wazuh Integration

```yaml
# In Wazuh ossec.conf
<localfile>
  <log_format>json</log_format>
  <location>/var/log/suricata/eve.json</location>
</localfile>
```

### ELK Stack Integration

```yaml
# Logstash input
input {
  file {
    path => "/var/log/suricata/eve.json"
    codec => "json"
    type => "suricata"
  }
}
```

### Splunk Integration

```ini
[monitor:///var/log/suricata/eve.json]
sourcetype = suricata:json
```

## License

MIT

## Author Information

Created for HA Infrastructure Security Monitoring Project

- **Role:** Suricata IDS deployment
- **Platform:** AlmaLinux / RHEL 8+
- **Version:** 1.0.0
- **Last Updated:** 2025-12-26

## Support

For issues or questions:
- Check `SURICATA_IDS_GUIDE.md` for detailed documentation
- Review playbook output for error messages
- Check logs: `/var/log/suricata/suricata.log`

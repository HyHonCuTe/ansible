# Suricata IPS Mode Deployment

## Overview
This guide enables Suricata IPS (Intrusion Prevention System) mode for **inline traffic blocking**.

## IDS vs IPS

| Feature | IDS (Current) | IPS (New) |
|---------|---------------|-----------|
| Mode | Passive monitoring | Inline blocking |
| Traffic | Mirror/Tap | All traffic flows through |
| Action | Alert only | Alert + Drop/Reject |
| Performance | Minimal impact | Higher CPU usage |
| Risk | No false positive impact | False positives can block legitimate traffic |

## Architecture

### IDS Mode (Passive)
```
Network Traffic → [Switch Mirror Port] → Suricata → Alerts
                                    ↓
                            Main Traffic continues
```

### IPS Mode (Inline with NFQueue)
```
Network Traffic → iptables PREROUTING → NFQueue 0 → Suricata
                                                        ↓
                                              Analyze & Decide
                                                        ↓
                                         DROP ← Malicious | Legitimate → ACCEPT
                                                        ↓
                                              iptables POSTROUTING → Network
```

## Deployment

### 1. Enable IPS Mode

Edit `roles/suricata/defaults/main.yml`:
```yaml
suricata_ips_enabled: yes
suricata_ips_drop_mode: yes
```

### 2. Deploy with Playbook

```bash
# Deploy IPS mode
ansible-playbook -i inventory/hosts.yml playbooks/deploy_suricata_ips.yml

# Or use tags for existing deployment
ansible-playbook -i inventory/hosts.yml playbooks/deploy_wazuh_agent.yml --tags ips
```

### 3. Verify Deployment

```bash
# Check NFQueue module
ansible IDS-Server -i inventory/hosts.yml -m shell -a "lsmod | grep nfnetlink_queue" -b

# Check iptables rules
ansible IDS-Server -i inventory/hosts.yml -m shell -a "iptables -L -t raw -n -v" -b

# Check Suricata process
ansible IDS-Server -i inventory/hosts.yml -m shell -a "ps aux | grep 'suricata.*-q'" -b

# Check drop rules
ansible IDS-Server -i inventory/hosts.yml -m shell -a "grep '^drop' /etc/suricata/rules/custom.rules" -b
```

## Configuration Details

### Variables (`roles/suricata/defaults/main.yml`)

```yaml
# IPS Configuration
suricata_ips_enabled: no                    # Set to 'yes' to enable IPS
suricata_ips_use_nfqueue: yes               # Use NFQueue (recommended)
suricata_ips_interface: "ens192"            # Interface for inline mode
suricata_ips_drop_mode: yes                 # Convert alert → drop rules
suricata_ips_queue_numbers:
  - 0  # Incoming traffic
  - 1  # Outgoing traffic
```

### IPtables NFQueue Rules

Automatically created by `ips_iptables.sh.j2`:

```bash
# Redirect incoming traffic to NFQueue 0
iptables -t raw -A PREROUTING -i ens192 -j NFQUEUE --queue-num 0 --queue-bypass

# Redirect outgoing traffic to NFQueue 1
iptables -t raw -A OUTPUT -o ens192 -j NFQUEUE --queue-num 1 --queue-bypass
```

**Note:** `--queue-bypass` ensures traffic continues if Suricata crashes (fail-open for availability)

### Suricata NFQueue Config

Added to `/etc/suricata/suricata.yaml`:

```yaml
nfq:
  mode: accept          # Default action: accept
  repeat-mark: 1
  repeat-mask: 1
  route-queue: 2
  batchcount: 20
```

### Drop Rules Conversion

When `suricata_ips_drop_mode: yes`, all `alert` rules become `drop` rules:

**Before (IDS):**
```
alert tcp any any -> any 22 (msg:"SSH Brute Force"; threshold:type threshold, track by_src, count 5, seconds 60; sid:1000001;)
```

**After (IPS):**
```
drop tcp any any -> any 22 (msg:"SSH Brute Force"; threshold:type threshold, track by_src, count 5, seconds 60; sid:1000001;)
```

## Testing IPS Blocking

### 1. Test SQL Injection (Should be blocked)

```bash
# From another machine
curl "http://192.168.1.100/?id=1' OR '1'='1"

# Expected: Connection timeout or reset
# Check logs
sudo tail -f /var/log/suricata/eve.json | grep drop
```

### 2. Test User-Agent Detection

```bash
curl -A "sqlmap" http://192.168.1.100

# Should be blocked if drop rule exists
```

### 3. Test Port Scan

```bash
nmap -sS 192.168.1.27

# May be blocked after threshold
```

### 4. View Blocked Traffic

```bash
# Real-time monitoring
sudo tail -f /var/log/suricata/eve.json | grep '"action":"blocked"'

# Count dropped packets
sudo grep -c '"action":"blocked"' /var/log/suricata/eve.json
```

## Performance Tuning

### For High-Traffic Environments

Edit `/etc/suricata/suricata.yaml`:

```yaml
nfq:
  mode: accept
  batchcount: 50          # Process more packets per batch
  fail-open: yes          # Bypass if Suricata fails

# Increase threads
threading:
  set-cpu-affinity: yes
  cpu-affinity:
    - management-cpu-set:
        cpu: [ 0 ]
    - receive-cpu-set:
        cpu: [ 1,2 ]
    - worker-cpu-set:
        cpu: [ 3,4,5,6 ]
```

### Monitor Performance

```bash
# CPU usage
top -p $(pgrep suricata)

# Packet drop statistics
sudo suricatasc -c "dump-counters" | grep drop

# NFQueue statistics
cat /proc/net/netfilter/nfnetlink_queue
```

## Troubleshooting

### Issue: Traffic stops flowing

**Cause:** Suricata crashed but iptables still redirecting to NFQueue

**Solution:**
```bash
# Emergency: Remove NFQueue rules
sudo iptables -t raw -F

# Or restart IPS service
sudo systemctl restart suricata-ips-iptables
sudo systemctl restart suricata
```

### Issue: False positives blocking legitimate traffic

**Solution:** Convert specific drop rules back to alert:

```bash
# Edit custom rules
sudo vi /etc/suricata/rules/custom.rules

# Change:
drop http any any -> any any (msg:"False Positive"; ...)
# To:
alert http any any -> any any (msg:"False Positive"; ...)

# Reload rules
sudo systemctl restart suricata
```

### Issue: NFQueue module not loaded

```bash
# Load module
sudo modprobe nfnetlink_queue

# Make persistent
echo "nfnetlink_queue" | sudo tee -a /etc/modules-load.d/suricata.conf
```

## Switching Between IDS and IPS

### Disable IPS (Back to IDS)

```yaml
# In defaults/main.yml or playbook vars
suricata_ips_enabled: no
```

```bash
# Re-run playbook
ansible-playbook -i inventory/hosts.yml playbooks/deploy_suricata_ips.yml

# Or manually
sudo systemctl stop suricata-ips-iptables
sudo systemctl disable suricata-ips-iptables
sudo iptables -t raw -F
sudo systemctl restart suricata
```

### Enable IPS

```yaml
suricata_ips_enabled: yes
```

```bash
ansible-playbook -i inventory/hosts.yml playbooks/deploy_suricata_ips.yml
```

## Security Considerations

1. **Fail-Open vs Fail-Closed**
   - Current config: `--queue-bypass` (fail-open for availability)
   - For maximum security: Remove `--queue-bypass` (fail-closed)

2. **Rule Testing**
   - Test drop rules in IDS mode first (alert only)
   - Gradually convert to drop after validation

3. **Backup Network Path**
   - Have out-of-band management access
   - IPS can block SSH if misconfigured

4. **Logging**
   - Monitor drop actions in eve.json
   - Set up alerts for excessive blocking

## Files Modified

- `roles/suricata/tasks/configure_ips.yml` - IPS setup tasks
- `roles/suricata/templates/ips_iptables.sh.j2` - NFQueue iptables script
- `roles/suricata/defaults/main.yml` - IPS variables
- `roles/suricata/handlers/main.yml` - Added reload systemd handler
- `playbooks/deploy_suricata_ips.yml` - IPS deployment playbook

## References

- [Suricata IPS Documentation](https://suricata.readthedocs.io/en/latest/setting-up-ipsinline-for-linux.html)
- [NFQueue Documentation](https://home.regit.org/netfilter-en/using-nfqueue-and-libnetfilter_queue/)
- [Drop vs Alert Rules](https://suricata.readthedocs.io/en/latest/rules/intro.html#action)

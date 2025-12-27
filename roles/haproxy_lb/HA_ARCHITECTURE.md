# High Availability Load Balancer - System Architecture

## Mô hình Tổng Quan

```
┌──────────────────────────────────────────────────────────────────┐
│                         INTERNET / CLIENTS                        │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             │ Access via VIP
                             │
                    ┌────────▼────────┐
                    │  Virtual IP     │
                    │  192.168.1.100  │
                    │   (VRRP/VIP)    │
                    └────────┬────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │           Keepalived - VRRP             │
        │         (Virtual Router ID: 51)         │
        └────────────────────┬────────────────────┘
                             │
            ┌────────────────┴───────────────┐
            │                                │
    ┌───────▼────────┐              ┌───────▼────────┐
    │      HA1       │              │      HA2       │
    │  192.168.1.8   │◄────VRRP────►│  192.168.1.25  │
    │   (MASTER)     │   Multicast  │   (BACKUP)     │
    │  Priority: 100 │              │  Priority: 90  │
    ├────────────────┤              ├────────────────┤
    │  Keepalived    │              │  Keepalived    │
    │  + HAProxy     │              │  + HAProxy     │
    └───────┬────────┘              └────────┬───────┘
            │                                │
            │      HAProxy Load Balancing    │
            │      Algorithm: Round Robin    │
            │      Port: 80                  │
            │      Stats: 8080               │
            │                                │
            └────────────┬───────────────────┘
                         │
            ┌────────────┴───────────────┐
            │                            │
    ┌───────▼────────┐          ┌───────▼────────┐
    │     WEB-1      │          │     WEB-2      │
    │  192.168.1.27  │          │  192.168.1.30  │
    │   (Backend)    │          │   (Backend)    │
    ├────────────────┤          ├────────────────┤
    │  Apache HTTPD  │          │  Apache HTTPD  │
    │  Port: 80      │          │  Port: 80      │
    │  Color: Blue   │          │  Color: Red    │
    └────────────────┘          └────────────────┘
```

## Luồng Hoạt Động

### 1. Normal Operation (Hoạt động bình thường)

```
Client Request
     │
     ├─► VIP: 192.168.1.100 (assigned to HA1 - MASTER)
     │
     ├─► HAProxy on HA1
     │       │
     │       ├─► Round Robin Distribution
     │       │
     │       ├─► Request #1 → WEB-1 (192.168.1.27)
     │       ├─► Request #2 → WEB-2 (192.168.1.30)
     │       ├─► Request #3 → WEB-1 (192.168.1.27)
     │       └─► Request #4 → WEB-2 (192.168.1.30)
     │
     └─► Response to Client
```

### 2. Failover Scenario (Khi MASTER fail)

```
Before Failover:
┌────────────┐         ┌────────────┐
│    HA1     │ MASTER  │    HA2     │ BACKUP
│ [Has VIP]  │◄───────►│ [No VIP]   │
└────────────┘         └────────────┘

Event: HAProxy stops on HA1
     │
     ├─► Keepalived health check fails
     │
     ├─► HA1 priority drops (100 → 90)
     │
     ├─► VRRP failover triggered
     │
     └─► VIP migrates to HA2 (within 3 seconds)

After Failover:
┌────────────┐         ┌────────────┐
│    HA1     │ FAULT   │    HA2     │ MASTER
│ [No VIP]   │◄───────►│ [Has VIP]  │
└────────────┘         └────────────┘

Client continues accessing VIP (now on HA2)
     │
     └─► Zero downtime!
```

## Chi Tiết Thành Phần

### Keepalived Configuration

| Parameter              | HA1 (MASTER)    | HA2 (BACKUP)    |
|------------------------|-----------------|-----------------|
| State                  | MASTER          | BACKUP          |
| Priority               | 100             | 90              |
| Virtual Router ID      | 51              | 51              |
| Advertisement Interval | 1 second        | 1 second        |
| Authentication         | PASS            | PASS            |
| Auth Password          | HA_SECRET_2025  | HA_SECRET_2025  |
| Virtual IP             | 192.168.1.100   | 192.168.1.100   |
| Health Check           | check_haproxy.sh| check_haproxy.sh|
| Check Interval         | 2 seconds       | 2 seconds       |
| Check Weight           | -10             | -10             |

### HAProxy Configuration

| Parameter              | Value                    |
|------------------------|--------------------------|
| Frontend Port          | 80                       |
| Stats Port             | 8080                     |
| Balance Algorithm      | roundrobin               |
| Health Check URI       | /health.html             |
| Check Interval         | 3000ms                   |
| Check Rise             | 2                        |
| Check Fall             | 3                        |
| Max Connections        | 4000                     |
| Timeout Connect        | 5s                       |
| Timeout Client         | 50s                      |
| Timeout Server         | 50s                      |

### Backend Web Servers

| Server | IP            | Port | Server Name | Color  | Content ID |
|--------|---------------|------|-------------|--------|------------|
| Web1   | 192.168.1.27  | 80   | WEB-1       | Blue   | Unique     |
| Web2   | 192.168.1.30  | 80   | WEB-2       | Red    | Unique     |

## Network Flow

### VRRP Protocol Flow

```
HA1 (MASTER)                           HA2 (BACKUP)
     │                                      │
     ├──VRRP Advertisement (every 1s)──────►│
     │  [I am MASTER, Priority 100]         │
     │                                      │
     │                                      │ Receives
     │                                      │ Stays BACKUP
     │                                      │
     │                                      │
     │  [HAProxy Failed!]                   │
     │  Priority: 100 → 90                  │
     │                                      │
     ├──VRRP Advertisement────────────────► │
     │  [I am BACKUP, Priority 90]          │
     │                                      │
     │                                      │ Detects lower priority
     │                                      │ Becomes MASTER
     │                                      │ Assigns VIP
     │                                      │
     │ ◄────VRRP Advertisement──────────────┤
     │         [I am MASTER, Priority 90]   │
```

### Health Check Flow

```
Keepalived
    │
    ├─► Execute: /usr/local/bin/check_haproxy.sh
    │
    ├─► Check 1: Is HAProxy process running?
    │       pidof haproxy
    │       ├─► YES → Continue
    │       └─► NO  → Exit 1 (Fail)
    │
    ├─► Check 2: Is HAProxy listening on port 80?
    │       netstat -tuln | grep ":80 "
    │       ├─► YES → Continue
    │       └─► NO  → Exit 1 (Fail)
    │
    ├─► Check 3: Is stats socket responsive?
    │       echo "show info" | socat stdio /var/lib/haproxy/stats
    │       ├─► YES → Exit 0 (Success)
    │       └─► NO  → Exit 1 (Fail)
    │
    └─► If ANY check fails:
            Priority -= 10 (Weight)
            Trigger failover if priority < backup
```

## Port và Protocol

| Service    | Protocol | Port | Purpose                |
|------------|----------|------|------------------------|
| HAProxy    | TCP      | 80   | HTTP Load Balancer     |
| HAProxy    | TCP      | 8080 | Statistics Page        |
| Keepalived | IP/112   | N/A  | VRRP Protocol          |
| Apache     | TCP      | 80   | Web Server             |

## Firewall Rules

### HA Servers (HA1, HA2)
```bash
# HTTP Traffic
firewall-cmd --permanent --add-port=80/tcp

# HAProxy Stats
firewall-cmd --permanent --add-port=8080/tcp

# VRRP Protocol
firewall-cmd --permanent --add-rich-rule='rule protocol value="vrrp" accept'
```

### Web Servers (Web1, Web2)
```bash
# HTTP Traffic
firewall-cmd --permanent --add-port=80/tcp

# HTTPS (optional)
firewall-cmd --permanent --add-port=443/tcp
```

## Kernel Parameters

Các HA servers cần enable:

```bash
# IP Forwarding
net.ipv4.ip_forward = 1

# Non-local bind (allow binding to VIP before it's assigned)
net.ipv4.ip_nonlocal_bind = 1
```

## Monitoring Points

### 1. Service Status
```bash
systemctl status haproxy keepalived httpd
```

### 2. VIP Assignment
```bash
ip addr show | grep 192.168.1.100
```

### 3. HAProxy Backend Status
```bash
echo "show stat" | socat stdio /var/lib/haproxy/stats
```

### 4. VRRP Traffic
```bash
tcpdump -i ens192 vrrp -n
```

### 5. Logs
```bash
# HAProxy
tail -f /var/log/haproxy.log

# Keepalived
journalctl -u keepalived -f

# Apache
tail -f /var/log/httpd/access_log
```

## Performance Metrics

| Metric                 | Expected Value      |
|------------------------|---------------------|
| Failover Time          | < 3 seconds         |
| Health Check Frequency | Every 2 seconds     |
| VRRP Advertisement     | Every 1 second      |
| Load Distribution      | 50/50 (±10%)        |
| Connection Timeout     | 5 seconds           |
| Max Concurrent Conn    | 4000                |

---

**Note**: Diagram này mô tả kiến trúc của hệ thống High Availability Load Balancer. Tất cả thành phần được tự động hóa triển khai bằng Ansible.

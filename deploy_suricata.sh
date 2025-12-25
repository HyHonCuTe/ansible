#!/bin/bash
# Suricata IDS Deployment Script
# Automated deployment for security monitoring infrastructure

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║           SURICATA IDS DEPLOYMENT AUTOMATION                  ║
║         Security Monitoring for HA Infrastructure             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Function to print section headers
print_section() {
    echo -e "\n${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${YELLOW}▶ $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✔ $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✖ $1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running from ansible directory
if [ ! -f "ansible.cfg" ]; then
    print_error "Please run this script from the ansible directory"
    exit 1
fi

print_section "Step 1: Pre-deployment Checks"

print_info "Checking connectivity to IDS server..."
if ansible security_servers -m ping > /dev/null 2>&1; then
    print_success "IDS server is reachable"
else
    print_error "Cannot reach IDS server (192.168.1.26)"
    print_info "Please check:"
    echo "  - Network connectivity"
    echo "  - SSH access"
    echo "  - Inventory configuration"
    exit 1
fi

print_info "Checking interface ens192..."
if ansible security_servers -m shell -a "ip link show ens192" > /dev/null 2>&1; then
    print_success "Interface ens192 exists"
else
    print_error "Interface ens192 not found"
    exit 1
fi

print_info "Checking Ansible collections..."
if ansible-galaxy collection list | grep -q "ansible.posix"; then
    print_success "Required collections installed"
else
    print_info "Installing ansible.posix collection..."
    ansible-galaxy collection install ansible.posix
fi

print_section "Step 2: Deploy Suricata IDS"

print_info "Starting Suricata deployment..."
print_info "This will:"
echo "  • Install Suricata IDS"
echo "  • Configure network monitoring (ens192)"
echo "  • Update detection rules"
echo "  • Deploy Web UI dashboard"
echo "  • Configure firewall"
echo ""

read -p "Continue with deployment? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    print_info "Deployment cancelled"
    exit 0
fi

if ansible-playbook playbooks/deploy_suricata_ids.yml; then
    print_success "Suricata IDS deployed successfully!"
else
    print_error "Deployment failed!"
    exit 1
fi

print_section "Step 3: Verify Installation"

print_info "Verifying Suricata installation..."
sleep 3

if ansible-playbook playbooks/verify_suricata_ids.yml; then
    print_success "Verification completed successfully!"
else
    print_error "Verification failed. Please check logs."
    exit 1
fi

print_section "Step 4: Optional - Run Demo Attacks"

echo -e "${YELLOW}Would you like to run attack simulation demo?${NC}"
echo "This will generate test alerts to verify IDS detection capabilities."
echo ""
read -p "Run demo attacks? [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Running attack simulation..."
    
    if ansible-playbook playbooks/demo_suricata_attacks.yml; then
        print_success "Demo attacks completed!"
    else
        print_error "Demo failed, but IDS is still functional"
    fi
fi

print_section "Deployment Summary"

# Get IDS server info
IDS_IP=$(ansible security_servers --list-hosts 2>/dev/null | grep -v "hosts" | tr -d ' ')

echo -e "${GREEN}${BOLD}"
cat << EOF
╔═══════════════════════════════════════════════════════════════╗
║              SURICATA IDS DEPLOYMENT COMPLETE!                ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ✅ Service Status: RUNNING                                   ║
║  ✅ Interface: ens192 (Promiscuous Mode)                      ║
║  ✅ Rules: Loaded (Emerging Threats + Custom)                 ║
║  ✅ Web Dashboard: DEPLOYED                                   ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  🌐 ACCESS POINTS                                             ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Web Dashboard:                                               ║
║    http://192.168.1.26:8080/                                  ║
║                                                               ║
║  SSH Access:                                                  ║
║    ssh ansible@192.168.1.26                                   ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  📊 MONITORING SCOPE                                          ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  • HAProxy Load Balancers: 192.168.1.8, 192.168.1.25         ║
║  • Web Backend Servers: 192.168.1.27, 192.168.1.30           ║
║  • VIP: 192.168.1.100                                         ║
║  • Network: 192.168.1.0/24                                    ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  📝 LOG FILES                                                 ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  EVE JSON: /var/log/suricata/eve.json                         ║
║  Fast Log: /var/log/suricata/fast.log                         ║
║  Main Log: /var/log/suricata/suricata.log                     ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  🎯 NEXT STEPS                                                ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  1. Open web dashboard in browser                            ║
║  2. Generate traffic to HA infrastructure                     ║
║  3. Monitor alerts on dashboard                               ║
║  4. Run demo attacks for testing:                             ║
║     ansible-playbook playbooks/demo_suricata_attacks.yml      ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  🔍 USEFUL COMMANDS                                           ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  View live alerts:                                            ║
║    tail -f /var/log/suricata/fast.log                         ║
║                                                               ║
║  Check service status:                                        ║
║    systemctl status suricata                                  ║
║                                                               ║
║  Reload rules:                                                ║
║    suricatasc -c reload-rules                                 ║
║                                                               ║
║  View statistics:                                             ║
║    suricatasc -c dump-counters                                ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "For detailed documentation, see: SURICATA_IDS_GUIDE.md"
print_success "Deployment completed successfully!"

exit 0

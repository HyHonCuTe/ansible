#!/bin/bash
#
# High Availability Load Balancer - Quick Deployment Script
# This script automates the deployment of HAProxy + Keepalived + Web Servers
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INVENTORY="inventory/hosts.yml"
DEPLOY_PLAYBOOK="playbooks/deploy_ha_loadbalancer.yml"
VERIFY_PLAYBOOK="playbooks/verify_ha_loadbalancer.yml"
VIP="192.168.1.100"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  High Availability Load Balancer Deployment           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check connectivity
echo -e "${YELLOW}[1/4] Checking connectivity to all servers...${NC}"
if ansible ha_servers,web_servers -i $INVENTORY -m ping -o > /dev/null 2>&1; then
    echo -e "${GREEN}✅ All servers are reachable${NC}"
else
    echo -e "${RED}❌ Cannot reach one or more servers. Please check your inventory.${NC}"
    exit 1
fi
echo ""

# Step 2: Check playbook syntax
echo -e "${YELLOW}[2/4] Validating playbook syntax...${NC}"
if ansible-playbook --syntax-check $DEPLOY_PLAYBOOK > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Playbook syntax is valid${NC}"
else
    echo -e "${RED}❌ Playbook syntax error${NC}"
    exit 1
fi
echo ""

# Step 3: Deploy
echo -e "${YELLOW}[3/4] Deploying HA Load Balancer infrastructure...${NC}"
echo -e "${BLUE}This will install and configure:${NC}"
echo -e "  - Apache web servers on Web1 (192.168.1.27) and Web2 (192.168.1.30)"
echo -e "  - HAProxy load balancers on HA1 (192.168.1.8) and HA2 (192.168.1.25)"
echo -e "  - Keepalived with VIP: ${VIP}"
echo ""

read -p "Continue with deployment? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

ansible-playbook -i $INVENTORY $DEPLOY_PLAYBOOK

echo ""
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo ""

# Step 4: Verify
echo -e "${YELLOW}[4/4] Running verification tests...${NC}"
sleep 3

ansible-playbook -i $INVENTORY $VERIFY_PLAYBOOK

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Deployment and Verification Complete!                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Access your HA Load Balancer at:${NC}"
echo -e "  🌐 http://${VIP}"
echo ""
echo -e "${BLUE}HAProxy Statistics:${NC}"
echo -e "  📊 http://192.168.1.8:8080/stats (admin/admin123)"
echo -e "  📊 http://192.168.1.25:8080/stats (admin/admin123)"
echo ""
echo -e "${BLUE}Quick Tests:${NC}"
echo -e "  # Test load balancing"
echo -e "  for i in {1..10}; do curl -s http://${VIP} | grep 'server-badge' | grep -o 'WEB-[12]'; done"
echo ""
echo -e "  # Monitor VIP"
echo -e "  watch -n 1 'curl -s http://${VIP}'"
echo ""
echo -e "  # Test failover (stop HAProxy on MASTER)"
echo -e "  ssh ansible@192.168.1.8 'sudo systemctl stop haproxy'"
echo ""

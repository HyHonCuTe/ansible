#!/bin/bash
#
# MariaDB Replication - Quick Deployment Script
# This script automates the deployment of MariaDB replication
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
INVENTORY="inventory/hosts.yml"
DEPLOY_PLAYBOOK="playbooks/deploy_mariadb_replication.yml"
VERIFY_PLAYBOOK="playbooks/verify_mariadb_replication.yml"
DEMO_PLAYBOOK="playbooks/demo_mariadb_web.yml"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  MariaDB Replication Deployment                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check connectivity
echo -e "${YELLOW}[1/5] Checking connectivity to web servers...${NC}"
if ansible web_servers -i $INVENTORY -m ping -o > /dev/null 2>&1; then
    echo -e "${GREEN}✅ All web servers are reachable${NC}"
else
    echo -e "${RED}❌ Cannot reach web servers. Please check your inventory.${NC}"
    exit 1
fi
echo ""

# Step 2: Check required collection
echo -e "${YELLOW}[2/5] Checking required Ansible collections...${NC}"
if ansible-galaxy collection list | grep -q "community.mysql"; then
    echo -e "${GREEN}✅ community.mysql collection is installed${NC}"
else
    echo -e "${YELLOW}⚠️  Installing community.mysql collection...${NC}"
    ansible-galaxy collection install community.mysql
fi
echo ""

# Step 3: Deploy MariaDB
echo -e "${YELLOW}[3/5] Deploying MariaDB with replication...${NC}"
echo -e "${BLUE}This will install and configure:${NC}"
echo -e "  - MariaDB PRIMARY on Web1 (192.168.1.27)"
echo -e "  - MariaDB REPLICA on Web2 (192.168.1.30)"
echo -e "  - Demo database 'webapp_db'"
echo ""

read -p "Continue with deployment? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

ansible-playbook -i $INVENTORY $DEPLOY_PLAYBOOK

echo ""
echo -e "${GREEN}✅ MariaDB replication deployed!${NC}"
echo ""

# Step 4: Verify replication
echo -e "${YELLOW}[4/5] Verifying replication status...${NC}"
sleep 3

ansible-playbook -i $INVENTORY $VERIFY_PLAYBOOK

echo ""
echo -e "${GREEN}✅ Replication verified!${NC}"
echo ""

# Step 5: Deploy web demo
echo -e "${YELLOW}[5/5] Deploying web demo application...${NC}"
read -p "Deploy web demo? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}Skipping web demo deployment.${NC}"
else
    ansible-playbook -i $INVENTORY $DEMO_PLAYBOOK
    echo ""
    echo -e "${GREEN}✅ Web demo deployed!${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  MariaDB Replication Deployment Complete!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}🌐 Access web demo at:${NC}"
echo -e "  http://192.168.1.100/db-demo/"
echo ""
echo -e "${BLUE}📊 Database credentials:${NC}"
echo -e "  Root: root / RootP@ssw0rd2025"
echo -e "  App:  webapp_user / WebApp123!"
echo ""
echo -e "${BLUE}🧪 Test replication:${NC}"
echo -e "  1. Open http://192.168.1.100/db-demo/ in browser"
echo -e "  2. Refresh until you see WEB-1 (PRIMARY)"
echo -e "  3. Add a user"
echo -e "  4. Refresh until you see WEB-2 (REPLICA)"
echo -e "  5. Verify user appears on REPLICA!"
echo ""
echo -e "${BLUE}🔍 Monitoring commands:${NC}"
echo -e "  # Check PRIMARY status"
echo -e "  ssh ansible@192.168.1.27 'mysql -u root -pRootP@ssw0rd2025 -e \"SHOW MASTER STATUS\"'"
echo ""
echo -e "  # Check REPLICA status"
echo -e "  ssh ansible@192.168.1.30 'mysql -u root -pRootP@ssw0rd2025 -e \"SHOW SLAVE STATUS\G\"'"
echo ""

#!/bin/bash
# Grafana Password Reset Helper
# Author: HyHonCuTe

GRAFANA_CLI="/usr/sbin/grafana-cli"
NEW_PASSWORD="${1:-Grafana@2025}"

echo "======================================"
echo "  Grafana Password Reset Tool"
echo "======================================"
echo ""

# Check if grafana-cli exists
if [ ! -f "$GRAFANA_CLI" ]; then
    echo "❌ Error: grafana-cli not found at $GRAFANA_CLI"
    exit 1
fi

# Stop Grafana service
echo "🛑 Stopping Grafana service..."
sudo systemctl stop grafana-server

# Reset admin password
echo "🔐 Resetting admin password..."
sudo $GRAFANA_CLI admin reset-admin-password "$NEW_PASSWORD"

# Start Grafana service
echo "▶️  Starting Grafana service..."
sudo systemctl start grafana-server

# Wait for Grafana to be ready
echo "⏳ Waiting for Grafana to start..."
sleep 5

# Test connection
echo "🧪 Testing new credentials..."
curl -s -u admin:$NEW_PASSWORD http://localhost:3000/api/org > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Password reset successful!"
    echo ""
    echo "📋 Access Information:"
    echo "   URL: http://localhost:3000"
    echo "   Username: admin"
    echo "   Password: $NEW_PASSWORD"
    echo ""
else
    echo ""
    echo "⚠️  Password was reset but connection test failed"
    echo "   Please verify manually at http://localhost:3000"
    echo ""
fi

echo "======================================"

#!/bin/bash
set -euo pipefail

# God Mode Lab Monitoring Script
# Lightweight resource and health monitoring

echo "📊 God Mode Lab System Monitor"
echo "=============================="
echo ""

# Check if container is running
if ! docker ps | grep -q god_mode_lab; then
    echo "❌ Container 'god_mode_lab' is NOT running!"
    echo ""
    echo "Start it with:"
    echo "  cd /home/harjot/god_mode_lab"
    echo "  docker compose up -d"
    exit 1
fi

echo "✅ Container Status: Running"
echo ""

# Container resource usage
echo "📈 Resource Usage:"
echo "------------------"
docker stats god_mode_lab --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
echo ""

# Disk usage in container
echo "💾 Container Disk Usage:"
echo "------------------------"
docker exec god_mode_lab df -h / | tail -n 1
echo ""

# Docker system usage (inside container)
echo "🐳 Docker-in-Docker Status:"
echo "---------------------------"
if docker exec god_mode_lab docker system df 2>/dev/null; then
    echo ""
else
    echo "⚠️  Docker daemon not running inside container"
    echo ""
fi

# Health check status
echo "🏥 Health Check Status:"
echo "-----------------------"
HEALTH=$(docker inspect god_mode_lab --format='{{.State.Health.Status}}' 2>/dev/null || echo "no healthcheck")
if [ "$HEALTH" = "healthy" ]; then
    echo "✅ Health: $HEALTH"
elif [ "$HEALTH" = "no healthcheck" ]; then
    echo "⚠️  No health check configured"
else
    echo "❌ Health: $HEALTH"
fi
echo ""

# Uptime
echo "⏱️  Uptime:"
echo "----------"
docker inspect god_mode_lab --format='Started: {{.State.StartedAt}}' | sed 's/T/ /' | cut -d'.' -f1
echo ""

echo "✅ Monitoring Complete"

#!/bin/bash
set -euo pipefail

# God Mode Lab Update Script
# Safe update workflow with rebuild and verification

echo "🔄 God Mode Lab Update Starting..."
echo "==================================="
echo ""

cd /home/harjot/god_mode_lab

# Check if container is running
RUNNING=false
if docker ps | grep -q god_mode_lab; then
    RUNNING=true
fi

# Pull latest changes (if using git)
if [ -d .git ]; then
    echo "📥 Pulling latest changes from git..."
    git pull
    echo ""
fi

# Stop container
if [ "$RUNNING" = true ]; then
    echo "🛑 Stopping container..."
    docker compose down
    echo ""
fi

# Pull base images
echo "🐳 Pulling updated base images..."
docker compose pull
echo ""

# Rebuild with no cache
echo "🔨 Rebuilding container (this may take a few minutes)..."
docker compose build --no-cache
echo ""

# Start container
echo "🚀 Starting updated container..."
docker compose up -d
echo ""

# Wait for startup
echo "⏳ Waiting for container to be ready (45 seconds)..."
sleep 45
echo ""

# Check health
HEALTH=$(docker inspect god_mode_lab --format='{{.State.Health.Status}}' 2>/dev/null || echo "running")
if [ "$HEALTH" = "healthy" ]; then
    echo "✅ Container is healthy!"
elif [ "$HEALTH" = "running" ]; then
    echo "✅ Container is running (no health check configured)"
else
    echo "⚠️  Container health: $HEALTH"
fi
echo ""

# Prompt for manual verification
echo "=================================="
echo "✅ Update Complete!"
echo ""
echo "Recommended verification steps:"
echo ""
echo "1. Run health diagnostics:"
echo "   docker exec god_mode_lab bash /root/workspace/container_tests/test_basic.sh"
echo ""
echo "2. Test Docker-in-Docker:"
echo "   docker exec god_mode_lab docker run --rm hello-world"
echo ""
echo "3. Test GUI apps:"
echo "   docker exec god_mode_lab code --version"
echo ""
echo "4. Check the monitoring dashboard:"
echo "   ./scripts/monitor.sh"
echo ""

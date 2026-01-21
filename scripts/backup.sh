#!/bin/bash
set -euo pipefail

# God Mode Lab Backup Script
# Creates timestamped backups of workspace and container state

BACKUP_DIR="$HOME/god_mode_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔒 God Mode Lab Backup Starting..."
echo "=================================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup workspace
echo "📁 Backing up workspace directory..."
if tar czf "$BACKUP_DIR/workspace-$TIMESTAMP.tar.gz" -C /home/harjot/god_mode_lab workspace; then
    WORKSPACE_SIZE=$(du -h "$BACKUP_DIR/workspace-$TIMESTAMP.tar.gz" | cut -f1)
    echo "   ✅ Workspace backup complete: $WORKSPACE_SIZE"
else
    echo "   ❌ Workspace backup failed!"
    exit 1
fi

# Commit container state (optional - only if container is running)
if docker ps | grep -q god_mode_lab; then
    echo "🐳 Committing container state..."
    if docker commit god_mode_lab "god_mode_lab:backup-$TIMESTAMP" > /dev/null; then
        echo "   ✅ Container state saved as: god_mode_lab:backup-$TIMESTAMP"
    else
        echo "   ⚠️  Container commit failed (non-critical)"
    fi
else
    echo "⚠️  Container not running, skipping container state backup"
fi

echo ""
echo "✅ Backup Complete!"
echo "Location: $BACKUP_DIR/workspace-$TIMESTAMP.tar.gz"
echo ""
echo "To restore workspace:"
echo "  cd /home/harjot/god_mode_lab"
echo "  rm -rf workspace"
echo "  tar xzf $BACKUP_DIR/workspace-$TIMESTAMP.tar.gz"

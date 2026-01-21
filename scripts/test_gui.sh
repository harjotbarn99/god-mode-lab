#!/bin/bash
# GUI Test Script for God Mode Lab
set -e

echo "🖥️  Testing GUI Applications in God Mode Lab"
echo "=============================================="
echo ""

# Note about xhost
echo "💡 Note: Make sure you've run 'xhost +local:root' on the host"
echo ""

echo "[1/3] Checking container status..."
if docker ps | grep -q god_mode_lab; then
    echo "✅ Container running"
else
    echo "❌ Container not running"
    echo "      Run: make start"
    exit 1
fi

echo ""
echo "[2/3] Testing simple GUI (xeyes)..."
echo "      This will open a small window with eyes that follow your cursor"
echo "      Press Ctrl+C in this terminal to close it, or close the window"
echo ""
sleep 2

echo "Launching xeyes..."
if docker exec god_mode_lab xeyes 2>&1 | grep -q "Can't open display"; then
    echo ""
    echo "❌ GUI connection failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Run: xhost +local:root"
    echo "  2. Check DISPLAY: echo \$DISPLAY"
    echo "  3. Ensure X11 is running on your system"
    echo "  4. For Docker Desktop, ensure X11 forwarding is configured"
    echo ""
    exit 1
fi

echo ""
echo "✅ GUI is working!"
echo ""
echo "[3/3] Launching VS Code..."
echo "      (This may take a few seconds)..."
echo ""

docker exec -d god_mode_lab code --no-sandbox --user-data-dir=/root/.vscode-data

echo "✅ VS Code launched"
echo ""
echo "================================================"
echo "✅ GUI Test Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  - Install Antigravity: apt install ./google-antigravity*.deb"
echo "  - Launch Antigravity: antigravity --no-sandbox --user-data-dir=/root/.antigravity-data"
echo "  - Use AI tools: claude or gemini"
echo "================================================"


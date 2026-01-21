#!/bin/bash
set -euo pipefail

# ==========================================
# GOD MODE DIAGNOSTIC PROTOCOL v1.0
# ==========================================

# ANSI Colors for Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo -e "\n${BLUE}=== INITIATING SYSTEM DIAGNOSTIC ===${NC}\n"

# ---------------------------------------------------
# STEP 1: VISUAL INTERFACE (GUI) CHECK
# ---------------------------------------------------
info "Checking Visual Interface Link..."

if [ -z "$DISPLAY" ]; then
    fail "DISPLAY environment variable is NOT set."
    warn "Fix: Ensure 'network_mode: host' is in docker-compose.yml"
else
    pass "DISPLAY variable detected: $DISPLAY"
    
    # Try to detect if X11 socket is accessible
    if [ -d "/tmp/.X11-unix" ]; then
        pass "X11 Socket mounted found."
    else
        fail "X11 Socket missing."
    fi
fi

# ---------------------------------------------------
# STEP 2: DOCKER-IN-DOCKER ENGINE
# ---------------------------------------------------
echo -e "\n${BLUE}=== CHECKING DOCKER ENGINE ===${NC}"

# Check if Docker Daemon is running
if ! pgrep -x "dockerd" > /dev/null; then
    warn "Docker Daemon is NOT running (Zombie Mode active)."
    info "Attempting Auto-Start sequence..."
    dockerd > /var/log/dockerd.log 2>&1 &
    
    # Wait loop (up to 10 seconds)
    for i in {1..10}; do
        if docker version > /dev/null 2>&1; then
            break
        fi
        echo -n "."
        sleep 1
    done
    echo ""
fi

# Final Verification
if docker version > /dev/null 2>&1; then
    pass "Docker Daemon is online."
    
    # The Real Test: Can we spawn a child?
    info "Attempting to spawn 'hello-world' child container..."
    if docker run --rm hello-world | grep -q "Hello from Docker!"; then
        pass "Nested Virtualization Verified (Docker-in-Docker working)."
    else
        fail "Child container failed to run."
    fi
else
    fail "Docker Daemon failed to start. Check 'privileged: true'."
fi

# ---------------------------------------------------
# STEP 3: AI TOOLCHAIN
# ---------------------------------------------------
echo -e "\n${BLUE}=== CHECKING AI TOOLCHAIN ===${NC}"

# Node.js
if command -v node > /dev/null; then
    NODE_V=$(node -v)
    pass "Node.js installed: $NODE_V"
else
    fail "Node.js missing."
fi

# Claude Code
if command -v claude > /dev/null; then
    pass "Claude Code CLI installed."
else
    fail "Claude Code CLI missing."
fi

# Gemini CLI
if command -v gemini > /dev/null; then
    pass "Gemini CLI installed."
else
    fail "Gemini CLI missing."
fi

# ---------------------------------------------------
# STEP 4: IDE AVAILABILITY
# ---------------------------------------------------
echo -e "\n${BLUE}=== CHECKING IDE STATUS ===${NC}"

# VS Code
if command -v code > /dev/null; then
    pass "VS Code installed."
else
    fail "VS Code missing."
fi

# Google Antigravity
# (We check multiple possible binary names or package presence)
if dpkg -l | grep -i "antigravity" > /dev/null; then
    pass "Google Antigravity Package detected."
else
    warn "Google Antigravity NOT detected."
    info "Did you run the manual install? (apt install ./google-antigravity*.deb)"
fi

# ---------------------------------------------------
# FINAL SUMMARY
# ---------------------------------------------------
echo -e "\n${BLUE}=== DIAGNOSTIC COMPLETE ===${NC}"
#!/bin/bash

# ==========================================
# ISOLATION SAFETY PROTOCOL v1.0
# ==========================================
# Run this SCRIPT inside the container.
# It performs checks to prove you are contained.

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}[SAFE]${NC} $1"; }
fail() { echo -e "${RED}[DANGER]${NC} $1"; }
info() { echo -e "${NC}[INFO]${NC} $1"; }

echo "=== STARTING ISOLATION VERIFICATION ==="

# ---------------------------------------------------
# TEST 1: FILESYSTEM ISOLATION (The "Rm -rf" Check)
# ---------------------------------------------------
# We look for a file that definitely exists on your Host (/boot/vmlinuz*)
# but should NOT exist in a standard container unless you mounted root.

if ls /boot/vmlinuz* 1> /dev/null 2>&1; then
    # If we see the host's kernel image, the filesystem is leaking.
    fail "Host Kernel Image detected inside container!"
    echo "       CRITICAL: You have mounted '/' into the container."
else
    pass "Host Filesystem is invisible."
    echo "       (The Agent cannot access your laptop's OS files)"
fi

# ---------------------------------------------------
# TEST 2: IDENTITY ISOLATION (Hostname Check)
# ---------------------------------------------------
# The container should have a random hex hostname (e.g., a1b2c3d4),
# not your laptop's name (e.g., 'ubuntu-desktop').

CONTAINER_HOST=$(hostname)
if [[ "$CONTAINER_HOST" == "god_mode_lab" ]] || [[ ${#CONTAINER_HOST} -eq 12 ]]; then
    pass "Namespace Isolation Active (Hostname: $CONTAINER_HOST)"
else
    # This might trigger if you set 'hostname: x' in compose, which is fine.
    info "Hostname is: $CONTAINER_HOST"
fi

# ---------------------------------------------------
# TEST 3: THE "MARKER" TEST (Manual Verification)
# ---------------------------------------------------
echo -e "\n=== MANUAL MARKER TEST ==="
echo "We will now create a file in the container's temporary folder."
echo "If isolation works, this file will NOT appear on your laptop."

touch /tmp/i_am_inside_the_matrix
echo "1. Created file: /tmp/i_am_inside_the_matrix (Inside Container)"

if [ -f "/root/workspace/verify_isolation.sh" ]; then
    pass "Workspace Volume is working (Data Bridge active)."
else
    fail "Workspace Volume is broken."
fi

echo -e "\n${GREEN}=== TEST COMPLETE ===${NC}"
echo "To finish verification, run this on your HOST terminal:"
echo "   ls /tmp/i_am_inside_the_matrix"
echo "If it says 'No such file or directory', you are SAFE."
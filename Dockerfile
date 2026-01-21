FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# --- LAYER 1: SYSTEM CORE & GUI ---
# We install 'mesa-utils' and 'dbus-x11' to ensure Electron apps (VS Code/Antigravity)
# can render graphics without crashing or flickering.
RUN apt-get update && apt-get install -y \
    curl wget gpg sudo git build-essential \
    python3 python3-pip python3-venv \
    docker.io \
    libx11-6 libxext6 libxrender1 libxtst6 libgtk-3-0 \
    dbus-x11 x11-utils x11-xserver-utils x11-apps mesa-utils \
    libasound2 libdrm2 libgbm1 libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*

# --- LAYER 2: AI RUNTIMES ---
# Node.js 22.x is required for the latest Anthropic/Google CLI tools.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && \
    apt-get install -y nodejs

# --- LAYER 3: THE AI TOOLBOX ---
# Pre-installing public CLI tools with pinned versions for security.
# Note: Antigravity is manual (via volume) as it is a Preview .deb.
RUN npm install -g @anthropic-ai/claude-code@latest @google/gemini-cli@latest

# --- LAYER 3.5: DOCKER DAEMON CONFIGURATION ---
# Configure Docker-in-Docker with log rotation and storage driver
# NOTE: vfs is used instead of overlay2 because overlay2 doesn't work in Docker-in-Docker
# RUN mkdir -p /etc/docker && \
#     echo '{' > /etc/docker/daemon.json && \
#     echo '  "storage-driver": "vfs",' >> /etc/docker/daemon.json && \
#     echo '  "log-driver": "json-file",' >> /etc/docker/daemon.json && \
#     echo '  "log-opts": {' >> /etc/docker/daemon.json && \
#     echo '    "max-size": "10m",' >> /etc/docker/daemon.json && \
#     echo '    "max-file": "3"' >> /etc/docker/daemon.json && \
#     echo '  }' >> /etc/docker/daemon.json && \
#     echo '}' >> /etc/docker/daemon.json

# --- LAYER 4: VS CODE (BACKUP IDE) ---
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    rm -f packages.microsoft.gpg && \
    apt-get update && apt-get install -y code

# --- LAYER 5: CONFIGURATION ---
WORKDIR /root/workspace

# The "Zombie Protocol":
# We start the Docker Daemon in the background, but the ENTRYPOINT is a 
# non-terminating command (tail -f). This prevents the container from 
# crash-looping if the Daemon takes too long to start.
ENTRYPOINT ["/bin/bash", "-c", "dockerd > /var/log/dockerd.log 2>&1 & tail -f /dev/null"]

# # Create startup script that ensures Docker daemon is ready 
# RUN echo '#!/bin/bash' > /start.sh && \
#     echo 'set -e' >> /start.sh && \
#     echo '' >> /start.sh && \
#     echo '# Start Docker daemon in background' >> /start.sh && \
#     echo 'echo "[STARTUP] Starting Docker daemon..."' >> /start.sh && \
#     echo 'dockerd > /var/log/dockerd.log 2>&1 &' >> /start.sh && \
#     echo 'DOCKERD_PID=$!' >> /start.sh && \
#     echo '' >> /start.sh && \
#     echo '# Wait for Docker daemon to be ready' >> /start.sh && \
#     echo 'echo "[STARTUP] Waiting for Docker daemon to be ready..."' >> /start.sh && \
#     echo 'MAX_WAIT=30' >> /start.sh && \
#     echo 'COUNTER=0' >> /start.sh && \
#     echo 'until docker version > /dev/null 2>&1; do' >> /start.sh && \
#     echo '    sleep 1' >> /start.sh && \
#     echo '    COUNTER=$((COUNTER + 1))' >> /start.sh && \
#     echo '    if [ $COUNTER -ge $MAX_WAIT ]; then' >> /start.sh && \
#     echo '        echo "[ERROR] Docker daemon failed to start within ${MAX_WAIT}s"' >> /start.sh && \
#     echo '        cat /var/log/dockerd.log' >> /start.sh && \
#     echo '        exit 1' >> /start.sh && \
#     echo '    fi' >> /start.sh && \
#     echo 'done' >> /start.sh && \
#     echo '' >> /start.sh && \
#     echo 'echo "[STARTUP] Docker daemon is ready!"' >> /start.sh && \
#     echo 'docker version' >> /start.sh && \
#     echo '' >> /start.sh && \
#     echo '# Keep container alive' >> /start.sh && \
#     echo 'echo "[STARTUP] Container ready. Keeping alive..."' >> /start.sh && \
#     echo 'tail -f /dev/null' >> /start.sh && \
#     chmod +x /start.sh

# # Use the startup script as entrypoint
# ENTRYPOINT ["/start.sh"]
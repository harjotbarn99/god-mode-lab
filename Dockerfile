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
# Pre-installing public CLI tools. 
# Note: Antigravity is manual (via volume) as it is a Preview .deb.
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli

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
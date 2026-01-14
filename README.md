# The Barn Labs: God Mode Environment

**Status:** `Production-Ready` | **Version:** `1.0.0`

## 1. Overview

The **God Mode Lab** is a specialized "Digital Clean Room" designed for high-risk AI Agent engineering. It allows developers to run autonomous coding agents (Google Antigravity, Claude Code, Gemini CLI) in a fully isolated environment that retains **Root-level capability** without endangering the Host Operating System.

**Key Capabilities:**

* **Nested Virtualization:** Agents can spawn their own Docker containers (Docker-in-Docker) to test deployed code.
* **Zero-Latency GUI:** Uses Host Networking to render full graphical IDEs (Antigravity, VS Code) directly on the Linux Host.
* **Filesystem Isolation:** Prevents agents from accidentally modifying or deleting Host OS files.
* **Persistent Workflow:** Code and configuration are saved to the Host via volume mapping, surviving container rebuilds.

---

## 2. System Architecture

The environment uses a "Russian Doll" architecture to balance security with capability.

* **Layer 0: The Host (Ubuntu 22.04 LTS)**
* Provides Hardware Acceleration and X11 Display Server.
* Acts as the "Digital Bouncer" for graphical permissions.


* **Layer 1: The God Mode Container**
* **Privilege:** `privileged: true` (Full Kernel Access).
* **Network:** `host` (Shared IP/Network Stack).
* **Role:** The "Developer Workstation." Hosts the AI CLI tools and IDEs.


* **Layer 2: The Agent Containers**
* Ephemeral containers spawned *by* the AI agents inside Layer 1 for testing purposes.



---

## 3. Prerequisites

* **OS:** Ubuntu 22.04 LTS (Intel/AMD64).
* **Runtime:** Docker Desktop for Linux OR Docker Engine.
* **Hardware:** Intel/AMD Processor (Virtualization enabled in BIOS).
* **Permissions:** Sudo access on the Host machine.

---

## 4. Installation & Setup

### Step 1: Directory Structure

Ensure your project folder follows this strict hierarchy:

```text
~/my-lab/
├── Dockerfile              # The Build Blueprint
├── docker-compose.yml      # The Orchestrator
├── workspace/              # [MOUNTED] Your source code lives here
│   ├── .antigravity-data/  # IDE Persisted Config
│   ├── google-antigravity.deb  # (Manual Download)
│   └── test_god_mode.sh    # Diagnostic Script
└── README.md

```

### Step 2: Configure Docker Desktop (Critical)

If using Docker Desktop, you must whitelist the graphics socket:

1. Open **Docker Desktop** > **Settings** > **Resources** > **File Sharing**.
2. Add the path: `/tmp`
3. Click **Apply & Restart**.

### Step 3: Authorize Graphics

On the Host machine, run this command to allow the container to draw windows:

```bash
xhost +local:root

```

*(Tip: Add this to your `~/.bashrc` to make it permanent).*

### Step 4: Build the Environment

```bash
cd ~/my-lab
docker compose up -d --build

```

---

## 5. Usage Guide

### 5.1 Entering the Lab

To access the terminal of your clean room:

```bash
docker exec -it god_mode_lab bash

```

### 5.2 Launching Tools

**Google Antigravity (IDE):**
*Note: You must install the `.deb` file manually the first time.*

```bash
# Launch Command
antigravity --no-sandbox --user-data-dir=/root/.antigravity-data &

```

**VS Code (Backup IDE):**

```bash
code --no-sandbox --user-data-dir=/root/.vscode-data &

```

**Claude Code CLI:**

```bash
claude login  # Run once to authenticate
claude

```

**Gemini CLI:**

```bash
gemini login  # Run once to authenticate
gemini

```

### 5.3 Verifying Docker-in-Docker

Inside the lab, you can test if the nested Docker engine is working:

```bash
docker run --rm hello-world

```

---

## 6. Maintenance & Diagnostics

### Auto-Fixing the Engine

If Docker inside the container isn't starting, we use the "Zombie Protocol."
The entrypoint is set to `tail -f /dev/null` to keep the container alive even if the engine crashes. You can manually restart the inner daemon:

```bash
dockerd > /var/log/dockerd.log 2>&1 &

```

### Running the Health Check

Run the included diagnostic script to verify all systems:

```bash
./workspace/test_god_mode.sh

```

**Expected Output:**

> [PASS] DISPLAY variable detected...
> [PASS] Docker Daemon is online...
> [PASS] Nested Virtualization Verified...
> [PASS] Node.js installed...

---

## 7. Security Disclaimer

This environment runs with **`privileged: true`**.

* **What it protects:** It effectively isolates your Host filesystem. `rm -rf /` inside the container will NOT wipe your laptop.
* **What it exposes:** The container has full access to your hardware devices and shares your Network IP. Do not run untrusted, malicious binaries that might attack local network devices.

---

## 8. Troubleshooting

**Error: `Authorization required, but no authorization protocol specified**`

* **Cause:** The Host rejected the GUI connection.
* **Fix:** Run `xhost +local:root` on the Host terminal.

**Error: `mounts denied: The path /tmp/.X11-unix is not shared**`

* **Cause:** Docker Desktop security blocking the file.
* **Fix:** Add `/tmp` to File Sharing in Docker Desktop settings.

**Error: `docker: command not found` (Inside container)**

* **Cause:** The inner Docker engine failed to start automatically.
* **Fix:** Run `dockerd > /var/log/dockerd.log 2>&1 &`.
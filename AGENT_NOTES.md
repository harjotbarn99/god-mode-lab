# Agent Notes - God Mode Lab

## 2026-01-19 - Repository Onboarding

**What was done:**
- Completed repository onboarding workflow
- Created `.agent/workflows/repo-onboard.md` for future onboarding
- Reviewed [README.md](file:///home/harjot/god_mode_lab/README.md), [Dockerfile](file:///home/harjot/god_mode_lab/Dockerfile), and [docker-compose.yml](file:///home/harjot/god_mode_lab/docker-compose.yml)
- Understood the "Russian Doll" architecture (3 layers)
- Verified container status: `god_mode_lab` is running (up 4 hours, started 5 days ago)

**Key insights:**
- This is a Docker-based isolated environment ("Digital Clean Room") for running AI agents safely
- Uses `privileged: true` for Docker-in-Docker capability (nested virtualization)
- GUI apps work via host networking (`network_mode: host`) and X11 socket mapping
- Code persists in [workspace/](file:///home/harjot/god_mode_lab/workspace) directory via volume mounting
- Container stays alive via "Zombie Protocol" (`tail -f /dev/null`) even if Docker daemon crashes

**Repository structure:**
- `/Dockerfile` - Multi-layer build: system core, GUI support, Node.js 22.x, AI tools (Claude Code, Gemini CLI), VS Code
- `/docker-compose.yml` - Container orchestration with privileged mode and volume mappings
- `/workspace/` - Persistent workspace (mounted from host)
- `/workspace/container_tests/` - Contains test scripts
- `/workspace/test_isolation.sh` - Diagnostic/health check script
- `/.agent/workflows/` - Agent workflow definitions (newly created)

**Current status:**
- Repository structure understood
- Container running and healthy
- Onboarding workflow created for future agents
- Ready for agent tasks

**Next steps:**
- Await user instructions for specific tasks
- Refer to this file for repository context
- Update this file after significant work sessions

# God Mode Lab - Makefile

# Defaults
.DEFAULT_GOAL := help

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

## Help: Show this help message
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-20s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''

## Start: Start the container in detached mode
start: up

## Up: Alias for start
up:
	@echo "${GREEN}[+] Starting God Mode Lab...${RESET}"
	docker compose up -d
	@echo "${GREEN}[+] Container started!${RESET}"

## Stop: Stop the container
stop: down

## Down: Stop and remove the container
down:
	@echo "${YELLOW}[-] Stopping God Mode Lab...${RESET}"
	docker compose down
	@echo "${GREEN}[+] Container stopped.${RESET}"

## Restart: Restart the container
restart: stop start

## Logs: Follow container logs
logs:
	docker compose logs -f

## Shell: Enter the container shell
shell:
	docker exec -it god_mode_lab /bin/bash

## Build: Build the container image
build:
	@echo "${GREEN}[+] Building image...${RESET}"
	docker compose build

## Force Install: Rebuild image with no cache and restart (clean install)
force-install:
	@echo "${YELLOW}[!] Rebuilding from scratch (no cache)...${RESET}"
	docker compose build --no-cache
	@$(MAKE) up

## Clean: Remove containers, networks, and orphans
clean:
	@echo "${YELLOW}[!] Cleaning up containers and networks...${RESET}"
	docker compose down --remove-orphans
	@echo "${GREEN}[+] Clean complete.${RESET}"

## Test: Run diagnostic tests
test:
	@echo "${GREEN}[+] Running test_basic...${RESET}"
	docker exec god_mode_lab bash /root/workspace/container_tests/test_basic.sh
# 	@echo "${GREEN}[+] Running test_isolation...${RESET}"
# 	docker exec god_mode_lab bash /root/workspace/test_isolation.sh


## Backup: Run the backup script
backup:
	@echo "${GREEN}[+] Starting backup...${RESET}"
	@./scripts/backup.sh

## Monitor: Run the monitor script
monitor:
	@echo "${GREEN}[+] Starting monitor...${RESET}"
	@./scripts/monitor.sh

## Update: Run the update script
update:
	@echo "${YELLOW}[!] Starting update process...${RESET}"
	@./scripts/update.sh

## Test GUI: Run the GUI testing script
test-gui:
	@echo "${GREEN}[+] Testing GUI applications...${RESET}"
	@./scripts/test_gui.sh

.PHONY: help start up stop down restart logs shell build force-install clean test backup monitor update test-gui

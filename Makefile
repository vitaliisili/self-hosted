# === Global Settings ===
# Load variables from .env
include .env
export $(shell sed 's/=.*//' .env)

ENV_FILE := .env
DC := docker compose --env-file $(ENV_FILE)


# === Open Browser Helper ===
.PHONY: open-browser
open-browser:
ifdef APP_URL
	@echo "🌐 Opening $(APP_URL) in browser..."
	@xdg-open $(APP_URL) 2>/dev/null || open $(APP_URL) || echo "❗ Could not auto-open browser"
else
	@echo "ℹ️  No APP_URL defined."
endif


# === Create Docker Network ===
.PHONY: create-network
create-network:
	@echo "🔧 Ensuring Docker network exists..."
	@./docker-network.sh


# === Flame ===
.PHONY: flame
flame: create-network
	@echo "🚀 Deploying Flame..."
	@$(DC) -f apps/flame/docker-compose.yml down --remove-orphans
	@$(DC) -f apps/flame/docker-compose.yml pull
	@$(DC) -f apps/flame/docker-compose.yml up -d
	@$(MAKE) open-browser APP_URL=http://localhost:5005


# === ChangeDetection.io ===
.PHONY: changedetection
changedetection: create-network
	@echo "🔍 Deploying changedetection.io..."
	@$(DC) -f apps/changedetection/docker-compose.yml down --remove-orphans
	@$(DC) -f apps/changedetection/docker-compose.yml pull
	@$(DC) -f apps/changedetection/docker-compose.yml up -d
	@$(MAKE) open-browser APP_URL=http://localhost:5000


# === Browserless ===
.PHONY: browserless
browserless: create-network
	@echo "🧠 Deploying browserless (headless Chrome) with token auth..."
	@$(DC) -f apps/browserless/docker-compose.yml down --remove-orphans
	@$(DC) -f apps/browserless/docker-compose.yml pull
	@$(DC) -f apps/browserless/docker-compose.yml up -d
	@echo "🔐 Access secured: http://localhost:3099?token=secret"
	@$(MAKE) open-browser APP_URL=http://localhost:3099?token=secret


# === Homepage ===
.PHONY: homepage
homepage: create-network
	@echo "🏠 Deploying Homepage dashboard..."
	@$(DC) -f apps/homepage/docker-compose.yml down --remove-orphans
	@$(DC) -f apps/homepage/docker-compose.yml pull
	@$(DC) -f apps/homepage/docker-compose.yml up -d
	@$(MAKE) open-browser APP_URL=http://localhost:$(HOMEPAGE_PORT)


# === Uptime Kuma ===
.PHONY: uptime-kuma
uptime-kuma: create-network
	@echo "🏠 Deploying Uptime Kuma..."
	@$(DC) -f apps/uptime-kuma/docker-compose.yml down --remove-orphans
	@$(DC) -f apps/uptime-kuma/docker-compose.yml pull
	@$(DC) -f apps/uptime-kuma/docker-compose.yml up -d
	@$(MAKE) open-browser APP_URL=http://localhost:$(KUMA_PORT)


# === Clean & Prune ===
.PHONY: clean prune


clean:
	@make flame-down
	@make changedetection-down


flame-down:
	@$(DC) -f apps/flame/docker-compose.yml down --remove-orphans


changedetection-down:
	@$(DC) -f apps/changedetection/docker-compose.yml down --remove-orphans


prune:
	@docker container prune -f
	@docker image prune -af
	@docker volume prune -f
	@docker network prune -f

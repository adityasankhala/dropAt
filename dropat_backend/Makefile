# ──────────────────────────────────────────────────
# DropAt Backend — Common Development Commands
# ──────────────────────────────────────────────────
# Usage:  make <target>
# Run `make help` to see all available commands.
# ──────────────────────────────────────────────────

.PHONY: help setup dev stop logs seed migrate clean

help: ## Show this help message
	@echo ""
	@echo "  DropAt Backend — Available Commands"
	@echo "  ──────────────────────────────────────"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

setup: ## First-time setup: copy .env, build containers, seed DB
	@echo "📋 Creating .env from template..."
	@test -f .env || cp .env.example .env
	@echo "🐳 Building and starting Docker containers..."
	docker compose up --build -d
	@echo "⏳ Waiting for database to be ready..."
	@sleep 5
	@echo "🌱 Seeding the database..."
	curl -s -X POST http://localhost:8000/seed | python3 -m json.tool
	@echo ""
	@echo "✅ Setup complete!"
	@echo "   API Docs:  http://localhost:8000/docs"
	@echo "   Admin:     http://localhost:8000/admin"
	@echo "   Health:    http://localhost:8000/health"

dev: ## Start Docker containers (detached)
	docker compose up -d

stop: ## Stop all Docker containers
	docker compose down

logs: ## Tail API container logs
	docker compose logs -f api

seed: ## Seed the database with sample routes and vouchers
	curl -s -X POST http://localhost:8000/seed | python3 -m json.tool

health: ## Check API health
	@curl -s http://localhost:8000/health | python3 -m json.tool

clean: ## Stop containers and remove volumes (⚠️ deletes DB data!)
	@echo "⚠️  This will delete all database data!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] && \
		docker compose down -v || echo "Cancelled."

rebuild: ## Rebuild API container (after changing requirements.txt)
	docker compose up --build -d api

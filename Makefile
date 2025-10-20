# WordPress WP Starter Makefile - Multi-Project Support

.DEFAULT_GOAL := help
.PHONY: help setup multi-setup start stop restart status logs shell wp-shell db-shell info clean docs

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

##@ Getting Started

help: ## Display available commands
	@echo "$(CYAN)WordPress WP Starter - Multi-Project Development$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make $(CYAN)<target>$(RESET)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Multi-Project Examples:$(RESET)"
	@echo "  scripts/project-manager.ps1 create client-acme 8080 'ACME Corp'"
	@echo "  scripts/project-manager.ps1 start client-acme"
	@echo "  scripts/project-manager.ps1 list"

setup: ## Initial single-project setup
	@echo "$(GREEN)Setting up WordPress development environment...$(RESET)"
	@if [ ! -f .env ]; then cp config/.env.example .env && echo "$(GREEN)✓ Created .env file$(RESET)"; fi
	@docker-compose up -d
	@echo "$(GREEN)✓ WordPress available at http://localhost:8080$(RESET)"

multi-info: ## Show multi-project information
	@echo "$(CYAN)Multi-Project WordPress Development$(RESET)"
	@echo ""
	@echo "$(GREEN)Create unlimited WordPress projects:$(RESET)"
	@echo "  scripts/project-manager.ps1 create my-project 8080 'Description'"
	@echo "  scripts/project-manager.ps1 start my-project"
	@echo ""
	@echo "$(GREEN)Documentation:$(RESET)"
	@echo "  📚 Complete guide: docs/setup/multi-project.md"
	@echo "  🏢 Team workflows: docs/guides/multi-project-workflows.md"

##@ Single Project Management

start: ## Start single project containers
	@docker-compose up -d
	@echo "$(GREEN)✓ WordPress available at http://localhost:8080$(RESET)"

stop: ## Stop single project containers
	@docker-compose down
	@echo "$(YELLOW)✓ Containers stopped$(RESET)"

restart: ## Restart single project containers
	@docker-compose restart
	@echo "$(GREEN)✓ Containers restarted$(RESET)"

status: ## Show container status
	@docker-compose ps

logs: ## Show container logs
	@docker-compose logs -f

##@ Development Tools

shell: ## Access WordPress container shell
	@docker-compose exec wordpress bash

wp: ## Run WP-CLI command (usage: make wp plugin list)
	@docker-compose exec wordpress wp $(filter-out wp,$(MAKECMDGOALS))

db-shell: ## Access MySQL shell
	@docker-compose exec mysql mysql -u root -p

##@ Multi-Project Commands

multi-create: ## Create new project (NAME=project PORT=8080 DESC="Description")
	@scripts/project-manager.ps1 create $(NAME) $(PORT) "$(DESC)"

multi-start: ## Start project (NAME=project-name)
	@scripts/project-manager.ps1 start $(NAME)

multi-stop: ## Stop project (NAME=project-name)
	@scripts/project-manager.ps1 stop $(NAME)

multi-list: ## List all projects
	@scripts/project-manager.ps1 list

multi-ports: ## Show port assignments
	@scripts/project-manager.ps1 ports

##@ Maintenance

clean: ## Clean up Docker resources
	@docker system prune -f
	@echo "$(GREEN)✓ Docker resources cleaned$(RESET)"

build: ## Build/rebuild containers
	@docker-compose build --no-cache
	@echo "$(GREEN)✓ Containers built$(RESET)"

##@ Information

info: ## Show environment information
	@echo "$(CYAN)WordPress WP Starter Environment$(RESET)"
	@echo "Docker: $$(docker --version 2>/dev/null || echo 'Not installed')"
	@echo "Docker Compose: $$(docker-compose --version 2>/dev/null || echo 'Not installed')"
	@echo ""
	@echo "$(CYAN)Single Project URLs:$(RESET)"
	@echo "  WordPress: http://localhost:8080"
	@echo "  Admin: http://localhost:8080/wp/wp-admin"
	@echo "  phpMyAdmin: http://localhost:8081"
	@echo "  MailHog: http://localhost:8025"

docs: ## Show documentation links
	@echo "$(CYAN)📚 Documentation Available:$(RESET)"
	@echo ""
	@echo "$(GREEN)Getting Started:$(RESET)"
	@echo "  🚀 Multi-Project Setup: docs/setup/multi-project.md"
	@echo "  ⚡ Single Project: docs/setup/quickstart.md"
	@echo "  ✅ Developer Checklist: docs/setup/developer-checklist.md"
	@echo ""
	@echo "$(GREEN)Guides & Workflows:$(RESET)"
	@echo "  👥 Contributing: docs/guides/contributing.md"
	@echo "  🏢 Multi-Project Workflows: docs/guides/multi-project-workflows.md"
	@echo "  🐳 Docker Guide: docs/guides/docker-guide.md"
	@echo ""
	@echo "$(GREEN)Tools & Scripts:$(RESET)"
	@echo "  🛠️ Scripts: scripts/"
	@echo "  ⚙️ Configuration: config/"

##@ Quick Actions

quick-start: setup ## Complete single-project setup
	@echo "$(GREEN)🎉 Single project ready at http://localhost:8080$(RESET)"

quick-multi: ## Show multi-project quick start
	@echo "$(CYAN)🚀 Multi-Project Quick Start:$(RESET)"
	@echo ""
	@echo "$(YELLOW)1. Create a project:$(RESET)"
	@echo "   scripts/project-manager.ps1 create my-project 8080 'My Project'"
	@echo ""
	@echo "$(YELLOW)2. Start the project:$(RESET)"
	@echo "   scripts/project-manager.ps1 start my-project"
	@echo ""
	@echo "$(YELLOW)3. Access your site:$(RESET)"
	@echo "   http://localhost:8080"
	@echo ""
	@echo "$(GREEN)📚 Complete guide: docs/setup/multi-project.md$(RESET)"

# Catch-all target to prevent errors
%:
	@:
	@echo "  WordPress:  http://localhost:8080"
	@echo "  Admin:      http://localhost:8080/wp/wp-admin/"
	@echo "  phpMyAdmin: http://localhost:8081"
	@echo "  MailHog:    http://localhost:8025"

# Prevent make from interpreting additional arguments as targets
%:
	@:
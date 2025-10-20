# WordPress Docker Development Makefile

.DEFAULT_GOAL := help
.PHONY: help start stop restart reset status logs shell wp composer npm backup restore install update info clean

# Colors for help
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

help: ## Show this help message
	@echo "$(BLUE)WordPress Docker Development Environment (Nginx + PHP-FPM)$(RESET)"
	@echo ""
	@echo "$(GREEN)Available commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-12s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Examples:$(RESET)"
	@echo "  make start          # Start development environment"
	@echo "  make wp -- --info   # Run WP-CLI info command"
	@echo "  make logs wordpress # Show WordPress container logs"

start: ## Start the development environment
	@echo "$(GREEN)Starting WordPress development environment...$(RESET)"
	@chmod +x docker/scripts/dev.sh
	@./docker/scripts/dev.sh start

stop: ## Stop the development environment
	@echo "$(YELLOW)Stopping WordPress development environment...$(RESET)"
	@docker-compose down

restart: ## Restart the development environment
	@echo "$(YELLOW)Restarting WordPress development environment...$(RESET)"
	@docker-compose restart

reset: ## Reset environment (remove all data)
	@echo "$(RED)WARNING: This will remove all containers and data!$(RESET)"
	@./docker/scripts/dev.sh reset

status: ## Show container status
	@docker-compose ps

logs: ## Show logs for all services (or specific service: make logs wordpress)
	@docker-compose logs -f $(filter-out logs,$(MAKECMDGOALS))

shell: ## Access WordPress container shell
	@docker-compose exec wordpress bash

wp: ## Run WP-CLI command (usage: make wp -- plugin list)
	@docker-compose run --rm wpcli $(filter-out wp,$(MAKECMDGOALS))

composer: ## Run Composer command (usage: make composer -- install)
	@docker-compose exec wordpress composer $(filter-out composer,$(MAKECMDGOALS))

npm: ## Run npm command (usage: make npm -- install)
	@docker-compose run --rm nodejs npm $(filter-out npm,$(MAKECMDGOALS))

backup: ## Create backup of database and files
	@echo "$(GREEN)Creating backup...$(RESET)"
	@chmod +x docker/scripts/backup.sh
	@./docker/scripts/backup.sh

restore: ## Restore from backup (usage: make restore backup_file.tar.gz)
	@echo "$(YELLOW)Restoring from backup...$(RESET)"
	@chmod +x docker/scripts/restore.sh
	@./docker/scripts/restore.sh $(filter-out restore,$(MAKECMDGOALS))

install: ## Install WordPress and development plugins
	@echo "$(GREEN)Installing WordPress and plugins...$(RESET)"
	@./docker/scripts/dev.sh install

update: ## Update WordPress core and plugins
	@echo "$(GREEN)Updating WordPress...$(RESET)"
	@./docker/scripts/dev.sh update

info: ## Show environment information
	@./docker/scripts/dev.sh info

clean: ## Clean up Docker resources
	@echo "$(YELLOW)Cleaning Docker resources...$(RESET)"
	@docker system prune -f
	@docker volume prune -f

build: ## Build/rebuild containers
	@echo "$(GREEN)Building containers...$(RESET)"
	@docker-compose build --no-cache

# Development shortcuts
dev-install: start install ## Start environment and install WordPress
	@echo "$(GREEN)Development environment ready!$(RESET)"

dev-reset: reset start install ## Complete reset and setup
	@echo "$(GREEN)Development environment reset and ready!$(RESET)"

# Database shortcuts
db-export: ## Export database to file
	@docker-compose exec mysql mysqldump -u wp_user -pwp_secure_password wordpress_dev > wordpress_dev.sql
	@echo "$(GREEN)Database exported to wordpress_dev.sql$(RESET)"

db-import: ## Import database from wordpress_dev.sql
	@docker-compose exec -T mysql mysql -u wp_user -pwp_secure_password wordpress_dev < wordpress_dev.sql
	@echo "$(GREEN)Database imported from wordpress_dev.sql$(RESET)"

db-shell: ## Access MySQL shell
	@docker-compose exec mysql mysql -u wp_user -pwp_secure_password wordpress_dev

# Quick access URLs
urls: ## Show all service URLs
	@echo "$(BLUE)Service URLs:$(RESET)"
	@echo "  WordPress:  http://localhost:8080"
	@echo "  Admin:      http://localhost:8080/wp/wp-admin/"
	@echo "  phpMyAdmin: http://localhost:8081"
	@echo "  MailHog:    http://localhost:8025"

# Prevent make from interpreting additional arguments as targets
%:
	@:
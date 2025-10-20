#!/bin/bash

# Docker WordPress Development Helper Script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info &>/dev/null; then
        log_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
}

# Display help
show_help() {
    echo "WordPress Docker Development Helper"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start           Start the development environment"
    echo "  stop            Stop the development environment"
    echo "  restart         Restart the development environment"
    echo "  reset           Stop and remove all containers and volumes"
    echo "  status          Show container status"
    echo "  logs            Show logs for all services"
    echo "  logs [service]  Show logs for specific service"
    echo "  shell           Access WordPress container shell"
    echo "  wp [cmd]        Run WP-CLI command"
    echo "  composer [cmd]  Run Composer command"
    echo "  npm [cmd]       Run npm command"
    echo "  backup          Create backup of database and files"
    echo "  restore [file]  Restore from backup file"
    echo "  install         Install WordPress and plugins"
    echo "  update          Update WordPress core and plugins"
    echo "  info            Show environment information"
    echo "  help            Show this help message"
}

# Start environment
start_env() {
    log_info "Starting WordPress development environment..."
    check_docker
    
    cd "$PROJECT_DIR"
    
    # Create .env if it doesn't exist
    if [ ! -f ".env" ]; then
        log_info "Creating .env file from .env.docker template..."
        cp .env.docker .env
        log_success ".env file created"
    fi
    
    # Build and start containers
    docker-compose up -d --build
    
    log_success "Environment started!"
    log_info "WordPress: http://localhost:8080"
    log_info "Admin: http://localhost:8080/wp/wp-admin/ (admin/admin)"
    log_info "phpMyAdmin: http://localhost:8081"
    log_info "MailHog: http://localhost:8025"
}

# Stop environment
stop_env() {
    log_info "Stopping WordPress development environment..."
    cd "$PROJECT_DIR"
    docker-compose down
    log_success "Environment stopped"
}

# Restart environment
restart_env() {
    log_info "Restarting WordPress development environment..."
    cd "$PROJECT_DIR"
    docker-compose restart
    log_success "Environment restarted"
}

# Reset environment (remove everything)
reset_env() {
    log_warning "This will remove all containers, volumes, and data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Resetting environment..."
        cd "$PROJECT_DIR"
        docker-compose down -v --remove-orphans
        docker-compose build --no-cache
        log_success "Environment reset complete"
    else
        log_info "Reset cancelled"
    fi
}

# Show status
show_status() {
    log_info "Container status:"
    cd "$PROJECT_DIR"
    docker-compose ps
}

# Show logs
show_logs() {
    cd "$PROJECT_DIR"
    if [ $# -eq 0 ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$1"
    fi
}

# Access shell
access_shell() {
    log_info "Accessing WordPress container shell..."
    cd "$PROJECT_DIR"
    docker-compose exec wordpress bash
}

# Run WP-CLI command
run_wp() {
    cd "$PROJECT_DIR"
    if [ $# -eq 0 ]; then
        docker-compose run --rm wpcli --info
    else
        docker-compose run --rm wpcli "$@"
    fi
}

# Run Composer command
run_composer() {
    cd "$PROJECT_DIR"
    if [ $# -eq 0 ]; then
        docker-compose exec wordpress composer --version
    else
        docker-compose exec wordpress composer "$@"
    fi
}

# Run npm command
run_npm() {
    cd "$PROJECT_DIR"
    if [ $# -eq 0 ]; then
        docker-compose run --rm nodejs npm --version
    else
        docker-compose run --rm nodejs npm "$@"
    fi
}

# Create backup
create_backup() {
    log_info "Creating backup..."
    cd "$PROJECT_DIR"
    
    BACKUP_DIR="backups"
    BACKUP_FILE="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    mkdir -p "$BACKUP_DIR"
    
    # Export database
    log_info "Exporting database..."
    docker-compose exec mysql mysqldump -u wp_user -pwp_secure_password wordpress_dev > "${BACKUP_DIR}/database.sql"
    
    # Create archive
    log_info "Creating archive..."
    tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
        --exclude='vendor' \
        --exclude='node_modules' \
        --exclude='wp/wp-admin' \
        --exclude='wp/wp-includes' \
        wp-content/ \
        .env \
        "${BACKUP_DIR}/database.sql"
    
    # Cleanup
    rm "${BACKUP_DIR}/database.sql"
    
    log_success "Backup created: ${BACKUP_DIR}/${BACKUP_FILE}"
}

# Restore from backup
restore_backup() {
    if [ $# -eq 0 ]; then
        log_error "Please specify backup file to restore"
        exit 1
    fi
    
    BACKUP_FILE="$1"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        log_error "Backup file not found: $BACKUP_FILE"
        exit 1
    fi
    
    log_warning "This will overwrite current data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restoring from backup: $BACKUP_FILE"
        cd "$PROJECT_DIR"
        
        # Extract backup
        tar -xzf "$BACKUP_FILE"
        
        # Import database if present
        if [ -f "database.sql" ]; then
            log_info "Importing database..."
            docker-compose exec -T mysql mysql -u wp_user -pwp_secure_password wordpress_dev < database.sql
            rm database.sql
        fi
        
        log_success "Restore completed"
    else
        log_info "Restore cancelled"
    fi
}

# Install WordPress and plugins
install_wordpress() {
    log_info "Installing WordPress and plugins..."
    cd "$PROJECT_DIR"
    
    # Install Composer dependencies
    docker-compose exec wordpress composer install
    
    # Install WordPress if not already installed
    if ! docker-compose run --rm wpcli core is-installed 2>/dev/null; then
        log_info "Installing WordPress core..."
        docker-compose run --rm wpcli core install \
            --url="http://localhost:8080" \
            --title="WordPress Development" \
            --admin_user="admin" \
            --admin_password="admin" \
            --admin_email="admin@localhost.dev" \
            --skip-email
    fi
    
    # Install development plugins
    log_info "Installing development plugins..."
    docker-compose run --rm wpcli plugin install query-monitor --activate || true
    docker-compose run --rm wpcli plugin install redis-cache --activate || true
    
    # Enable Redis cache
    docker-compose run --rm wpcli redis enable || log_warning "Could not enable Redis cache"
    
    log_success "Installation completed"
}

# Update WordPress and plugins
update_wordpress() {
    log_info "Updating WordPress and plugins..."
    cd "$PROJECT_DIR"
    
    # Update Composer dependencies
    docker-compose exec wordpress composer update
    
    # Update WordPress core
    docker-compose run --rm wpcli core update
    
    # Update plugins
    docker-compose run --rm wpcli plugin update --all
    
    # Update themes
    docker-compose run --rm wpcli theme update --all
    
    log_success "Updates completed"
}

# Show environment information
show_info() {
    log_info "WordPress Docker Development Environment (Nginx + PHP-FPM)"
    echo ""
    echo "🔗 URLs:"
    echo "   WordPress:  http://localhost:8080"
    echo "   Admin:      http://localhost:8080/wp/wp-admin/"
    echo "   phpMyAdmin: http://localhost:8081"
    echo "   MailHog:    http://localhost:8025"
    echo ""
    echo "🔑 Credentials:"
    echo "   WordPress:  admin / admin"
    echo "   Database:   wp_user / wp_secure_password"
    echo "   Root DB:    root / root_secure_password"
    echo ""
    echo "🗄️  Database:"
    echo "   Host:       localhost:3306"
    echo "   Database:   wordpress_dev"
    echo ""
    echo "📁 Volumes:"
    echo "   Uploads:    wp_uploads"
    echo "   Database:   mysql_data"
    echo "   Redis:      redis_data"
    echo ""
}

# Main script logic
case "${1:-help}" in
    start)
        start_env
        ;;
    stop)
        stop_env
        ;;
    restart)
        restart_env
        ;;
    reset)
        reset_env
        ;;
    status)
        show_status
        ;;
    logs)
        shift
        show_logs "$@"
        ;;
    shell)
        access_shell
        ;;
    wp)
        shift
        run_wp "$@"
        ;;
    composer)
        shift
        run_composer "$@"
        ;;
    npm)
        shift
        run_npm "$@"
        ;;
    backup)
        create_backup
        ;;
    restore)
        shift
        restore_backup "$@"
        ;;
    install)
        install_wordpress
        ;;
    update)
        update_wordpress
        ;;
    info)
        show_info
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
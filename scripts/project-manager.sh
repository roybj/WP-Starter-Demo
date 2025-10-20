#!/bin/bash

# ============================================================================
# WordPress Project Manager (Simplified) - Linux/macOS
# ============================================================================
# Manage WordPress development projects (start/stop/status)
# Run from your project directory: ./scripts/project-manager.sh [command]

set -e

# Colors
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'

# Helper functions
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${COLOR_RESET}"
}

print_success() { print_color "$COLOR_GREEN" "$1"; }
print_error() { print_color "$COLOR_RED" "$1"; }
print_warning() { print_color "$COLOR_YELLOW" "$1"; }
print_info() { print_color "$COLOR_BLUE" "$1"; }
print_cyan() { print_color "$COLOR_CYAN" "$1"; }

# Get project info from .env
get_project_info() {
    if [ ! -f ".env" ]; then
        print_error "❌ Error: .env file not found in current directory"
        echo "Please run this command from your WordPress project directory."
        echo "If this is a new project, copy .env.example to .env first."
        exit 1
    fi
    
    PROJECT_NAME=$(grep "COMPOSE_PROJECT_NAME=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "wordpress-project")
    HTTP_PORT=$(grep "HTTP_PORT=" .env 2>/dev/null | cut -d'=' -f2 || echo "8080")
    PHPMYADMIN_PORT=$(grep "PHPMYADMIN_PORT=" .env 2>/dev/null | cut -d'=' -f2 || echo "8081")
}

# ============================================================================
# START PROJECT
# ============================================================================
start_project() {
    get_project_info
    
    print_info "🚀 Starting WordPress project: $PROJECT_NAME"
    
    # Check if .env exists
    if [ ! -f ".env" ]; then
        print_error "❌ Error: .env file not found"
        echo ""
        echo "Quick setup:"
        echo "  1. Copy template:  cp .env.example .env"
        echo "  2. Edit ports:     nano .env"
        echo "  3. Start project:  ./scripts/project-manager.sh start"
        exit 1
    fi
    
    # Ensure shared network exists
    if ! docker network ls --filter name=wordpress-shared --format "{{.Name}}" | grep -q "^wordpress-shared$"; then
        print_info "🌐 Creating shared network: wordpress-shared"
        docker network create wordpress-shared
    fi
    
    # Use multi-project compose if available, otherwise fallback
    if [ -f "config/docker-compose.multi.yml" ]; then
        cp config/docker-compose.multi.yml docker-compose.yml
        print_info "📁 Using multi-project configuration"
    fi
    
    # Check if containers are already running
    if docker-compose ps | grep -q "Up"; then
        print_warning "⚠️  Project containers are already running"
    else
        print_info "🐳 Starting Docker containers..."
        docker-compose up -d
    fi
    
    # Wait a moment for services to initialize
    sleep 2
    
    print_success "✅ Project '$PROJECT_NAME' started successfully"
    echo ""
    print_info "🌐 Access URLs:"
    echo "   Website:      http://localhost:$HTTP_PORT"
    echo "   WordPress:    http://localhost:$HTTP_PORT/wp/wp-admin/"
    echo "   phpMyAdmin:   http://localhost:$PHPMYADMIN_PORT"
    echo "   🔑 WordPress Login: admin/admin"
    echo ""
    print_info "📧 Optional Email Testing:"
    echo "   Start MailHog: docker-compose -f docker-compose.mailhog.yml up -d"
    echo "   Access:        http://localhost:8025"
    echo ""
}

# ============================================================================
# STOP PROJECT
# ============================================================================
stop_project() {
    get_project_info
    
    print_info "🛑 Stopping WordPress project: $PROJECT_NAME"
    
    docker-compose down
    
    print_success "✅ Project '$PROJECT_NAME' stopped successfully"
}

# ============================================================================
# PROJECT STATUS
# ============================================================================
show_status() {
    get_project_info
    
    print_info "📊 Project Status: $PROJECT_NAME"
    echo ""
    
    # Check if .env exists
    if [ ! -f ".env" ]; then
        print_error "❌ .env file not found - project not configured"
        return 1
    fi
    
    # Show configuration
    print_info "⚙️  Configuration:"
    echo "   Project:      $PROJECT_NAME"
    echo "   Directory:    $(pwd)"
    echo "   Website:      http://localhost:$HTTP_PORT"
    echo "   phpMyAdmin:   http://localhost:$PHPMYADMIN_PORT"
    echo ""
    
    # Show container status
    print_info "🐳 Container Status:"
    if docker-compose ps 2>/dev/null | grep -q "."; then
        docker-compose ps
    else
        echo "   No containers running"
    fi
    
    echo ""
    
    # Show system info
    print_info "🖥️  System Status:"
    if command -v docker &> /dev/null; then
        print_success "   ✅ Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')"
    else
        print_error "   ❌ Docker: Not installed"
    fi
    
    if command -v docker-compose &> /dev/null; then
        print_success "   ✅ Docker Compose: Available"
    else
        print_error "   ❌ Docker Compose: Not installed"
    fi
    
    echo ""
}

# ============================================================================
# RESTART PROJECT
# ============================================================================
restart_project() {
    get_project_info
    
    print_info "🔄 Restarting WordPress project: $PROJECT_NAME"
    
    docker-compose down
    sleep 1
    docker-compose up -d
    
    print_success "✅ Project '$PROJECT_NAME' restarted successfully"
}

# ============================================================================
# VIEW LOGS
# ============================================================================
show_logs() {
    get_project_info
    
    local service="${1:-}"
    
    print_info "📋 Container Logs: $PROJECT_NAME"
    
    if [ -n "$service" ]; then
        echo "Service: $service"
        docker-compose logs -f "$service"
    else
        echo "All services (Ctrl+C to exit)"
        docker-compose logs -f
    fi
}

# ============================================================================
# MAILHOG MANAGEMENT  
# ============================================================================
mailhog_start() {
    if [ ! -f "docker-compose.mailhog.yml" ]; then
        print_error "❌ MailHog configuration not found"
        exit 1
    fi
    
    print_info "📧 Starting shared MailHog service..."
    docker-compose -f docker-compose.mailhog.yml up -d
    
    print_success "✅ MailHog started successfully"
    echo "   Access: http://localhost:8025"
}

mailhog_stop() {
    print_info "📧 Stopping shared MailHog service..."
    docker-compose -f docker-compose.mailhog.yml down 2>/dev/null || true
    print_success "✅ MailHog stopped"
}

# ============================================================================
# HELP
# ============================================================================
show_help() {
    echo ""
    print_cyan "🎯 WordPress Project Manager (Simplified)"
    echo ""
    print_info "📖 Usage:"
    echo "   ./project-manager.sh <command> [arguments]"
    echo ""
    print_info "📋 Commands:"
    echo "   start                          Start project containers"
    echo "   stop                           Stop project containers"
    echo "   restart                        Restart project containers"
    echo "   status                         Show project status"
    echo "   logs [service]                 View container logs"
    echo "   mailhog-start                  Start shared MailHog service"
    echo "   mailhog-stop                   Stop shared MailHog service"  
    echo "   help                           Show this help"
    echo ""
    print_info "💡 Setup New Project:"
    echo "   1. Copy repo:      cp -r /path/to/wp-starter ~/my-project"
    echo "   2. Configure:      cd ~/my-project && cp .env.example .env"
    echo "   3. Edit ports:     nano .env"
    echo "   4. Start:          ./scripts/project-manager.sh start"
    echo ""
    print_info "🌐 After Starting:"
    echo "   Website:      http://localhost:<HTTP_PORT>"
    echo "   WordPress:    http://localhost:<HTTP_PORT>/wp/wp-admin/"
    echo "   phpMyAdmin:   http://localhost:<PHPMYADMIN_PORT>"
    echo "   MailHog:      http://localhost:8025 (if started)"
    echo ""
    print_info "🔧 Requirements:"
    echo "   - Docker and Docker Compose installed"
    echo "   - .env file configured with unique ports"
    echo "   - Run from project root directory"
    echo ""
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Parse command
COMMAND="${1:-}"

case "$COMMAND" in
    "start")
        start_project
        ;;
    "stop")
        stop_project
        ;;
    "restart")
        restart_project
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$2"
        ;;
    "mailhog-start")
        mailhog_start
        ;;
    "mailhog-stop")
        mailhog_stop
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        print_error "❌ Unknown command: $COMMAND"
        echo ""
        show_help
        exit 1
        ;;
esac
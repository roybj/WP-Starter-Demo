#!/bin/bash

# ============================================================================
# WordPress Multi-Project Manager for Linux/macOS
# ============================================================================
# Easily manage multiple WordPress development projects
# Usage: ./project-manager.sh [create|start|stop|list|status|help] [args...]

set -e

# Configuration
PROJECTS_BASE_DIR="$HOME/wordpress-projects"
PORTS_FILE="$PROJECTS_BASE_DIR/.port-assignments"
TEMPLATE_REPO="$(pwd)"

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

print_success() {
    print_color "$COLOR_GREEN" "$1"
}

print_error() {
    print_color "$COLOR_RED" "$1"
}

print_warning() {
    print_color "$COLOR_YELLOW" "$1"
}

print_info() {
    print_color "$COLOR_BLUE" "$1"
}

print_cyan() {
    print_color "$COLOR_CYAN" "$1"
}

# Create projects directory if it doesn't exist
create_projects_dir() {
    if [ ! -d "$PROJECTS_BASE_DIR" ]; then
        mkdir -p "$PROJECTS_BASE_DIR"
        print_success "✅ Created projects directory: $PROJECTS_BASE_DIR"
    fi
}

# Check if port is in use
test_port_in_use() {
    local port=$1
    if [ -f "$PORTS_FILE" ]; then
        grep -q ":$port:" "$PORTS_FILE" 2>/dev/null
    else
        return 1
    fi
}

# Find next available port
find_available_port() {
    local start_port=${1:-8080}
    local port=$start_port
    
    while test_port_in_use $port; do
        port=$((port + 10))
        if [ $port -gt 9000 ]; then
            print_error "❌ Error: No available ports found"
            exit 1
        fi
    done
    
    echo $port
}

# ============================================================================
# CREATE NEW PROJECT
# ============================================================================
create_project() {
    local project_name="$1"
    local http_port="$2"
    local description="$3"
    
    if [ -z "$project_name" ]; then
        print_error "❌ Error: Project name is required"
        echo "Usage: ./project-manager.sh create <project-name> <http-port> [description]"
        echo "Example: ./project-manager.sh create client-acme 8080 'ACME Corp Website'"
        exit 1
    fi
    
    # Validate project name
    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "❌ Error: Project name can only contain letters, numbers, hyphens, and underscores"
        exit 1
    fi
    
    # Set default port if not provided
    if [ -z "$http_port" ]; then
        http_port=$(find_available_port 8080)
        print_warning "⚠️  No port specified, using available port: $http_port"
    fi
    
    # Validate port
    if ! [[ "$http_port" =~ ^[0-9]+$ ]] || [ "$http_port" -lt 1000 ] || [ "$http_port" -gt 9999 ]; then
        print_error "❌ Error: Port must be a number between 1000-9999"
        exit 1
    fi
    
    # Check if port is in use
    if test_port_in_use "$http_port"; then
        print_error "❌ Error: Port $http_port is already in use"
        echo "Available ports:"
        find_available_port "$http_port"
        exit 1
    fi
    
    # Set default description
    if [ -z "$description" ]; then
        description="WordPress Development Site"
    fi
    
    create_projects_dir
    
    local project_dir="$PROJECTS_BASE_DIR/$project_name"
    
    # Check if project exists
    if [ -d "$project_dir" ]; then
        print_error "❌ Error: Project '$project_name' already exists"
        exit 1
    fi
    
    print_info "🎯 Creating WordPress project: $project_name"
    echo "   Port: $http_port"
    echo "   Directory: $project_dir"
    echo ""
    
    # Create project directory
    mkdir -p "$project_dir"
    
    # Copy template files
    print_warning "📁 Copying template files..."
    cp -r "$TEMPLATE_REPO"/* "$project_dir"/ 2>/dev/null || true
    cp -r "$TEMPLATE_REPO"/.* "$project_dir"/ 2>/dev/null || true
    
    # Remove unwanted directories
    rm -rf "$project_dir/.git" "$project_dir/docker-data" "$project_dir/node_modules" "$project_dir/vendor" 2>/dev/null || true
    
    # Create .env file
    print_warning "⚙️ Configuring environment..."
    local phpmyadmin_port=$((http_port + 1))
    
    cat > "$project_dir/.env" << EOF
# ============================================================================
# WordPress Project: $project_name
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# ============================================================================

# Project Identity
COMPOSE_PROJECT_NAME=$project_name
PROJECT_DESCRIPTION=$description

# Port Configuration
HTTP_PORT=$http_port
PHPMYADMIN_PORT=$phpmyadmin_port
MAILHOG_WEB_PORT=8025
MAILHOG_SMTP_PORT=1025
MYSQL_PORT=3306
REDIS_PORT=6379

# WordPress Configuration
WP_ENV=development
WP_HOME=http://localhost:$http_port
WP_SITEURL=http://localhost:$http_port/wp
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=true
DISALLOW_FILE_EDIT=true
DISALLOW_FILE_MODS=false
WP_MEMORY_LIMIT=512M

# Database Configuration
DB_NAME=wordpress_dev
DB_USER=wp_user
DB_PASSWORD=wp_secure_password
DB_HOST=mysql
DB_ROOT_PASSWORD=root_secure_password
TABLE_PREFIX=wp_

# Security Keys (Change in production)
AUTH_KEY='$project_name-auth-key-$RANDOM-$RANDOM'
SECURE_AUTH_KEY='$project_name-secure-auth-key-$RANDOM-$RANDOM'
LOGGED_IN_KEY='$project_name-logged-in-key-$RANDOM-$RANDOM'
NONCE_KEY='$project_name-nonce-key-$RANDOM-$RANDOM'
AUTH_SALT='$project_name-auth-salt-$RANDOM-$RANDOM'
SECURE_AUTH_SALT='$project_name-secure-auth-salt-$RANDOM-$RANDOM'
LOGGED_IN_SALT='$project_name-logged-in-salt-$RANDOM-$RANDOM'
NONCE_SALT='$project_name-nonce-salt-$RANDOM-$RANDOM'
EOF

    # Use multi-project docker-compose if available
    if [ -f "$project_dir/config/docker-compose.multi.yml" ]; then
        cp "$project_dir/config/docker-compose.multi.yml" "$project_dir/docker-compose.yml"
    fi

    # Record port assignment
    echo "$project_name:$http_port:$phpmyadmin_port:$description" >> "$PORTS_FILE"

    # Success message
    echo ""
    print_success "✅ Project '$project_name' created successfully"
    echo ""
    print_info "🎯 Project Information:"
    echo "   🌐 Website:      http://localhost:$http_port"
    echo "   🛠️  phpMyAdmin:   http://localhost:$phpmyadmin_port"
    echo "   📧 MailHog:      http://localhost:8025"
    echo "   📁 Directory:    $project_dir"
    echo ""
    print_info "🚀 Next Steps:"
    echo "   1. Start project:  ./project-manager.sh start $project_name"
    echo "   2. Install WP:     Navigate to http://localhost:$http_port"
    echo "   3. Develop:        Edit files in $project_dir"
    echo ""
}

# ============================================================================
# START PROJECT
# ============================================================================
start_project() {
    local project_name="$1"
    
    if [ -z "$project_name" ]; then
        print_error "❌ Error: Project name is required"
        echo "Usage: ./project-manager.sh start <project-name>"
        echo "Example: ./project-manager.sh start client-acme"
        exit 1
    fi

    local project_dir="$PROJECTS_BASE_DIR/$project_name"
    if [ ! -d "$project_dir" ]; then
        print_error "❌ Error: Project '$project_name' not found"
        echo "Available projects:"
        find "$PROJECTS_BASE_DIR" -maxdepth 1 -type d -not -path "$PROJECTS_BASE_DIR" -exec basename {} \; 2>/dev/null | while read -r name; do
            echo "   $name"
        done
        exit 1
    fi

    print_info "🚀 Starting WordPress project: $project_name"
    
    cd "$project_dir"
    
    # Check if containers are already running
    if docker-compose ps | grep -q "Up"; then
        print_warning "⚠️  Project containers are already running"
    else
        docker-compose up -d
    fi
    
    # Get port information
    local http_port=""
    local phpmyadmin_port=""
    if [ -f "$project_dir/.env" ]; then
        http_port=$(grep "HTTP_PORT=" "$project_dir/.env" | cut -d'=' -f2)
        phpmyadmin_port=$(grep "PHPMYADMIN_PORT=" "$project_dir/.env" | cut -d'=' -f2)
    fi
    
    print_success "✅ Project '$project_name' started successfully"
    echo ""
    print_info "🌐 Access URLs:"
    echo "   Website:      http://localhost:${http_port:-8080}"
    echo "   WordPress:    http://localhost:${http_port:-8080}/wp/wp-admin/"
    echo "   phpMyAdmin:   http://localhost:${phpmyadmin_port:-8081}"
    echo "   MailHog:      http://localhost:8025"
    echo "   🔑 WordPress Login: admin/admin"
    echo ""
}

# ============================================================================
# STOP PROJECT
# ============================================================================
stop_project() {
    local project_name="$1"
    
    if [ -z "$project_name" ]; then
        print_error "❌ Error: Project name is required"
        echo "Usage: ./project-manager.sh stop <project-name>"
        exit 1
    fi

    local project_dir="$PROJECTS_BASE_DIR/$project_name"
    if [ ! -d "$project_dir" ]; then
        print_error "❌ Error: Project '$project_name' not found"
        exit 1
    fi

    print_info "🛑 Stopping WordPress project: $project_name"
    
    cd "$project_dir"
    docker-compose down
    
    print_success "✅ Project '$project_name' stopped successfully"
}

# ============================================================================
# LIST PROJECTS
# ============================================================================
list_projects() {
    create_projects_dir
    
    if [ ! -d "$PROJECTS_BASE_DIR" ] || [ -z "$(find "$PROJECTS_BASE_DIR" -maxdepth 1 -type d -not -path "$PROJECTS_BASE_DIR" 2>/dev/null)" ]; then
        print_warning "⚠️  No projects found"
        echo ""
        echo "Create your first project:"
        echo "   ./project-manager.sh create my-project 8080 'My WordPress Site'"
        return
    fi

    print_info "📋 WordPress Projects:"
    echo ""
    
    find "$PROJECTS_BASE_DIR" -maxdepth 1 -type d -not -path "$PROJECTS_BASE_DIR" -exec basename {} \; 2>/dev/null | while read -r project; do
        local project_dir="$PROJECTS_BASE_DIR/$project"
        local status="Stopped"
        local http_port=""
        local description=""
        
        if [ -f "$project_dir/.env" ]; then
            http_port=$(grep "HTTP_PORT=" "$project_dir/.env" | cut -d'=' -f2 2>/dev/null || echo "")
            description=$(grep "PROJECT_DESCRIPTION=" "$project_dir/.env" | cut -d'=' -f2 2>/dev/null || echo "")
        fi
        
        # Check if running
        if [ -d "$project_dir" ]; then
            cd "$project_dir"
            if docker-compose ps 2>/dev/null | grep -q "Up"; then
                status="Running"
            fi
        fi
        
        printf "   %-20s %-10s Port: %-5s %s\n" "$project" "$status" "${http_port:-N/A}" "$description"
    done
    echo ""
}

# ============================================================================
# SHOW STATUS
# ============================================================================
show_status() {
    print_info "🖥️  System Status:"
    echo ""
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "✅ Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')"
    else
        print_error "❌ Docker: Not installed"
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_success "✅ Docker Compose: $(docker-compose --version | cut -d' ' -f3 | tr -d ',')"
    else
        print_error "❌ Docker Compose: Not installed"
    fi
    
    echo ""
    print_info "📁 Projects Directory: $PROJECTS_BASE_DIR"
    
    # Show running containers
    echo ""
    print_info "🐳 Running Containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "   No containers running"
    
    echo ""
}

# ============================================================================
# SHOW PORT ASSIGNMENTS
# ============================================================================
show_ports() {
    print_info "🔌 Port Assignments:"
    echo ""
    
    if [ ! -f "$PORTS_FILE" ]; then
        print_warning "⚠️  No port assignments found"
        return
    fi
    
    printf "   %-20s %-10s %-15s %s\n" "Project" "HTTP" "phpMyAdmin" "Description"
    echo "   ────────────────────────────────────────────────────────────────"
    
    while IFS=: read -r project http_port phpmyadmin_port description; do
        printf "   %-20s %-10s %-15s %s\n" "$project" "$http_port" "$phpmyadmin_port" "$description"
    done < "$PORTS_FILE"
    
    echo ""
}

# ============================================================================
# CLEANUP DOCKER RESOURCES
# ============================================================================
cleanup_docker() {
    print_info "🧹 Cleaning up Docker resources..."
    
    echo "Stopping all WordPress containers..."
    docker stop $(docker ps -q --filter "name=wp-") 2>/dev/null || true
    
    echo "Removing stopped containers..."
    docker container prune -f
    
    echo "Removing unused images..."
    docker image prune -f
    
    echo "Removing unused volumes..."
    docker volume prune -f
    
    echo "Removing unused networks..."
    docker network prune -f
    
    print_success "✅ Docker cleanup completed"
}

# ============================================================================
# HELP
# ============================================================================
show_help() {
    echo ""
    print_cyan "🎯 WordPress Multi-Project Manager (Bash)"
    echo ""
    print_info "📖 Usage:"
    echo "   ./project-manager.sh <command> [arguments]"
    echo ""
    print_info "📋 Commands:"
    echo "   create <name> [port] [desc]    Create new WordPress project"
    echo "   start <name>                   Start existing project"  
    echo "   stop <name>                    Stop running project"
    echo "   list                           List all projects"
    echo "   status                         Show system status"
    echo "   ports                          Show port assignments"
    echo "   clean                          Clean Docker resources"
    echo "   help                           Show this help"
    echo ""
    print_info "💡 Examples:"
    echo '   ./project-manager.sh create client-acme 8080 "ACME Website"'
    echo "   ./project-manager.sh start client-acme"
    echo "   ./project-manager.sh stop client-acme"
    echo "   ./project-manager.sh list"
    echo ""
    print_info "🌐 Access URLs (after starting):"
    echo "   Website:      http://localhost:<port>"
    echo "   phpMyAdmin:   http://localhost:<port+1>"
    echo "   MailHog:      http://localhost:8025"
    echo ""
    print_info "📁 Projects Directory:"
    echo "   $PROJECTS_BASE_DIR"
    echo ""
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Parse command
COMMAND="${1:-}"

if [ -z "$COMMAND" ]; then
    show_help
    exit 0
fi

# Route to appropriate function
case "$COMMAND" in
    "create")
        create_project "$2" "$3" "$4"
        ;;
    "start")
        start_project "$2"
        ;;
    "stop")
        stop_project "$2"
        ;;
    "list")
        list_projects
        ;;
    "status")
        show_status
        ;;
    "ports")
        show_ports
        ;;
    "clean")
        cleanup_docker
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "❌ Unknown command: $COMMAND"
        echo ""
        show_help
        exit 1
        ;;
esac
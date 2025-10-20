#!/bin/bash

# ============================================================================
# WordPress WP Starter - Developer Setup Script
# ============================================================================
# This script automates the initial setup for developers
# Run from project root: bash setup-dev.sh
# ============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed"
        return 1
    fi
    print_success "$1 found"
    return 0
}

# ============================================================================
# MAIN SETUP
# ============================================================================

print_header "WordPress WP Starter - Developer Setup"

# 1. Check Prerequisites
print_header "Checking Prerequisites"

echo "Checking required tools..."
check_command docker || exit 1
check_command docker-compose || exit 1
check_command git || exit 1

# 2. Check if already initialized
print_header "Checking Project Status"

if [ -f ".env" ]; then
    print_warning ".env file already exists - skipping environment setup"
    read -p "Do you want to regenerate .env? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm .env
    fi
fi

# 3. Setup .env file
if [ ! -f ".env" ]; then
    print_header "Setting up Environment Configuration"
    
    if [ ! -f ".env.example" ]; then
        print_error ".env.example not found!"
        exit 1
    fi
    
    cp .env.example .env
    print_success ".env created from template"
    print_warning "Review .env and update if needed"
    echo "Editor: nano .env"
fi

# 4. Check Docker resources
print_header "Checking Docker Resources"

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker daemon is not running!"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

print_success "Docker daemon is running"

# Check available memory
DOCKER_MEMORY=$(docker info --format '{{.MemTotal}}' 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "unknown")
echo "Docker memory: $DOCKER_MEMORY"

if [ "$DOCKER_MEMORY" = "unknown" ]; then
    print_warning "Could not determine Docker memory - ensure 4GB+ is allocated"
fi

# 5. Pull latest images (optional)
print_header "Preparing Docker Images"

read -p "Do you want to pull latest Docker images? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Pulling images..."
    docker-compose pull
    print_success "Images pulled"
else
    print_warning "Skipping image pull - using cached images"
fi

# 6. Build containers
print_header "Building Docker Containers"

echo "Building containers (this may take 2-3 minutes on first run)..."
docker-compose build --no-cache wordpress

print_success "Containers built"

# 7. Start services
print_header "Starting Services"

echo "Starting Docker services..."
docker-compose up -d

print_success "Services started"

# Wait for WordPress container to be ready
echo -e "\nWaiting for services to initialize (this may take 1-2 minutes)..."
RETRY=0
MAX_RETRY=30
while [ $RETRY -lt $MAX_RETRY ]; do
    if docker-compose exec -T wordpress php -v > /dev/null 2>&1; then
        print_success "WordPress container is ready"
        break
    fi
    RETRY=$((RETRY + 1))
    echo -n "."
    sleep 2
done

if [ $RETRY -eq $MAX_RETRY ]; then
    print_warning "WordPress container initialization timed out"
    echo "Check logs with: docker-compose logs wordpress"
fi

# 8. Install Composer dependencies
print_header "Installing Composer Dependencies"

echo "Installing PHP dependencies..."
docker-compose exec -T wordpress composer install

if [ $? -eq 0 ]; then
    print_success "Composer dependencies installed"
else
    print_error "Composer installation failed"
    echo "Try manually: docker-compose exec wordpress composer install"
fi

# 9. Verify WordPress installation
print_header "Verifying WordPress Installation"

docker-compose exec -T wordpress wp --info > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_success "WordPress is installed and configured"
    
    # Check if database is initialized
    docker-compose exec -T wordpress wp core is-installed > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_success "WordPress database is initialized"
    else
        print_warning "WordPress database not yet initialized"
        echo "Complete WordPress setup at: http://localhost:8080/wp/wp-admin/install.php"
    fi
else
    print_warning "WordPress verification skipped"
fi

# 10. Summary
print_header "Setup Complete!"

echo "Your development environment is ready!"
echo ""
echo -e "${BLUE}Access Your Services:${NC}"
echo -e "  Website:   ${GREEN}http://localhost:8080${NC}"
echo -e "  WP Admin:  ${GREEN}http://localhost:8080/wp/wp-admin${NC}"
echo -e "  phpMyAdmin: ${GREEN}http://localhost:8081${NC}"
echo -e "  MailHog:   ${GREEN}http://localhost:8025${NC}"
echo ""
echo -e "${BLUE}Common Commands:${NC}"
echo -e "  make help              ${YELLOW}# Show all available commands${NC}"
echo -e "  make logs              ${YELLOW}# View container logs${NC}"
echo -e "  make shell             ${YELLOW}# Access WordPress container${NC}"
echo -e "  docker-compose ps      ${YELLOW}# View container status${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Complete WordPress installation at http://localhost:8080/wp/wp-admin/install.php"
echo "  2. Review README.md for development workflow"
echo "  3. Start developing! Happy coding!"
echo ""
echo -e "${BLUE}Stop Services:${NC}"
echo "  docker-compose down       ${YELLOW}# Stop services (data preserved)${NC}"
echo "  docker-compose down -v    ${YELLOW}# Stop and remove all data${NC}"
echo ""

print_success "Setup completed successfully!"

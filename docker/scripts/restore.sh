#!/bin/bash

# Restore Script for WordPress Docker Environment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
BACKUP_DIR="$PROJECT_DIR/backups"

if [ $# -eq 0 ]; then
    echo "❌ Usage: $0 <backup_file>"
    echo "Available backups:"
    ls -1t "$BACKUP_DIR"/wp_backup_*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ] && [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Use full path if relative path provided
if [ ! -f "$BACKUP_FILE" ] && [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
fi

echo "🔄 Restoring WordPress from: $BACKUP_FILE"

# Confirm restoration
read -p "⚠️  This will overwrite current data. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Restore cancelled"
    exit 1
fi

cd "$PROJECT_DIR"

# Create temporary extraction directory
TEMP_DIR="restore_tmp_$(date +%s)"
mkdir -p "$TEMP_DIR"

echo "📦 Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "🚀 Starting Docker containers..."
    docker-compose up -d
    
    # Wait for MySQL to be ready
    echo "⏳ Waiting for MySQL..."
    until docker-compose exec mysql mysqladmin ping -h localhost -u root -proot_secure_password --silent; do
        sleep 2
    done
fi

# Restore database if present
if [ -f "$TEMP_DIR/database.sql" ]; then
    echo "🗄️  Restoring database..."
    
    # Create backup of current database
    echo "💾 Creating backup of current database..."
    docker-compose exec mysql mysqldump \
        -u wp_user \
        -pwp_secure_password \
        wordpress_dev > "current_db_backup_$(date +%s).sql" || true
    
    # Import database
    docker-compose exec -T mysql mysql \
        -u wp_user \
        -pwp_secure_password \
        wordpress_dev < "$TEMP_DIR/database.sql"
    
    echo "✅ Database restored"
fi

# Restore files
if [ -d "$TEMP_DIR/wp-content" ]; then
    echo "📁 Restoring wp-content..."
    
    # Backup current wp-content
    if [ -d "wp-content" ]; then
        mv wp-content "wp-content.backup.$(date +%s)" || true
    fi
    
    # Restore wp-content
    cp -r "$TEMP_DIR/wp-content" .
    
    # Set proper permissions
    docker-compose exec wordpress chown -R www-data:www-data /var/www/html/wp-content
    docker-compose exec wordpress chmod -R 755 /var/www/html/wp-content
    docker-compose exec wordpress chmod -R 775 /var/www/html/wp-content/uploads
    
    echo "✅ Files restored"
fi

# Restore environment file
if [ -f "$TEMP_DIR/.env" ]; then
    echo "⚙️  Restoring environment configuration..."
    cp "$TEMP_DIR/.env" .env.restored
    echo "💡 Environment saved as .env.restored (review before replacing .env)"
fi

# Restore Docker configuration
if [ -d "$TEMP_DIR/docker" ]; then
    echo "🐳 Docker configuration found in backup"
    echo "💡 Review $TEMP_DIR/docker for any custom configurations"
fi

# Cleanup
rm -rf "$TEMP_DIR"

# Flush WordPress caches
echo "🧹 Flushing WordPress caches..."
docker-compose run --rm wpcli cache flush || true
docker-compose run --rm wpcli rewrite flush || true

# Show restore info
if [ -f "backup_info.txt" ]; then
    echo ""
    echo "📊 Backup Information:"
    cat backup_info.txt
    rm backup_info.txt
fi

echo ""
echo "✅ Restore completed successfully!"
echo "🔗 WordPress: http://localhost:8080"
echo "🔗 Admin: http://localhost:8080/wp/wp-admin/"
echo ""
echo "💡 If you encounter issues:"
echo "   - Check .env.restored for environment differences"
echo "   - Run: docker-compose restart"
echo "   - Check logs: docker-compose logs wordpress"
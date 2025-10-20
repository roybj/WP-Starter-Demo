#!/bin/bash

# Backup Script for WordPress Docker Environment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="wp_backup_$TIMESTAMP"

echo "🗄️  Creating WordPress backup: $BACKUP_NAME"

# Create backup directory
mkdir -p "$BACKUP_DIR"
cd "$PROJECT_DIR"

# Create temporary directory
TEMP_DIR="$BACKUP_DIR/tmp_$TIMESTAMP"
mkdir -p "$TEMP_DIR"

echo "📊 Exporting database..."
# Export database
docker-compose exec mysql mysqldump \
    -u wp_user \
    -pwp_secure_password \
    --single-transaction \
    --routines \
    --triggers \
    wordpress_dev > "$TEMP_DIR/database.sql"

echo "📁 Copying files..."
# Copy important files
cp -r wp-content "$TEMP_DIR/" 2>/dev/null || true
cp .env "$TEMP_DIR/" 2>/dev/null || true
cp .env.docker "$TEMP_DIR/" 2>/dev/null || true
cp composer.json "$TEMP_DIR/"
cp composer.lock "$TEMP_DIR/" 2>/dev/null || true

# Copy custom configuration files
cp -r docker "$TEMP_DIR/" 2>/dev/null || true

# Create info file
cat > "$TEMP_DIR/backup_info.txt" << EOF
WordPress Docker Backup
Date: $(date)
Environment: development
Database: wordpress_dev
WordPress Version: $(docker-compose run --rm wpcli core version 2>/dev/null || echo "Unknown")
EOF

echo "📦 Creating archive..."
# Create compressed archive
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" -C "tmp_$TIMESTAMP" .

# Cleanup temporary directory
rm -rf "tmp_$TIMESTAMP"

echo "✅ Backup completed: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "📊 Backup size: $(du -h "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" | cut -f1)"

# Keep only last 5 backups
cd "$BACKUP_DIR"
ls -1t wp_backup_*.tar.gz | tail -n +6 | xargs -r rm --

echo "🧹 Cleaned old backups (keeping 5 most recent)"
#!/bin/bash

# WordPress Docker Startup Script
set -euo pipefail

echo "🚀 Starting WordPress Development Environment..."

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
until mysqladmin ping -h mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root_secure_password}" --skip-ssl --silent; do
    echo "MySQL not ready yet, waiting..."
    sleep 2
done
echo "✅ MySQL is ready!"

# Create .env file if it doesn't exist
if [ ! -f "/var/www/html/.env" ]; then
    echo "📝 Creating .env file from .env.example..."
    if [ -f "/var/www/html/.env.example" ]; then
        cp /var/www/html/.env.example /var/www/html/.env
        # Update with Docker environment values
        sed -i "s|DB_HOST=localhost|DB_HOST=${DB_HOST:-mysql}|g" /var/www/html/.env
        sed -i "s|DB_NAME=wp_database_name|DB_NAME=${DB_NAME:-wordpress_dev}|g" /var/www/html/.env
        sed -i "s|DB_USER=wp_user|DB_USER=${DB_USER:-wp_user}|g" /var/www/html/.env
        sed -i "s|DB_PASSWORD=your_secure_database_password|DB_PASSWORD=${DB_PASSWORD:-wp_secure_password}|g" /var/www/html/.env
        sed -i "s|WP_HOME=https://your-domain.com|WP_HOME=${WP_HOME:-http://localhost:8080}|g" /var/www/html/.env
        sed -i "s|WP_SITEURL=https://your-domain.com/wp|WP_SITEURL=${WP_SITEURL:-http://localhost:8080/wp}|g" /var/www/html/.env
        sed -i "s|WP_ENV=development|WP_ENV=${WP_ENV:-development}|g" /var/www/html/.env
        echo "✅ .env file created and configured for Docker"
    else
        echo "⚠️  .env.example not found, creating basic .env..."
        cat > /var/www/html/.env << EOF
WP_ENV=${WP_ENV:-development}
DB_NAME=${DB_NAME:-wordpress_dev}
DB_USER=${DB_USER:-wp_user}
DB_PASSWORD=${DB_PASSWORD:-wp_secure_password}
DB_HOST=${DB_HOST:-mysql}
TABLE_PREFIX=${TABLE_PREFIX:-wp_}
WP_HOME=${WP_HOME:-http://localhost:8080}
WP_SITEURL=${WP_SITEURL:-http://localhost:8080/wp}
WP_DEBUG=${WP_DEBUG:-true}
WP_DEBUG_LOG=${WP_DEBUG_LOG:-true}
WP_DEBUG_DISPLAY=${WP_DEBUG_DISPLAY:-true}
DISALLOW_FILE_EDIT=${DISALLOW_FILE_EDIT:-true}
DISALLOW_FILE_MODS=${DISALLOW_FILE_MODS:-false}
WP_MEMORY_LIMIT=${WP_MEMORY_LIMIT:-512M}
AUTH_KEY='${AUTH_KEY:-dev-auth-key-change-in-production}'
SECURE_AUTH_KEY='${SECURE_AUTH_KEY:-dev-secure-auth-key-change-in-production}'
LOGGED_IN_KEY='${LOGGED_IN_KEY:-dev-logged-in-key-change-in-production}'
NONCE_KEY='${NONCE_KEY:-dev-nonce-key-change-in-production}'
AUTH_SALT='${AUTH_SALT:-dev-auth-salt-change-in-production}'
SECURE_AUTH_SALT='${SECURE_AUTH_SALT:-dev-secure-auth-salt-change-in-production}'
LOGGED_IN_SALT='${LOGGED_IN_SALT:-dev-logged-in-salt-change-in-production}'
NONCE_SALT='${NONCE_SALT:-dev-nonce-salt-change-in-production}'
EOF
        echo "✅ Basic .env file created"
    fi
fi

# Install Composer dependencies if vendor directory doesn't exist
if [ ! -d "/var/www/html/vendor" ]; then
    echo "📦 Installing Composer dependencies..."
    cd /var/www/html
    composer install --no-interaction --prefer-dist --optimize-autoloader
    echo "✅ Composer dependencies installed"
fi

# Create WordPress directory structure if it doesn't exist
if [ ! -d "/var/www/html/wp" ]; then
    echo "🔧 WordPress core not found, running Composer to install..."
    cd /var/www/html
    composer install --no-interaction
    echo "✅ WordPress core installed"
fi

# Create wp-content directories
mkdir -p /var/www/html/wp-content/themes
mkdir -p /var/www/html/wp-content/plugins
mkdir -p /var/www/html/wp-content/mu-plugins
mkdir -p /var/www/html/wp-content/uploads

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/wp-content/uploads

# Wait a bit for MySQL to be fully ready
sleep 3

# Check if WordPress is already installed
cd /var/www/html
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "🔧 WordPress not installed, running installation..."
    
    # Install WordPress
    wp core install \
        --url="${WP_HOME:-http://localhost:8080}" \
        --title="${WP_TITLE:-WordPress Development Site}" \
        --admin_user="${WP_ADMIN_USER:-admin}" \
        --admin_password="${WP_ADMIN_PASSWORD:-admin}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@localhost.dev}" \
        --allow-root \
        --skip-email
    
    echo "✅ WordPress installed successfully!"
    echo "🔑 Admin credentials: admin/admin"
    
    # Install and activate development plugins
    # echo "📦 Installing development plugins..."
    
    # Query Monitor for debugging
    # wp plugin install query-monitor --activate --allow-root || true
    
    # Redis Object Cache (if redis is available)
    # wp plugin install redis-cache --activate --allow-root || true
    
    # Enable Redis object cache
    # wp redis enable --allow-root || echo "⚠️  Redis cache not enabled (plugin may not be available)"
    
    # echo "✅ Development plugins installed"
    
    # Set up development theme
    wp theme install twentytwentyfour --activate --allow-root || true
    
    # Create sample content
    wp post create --post_type=page --post_title="Home" --post_status=publish --post_content="<h1>Welcome to WordPress Development</h1><p>Your development environment is ready!</p>" --allow-root || true
    wp post create --post_type=page --post_title="About" --post_status=publish --post_content="<h1>About This Site</h1><p>This is a development environment.</p>" --allow-root || true
    
    # Set front page
    HOMEPAGE_ID=$(wp post list --post_type=page --post_title="Home" --format=ids --allow-root)
    if [ ! -z "$HOMEPAGE_ID" ]; then
        wp option update page_on_front $HOMEPAGE_ID --allow-root
        wp option update show_on_front page --allow-root
    fi
    
    # Update permalink structure
    wp rewrite structure '/%postname%/' --hard --allow-root
    
    echo "✅ WordPress setup completed!"
else
    echo "✅ WordPress already installed"
fi

# Display environment information
echo ""
echo "🎉 WordPress Development Environment Ready!"
echo "📍 WordPress Site: ${WP_HOME:-http://localhost:8080}"
echo "📍 WordPress Admin: ${WP_HOME:-http://localhost:8080}/wp/wp-admin/"
echo "📍 phpMyAdmin: http://localhost:${PHPMYADMIN_PORT:-8081}"
echo "📍 MailHog: http://localhost:${MAILHOG_WEB_PORT:-8025}"
echo "🔑 WordPress Admin: ${WP_ADMIN_USER:-admin}/${WP_ADMIN_PASSWORD:-admin}"
echo "🗄️  Database: ${DB_HOST:-mysql}:${MYSQL_PORT:-3306} (${DB_USER:-wp_user}/${DB_PASSWORD:-wp_secure_password})"
echo ""

# Start PHP-FPM in foreground
echo "🚀 Starting PHP-FPM..."
exec php-fpm
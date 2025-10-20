# WordPress Docker Development Environment

This Docker Compose setup provides a complete local development environment that mirrors the production CloudPanel setup.

## 🏗️ Architecture Overview

The Docker environment includes:
- **Nginx** web server (matches CloudPanel production environment)
- **WordPress/PHP-FPM 8.2** (main application in FPM mode)
- **MySQL 8.0** database server
- **Redis** for object caching
- **phpMyAdmin** for database management
- **MailHog** for email testing
- **WP-CLI** for WordPress management
- **Node.js** for asset building

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed
- Docker Compose v2+
- At least 4GB RAM allocated to Docker

### 1. Start the Environment
```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd BB-WP_Template

# Start all services
docker-compose up -d

# Watch logs (optional)
docker-compose logs -f wordpress
```

### 2. Access Your Development Site
- **WordPress Site**: http://localhost:8080
- **WordPress Admin**: http://localhost:8080/wp/wp-admin/ (admin/admin)
- **phpMyAdmin**: http://localhost:8081
- **MailHog**: http://localhost:8025 (email testing)

### 3. Stop the Environment
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (complete reset)
docker-compose down -v
```

## 📁 Directory Structure (Docker)

```
project-root/
├── docker-compose.yml           # Main orchestration file
├── .env.docker                  # Docker environment template
├── docker/
│   ├── Dockerfile.wordpress     # WordPress/PHP container
│   ├── Dockerfile.wpcli         # WP-CLI container
│   ├── apache/
│   │   └── wordpress.conf       # Apache virtual host
│   ├── php/
│   │   └── php.ini              # PHP configuration
│   ├── mysql/
│   │   ├── conf.d/
│   │   │   └── wordpress.cnf    # MySQL configuration
│   │   └── init/
│   │       └── 01-init-wordpress.sql # Database initialization
│   ├── redis/
│   │   └── redis.conf           # Redis configuration
│   └── scripts/
│       └── start.sh             # WordPress startup script
├── wp/                          # WordPress core (auto-generated)
├── wp-content/                  # Your themes, plugins, uploads
├── vendor/                      # Composer dependencies
└── .env                         # Environment configuration
```

## 🔧 Development Workflow

### Installing Dependencies
```bash
# Install Composer dependencies
docker-compose exec wordpress composer install

# Install Node dependencies (if using theme building)
docker-compose run nodejs npm install

# Build theme assets
docker-compose run nodejs npm run build
```

### WordPress Management
```bash
# Use WP-CLI
docker-compose run wpcli --info
docker-compose run wpcli plugin list
docker-compose run wpcli theme list

# Install plugins
docker-compose run wpcli plugin install advanced-custom-fields --activate

# Database operations
docker-compose run wpcli db export backup.sql
docker-compose run wpcli db import backup.sql

# Update WordPress
docker-compose run wpcli core update
```

### Database Management
```bash
# Access MySQL directly
docker-compose exec mysql mysql -u wp_user -pwp_secure_password wordpress_dev

# Backup database
docker-compose exec mysql mysqldump -u wp_user -pwp_secure_password wordpress_dev > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u wp_user -pwp_secure_password wordpress_dev < backup.sql
```

### File Operations
```bash
# Access container shell
docker-compose exec wordpress bash

# View logs
docker-compose logs wordpress
docker-compose logs mysql
docker-compose logs redis
```

## ⚙️ Configuration

### Environment Variables
The Docker environment uses `.env` for configuration. Key variables:

```bash
# Database
DB_HOST=mysql
DB_NAME=wordpress_dev
DB_USER=wp_user
DB_PASSWORD=wp_secure_password

# URLs
WP_HOME=http://localhost:8080
WP_SITEURL=http://localhost:8080/wp

# Cache
WP_REDIS_HOST=redis
WP_REDIS_PORT=6379

# Email (MailHog)
SMTP_HOST=mailhog
SMTP_PORT=1025
```

### Custom Configuration
Create `.env.local` to override default settings:
```bash
# Copy Docker template
cp .env.docker .env.local

# Edit as needed
nano .env.local
```

## 🔌 Services

### WordPress/PHP Container
- **PHP 8.2** with all necessary extensions
- **Apache** with mod_rewrite enabled
- **Composer** for dependency management
- **WP-CLI** for WordPress management
- **Node.js** for asset building

### MySQL Container
- **MySQL 8.0** with WordPress optimizations
- **Persistent storage** via Docker volumes
- **Performance tuning** for development
- **Automatic initialization** with WordPress schema

### Redis Container
- **Redis 7** for object caching
- **Optimized configuration** for WordPress
- **Persistent storage** between restarts

### Support Services
- **phpMyAdmin**: Database management GUI
- **MailHog**: Email testing and debugging
- **WP-CLI**: Dedicated container for WordPress CLI operations

## 🎛️ Port Mapping

| Service | Internal Port | External Port | URL |
|---------|---------------|---------------|-----|
| WordPress | 80 | 8080 | http://localhost:8080 |
| MySQL | 3306 | 3306 | localhost:3306 |
| Redis | 6379 | 6379 | localhost:6379 |
| phpMyAdmin | 80 | 8081 | http://localhost:8081 |
| MailHog SMTP | 1025 | 1025 | localhost:1025 |
| MailHog Web | 8025 | 8025 | http://localhost:8025 |

## 🔍 Debugging

### Enable Xdebug
Add to your `.env.local`:
```bash
XDEBUG_MODE=debug
XDEBUG_CLIENT_HOST=host.docker.internal
XDEBUG_CLIENT_PORT=9003
```

### View Logs
```bash
# WordPress/PHP errors
docker-compose logs wordpress

# MySQL errors
docker-compose logs mysql

# Apache access logs
docker-compose exec wordpress tail -f /var/log/apache2/access.log

# WordPress debug log
docker-compose exec wordpress tail -f /var/www/html/wp-content/debug.log
```

### Performance Monitoring
- **Query Monitor**: Pre-installed plugin for debugging
- **Redis Object Cache**: Pre-configured for performance
- **MySQL slow query log**: Enabled in development

## 🧪 Testing

### Running Tests
```bash
# PHPUnit tests (if configured)
docker-compose exec wordpress vendor/bin/phpunit

# WordPress unit tests
docker-compose run wpcli db create wordpress_test
docker-compose exec wordpress bash -c "cd wp-content/plugins/your-plugin && phpunit"
```

### Database Testing
```bash
# Create test database
docker-compose run wpcli db create wordpress_test

# Run database migrations
docker-compose run wpcli db import test-data.sql --database=wordpress_test
```

## 🚀 Production Parity

This Docker environment mirrors the production CloudPanel setup:

### Similarities
- **PHP 8.2** with same extensions
- **MySQL 8.0** with WordPress optimizations
- **Apache** web server configuration
- **WP Starter** project structure
- **Composer** dependency management
- **Redis** object caching

### Development Enhancements
- **MailHog** for email testing
- **phpMyAdmin** for database management
- **Xdebug** support for debugging
- **Query Monitor** for performance analysis
- **Hot reloading** for file changes

## 🛠️ Customization

### Adding Services
Edit `docker-compose.yml` to add services:
```yaml
  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"
    networks:
      - wp-network
```

### Custom PHP Configuration
Edit `docker/php/php.ini` and rebuild:
```bash
docker-compose build wordpress
docker-compose up -d wordpress
```

### Custom MySQL Configuration
Edit `docker/mysql/conf.d/wordpress.cnf` and restart:
```bash
docker-compose restart mysql
```

## 📦 Backup & Restore

### Full Environment Backup
```bash
# Create backup script
./docker/scripts/backup.sh

# This will backup:
# - Database dump
# - wp-content directory
# - .env configuration
```

### Restore Environment
```bash
# Restore from backup
./docker/scripts/restore.sh backup-2024-01-01.tar.gz
```

## 🔧 Troubleshooting

### Common Issues

**WordPress not loading:**
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs wordpress

# Restart services
docker-compose restart
```

**Database connection error:**
```bash
# Check MySQL status
docker-compose logs mysql

# Verify credentials in .env
grep DB_ .env

# Test connection
docker-compose exec wordpress wp db check --allow-root
```

**Permission issues:**
```bash
# Fix file permissions
docker-compose exec wordpress chown -R www-data:www-data /var/www/html
docker-compose exec wordpress chmod -R 755 /var/www/html
```

**Redis not working:**
```bash
# Check Redis status
docker-compose logs redis

# Test Redis connection
docker-compose exec redis redis-cli ping

# Enable object cache
docker-compose run wpcli redis enable --allow-root
```

### Performance Issues

**Slow loading:**
- Increase Docker Desktop memory allocation
- Enable Redis object caching
- Check MySQL slow query log

**File sync issues:**
- Use Docker's built-in file watching
- Avoid running on network drives
- Use native file system (not WSL2 for Windows)

## 🎯 Production Deployment

When ready to deploy to production CloudPanel:

1. **Test locally** with this Docker environment
2. **Run production build**: `composer install --no-dev --optimize-autoloader`
3. **Push to repository** and trigger Bitbucket Pipelines
4. **Use migration pipelines** for database/uploads sync

The Docker environment ensures your local development matches production behavior exactly.

---

**Happy developing! 🎉**
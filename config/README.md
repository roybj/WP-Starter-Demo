# Configuration Templates

This directory contains all configuration templates and environment files for the WordPress development environment.

## 📁 Configuration Files

### Environment Templates

| File | Purpose | Usage |
|------|---------|--------|
| **.env.example** | Single project template | `cp config/.env.example .env` |
| **.env.multi-project** | Multi-project template | Used by project-manager scripts |
| **.env.production.example** | Production deployment reference | Copy and customize for production |

### Docker Configuration

| File | Purpose | Usage |
|------|---------|--------|
| **docker-compose.multi.yml** | Multi-project Docker template | Used automatically by project-manager |

## ⚙️ Environment Configuration

### Single Project Setup

For traditional single WordPress site:

```bash
# Copy the template
cp config/.env.example .env

# Customize if needed (optional)
# Default values work for most local development
```

### Multi-Project Setup

Managed automatically by project-manager scripts:

```powershell
# Project manager handles all configuration
scripts\project-manager.ps1 create my-project 8080 "My Project"
# Creates project-specific .env with unique:
# - Database credentials  
# - Security keys
# - Port assignments
# - Project isolation
```

## 🔧 Configuration Options

### Key Environment Variables

#### Project Identity
```env
COMPOSE_PROJECT_NAME=my-project        # Unique project identifier
PROJECT_DESCRIPTION="My WordPress Site" # Human-readable description
```

#### Port Configuration
```env
HTTP_PORT=8080                # WordPress web interface
PHPMYADMIN_PORT=8081         # Database management interface  
MAILHOG_WEB_PORT=8025        # Email testing interface
MYSQL_PORT=3306              # Database port (usually keep default)
REDIS_PORT=6379              # Cache port (usually keep default)
```

#### WordPress Configuration
```env
WP_ENV=development           # Environment (development/staging/production)
WP_HOME=http://localhost:8080      # Site URL
WP_SITEURL=http://localhost:8080/wp # WordPress admin URL
DB_NAME=wordpress_dev        # Database name
DB_USER=wp_user             # Database username
DB_PASSWORD=secure_password  # Database password
```

#### Development Settings
```env
WP_DEBUG=true               # Enable WordPress debugging
WP_DEBUG_LOG=true          # Log errors to file
WP_DEBUG_DISPLAY=false     # Don't display errors on screen
DISALLOW_FILE_MODS=false   # Allow plugin/theme installation
```

### Security Configuration

#### WordPress Security Keys
Generate unique keys for each project:
```bash
# Visit: https://api.wordpress.org/secret-key/1.1/salt/
# Copy generated keys to .env file:

AUTH_KEY='your-unique-key-here'
SECURE_AUTH_KEY='your-unique-key-here'  
LOGGED_IN_KEY='your-unique-key-here'
NONCE_KEY='your-unique-key-here'
# ... etc
```

#### Database Security
```env
MYSQL_ROOT_PASSWORD=root_secure_password  # MySQL root password
DB_PASSWORD=project_secure_password       # WordPress database password
```

## 🚀 Best Practices

### 🔒 Security
- ✅ **Never commit .env files** to version control
- ✅ **Use unique passwords** for each project  
- ✅ **Generate unique security keys** per project
- ✅ **Use strong passwords** in production

### 📊 Organization
- ✅ **Consistent naming**: Use kebab-case for project names
- ✅ **Port ranges**: Assign port ranges by project type
- ✅ **Documentation**: Comment complex configurations
- ✅ **Validation**: Test configurations before deployment

### 🎯 Development
- ✅ **Local domains**: Consider using .local domains for projects
- ✅ **Environment parity**: Keep dev/staging/production similar
- ✅ **Performance**: Optimize for your development machine specs
- ✅ **Debugging**: Enable appropriate debug settings per environment

## 📋 Port Management Strategy

### Recommended Port Ranges

| Project Type | HTTP Ports | phpMyAdmin | Description |
|-------------|------------|------------|-------------|
| **Client Projects** | 8080-8199 | 8081-8200 | Client work, demos |
| **Personal Projects** | 8200-8299 | 8201-8300 | Personal sites, blogs |  
| **Experiments** | 8300-8399 | 8301-8400 | Testing, R&D |
| **Team Projects** | 8400-8499 | 8401-8500 | Collaborative work |

### Example Configuration
```env
# Client project example
COMPOSE_PROJECT_NAME=client-acme
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
PROJECT_DESCRIPTION="ACME Corp Website Redesign"

# Personal project example  
COMPOSE_PROJECT_NAME=personal-blog
HTTP_PORT=8200
PHPMYADMIN_PORT=8201
PROJECT_DESCRIPTION="My Personal WordPress Blog"
```

## 🔄 Migration & Updates

### Updating Configuration
```bash
# Backup existing config
cp .env .env.backup

# Update with new template
cp config/.env.example .env.new
# Merge your customizations from .env.backup

# For multi-project setups
scripts\project-manager.ps1 list  # Check current projects
# Individual project configs are updated automatically
```

### Production Deployment
```bash
# Use production template as starting point
cp config/.env.production.example .env.production

# Customize for your production environment:
# - Set WP_ENV=production
# - Use production URLs  
# - Set strong passwords
# - Disable debug settings
# - Configure production database
```

## 📚 Related Documentation

- **Setup Guides**: [../docs/setup/](../docs/setup/)
- **Multi-Project Workflows**: [../docs/guides/multi-project-workflows.md](../docs/guides/multi-project-workflows.md)
- **Docker Configuration**: [../docs/guides/docker-guide.md](../docs/guides/docker-guide.md)
- **Contributing**: [../docs/guides/contributing.md](../docs/guides/contributing.md)

## 🆘 Troubleshooting

### Configuration Issues

**Environment not loading:**
- Check file location: `.env` must be in project root
- Verify syntax: No spaces around `=` signs
- Check permissions: File must be readable

**Port conflicts:**
- Use different ports: Change `HTTP_PORT` and `PHPMYADMIN_PORT`
- Check what's running: `netstat -ano | findstr :8080`
- Use project manager: `scripts\project-manager.ps1 ports`

**Database connection fails:**
- Verify credentials in `.env`
- Check container status: `docker-compose ps`
- Review logs: `docker-compose logs mysql`

---

**🎯 Use multi-project setup for automatic configuration management!**
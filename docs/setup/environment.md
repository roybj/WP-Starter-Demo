# 🔧 Environment Configuration

> **Essential guide for configuring .env files and managing ports across multiple projects**

## 📋 Overview

Each WordPress project requires its own `.env` file with **unique ports** to avoid conflicts. This guide shows you how to configure projects properly.

## 🚀 Quick Setup

### 1. Copy Environment Template
```bash
# In your new project directory
cp .env.example .env
```

### 2. Edit Configuration
```bash
# Linux/macOS
nano .env

# Windows  
notepad .env
```

### 3. Set Unique Ports
Each project **must have different ports**:

```bash
# Project 1: Client Website
COMPOSE_PROJECT_NAME=client-website
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
MYSQL_PORT=3306
REDIS_PORT=6379

# Project 2: Personal Blog
COMPOSE_PROJECT_NAME=personal-blog  
HTTP_PORT=8090
PHPMYADMIN_PORT=8091
MYSQL_PORT=3316
REDIS_PORT=6389
```

## 🔌 Port Management Strategy

### **Recommended Port Ranges**

| Service | Range | Increment | Example |
|---------|-------|-----------|---------|
| **HTTP** | 8080-8990 | +10 | 8080, 8090, 8100 |
| **phpMyAdmin** | HTTP + 1 | +10 | 8081, 8091, 8101 |
| **MySQL** | 3306-3996 | +10 | 3306, 3316, 3326 |
| **Redis** | 6379-6979 | +10 | 6379, 6389, 6399 |

### **Port Calculation Formula**
```bash
# For project N (0, 1, 2, ...):
HTTP_PORT = 8080 + (N * 10)
PHPMYADMIN_PORT = HTTP_PORT + 1  
MYSQL_PORT = 3306 + (N * 10)
REDIS_PORT = 6379 + (N * 10)
```

## ⚙️ Complete .env Configuration

### **Essential Settings**
```bash
# Project Identity (CHANGE THIS!)
COMPOSE_PROJECT_NAME=my-project-name
PROJECT_DESCRIPTION=My WordPress Development Site

# Ports (MUST BE UNIQUE!)
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
MYSQL_PORT=3306
REDIS_PORT=6379

# Shared Services (same for all projects)
MAILHOG_WEB_PORT=8025
MAILHOG_SMTP_PORT=1025

# WordPress URLs (update port in URLs!)
WP_HOME=http://localhost:8080
WP_SITEURL=http://localhost:8080/wp

# Database
DB_NAME=wordpress_dev
DB_USER=wp_user
DB_PASSWORD=wp_secure_password
DB_HOST=mysql
DB_ROOT_PASSWORD=root_secure_password
TABLE_PREFIX=wp_

# Development
WP_ENV=development
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=true
DISALLOW_FILE_EDIT=true
DISALLOW_FILE_MODS=false
WP_MEMORY_LIMIT=512M
```

### **Security Keys**
```bash
# Generate unique keys for each project
AUTH_KEY='your-unique-auth-key-here'
SECURE_AUTH_KEY='your-unique-secure-auth-key-here'
LOGGED_IN_KEY='your-unique-logged-in-key-here'
NONCE_KEY='your-unique-nonce-key-here'
AUTH_SALT='your-unique-auth-salt-here'
SECURE_AUTH_SALT='your-unique-secure-auth-salt-here'
LOGGED_IN_SALT='your-unique-logged-in-salt-here'
NONCE_SALT='your-unique-nonce-salt-here'
```

## 🔍 Port Conflict Detection

### **Check Port Usage**
```bash
# Linux/macOS
netstat -an | grep :8080
lsof -i :8080

# Windows
netstat -an | findstr :8080
```

### **Common Port Conflicts**
- **8080** - Often used by development servers
- **3306** - Default MySQL port
- **6379** - Default Redis port
- **8025** - MailHog web interface (shared)

### **Resolution Strategy**
1. **Use port ranges** - Increment by 10 for each project
2. **Document assignments** - Keep a list of used ports
3. **Test before starting** - Run port checks before `docker-compose up`

## 🏢 Multi-Project Examples

### **Agency Setup (3 Clients)**
```bash
# Client A - ACME Corp
COMPOSE_PROJECT_NAME=acme-corp
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
MYSQL_PORT=3306
REDIS_PORT=6379

# Client B - Beta Inc  
COMPOSE_PROJECT_NAME=beta-inc
HTTP_PORT=8090
PHPMYADMIN_PORT=8091
MYSQL_PORT=3316
REDIS_PORT=6389

# Client C - Gamma LLC
COMPOSE_PROJECT_NAME=gamma-llc
HTTP_PORT=8100
PHPMYADMIN_PORT=8101
MYSQL_PORT=3326
REDIS_PORT=6399
```

### **Personal Projects**
```bash
# Personal Blog
HTTP_PORT=8200, MySQL=3406, Redis=6479

# Portfolio Site  
HTTP_PORT=8210, MySQL=3416, Redis=6489

# E-commerce Experiment
HTTP_PORT=8220, MySQL=3426, Redis=6499
```

## ❗ Important Notes

1. **Always change `COMPOSE_PROJECT_NAME`** - This prevents Docker container conflicts
2. **Update URLs with correct ports** - `WP_HOME` and `WP_SITEURL` must match `HTTP_PORT`
3. **Keep port documentation** - Track assignments to avoid conflicts
4. **Test configuration** - Run `scripts/project-manager.ps1 status` after setup

## 🔧 Validation Checklist

- [ ] `.env` file exists
- [ ] `COMPOSE_PROJECT_NAME` is unique
- [ ] All ports are unique across projects
- [ ] URLs match HTTP_PORT  
- [ ] No port conflicts detected
- [ ] Project starts successfully

**Next step:** [Start your project](../workflows/development.md) once configuration is complete.
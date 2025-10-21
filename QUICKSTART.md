# 🚀 Quick Start Guide - Multi-Project WordPress Development

## 📋 Overview
Each WordPress project is a **copy of this repository** with its own `.env` configuration. You manage the lifecycle with simple scripts.

## � Prerequisites

### One-Time Setup (Required)

**Create the shared Docker network** (required for all projects):
```bash
docker network create wordpress-shared
```

This network allows WordPress projects to communicate with shared services like MailHog.

## �🛠️ Setup New Project (5 minutes)

### 1. Copy Repository
```bash
# Copy this repository to a new project directory
cp -r /path/to/wp-starter ~/my-projects/client-website
cd ~/my-projects/client-website
```

### 2. Configure Environment
```bash
# Copy and edit the environment file
cp .env.example .env
nano .env  # Edit ports and project name
```

**Important**: Each project needs **unique ports**:
```bash
# Project 1
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
MYSQL_PORT=3306
REDIS_PORT=6379

# Project 2  
HTTP_PORT=8090
PHPMYADMIN_PORT=8091
MYSQL_PORT=3316
REDIS_PORT=6389

# Project 3
HTTP_PORT=8100
PHPMYADMIN_PORT=8101
MYSQL_PORT=3326
REDIS_PORT=6399
```

### 3. Start Project
```bash
# Windows
scripts\project-manager.ps1 start

# Linux/macOS
./scripts/project-manager.sh start

# Or use Docker directly
docker-compose up -d
```

### 4. Access Your Site
- **Website**: http://localhost:8080 (your configured port)
- **Admin**: http://localhost:8080/wp/wp-admin (admin/admin)
- **phpMyAdmin**: http://localhost:8081

## 📧 Optional: Shared Email Testing

**One-time setup** for MailHog (shared across all projects):
```bash
# Start shared MailHog service
docker-compose -f docker-compose.mailhog.yml up -d

# Access: http://localhost:8025
# All projects can now send/test emails
```

## 🎯 Project Management

### Available Commands

| Command | Windows | Linux/macOS |
|---------|---------|-------------|
| **Start** | `scripts\project-manager.ps1 start` | `./scripts/project-manager.sh start` |
| **Stop** | `scripts\project-manager.ps1 stop` | `./scripts/project-manager.sh stop` |
| **Status** | `scripts\project-manager.ps1 status` | `./scripts/project-manager.sh status` |
| **Help** | `scripts\project-manager.ps1 help` | `./scripts/project-manager.sh help` |

### Multiple Projects Example
```bash
# Terminal 1: Client Website
cd ~/projects/client-website
./scripts/project-manager.sh start    # → http://localhost:8080

# Terminal 2: Personal Blog  
cd ~/projects/personal-blog
./scripts/project-manager.sh start    # → http://localhost:8090

# Terminal 3: E-commerce Store
cd ~/projects/ecommerce-store
./scripts/project-manager.sh start    # → http://localhost:8100
```

## 🔧 Troubleshooting

### Network Issues
If you see "network wordpress-shared declared as external, but could not be found":
```bash
# Create the missing shared network
docker network create wordpress-shared

# Then restart your project
docker-compose down
docker-compose up -d
```

### Port Conflicts
```bash
# Check what's using your ports
netstat -an | grep :8080
lsof -i :8080

# Update .env with different ports
HTTP_PORT=8200
PHPMYADMIN_PORT=8201
```

### Container Issues
```bash
# View logs
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose up -d --build

# Clean restart
docker-compose down -v
docker-compose up -d
```

## 📁 Project Structure
```
your-project/
├── .env                    # ← Your custom configuration
├── .env.example           # Template
├── wp-config.php          # ← WPStarter-compatible WordPress config
├── wp/wp-config.php       # ← WP-CLI compatible redirect
├── docker-compose.yml     # Main services
├── scripts/               # Management tools
│   ├── project-manager.sh # Linux/macOS
│   └── project-manager.ps1 # Windows
├── web/                   # WordPress files
├── wp-content/            # Themes, plugins
└── docker/                # Container configs
```

## ⚙️ **Key Features**
- **WPStarter Architecture**: Modern Bedrock-style WordPress setup
- **WP-CLI Compatible**: Includes proper wp-config.php structure for WP-CLI tools
- **Environment-Driven**: All configuration via .env files (no hardcoded values)
- **Multi-Project Ready**: Run unlimited WordPress sites simultaneously
- **Production-Ready**: Nginx + PHP-FPM architecture

---

**🎉 You're ready!** Copy this repo, configure `.env`, and run the start script. Each project is completely isolated with its own database, files, and configuration.
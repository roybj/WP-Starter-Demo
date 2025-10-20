# 🚀 Running Multiple WordPress Sites Simultaneously

Guide for developers working on multiple WordPress projects at the same time.

---

## 🎯 Current Issue & Solution

### ❌ Current Problem
The current setup has **hardcoded values** that prevent running multiple instances:

```yaml
# docker-compose.yml - CONFLICTS OCCUR:
container_name: wp-nginx     # ← Fixed container names
container_name: wp-mysql     # ← Will conflict with other projects
ports:
  - "8080:80"               # ← Fixed port assignments
  - "3306:3306"             # ← Will conflict between projects
```

### ✅ Solutions Available

We provide **3 different approaches** for running multiple sites:

1. **[Port-Based Setup](#1-port-based-setup-easiest)** - Different ports per project (Easiest)
2. **[Project-Based Setup](#2-project-based-setup-recommended)** - Dynamic containers (Recommended)
3. **[Domain-Based Setup](#3-domain-based-setup-advanced)** - Local domains (Advanced)

---

## 1. Port-Based Setup (Easiest)

### How It Works
Each project runs on different ports:
- **Project A**: http://localhost:8080, http://localhost:8081 (phpMyAdmin)
- **Project B**: http://localhost:8090, http://localhost:8091 (phpMyAdmin)  
- **Project C**: http://localhost:8100, http://localhost:8101 (phpMyAdmin)

### Setup Instructions

#### Step 1: Clone Multiple Projects
```bash
# Clone for each client/project
git clone <repo-url> client-website-a
git clone <repo-url> client-website-b
git clone <repo-url> client-website-c
```

#### Step 2: Configure Different Ports
For each project, edit the `.env` file:

**client-website-a/.env:**
```env
# Port Configuration
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
MAILHOG_PORT=8025
MYSQL_PORT=3306

# Project Identification
COMPOSE_PROJECT_NAME=client-a
```

**client-website-b/.env:**
```env
# Port Configuration  
HTTP_PORT=8090
PHPMYADMIN_PORT=8091
MAILHOG_PORT=8035
MYSQL_PORT=3316

# Project Identification
COMPOSE_PROJECT_NAME=client-b
```

**client-website-c/.env:**
```env
# Port Configuration
HTTP_PORT=8100
PHPMYADMIN_PORT=8101
MAILHOG_PORT=8045
MYSQL_PORT=3326

# Project Identification
COMPOSE_PROJECT_NAME=client-c
```

#### Step 3: Update docker-compose.yml Template
Create a **port-flexible docker-compose.yml**:

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: ${COMPOSE_PROJECT_NAME:-wp}-nginx
    restart: unless-stopped
    ports:
      - "${HTTP_PORT:-8080}:80"
    # ... rest of config

  mysql:
    image: mysql:8.0
    container_name: ${COMPOSE_PROJECT_NAME:-wp}-mysql
    ports:
      - "${MYSQL_PORT:-3306}:3306"
    # ... rest of config

  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: ${COMPOSE_PROJECT_NAME:-wp}-phpmyadmin
    ports:
      - "${PHPMYADMIN_PORT:-8081}:80"
    # ... rest of config

  mailhog:
    image: mailhog/mailhog:latest
    container_name: ${COMPOSE_PROJECT_NAME:-wp}-mailhog
    ports:
      - "${MAILHOG_PORT:-8025}:8025"
      - "1025:1025"
    # ... rest of config
```

#### Step 4: Start Multiple Projects
```bash
# Terminal 1: Start Client A
cd client-website-a
docker-compose up -d
# Access: http://localhost:8080

# Terminal 2: Start Client B  
cd client-website-b
docker-compose up -d
# Access: http://localhost:8090

# Terminal 3: Start Client C
cd client-website-c  
docker-compose up -d
# Access: http://localhost:8100
```

---

## 2. Project-Based Setup (Recommended)

### How It Works
Use Docker Compose project names to isolate containers and networks:

```bash
# Each project gets isolated containers:
client-a_nginx_1, client-a_mysql_1, client-a_redis_1
client-b_nginx_1, client-b_mysql_1, client-b_redis_1
client-c_nginx_1, client-c_mysql_1, client-c_redis_1
```

### Setup Instructions

#### Step 1: Use Project Names
```bash
# Method 1: Environment Variable
cd client-website-a
export COMPOSE_PROJECT_NAME=client-a
docker-compose up -d

# Method 2: Command Line Flag
cd client-website-b
docker-compose -p client-b up -d

# Method 3: .env File (Recommended)
cd client-website-c
echo "COMPOSE_PROJECT_NAME=client-c" >> .env
docker-compose up -d
```

#### Step 2: Port Management
Create a **port allocation system**:

**ports.md** (reference file):
```
Project          HTTP  phpMyAdmin  MailHog  MySQL
client-a         8080     8081      8025    3306
client-b         8090     8091      8035    3316
client-c         8100     8101      8045    3326
personal-blog    8110     8111      8055    3336
ecommerce-site   8120     8121      8065    3346
```

#### Step 3: Quick Start Script
Create **start-project.sh**:

```bash
#!/bin/bash
# Usage: ./start-project.sh client-a 8080 8081

PROJECT_NAME=$1
HTTP_PORT=$2
PHPMYADMIN_PORT=$3

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./start-project.sh <project-name> <http-port> <phpmyadmin-port>"
    echo "Example: ./start-project.sh client-a 8080 8081"
    exit 1
fi

# Set environment
export COMPOSE_PROJECT_NAME=$PROJECT_NAME
export HTTP_PORT=$HTTP_PORT
export PHPMYADMIN_PORT=$PHPMYADMIN_PORT

# Start containers
docker-compose up -d

echo "✅ Project '$PROJECT_NAME' started:"
echo "   Website: http://localhost:$HTTP_PORT"
echo "   phpMyAdmin: http://localhost:$PHPMYADMIN_PORT"
echo "   MailHog: http://localhost:8025"
```

#### Step 4: Management Commands
```bash
# List all running projects
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Stop specific project
docker-compose -p client-a down

# Stop all projects
docker stop $(docker ps -q)

# Remove unused containers
docker system prune -f
```

---

## 3. Domain-Based Setup (Advanced)

### How It Works
Use local domains instead of ports:
- **client-a.local** → Project A
- **client-b.local** → Project B  
- **client-c.local** → Project C

### Setup Instructions

#### Step 1: Configure Local DNS
**On Windows (Admin PowerShell):**
```powershell
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "
127.0.0.1 client-a.local
127.0.0.1 client-b.local  
127.0.0.1 client-c.local"
```

**On Mac/Linux:**
```bash
sudo sh -c 'echo "127.0.0.1 client-a.local" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 client-b.local" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 client-c.local" >> /etc/hosts'
```

#### Step 2: Use Traefik Reverse Proxy
Create **docker-compose.traefik.yml**:

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.9
    container_name: traefik
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Traefik dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.yml:/etc/traefik/traefik.yml
    networks:
      - wp-network

  # Client A
  nginx-client-a:
    image: nginx:alpine
    container_name: client-a-nginx
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.client-a.rule=Host(`client-a.local`)"
      - "traefik.http.services.client-a.loadbalancer.server.port=80"
    networks:
      - wp-network

  # Client B  
  nginx-client-b:
    image: nginx:alpine
    container_name: client-b-nginx
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.client-b.rule=Host(`client-b.local`)"
      - "traefik.http.services.client-b.loadbalancer.server.port=80"
    networks:
      - wp-network

networks:
  wp-network:
    external: true
```

#### Step 3: Access Sites
- **http://client-a.local** → Project A
- **http://client-b.local** → Project B
- **http://client-c.local** → Project C
- **http://localhost:8080** → Traefik Dashboard

---

## 🛠️ Practical Implementation

### Recommended Approach: Port-Based + Project Names

Create this **multi-project setup**:

#### 1. Create .env.template
```env
# ============================================================================
# Multi-Project WordPress Configuration Template
# ============================================================================
# Copy to each project directory and customize

# Project Identity
COMPOSE_PROJECT_NAME=project-name-here
PROJECT_DESCRIPTION="Client Project Description"

# Port Configuration (Avoid conflicts)
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
MAILHOG_WEB_PORT=8025
MAILHOG_SMTP_PORT=1025
MYSQL_PORT=3306

# WordPress Configuration
WP_ENV=development
DB_NAME=${COMPOSE_PROJECT_NAME}_db
DB_USER=${COMPOSE_PROJECT_NAME}_user
DB_PASSWORD=${COMPOSE_PROJECT_NAME}_pass
DB_HOST=mysql

# URLs (adjust port)
WP_HOME=http://localhost:${HTTP_PORT}
WP_SITEURL=http://localhost:${HTTP_PORT}/wp

# Security Keys (generate unique per project)
# Visit: https://api.wordpress.org/secret-key/1.1/salt/
AUTH_KEY='unique-key-for-this-project'
# ... other keys
```

#### 2. Create project-manager.sh
```bash
#!/bin/bash
# WordPress Multi-Project Manager

PROJECTS_DIR="$HOME/wordpress-projects"
PORTS_FILE="$PROJECTS_DIR/.port-assignments"

create_project() {
    local PROJECT_NAME=$1
    local HTTP_PORT=$2
    
    if [ -z "$PROJECT_NAME" ] || [ -z "$HTTP_PORT" ]; then
        echo "Usage: create_project <name> <http-port>"
        echo "Example: create_project client-acme 8090"
        return 1
    fi
    
    # Create project directory
    local PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"
    git clone <template-repo-url> "$PROJECT_DIR"
    
    # Configure ports
    cd "$PROJECT_DIR"
    cp .env.example .env
    sed -i "s/COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=$PROJECT_NAME/" .env
    sed -i "s/HTTP_PORT=.*/HTTP_PORT=$HTTP_PORT/" .env
    sed -i "s/PHPMYADMIN_PORT=.*/PHPMYADMIN_PORT=$((HTTP_PORT + 1))/" .env
    
    # Record port assignment
    echo "$PROJECT_NAME:$HTTP_PORT:$((HTTP_PORT + 1))" >> "$PORTS_FILE"
    
    echo "✅ Project '$PROJECT_NAME' created at $PROJECT_DIR"
    echo "   HTTP: http://localhost:$HTTP_PORT"
    echo "   phpMyAdmin: http://localhost:$((HTTP_PORT + 1))"
}

list_projects() {
    echo "📋 Active WordPress Projects:"
    docker ps --filter "label=com.docker.compose.service" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

start_project() {
    local PROJECT_NAME=$1
    local PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"
    
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "❌ Project '$PROJECT_NAME' not found in $PROJECTS_DIR"
        return 1
    fi
    
    cd "$PROJECT_DIR"
    docker-compose up -d
    
    # Get project info
    local HTTP_PORT=$(grep "HTTP_PORT=" .env | cut -d'=' -f2)
    echo "🚀 Project '$PROJECT_NAME' started:"
    echo "   Website: http://localhost:$HTTP_PORT"
}

stop_project() {
    local PROJECT_NAME=$1
    local PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"
    
    cd "$PROJECT_DIR" 2>/dev/null || {
        echo "❌ Project '$PROJECT_NAME' not found"
        return 1
    }
    
    docker-compose down
    echo "🛑 Project '$PROJECT_NAME' stopped"
}

# Command router
case "$1" in
    "create")
        create_project "$2" "$3"
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
    *)
        echo "WordPress Multi-Project Manager"
        echo ""
        echo "Usage:"
        echo "  ./project-manager.sh create <name> <port>  # Create new project"
        echo "  ./project-manager.sh start <name>         # Start project"
        echo "  ./project-manager.sh stop <name>          # Stop project" 
        echo "  ./project-manager.sh list                 # List all projects"
        echo ""
        echo "Examples:"
        echo "  ./project-manager.sh create client-acme 8090"
        echo "  ./project-manager.sh start client-acme"
        echo "  ./project-manager.sh list"
        ;;
esac
```

#### 3. Usage Example
```bash
# Create projects
./project-manager.sh create client-acme 8080
./project-manager.sh create personal-blog 8090  
./project-manager.sh create ecommerce-site 8100

# Start multiple projects
./project-manager.sh start client-acme        # http://localhost:8080
./project-manager.sh start personal-blog      # http://localhost:8090
./project-manager.sh start ecommerce-site     # http://localhost:8100

# List all running
./project-manager.sh list

# Stop when done
./project-manager.sh stop client-acme
```

---

## 📊 Port Allocation Strategy

### Recommended Port Ranges

| Project Type | HTTP Port Range | phpMyAdmin | MailHog |
|-------------|----------------|------------|---------|
| **Client Work** | 8080-8199 | +1 from HTTP | 8025 (shared) |
| **Personal Projects** | 8200-8299 | +1 from HTTP | 8035 (alt) |
| **Experiments** | 8300-8399 | +1 from HTTP | 8045 (alt) |
| **Team Projects** | 8400-8499 | +1 from HTTP | 8055 (alt) |

### Port Assignment Examples
```
client-acme       8080 → 8081 (phpMyAdmin)
client-bigcorp    8090 → 8091 (phpMyAdmin) 
personal-blog     8200 → 8201 (phpMyAdmin)
experimental-cms  8300 → 8301 (phpMyAdmin)
team-project      8400 → 8401 (phpMyAdmin)
```

---

## 🚀 Quick Commands Reference

```bash
# Create new project with custom ports
git clone <repo-url> my-new-project
cd my-new-project
cp .env.example .env

# Edit .env:
# COMPOSE_PROJECT_NAME=my-new-project
# HTTP_PORT=8090
# PHPMYADMIN_PORT=8091

# Start project
docker-compose up -d

# Access
# Website: http://localhost:8090
# phpMyAdmin: http://localhost:8091
# MailHog: http://localhost:8025

# List all containers
docker ps

# Stop specific project
docker-compose down

# Stop all projects
docker stop $(docker ps -q)

# Clean up unused containers
docker system prune -f
```

---

## 💡 Best Practices

### 1. **Project Organization**
```
~/wordpress-projects/
├── client-acme/          # Port 8080-8081
├── client-bigcorp/       # Port 8090-8091  
├── personal-blog/        # Port 8200-8201
├── experimental-cms/     # Port 8300-8301
├── .port-assignments     # Port tracking file
└── project-manager.sh    # Management script
```

### 2. **Resource Management**
```bash
# Monitor Docker resource usage
docker stats

# Stop unused projects to free resources  
docker-compose -p unused-project down

# Clean up regularly
docker system prune -f --volumes
```

### 3. **Database Isolation**
Each project gets its own:
- MySQL container with isolated data
- Database name matching project
- Separate user credentials
- Independent backups

### 4. **Development Workflow**
```bash
# Morning: Start active projects
./project-manager.sh start client-acme
./project-manager.sh start personal-blog

# Work on projects throughout day
# Access via different ports

# Evening: Stop non-critical projects
./project-manager.sh stop personal-blog
# Keep client work running for demos
```

---

## 🎯 Implementation for Your Repository

Let me update your current setup to support multiple projects. I'll create the necessary files to make this seamless for your developers.

Would you like me to:

1. **Update docker-compose.yml** to use environment variables for ports and project names?
2. **Create project management scripts** for easy multi-project handling?
3. **Update documentation** with multi-project workflows?
4. **Create .env templates** for different project types?

This will make your repository much more powerful for developers working on multiple WordPress sites simultaneously! 🚀
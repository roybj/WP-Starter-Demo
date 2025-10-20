# 🚀 Quick Multi-Project Setup Guide

This guide shows you how to quickly start running multiple WordPress projects simultaneously using this repository.

## 🎯 Problem Solved

**Before**: Developers could only run one WordPress project at a time due to port conflicts
**After**: Run unlimited WordPress projects simultaneously with automatic port management

---

## 🔧 Prerequisites

### One-Time Setup (Required)

**Create the shared Docker network** before starting any projects:
```bash
docker network create wordpress-shared
```

This network is required for:
- Communication between WordPress projects and shared services
- MailHog email testing functionality
- Proper container isolation and networking

---

## 🏃‍♂️ Quick Start (5 minutes)

### Step 1: Clone the Template
```bash
git clone <this-repo> wordpress-template
cd wordpress-template
```

### Step 2: Create Your First Project
**Windows (PowerShell):**
```powershell
scripts\project-manager.ps1 create client-acme 8080 "ACME Corp Website"
```

**Windows (Command Prompt):**
```cmd
scripts\project-manager.bat create client-acme 8080 "ACME Corp Website"
```

### Step 3: Start the Project
```powershell
.\project-manager.ps1 start client-acme
```

### Step 4: Access Your Site
- **Website**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081
- **Email Testing**: http://localhost:8025

### Step 5: Create More Projects
```powershell
# Personal blog on different port
.\project-manager.ps1 create personal-blog 8090 "My Personal Blog"
.\project-manager.ps1 start personal-blog

# E-commerce experiment  
.\project-manager.ps1 create ecommerce-test 8100 "WooCommerce Testing"
.\project-manager.ps1 start ecommerce-test
```

Now you have **3 WordPress sites running simultaneously**:
- http://localhost:8080 (ACME Corp)
- http://localhost:8090 (Personal Blog)  
- http://localhost:8100 (E-commerce Test)

---

## 📊 Project Management

### List All Projects
```powershell
.\project-manager.ps1 list
```

### Check Status
```powershell  
.\project-manager.ps1 status
```

### View Port Assignments
```powershell
.\project-manager.ps1 ports
```

### Stop Projects
```powershell
# Stop individual project
.\project-manager.ps1 stop client-acme

# Stop all containers
docker stop $(docker ps -q)
```

### Clean Up Resources
```powershell
.\project-manager.ps1 clean
```

---

## 🗂️ File Structure

After creating projects, your structure looks like this:

```
%USERPROFILE%\wordpress-projects\
├── client-acme\               # HTTP: 8080, phpMyAdmin: 8081
│   ├── .env                   # Project-specific config
│   ├── docker-compose.yml     # Multi-project Docker setup
│   ├── web\                   # WordPress files
│   └── wp\                    # Core WordPress
│
├── personal-blog\             # HTTP: 8090, phpMyAdmin: 8091  
│   ├── .env                   # Different ports/config
│   ├── docker-compose.yml     # Isolated containers
│   └── ...
│
├── ecommerce-test\            # HTTP: 8100, phpMyAdmin: 8101
│   └── ...
│
└── .port-assignments          # Port tracking file
```

---

## 🎛️ Port Management

### Automatic Port Assignment
If you don't specify a port, the system finds the next available port:

```powershell
# Auto-assigns ports starting from 8080
.\project-manager.ps1 create new-project

# Output: 💡 Auto-assigned port: 8110
```

### Recommended Port Ranges

| Project Type | HTTP Ports | phpMyAdmin | Usage |
|-------------|------------|------------|--------|
| **Client Work** | 8080-8199 | 8081-8200 | Client websites |
| **Personal** | 8200-8299 | 8201-8300 | Personal projects |
| **Experiments** | 8300-8399 | 8301-8400 | Testing/R&D |
| **Team Projects** | 8400-8499 | 8401-8500 | Collaborative work |

### Port Conflict Prevention
The system automatically prevents conflicts:

```powershell
.\project-manager.ps1 create second-project 8080
# ❌ Error: Port 8080 is already in use
# Run '.\project-manager.ps1 ports' to see current assignments
```

---

## 💡 Development Workflow Examples

### Daily Development
```powershell
# Morning: Start active projects
.\project-manager.ps1 start client-acme
.\project-manager.ps1 start personal-blog

# Work on different projects throughout the day
# Switch between http://localhost:8080 and http://localhost:8090

# Evening: Stop resource-intensive projects
.\project-manager.ps1 stop personal-blog
# Keep client work running for demos
```

### Client Work
```powershell
# Create client project
.\project-manager.ps1 create client-bigcorp 8120 "BigCorp Website Redesign"

# Start for development
.\project-manager.ps1 start client-bigcorp

# Access for demo: http://localhost:8120
# Share with client: "Visit http://localhost:8120"

# Stop when presentation is done
.\project-manager.ps1 stop client-bigcorp
```

### Team Collaboration
```powershell
# Team member A
.\project-manager.ps1 create team-project-frontend 8400 "Frontend Development"

# Team member B (different machine)  
.\project-manager.ps1 create team-project-backend 8410 "Backend Development"

# Same codebase, different ports, no conflicts
```

---

## 🐳 Docker Container Isolation

Each project gets completely isolated:

### Container Names
```
client-acme_nginx_1      # Project A containers
client-acme_mysql_1
client-acme_redis_1

personal-blog_nginx_1    # Project B containers  
personal-blog_mysql_1
personal-blog_redis_1
```

### Networks & Volumes
```
client-acme_network      # Isolated networking
client-acme_mysql_data   # Separate databases
client-acme_wp_uploads   # Independent uploads

personal-blog_network    # No cross-talk
personal-blog_mysql_data # Different data
personal-blog_wp_uploads # Different files
```

---

## 🔧 Customization

### Environment Variables
Each project has its own `.env` file with unique:
- Database credentials
- Security keys  
- Port assignments
- WordPress configuration

### Docker Compose
Each project uses `docker-compose.multi.yml` which supports:
- Dynamic container naming: `${COMPOSE_PROJECT_NAME}-nginx`
- Variable ports: `${HTTP_PORT}:80`
- Isolated volumes: `${COMPOSE_PROJECT_NAME}_mysql_data`

---

## 🚨 Troubleshooting

### Port Already in Use
```powershell
# Check what's using the port
netstat -ano | findstr :8080

# Kill the process (if safe)
taskkill /PID <process-id> /F

# Or use a different port
.\project-manager.ps1 create new-project 8090
```

### Docker Issues
```powershell
# Check Docker status
docker --version
docker ps

# Restart Docker Desktop
# Right-click Docker Desktop → Restart

# Clean up if needed
.\project-manager.ps1 clean
```

### Container Won't Start
```powershell
# Check logs
cd %USERPROFILE%\wordpress-projects\project-name
docker-compose logs

# Recreate containers
docker-compose down
docker-compose up -d --force-recreate
```

---

## 🎯 Next Steps

1. **Create your first project**: Follow the Quick Start above
2. **Read the full guide**: See `MULTI-PROJECT-GUIDE.md` for advanced features
3. **Customize your setup**: Edit `.env` files for specific project needs
4. **Share with team**: Each developer can run the same workflow independently

---

## 📋 Command Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `create` | Create new project | `.\project-manager.ps1 create my-site 8080` |
| `start` | Start project | `.\project-manager.ps1 start my-site` |
| `stop` | Stop project | `.\project-manager.ps1 stop my-site` |
| `list` | List projects | `.\project-manager.ps1 list` |
| `status` | Show Docker status | `.\project-manager.ps1 status` |
| `ports` | Show port assignments | `.\project-manager.ps1 ports` |
| `clean` | Clean Docker resources | `.\project-manager.ps1 clean` |

---

**🎉 You're now ready to run multiple WordPress projects simultaneously!**

Each project is completely isolated with its own database, uploads, and configuration. Perfect for agencies, freelancers, or developers working on multiple client projects.

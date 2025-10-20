# 🌐 Cross-Platform Setup Guide

> **Identical WordPress development workflow on Windows, Linux, and macOS**

## 📋 Overview

This WordPress development environment works identically across all operating systems. The only difference is the command syntax - the functionality and workflow are exactly the same.

## 🖥️ Platform-Specific Instructions

### Windows (PowerShell)

#### **Prerequisites**
```powershell
# Check if Docker is installed
docker --version
docker-compose --version

# If not installed, download Docker Desktop from:
# https://www.docker.com/products/docker-desktop
```

#### **Project Setup**
```powershell
# 1. Copy repository
Copy-Item -Recurse "path\to\wp-starter" "C:\Projects\my-project"
cd "C:\Projects\my-project"

# 2. Configure environment
copy .env.example .env
notepad .env  # Edit ports and project name

# 3. Start project
scripts\project-manager.ps1 start

# 4. Access URLs
# Website: http://localhost:8080
# Admin: http://localhost:8080/wp/wp-admin (admin/admin)
```

#### **Daily Commands**
```powershell
# Start project
scripts\project-manager.ps1 start

# Stop project  
scripts\project-manager.ps1 stop

# View status
scripts\project-manager.ps1 status

# View logs
scripts\project-manager.ps1 logs

# Restart project
scripts\project-manager.ps1 restart
```

---

### Linux

#### **Prerequisites**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# CentOS/RHEL
sudo yum install docker docker-compose

# Arch Linux
sudo pacman -S docker docker-compose

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

#### **Project Setup**
```bash
# 1. Copy repository
cp -r /path/to/wp-starter ~/projects/my-project
cd ~/projects/my-project

# 2. Configure environment
cp .env.example .env
nano .env  # Edit ports and project name

# 3. Make script executable
chmod +x scripts/project-manager.sh

# 4. Start project
./scripts/project-manager.sh start

# 5. Access URLs
# Website: http://localhost:8080
# Admin: http://localhost:8080/wp/wp-admin (admin/admin)
```

#### **Daily Commands**
```bash
# Start project
./scripts/project-manager.sh start

# Stop project
./scripts/project-manager.sh stop

# View status
./scripts/project-manager.sh status

# View logs
./scripts/project-manager.sh logs

# Restart project
./scripts/project-manager.sh restart
```

---

### macOS

#### **Prerequisites**
```bash
# Install Docker Desktop from:
# https://www.docker.com/products/docker-desktop

# Or using Homebrew
brew install --cask docker

# Verify installation
docker --version
docker-compose --version
```

#### **Project Setup**
```bash
# 1. Copy repository
cp -r /path/to/wp-starter ~/Projects/my-project
cd ~/Projects/my-project

# 2. Configure environment
cp .env.example .env
nano .env  # Edit ports and project name

# 3. Make script executable (if needed)
chmod +x scripts/project-manager.sh

# 4. Start project
./scripts/project-manager.sh start

# 5. Access URLs
# Website: http://localhost:8080  
# Admin: http://localhost:8080/wp/wp-admin (admin/admin)
```

#### **Daily Commands**
```bash
# Start project
./scripts/project-manager.sh start

# Stop project
./scripts/project-manager.sh stop

# View status
./scripts/project-manager.sh status

# View logs  
./scripts/project-manager.sh logs

# Restart project
./scripts/project-manager.sh restart
```

---

## 🔧 WSL2 (Windows Subsystem for Linux)

Windows users can also use the Linux commands through WSL2:

### **Setup WSL2**
```powershell
# Install WSL2 (Windows PowerShell as Administrator)
wsl --install

# Or install specific distribution
wsl --install -d Ubuntu
```

### **Use Linux Commands in WSL2**
```bash
# Navigate to project (from Windows directory)
cd /mnt/c/Projects/my-project

# Use Linux commands
./scripts/project-manager.sh start
./scripts/project-manager.sh status
```

## 🌐 Multi-Project Management

### **Windows Example**
```powershell
# Project 1: Client Website
cd "C:\Projects\client-website"
scripts\project-manager.ps1 start
# → http://localhost:8080

# Project 2: Personal Blog
cd "C:\Projects\personal-blog"  
scripts\project-manager.ps1 start
# → http://localhost:8090
```

### **Linux/macOS Example**
```bash
# Project 1: Client Website
cd ~/projects/client-website
./scripts/project-manager.sh start
# → http://localhost:8080

# Project 2: Personal Blog
cd ~/projects/personal-blog
./scripts/project-manager.sh start  
# → http://localhost:8090
```

## 🚀 Command Reference

### **Project Management**

| Task | Windows | Linux/macOS |
|------|---------|-------------|
| **Start** | `scripts\project-manager.ps1 start` | `./scripts/project-manager.sh start` |
| **Stop** | `scripts\project-manager.ps1 stop` | `./scripts/project-manager.sh stop` |
| **Status** | `scripts\project-manager.ps1 status` | `./scripts/project-manager.sh status` |
| **Logs** | `scripts\project-manager.ps1 logs` | `./scripts/project-manager.sh logs` |
| **Restart** | `scripts\project-manager.ps1 restart` | `./scripts/project-manager.sh restart` |
| **Help** | `scripts\project-manager.ps1 help` | `./scripts/project-manager.sh help` |

### **MailHog (Optional Email Testing)**

| Task | Windows | Linux/macOS |
|------|---------|-------------|
| **Start MailHog** | `scripts\project-manager.ps1 mailhog-start` | `./scripts/project-manager.sh mailhog-start` |
| **Stop MailHog** | `scripts\project-manager.ps1 mailhog-stop` | `./scripts/project-manager.sh mailhog-stop` |

## 💡 Platform-Specific Tips

### **Windows**
- Use **PowerShell** (not Command Prompt) for best experience
- **Docker Desktop** handles all Docker functionality
- **WSL2** provides Linux compatibility if needed

### **Linux**  
- Ensure user is in **docker group** to avoid sudo
- Use **systemctl** to manage Docker service
- **UFW firewall** may need port configuration

### **macOS**
- **Docker Desktop** is the recommended approach
- **Homebrew** simplifies installation
- **Finder** integration works with Docker Desktop

## 🔍 Troubleshooting

### **Common Issues**

**Docker not found:**
```bash
# Linux: Install Docker
sudo apt install docker.io docker-compose

# macOS: Install Docker Desktop  
brew install --cask docker

# Windows: Download Docker Desktop
# https://www.docker.com/products/docker-desktop
```

**Permission denied:**
```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again

# Make script executable
chmod +x scripts/project-manager.sh
```

**Port conflicts:**
```bash
# Check what's using the port
netstat -an | grep :8080  # Linux/macOS
netstat -an | findstr :8080  # Windows

# Edit .env to use different ports
nano .env  # Change HTTP_PORT, MYSQL_PORT, etc.
```

## ✅ Validation

After setup, verify everything works:

```bash
# Check Docker
docker --version

# Check project status
./scripts/project-manager.sh status  # Linux/macOS
scripts\project-manager.ps1 status   # Windows

# Access WordPress
# http://localhost:8080
```

**Next step:** Learn about [daily development workflows](../workflows/development.md) once your platform is set up.
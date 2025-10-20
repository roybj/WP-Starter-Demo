# 🚀 WordPress WP Starter

> **Professional WordPress development environment with multi-project support**

A modern WordPress development stack using **WP Starter 3.0** (Bedrock-style architecture), **Docker Compose**, **Nginx**, **PHP 8.2**, **MySQL 8.0**, and **Redis**.

## ⚡ Quick Start - Simplified Multi-Project Approach

### 🎯 **New Project Setup (5 minutes)**

Each WordPress project is a **copy of this repository** with its own configuration:

```bash
# 1. Copy repository for new project
cp -r /path/to/wp-starter ~/my-projects/client-website
cd ~/my-projects/client-website

# 2. Configure environment (set unique ports!)
cp .env.example .env
nano .env  # Edit COMPOSE_PROJECT_NAME and ports

# 3. Start project
./scripts/project-manager.sh start    # Linux/macOS
# OR
scripts\project-manager.ps1 start     # Windows
```

### 🌐 **Multiple Projects Running Simultaneously**

```bash
# Project 1: Client Website
cd ~/projects/client-website         # HTTP_PORT=8080
./scripts/project-manager.sh start   # → http://localhost:8080

# Project 2: Personal Blog  
cd ~/projects/personal-blog          # HTTP_PORT=8090
./scripts/project-manager.sh start   # → http://localhost:8090

# Project 3: E-commerce Store
cd ~/projects/ecommerce-store        # HTTP_PORT=8100  
./scripts/project-manager.sh start   # → http://localhost:8100
```

**🔑 Key Benefits:**
- ✅ **Complete isolation** - separate databases, files, configurations
- ✅ **Simple setup** - copy repo, edit .env, start
- ✅ **No port conflicts** - you control all port assignments
- ✅ **Cross-platform** - same workflow on Windows, Linux, macOS

### 🔌 **Port Configuration Examples**

**Important**: Each project needs unique ports in `.env`:

```bash
# Project 1: Client Website
HTTP_PORT=8080
PHPMYADMIN_PORT=8081
MYSQL_PORT=3306
REDIS_PORT=6379

# Project 2: Personal Blog
HTTP_PORT=8090  
PHPMYADMIN_PORT=8091
MYSQL_PORT=3316
REDIS_PORT=6389

# Project 3: E-commerce
HTTP_PORT=8100
PHPMYADMIN_PORT=8101  
MYSQL_PORT=3326
REDIS_PORT=6399
```

### � **Optional: Shared Email Testing**

**One-time setup** for MailHog (shared across all projects):
```bash
# Start shared MailHog service
docker-compose -f docker-compose.mailhog.yml up -d

# Access: http://localhost:8025
# All projects can now send/test emails
```

### 🛠️ **Prerequisites & Setup**

**One-time setup required** - Create the shared network:
```bash
# Create shared network for all WordPress projects
docker network create wordpress-shared
```

### 🛠️ **Project Management Commands**

| Platform | Start | Stop | Status |
|----------|--------|-------|---------|
| **Linux/macOS** | `./scripts/project-manager.sh start` | `./scripts/project-manager.sh stop` | `./scripts/project-manager.sh status` |
| **Windows** | `scripts\project-manager.ps1 start` | `scripts\project-manager.ps1 stop` | `scripts\project-manager.ps1 status` |

**📖 [Complete Setup Guide →](QUICKSTART.md)**

**📚 [Single Project Guide →](docs/setup/quickstart.md)**

---

## 📚 Documentation

### 🚀 Getting Started
- **[Multi-Project Setup](docs/setup/multi-project.md)** ⭐ - Unlimited concurrent sites (5 min)
- **[Single Project Setup](docs/setup/quickstart.md)** - Traditional approach (2 min)  
- **[Developer Checklist](docs/setup/developer-checklist.md)** - Verification steps (15 min)

### 📖 Guides & Workflows
- **[Contributing Guide](docs/guides/contributing.md)** - Team collaboration & code standards
- **[Multi-Project Workflows](docs/guides/multi-project-workflows.md)** - Professional management strategies
- **[Docker Guide](docs/guides/docker-guide.md)** - Container architecture & debugging

### 📋 Reference  
- **[Setup Summary](docs/reference/setup-summary.md)** - Complete comparison & file inventory
- **[Publish Checklist](docs/reference/publish-checklist.md)** - Pre-deployment verification
- **[All Documentation](docs/)** - Complete documentation index

---

## 🏗️ Architecture Overview

### WP Starter 3.0 (Bedrock-Style)
```
Project Structure:
├── web/              # 🌐 Document root (public files only)
├── wp/               # 📦 WordPress core (Composer managed)
├── wp-content/       # 🎨 Themes, plugins, uploads
├── vendor/           # 📦 Composer dependencies  
├── config/           # ⚙️ Environment templates
├── scripts/          # 🛠️ Management tools
├── docs/             # 📚 All documentation
└── docker/           # 🐳 Container configuration
```

### Multi-Project Isolation
Each project gets:
- ✅ **Separate containers** with unique names
- ✅ **Isolated databases** and volumes  
- ✅ **Different ports** (8080, 8090, 8100...)
- ✅ **Independent configuration** and environment variables
- ✅ **No conflicts** between projects

---

## 🛠️ Key Features

### 🔧 Development Stack
- **WordPress** 6.8+ with WP Starter 3.0 architecture
- **PHP** 8.2 with FPM (production-ready configuration)
- **Nginx** web server (CloudPanel compatible)
- **MySQL** 8.0 with optimized configuration
- **Redis** for object caching and session storage
- **MailHog** for email testing and debugging

### 🚀 Multi-Project Capabilities
- **Unlimited concurrent projects** with automatic port management
- **Professional team workflows** for agencies and freelancers
- **Complete project isolation** - no data mixing between clients
- **Cross-platform scripts** for Windows, Mac, and Linux
- **Resource management** tools for optimal performance

### 🔒 Security & Best Practices
- **Bedrock-style architecture** with secure directory structure
- **Environment-based configuration** with `.env` files
- **Composer dependency management** for plugins and themes
- **Git-friendly setup** with proper `.gitignore` exclusions
- **Production-ready** container configuration

---

## 🎯 Use Cases

### 🏢 **For Agencies & Teams**
- Manage multiple client projects simultaneously
- Demonstrate different projects to clients on separate ports
- Collaborate on projects with isolated development environments
- Maintain clean separation between client codebases

### 👤 **For Freelancers**
- Switch between client projects instantly
- Maintain multiple WordPress versions for compatibility testing
- Present live development progress to clients
- Organize projects by client or project type

### 🎓 **For Learning & Development**
- Experiment with different WordPress configurations
- Test plugins and themes in isolated environments
- Learn WordPress development with professional tools
- Practice deployment workflows safely

---

## 📦 Quick Commands

```bash
# Multi-project management
scripts/project-manager.ps1 create my-project 8080    # Create new project
scripts/project-manager.ps1 start my-project         # Start project
scripts/project-manager.ps1 list                     # List all projects
scripts/project-manager.ps1 ports                    # Show port assignments

# Single project management
docker-compose up -d                                 # Start containers
docker-compose ps                                    # Check status
docker-compose logs -f                              # View logs
docker-compose down                                  # Stop containers

# WordPress management
docker-compose exec wordpress wp plugin list        # List plugins
docker-compose exec wordpress wp theme list         # List themes  
docker-compose exec wordpress wp cache flush        # Clear cache
```

---

## 🆘 Getting Help

### 📚 **Documentation**
- **New to the project?** → [Multi-Project Setup](docs/setup/multi-project.md)
- **Need team workflows?** → [Contributing Guide](docs/guides/contributing.md)
- **Docker issues?** → [Docker Guide](docs/guides/docker-guide.md)
- **Full documentation** → [docs/](docs/)

### 🐛 **Troubleshooting**
- **Port conflicts** → Check [port assignments](docs/setup/multi-project.md#port-management)
- **Container issues** → Review [Docker troubleshooting](docs/guides/docker-guide.md#troubleshooting)
- **WordPress problems** → See [common solutions](docs/setup/developer-checklist.md)

### 💬 **Support**
- Review documentation in [docs/](docs/) directory
- Check existing issues and solutions in guides
- Follow setup verification steps in [Developer Checklist](docs/setup/developer-checklist.md)

---

## 🎉 What Makes This Special?

### ✨ **Professional Grade**
This isn't just another WordPress Docker setup. It's a **complete development platform** designed for professional use with:

- **Multi-project architecture** that scales with your business
- **Team collaboration features** for agencies and development teams  
- **Production-ready configuration** that mirrors real hosting environments
- **Comprehensive documentation** covering all scenarios and use cases

### 🚀 **Ready for Production**
The Docker configuration mirrors modern hosting environments:
- **Nginx + PHP-FPM** architecture (used by CloudPanel and similar platforms)
- **Optimized MySQL 8.0** configuration with performance tuning
- **Redis caching** for improved WordPress performance
- **Security-focused** directory structure following Bedrock best practices

### 👥 **Team-Friendly**  
Built for collaboration from day one:
- **Consistent environments** across all team members
- **Easy onboarding** with automated setup scripts
- **Clear documentation** and contribution guidelines
- **Flexible workflows** supporting different development styles

---

**🚀 Ready to get started? Try the [Multi-Project Setup](docs/setup/multi-project.md) for the best experience!**
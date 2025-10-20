# 📚 WordPress Multi-Project Starter - Documentation

> **Day 0 ready WordPress development environment for any operating system**

## 🚀 Quick Navigation

### 🎯 **Getting Started**
- **[Quick Setup Guide](../QUICKSTART.md)** - 5-minute setup for new projects
- **[Environment Configuration](setup/environment.md)** - .env file configuration and port management
- **[Cross-Platform Setup](setup/cross-platform.md)** - Windows, Linux, and macOS instructions

### 💻 **Development Workflows**
- **[Multi-Project Management](workflows/multi-project.md)** - Running multiple WordPress sites simultaneously  
- **[Daily Development](workflows/development.md)** - Common tasks and best practices
- **[Email Testing](workflows/email-testing.md)** - Using MailHog for email development

### 🛠️ **Advanced Topics**
- **[Docker Architecture](advanced/docker-architecture.md)** - Container setup and networking
- **[Troubleshooting](advanced/troubleshooting.md)** - Common issues and solutions
- **[Custom Configuration](advanced/customization.md)** - Extending the setup for specific needs

### 📋 **Reference**
- **[Available Commands](reference/commands.md)** - Complete command reference
- **[Port Configuration](reference/ports.md)** - Port allocation strategies
- **[File Structure](reference/file-structure.md)** - Project organization

---

## 🏆 **Key Features**

✅ **Day 0 Ready** - Copy repo, edit .env, start developing  
✅ **Multi-Project** - Run unlimited WordPress sites simultaneously  
✅ **Cross-Platform** - Identical workflow on Windows, Linux, macOS  
✅ **Complete Isolation** - Separate databases, files, and configurations  
✅ **Optional Services** - MailHog email testing when needed  
✅ **Simple Management** - Intuitive scripts for all lifecycle operations

## 🎯 **Architecture Overview**

```
Copy Repository → Configure .env → Start Project → Develop
       ↓               ↓              ↓           ↓
   New folder    Set unique ports   Docker up   WordPress ready
```

### **Multi-Project Example:**
```bash
~/projects/
├── client-website/     # Port 8080, MySQL 3306
├── personal-blog/      # Port 8090, MySQL 3316  
└── ecommerce-store/    # Port 8100, MySQL 3326
```

Each project is **completely independent** with its own:
- WordPress installation and database
- Themes, plugins, and uploads
- Configuration and environment settings
- Docker containers and networking

---

## 📖 **Documentation Structure**

- **`setup/`** - Initial configuration and environment setup
- **`workflows/`** - Development processes and daily tasks  
- **`advanced/`** - Docker internals, troubleshooting, customization
- **`reference/`** - Command lists, configuration options, file layouts

**Need help?** Start with the [Quick Setup Guide](../QUICKSTART.md) or browse the specific topic you need above.
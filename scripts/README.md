# WordPress WP Starter - Scripts Directory

This directory contains all management and automation scripts for the WordPress development environment.

## 🛠️ Available Scripts

### Multi-Project Management

| Script | Platform | Purpose |
|--------|----------|---------|
| **project-manager.ps1** | Windows PowerShell | Full project lifecycle management |
| **project-manager.bat** | Windows Command Prompt | Basic project management (legacy) |

#### Usage Examples
```powershell
# PowerShell (Recommended)
scripts\project-manager.ps1 create client-acme 8080 "ACME Corp Website"
scripts\project-manager.ps1 start client-acme
scripts\project-manager.ps1 list
scripts\project-manager.ps1 ports

# Command Prompt
scripts\project-manager.bat create client-acme 8080 "ACME Corp Website"
scripts\project-manager.bat start client-acme
```

### Single Project Setup

| Script | Platform | Purpose |
|--------|----------|---------|
| **setup-dev.sh** | Mac/Linux | Automated single-project setup |
| **setup-dev.bat** | Windows | Automated single-project setup |

#### Usage Examples
```bash
# Mac/Linux
scripts/setup-dev.sh

# Windows
scripts\setup-dev.bat
```

## 🚀 Getting Started

### For Multi-Project Development (Recommended)
1. Use **project-manager.ps1** for the best experience
2. Create unlimited concurrent WordPress projects
3. Each project gets isolated containers and ports
4. Perfect for agencies, teams, and freelancers

### For Single Project Development
1. Use **setup-dev.sh** (Mac/Linux) or **setup-dev.bat** (Windows)
2. Traditional single WordPress site setup
3. Lower resource usage, simpler workflow
4. Good for learning and simple projects

## 📋 Script Features

### project-manager.ps1 Features
- ✅ **Cross-platform** PowerShell support
- ✅ **Colored output** for better readability
- ✅ **Error handling** with helpful messages
- ✅ **Port conflict detection** and resolution
- ✅ **Project validation** and verification
- ✅ **Resource management** and cleanup tools

### setup-dev Scripts Features
- ✅ **Automated Docker checks** and setup
- ✅ **Dependency installation** via Composer
- ✅ **WordPress initialization** and configuration
- ✅ **Interactive prompts** for custom setup
- ✅ **Error recovery** and retry mechanisms

## 🔧 Customization

### Environment Variables
Scripts respect these environment variables:

```bash
# Project configuration
COMPOSE_PROJECT_NAME=my-project     # Project name
HTTP_PORT=8080                      # Web server port
PHPMYADMIN_PORT=8081               # Database management port

# Paths
PROJECTS_BASE_DIR="$HOME/wordpress-projects"  # Base directory for projects
```

### Script Modification
Feel free to customize scripts for your workflow:

1. **Fork the repository** for your team's needs
2. **Modify port ranges** in project-manager scripts
3. **Add custom commands** for your specific requirements
4. **Integrate with CI/CD** pipelines for automation

## 📚 Documentation

- **Multi-project setup**: [../docs/setup/multi-project.md](../docs/setup/multi-project.md)
- **Single project setup**: [../docs/setup/quickstart.md](../docs/setup/quickstart.md)
- **Complete workflows**: [../docs/guides/multi-project-workflows.md](../docs/guides/multi-project-workflows.md)
- **Contributing**: [../docs/guides/contributing.md](../docs/guides/contributing.md)

## 🆘 Troubleshooting

### Common Issues

**PowerShell execution policy:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Script not found:**
- Ensure you're running from repository root
- Use relative paths: `scripts\project-manager.ps1`
- Check file permissions on Mac/Linux: `chmod +x scripts/setup-dev.sh`

**Docker not running:**
- Start Docker Desktop
- Verify: `docker --version`
- Check Docker daemon status

**Port conflicts:**
- Use `scripts\project-manager.ps1 ports` to see assignments
- Choose different ports: `create my-project 8090`
- Stop conflicting services: `scripts\project-manager.ps1 stop other-project`

---

**🎯 Start with multi-project setup for the best professional development experience!**
# 👨‍💻 Developer Onboarding Checklist

Use this checklist when setting up your local development environment.

## 🎯 Choose Your Setup Method

### ⭐ Option A: Multi-Project Setup (Recommended)

**Perfect for:** Agencies, freelancers, teams working on multiple client projects

**Benefits:**
- ✅ Run multiple WordPress sites simultaneously  
- ✅ Complete project isolation
- ✅ No port conflicts
- ✅ Professional workflow
- ✅ Team collaboration ready

**📚 [Multi-Project Quick Start →](multi-project.md)**

### Option B: Single Project Setup (Traditional)

**Perfect for:** Single WordPress site development, learning, simple projects

---

## ✅ Pre-Setup (5 minutes)

- [ ] **Docker Desktop installed** ([Download](https://www.docker.com/products/docker-desktop))
  - Verify: `docker --version` returns v4.0+
  
- [ ] **Git installed and configured** ([Download](https://git-scm.com/))
  - Verify: `git --version`
  - Configure: `git config --global user.name "Your Name"`
  - Configure: `git config --global user.email "you@example.com"`

- [ ] **4GB+ RAM available** for Docker
  - Check Docker Desktop → Preferences → Resources

- [ ] **10GB free disk space** for containers and databases

---

## 🚀 Repository Setup (5 minutes)

- [ ] **Clone repository**
  ```bash
  git clone <repo-url>
  cd wp-starter-project
  ```

- [ ] **Create shared Docker network (One-time setup)**
  ```bash
  docker network create wordpress-shared
  ```
  This network is required for all WordPress projects to function properly.

- [ ] **Review setup guides**
  - [ ] **Multi-Project**: [multi-project.md](multi-project.md) ⭐ Recommended
  - [ ] **Single Project**: [quickstart.md](quickstart.md) - Traditional setup

- [ ] **Copy environment template**
  ```bash
  cp .env.example .env
  ```
  - Do NOT modify .env unless needed
  - Default values work for local development

---

## 🐳 Docker Setup (5-10 minutes)

### Option A: Automated Setup (Recommended)

- [ ] **Run setup script**
  
  **Mac/Linux:**
  ```bash
  # Copy repository to new project
  cp -r /path/to/wp-starter ~/my-projects/client-website
  cd ~/my-projects/client-website
  
  # Configure environment
  cp .env.example .env
  # Edit .env with your unique ports and project name
  
  # Start project  
  ./scripts/project-manager.sh start
  ```

  **Windows:**
  ```cmd
  # Copy repository to new project (or git clone)
  # Configure environment
  copy .env.example .env
  # Edit .env with your unique ports and project name
  
  # Start project
  scripts\project-manager.ps1 start
  ```- [ ] **Wait for completion**
  - Script will:
    - ✓ Check Docker daemon
    - ✓ Pull images
    - ✓ Build containers
    - ✓ Start services
    - ✓ Install dependencies
    - ✓ Take ~5-10 minutes

- [ ] **Verify setup completed**
  - Should show "Setup completed successfully!"

### Option B: Manual Setup

- [ ] **Start Docker containers**
  ```bash
  docker-compose up -d
  ```

- [ ] **Wait for WordPress to initialize** (2-3 minutes)
  ```bash
  docker-compose logs -f wordpress
  ```
  Look for: "WordPress is ready"

- [ ] **Install Composer dependencies**
  ```bash
  docker-compose exec wordpress composer install
  ```

---

## ✅ Verify Installation (5 minutes)

- [ ] **All containers running**
  ```bash
  docker-compose ps
  ```
  Should show all containers with status "Up"

- [ ] **WordPress working**
  ```bash
  docker-compose exec wordpress wp --info
  ```
  Should display WordPress version and PHP info

- [ ] **Access websites in browser**
  - [ ] http://localhost:8080 (WordPress site)
  - [ ] http://localhost:8080/wp/wp-admin (WordPress admin)
  - [ ] http://localhost:8081 (phpMyAdmin)
  - [ ] http://localhost:8025 (MailHog email)

- [ ] **Database connected**
  - Go to http://localhost:8081
  - Login with:
    - Username: `root`
    - Password: `root_secure_password`
  - Should see `wordpress_dev` database

---

## � Multi-Project Verification (Optional)

**If you chose multi-project setup, verify it works:**

- [ ] **Test project creation**
  ```powershell
  # Create a test project
  .\project-manager.ps1 create test-site 8090 "Test Site"
  ```

- [ ] **Verify project starts**
  ```powershell
  .\project-manager.ps1 start test-site
  ```

- [ ] **Check project isolation**
  - [ ] http://localhost:8090 (Test site)
  - [ ] http://localhost:8091 (Test phpMyAdmin)
  - Should be completely separate from main project

- [ ] **Test port management**
  ```powershell
  .\project-manager.ps1 ports
  .\project-manager.ps1 list
  ```

- [ ] **Clean up test project**
  ```powershell
  .\project-manager.ps1 stop test-site
  # Optional: Remove test project directory
  ```

- [ ] **Understand team workflow**
  - [ ] Each team member gets different port ranges
  - [ ] Projects are completely isolated
  - [ ] Multiple client sites can run simultaneously
  - [ ] Perfect for agency/freelance work

---

## 📖 Learn the Project (15-20 minutes)

- [ ] **Read README.md**
  - Architecture overview
  - Development workflow
  - Common tasks
  - Troubleshooting guide

- [ ] **Understanding the wp-config.php Setup**
  - [ ] Review `wp-config.php` (project root) - WPStarter-compatible configuration
  - [ ] Review `wp/wp-config.php` - WP-CLI compatibility layer that redirects to main config
  - [ ] Understand environment-driven configuration (no hardcoded values)
  - [ ] Note: This solves WPStarter + WP-CLI compatibility issues

- [ ] **Read [../guides/contributing.md](../guides/contributing.md)**
  - Git workflow
  - Code standards
  - Commit message format
  - Pull request process

- [ ] **Understand .gitignore**
  - What gets committed
  - What gets ignored
  - Why (security & reproducibility)

- [ ] **Review existing code**
  - Check out a branch
  - Look at theme/plugin structure
  - Study existing commits

---

## 🎨 Development Readiness (5 minutes)

- [ ] **Create a test file** (verify editing works)
  ```bash
  # Edit a theme file or create a test page
  # Verify changes appear in http://localhost:8080
  ```

- [ ] **Test Git workflow**
  ```bash
  # Create test branch
  git checkout -b test/setup-check
  
  # Make a change
  # Commit: git add . && git commit -m "test: verify setup"
  
  # Return to main branch
  git checkout develop
  ```

- [ ] **Understand WP Starter structure**
  - Where themes go: `wp-content/themes/`
  - Where plugins go: `wp-content/plugins/`
  - Where uploads go: `wp-content/uploads/` (git-ignored)
  - WordPress core location: `wp/` (auto-installed)

---

## 🔑 Important Notes

- [ ] **Remember**: `cp .env.example .env` creates your local config
  - This .env is in .gitignore (never commit!)
  - Each developer has their own .env

- [ ] **Remember**: Don't commit:
  - `.env` files
  - `vendor/` directory
  - `wp/` WordPress core
  - `node_modules/`
  - `wp-content/uploads/`

- [ ] **Remember**: DO commit:
  - Theme/plugin source code
  - `composer.json` (not composer.lock)
  - Docker configuration
  - Documentation

---

## 🆘 Troubleshooting

If you encounter issues:

1. **Check README.md troubleshooting section**
   - Most common issues are documented

2. **View logs**
   ```bash
   docker-compose logs -f
   docker-compose logs -f wordpress
   docker-compose logs -f nginx
   ```

3. **Restart everything**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

4. **Full reset** (loses all data)
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

5. **Ask team members**
   - Check existing issues
   - Ask in team channel
   - Reference CONTRIBUTING.md

---

## 📚 Quick Reference

### Common Commands

```bash
# Start environment
docker-compose up -d

# Stop environment (data preserved)
docker-compose down

# View logs
docker-compose logs -f

# Access container
docker-compose exec wordpress bash

# Run WP-CLI
docker-compose exec wordpress wp --info

# Install packages
docker-compose exec wordpress composer install

# Run tests/linting
make help  # See all Makefile commands
```

### Website Access

| Service | URL |
|---------|-----|
| WordPress | http://localhost:8080 |
| Admin | http://localhost:8080/wp/wp-admin |
| phpMyAdmin | http://localhost:8081 |
| MailHog | http://localhost:8025 |

### Important Directories

```
wp-content/themes/     ← Your theme development
wp-content/plugins/    ← Your plugin development
wp-content/uploads/    ← User uploads (git-ignored)
docker/                ← Docker configuration
vendor/                ← Composer packages (git-ignored)
wp/                    ← WordPress core (git-ignored)
```

---

## ✨ Done!

You're ready to start developing! 

### Next Steps:
1. Create your feature branch: `git checkout -b feature/your-feature`
2. Make your changes in `wp-content/themes/` or `wp-content/plugins/`
3. Test locally in browser
4. Commit and push: `git push origin feature/your-feature`
5. Create pull request
6. Wait for code review
7. Merge when approved!

---

## 📞 Need Help?

- **Setup issues**: See README.md → Troubleshooting
- **Development questions**: See [../guides/contributing.md](../guides/contributing.md)
- **Git workflow**: See [../guides/contributing.md](../guides/contributing.md) → Development Workflow
- **Docker issues**: See [../guides/docker-guide.md](../guides/docker-guide.md)
- **Team members**: Ask in your communication channel

---

**Congratulations! Your environment is ready. Happy coding!** 🚀

*Last updated: October 2025*

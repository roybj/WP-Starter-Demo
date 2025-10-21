# 👥 Contributing Guide

Thank you for contributing to this WordPress WP Starter project! This guide will help you get started and ensure consistency across the development team.

## 🎯 Multi-Project Development

This repository supports **multiple concurrent WordPress projects** - perfect for teams working on multiple client sites simultaneously.

**New to multi-project setup?** � [Multi-Project Quick Start Guide](QUICKSTART-MULTI-PROJECT.md)

## �📋 Table of Contents

### 🚀 Getting Started
- [Multi-Project Setup](#multi-project-setup) ⭐ **Recommended for teams**
- [Single Project Setup](#single-project-setup) - Traditional approach
- [Development Workflow](#development-workflow)

### 👥 Team Collaboration  
- [Multi-Project Team Workflow](#multi-project-team-workflow)
- [Code Standards](#code-standards)
- [Committing Changes](#committing-changes)

### 🛠️ Development
- [Plugin & Theme Development](#plugin--theme-development)
- [Database Changes](#database-changes)
- [Testing](#testing)
- [Deploying Changes](#deploying-changes)

---

## Multi-Project Setup

### 🚀 Quick Start (Recommended for Teams)

**Step 1: Get the project manager**
```bash
# Clone this repository once as a template
git clone <repo-url> wordpress-template
cd wordpress-template
```

**Step 2: Create your first project**
```powershell
# Windows PowerShell
.\project-manager.ps1 create client-acme 8080 "ACME Corp Website"
.\project-manager.ps1 start client-acme
# Access: http://localhost:8080
```

**Step 3: Create more projects as needed**
```powershell
.\project-manager.ps1 create personal-blog 8090 "My Blog"
.\project-manager.ps1 create ecommerce-site 8100 "E-commerce Project"
```

📚 **[Complete Multi-Project Guide →](MULTI-PROJECT-GUIDE.md)**

---

## Single Project Setup

### 1. Prerequisites

Before you start, ensure you have:

- **Docker Desktop** installed and running
- **Git** configured with your credentials
- **4GB+ RAM** allocated to Docker
- **Cloned the repository**

### 2. Initial Setup

**On Mac/Linux:**
```bash
```bash
git clone <repo-url>
cd wp-starter-project

# Setup (Mac/Linux)
cp .env.example .env
# Edit .env with your unique ports
./scripts/project-manager.sh start
```
```

**On Windows:**
```cmd
git clone <repo-url>
cd wp-starter-project

# Setup (Windows)
copy .env.example .env
# Edit .env with your unique ports
scripts\project-manager.ps1 start
```

### 3. Verify Setup

```bash
# Check Docker status
docker-compose ps

# Check WordPress
docker-compose exec wordpress wp --info

# Check site access
curl http://localhost:8080
```

---

## Development Workflow

### 1. Create a Feature Branch

```bash
# Always create branches from latest main/develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name
# OR
git checkout -b bugfix/issue-description
# OR
git checkout -b docs/documentation-updates
```

**Branch naming convention:**
- `feature/` - New features
- `bugfix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code refactoring
- `perf/` - Performance improvements

### 2. Make Your Changes

```bash
# Start your development
# Edit theme files, plugins, etc.
# Test locally

# View changes
git status
git diff
```

### 3. Test Locally

```bash
# View all containers
docker-compose ps

# Check logs
docker-compose logs -f

# Test your changes
# Visit http://localhost:8080

# Clear cache if needed
docker-compose exec wordpress wp cache flush
docker-compose exec wordpress wp redis-cli flush all
```

### 4. Commit Your Changes

```bash
# Stage changes
git add .

# Commit with clear message
git commit -m "feat: add new feature description"
git commit -m "fix: resolve issue with..."
git commit -m "docs: update README"

# Push to remote
git push origin feature/your-feature-name
```

**Commit message format:**
```
type(scope): subject

body

footer
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting
- `refactor:` - Code reorganization
- `perf:` - Performance improvement
- `test:` - Test changes
- `chore:` - Build/dependency updates

**Example:**
```
feat(plugins): add ACF Pro plugin for custom fields

- Install ACF Pro via Composer
- Configure ACF settings
- Add field groups for blog posts

Closes #123
```

### 5. Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# On GitHub/GitLab:
# 1. Click "Create Pull Request"
# 2. Fill in title and description
# 3. Link related issues (Closes #123)
# 4. Request reviewers
```

**PR Template:**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Performance improvement

## Testing
- [ ] Tested locally in Docker environment
- [ ] No database migrations required
- [ ] No breaking changes

## Checklist
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] Committed files reviewed (.gitignore)
- [ ] No secrets committed
- [ ] Cache cleared and tested
```

### 6. Review & Merge

```bash
# After approval:
# 1. Update your branch with latest main
git pull origin develop

# 2. Resolve any conflicts
# 3. Push updates
git push origin feature/your-feature-name

# 4. Merge on GitHub/GitLab or locally:
git checkout develop
git pull origin develop
git merge feature/your-feature-name
git push origin develop
```

---

## Multi-Project Team Workflow

### 🏢 Agency/Team Collaboration

**Scenario**: Multiple developers working on different client projects simultaneously.

#### 1. Project Assignment Strategy

```powershell
# Lead Developer: Assign port ranges to team members
# Developer A: Ports 8080-8089 (Client projects)
.\project-manager.ps1 create client-acme 8080 "ACME Corp"
.\project-manager.ps1 create client-techcorp 8081 "Tech Corp"

# Developer B: Ports 8090-8099 (E-commerce projects)  
.\project-manager.ps1 create ecommerce-fashion 8090 "Fashion Store"
.\project-manager.ps1 create ecommerce-electronics 8091 "Electronics Store"

# Developer C: Ports 8100-8109 (Internal projects)
.\project-manager.ps1 create company-blog 8100 "Company Blog"
.\project-manager.ps1 create internal-tools 8101 "Internal Tools"
```

#### 2. Daily Development Workflow

```powershell
# Morning: Start active client projects
.\project-manager.ps1 start client-acme      # Developer working on ACME
.\project-manager.ps1 start client-techcorp  # Developer working on Tech Corp

# During day: Switch between projects seamlessly
# http://localhost:8080 - ACME Corp demo
# http://localhost:8081 - Tech Corp development

# Evening: Stop resource-intensive projects
.\project-manager.ps1 stop client-techcorp
# Keep ACME running for tomorrow's client meeting
```

#### 3. Client Presentations

```powershell
# Before client meeting
.\project-manager.ps1 start client-acme

# During presentation
# Share screen: "Let me show you the site at http://localhost:8080"
# Client sees live development progress

# After meeting
.\project-manager.ps1 stop client-acme  # Free up resources
```

#### 4. Code Collaboration

```bash
# Each project has separate Git repository
cd ~/wordpress-projects/client-acme
git init
git remote add origin <client-acme-repo>
git push -u origin main

cd ~/wordpress-projects/client-techcorp  
git init
git remote add origin <client-techcorp-repo>
git push -u origin main

# Developers collaborate on specific client projects
# No mixing of client codebases
```

#### 5. Resource Management

```powershell
# Check system resources
.\project-manager.ps1 status

# Stop unused projects during intensive work
.\project-manager.ps1 list
.\project-manager.ps1 stop old-project

# Clean up completed projects
.\project-manager.ps1 clean
```

### 🎯 Team Best Practices

#### Port Assignment Convention

| Developer | Port Range | Project Types |
|-----------|------------|---------------|
| **Lead/Senior** | 8080-8089 | Client reviews, demonstrations |
| **Developer A** | 8090-8099 | Frontend projects |  
| **Developer B** | 8100-8109 | Backend/API projects |
| **Developer C** | 8110-8119 | E-commerce projects |
| **Intern/Junior** | 8120-8129 | Learning/practice projects |

#### Communication Protocol

```powershell
# Share project status in team chat
.\project-manager.ps1 ports
# "Current projects: client-acme (8080), ecommerce-site (8090)"

# Before client calls
# "Starting ACME demo on port 8080 for 2PM meeting"

# Resource conflicts
# "Need port 8080 for client demo - can someone move their test site?"
```

#### Project Handoffs

```powershell
# Developer A to Developer B project handoff
# 1. Document current project state
.\project-manager.ps1 ports > project-handoff.txt

# 2. Stop project locally  
.\project-manager.ps1 stop client-acme

# 3. Developer B creates same project
.\project-manager.ps1 create client-acme 8090 "ACME Corp - Handoff"

# 4. Pull latest code
cd ~/wordpress-projects/client-acme
git pull origin develop
```

---

## Code Standards

### PHP Code Standards

Follow [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/):

```php
// Good: Clear, descriptive variable names
$user_posts = get_posts( ['author' => $author_id] );

// Avoid: Abbreviations
$u_p = get_posts( ['author' => $a_id] );

// Good: Proper indentation (4 spaces)
if ( condition ) {
    do_something();
}

// Good: Hooks and filters
do_action( 'my_plugin_before_save' );
apply_filters( 'my_plugin_post_content', $content );
```

### Theme/Plugin Structure

```
wp-content/plugins/my-plugin/
├── my-plugin.php           # Main plugin file with header
├── composer.json           # If using Composer
├── src/
│   ├── Admin/
│   ├── Frontend/
│   └── Helpers/
├── templates/              # Theme files
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
├── tests/
├── README.md
└── .gitignore
```

### Documentation

- Add comments to complex functions
- Document all custom hooks and filters
- Update README.md for plugin changes
- Add inline comments for business logic

---

## Committing Changes

### Files to Commit

✅ **Always Commit:**
- Theme code (`wp-content/themes/your-theme/`)
- Plugin code (`wp-content/plugins/your-plugin/`)
- `composer.json` (dependencies)
- `docker/` configuration
- `README.md`, documentation
- `.gitignore` updates

❌ **Never Commit:**
- `.env` (environment configuration)
- `.env.cached.php` (generated)
- `vendor/` (Composer auto-installs)
- `wp/` (WordPress core, auto-installed)
- `wp-content/uploads/` (user uploads)
- `node_modules/` (npm auto-installs)

### Verify Before Committing

```bash
# Check what will be committed
git status
git diff

# Ensure .env is not included
git check-ignore .env  # Should show: .env

# View file sizes (catch accidental large files)
git diff --stat

# Dry-run commit to preview
git diff --cached --stat
```

---

## Plugin & Theme Development

### Installing a New Plugin

**Via Composer (Recommended for managed packages):**

```bash
# Find plugin on WPackagist
# Visit: https://wpackagist.org

# Install via Composer
docker-compose exec wordpress composer require wpackagist-plugin/plugin-name

# Commit changes
git add composer.json composer.lock wp-content/plugins/
git commit -m "feat(plugins): add plugin-name"
```

**Custom Plugin Development:**

```bash
# Create plugin directory
mkdir wp-content/plugins/my-custom-plugin
cd wp-content/plugins/my-custom-plugin

# Create plugin file
cat > my-custom-plugin.php << 'EOF'
<?php
/**
 * Plugin Name: My Custom Plugin
 * Description: Brief description
 * Version: 1.0.0
 * Author: Your Name
 * License: MIT
 */

// Plugin code here
EOF

# Commit
git add wp-content/plugins/my-custom-plugin/
git commit -m "feat(plugins): add my-custom-plugin"
```

### Developing a Theme

```bash
# Navigate to theme
cd wp-content/themes/your-theme

# For asset building
docker-compose exec nodejs npm install
docker-compose exec nodejs npm run build

# Watch for changes
docker-compose exec nodejs npm run watch
```

---

## Database Changes

### Exporting Database Changes

```bash
# Export database after making changes
docker-compose exec wordpress wp db export - > schema-changes.sql

# Review the SQL file before committing
git add schema-changes.sql
git commit -m "docs: database schema changes"
```

### Applying Changes to Team Database

```bash
# Team member receives changes
git pull origin feature/your-feature-name

# Apply database changes
docker-compose exec wordpress wp db import schema-changes.sql

# Verify
docker-compose exec wordpress wp db check
```

### Using Database Migrations

For complex changes, use a plugin like [WP Migrate](https://github.com/deliciousbrains/wp-migrate):

```bash
# Team member runs migrations
docker-compose exec wordpress wp migrate
```

---

## Testing

### Local Testing Checklist

Before pushing changes:

- [ ] **Functionality**: Feature works as expected
- [ ] **Responsive Design**: Works on mobile/tablet/desktop
- [ ] **Browser Compatibility**: Works in Chrome, Firefox, Safari
- [ ] **Cross-browser**: Works in different browsers
- [ ] **Error Logs**: No PHP/database errors
- [ ] **Performance**: No significant slowdown
- [ ] **Cache**: Cleared and tested
- [ ] **Security**: No hardcoded credentials, no XSS

### WordPress Debugging

```bash
# Enable debug logging
# Already enabled in .env for development

# View debug log
docker-compose exec wordpress tail -f wp-content/debug.log

# Clear debug log
docker-compose exec wordpress truncate -s 0 wp-content/debug.log

# Check database queries
docker-compose exec wordpress wp db query "SELECT * FROM wp_options WHERE option_name = 'debug_log'"
```

### Testing on Different Browsers

```bash
# Access site from different machines on same network
# Note the IP address
ifconfig  # Mac/Linux
ipconfig  # Windows

# Other developers can access:
http://YOUR_MACHINE_IP:8080
```

---

## Deploying Changes

### Pre-Deployment Checklist

Before deploying to production:

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] No database migrations conflicts
- [ ] No hardcoded URLs or credentials
- [ ] `.env` variables properly configured
- [ ] Backups taken
- [ ] Team notified

### Deployment Steps

```bash
# 1. Pull latest code
git pull origin main

# 2. Install/update dependencies
docker-compose exec wordpress composer install --no-dev

# 3. Run database migrations
docker-compose exec wordpress wp db check
docker-compose exec wordpress wp db repair

# 4. Clear all caches
docker-compose exec wordpress wp cache flush
docker-compose exec wordpress wp redis-cli flush all

# 5. Verify deployment
docker-compose exec wordpress wp --info
docker-compose exec wordpress wp plugin list
docker-compose exec wordpress wp theme list

# 6. Test site
curl -I https://yourdomain.com
```

### Rollback Procedure

```bash
# If issues occur:

# 1. Revert to previous commit
git revert <commit-hash>
git push origin main

# 2. Restore database backup
# (kept separately by your hosting provider)

# 3. Clear caches
docker-compose exec wordpress wp cache flush
```

---

## Common Workflows

### Syncing with Main Branch

```bash
# Keep your branch updated
git fetch origin
git rebase origin/develop

# Or merge (creates merge commit)
git merge origin/develop

# Push updated branch
git push origin feature/your-feature-name --force-with-lease
```

### Fixing Merge Conflicts

```bash
# If conflicts occur during rebase/merge
# Edit conflicting files, then:

git add resolved-file.txt
git rebase --continue

# OR for merge:
git add resolved-file.txt
git commit -m "fix: resolve merge conflicts"
```

### Stashing Changes

```bash
# Save uncommitted changes temporarily
git stash

# Switch branches without committing
git checkout develop

# Return to your branch
git checkout feature/your-feature-name

# Restore changes
git stash pop
```

---

## Questions?

- **Check README.md** for setup and development help
- **Review existing branches** for examples
- **Check Git history** for patterns: `git log --oneline`
- **Ask team members** in your communication channel

---

## Code of Conduct

- Be respectful to team members
- Review code objectively, not personally
- Ask questions rather than assuming
- Help newer team members learn
- Share knowledge and best practices

---

**Happy Coding! 🚀**

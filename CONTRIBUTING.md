# 👥 Contributing Guide

Thank you for contributing to this WordPress WP Starter project! This guide will help you get started and ensure consistency across the development team.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Committing Changes](#committing-changes)
- [Plugin & Theme Development](#plugin--theme-development)
- [Database Changes](#database-changes)
- [Testing](#testing)
- [Deploying Changes](#deploying-changes)

---

## Getting Started

### 1. Prerequisites

Before you start, ensure you have:

- **Docker Desktop** installed and running
- **Git** configured with your credentials
- **4GB+ RAM** allocated to Docker
- **Cloned the repository**

### 2. Initial Setup

**On Mac/Linux:**
```bash
# Clone repository
git clone <repo-url>
cd BB-WP_Template

# Run setup script
bash setup-dev.sh

# Follow the prompts to complete setup
```

**On Windows:**
```bash
# Clone repository
git clone <repo-url>
cd BB-WP_Template

# Run setup script
setup-dev.bat

# Follow the prompts to complete setup
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

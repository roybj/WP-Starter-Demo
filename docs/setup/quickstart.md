# ⚡ Quick Start Guide

Choose your preferred setup method:

## 🎯 Choose Your Setup

### Option A: Multi-Project Setup (⭐ Recommended)

**Perfect for agencies, freelancers, or multiple client projects**

Run unlimited WordPress sites simultaneously on different ports:

**📚 [Multi-Project Quick Start Guide](multi-project.md)**

- ✅ Multiple WordPress sites at once
- ✅ No port conflicts  
- ✅ Complete project isolation
- ✅ Professional workflow
- ✅ Team-friendly architecture

### Option B: Single Project Setup (Traditional)

**For single WordPress site development**

## Prerequisites

- Docker Desktop installed
- At least 4GB RAM available
- 10GB free disk space

## Step 1: Clone & Setup (30 seconds)

**Mac/Linux:**
```bash
git clone <repo-url>
cd BB-WP_Template
cp .env.example .env
bash setup-dev.sh
```

**Windows:**
```cmd
git clone <repo-url>
cd BB-WP_Template
copy .env.example .env
setup-dev.bat
```

## Step 2: Wait for Initialization (60-90 seconds)

The script will:
- ✓ Check Docker is running
- ✓ Pull Docker images
- ✓ Build containers
- ✓ Start services
- ✓ Install dependencies
- ✓ Initialize WordPress

## Step 3: Access Your Site (30 seconds)

Once the script completes, open in your browser:

| Service | URL |
|---------|-----|
| **WordPress** | http://localhost:8080 |
| **Admin** | http://localhost:8080/wp/wp-admin |
| **phpMyAdmin** | http://localhost:8081 |
| **MailHog** | http://localhost:8025 |

## Step 4: Complete WordPress Setup (Optional)

If WordPress shows installation screen:
1. Click "Let's go!"
2. Fill in site details (any values work for local dev)
3. Install WordPress
4. Log in with credentials

## Done! 🎉

Start developing on your site:
- Edit theme: `wp-content/themes/`
- Create plugins: `wp-content/plugins/`
- Commit to Git: files auto-excluded properly

## Common Commands

```bash
# View logs
docker-compose logs -f

# Access WordPress container
docker-compose exec wordpress bash

# Stop services
docker-compose down

# Full reset (warning: loses data)
docker-compose down -v

# Get help
make help

# Run WP-CLI commands
docker-compose exec wordpress wp plugin list
docker-compose exec wordpress wp theme list
```

## Need Help?

- **Multi-Project Setup**: See [multi-project.md](multi-project.md) ⭐
- **Complete Guide**: See [../guides/multi-project-workflows.md](../guides/multi-project-workflows.md)
- **Full documentation**: See [../../README.md](../../README.md)
- **Development guide**: See [../guides/contributing.md](../guides/contributing.md)
- **Setup issues**: Check [../../README.md #troubleshooting](../../README.md#getting-help)
- **Docker issues**: Check Docker Desktop logs

## What Got Installed?

✓ WordPress 6.8+  
✓ WP Starter 3.0 (Bedrock architecture)  
✓ Nginx web server  
✓ PHP 8.2  
✓ MySQL 8.0  
✓ Redis caching  
✓ phpMyAdmin for database  
✓ MailHog for email testing  
✓ Node.js for build tools  

All running locally in Docker! 🐳

---

**Ready to develop?** Start editing files in `wp-content/themes/` and `wp-content/plugins/`

**Happy coding!** 🚀

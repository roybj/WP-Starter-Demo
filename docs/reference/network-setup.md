# 🌐 Docker Network Setup Guide

## Overview

This WordPress development environment uses a shared Docker network (`wordpress-shared`) to enable communication between projects and shared services like MailHog.

## Why This Network is Required

The `wordpress-shared` network serves several purposes:

1. **Cross-project communication** - Allows multiple WordPress projects to use shared services
2. **MailHog integration** - Enables email testing across all projects
3. **Service isolation** - Provides secure communication between related containers
4. **Scalability** - Supports unlimited concurrent WordPress projects

## Automatic Setup

As of the latest version, the project manager scripts automatically create this network:

### PowerShell (Windows)
```powershell
scripts\project-manager.ps1 start
```

### Bash (Linux/macOS)
```bash
./scripts/project-manager.sh start
```

## Manual Setup

If you need to create the network manually:

```bash
docker network create wordpress-shared
```

## Verification

Check if the network exists:
```bash
docker network ls | grep wordpress-shared
```

Expected output:
```
NETWORK ID     NAME               DRIVER    SCOPE
515e6e4fbd1e   wordpress-shared   bridge    local
```

## Troubleshooting

### Error: "network wordpress-shared declared as external, but could not be found"

**Solution:**
```bash
# Create the missing network
docker network create wordpress-shared

# Restart your project
docker-compose down
docker-compose up -d
```

### MailHog Not Working

The MailHog service automatically creates the shared network when started:
```bash
docker-compose -f docker-compose.mailhog.yml up -d
```

### Network Already Exists Error

If you see "network with name wordpress-shared already exists", this is normal and expected. The scripts handle this gracefully.

## Network Architecture

```
wordpress-shared (External Network)
├── Project 1 containers
├── Project 2 containers  
├── Project N containers
└── shared-mailhog (Optional)
```

Each project also has its own isolated network:
- `{project-name}_network` (Internal project communications)

## Best Practices

1. **Don't delete the shared network** while projects are running
2. **Use project manager scripts** for consistent setup
3. **Check network status** if containers fail to start
4. **Recreate network** if experiencing communication issues

## Related Documentation

- [Multi-Project Setup](../setup/multi-project.md)
- [Docker Guide](../guides/docker-guide.md)
- [Troubleshooting](../guides/docker-guide.md#troubleshooting)
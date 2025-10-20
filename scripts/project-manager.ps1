# ============================================================================
# WordPress Multi-Project Manager (PowerShell)
# ============================================================================
# Easily manage multiple WordPress development projects on Windows
# Usage: .\project-manager.ps1 [create|start|stop|list|status|help] [args...]

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [string]$ProjectName = "",
    
    [Parameter(Position=2)]
    [int]$HttpPort = 0,
    
    [Parameter(Position=3)]
    [string]$Description = ""
)

# Configuration
$ProjectsBaseDir = "$env:USERPROFILE\wordpress-projects"
$PortsFile = "$ProjectsBaseDir\.port-assignments"
$TemplateRepo = Get-Location

# Colors
$Colors = @{
    Green = "`e[32m"
    Red = "`e[31m"
    Yellow = "`e[33m"
    Blue = "`e[34m"
    Reset = "`e[0m"
}

# Helper Functions
function Write-ColorText {
    param([string]$Text, [string]$Color = "Reset")
    Write-Host "$($Colors[$Color])$Text$($Colors.Reset)"
}

function Test-PortInUse {
    param([int]$Port)
    
    if (Test-Path $PortsFile) {
        $portAssignments = Get-Content $PortsFile
        return $portAssignments -match ":$Port:"
    }
    return $false
}

function Get-NextAvailablePort {
    param([int]$StartPort = 8080)
    
    $port = $StartPort
    while (Test-PortInUse -Port $port) {
        $port += 10
    }
    return $port
}

# Ensure projects directory exists
if (-not (Test-Path $ProjectsBaseDir)) {
    New-Item -ItemType Directory -Path $ProjectsBaseDir -Force | Out-Null
    Write-ColorText "✅ Created projects directory: $ProjectsBaseDir" "Green"
}

# Main Command Router
switch ($Command.ToLower()) {
    "create" { Create-Project }
    "start" { Start-Project }
    "stop" { Stop-Project }
    "list" { List-Projects }
    "status" { Show-Status }
    "ports" { Show-Ports }
    "clean" { Clean-Docker }
    "help" { Show-Help }
    default { Show-Help }
}

# ============================================================================
# CREATE NEW PROJECT
# ============================================================================
function Create-Project {
    if ([string]::IsNullOrEmpty($ProjectName)) {
        Write-ColorText "❌ Error: Project name is required" "Red"
        Write-Host "Usage: .\project-manager.ps1 create <project-name> <http-port> [description]"
        Write-Host "Example: .\project-manager.ps1 create client-acme 8080 'ACME Corp Website'"
        exit 1
    }

    if ($HttpPort -eq 0) {
        $HttpPort = Get-NextAvailablePort
        Write-ColorText "💡 Auto-assigned port: $HttpPort" "Yellow"
    }

    $ProjectDir = "$ProjectsBaseDir\$ProjectName"
    
    # Check if project exists
    if (Test-Path $ProjectDir) {
        Write-ColorText "❌ Error: Project '$ProjectName' already exists" "Red"
        exit 1
    }

    # Check port availability
    if (Test-PortInUse -Port $HttpPort) {
        Write-ColorText "❌ Error: Port $HttpPort is already in use" "Red"
        Write-Host "Run '.\project-manager.ps1 ports' to see current assignments"
        exit 1
    }

    Write-ColorText "🚀 Creating WordPress project: $ProjectName" "Blue"
    Write-Host "   Port: $HttpPort"
    Write-Host "   Directory: $ProjectDir"
    Write-Host ""

    # Copy template files
    Write-ColorText "📁 Copying template files..." "Yellow"
    Copy-Item -Path "$TemplateRepo\*" -Destination $ProjectDir -Recurse -Force -Exclude @('.git', 'docker-data', 'node_modules', 'vendor')

    # Create .env file
    Write-ColorText "⚙️ Configuring environment..." "Yellow"
    $PhpMyAdminPort = $HttpPort + 1
    
    $envContent = @"
# ============================================================================
# WordPress Project: $ProjectName
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# ============================================================================

# Project Identity
COMPOSE_PROJECT_NAME=$ProjectName
PROJECT_DESCRIPTION=$Description

# Port Configuration
HTTP_PORT=$HttpPort
PHPMYADMIN_PORT=$PhpMyAdminPort
MAILHOG_WEB_PORT=8025
MAILHOG_SMTP_PORT=1025
MYSQL_PORT=3306
REDIS_PORT=6379

# WordPress Configuration
WP_ENV=development
WP_HOME=http://localhost:$HttpPort
WP_SITEURL=http://localhost:$HttpPort/wp

# Database Configuration
DB_NAME=${ProjectName}_db
DB_USER=${ProjectName}_user
DB_PASSWORD=${ProjectName}_pass_$(Get-Random -Minimum 1000 -Maximum 9999)
DB_HOST=mysql
TABLE_PREFIX=wp_

# MySQL Root Password
MYSQL_ROOT_PASSWORD=root_pass_$(Get-Random -Minimum 1000 -Maximum 9999)

# Development Settings
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=false
DISALLOW_FILE_MODS=false

# Security Keys (generate unique keys at https://api.wordpress.org/secret-key/1.1/salt/)
AUTH_KEY='$ProjectName-auth-key-$(Get-Random)-$(Get-Random)'
SECURE_AUTH_KEY='$ProjectName-secure-auth-key-$(Get-Random)-$(Get-Random)'
LOGGED_IN_KEY='$ProjectName-logged-in-key-$(Get-Random)-$(Get-Random)'
NONCE_KEY='$ProjectName-nonce-key-$(Get-Random)-$(Get-Random)'
AUTH_SALT='$ProjectName-auth-salt-$(Get-Random)-$(Get-Random)'
SECURE_AUTH_SALT='$ProjectName-secure-auth-salt-$(Get-Random)-$(Get-Random)'
LOGGED_IN_SALT='$ProjectName-logged-in-salt-$(Get-Random)-$(Get-Random)'
NONCE_SALT='$ProjectName-nonce-salt-$(Get-Random)-$(Get-Random)'
"@

    $envContent | Out-File -FilePath "$ProjectDir\.env" -Encoding UTF8

    # Use multi-project docker-compose if available
    if (Test-Path "$ProjectDir\docker-compose.multi.yml") {
        Copy-Item "$ProjectDir\config\docker-compose.multi.yml" "$ProjectDir\docker-compose.yml" -Force
    }

    # Record port assignment
    "$ProjectName`:$HttpPort`:$PhpMyAdminPort`:$Description" | Add-Content -Path $PortsFile

    # Success message
    Write-Host ""
    Write-ColorText "✅ Project '$ProjectName' created successfully!" "Green"
    Write-Host ""
    Write-ColorText "📋 Project Information:" "Blue"
    Write-Host "   🌐 Website:      http://localhost:$HttpPort"
    Write-Host "   🗄️ phpMyAdmin:   http://localhost:$PhpMyAdminPort"  
    Write-Host "   📧 MailHog:      http://localhost:8025"
    Write-Host "   📁 Directory:    $ProjectDir"
    Write-Host ""
    Write-ColorText "🚀 Next Steps:" "Blue"
    Write-Host "   1. Start project:  .\project-manager.ps1 start $ProjectName"
    Write-Host "   2. Install WP:     Navigate to http://localhost:$HttpPort"
    Write-Host "   3. Develop:        Edit files in $ProjectDir"
    Write-Host ""
}

# ============================================================================
# START PROJECT
# ============================================================================
function Start-Project {
    if ([string]::IsNullOrEmpty($ProjectName)) {
        Write-ColorText "❌ Error: Project name is required" "Red"
        Write-Host "Usage: .\project-manager.ps1 start <project-name>"
        Write-Host "Example: .\project-manager.ps1 start client-acme"
        exit 1
    }

    $ProjectDir = "$ProjectsBaseDir\$ProjectName"
    if (-not (Test-Path $ProjectDir)) {
        Write-ColorText "❌ Error: Project '$ProjectName' not found" "Red"
        Write-Host "Available projects:"
        Get-ChildItem $ProjectsBaseDir -Directory | ForEach-Object { Write-Host "   $($_.Name)" }
        exit 1
    }

    Write-ColorText "🚀 Starting WordPress project: $ProjectName" "Blue"

    Push-Location $ProjectDir
    try {
        $result = docker-compose up -d 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Get ports from .env file
            $envContent = Get-Content ".env"
            $httpPort = ($envContent | Where-Object { $_ -match "HTTP_PORT=(.+)" }) -replace "HTTP_PORT=", ""
            $phpMyAdminPort = ($envContent | Where-Object { $_ -match "PHPMYADMIN_PORT=(.+)" }) -replace "PHPMYADMIN_PORT=", ""
            
            Write-Host ""
            Write-ColorText "✅ Project '$ProjectName' started successfully!" "Green"
            Write-Host ""
            Write-ColorText "🌐 Access URLs:" "Blue"
            Write-Host "   Website:      http://localhost:$httpPort"
            Write-Host "   phpMyAdmin:   http://localhost:$phpMyAdminPort"
            Write-Host "   MailHog:      http://localhost:8025"
            Write-Host ""
            Write-ColorText "📊 Container Status:" "Blue"
            docker-compose ps
        } else {
            Write-ColorText "❌ Failed to start project '$ProjectName'" "Red"
            Write-Host $result
        }
    }
    finally {
        Pop-Location
    }
}

# ============================================================================
# STOP PROJECT
# ============================================================================
function Stop-Project {
    if ([string]::IsNullOrEmpty($ProjectName)) {
        Write-ColorText "❌ Error: Project name is required" "Red"
        Write-Host "Usage: .\project-manager.ps1 stop <project-name>"
        exit 1
    }

    $ProjectDir = "$ProjectsBaseDir\$ProjectName"
    if (-not (Test-Path $ProjectDir)) {
        Write-ColorText "❌ Error: Project '$ProjectName' not found" "Red"
        exit 1
    }

    Write-ColorText "🛑 Stopping WordPress project: $ProjectName" "Blue"

    Push-Location $ProjectDir
    try {
        docker-compose down
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "✅ Project '$ProjectName' stopped successfully!" "Green"
        } else {
            Write-ColorText "❌ Failed to stop project '$ProjectName'" "Red"
        }
    }
    finally {
        Pop-Location
    }
}

# ============================================================================
# LIST PROJECTS
# ============================================================================
function List-Projects {
    Write-ColorText "📋 WordPress Development Projects" "Blue"
    Write-Host ""

    if (-not (Test-Path $ProjectsBaseDir)) {
        Write-Host "No projects directory found"
        return
    }

    Write-ColorText "📁 Available Projects:" "Blue"
    $projects = Get-ChildItem $ProjectsBaseDir -Directory
    if ($projects) {
        $projects | ForEach-Object { Write-Host "   $($_.Name)" }
    } else {
        Write-Host "   No projects found"
    }
    Write-Host ""

    Write-ColorText "🐳 Running Containers:" "Blue"
    try {
        $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "label=service" 2>$null
        if ($containers) {
            $containers | ForEach-Object { Write-Host $_ }
        } else {
            Write-Host "   No running containers"
        }
    } catch {
        Write-Host "   Docker not available"
    }
    Write-Host ""
}

# ============================================================================
# SHOW STATUS
# ============================================================================
function Show-Status {
    Write-ColorText "📊 WordPress Projects Status" "Blue"
    Write-Host ""

    Write-ColorText "🐳 Docker System:" "Blue"
    try {
        docker system df 2>$null
    } catch {
        Write-Host "Docker not available"
    }

    Write-Host ""
    Write-ColorText "🏃 Running Projects:" "Blue"
    try {
        $containers = docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" --filter "label=service" 2>$null
        if ($containers) {
            $containers | ForEach-Object { Write-Host $_ }
        } else {
            Write-Host "   No running projects"
        }
    } catch {
        Write-Host "   Docker not available"
    }
    Write-Host ""
}

# ============================================================================
# SHOW PORTS
# ============================================================================
function Show-Ports {
    Write-ColorText "🚪 Port Assignments" "Blue"
    Write-Host ""

    if (Test-Path $PortsFile) {
        Write-Host "Project Name          HTTP    phpMyAdmin    Description"
        Write-Host "========================================================"
        Get-Content $PortsFile | ForEach-Object {
            $parts = $_ -split ":"
            if ($parts.Length -ge 3) {
                $name = $parts[0].PadRight(20)
                $http = $parts[1].PadRight(8)
                $phpmyadmin = $parts[2].PadRight(12)
                $desc = if ($parts.Length -gt 3) { $parts[3] } else { "" }
                Write-Host "$name$http$phpmyadmin$desc"
            }
        }
    } else {
        Write-Host "No port assignments found"
        Write-Host "Create projects to see port allocations"
    }

    Write-Host ""
    Write-ColorText "📝 Port Range Recommendations:" "Blue"
    Write-Host "   Client Projects:      8080-8199 (HTTP), 8081-8200 (phpMyAdmin)"
    Write-Host "   Personal Projects:    8200-8299 (HTTP), 8201-8300 (phpMyAdmin)"
    Write-Host "   Experiments:          8300-8399 (HTTP), 8301-8400 (phpMyAdmin)"  
    Write-Host "   Team Projects:        8400-8499 (HTTP), 8401-8500 (phpMyAdmin)"
    Write-Host ""
}

# ============================================================================
# CLEAN DOCKER
# ============================================================================
function Clean-Docker {
    Write-ColorText "🧹 Cleaning up Docker resources..." "Yellow"
    Write-Host ""

    Write-Host "Removing stopped containers..."
    docker container prune -f

    Write-Host "Removing unused volumes..."  
    docker volume prune -f

    Write-Host "Removing unused networks..."
    docker network prune -f

    Write-Host "Removing unused images..."
    docker image prune -f

    Write-Host ""
    Write-ColorText "✅ Docker cleanup completed" "Green"
}

# ============================================================================
# SHOW HELP
# ============================================================================
function Show-Help {
    Write-Host ""
    Write-ColorText "🎯 WordPress Multi-Project Manager (PowerShell)" "Blue"
    Write-Host ""
    Write-ColorText "📖 Usage:" "Blue"
    Write-Host "   .\project-manager.ps1 <command> [arguments]"
    Write-Host ""
    Write-ColorText "📋 Commands:" "Blue"
    Write-Host "   create <name> [port] [desc]    Create new WordPress project"
    Write-Host "   start <name>                   Start existing project"  
    Write-Host "   stop <name>                    Stop running project"
    Write-Host "   list                           List all projects"
    Write-Host "   status                         Show system status"
    Write-Host "   ports                          Show port assignments"
    Write-Host "   clean                          Clean Docker resources"
    Write-Host "   help                           Show this help"
    Write-Host ""
    Write-ColorText "💡 Examples:" "Blue"
    Write-Host '   .\project-manager.ps1 create client-acme 8080 "ACME Website"'
    Write-Host "   .\project-manager.ps1 start client-acme"
    Write-Host "   .\project-manager.ps1 stop client-acme"
    Write-Host "   .\project-manager.ps1 list"
    Write-Host ""
    Write-ColorText "🌐 Access URLs (after starting):" "Blue"
    Write-Host "   Website:      http://localhost:<port>"
    Write-Host "   phpMyAdmin:   http://localhost:<port+1>"
    Write-Host "   MailHog:      http://localhost:8025"
    Write-Host ""
    Write-ColorText "📁 Projects Directory:" "Blue"
    Write-Host "   $ProjectsBaseDir"
    Write-Host ""
}
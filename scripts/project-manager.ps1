# WordPress Project Manager (Simplified) - Windows PowerShell
# Manage WordPress development projects (start/stop/status)
# Run from your project directory: scripts\project-manager.ps1 [command]

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    [Parameter(Position=1)]
    [string]$Service = ""
)

function Write-ColorText($Text, $Color = "White") {
    $colors = @{
        "Red" = [System.ConsoleColor]::Red
        "Green" = [System.ConsoleColor]::Green  
        "Yellow" = [System.ConsoleColor]::Yellow
        "Blue" = [System.ConsoleColor]::Blue
        "Cyan" = [System.ConsoleColor]::Cyan
        "White" = [System.ConsoleColor]::White
    }
    if ($colors.ContainsKey($Color)) {
        Write-Host $Text -ForegroundColor $colors[$Color]
    } else {
        Write-Host $Text
    }
}

function Get-ProjectInfo {
    if (-not (Test-Path ".env")) {
        Write-ColorText "[ERROR] .env file not found" "Red"
        exit 1
    }
    $envContent = Get-Content ".env"
    $script:ProjectName = ($envContent | Where-Object { $_ -match "COMPOSE_PROJECT_NAME=" } | ForEach-Object { ($_ -split "=")[1] }) -replace '"', ''
    if (-not $script:ProjectName) { $script:ProjectName = "wordpress-project" }
    $script:HttpPort = ($envContent | Where-Object { $_ -match "HTTP_PORT=" } | ForEach-Object { ($_ -split "=")[1] })
    if (-not $script:HttpPort) { $script:HttpPort = "8080" }
    $script:PhpMyAdminPort = ($envContent | Where-Object { $_ -match "PHPMYADMIN_PORT=" } | ForEach-Object { ($_ -split "=")[1] })
    if (-not $script:PhpMyAdminPort) { $script:PhpMyAdminPort = "8081" }
}

function Start-Project {
    Get-ProjectInfo
    Write-ColorText "[START] Starting WordPress project: $ProjectName" "Blue"
    if (-not (Test-Path ".env")) {
        Write-ColorText "[ERROR] .env file not found" "Red"
        exit 1
    }
    if (Test-Path "config\docker-compose.multi.yml") {
        Copy-Item "config\docker-compose.multi.yml" "docker-compose.yml" -Force
        Write-ColorText "[CONFIG] Using multi-project configuration" "Blue"
    }
    $runningContainers = docker-compose ps | Where-Object { $_ -match "Up" }
    if ($runningContainers) {
        Write-ColorText "[INFO] Project containers already running" "Yellow"
    } else {
        Write-ColorText "[DOCKER] Starting Docker containers..." "Blue"
        docker-compose up -d
    }
    Start-Sleep -Seconds 2
    Write-ColorText "[SUCCESS] Project started: $ProjectName" "Green"
    Write-Host ""
    Write-ColorText "[ACCESS] URLs:" "Blue"
    Write-Host "   Website:    http://localhost:$HttpPort"
    Write-Host "   WordPress:  http://localhost:$HttpPort/wp/wp-admin/"
    Write-Host "   phpMyAdmin: http://localhost:$PhpMyAdminPort"
}

function Stop-Project {
    Get-ProjectInfo
    Write-ColorText "[STOP] Stopping: $ProjectName" "Yellow"
    if (Test-Path "docker-compose.yml") {
        docker-compose down
        Write-ColorText "[SUCCESS] Project stopped" "Green"
    }
}

function Restart-Project {
    Stop-Project
    Start-Sleep -Seconds 1
    Start-Project
}

function Show-Status {
    Get-ProjectInfo
    Write-ColorText "[STATUS] Project: $ProjectName (Port: $HttpPort)" "Blue"
    if (Test-Path "docker-compose.yml") {
        docker-compose ps
    }
}

function Show-Logs {
    Get-ProjectInfo
    if ($Service) {
        Write-ColorText "[LOGS] Service: $Service" "Blue"
        docker-compose logs -f $Service
    } else {
        Write-ColorText "[LOGS] All services" "Blue"
        docker-compose logs -f
    }
}

function Start-MailHog {
    Write-ColorText "[MAILHOG] Starting..." "Blue"
    if (Test-Path "docker-compose.mailhog.yml") {
        docker-compose -f docker-compose.mailhog.yml up -d
        Write-ColorText "[SUCCESS] MailHog started" "Green"
        Write-Host "Web UI: http://localhost:8025"
    }
}

function Stop-MailHog {
    Write-ColorText "[MAILHOG] Stopping..." "Yellow"
    docker-compose -f docker-compose.mailhog.yml down
    Write-ColorText "[SUCCESS] MailHog stopped" "Green"
}

function Show-Help {
    Write-Host ""
    Write-ColorText "WordPress Project Manager" "Blue"
    Write-Host ""
    Write-Host "Usage: scripts\project-manager.ps1 [command]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  start              Start WordPress project"
    Write-Host "  stop               Stop WordPress project"
    Write-Host "  restart            Restart WordPress project"
    Write-Host "  status             Show project status"
    Write-Host "  logs [service]     Show logs (optional service)"
    Write-Host "  mailhog-start      Start MailHog service"
    Write-Host "  mailhog-stop       Stop MailHog service"
    Write-Host "  help               Show this help"
    Write-Host ""
}

$Command = $Command.ToLower()

switch ($Command) {
    "start" { Start-Project }
    "stop" { Stop-Project }
    "restart" { Restart-Project }
    "status" { Show-Status }
    "logs" { Show-Logs }
    "mailhog-start" { Start-MailHog }
    "mailhog-stop" { Stop-MailHog }
    "help" { Show-Help }
    default {
        Write-ColorText "[ERROR] Unknown command: $Command" "Red"
        Show-Help
    }
}

@echo off
REM ============================================================================
REM WordPress WP Starter - Developer Setup Script (Windows)
REM ============================================================================
REM This script automates the initial setup for developers on Windows
REM Run from project root: setup-dev.bat
REM ============================================================================

setlocal enabledelayedexpansion

REM Define colors using ANSI codes (requires Windows 10+)
set "BLUE=[36m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "RESET=[0m"

echo.
echo %BLUE%========================================%RESET%
echo %BLUE%WordPress WP Starter - Developer Setup%RESET%
echo %BLUE%========================================%RESET%
echo.

REM ============================================================================
REM Check Prerequisites
REM ============================================================================
echo %BLUE%Checking Prerequisites...%RESET%

where docker >nul 2>nul
if errorlevel 1 (
    echo %RED%✗ Docker is not installed%RESET%
    echo Please install Docker Desktop: https://www.docker.com/products/docker-desktop
    exit /b 1
)
echo %GREEN%✓ Docker found%RESET%

where docker-compose >nul 2>nul
if errorlevel 1 (
    echo %RED%✗ Docker Compose is not installed%RESET%
    exit /b 1
)
echo %GREEN%✓ Docker Compose found%RESET%

where git >nul 2>nul
if errorlevel 1 (
    echo %RED%✗ Git is not installed%RESET%
    exit /b 1
)
echo %GREEN%✓ Git found%RESET%

REM ============================================================================
REM Check if Docker daemon is running
REM ============================================================================
echo.
docker ps >nul 2>nul
if errorlevel 1 (
    echo %RED%✗ Docker daemon is not running%RESET%
    echo Please start Docker Desktop and try again
    exit /b 1
)
echo %GREEN%✓ Docker daemon is running%RESET%

REM ============================================================================
REM Setup .env file
REM ============================================================================
echo.
echo %BLUE%Setting up Environment Configuration...%RESET%

if exist ".env" (
    echo %YELLOW%⚠ .env file already exists%RESET%
    set /p REGEN="Do you want to regenerate .env? (y/n): "
    if /i "!REGEN!"=="y" (
        del .env
        echo Deleted existing .env
    ) else (
        echo Skipping .env creation
        goto :skip_env
    )
)

if not exist "config\.env.example" (
    echo %RED%✗ config\.env.example not found!%RESET%
    exit /b 1
)

copy config\.env.example .env >nul
echo %GREEN%✓ .env created from template%RESET%
echo %YELLOW%⚠ Review .env and update if needed%RESET%
echo.

:skip_env

REM ============================================================================
REM Pull latest Docker images
REM ============================================================================
echo.
echo %BLUE%Preparing Docker Images...%RESET%
set /p PULL="Do you want to pull latest Docker images? (y/n): "
if /i "!PULL!"=="y" (
    echo Pulling images...
    docker-compose pull
    echo %GREEN%✓ Images pulled%RESET%
) else (
    echo %YELLOW%⚠ Skipping image pull%RESET%
)

REM ============================================================================
REM Build containers
REM ============================================================================
echo.
echo %BLUE%Building Docker Containers...%RESET%
echo This may take 2-3 minutes on first run...
docker-compose build --no-cache wordpress
if errorlevel 1 (
    echo %RED%✗ Container build failed%RESET%
    exit /b 1
)
echo %GREEN%✓ Containers built%RESET%

REM ============================================================================
REM Start services
REM ============================================================================
echo.
echo %BLUE%Starting Docker Services...%RESET%
docker-compose up -d
if errorlevel 1 (
    echo %RED%✗ Failed to start services%RESET%
    exit /b 1
)
echo %GREEN%✓ Services started%RESET%

REM ============================================================================
REM Wait for services to be ready
REM ============================================================================
echo.
echo Waiting for services to initialize (this may take 1-2 minutes^)...

setlocal enabledelayedexpansion
set "RETRY=0"
set "MAX_RETRY=30"

:wait_loop
if !RETRY! geq !MAX_RETRY! goto :wait_done
docker-compose exec -T wordpress php -v >nul 2>nul
if errorlevel 0 (
    echo.
    echo %GREEN%✓ WordPress container is ready%RESET%
    goto :wait_done
)
set /a RETRY=!RETRY!+1
echo -n "."
timeout /t 2 /nobreak >nul 2>nul
goto :wait_loop

:wait_done
if !RETRY! geq !MAX_RETRY! (
    echo.
    echo %YELLOW%⚠ Services initialization may still be in progress%RESET%
    echo Check logs with: docker-compose logs wordpress
)

REM ============================================================================
REM Install Composer dependencies
REM ============================================================================
echo.
echo %BLUE%Installing Composer Dependencies...%RESET%
docker-compose exec -T wordpress composer install
if errorlevel 0 (
    echo %GREEN%✓ Composer dependencies installed%RESET%
) else (
    echo %RED%✗ Composer installation failed%RESET%
    echo Try manually: docker-compose exec wordpress composer install
)

REM ============================================================================
REM Verify WordPress installation
REM ============================================================================
echo.
echo %BLUE%Verifying WordPress Installation...%RESET%
docker-compose exec -T wordpress wp --info >nul 2>nul
if errorlevel 0 (
    echo %GREEN%✓ WordPress is installed and configured%RESET%
) else (
    echo %YELLOW%⚠ WordPress verification skipped%RESET%
)

REM ============================================================================
REM Summary
REM ============================================================================
echo.
echo %BLUE%========================================%RESET%
echo %BLUE%Setup Complete!%RESET%
echo %BLUE%========================================%RESET%
echo.
echo Your development environment is ready!
echo.
echo %BLUE%Access Your Services:%RESET%
echo   Website:    %GREEN%http://localhost:8080%RESET%
echo   WP Admin:   %GREEN%http://localhost:8080/wp/wp-admin%RESET%
echo   phpMyAdmin: %GREEN%http://localhost:8081%RESET%
echo   MailHog:    %GREEN%http://localhost:8025%RESET%
echo.
echo %BLUE%Common Commands:%RESET%
echo   docker-compose ps          - View container status
echo   docker-compose logs -f     - View live logs
echo   docker-compose exec wordpress bash  - Access container shell
echo.
echo %BLUE%Next Steps:%RESET%
echo   1. Complete WordPress installation at http://localhost:8080/wp/wp-admin/install.php
echo   2. Review README.md for development workflow
echo   3. Start developing! Happy coding!
echo.
echo %BLUE%Stop Services:%RESET%
echo   docker-compose down        - Stop services (data preserved^)
echo   docker-compose down -v     - Stop and remove all data
echo.
echo %GREEN%Setup completed successfully!%RESET%
echo.

endlocal

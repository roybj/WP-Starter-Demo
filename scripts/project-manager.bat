@echo off
:: ============================================================================
:: WordPress Multi-Project Manager for Windows
:: ============================================================================
:: Easily manage multiple WordPress development projects
:: Usage: project-manager.bat [create|start|stop|list|status|help] [args...]

setlocal EnableDelayedExpansion

:: Configuration
set "PROJECTS_BASE_DIR=%USERPROFILE%\wordpress-projects"
set "PORTS_FILE=%PROJECTS_BASE_DIR%\.port-assignments"
set "TEMPLATE_REPO=." 

:: Colors (if supported)
set "COLOR_GREEN=[32m"
set "COLOR_RED=[31m"
set "COLOR_YELLOW=[33m" 
set "COLOR_BLUE=[34m"
set "COLOR_RESET=[0m"

:: Create projects directory if it doesn't exist
if not exist "%PROJECTS_BASE_DIR%" (
    mkdir "%PROJECTS_BASE_DIR%"
    echo %COLOR_GREEN%✅ Created projects directory: %PROJECTS_BASE_DIR%%COLOR_RESET%
)

:: Parse command
set "COMMAND=%1"
if "%COMMAND%"=="" goto :help

:: Route to appropriate function
if "%COMMAND%"=="create" goto :create_project
if "%COMMAND%"=="start" goto :start_project  
if "%COMMAND%"=="stop" goto :stop_project
if "%COMMAND%"=="list" goto :list_projects
if "%COMMAND%"=="status" goto :status_projects
if "%COMMAND%"=="ports" goto :show_ports
if "%COMMAND%"=="clean" goto :cleanup_docker
if "%COMMAND%"=="help" goto :help
goto :help

:: ============================================================================
:: CREATE NEW PROJECT
:: ============================================================================
:create_project
set "PROJECT_NAME=%2"
set "HTTP_PORT=%3"
set "DESCRIPTION=%4"

if "%PROJECT_NAME%"=="" (
    echo %COLOR_RED%❌ Error: Project name is required%COLOR_RESET%
    echo Usage: project-manager.bat create ^<project-name^> ^<http-port^> [description]
    echo Example: project-manager.bat create client-acme 8080 "ACME Corp Website"
    exit /b 1
)

if "%HTTP_PORT%"=="" (
    echo %COLOR_RED%❌ Error: HTTP port is required%COLOR_RESET%
    echo Usage: project-manager.bat create ^<project-name^> ^<http-port^> [description]
    echo Example: project-manager.bat create client-acme 8080 "ACME Corp Website"
    exit /b 1
)

:: Check if project already exists
set "PROJECT_DIR=%PROJECTS_BASE_DIR%\%PROJECT_NAME%"
if exist "%PROJECT_DIR%" (
    echo %COLOR_RED%❌ Error: Project '%PROJECT_NAME%' already exists%COLOR_RESET%
    exit /b 1
)

:: Check if port is already in use
if exist "%PORTS_FILE%" (
    findstr /C:":%HTTP_PORT%:" "%PORTS_FILE%" >nul
    if !errorlevel! == 0 (
        echo %COLOR_RED%❌ Error: Port %HTTP_PORT% is already in use%COLOR_RESET%
        echo Run 'project-manager.bat ports' to see current assignments
        exit /b 1
    )
)

echo %COLOR_BLUE%🚀 Creating WordPress project: %PROJECT_NAME%%COLOR_RESET%
echo    Port: %HTTP_PORT%
echo    Directory: %PROJECT_DIR%
echo.

:: Copy template repository 
echo %COLOR_YELLOW%📁 Copying template files...%COLOR_RESET%
robocopy "%TEMPLATE_REPO%" "%PROJECT_DIR%" /E /XD .git docker-data node_modules vendor >nul

:: Create project-specific .env file
echo %COLOR_YELLOW%⚙️  Configuring environment...%COLOR_RESET%
set "PHPMYADMIN_PORT=%HTTP_PORT%"
set /a "PHPMYADMIN_PORT+=1"

(
echo # ============================================================================
echo # WordPress Project: %PROJECT_NAME%
echo # Generated: %date% %time%
echo # ============================================================================
echo.
echo # Project Identity
echo COMPOSE_PROJECT_NAME=%PROJECT_NAME%
echo PROJECT_DESCRIPTION=%DESCRIPTION%
echo.
echo # Port Configuration
echo HTTP_PORT=%HTTP_PORT%
echo PHPMYADMIN_PORT=!PHPMYADMIN_PORT!
echo MAILHOG_WEB_PORT=8025
echo MAILHOG_SMTP_PORT=1025
echo MYSQL_PORT=3306
echo REDIS_PORT=6379
echo.
echo # WordPress Configuration
echo WP_ENV=development
echo WP_HOME=http://localhost:%HTTP_PORT%
echo WP_SITEURL=http://localhost:%HTTP_PORT%/wp
echo.
echo # Database Configuration
echo DB_NAME=%PROJECT_NAME%_db
echo DB_USER=%PROJECT_NAME%_user
echo DB_PASSWORD=%PROJECT_NAME%_pass_%RANDOM%
echo DB_HOST=mysql
echo TABLE_PREFIX=wp_
echo.
echo # MySQL Root Password
echo MYSQL_ROOT_PASSWORD=root_pass_%RANDOM%
echo.
echo # Development Settings
echo WP_DEBUG=true
echo WP_DEBUG_LOG=true
echo WP_DEBUG_DISPLAY=false
echo DISALLOW_FILE_MODS=false
echo.
echo # Security Keys ^(generate unique keys at https://api.wordpress.org/secret-key/1.1/salt/^)
echo AUTH_KEY='%PROJECT_NAME%-auth-key-%RANDOM%-%RANDOM%'
echo SECURE_AUTH_KEY='%PROJECT_NAME%-secure-auth-key-%RANDOM%-%RANDOM%'
echo LOGGED_IN_KEY='%PROJECT_NAME%-logged-in-key-%RANDOM%-%RANDOM%'
echo NONCE_KEY='%PROJECT_NAME%-nonce-key-%RANDOM%-%RANDOM%'
echo AUTH_SALT='%PROJECT_NAME%-auth-salt-%RANDOM%-%RANDOM%'
echo SECURE_AUTH_SALT='%PROJECT_NAME%-secure-auth-salt-%RANDOM%-%RANDOM%'
echo LOGGED_IN_SALT='%PROJECT_NAME%-logged-in-salt-%RANDOM%-%RANDOM%'
echo NONCE_SALT='%PROJECT_NAME%-nonce-salt-%RANDOM%-%RANDOM%'
) > "%PROJECT_DIR%\.env"

:: Use multi-project docker-compose.yml
if exist "%PROJECT_DIR%\config\docker-compose.multi.yml" (
    copy "%PROJECT_DIR%\config\docker-compose.multi.yml" "%PROJECT_DIR%\docker-compose.yml" >nul
) else (
    echo %COLOR_YELLOW%⚠️  Warning: config\docker-compose.multi.yml not found, using default%COLOR_RESET%
)

:: Record port assignment
echo %PROJECT_NAME%:%HTTP_PORT%:!PHPMYADMIN_PORT!:%DESCRIPTION% >> "%PORTS_FILE%"

:: Display success message
echo.
echo %COLOR_GREEN%✅ Project '%PROJECT_NAME%' created successfully!%COLOR_RESET%
echo.
echo %COLOR_BLUE%📋 Project Information:%COLOR_RESET%
echo    🌐 Website:      http://localhost:%HTTP_PORT%
echo    🗄️  phpMyAdmin:   http://localhost:!PHPMYADMIN_PORT!
echo    📧 MailHog:      http://localhost:8025
echo    📁 Directory:    %PROJECT_DIR%
echo.
echo %COLOR_BLUE%🚀 Next Steps:%COLOR_RESET%
echo    1. Start project:  project-manager.bat start %PROJECT_NAME%
echo    2. Install WP:     Navigate to http://localhost:%HTTP_PORT%
echo    3. Develop:        Edit files in %PROJECT_DIR%
echo.
exit /b 0

:: ============================================================================
:: START PROJECT
:: ============================================================================
:start_project
set "PROJECT_NAME=%2"

if "%PROJECT_NAME%"=="" (
    echo %COLOR_RED%❌ Error: Project name is required%COLOR_RESET%
    echo Usage: project-manager.bat start ^<project-name^>
    echo Example: project-manager.bat start client-acme
    exit /b 1
)

set "PROJECT_DIR=%PROJECTS_BASE_DIR%\%PROJECT_NAME%"
if not exist "%PROJECT_DIR%" (
    echo %COLOR_RED%❌ Error: Project '%PROJECT_NAME%' not found%COLOR_RESET%
    echo Available projects:
    dir /B "%PROJECTS_BASE_DIR%" 2>nul || echo    No projects found
    exit /b 1
)

echo %COLOR_BLUE%🚀 Starting WordPress project: %PROJECT_NAME%%COLOR_RESET%

:: Change to project directory and start
pushd "%PROJECT_DIR%"
docker-compose up -d

if %errorlevel% == 0 (
    :: Get port from .env file
    for /f "tokens=2 delims==" %%i in ('findstr "HTTP_PORT=" .env') do set "HTTP_PORT=%%i"
    for /f "tokens=2 delims==" %%i in ('findstr "PHPMYADMIN_PORT=" .env') do set "PHPMYADMIN_PORT=%%i"
    
    echo.
    echo %COLOR_GREEN%✅ Project '%PROJECT_NAME%' started successfully!%COLOR_RESET%
    echo.
    echo %COLOR_BLUE%🌐 Access URLs:%COLOR_RESET%
    echo    Website:      http://localhost:!HTTP_PORT!
    echo    phpMyAdmin:   http://localhost:!PHPMYADMIN_PORT!
    echo    MailHog:      http://localhost:8025
    echo.
    echo %COLOR_BLUE%📊 Container Status:%COLOR_RESET%
    docker-compose ps
) else (
    echo %COLOR_RED%❌ Failed to start project '%PROJECT_NAME%'%COLOR_RESET%
)

popd
exit /b 0

:: ============================================================================
:: STOP PROJECT  
:: ============================================================================
:stop_project
set "PROJECT_NAME=%2"

if "%PROJECT_NAME%"=="" (
    echo %COLOR_RED%❌ Error: Project name is required%COLOR_RESET%
    echo Usage: project-manager.bat stop ^<project-name^>
    echo Example: project-manager.bat stop client-acme
    exit /b 1
)

set "PROJECT_DIR=%PROJECTS_BASE_DIR%\%PROJECT_NAME%"
if not exist "%PROJECT_DIR%" (
    echo %COLOR_RED%❌ Error: Project '%PROJECT_NAME%' not found%COLOR_RESET%
    exit /b 1
)

echo %COLOR_BLUE%🛑 Stopping WordPress project: %PROJECT_NAME%%COLOR_RESET%

pushd "%PROJECT_DIR%"
docker-compose down

if %errorlevel% == 0 (
    echo %COLOR_GREEN%✅ Project '%PROJECT_NAME%' stopped successfully!%COLOR_RESET%
) else (
    echo %COLOR_RED%❌ Failed to stop project '%PROJECT_NAME%'%COLOR_RESET%
)

popd
exit /b 0

:: ============================================================================
:: LIST ALL PROJECTS
:: ============================================================================ 
:list_projects
echo %COLOR_BLUE%📋 WordPress Development Projects%COLOR_RESET%
echo.

if not exist "%PROJECTS_BASE_DIR%" (
    echo No projects directory found
    exit /b 0
)

:: List project directories
echo %COLOR_BLUE%📁 Available Projects:%COLOR_RESET%
dir /B "%PROJECTS_BASE_DIR%" 2>nul | findstr /V ".port-assignments" || echo    No projects found
echo.

:: Show running containers
echo %COLOR_BLUE%🐳 Running Containers:%COLOR_RESET%
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "label=service" 2>nul || echo    No running containers
echo.

exit /b 0

:: ============================================================================
:: SHOW PROJECT STATUS
:: ============================================================================
:status_projects
echo %COLOR_BLUE%📊 WordPress Projects Status%COLOR_RESET%
echo.

:: Docker system info
echo %COLOR_BLUE%🐳 Docker System:%COLOR_RESET%
docker system df 2>nul || echo Docker not available

echo.
echo %COLOR_BLUE%🏃 Running Projects:%COLOR_RESET%
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" --filter "label=service" 2>nul || echo    No running projects

echo.
exit /b 0

:: ============================================================================
:: SHOW PORT ASSIGNMENTS
:: ============================================================================ 
:show_ports
echo %COLOR_BLUE%🚪 Port Assignments%COLOR_RESET%
echo.

if exist "%PORTS_FILE%" (
    echo Project Name          HTTP    phpMyAdmin    Description
    echo ========================================================
    for /f "tokens=1,2,3,* delims=:" %%a in (%PORTS_FILE%) do (
        echo %%a                 %%b      %%c           %%d
    )
) else (
    echo No port assignments found
    echo Create projects to see port allocations
)
echo.

echo %COLOR_BLUE%📝 Port Range Recommendations:%COLOR_RESET%
echo    Client Projects:      8080-8199 ^(HTTP^), 8081-8200 ^(phpMyAdmin^)
echo    Personal Projects:    8200-8299 ^(HTTP^), 8201-8300 ^(phpMyAdmin^)
echo    Experiments:          8300-8399 ^(HTTP^), 8301-8400 ^(phpMyAdmin^)
echo    Team Projects:        8400-8499 ^(HTTP^), 8401-8500 ^(phpMyAdmin^)
echo.
exit /b 0

:: ============================================================================
:: CLEANUP DOCKER RESOURCES
:: ============================================================================
:cleanup_docker
echo %COLOR_YELLOW%🧹 Cleaning up Docker resources...%COLOR_RESET%
echo.

echo Removing stopped containers...
docker container prune -f

echo Removing unused volumes...
docker volume prune -f

echo Removing unused networks...
docker network prune -f

echo Removing unused images...
docker image prune -f

echo.
echo %COLOR_GREEN%✅ Docker cleanup completed%COLOR_RESET%
exit /b 0

:: ============================================================================
:: SHOW HELP
:: ============================================================================
:help
echo.
echo %COLOR_BLUE%🎯 WordPress Multi-Project Manager%COLOR_RESET%
echo.
echo %COLOR_BLUE%📖 Usage:%COLOR_RESET%
echo    project-manager.bat ^<command^> [arguments]
echo.
echo %COLOR_BLUE%📋 Commands:%COLOR_RESET%
echo    create ^<name^> ^<port^> [desc]    Create new WordPress project
echo    start ^<name^>                   Start existing project
echo    stop ^<name^>                    Stop running project
echo    list                           List all projects
echo    status                         Show system status
echo    ports                          Show port assignments
echo    clean                          Clean Docker resources
echo    help                           Show this help
echo.
echo %COLOR_BLUE%💡 Examples:%COLOR_RESET%
echo    project-manager.bat create client-acme 8080 "ACME Website"
echo    project-manager.bat start client-acme
echo    project-manager.bat stop client-acme
echo    project-manager.bat list
echo.
echo %COLOR_BLUE%🌐 Access URLs ^(after starting^):%COLOR_RESET%
echo    Website:      http://localhost:^<port^>
echo    phpMyAdmin:   http://localhost:^<port+1^>  
echo    MailHog:      http://localhost:8025
echo.
echo %COLOR_BLUE%📁 Projects Directory:%COLOR_RESET%
echo    %PROJECTS_BASE_DIR%
echo.
exit /b 0
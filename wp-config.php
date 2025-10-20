<?php
/**
 * WordPress Configuration File (WPStarter)
 *
 * This file is automatically loaded by WPStarter and contains
 * the configuration for this WordPress installation.
 * 
 * All configuration is driven by environment variables from .env file
 * No hardcoded values - supports multiple projects with different configurations
 */

// Composer autoloader
require_once __DIR__ . '/vendor/autoload.php';

// Load environment variables from .env file
if (file_exists(__DIR__ . '/.env')) {
    $dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
    $dotenv->load();
}

// Helper function to get environment variables (required values have no defaults)
function env($key, $default = null) {
    $value = $_ENV[$key] ?? getenv($key);
    
    if ($value === false || $value === null) {
        if ($default === null) {
            throw new Exception("Required environment variable {$key} is not set. Please check your .env file.");
        }
        return $default;
    }
    
    return $value;
}

// Database Settings - All required from environment
define('DB_NAME', env('DB_NAME'));
define('DB_USER', env('DB_USER'));
define('DB_PASSWORD', env('DB_PASSWORD'));
define('DB_HOST', env('DB_HOST'));
define('DB_CHARSET', env('DB_CHARSET', 'utf8mb4'));
define('DB_COLLATE', env('DB_COLLATE', ''));
$table_prefix = env('TABLE_PREFIX', 'wp_');

// WordPress URLs - Required from environment
define('WP_HOME', env('WP_HOME'));
define('WP_SITEURL', env('WP_SITEURL'));

// Custom Content Directory (WPStarter structure)
define('WP_CONTENT_DIR', __DIR__ . '/wp-content');
define('WP_CONTENT_URL', WP_HOME . '/wp-content');

// Security Keys - All required from environment for security
define('AUTH_KEY', env('AUTH_KEY'));
define('SECURE_AUTH_KEY', env('SECURE_AUTH_KEY'));
define('LOGGED_IN_KEY', env('LOGGED_IN_KEY'));
define('NONCE_KEY', env('NONCE_KEY'));
define('AUTH_SALT', env('AUTH_SALT'));
define('SECURE_AUTH_SALT', env('SECURE_AUTH_SALT'));
define('LOGGED_IN_SALT', env('LOGGED_IN_SALT'));
define('NONCE_SALT', env('NONCE_SALT'));

// WordPress Debug Settings - Environment driven
define('WP_DEBUG', filter_var(env('WP_DEBUG', 'false'), FILTER_VALIDATE_BOOLEAN));
define('WP_DEBUG_LOG', filter_var(env('WP_DEBUG_LOG', 'false'), FILTER_VALIDATE_BOOLEAN));
define('WP_DEBUG_DISPLAY', filter_var(env('WP_DEBUG_DISPLAY', 'false'), FILTER_VALIDATE_BOOLEAN));
define('SCRIPT_DEBUG', WP_DEBUG);

// Additional WordPress Settings - Environment driven
define('WP_MEMORY_LIMIT', env('WP_MEMORY_LIMIT', '256M'));
define('DISALLOW_FILE_EDIT', filter_var(env('DISALLOW_FILE_EDIT', 'false'), FILTER_VALIDATE_BOOLEAN));
define('DISALLOW_FILE_MODS', filter_var(env('DISALLOW_FILE_MODS', 'false'), FILTER_VALIDATE_BOOLEAN));
define('AUTOMATIC_UPDATER_DISABLED', filter_var(env('AUTOMATIC_UPDATER_DISABLED', 'false'), FILTER_VALIDATE_BOOLEAN));

// Environment Type
$wp_env = env('WP_ENV', 'production');
define('WP_ENVIRONMENT_TYPE', $wp_env);

// Environment-specific settings
if ($wp_env === 'development') {
    // Development-specific settings
    if (!defined('SAVEQUERIES')) {
        define('SAVEQUERIES', filter_var(env('SAVEQUERIES', 'true'), FILTER_VALIDATE_BOOLEAN));
    }
    
    // Optional development features
    if (env('WP_CACHE', 'true') === 'false') {
        define('WP_CACHE', false);
    }
    
    if (filter_var(env('ALLOW_UNFILTERED_UPLOADS', 'false'), FILTER_VALIDATE_BOOLEAN)) {
        define('ALLOW_UNFILTERED_UPLOADS', true);
    }
}

// Redis Configuration (if available and configured)
if (extension_loaded('redis') && env('WP_REDIS_HOST', false)) {
    define('WP_REDIS_HOST', env('WP_REDIS_HOST'));
    define('WP_REDIS_PORT', (int) env('WP_REDIS_PORT', 6379));
    define('WP_REDIS_DATABASE', (int) env('WP_REDIS_DATABASE', 0));
    define('WP_CACHE_KEY_SALT', env('WP_CACHE_KEY_SALT', WP_HOME));
}

// Multisite Configuration (if enabled in environment)
if (filter_var(env('WP_MULTISITE', 'false'), FILTER_VALIDATE_BOOLEAN)) {
    define('WP_ALLOW_MULTISITE', true);
    
    if (env('MULTISITE_DOMAIN', false)) {
        define('DOMAIN_CURRENT_SITE', env('MULTISITE_DOMAIN'));
    }
    
    if (env('MULTISITE_PATH', false)) {
        define('PATH_CURRENT_SITE', env('MULTISITE_PATH'));
    }
}

// WordPress absolute path
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/wp/');
}

// Bootstrap WordPress
require_once ABSPATH . 'wp-settings.php';
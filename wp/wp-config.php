<?php
/**
 * WordPress Configuration File (WP Directory)
 *
 * This file redirects to the main wp-config.php in the project root
 * for WPStarter compatibility while maintaining WP-CLI compatibility.
 */

// Load the main wp-config.php from project root
require_once dirname(__DIR__) . '/wp-config.php';
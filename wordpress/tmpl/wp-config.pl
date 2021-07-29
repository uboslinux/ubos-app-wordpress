#!/usr/bin/perl
#
# Fix permissions.
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Utils;

{
    # This gets evaluated twice per Wordpress appconfig: once during the
    # check phase, and once during the install phase.
    # There may be a better way of doing this.

    no warnings 'redefine';

    sub _generateRandomWpSecret {
        my $ret = '';

        for( my $i=0 ; $i<64 ; ++$i ) {
            my $found = chr( ord( ' ' ) + rand( 0x5F )); # I think ...
            if( $found eq '\'' || $found eq '\\' ) {
                $found = '\\' . $found;
            }
            $ret .= $found;
        }
        return $ret;
    }
}

my $hostname    = $config->getResolve( 'site.hostname' );
my $context     = $config->getResolve( 'appconfig.context' );
my $dir         = $config->getResolve( 'appconfig.apache2.dir' );
my $appconfigid = $config->getResolve( 'appconfig.appconfigid' );

my $dbname = $config->getResolve( 'appconfig.mysql.dbname.maindb' );
my $dbuser = $config->getResolve( 'appconfig.mysql.dbuser.maindb' );
my $dbpass = $config->getResolve( 'appconfig.mysql.dbusercredential.maindb' );
my $dbhost = $config->getResolve( 'appconfig.mysql.dbhost.maindb' );

my $apacheUname = $config->getResolve( 'apache2.uname' );
my $apacheGname = $config->getResolve( 'apache2.gname' );

my $secret1 = _generateRandomWpSecret();
my $secret2 = _generateRandomWpSecret();
my $secret3 = _generateRandomWpSecret();
my $secret4 = _generateRandomWpSecret();
my $secret5 = _generateRandomWpSecret();
my $secret6 = _generateRandomWpSecret();
my $secret7 = _generateRandomWpSecret();
my $secret8 = _generateRandomWpSecret();

my $ret = <<RET;
<?php
//
// Config file fragment for app Wordpress at $hostname$context
//

define('WP_HOME',  (\$_SERVER['HTTPS'] ? 'https://' : 'http://' ) . \$_SERVER['HTTP_HOST'] . '$context' );

define('WP_SITEURL', WP_HOME );

define('DB_NAME',     '$dbname');
define('DB_USER',     '$dbuser');
define('DB_PASSWORD', '$dbpass');
define('DB_HOST',     '$dbhost');

\$table_prefix  = 'wp_';   // Staying with the default so imports are easier
define('WP_CORE_UPDATE', false ); // seems a bug with current Wordpress; lots of reports on-line
define('WP_CONTENT_DIR', '$dir/wp-content' ); // no trailing slash, full paths only

define('AUTH_KEY',         '$secret1');
define('SECURE_AUTH_KEY',  '$secret2');
define('LOGGED_IN_KEY',    '$secret3');
define('NONCE_KEY',        '$secret4');
define('AUTH_SALT',        '$secret5');
define('SECURE_AUTH_SALT', '$secret6');
define('LOGGED_IN_SALT',   '$secret7');
define('NONCE_SALT',       '$secret8');

define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
define('WPLANG', '');
define('WP_DEBUG', false);

require( 'wp-settings.php' );

// disable automatic updates per
// https://plugins.trac.wordpress.org/browser/disable-wordpress-core-update/trunk/disable-core-update.php
// https://plugins.trac.wordpress.org/browser/disable-wordpress-plugin-updates/trunk/disable-plugin-updates.php

remove_action( 'load-update-core.php', 'wp_update_plugins' );
define( 'AUTOMATIC_UPDATER_DISABLED', true );

RET

$ret;

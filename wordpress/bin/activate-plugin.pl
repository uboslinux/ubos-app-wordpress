#!/usr/bin/perl
#
# Activate a Wordpress plugin. Only invoke from ubos-manifest.json.
# Watch out for quotes etc. Perl and PHP use the same way of naming variables.
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

my $pluginName = $config->getResolve( 'installable.accessoryinfo.accessoryid' );

my $dir      = $config->getResolve( 'appconfig.apache2.dir' );
my $hostname = $config->getResolve( 'site.hostname' );

if( '*' eq $hostname ) {
    $hostname = 'localhost'; # best we can do
}

my $cmd  =  'HTTP_HOST='     . $hostname;
$cmd    .= ' REQUEST_URI='   . $config->getResolve( 'appconfig.context' );
$cmd    .= ' APPCONFIG_DIR=' . $dir;
$cmd    .= ' php';
$cmd    .= ' -d "open_basedir=\'/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/:/usr/share/wordpress/wordpress/\'"';
        # use default open_basedir and append Wordpress

# Replace Perl variable
my $php = <<PHP;
<?php
require_once( '$dir/wp-blog-header.php' );
require_once( '$dir/wp-admin/includes/plugin.php' );

\$current = get_option( 'active_plugins' );
\$plugin  = '$pluginName/$pluginName.php';

PHP

if( 'install' eq $operation ) {

    # Do not replace Perl variable
    $php .= <<'PHP';
$ret = activate_plugins( $plugin, false, false );
PHP

} else {

    # Do not replace Perl variable
    $php .= <<'PHP';
$ret = deactivate_plugins( $plugin, false, false );
PHP
    }

my $out = '';
my $err = '';

# pipe PHP in from stdin
trace( 'About to execute PHP', $php );

if( UBOS::Utils::myexec( $cmd, $php, \$out, \$err ) != 0 ) {
    error( "Activating plugin $pluginName failed:", $err );
}

1;

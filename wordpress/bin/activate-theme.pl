#!/usr/bin/perl
#
# Activate a Wordpress theme. Only invoke from ubos-manifest.json.
# Watch out for quotes etc. Perl and PHP use the same way of naming variables.
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Utils;

my $themeName;
if( 'install' eq $operation ) {
    $themeName = $config->getResolve( 'installable.accessoryinfo.accessoryid' );
}
unless( $themeName ) {
    $themeName = 'twentysixteen';
}

my $dir      = $config->getResolve( 'appconfig.apache2.dir' );
my $hostname = $config->getResolve( 'site.hostname' );

if( '*' eq $hostname ) {
    $hostname = 'localhost'; # best we can do
}

my $cmd  =  'HTTP_HOST='     . $hostname;
$cmd    .= ' REQUEST_URI='   . $config->getResolve( 'appconfig.context' );
$cmd    .= ' APPCONFIG_DIR=' . $dir;
$cmd    .= ' php';
$cmd    .= ' -d "open_basedir=\'/ubos/http/:/tmp/:/usr/share/pear/:/ubos/share/wordpress/wordpress/\'"';

# need to replace Perl variable with string in this PHP
my $php = <<PHP;
<?php
require_once( '${dir}/wp-blog-header.php' );

switch_theme( '$themeName', '$themeName' );
PHP

my $out = '';
my $err = '';

trace( "About to execute PHP:", $php );

if( UBOS::Utils::myexec( $cmd, $php, \$out, \$err ) != 0 ) {
    error( "Activating theme $themeName failed:", $err );
}

1;

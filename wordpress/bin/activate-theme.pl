#!/usr/bin/perl
#
# Activate a Wordpress theme. Only invoke from ubos-manifest.json.
# Watch out for quotes etc. Perl and PHP use the same way of naming variables.
#

use strict;

use UBOS::Utils;

my $themeName;
if( 'deploy' eq $operation ) {
    $themeName = $config->getResolve( 'installable.accessoryinfo.accessoryid' );
}
unless( $themeName ) {
    $themeName = 'twentyfourteen';
}

my $dir  = $config->getResolve( 'appconfig.apache2.dir' );
my $cmd  =  'HTTP_HOST='     . $config->getResolve( 'site.hostname' );
$cmd    .= ' REQUEST_URI='   . $config->getResolve( 'appconfig.context' );
$cmd    .= ' APPCONFIG_DIR=' . $dir;
$cmd    .= ' php';
$cmd    .= ' -d "open_basedir=\'/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/:/usr/share/wordpress/wordpress/\'"';

# need to replace Perl variable with string in this PHP
my $php = <<PHP;
<?php
require_once( '${dir}/wp-blog-header.php' );

switch_theme( '$themeName', '$themeName' );
PHP

my $out = '';
my $err = '';

debug( "About to execute PHP:", $php );

if( UBOS::Utils::myexec( $cmd, $php, \$out, \$err ) != 0 ) {
    error( "Activating theme $themeName failed:", $err );
}

1;

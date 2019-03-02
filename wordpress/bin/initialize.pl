#!/usr/bin/perl
#
# Initialize freshly installed Wordpress. Only invoke from ubos-manifest.json.
#
# Watch out for quotes etc. Perl and PHP use the same way of naming variables.
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;

use UBOS::Logging;
use UBOS::Utils;

if( 'install' eq $operation ) {
    my $dir      = $config->getResolve( 'appconfig.apache2.dir' );
    my $hostname = $config->getResolve( 'site.hostname' );

    if( '*' eq $hostname ) {
        $hostname = 'localhost'; # best we can do
    }

    my $cmd  = "cd $dir/wp-admin ;";
    $cmd    .= ' HTTP_HOST='     . $hostname;
    $cmd    .= ' REQUEST_URI='   . $config->getResolve( 'appconfig.context' );
    $cmd    .= ' APPCONFIG_DIR=' . $dir;
    $cmd    .= ' php';
    $cmd    .= ' -d "open_basedir=\'/ubos/http/:/tmp/:/ubos/tmp/:/usr/share/pear/:/ubos/share/wordpress/wordpress/\'"';
        # use default open_basedir and append Wordpress

    my $title      = $config->getResolve( 'installable.customizationpoints.title.value' );
    my $adminname  = $config->getResolve( 'site.admin.userid' );
    my $adminpass  = $config->getResolve( 'site.admin.credential' );
    my $adminemail = $config->getResolve( 'site.admin.email' );

    $title      = UBOS::Utils::escapeSquote( $title );
    $adminname  = UBOS::Utils::escapeSquote( $adminname );
    $adminpass  = UBOS::Utils::escapeSquote( $adminpass );
    $adminemail = UBOS::Utils::escapeSquote( $adminemail );

    my $php = <<PHP;
<?php
\$_SERVER['SERVER_PROTOCOL'] = 'HTTP/1.1';
\$_SERVER['SERVER_NAME']     = '$hostname';
\$_SERVER['PHP_SELF']        = 'wp-admin/install.php';

\$_GET['step'] = 2;

\$_POST['weblog_title']    = '$title';
\$_POST['user_name']       = '$adminname';
\$_POST['admin_password']  = '$adminpass';
\$_POST['admin_password2'] = \$_POST['admin_password'];
\$_POST['admin_email']     = '$adminemail';
\$_POST['Submit']          = 'Install WordPress';
\$_POST['language']        = '';

require_once( 'install.php' );
PHP

    my $out = '';
    my $err = '';

    # pipe PHP in from stdin
    trace( 'About to execute PHP', $php );

    if( UBOS::Utils::myexec( $cmd, $php, \$out, \$err ) != 0 ) {
        error( 'Initializing Wordpress failed:', $err );
    }
}

1;

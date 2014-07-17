#!/usr/bin/perl
#
# Trigger a Wordpress database upgrade. Only invoke from indie-box-manifest.json.
#
# Watch out for quotes etc. Perl and PHP use the same way of naming variables.
#

use strict;

use IndieBox::Logging;
use IndieBox::Utils;

if( 'upgrade' eq $operation ) {
    my $dir  = $config->getResolve( 'appconfig.apache2.dir' );
    my $cmd  = "cd $dir/wp-admin ;";
    $cmd    .= ' HTTP_HOST='     . $config->getResolve( 'site.hostname' );
    $cmd    .= ' REQUEST_URI='   . $config->getResolve( 'appconfig.context' );
    $cmd    .= ' APPCONFIG_DIR=' . $dir;
    $cmd    .= ' php';
    $cmd    .= ' -d "open_basedir=\'/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/:/usr/share/wordpress/wordpress/\'"';
        # use default open_basedir and append Wordpress

    my $php = <<PHP;
<?php
\$_SERVER['SERVER_PROTOCOL'] = 'HTTP/1.1';
\$_SERVER['PHP_SELF']        = 'wp-admin/install.php';

\$_GET['step'] = 1;

require_once( '../wp-blog-header.php' );
require_once( 'upgrade.php' );
PHP

    my $out = '';
    my $err = '';

    # pipe PHP in from stdin
    debug( 'About to execute PHP', $php );

    if( IndieBox::Utils::myexec( $cmd, $php, \$out, \$err ) != 0 ) {
        error( 'Upgrading Wordpress failed:', $err );
    }
}

1;

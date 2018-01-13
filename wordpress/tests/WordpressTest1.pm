#!/usr/bin/perl
#
# Simple test for Wordpress
#
# Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
#

use strict;
use warnings;

package WordpressTest1;

use UBOS::WebAppTest;

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'wordpress',
    description => 'Tests whether Wordpress comes up',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;
                        
                        $c->getMustContain(    '/', 'This is your first post', undef, 'Wrong front page' );

                        my $robotsTxt = $c->absGet( '/robots.txt' );
                        $c->mustMatch( $robotsTxt, '(?m)^Disallow:.*' . quotemeta( $c->context() . '/wp-admin/' ) . '$', 'robots.txt contribution wrong' );

                        return 1;
                    }
            )
    ]
);

$TEST;

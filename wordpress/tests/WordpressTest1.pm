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
use UBOS::WebAppTest::TestContext;

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'wordpress',
    description => 'Tests whether Wordpress comes up',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $frontResponse = $c->get( '/' );
                        if( !$c->contains( $frontResponse, 'This is your first post' ) && !$c->contains( $frontResponse, 'Hello world!' )) {
                            UBOS::WebAppTest::TestContextdebugResponse( $frontResponse );
                            $c->myerror( 'Wrong front page', 'Response content does not contain correct front page' );
                        }

                        my $robotsTxt = $c->absGet( '/robots.txt' );
                        $c->mustMatch( $robotsTxt, '(?m)^Disallow:.*' . quotemeta( $c->context() . '/wp-admin/' ) . '$', 'robots.txt contribution wrong' );

                        return 1;
                    }
            )
    ]
);

$TEST;

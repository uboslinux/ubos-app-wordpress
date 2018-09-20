#!/usr/bin/perl
#
# Simple test for Wordpress IndieWeb functionality
#

use strict;
use warnings;

package Test1;

use UBOS::WebAppTest;

##
# Helper to invoke uf2py
sub _ufGetParse {
}

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'wordpress',
    accessoriesToTest => [
            'wordpress-plugin-indieweb',
            'wordpress-plugin-semantic-linkbacks',
            'wordpress-plugin-webmention'
    ],
    description => 'Tests whether Wordpress comes up',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;
                        
                        return 1;
                    }
            )
    ]
);

$TEST;

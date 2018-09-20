#!/usr/bin/perl
#
# Check that Wordpress still emits the same microformat content as before
#

use strict;
use warnings;

package Test1;

use UBOS::Utils;
use UBOS::WebAppTest;

##
# Helper to invoke uf2py
sub _ufGetParse {
    my $c       = shift;
    my $content = shift;

    my $json;
    my $error;

    if( UBOS::Utils::myexec( 'mf2dump --stdin', $content, \$json, \$error )) {
        $c->myerror( 'mf2dump error:', $error );
        return undef;
    }
    return UBOS::Utils::readJsonFromString( $json );
}

# The states and transitions for this test

my $TEST = new UBOS::WebAppTest(
    appToTest   => 'wordpress',
    description => 'Tests out-of-the-box Wordpress microformats',
    checks      => [
            new UBOS::WebAppTest::StateCheck(
                    name  => 'virgin',
                    check => sub {
                        my $c = shift;

                        my $frontContent = $c->get( '/' );
                        my $frontUfs     = _ufGetParse( $c, $frontContent->{content} );

#                        if( keys %{$frontUfs->{'rel-urls'}} ) {
#                            $c->myerror( 'Has front rel-urls:', join( ' ', keys %{$frontUfs->{'rel-urls'}} ));
#                        }
#                        if( keys %{$frontUfs->{'items'}} ) {
#                            $c->myerror( 'Has front items:', join( ' ', keys %{$frontUfs->{'items'}} ));
#                        }
#                        if( keys %{$frontUfs->{'rels'}} ) {
#                            $c->myerror( 'Has front rels:', join( ' ', keys %{$frontUfs->{'rels'}} ));
#                        }

                        use Data::Dumper;
                        print "XXX Front\n";
                        print Dumper( $frontUfs );

                        my $postContent = $c->get( '/?p=1' );
                        if( $postContent->{headers} =~ m!^< Location:\s*([^\s]+)\s*$!m ) {
                            my $target = $1;
                            if( $target =~ m!^http! ) {
                                $postContent = $c->absGet( $target );
                            } else {
                                $postContent = $c->get( $target );
                            }
                        }
                        
                        my $postUfs = _ufGetParse( $c, $postContent->{content} );

#                        if( keys %{$postUfs->{'rel-urls'}} ) {
#                            $c->myerror( 'Has post rel-urls:', join( ' ', keys %{$postUfs->{'rel-urls'}} ));
#                        }
#                        if( keys %{$postUfs->{'items'}} ) {
#                            $c->myerror( 'Has post items:', join( ' ', keys %{$postUfs->{'items'}} ));
#                        }
#                        if( keys %{$postUfs->{'rels'}} ) {
#                            $c->myerror( 'Has post rels:', join( ' ', keys %{$postUfs->{'rels'}} ));
#                        }

                        print "XXX after redirect\n";
                        print Dumper( $postUfs );

                        return 1;
                    }
            )
    ]
);

$TEST;

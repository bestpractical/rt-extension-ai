package RT::Extension::AI::Utils;

use strict;
use warnings;
use LWP::UserAgent;

sub create_user_agent {
    my (%args) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->timeout($args{timeout} // 10);
    $ua->env_proxy;

    if ( $args{headers} ) {
        foreach my $header ( keys %{ $args{headers} } ) {
            $ua->default_header( $header => $args{headers}{$header} );
        }
    }

    return $ua;
}

1;

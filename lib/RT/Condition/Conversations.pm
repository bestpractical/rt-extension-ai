package RT::Condition::Conversations;
use RT;
use base 'RT::Condition';
use strict;
use warnings;

sub IsApplicable {
    my $self = shift;

    return 1;
}

RT::Base->_ImportOverlays();

1;

package RT::Extension::AI::Providers::Provider;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub suggest_text {
    die "Method 'suggest_text' not implemented in the provider";
}

sub translate {
    die "Method 'translate' not implemented in the provider";
}

sub adjust_tone {
    die "Method 'adjust_tone' not implemented in the provider";
}

1;

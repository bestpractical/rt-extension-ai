package RT::Extension::AI::Providers::Factory;

use strict;
use warnings;
use Module::Load;

sub get_provider {
    my ($self, $provider_name, $config) = @_;

    # Convert provider name to module name (e.g., 'OpenAI' -> 'RT::Extension::AI::Providers::OpenAI')
    my $module = "RT::Extension::AI::Providers::$provider_name";

    eval { load $module };
    if ($@) {
        die "Failed to load provider module '$module': $@";
    }

    return $module->new(config => $config);
}

1;

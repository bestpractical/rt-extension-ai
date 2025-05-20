package RT::Extension::AI::Providers::Factory;

use strict;
use warnings;
use Module::Load;

my %_loaded;

sub get_provider {
    my ( $self, $provider_name, $config ) = @_;

    $provider_name ||= RT->Config->Get('DefaultProvider') || 'OpenAI';
    $config        ||= RT->Config->Get('AIProviders')->{$provider_name};

    my $module = "RT::Extension::AI::Providers::$provider_name";

    unless ( $_loaded{$module} ) {
        eval { load $module };
        die "Failed to load provider module '$module': $@" if $@;
        $_loaded{$module} = 1;
    }

    return $module->new( config => $config );
}

1;

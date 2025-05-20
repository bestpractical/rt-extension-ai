package RT::Extension::AI::Utils;

use strict;
use warnings;
use LWP::UserAgent;

sub get_provider_config {
    my $self     = shift;
    my $provider = shift;
    my $config   = RT->Config;

    return {
        api_key => $config->Get('AIProviders')->{$provider}->{api_key},
        timeout => $config->Get('AIProviders')->{$provider}->{timeout},
        api_url => $config->Get('AIProviders')->{$provider}->{url},

        prompts => {
            adjustTone   => $config->Get('AdjustTone'),
            aisuggestion => $config->Get('AiSuggestion'),
            translate    => $config->Get('Translate'),
            autocomplete => $config->Get('Autocomplete'),
        },

        models => {
            general      => $config->Get('GeneralAIModel')->{modelDetails},
            autocomplete => $config->Get('AutoCompleteModel')->{modelDetails},
        },
    };
}

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

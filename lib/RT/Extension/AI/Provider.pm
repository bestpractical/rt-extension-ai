package RT::Extension::AI::Providers::Provider;

use strict;
use warnings;

sub default_headers {
    my ( $class, $config ) = @_;
    return {
        'Authorization' => "Bearer $config->{api_key}",
        'Content-Type'  => 'application/json'
    };
}

sub new {
    my ( $class, %args ) = @_;
    my $config = $args{config};

    unless ( $config->{url} ) {
        RT->Logger->error("Missing $class API URL");
        return;
    }
    unless ( $config->{api_key} ) {
        RT->Logger->error("Missing $class API key");
        return;
    }

    $config->{ua} = RT::Extension::AI::Utils::create_user_agent(
        timeout => $config->{timeout},
        headers => $class->default_headers($config)
    );

    $config->{api_url} = $config->{url};

    return bless $config, $class;
}

sub process_request {
    die "Method 'process_request' not implemented in the provider";
}

1;

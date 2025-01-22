package RT::Extension::AI::Providers::OpenAI;

use strict;
use warnings;

use base 'RT::Extension::AI::Providers::Provider';

use RT::Extension::AI::Utils;
use LWP::UserAgent;
use JSON;

sub new {
    my ( $class, %args ) = @_;
    my $config = $args{config};

    $config->{ua} = RT::Extension::AI::Utils::create_user_agent(
        timeout => $config->{timeout},
        headers => { 'Authorization' => "Bearer $config->{api_key}" }
    );

    return $class->SUPER::new( %{$config} );
}

sub process_request {
    my ( $self, %args ) = @_;
    my $ua = $self->{ua};

    my $request_payload = {
        model    => $args{model_config}->{modelName},
        messages => [
            { role => 'system', content => $args{prompt} },
            { role => 'user',   content => $args{raw_text} },
        ],
        max_tokens  => $args{model_config}->{maxToken},
        temperature => $args{model_config}->{temperature},
    };

    my $response = $ua->post(
        $self->{api_url},
        'Content-Type' => 'application/json',
        Content        => encode_json($request_payload),
    );

    if ( $response->is_success ) {
        my $content = decode_json( $response->decoded_content );

        return $content->{choices}[0]{message}{content}
            || 'No suggestion available';
    } else {
        die "OpenAI API error: "
            . $response->status_line . " "
            . $response->decoded_content;
    }
}

1;

package RT::Action::AddTicketSentiment;

use RT;
use strict;
use warnings;
use base qw(RT::Action);

use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;

sub Prepare {
    return 1;  # Nothing to prepare
}

sub Commit {
    my $self = shift;

    my $api_key = $ENV{'OPENAI_API_KEY'} || RT->Config->Get('OpenAI_ApiKey');
    my $url     = RT->Config->Get('OpenAI_ApiUrl');
    my $sentiment_prompt = RT->Config->Get('TicketSentiment');

    my $ticket_id           = $self->TicketObj->id;
    my $ticket_transactions = $self->TicketObj->Transactions;
    my $conversation_input  = '';

    my $max_tokens = 3000;

    while ( my $transaction = $ticket_transactions->Next ) {
        my $content = $transaction->Content;
        next unless $content;

        $conversation_input .= $content . "\n";
        last if length($conversation_input) > $max_tokens;
    }

    unless ($conversation_input) {
        $RT::Logger->info("No valid content for sentiment analysis for ticket #$ticket_id.");
        return 1;
    }

    my $ua = LWP::UserAgent->new;
    $ua->timeout(15);

    my $request = HTTP::Request->new( POST => $url );
    $request->header(
        'Content-Type'  => 'application/json',
        'Authorization' => "Bearer $api_key",
        'Accept'        => 'application/json',
        'User-Agent'    => 'RT-SentimentAnalysis/1.0'
    );

    my $data = {
        "model"    => "gpt-4",
        "messages" => [
            { "role" => "system", "content" => $sentiment_prompt },
            { "role" => "user", "content" => $conversation_input }
        ],
        "max_tokens"  => 100,
        "temperature" => 0.5
    };

    $request->content( encode_json($data) );

    my $response = $ua->request($request);

    if ( $response->is_success ) {
        my $result = eval { decode_json( $response->decoded_content ) };
        if ($@) {
            $RT::Logger->error("Failed to parse JSON response: $@");
            return;
        }

        my $sentiment = $result->{'choices'}[0]{'message'}{'content'} || 'Neutral';
        my %sentiment_map = (
            qr/satisfied/i   => 'Satisfied',
            qr/dissatisfied/i => 'Dissatisfied',
            qr/neutral/i      => 'Neutral'
        );

        my $normalized_sentiment = 'Neutral';
        for my $regex ( keys %sentiment_map ) {
            if ( $sentiment =~ $regex ) {
                $normalized_sentiment = $sentiment_map{$regex};
                last;
            }
        }

        $RT::Logger->info("Generated sentiment for ticket #$ticket_id: $normalized_sentiment");
        $self->TicketObj->AddCustomFieldValue( Field => 'Ticket Sentiment', Value => $normalized_sentiment );
    } else {
        $RT::Logger->error(
            "Failed to perform sentiment analysis for ticket #$ticket_id: "
                . $response->status_line . " - " . $response->decoded_content
        );
    }

    return 1;
}

RT::Base->_ImportOverlays();

1;

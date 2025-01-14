package RT::Action::AddTicketSummary;

use RT;
use strict;
use warnings;
use base qw(RT::Action);

use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;

sub Prepare {
    return 1;
}

sub Commit {
    my $self = shift;

    my $api_key = $ENV{'OPENAI_API_KEY'} || RT->Config->Get('OpenAI_ApiKey');
    my $url     = RT->Config->Get('OpenAI_ApiUrl');
    my $summary_prompt = RT->Config->Get('TicketSummary');

    my $ticket_id           = $self->TicketObj->id;
    my $ticket_subject      = $self->TicketObj->Subject;
    my $ticket_transactions = $self->TicketObj->Transactions;

    $summary_prompt .= "\nTicket ID: $ticket_id\nSubject: $ticket_subject";

    my $conversation_input = '';
    my $max_tokens         = 3000;

    while ( my $transaction = $ticket_transactions->Next ) {
        my $content = $transaction->Content;
        next unless $content;

        if ( $transaction->Type eq 'Correspond' ) {
            $conversation_input .= "User: $content\n";
        } elsif ( $transaction->Type eq 'Comment' ) {
            $conversation_input .= "Staff: $content\n";
        }

        last if length($conversation_input) > $max_tokens;
    }

    unless ($conversation_input) {
        $RT::Logger->info(
            "No valid content to summarize for ticket #$ticket_id.");
        return 1;
    }

    my $ua = LWP::UserAgent->new;
    $ua->timeout(15);

    my $request = HTTP::Request->new( POST => $url );
    $request->header(
        'Content-Type'  => 'application/json',
        'Authorization' => "Bearer $api_key",
        'Accept'        => 'application/json',
        'User-Agent'    => 'RT-Summary/1.0'
    );

    my $data = {
        "model"    => "gpt-4",
        "messages" => [
            { "role" => "system", "content" => $summary_prompt },
            { "role" => "user",   "content" => $conversation_input }
        ],
        "max_tokens"  => 300,
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

        if ( defined $result->{'choices'}[0]{'message'}{'content'} ) {
            my $summary = $result->{'choices'}[0]{'message'}{'content'};

            $RT::Logger->info(
                "Generated summary for ticket #$ticket_id: $summary");
            $self->TicketObj->AddCustomFieldValue(
                Field => 'Ticket Summary',
                Value => $summary
            );
        } else {
            $RT::Logger->error(
                "Unexpected response structure from OpenAI API for ticket #$ticket_id: "
                    . $response->decoded_content );
        }
    } else {
        $RT::Logger->error(
                  "Failed to perform summarization for ticket #$ticket_id: "
                . $response->status_line . " - "
                . $response->decoded_content );
    }

    return 1;
}

RT::Base->_ImportOverlays();

1;

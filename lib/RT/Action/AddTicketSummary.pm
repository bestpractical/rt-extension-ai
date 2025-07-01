package RT::Action::AddTicketSummary;

use RT;
use strict;
use warnings;
use base qw(RT::Action);

use Encode;
use JSON;

sub Prepare {
    return 1;
}

sub Commit {
    my $self      = shift;
    my $ticket    = $self->TicketObj;
    my $ticket_id = $ticket->id;

    my $provider_name = $self->Argument || RT->Config->Get('DefaultProvider');
    my $model_key     = 'GeneralAIModel';
    my $model_config  = RT->Config->Get($model_key)->{modelDetails};

    my $prompt = RT->Config->Get('TicketSummary');
    $prompt .= "\nTicket ID: $ticket_id\nSubject: " . $ticket->Subject;

    my $transactions = $ticket->Transactions;
    my $conversation = '';
    my $max_chars    = 3000;

    while ( my $txn = $transactions->Next ) {
        my $content = $txn->Content;
        next unless $content;

        if ( $txn->Type eq 'Correspond' ) {
            $conversation .= "User: $content\n";
        } elsif ( $txn->Type eq 'Comment' ) {
            $conversation .= "Staff: $content\n";
        } else {
            $conversation .= "$content\n";
        }

        last if length($conversation) > $max_chars;
    }

    unless ($conversation) {
        RT->Logger->info("No content to summarize for ticket #$ticket_id.");
        return 1;
    }

    my $provider_class = "RT::Extension::AI::Provider::" . $provider_name;
    my $provider = $provider_class->new(config => RT->Config->Get('AIProviders')->{$provider_name});

    my $response = $provider->process_request(
        prompt       => $prompt,
        raw_text     => $conversation,
        model_config => $model_config,
    );

    unless ( $response->{success} ) {
        RT->Logger->info(
            "Summary generation failed for ticket #$ticket_id: $response->{error}"
        );
        return 1;
    }

    my $summary = $response->{result};
    RT->Logger->info("Generated summary for ticket #$ticket_id: $summary");

    $ticket->AddCustomFieldValue(
        Field => 'Ticket Summary',
        Value => $summary,
    );

    return 1;
}

RT::Base->_ImportOverlays();

1;

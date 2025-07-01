package RT::Action::AddTicketSentiment;

use RT;
use strict;
use warnings;
use base qw(RT::Action);

use RT::Extension::AI::Provider::Factory;
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

    my $prompt = RT->Config->Get('TicketSentiment');

    # Build ticket content
    my $transactions = $ticket->Transactions;
    my $conversation = '';
    my $max_chars    = 3000;

    while ( my $txn = $transactions->Next ) {
        my $content = $txn->Content;
        next unless $content;
        $conversation .= $content . "\n";
        last if length($conversation) > $max_chars;
    }

    unless ($conversation) {
        RT->Logger->info("No content to analyze for ticket #$ticket_id.");
        return 1;
    }

    my $provider
        = RT::Extension::AI::Provider::Factory->get_provider($provider_name);

    my $response = $provider->process_request(
        prompt       => $prompt,
        raw_text     => $conversation,
        model_config => $model_config,
    );

    unless ( $response->{success} ) {
        RT->Logger->error(
            "Sentiment analysis failed for ticket #$ticket_id: $response->{error}"
        );
        return 1;
    }

    my $sentiment = $response->{result} || 'Neutral';

    # Normalize the result
    my %sentiment_map = (
        qr/satisfied/i    => 'Satisfied',
        qr/dissatisfied/i => 'Dissatisfied',
        qr/neutral/i      => 'Neutral',
    );

    my $normalized = 'Neutral';
    for my $regex ( keys %sentiment_map ) {
        if ( $sentiment =~ $regex ) {
            $normalized = $sentiment_map{$regex};
            last;
        }
    }

    RT->Logger->info("Ticket #$ticket_id sentiment: $normalized");

    $ticket->AddCustomFieldValue(
        Field => 'Ticket Sentiment',
        Value => $normalized,
    );

    return 1;
}

RT::Base->_ImportOverlays();

1;

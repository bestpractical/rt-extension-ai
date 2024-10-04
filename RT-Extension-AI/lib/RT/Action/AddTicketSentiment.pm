package RT::Action::AddTicketSentiment;

use RT;
use RT::Config;
use strict;
use warnings;
use base qw(RT::Action);

use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;


sub Prepare {
    my $self = shift;

    # Nothing to do in Prepare
    return 1;
}

sub Commit {
	my $self = shift;

	RT->LoadConfig;
	my $config = RT->Config;

	my $api_key = $config->Get('OpenAI_ApiKey');
	my $url = $config->Get('OpenAI_ApiUrl');

	# Gather the content of the ticket for sentiment analysis
	my $ticket_id = $self->TicketObj->id;
	my $ticket_transactions = $self->TicketObj->Transactions;
	my $conversation_input = '';

	while (my $transaction = $ticket_transactions->Next) {
		my $content = $transaction->Content;
		my $creator = $transaction->CreatorObj->Name;

		if (!$content || $content =~ /This transaction appears to have no content/i) {
			next;  # Skip to the next transaction
		}

		# Add all the content to be analyzed for sentiment
		$conversation_input .= $content . "\n";
	}

	unless ($conversation_input) {
		$RT::Logger->info("No valid content for sentiment analysis for ticket #$ticket_id.");
		return 1;
	}

	my $ua = LWP::UserAgent->new;
	my $request = HTTP::Request->new(POST => $url);
	$request->header('Content-Type' => 'application/json');
	$request->header('Authorization' => "Bearer $api_key");


	my $data = {
		"model" => "gpt-4",
		"messages" => [{
			"role" => "system",
			"content" => "You are a sentiment analysis assistant. Based on the conversation, classify the overall sentiment into one of the following categories: Satisfied, Dissatisfied, or Neutral."
		}, {
			"role" => "user",
			"content" => $conversation_input
		}],
		"max_tokens" => 100,
		"temperature" => 0.5
	};

	$request->content(encode_json($data));


	my $response = $ua->request($request);

	if ($response->is_success) {
		my $result = decode_json($response->decoded_content);


		if (defined($result->{'choices'}[0]{'message'}{'content'})) {
			my $sentiment = $result->{'choices'}[0]{'message'}{'content'};


			my $normalized_sentiment;
			if ($sentiment =~ /satisfied/i) {
				$normalized_sentiment = 'Satisfied';
			} elsif ($sentiment =~ /dissatisfied/i) {
				$normalized_sentiment = 'Dissatisfied';
			} else {
				$normalized_sentiment = 'Neutral';
			}


			$RT::Logger->info("Generated sentiment for ticket #$ticket_id: $normalized_sentiment");
			$self->TicketObj->AddCustomFieldValue(
				Field => 'Ticket Sentiment',  # The custom field for storing sentiment
				Value => $normalized_sentiment
			);
		} else {
			$RT::Logger->error("Unexpected response structure from OpenAI API for ticket #$ticket_id: " . $response->decoded_content);
		}
	} else {
		$RT::Logger->error("Failed to perform sentiment analysis for ticket #$ticket_id: " . $response->status_line);
	}
}


RT::Base->_ImportOverlays();

1;

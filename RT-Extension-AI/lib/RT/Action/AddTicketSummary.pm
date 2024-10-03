package RT::Action::AddTicketSummary;

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
	my $api_key = 'Your API KEY';
	my $url = 'https://api.openai.com/v1/chat/completions';
	my $ticket_id = $self->TicketObj->id;
	my $ticket_transactions = $self->TicketObj->Transactions;
	my $conversation_input = '';


	while (my $transaction = $ticket_transactions->Next) {
	    my $content = $transaction->Content;
	    my $type = $transaction->Type;

	    if (!$content || $content =~ /This transaction appears to have no content/i) {
	        next;
	    }


	    if ($type eq 'Correspond') {
	        $conversation_input .= "User: " . $content . "\n";
	    } elsif ($type eq 'Comment') {
	        $conversation_input .= "Staff: " . $content . "\n";
	    }
	}

	RT::Logger->info("Ticket conversation history: " . $conversation_input);


	unless ($conversation_input) {
	    $RT::Logger->info("No valid content to summarize for ticket #$ticket_id.");
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
	        "content" => "You are a helpdesk assistant. Summarize the following ticket conversation between a user and the staff in a precise manner. Ensure the summary is clear and concise, and focuses on the core points of the discussion."
	    }, {
	        "role" => "user",
	        "content" => $conversation_input
	    }],
	    "max_tokens" => 300,
	    "temperature" => 0.5
	};

	$request->content(encode_json($data));


	my $response = $ua->request($request);

	if ($response->is_success) {
	    my $result = decode_json($response->decoded_content);


	    if (defined($result->{'choices'}[0]{'message'}{'content'})) {
	        my $summary = $result->{'choices'}[0]{'message'}{'content'};


	        $RT::Logger->info("Generated summary for ticket #$ticket_id: $summary");
	        $self->TicketObj->AddCustomFieldValue(
	            Field => 'Ticket Summary',
	            Value => $summary
	        );
	    } else {
	        $RT::Logger->error("Unexpected response structure from OpenAI API for ticket #$ticket_id: " . $response->decoded_content);
	    }
	} else {
	    $RT::Logger->error("Failed to perform summarization for ticket #$ticket_id: " . $response->status_line);
	}
}

RT::Base->_ImportOverlays();

1;

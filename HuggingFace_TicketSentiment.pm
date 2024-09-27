use LWP::UserAgent;
use HTTP::Request;
use JSON;
my $ticket = $self->TicketObj;
my $content = $self->TransactionObj->Content;  


RT::Logger->info("Performing sentiment analysis on ticket #" . $ticket->id . " with content: $content");

my $ua = LWP::UserAgent->new;
my $url = 'https://api-inference.huggingface.co/models/cardiffnlp/twitter-roberta-base-sentiment';  
my $api_key = '<key>';  

my $request_body = {
    inputs => $content
};


RT::Logger->info("Sending request to Huggingface API: " . encode_json($request_body));

my $req = HTTP::Request->new(POST => $url);
$req->header('Authorization' => "Bearer $api_key");
$req->header('Content-Type' => 'application/json');
$req->content(encode_json($request_body));

my $response = $ua->request($req);
if ($response->is_success) {
    my $response_content = decode_json($response->decoded_content);
    
    RT::Logger->info("Huggingface API response: " . $response->decoded_content);
    
    my $sentiment_label = $response_content->[0]->[0]{label}; 
    
    my $mapped_value;
    if ($sentiment_label eq 'LABEL_2') {
        $mapped_value = 'Satisfied';
    } elsif ($sentiment_label eq 'LABEL_0') {
        $mapped_value = 'Dissatisfied';
    } else {
        $mapped_value = 'Neutral';
    }
    RT::Logger->info("Mapped sentiment value: $mapped_value for ticket #" . $ticket->id);
    
    my $cf_name = 'Ticket Sentiment';
    my ($success, $msg) = $ticket->AddCustomFieldValue(
        Field => $cf_name,
        Value => $mapped_value
    );
    if ($success) {
        RT::Logger->info("Successfully updated Ticket Sentiment to '$mapped_value' for ticket #" . $ticket->id);
    } else {
        RT::Logger->error("Failed to update Ticket Sentiment for ticket #" . $ticket->id . ": $msg");
    }
} else {
    RT::Logger->error("Failed to perform sentiment analysis using Huggingface for ticket #" . $ticket->id . ": " . $response->status_line);
    RT::Logger->error("Huggingface API response: " . $response->decoded_content);
}

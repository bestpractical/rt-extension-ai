Set( $TicketSummary,
    "You are a helpdesk assistant. Summarize the ticket conversation precisely. Focus on key points, decisions made, and any follow-up actions required."
   );
Set( $TicketSentiment,
    "Classify the overall sentiment as Satisfied, Dissatisfied, or Neutral. Provide reasoning if possible."
   );
Set( $AdjustTone,
    "Paraphrase the text for clarity and professionalism. Ensure the tone is polite, concise, and customer-friendly."
   );
Set( $AiSuggestion,
    "Provide clear, practical advice or suggestions based on the given question or scenario."
   );
Set( $Translate,
    "Translate the text from {source_language} to {target_language}, maintaining accuracy and idiomatic expressions."
   );
Set( $Autocomplete,
    "Predict the next three words based on the input text without explanations."
   );

Set($GeneralAIModel,
    {   modelDetails => {
            modelName   => 'gpt-4',
            maxToken    => 300,
            temperature => 0.5,
            stream      => \0
        }
    }
   );

Set($AutoCompleteModel,
    {   modelDetails => {
            modelName   => 'gpt-3.5-turbo',
            maxToken    => 20,
            temperature => 0.7,
            stream      => \1
        }
    }
   );

# Default provider used for initialdata
Set( $DefaultProvider, 'OpenAI' );

Set(%AIProviders,
    'OpenAI' => {
        api_key => 'YOUR_OPEN_API_KEY',
        timeout => 15,
        url     => 'https://api.openai.com/v1/chat/completions'
    },
    'Gemini' => {
        api_key => 'YOUR_GOOGLE_GEMINI_API_KEY',
        timeout => 20,
        url     => 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    }
);

my $messageBoxRichTextInitArguments
    = RT->Config->Get('MessageBoxRichTextInitArguments');

$messageBoxRichTextInitArguments->{extraPlugins} //= [];
push @{ $messageBoxRichTextInitArguments->{extraPlugins} }, 'RtExtensionAi';

# Add 'aiSuggestion' to the toolbar, creating a new array
$messageBoxRichTextInitArguments->{toolbar} //= [];
$messageBoxRichTextInitArguments->{toolbar}
    = [ @{ $messageBoxRichTextInitArguments->{toolbar} }, 'aiSuggestion' ];

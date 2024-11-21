Set($OpenAI_ApiUrl, "https://api.openai.com/v1/chat/completions");
Set($OpenAI_ApiKey, "Your open AI API Key");

Set($TicketSummary, "You are a helpdesk assistant. Summarize the following ticket conversation between a user and the staff in a precise manner. Ensure the summary is clear and concise, and focuses on the core points of the discussion.");
Set($TicketSentiment, "You are a sentiment analysis assistant. Based on the conversation, classify the overall sentiment into one of the following categories: Satisfied, Dissatisfied, or Neutral.");
Set($AdjustTone, "You are a language expert. Your task is to paraphrase the following text to improve clarity, tone, and readability, while maintaining the original meaning. Ensure that the paraphrased version is more concise, professional, and customer-friendly.");
Set($AiSuggestion, "You are a knowledgeable assistant. Based on the following question or scenario, provide clear and concise suggestions or answers. Make sure to consider different perspectives and provide practical advice that is easy to understand.");
Set($Translate, "You are a highly skilled translator. Your task is to translate the following text from Spanish to English. Ensure that the translation maintains the original meaning and is idiomatic in the target language.");
Set($Autocomplete, "For the given text predict next three words.");

Set(
    %MessageBoxRichTextInitArguments,
    toolbar => {
        items => [
            'undo',                'redo',        '|',           'heading',
            '|',                   'fontfamily',  'fontsize',    'fontColor',
            'fontBackgroundColor', '|',           'bold',        'italic',
            'strikethrough',       'subscript',   'superscript', '|',
            'link',                'imageUpload', 'mediaEmbed',  '|',
            'code',                'blockQuote',  'codeBlock',   '|',
            'insertTable',         'alignment',   '|',           'bulletedList',
            'numberedList',        '|',           'outdent',
            'indent',              '|',           'sourceEditing', 'aiSuggestion'
        ],
    },
    mediaEmbed => {
        removeProviders => [ 'instagram', 'twitter', 'googleMaps', 'flickr', 'facebook' ],
        previewsInData  => 1,
    },
    language => 'en',
    image    => {
        toolbar => [
            'imageTextAlternative', 'toggleImageCaption', 'imageStyle:inline', 'imageStyle:block',
            'imageStyle:side',
        ],
    },
    table => {
        contentToolbar => [ 'tableColumn', 'tableRow', 'mergeTableCells', ],
    },
    ui => {
        poweredBy => {
            position         => 'border',
            side             => 'right',
            label            => undef,
            verticalOffset   => 5,
            horizontalOffset => 5,
        },
    },
    fontSize => {
        options => [
            {
                title => 'Tiny',
                model => '9px'
            },
            {
                title => 'Small',
                model => '11px'
            },
            'default',
            {
                title => 'Big',
                model => '15px'
            },
            {
                title => 'Huge',
                model => '17px'
            }
        ],
        supportAllValues => 1,
    },
);

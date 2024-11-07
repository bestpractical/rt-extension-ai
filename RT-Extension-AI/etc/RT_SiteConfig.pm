Set($HuggingFace_SentimentApiUrl, 'https://api-inference.huggingface.co/models/cardiffnlp/twitter-roberta-base-sentiment');
Set($HuggingFace_SummaryApiUrl, 'https://api-inference.huggingface.co/models/facebook/bart-large-cnn');
Set($HuggingFace_ApiKey, "API");
Set($OpenAI_ApiUrl, "https://api.openai.com/v1/chat/completions");
Set($OpenAI_ApiKey, "Your open AI API Key");
Set($AdjustTone, "You are a language expert. Your task is to paraphrase the following text to improve clarity, tone, and readability, while maintaining the original meaning. Ensure that the paraphrased version is more concise, professional, and customer-friendly.");
Set($AiSuggestion, "You are a knowledgeable assistant. Based on the following question or scenario, provide clear and concise suggestions or answers. Make sure to consider different perspectives and provide practical advice that is easy to understand.");
Set($Translate, "You are a highly skilled translator. Your task is to translate the following text from Spanish to English. Ensure that the translation maintains the original meaning and is idiomatic in the target language.");

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

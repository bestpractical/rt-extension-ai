use strict;
use warnings;

package RT::Extension::AI;

our $VERSION = '0.01';

=head1 NAME

RT-Extension-AI - AI Features for Request Tracker extension

=head1 DESCRIPTION

This RT extension introduces AI-powered features to enhance ticket handling efficiency and improve the user experience in Request Tracker (RT).

=over 4

=item 1. Autocomplete

This aids staff users in writing better responses and adding internal comments to support tickets. 
It also helps end-users submit better questions when creating and replying to tickets via the Self Service interface.
When a user starts to type in a content box, the current written text is set as context to ChatGPT, 
which suggests the next three words to the user. On pressing Tab, the suggestion will be appended to the current text.

=item 2. AI Filters

=over 4

=item * Adjust Tone/Voice: Modify the tone of the text.

=item * AI Suggestion: Provides suggestions or answers for user queries.

=item * Translate: Translates ticket content into different languages.

=back

=item 3. Ticket Sentiment

A custom field, Ticket Sentiment, has been added to classify ticket responses as Satisfied, Dissatisfied, or Neutral using OpenAI's API.

=item 4. Ticket Summarization

Automatically generates ticket summaries based on the ticket conversation between users and staff responses. This ensures clarity in ticket updates.

=back

=cut

=head1 RT VERSION

Works with RT 6.

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item C<make initdb>

Only run this the first time you install this module.

If you run this twice, you may end up with duplicate data
in your database.

If you are upgrading this module, check for upgrading instructions
in case changes need to be made to your database.

=item Edit your F</opt/rt5/etc/RT_SiteConfig.pm>

Add this line:

    Plugin('RT::Extension::AI');

See below for additional configuration details.

=item Clear your mason cache

    rm -rf /opt/rt6/var/mason_data/obj

=item Restart your webserver

=back

=head1 CONFIGURATION

This section outlines the configuration steps to enable the AI functionalities in RT.

=head2 OpenAI API

    Following are the variables used in the extension for API url and key :

    Set($OpenAI_ApiUrl, "https://api.openai.com/v1/chat/completions");
    Set($OpenAI_ApiKey, "Your open AI API Key");

=head2 Prompts

    We added customized prompts for various tasks :

    Set($TicketSummary, "You are a helpdesk assistant. Summarize the following ticket conversation between a user and the staff in a precise manner. Ensure the summary is clear and concise, and focuses on the core points of the discussion.");
    Set($TicketSentiment, "You are a sentiment analysis assistant. Based on the conversation, classify the overall sentiment into one of the following categories: Satisfied, Dissatisfied, or Neutral.");
    Set($AdjustTone, "You are a language expert. Your task is to paraphrase the following text to improve clarity, tone, and readability, while maintaining the original meaning. Ensure that the paraphrased version is more concise, professional, and customer-friendly.");
    Set($AiSuggestion, "You are a knowledgeable assistant. Based on the following question or scenario, provide clear and concise suggestions or answers. Make sure to consider different perspectives and provide practical advice that is easy to understand.");
    Set($Translate, "You are a highly skilled translator. Ensure that the translation maintains the original meaning and is idiomatic in the target language. Your task is to translate the following text from .");
    Set($Autocomplete, "You are an autocomplete engine. For the given text, predict the next three words. Do not provide explanations or additional suggestions. If the text implies a request for assistance, only return the predicted words without addressing the request for help.");


=head2 Model Config 

    Following is the AI model's configuration to set the model details:

    Set($GeneralAIModel, {
    modelDetails => {
        modelName   => 'gpt-4',
        maxToken    => 300,
        temperature => 0.5,
        stream      => \0
    }
    });

    Set($AutoCompleteModel, {
        modelDetails => {
            modelName   => 'gpt-3.5-turbo',
            maxToken    => 10,
            temperature => 0.7,
            stream      => \1
        }
    });

=head2 Ckeditor Config 

    We added a custom plugin 'aiSuggestion' to the Ckeditor default configuration.

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



=head1 RT Scrips and Custom Fields

=head2 Scrips

This extension will install two new Scrips:

=over

=item On Comment and On Correspond Trigger

Generate ticket summary when conversation occurs between user and staff.

=item On Correspond Trigger

Automatically update the 'Ticket Sentiment' field when user updates on ticket.

=back

=head2 Custom Fields

This extension adds two ticket custom fields: C<Ticket Sentiment> and C<Ticket Summary>.

=head2 AIModal

AIModal File:

URL: /helper/OpenAiSuggestion/aiModal
This internal endpoint returns the HTML required to render the AI popup, which supports features such as AI Suggestions, Adjust Tone, and AI Translate.

Request Body:

$rawText: Text content from CKEditor (either the selected portion or the entire text).
$popupLabel: The heading to display on the popup.

=head2 AISuggestion

AISuggestion File:

URL: /helper/OpenAiSuggestion/aisuggestion
This internal endpoint processes AI suggestions, tone adjustments, and translation requests. It leverages OpenAI endpoints internally, with the responses displayed in the AI popup.

The AISuggestion functionality depends on a configuration file for the OpenAI base URL, API key, and model settings.

Request Body:

$rawText: Input text from the user.
$callType: Specifies the type of request (e.g., aisuggestion, adjustTone, translate, autocomplete, etc.).
$transFrom: Source language for translation.
$transTo: Target language for translation.

=head2 CkEditor.ts

A new custom dropdown plugin named aiSuggestion has been added to the toolbar. This plugin includes dropdown options for features such as AI Suggestion, Adjust Tone, and Translat. Additionally, AI-powered autocomplete functionality has been implemented for the CKEditor text area.

The implementation involves making API calls to internal endpoints for all functionalities, and the responses are processed and displayed seamlessly within the editor text area.

For the updated file, the location "\devel\third-party\ckeditor5\src\CKEditor.ts" can be accessed to check all the new changes. For understanding the source code inline comment and JSDocs are provided within the file.

Branch Information: L<https://github.com/ParagShah97/rt6_AIEnabled/tree/ckeditor6_updated/parag>

File Information: L<https://github.com/ParagShah97/rt6_AIEnabled/blob/ckeditor6_updated/parag/devel/third-party/ckeditor5/src/ckeditor.ts>



=head1 AUTHOR

Parag Shah E<lt>paragsha@buffalo.eduE<gt>

Neel Patel E<lt>neelvish@buffalo.eduE<gt>

Abhinandan Vijan E<lt>abhinandanvijan98@gmail.comE<gt>

Ayush Goel E<lt>ayushgoe@buffalo.eduE<gt>

Shivan Mathur E<lt>shivanmthr18@gmail.comE<gt>

Best Practical Solutions, LLC E<lt>modules@bestpractical.comE<gt>


=for html <p>All bugs should be reported via email to <a
href="mailto:bug-RT-Extension-PagerDuty@rt.cpan.org">bug-RT-Extension-PagerDuty@rt.cpan.org</a>
or via the web at <a
href="http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-PagerDuty">rt.cpan.org</a>.</p>

=for text
    All bugs should be reported via email to
        bug-RT-Extension-PagerDuty@rt.cpan.org
    or via the web at
        E<lt>Page linkE<gt>

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by BPS

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;

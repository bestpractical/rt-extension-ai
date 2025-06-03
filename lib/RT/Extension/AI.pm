use strict;
use warnings;

package RT::Extension::AI;

our $VERSION = '0.01';

RT->AddJavaScript('rt-extension-ai.js');
RT->AddStyleSheets('rt-extension-ai.css');

if ( RT->Config->can('RegisterPluginConfig') ) {
    RT->Config->RegisterPluginConfig(
        Plugin  => 'AI',
        Content => [
            {   Name => 'TicketSummary',
                Help => 'Prompt to summarize ticket conversation.',
            },
            {   Name => 'TicketSentiment',
                Help => 'Prompt to classify overall sentiment.',
            },
            {   Name => 'AdjustTone',
                Help => 'Prompt to adjust tone for professionalism.',
            },
            {   Name => 'AiSuggestion',
                Help => 'Prompt for providing AI suggestions.',
            },
            {   Name => 'Translate',
                Help =>
                    'Prompt for translating text using source/target language.',
            },
            {   Name => 'Autocomplete',
                Help => 'Prompt for predicting next three words.',
            },
            {   Name => 'GeneralAIModel',
                Help => 'Configuration for the general-purpose AI model.',
            },
            {   Name => 'AutoCompleteModel',
                Help => 'Configuration for autocomplete-specific AI model.',
            },
            {   Name => 'DefaultProvider',
                Help => 'Default AI provider.',
            },
            {   Name => 'AIProviders',
                Help => 'List of available AI providers and API details.',
            },
        ],
        Meta => {
            TicketSummary     => { Type => 'SCALAR' },
            TicketSentiment   => { Type => 'SCALAR' },
            AdjustTone        => { Type => 'SCALAR' },
            AiSuggestion      => { Type => 'SCALAR' },
            Translate         => { Type => 'SCALAR' },
            Autocomplete      => { Type => 'SCALAR' },
            GeneralAIModel    => { Type => 'HASH' },
            AutoCompleteModel => { Type => 'HASH' },
            DefaultProvider   => { Type => 'SCALAR' },
            AIProviders       => { Type => 'HASH' },
        }
    );
}

=head1 NAME

RT-Extension-AI - AI Features for Request Tracker extension

=head1 DESCRIPTION

This RT extension introduces AI-powered features to enhance ticket handling efficiency and improve the user experience in Request Tracker (RT).

=head1 FEATURES

=over 4

=item * Autocomplete

    Suggests the next three words while typing in ticket comments or replies.

=item * AI CKEditor Actions

    - Adjust Tone - rephrase content for professionalism and clarity.
    - AI Suggestion - generate responses based on user input.
    - Translate - translate ticket text between languages.

=item * Ticket Sentiment

    Automatically analyzes user replies and categorizes sentiment (Satisfied, Dissatisfied, Neutral).

=item * Ticket Summarization

    Generates a concise summary based on ticket conversation history.

=back

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

=head2 AI Provider Setup

Set the default provider and its config:

    Set($DefaultProvider, 'OpenAI');

    Set(%AIProviders,
        'OpenAI' => {
            api_key => 'YOUR_API_KEY',
            timeout => 15,
            url     => 'https://api.openai.com/v1/chat/completions',
        }
    );

=head2 Model Configuration

    Set($GeneralAIModel, {
        modelDetails => {
            modelName   => 'gpt-4',
            maxToken    => 300,
            temperature => 0.5,
            stream      => \0,
        }
    });

    Set($AutoCompleteModel, {
        modelDetails => {
            modelName   => 'gpt-3.5-turbo',
            maxToken    => 10,
            temperature => 0.7,
            stream      => \1,
        }
    });

=head2 Prompts

Define system-level instructions for each AI task:

    Set($TicketSummary, "You are a helpdesk assistant. Summarize the conversation...");
    Set($TicketSentiment, "Classify the overall sentiment...");
    Set($AdjustTone,      "Paraphrase the text...");
    Set($AiSuggestion,    "Provide practical advice...");
    Set($Translate,       "Translate the text from...");
    Set($Autocomplete,    "Predict the next three words...");

=head2 CKEditor Integration

To activate the AI button in rich text editors:

    my $messageBoxRichTextInitArguments = RT->Config->Get('MessageBoxRichTextInitArguments');
    $messageBoxRichTextInitArguments->{extraPlugins} //= [];
    push @{$messageBoxRichTextInitArguments->{extraPlugins}}, 'RtExtensionAi';

    $messageBoxRichTextInitArguments->{toolbar}{items} //= [];
    push @{$messageBoxRichTextInitArguments->{toolbar}{items}}, 'aiSuggestion';

=head1 SCRIPS AND CUSTOM FIELDS

=head2 Installed Custom Fields

- C<Ticket Summary>
- C<Ticket Sentiment> (Dropdown: Satisfied, Dissatisfied, Neutral)

=head2 Installed Custom Fields

=over 4

=item * Ticket Summary

=item * Ticket Sentiment (Dropdown: Satisfied, Dissatisfied, Neutral)

=back

=head2 Installed Scrips

=over 4

=item * On Comment or Correspond - Adds a generated summary.

=item * On Correspond - Classifies sentiment and updates the custom field.

=back

=head2 RtExtensionAi

A new custom plugin RtExtensionAi was created to handle the AI suggestions and other AI-related features.
This plugin is integrated with CKEditor to provide a seamless user experience.

To enable the plugin, add the following line to your RT_SiteConfig.pm file:

    Set($MessageBoxRichTextInitArguments, {
        extraPlugins => ['RtExtensionAi'],
        toolbar => {
            items => [ ... 'aiSuggestion' ]
        }
    });


=head2 Updating the plugin

The plugin uses Vite to build the assets. Information on working with CKEditor plugins can be 
found on their website, a good place to start is here:

L<https://ckeditor.com/docs/ckeditor5/latest/framework/tutorials/creating-simple-plugin-timestamp.html>


=item BUILDING THE JS PLUGIN

We use Vite to build the CKEditor plugin.

    npm install
    npm run build

For more details: https://ckeditor.com/docs/ckeditor5/latest/framework/tutorials/creating-simple-plugin-timestamp.html


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

This software is Copyright (c) 2025 by BPS

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;

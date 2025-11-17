/**
 * Natural Language Search for TicketSQL
 * Uses htmx for form submission and event handling
 */
export function initNaturalLanguageSearch() {
  // Wait for htmx to be available
  if (typeof htmx === 'undefined') {
    return;
  }

  // Wait for jQuery to be available (for DOM manipulation)
  if (typeof jQuery === 'undefined') {
    return;
  }

  jQuery(function($) {
    const form = document.getElementById('natural-language-search-form');
    if (!form) {
      return;
    }

    const $generateBtn = $('#generate-ticketsql-btn');
    const $errorDiv = $('#nl-search-error');
    const $queryTextarea = $('textarea[name="Query"]');

    // Handle before request - show loading state
    form.addEventListener('htmx:beforeRequest', function(event) {
      $generateBtn.prop('disabled', true);
      $errorDiv.addClass('d-none');
    });

    // Handle after successful request
    form.addEventListener('htmx:afterRequest', function(event) {
      $generateBtn.prop('disabled', false);

      if (event.detail.successful) {
        const response = event.detail.xhr.responseText;

        if (response && response.trim()) {
          // Write the generated TicketSQL to the Query textarea
          $queryTextarea.val(response.trim());

          // Show success message
          if (typeof jGrowl !== 'undefined') {
            jGrowl('Search generated', { sticky: false });
          }

          // Trigger change event to update RT's search display
          $queryTextarea.trigger('change');
        } else {
          $errorDiv.text('No search query was generated. Please try rephrasing your request.')
                   .removeClass('d-none');
        }
      }
    });

    // Handle request errors
    form.addEventListener('htmx:responseError', function(event) {
      $generateBtn.prop('disabled', false);

      let errorMessage = 'Failed to generate search. Please try again.';
      if (event.detail.xhr && event.detail.xhr.responseText) {
        errorMessage += ' ' + event.detail.xhr.responseText;
      }

      $errorDiv.text(errorMessage).removeClass('d-none');
    });
  });
}

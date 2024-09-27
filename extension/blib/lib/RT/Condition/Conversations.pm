package RT::Condition::Conversations;
use base 'RT::Condition';
use strict;
use warnings;

sub IsApplicable {
    my $self = shift;  # Assign the first argument (the object) to $self
    my $ticket = $self->TicketObj;
    my $transaction = $self->TransactionObj;

    # Check if the transaction type is 'Correspond' or 'Comment'
    if ($transaction->Type eq 'Correspond' || $transaction->Type eq 'Comment') {
        return 1;  # Condition is met
    } else {
        return 0;  # Condition is not met
    }
}

RT::Base->_ImportOverlays();

1;

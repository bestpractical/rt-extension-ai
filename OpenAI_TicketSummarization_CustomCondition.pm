my $ticket = $self->TicketObj;
my $transaction = $self->TransactionObj;

if ($transaction->Type eq 'Correspond' || $transaction->Type eq 'Comment') {
    return 1;
} else {
    return 0;
}

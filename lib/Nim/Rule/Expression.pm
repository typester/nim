package Nim::Rule::Expression;
use Any::Moose;

use Carp;
use Try::Tiny;

has expression => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

no Any::Moose;

sub dispatch {
    my ($self, @args) = @_;

    my $entry_or_page = $args[0];
    my ($entry, $page);

    if ($entry_or_page) {
        if ($entry_or_page->isa('Nim::Entry')) {
            $entry = $entry_or_page;
        }
        elsif ($entry_or_page->isa('Nim::Page')) {
            $page = $entry_or_page;
        }
    }

    my $status;
    try {
        $status = eval $self->expression
    }
    catch {
        die +__PACKAGE__ . ": expression error: $_";
    };

    $status;
}

__PACKAGE__->meta->make_immutable;

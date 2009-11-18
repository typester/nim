package Nim::Page;
use Any::Moose;

has filename => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has entries => (
    is      => 'rw',
    isa     => 'ArrayRef[Nim::Entry]',
    default => sub { [] },
);

has rendered => (
    is  => 'rw',
);

has creator => (
    is       => 'rw',
    isa      => 'Object',
    weak_ref => 1,
);

no Any::Moose;

__PACKAGE__->meta->make_immutable;

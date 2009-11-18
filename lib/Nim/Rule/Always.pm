package Nim::Rule::Always;
use Any::Moose;

no Any::Moose;

sub dispatch { 1 };

__PACKAGE__->meta->make_immutable;

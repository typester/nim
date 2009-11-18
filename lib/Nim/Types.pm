package Nim::Types;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';

use Path::Class;

subtype 'Nim::Types::Dir'
    => as 'Object' => where { $_->isa('Path::Class::Dir') };
coerce 'Nim::Types::Dir'
    => from 'Str'
    => via { Path::Class::Dir->new($_) };

subtype 'Nim::Types::File'
    => as 'Object' => where { $_->isa('Path::Class::File') };
coerce 'Nim::Types::File'
    => from 'Str'
    => via { Path::Class::File->new($_) };

1;


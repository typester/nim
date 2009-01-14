package Nim::Types::Path::Class;
use MouseX::Types;
use Path::Class;

subtype 'Path::Class::File',
    as 'Object',
    where { $_->isa('Path::Class::File') };

subtype 'Path::Class::Dir',
    as 'Object',
    where { $_->isa('Path::Class::Dir') };

coerce 'Path::Class::File',
    from 'Str',
    via {
        Path::Class::File->new($_);
    };

coerce 'Path::Class::Dir',
    from 'Str',
    via {
        Path::Class::Dir->new($_);
    };

1;

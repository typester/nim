package Nim::Entry;
use utf8;
use Mouse;

use Encode;
use Nim::Types::Path::Class;

has file => (
    is       => 'rw',
    isa      => 'Path::Class::File',
    required => 1,
    coerce   => 1,
);

has fn => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = $_[0];
        (my $fn = $self->file->basename) =~ s/\.[^.]+$//;
        $fn;
    },
);

has headers => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
);

has body => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { '' },
);

has rendered_body => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { '' },
);

no Mouse;

sub BUILD {
    $_[0]->load_data;           # TODO: lazy load
}

sub load {
    my ($class, $file) = @_;
    $class->new( file => $file );
}

sub load_data {
    my $self = shift;

    my $data = $self->file->slurp;
    my ($meta, $body) = @_;
    if ($data =~ /^\S+:/) {
        ($meta, $body) = $data =~ /(.*?)\r?\n\r?\n(.*)/s;
        for my $line (split /\r?\n/, $meta) {
            my ($key, $value) = $line =~ /^(\S+):\s*(.*)/;
            $self->header( $key => $value );
        }
    }
    else {
        $body = $data;
    }

    my $charset = $self->header('charset') || 'utf-8';
    for my $k (keys %{ $self->headers }) {
        $self->header( $k, decode($charset, $self->header($k)) );
    }
    $self->body( decode($charset, $body) );
}

sub header {
    my ($self, $key, $value) = @_;

    if ($value) {
        return $self->headers->{ lc $key } = $value;
    }
    $self->headers->{ lc $key };
}

1;

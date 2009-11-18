package Nim::Config;
use Any::Moose;

use Nim::Types;
use YAML::Syck;

has log_level => (
    is      => 'rw',
    isa     => 'Str',
    default => 'info',
);

has time_zone => (
    is      => 'rw',
    isa     => 'Str',
    default => 'local',
);

has [qw/data_dir site_dir/] => (
    is       => 'rw',
    isa      => 'Nim::Types::Dir',
    required => 1,
    coerce   => 1,
);

has templates_dir => (
    is      => 'rw',
    isa     => 'Nim::Types::Dir',
    lazy    => 1,
    coerce  => 1,
    default => sub { shift->data_dir },
);

has plugins => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
);

no Any::Moose;

sub load {
    my ($class, $file) = @_;

    my $conf = LoadFile($file);
    $class->new($conf);
}

__PACKAGE__->meta->make_immutable;


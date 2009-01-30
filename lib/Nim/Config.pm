package Nim::Config;
use utf8;
use Mouse;

use YAML::Syck;
use Nim::Types::Path::Class;

has 'log_level' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { 'error' },
);

has [qw/output_dir data_dir/] => (
    is       => 'rw',
    isa      => 'Path::Class::Dir',
    required => 1,
    coerce   => 1,
);

has templates_dir => (
    is      => 'rw',
    isa     => 'Path::Class::Dir',
    lazy    => 1,
    default => sub { $_[0]->data_dir },
    coerce  => 1,
);

has default_flavour => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { 'html' },
);

has data_extension => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { 'txt' },
);

has plugins => (
    is      => 'rw',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub { [] },
);

no Mouse;

sub load {
    my ($class, $file) = @_;

    my $conf = LoadFile($file);
    $class->new($conf);
}

1;



package Nim::Log;
use utf8;
use Mouse;

has log_level => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { 'error' },
);

no Mouse;

our %log_levels = (
    fatal => 0,
    error => 1,
    warn  => 2,
    info  => 3,
    debug => 4,
);

sub log {
    my ($self, $type, $format, @args) = @_;
    return if $log_levels{ $self->log_level } < $log_levels{ $type };
    print sprintf("[${type}] ${format}\n", @args);
}

{
    no strict 'refs';
    my $pkg = __PACKAGE__;
    for my $type (qw/fatal error warn info debug/) {
        *{"$pkg\::$type"} = sub {
            my $self = shift;
            $self->log( $type => @_ );
        };
    }
}

1;


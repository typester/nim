package Nim::Log;
use Any::Moose;

has log_level => (
    is      => 'rw',
    isa     => 'Str',
    default => 'info',
);

no Any::Moose;

our %log_levels = (
    fatal => 0,
    error => 1,
    warn  => 2,
    info  => 3,
    debug => 4,
);

sub log {
    my ($self, $caller, $type, $format, @args) = @_;
    return if $log_levels{ $self->log_level } < $log_levels{ $type };
    print sprintf("[${type}] $caller: ${format}\n", @args);
}

{
    no strict 'refs';
    my $pkg = __PACKAGE__;
    for my $type (qw/fatal error warn info debug/) {
        *{"$pkg\::$type"} = sub {
            my $self   = shift;
            my $caller = caller;

            $self->log( $caller, $type => @_ );
        };
    }
}

__PACKAGE__->meta->make_immutable;

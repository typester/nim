package Nim::Entry;
use Any::Moose;

use Nim::Types;
use DateTime;

has [qw/path filename/] => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has time => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has datetime => (
    is         => 'rw',
    isa        => 'DateTime',
    lazy_build => 1,
);

has loader => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

has [qw/title body/] => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has rendered_body => (
    is  => 'rw',
);

no Any::Moose;

sub year {
    my ($self) = @_;
    $self->datetime->year;
}

sub month {
    my ($self) = @_;
    sprintf '%02d', $self->datetime->month;
}

sub day {
    my ($self) = @_;
    sprintf '%02d', $self->datetime->day;
}

sub _build_title {
    my ($self) = @_;
    $self->loader->( $self, 'title' );
}

sub _build_body {
    my ($self) = @_;
    $self->loader->( $self, 'body' );
}

sub _build_datetime {
    my ($self) = @_;

    DateTime->from_epoch(
        epoch     => $self->time,
        time_zone => Nim->context->conf->time_zone,
    );
}

__PACKAGE__->meta->make_immutable;

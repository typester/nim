package Nim::Entry;
use Any::Moose;

use Nim::Types;
use DateTime;
use Text::MicroTemplate qw(:all);

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

sub process_template {
    my ($self, $template, $params) = @_;

    my $_mt = Text::MicroTemplate->new( template => $template );
    my $_code = $_mt->code;

    my $_args = '';
    for my $k (keys %$params) {
        $_args .= "my \$${k} = \$_[0]->{$k};\n";
    }

    my $renderer = eval <<"..." or die $@;
sub {
    my \$entry = shift;
    my \$path = encoded_string(\$entry->path),
    my \$filename = encoded_string(\$entry->filename),
    my \$year = \$entry->year,
    my \$month = \$entry->month,
    my \$day = \$entry->day,
    my \$meta = \$entry->can('meta') ? \$entry->meta : undef;
    $_args;

    $_code->();
}
...

    $renderer->($self, $params);
}

__PACKAGE__->meta->make_immutable;

package Nim::Plugin::Render::Entry;
use Any::Moose;

use DateTime;
use URI::Template;

with 'Nim::Plugin';

has path => (
    is      => 'rw',
    isa     => 'Str',
    default => '{path}',
);

has filename => (
    is      => 'rw',
    isa     => 'Str',
    default => '{filename}.html',
);

use Carp;

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        'entry.render' => \&render,
    );
}

sub render {
    my ($self, $context, $entry) = @_;

    my $template = URI::Template->new( $self->path );
    my $dt       = DateTime->from_epoch(
        epoch     => $entry->time,
        time_zone => $context->conf->time_zone,
    );

    my $uri = $template->process(
        path     => $entry->path || '/',
        filename => $entry->filename,
        year     => $entry->year,
        month    => $entry->month,
        day      => $entry->day,
    );

    my $dir  = $context->conf->site_dir;
    my @path = grep { $_ } split '/', $uri;
    $dir = $dir->subdir(@path) if @path;

    $template = URI::Template->new($self->filename);
    $uri = $template->process(
        path     => $entry->path || '/',
        filename => $entry->filename,
        year     => $entry->year,
        month    => $entry->month,
        day      => $entry->day,
    );

    my $file = $dir->file($uri);
    $context->log->info('render: %s', $file);

    $file->parent->mkpath unless -d $file->parent;

    my $fh = $file->openw or croak "Can't write file: $!";
    print $fh $entry->rendered_body;
    $fh->close;
}

__PACKAGE__->meta->make_immutable;

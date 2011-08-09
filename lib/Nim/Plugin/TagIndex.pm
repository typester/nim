package Nim::Plugin::TagIndex;
use Any::Moose;

use URI::Template;

with 'Nim::Plugin';

extends 'Nim::Plugin::Index';

has path => (
    is      => 'rw',
    isa     => 'Str',
    default => 'tag/{tag}',
);

has filename => (
    is      => 'rw',
    isa     => 'Str',
    default => 'index.html',
);

has filter => (
    is      => 'rw',
    isa     => 'Str',
    default => 1,
);

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        'init_pages' => $self->can('init'),
        'page.render' => $self->can('render'),
    );
}

sub init {
    my ($self, $context) = @_;

    my $t = URI::Template->new( $self->path );
    my %entries_by_tag;

    for my $entry (@{ $context->entries }) {
        local $@;
        my $r = eval $self->filter;
        die $@ if $@;
        next unless $r;

        for my $tag (@{ $entry->meta->{tags} || [] }) {
            my $uri = $t->process(
                path     => $entry->path || '/',
                filename => $entry->filename,
                year     => $entry->year,
                month    => $entry->month,
                day      => $entry->day,
                tag      => $tag,
            );

            push @{ $entries_by_tag{$uri} }, $entry;
        }
    }
}

__PACKAGE__->meta->make_immutable;

package Nim::Plugin::AutoIndex;
use Any::Moose;

use URI::Escape;

with 'Nim::Plugin';

extends 'Nim::Plugin::Index';

has path => (
    is      => 'rw',
    isa     => 'Str',
    default => '{path}',
);

has filename => (
    is      => 'rw',
    isa     => 'Str',
    default => 'index.html',
);

has filter => (
    is      => 'rw',
    isa     => 'Str',
    default => '1',
);

has limit => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
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
    my %entries_path;

    for my $entry (@{ $context->entries }) {
        local $@;
        my $r = eval $self->filter;
        die $@ if $@;
        next unless $r;

        if ($entry->can('meta') and $self->path =~ /{tag}/) {
            # support tags
            for my $tag (@{ $entry->meta->{tags} || [] }) {
                my $uri = $t->process(
                    path     => $entry->path || '/',
                    filename => $entry->filename,
                    year     => $entry->year,
                    month    => $entry->month,
                    day      => $entry->day,
                    tag      => uri_escape_utf8($tag),
                );
                push @{ $entries_path{$uri} }, $entry;
            }
        }
        else {
            my $uri = $t->process(
                path     => $entry->path || '/',
                filename => $entry->filename,
                year     => $entry->year,
                month    => $entry->month,
                day      => $entry->day,
            );
            push @{ $entries_path{$uri} }, $entry;
        }
    }

    while (my ($path, $entries) = each %entries_path) {
        my $page = Nim::Page->new(
            creator  => $self,
            filename => join('/', $path, $self->filename),
            entries  => $entries,
        );
        push @{ $context->pages }, $page;
    }
}

__PACKAGE__->meta->make_immutable;

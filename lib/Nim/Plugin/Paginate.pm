package Nim::Plugin::Paginate;
use Any::Moose;

use Data::Page;

with 'Nim::Plugin';

has entries_per_page => (
    is      => 'rw',
    isa     => 'Int',
    default => 10,
);

has filter => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

no Any::Moose;

{
    package Nim::Plugin::Paginate::Page;
    use Any::Moose '::Role';

    has pager => (
        is  => 'rw',
        isa => 'Data::Page',
    );
}

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        after_init_pages => $self->can('paginate'),
    );

    my $page = Nim::Page->meta;
    $page->make_mutable if $Any::Moose::PREFERRED eq 'Moose';
    Nim::Plugin::Paginate::Page->meta->apply($page);
    $page->make_immutable;
}

sub paginate {
    my ($self, $context) = @_;

    my @pages;
    for my $page (@{ $context->pages }) {
        if ($self->filter) {
            local $@;
            my $r = eval $self->filter;
            die $@ if $@;

            unless ($r) {
                push @pages, $page;
                next;
            }
        }

        my $current_page = 1;

        my @entries = @{ $page->entries };
        while (my @e = splice @entries, 0, $self->entries_per_page) {
            my @path = split '/', $page->filename;
            my $fn = pop @path;

            if ($current_page > 1) {
                push @path, "page/${current_page}";
            }

            my $pager = Data::Page->new;
            $pager->total_entries(scalar @{ $page->entries });
            $pager->entries_per_page( $self->entries_per_page );
            $pager->current_page( $current_page );

            push @pages, Nim::Page->new(
                %$page,
                filename => join('/', @path, $fn),
                pager    => $pager,
                entries  => \@e,
            );

            $current_page++;
        }
    }

    $context->pages( \@pages );
}

__PACKAGE__->meta->make_immutable;

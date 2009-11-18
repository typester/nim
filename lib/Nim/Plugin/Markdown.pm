package Nim::Plugin::Markdown;
use Any::Moose;

with 'Nim::Plugin';

use Text::Markdown;

has md => (
    is         => 'rw',
    isa        => 'Text::Markdown',
    lazy_build => 1,
    handles    => ['markdown'],
);

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        'before_entry.interpolate' => \&process,
    );
}

sub process {
    my ($self, $context, $entry) = @_;
    $entry->body( $self->markdown( $entry->body ) );
}

sub _build_md {
    my ($self) = @_;
    Text::Markdown->new;
}

__PACKAGE__->meta->make_immutable;

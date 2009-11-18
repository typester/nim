package Nim::Plugin::Default;
use Any::Moose;

with 'Nim::Plugin';

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->load_plugin('Entry::File')
        unless $context->hooks->{find_entries};

    $context->load_plugin('Template::MicroTemplate')
        unless $context->hooks->{'entry.interpolate'};

    $context->load_plugin('Render::Entry')
        unless $context->hooks->{'entry.render'};
}

__PACKAGE__->meta->make_immutable;


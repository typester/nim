package Nim::Plugin::Template::TT;
use utf8;
use Mouse;

with 'Nim::Plugin';

use Carp;
use Template;

has tt => (
    is      => 'rw',
    isa     => 'Template',
    lazy    => 1,
    default => sub { Template->new },
);

no Mouse;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        interpolate   => \&interpolate,
    );
}

sub interpolate {
    my ($self, $context, $entry) = @_;

    warn 'inter';
    my $template = $context->run_hook_once( load_template => $entry );
warn $template;
    $self->tt->process(\$template, { nim => $context, entry => $entry }, \my $rendered);

    $entry->rendered_body( $rendered );
}

1;


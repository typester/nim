package Nim::Plugin::EmacsColor;
use Any::Moose;

with 'Nim::Plugin';

use Text::EmacsColor;
use HTML::TreeBuilder;
use Scalar::Util 'blessed';

has emacs_color => (
    is         => 'rw',
    isa        => 'Text::EmacsColor',
    lazy_build => 1,
);

has filter => (
    is  => 'rw',
    isa => 'Str',
);

has mode => (
    is      => 'rw',
    isa     => 'Str',
    default => 'cperl',
);

has emacs_command => (
    is  => 'rw',
    isa => 'Str',
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

    my $t = HTML::TreeBuilder->new;
    $t->parse_content($entry->body);

    for my $code ($t->find('code')) {
        my $child = $code->content_list;
        next if $child > 1;     # Not only text node, already colored?

        my $html = $code->content->[0];

        if (my $f = $self->filter) {
            next unless $html =~ /$f/;
        }

        my $res = $self->emacs_color->format($html, $self->mode);
        my ($body) = $res->full_html =~ m!<pre>\r?\n(.*)</pre>!s;

        $code->delete_content;
        $code->push_content(HTML::Element->new('~literal', text => $body));
    }

    my $result = join '',
        map { blessed $_ ? $_->as_XML : $_ } $t->find('body')->content_list;

    $t->delete;

    $entry->body($result);
}

sub _build_emacs_color {
    my ($self) = @_;
    Text::EmacsColor->new(
        $self->emacs_command ? (emacs_command => $self->emacs_command) : (),
    );
}

__PACKAGE__->meta->make_immutable;

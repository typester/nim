package Nim::Plugin::MultiMarkdown;
use Any::Moose;

with 'Nim::Plugin';

use Encode;
use Text::MultiMarkdown;

has md => (
    is         => 'rw',
    isa        => 'Text::MultiMarkdown',
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

    # meta support
    if ($entry->can('meta') and my $markup = $entry->meta->{markup}) {
        return unless lc $markup eq 'markdown';
    }

    $context->log->debug('apply markdown filter to %s', join '/', $entry->path, $entry->filename);

    my $body = $self->markdown( encode_utf8 $entry->body );
    $entry->body( decode_utf8 $body );
}

sub _build_md {
    my ($self) = @_;
    Text::MultiMarkdown->new;
}

__PACKAGE__->meta->make_immutable;

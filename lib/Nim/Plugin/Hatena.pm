package Nim::Plugin::Hatena;
use Any::Moose;

with 'Nim::Plugin';

use Encode;
use Text::Hatena;

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
        return unless lc $markup eq 'hatena';
    }

    $context->log->debug('apply hatena filter to %s', join '/', $entry->path, $entry->filename);

    my $body = Text::Hatena->parse( encode_utf8 $entry->body );
    $entry->body( decode_utf8 $body );
}

__PACKAGE__->meta->make_immutable;

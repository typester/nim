package Nim::Plugin::Meta;
use Any::Moose;

with 'Nim::Plugin';

use DateTime::Format::W3CDTF;

no Any::Moose;

{
    package Nim::Plugin::Meta::Entry;
    use Any::Moose '::Role';

    has meta => (
        is      => 'rw',
        isa     => 'HashRef',
        default => sub { {} },
    );
}

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        'after_find_entries' => \&apply,
    );

    # apply role
    my $entry = Nim::Entry->meta;

    $entry->make_mutable if $Any::Moose::PREFERRED eq 'Moose';
    Nim::Plugin::Meta::Entry->meta->apply( $entry );
    $entry->make_immutable;
}

sub apply {
    my ($self, $context) = @_;

 ENTRY:
    for my $entry (@{ $context->entries }) {
        my $src = $entry->body;

        my $meta = ref $entry->{meta} eq 'HASH' ? $entry->{meta} : {};
        my ($header, $body) = $src =~ /^(.*?)\r?\n\r?\n(.*)$/s;
        next unless $header;

        for my $line (split /\r?\n/, $header) {
            my ($key, $value) = $line =~ /^([\w\-_]+):\s*(.+)$/;
            next ENTRY unless $key; # invalid header

            $meta->{ lc $key } = $value || '';
        }

        if ($meta->{date}) {
            my $dt = DateTime::Format::W3CDTF->parse_datetime($meta->{date});
            $entry->time( $dt->epoch );
        }

        $entry->meta( $meta );
        $entry->body( $body );
    }
}

__PACKAGE__->meta->make_immutable;

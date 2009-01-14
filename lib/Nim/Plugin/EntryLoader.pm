package Nim::Plugin::EntryLoader;
use utf8;
use Mouse;

with 'Nim::Plugin';

use Nim::Entry;

no Mouse;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        find_entries => \&find,
    );
}

sub find {
    my ($self, $context) = @_;

    my $data_ext = $context->conf->data_extension;

    $context->conf->data_dir->recurse( callback => sub {
        my $f = $_[0];
        return unless -f $f;
        return unless $f->basename =~ /\.$data_ext$/;

        my $entry = Nim::Entry->new( file => $f );
        push @{ $context->entries }, $entry;
    });
}

1;


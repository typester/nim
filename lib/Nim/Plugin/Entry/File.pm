package Nim::Plugin::Entry::File;
use Any::Moose;

with 'Nim::Plugin';

use Carp;
use Nim::Entry;

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        find_entries => \&find,
    );
}

sub find {
    my ($self, $context) = @_;

    my $dir = $context->conf->data_dir->stringify;

    $context->conf->data_dir->recurse( callback => sub {
        my $f = $_[0];
        return unless -f $f;
        return unless $f->basename =~ /\.txt$/;

        (my $path = $f->parent) =~ s/^$dir//;
        (my $name = $f->basename) =~ s/\.txt$//;

        $context->log->info('find: %s', $f);

        my $entry = Nim::Entry->new(
            context  => $context,
            path     => $path,
            filename => $name,
            time     => $f->stat->mtime,
            loader   => sub {
                my ($entry, $want) = @_;

                open my $fh, '<:utf8', "$f"
                    or croak qq[Can't open entry file: "$f",  $!];

                my $title = <$fh>;
                my $body  = do { local $/; <$fh> };
                $fh->close;

                chomp $title;

                $entry->title( $title );
                $entry->body( $body );

                $want eq 'title' ? $title : $body;
            },
        );

        push @{ $context->entries }, $entry;
    });
}

__PACKAGE__->meta->make_immutable;

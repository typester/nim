package Nim::Plugin::Render::Entry;
use utf8;
use Mouse;

with 'Nim::Plugin';

no Mouse;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        render_entry => \&render,
    );
}

sub render {
    my ($self, $context, $entry) = @_;

    my ($fn) = $entry->file->basename =~ /^(.*)\./;
    $fn .= '.' . $context->conf->default_flavour;

    my $path = $entry->file->parent->stringify;
    my $root = $context->conf->data_dir->stringify;
    $path =~ s/^$root//;

    my $file = $path
        ? $context->conf->output_dir->subdir($path)->file($fn)
        : $context->conf->output_dir->file($fn);

    $file->parent->mkpath unless -d $file->parent;

    my $fh = $file->openw;
    print $fh $entry->rendered_body;
    $fh->close;
}

1;


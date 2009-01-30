package Nim::Plugin::TemplateLoader::Single;
use utf8;
use Mouse;

with 'Nim::Plugin';

no Mouse;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        load_template => \&load,
    );
}

sub load {
    my ($self, $context, $entry) = @_;

    my $template;
    my $data_dir = $context->conf->data_dir;
    my $path     = $entry->file->parent;
    my $fn       = 'template.' . $context->conf->default_flavour;

    while ($data_dir->contains($path)) {
        my $t = $path->file($fn);
        if (-f $t) {
            $template = $t->slurp;
            last;
        }
        $path = $path->parent;
    }

    return $template;
}

1;


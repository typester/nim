package Nim::Plugin::Render::Entry;
use Any::Moose;

use DateTime;
use Text::MicroTemplate;

with 'Nim::Plugin';

has path => (
    is      => 'rw',
    isa     => 'Str',
    default => '<?= $path ?>',
);

has filename => (
    is      => 'rw',
    isa     => 'Str',
    default => '<?= $filename ?>.html',
);

use Carp;

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        'entry.render' => \&render,
    );
}

sub render {
    my ($self, $context, $entry) = @_;

    my $uri = $entry->process_template($self->path);

    my $dir  = $context->conf->site_dir;
    my @path = grep { $_ } split '/', $uri;
    $dir = $dir->subdir(@path) if @path;

    $uri = $entry->process_template($self->filename);

    my $file = $dir->file($uri);
    $context->log->info('render: %s', $file);

    $file->parent->mkpath unless -d $file->parent;

    my $fh = $file->openw or croak "Can't write file: $!";
    binmode($fh, ':utf8');
    print $fh $entry->rendered_body;
    $fh->close;
}

__PACKAGE__->meta->make_immutable;

package Nim::Plugin::Index;
use Any::Moose;

use Carp;
use Nim::Page;

has output => (
    is  => 'rw',
    isa => 'Str',
);

no Any::Moose;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        'init_pages'   => \&init,
        'page.render' => \&render,
    );
}

sub init {
    my ($self, $context) = @_;

    my $page = Nim::Page->new(
        creator  => $self,
        filename => $self->output,
        entries  => $context->entries,
    );
    push @{ $context->pages }, $page;
}

sub render {
    my ($self, $context, $page) = @_;
    return unless $page->creator eq $self; # not my job

    my $dir  = $context->conf->site_dir;
    my @path = grep { $_ } split '/', $page->filename;
    my $fn   = pop @path;

    $dir = $dir->subdir(@path) if @path;
    my $file = $dir->file($fn);

    $context->log->info('render: %s', $file);

    $dir->mkpath unless -d $dir;

    my $fh = $file->openw or croak "Can't write file: $!";
    binmode($fh, ':utf8');
    print $fh $page->rendered;
    $fh->close;
}

__PACKAGE__->meta->make_immutable;


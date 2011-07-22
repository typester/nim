package Nim::Plugin::Template::MicroTemplate;
use Any::Moose;

with 'Nim::Plugin';

use Carp;
use Text::MicroTemplate::Extended;
use Path::Class qw/file dir/;

has mt => (
    is         => 'rw',
    isa        => 'Text::MicroTemplate::Extended',
    lazy_build => 1,
);

has context => (
    is       => 'rw',
    isa      => 'Nim',
    weak_ref => 1,
);

has handle_entry => (
    is       => 'rw',
    isa      => 'Nim::Entry',
    weak_ref => 1,
    clearer  => 'clear_entry',
);

has handle_page => (
    is       => 'rw',
    isa      => 'Nim::Page',
    weak_ref => 1,
    clearer  => 'clear_page',
);

no Any::Moose;

sub register {
    my ($self, $context) = @_;
    $self->context( $context );

    $context->register_hook(
        $self,
        'entry.interpolate' => \&interpolate_entry,
        'page.interpolate'  => \&interpolate_page,
    );
}

sub interpolate_entry {
    my ($self, $context, $entry) = @_;

    my $template = $self->find_template($context, $entry->path, 'entry.html')
        or die qq[Can't find template "entry.html" for entry: @{[ $entry->path ]}/@{[ $entry->filename ]}];

    $self->handle_entry( $entry );
    $self->clear_page;

    $entry->rendered_body( $self->mt->render($template) );
}

sub interpolate_page {
    my ($self, $context, $page) = @_;

    my @path = grep { $_ } split '/', $page->filename;
    my $fn   = pop @path;

    my $template = $self->find_template($context, join('/', '', @path), $fn)
        or die qq[Can't find template for @{[ $page->filename ]}];

    $context->log->debug('Find template %s for %s', $template, $page->filename);

    $self->clear_entry;
    $self->handle_page($page);

    $page->rendered( $self->mt->render($template) );
}

sub find_template {
    my ($self, $context, $path, $filename) = @_;

    my $dir = $context->conf->templates_dir;
    $path   = $dir->subdir( grep { $_ } split '/', $path );

#    $path->mkpath unless -d $path;

    while ($dir->subsumes($path)) {
        my $t = $path->file($filename);
        if (-f $t) {
            $t =~ s/^$dir//;
            $t =~ s{^[/\\]*}{};

            return $t;
        }
        $path = $path->parent;
    }

    return;
}

sub _build_mt {
    my ($self) = @_;
    my $context = $self->context or return;

    Text::MicroTemplate::Extended->new(
        include_path  => [$context->conf->templates_dir],
        template_args => {
            nim   => sub { $self->context },
            entry => sub { $self->handle_entry },
            page  => sub { $self->handle_page },
        },
        macro => {
            encoded_string => sub ($) {
                Text::MicroTemplate::encoded_string(@_);
            },
        },
        extension => '',
    );
}

__PACKAGE__->meta->make_immutable;

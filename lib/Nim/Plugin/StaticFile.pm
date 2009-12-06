package Nim::Plugin::StaticFile;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';
use File::Copy;

with 'Nim::Plugin';

coerce 'RegexpRef'
    => from 'Str'
    => via { qr/$_/ };

has regex => (
    is => 'ro',
    isa => 'RegexpRef',
    default => sub { qr{\.(?:css|js|pdf|jpg|gif|png|ico)} },
    coerce => 1,
);

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

    my $data_dir = $context->conf->data_dir->stringify;

    $context->conf->data_dir->recurse( 
        callback => sub {
            my $f = $_[0];
            return unless -f $f;
            return if $f->basename !~ $self->regex;
            $context->log->info('find: %s', $f);
            (my $path = $f->parent) =~ s/^$data_dir//;
            my @path = grep { $_ } split '/', $path;
            my $dir = $context->conf->site_dir;
            $dir = $dir->subdir(@path) if @path;
            my $file = $dir->file($f->basename);
            $context->log->info('copy to: %s', $file);
            $dir->mkpath unless -d $dir;
            copy $f->stringify, $file->stringify;
        }
    ); 
}

__PACKAGE__->meta->make_immutable;


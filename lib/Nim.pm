package Nim;
use Any::Moose;

our $VERSION = '0.01';

use Carp;
use Cwd qw/getcwd/;
use Path::Class qw/file dir/;

use Nim::Config;
use Nim::Entry;
use Nim::Log;

has conf => (
    is  => 'rw',
    isa => 'Nim::Config',
);

has hooks => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has entries => (
    is      => 'rw',
    isa     => 'ArrayRef[Nim::Entry]',
    default => sub { [] },
);

has pages => (
    is      => 'rw',
    isa     => 'ArrayRef[Nim::Page]',
    default => sub { [] },
);

has log => (
    is         => 'rw',
    isa        => 'Nim::Log',
    lazy_build => 1,
);

no Any::Moose;

do {
    my $CONTEXT;
    sub context {
        my ($class, $context) = @_;
        $CONTEXT = $context if $context;
        $CONTEXT;
    }
};

sub run {
    my ($self) = @_;

    $self->context($self);

    $self->load_config;
    $self->load_plugins;

    $self->run_hooks;
}

sub run_hooks {
    my ($self) = @_;

    $self->run_hook('initialize');

    $self->run_hook('find_entries');
    for my $entry (@{ $self->entries }) {
        $self->run_hook( 'entry.filter'      => $entry );
        $self->run_hook( 'entry.interpolate' => $entry );
        $self->run_hook( 'entry.render'      => $entry );
    }

    $self->run_hook('init_pages');
    for my $page (@{ $self->pages }) {
        $self->run_hook('page.filer'       => $page );
        $self->run_hook('page.interpolate' => $page );
        $self->run_hook('page.render'      => $page );
    }

    $self->run_hook('finalize');
}

sub run_hook {
    my ($self, $name, @args) = @_;

    $self->log->debug('run_hook: %s', $name);

    my @hooks = (
        @{ $self->hooks->{ 'before_' . $name } || [] },
        @{ $self->hooks->{$name}               || [] },
        @{ $self->hooks->{ 'after_' . $name }  || [] }
    );

    for my $hook (@hooks) {
        if ($hook->{plugin}->rule->dispatch($hook->{plugin}, $name, @args)) {
            $hook->{callback}->( $hook->{plugin}, $self, @args );
        }
    }
}

sub run_hook_once {
    my ($self, $name, @args) = @_;

    for my $hook (@{ $self->hooks->{$name} || [] }) {
        my $res = $hook->{callback}->( $hook->{plugin}, $self, @args );
        return $res if defined $res;
    }

    return;
}

sub load_config {
    my ($self) = @_;

    my $config_file = dir(getcwd)->file('.nim');
    croak 'config file ".nim" is not found on this directory' unless -f $config_file;

    $self->conf( Nim::Config->load($config_file) );

    $self->log->debug("Config file loaded");
    $self->log->debug('data_dir: %s', $self->conf->data_dir->absolute);
    $self->log->debug('site_dir: %s', $self->conf->site_dir->absolute);
    $self->log->debug('templates_dir: %s', $self->conf->templates_dir->absolute);
}

sub load_plugins {
    my ($self) = @_;

    for my $conf (@{ $self->conf->plugins }) {
        $conf->{config}{rule} ||= $conf->{rule};
        $self->load_plugin( $conf->{module}, $conf->{config} );
    }
    $self->load_plugin('Default');
}

sub load_plugin {
    my ($self, $module, $conf) = @_;

    $module =~ s/^\+//
        or $module = "Nim::Plugin::${module}";

    Any::Moose::load_class($module) unless Any::Moose::is_class_loaded($module);
    my $plugin = $module->new($conf || ());
    $plugin->register($self);
}

sub register_hook {
    my ($self, $plugin, @hooks) = @_;

    while (my ($hook, $callback) = splice @hooks, 0, 2) {
        push @{ $self->hooks->{ $hook } }, {
            plugin   => $plugin,
            callback => $callback,
        };
    }
}

sub _build_log {
    my ($self) = @_;
    Nim::Log->new( log_level => $self->conf->log_level );
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

Nim - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use Nim;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009 by KAYAC Inc.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

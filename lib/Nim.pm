package Nim;
use utf8;
use Mouse;

our $VERSION = '0.01';

use Carp;
use Cwd qw/getcwd/;
use Path::Class qw/file dir/;

use Nim::Config;
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
    lazy    => 1,
    default => sub { [] },
);

has logger => (
    is      => 'rw',
    isa     => 'Nim::Log',
    lazy    => 1,
    default => sub {
        my $self = shift;
        Nim::Log->new( log_level => $self->conf->log_level );
    },
);

no Mouse;

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

=head1 METHODS

=head2 new

=head2 run

=cut

sub run {
    my $self = shift;

    $self->load_config;
    $self->load_plugins;

    $self->run_hooks;
}

=head2 run_hooks



=cut

sub run_hooks {
    my $self = shift;

    $self->run_hook('initialize');
    $self->run_hook('find_entries');

    for my $entry (@{ $self->entries }) {
        $self->run_hook( filter       => $entry );
        $self->run_hook( interpolate  => $entry );
        $self->run_hook( render_entry => $entry );
    }

    $self->run_hook('render_pages');
    $self->run_hook('finalize');
}

=head2 run_hook

=cut

sub run_hook {
    my ($self, $name, @args) = @_;

    $self->logger->debug('run_hook: %s', $name);

    my @hooks = (
        @{ $self->hooks->{ 'before_' . $name } || [] },
        @{ $self->hooks->{$name}               || [] },
        @{ $self->hooks->{ 'after_' . $name }  || [] }
    );

    for my $hook (@hooks) {
        $hook->{callback}->( $hook->{plugin}, $self, @args );
    }
}

=head2 run_hook_once

=cut

sub run_hook_once {
    my ($self, $name, @args) = @_;

    for my $hook (@{ $self->hooks->{$name} }) {
        my $res = $hook->{callback}->( $hook->{plugin}, $self, @args );
        return $res if $res;
    }

    return;
}

=head2 load_config

=cut

sub load_config {
    my $self = shift;

    my $config_file = dir(getcwd)->file('.nim');
    croak 'config file ".nim" is not found on this directory' unless -f $config_file;

    $self->conf( Nim::Config->load($config_file) );

    $self->logger->debug('data_dir: %s', $self->conf->data_dir->absolute);
    $self->logger->debug('output_dir: %s', $self->conf->output_dir->absolute);
    $self->logger->debug('templates_dir: %s', $self->conf->templates_dir->absolute);
}

=head2 load_plugins

=cut

sub load_plugins {
    my $self = shift;

    for my $conf (@{ $self->conf->plugins }) {
        $self->load_plugin( $conf->{module}, $conf->{config} );
    }

    # load default plugins
    $self->load_plugin('EntryLoader') unless $self->hooks->{find_entries};
    $self->load_plugin('TemplateLoader::Single') unless $self->hooks->{load_template};
    $self->load_plugin('Template::TT') unless $self->hooks->{interpolate};
    $self->load_plugin('Render::Entry') unless $self->hooks->{render_entry};
}

=head2 load_plugin

=cut

sub load_plugin {
    my ($self, $module, $conf) = @_;

    unless ($module =~ s/^\+//) {
        $module = "Nim::Plugin::${module}";
    }

    Mouse::load_class($module) unless Mouse::is_class_loaded($module);
    my $plugin = $module->new($conf || ());
    $plugin->register($self);
}

=head2 register_hook

=cut

sub register_hook {
    my ($self, $plugin, @hooks) = @_;

    while (my ($hook, $callback) = splice @hooks, 0, 2) {
        push @{ $self->hooks->{ $hook } }, {
            plugin   => $plugin,
            callback => $callback,
        };
    }
}

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2009 KAYAC Inc. All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;

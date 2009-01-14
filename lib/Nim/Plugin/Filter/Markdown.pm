package Nim::Plugin::Filter::Markdown;
use utf8;
use Mouse;

with 'Nim::Plugin';

use Text::Markdown;

has md => (
    is      => 'rw',
    isa     => 'Text::Markdown',
    lazy    => 1,
    default => sub { Text::Markdown->new },
    handles => ['markdown'],
);

no Mouse;

sub register {
    my ($self, $context) = @_;

    $context->register_hook(
        $self,
        filter => \&process,
    );
}

sub process {
    my ($self, $context, $entry) = @_;
    $entry->body( $self->markdown($entry->body) );
}

1;

__END__

=head1 NAME

Nim::Plugin::Filter::Markdown - upgrade content by Markdown

=head1 SYNOSPS

    plugins:
      - module: Filter::Markdown

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2009 KAYAC Inc. All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

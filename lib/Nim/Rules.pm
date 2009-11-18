package Nim::Rules;
use Any::Moose;

use Nim::Operator;

has op => (
    is      => 'rw',
    isa     => 'NimOperator',
    default => 'AND',
    coerce  => 1,
);

has rules => (
    is      => 'rw',
    isa     => 'NimRules',
    default => sub { [] },
    coerce  => 1,
);

no Any::Moose;

sub dispatch {
    my ($self, $plugin, $hook, @args) = @_;

    my @bool;
    for my $rule (@{ $self->rules }) {
        push @bool, !!$rule->dispatch(@args);
    }

    # can't find rules for this phase: execute it
    return 1 unless @bool;

    Nim::Operator->call( $self->op, @bool );
}

__PACKAGE__->meta->make_immutable;

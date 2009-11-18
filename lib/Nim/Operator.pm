package Nim::Operator;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';

use Nim::Rule;

use List::Util qw(reduce);

our %Ops = (
    AND  => [ sub { $_[0] && $_[1] } ],
    OR   => [ sub { $_[0] || $_[1] } ],
    XOR  => [ sub { $_[0] xor $_[1] } ],
    NAND => [ sub { $_[0] && $_[1] }, 1 ],
    NOT  => [ sub { $_[0] && $_[1] }, 1 ], # alias of NAND
    NOR  => [ sub { $_[0] || $_[1] }, 1 ],
);

sub is_valid_op {
    my($class, $op) = @_;
    exists $Ops{$op};
}

sub call {
    my($class, $op, @bool) = @_;

    no warnings 'once';
    my $bool = reduce { $Ops{$op}->[0]->($a, $b) } @bool;
    $bool = !$bool if $Ops{$op}->[1];
    $bool;
}

subtype 'NimOperator' => as 'Str' => where { __PACKAGE__->is_valid_op($_) };
coerce  'NimOperator'
    => from 'Str'
    => via { uc $_ };

subtype 'NimRulesHash' => as 'ArrayRef[HashRef]';
subtype 'NimRules' => as 'ArrayRef[Object]';
coerce  'NimRules'
    => from 'NimRulesHash'
    => via { [map Nim::Rule->new($_), @$_ ] };

1;

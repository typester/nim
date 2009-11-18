package Nim::Plugin;
use Any::Moose '::Role';

use Nim::Rule;
use Nim::Rules;

requires 'register';

has rule => (
    is  => 'rw',
    isa => 'Object',
);

sub BUILDARGS {
    my ($self, $args) = @_;

    if (my $rule = $args->{rule}) {
        $rule = [$rule] if ref $rule eq 'HASH';
        $args->{rule} = Nim::Rules->new(
            op    => $args->{rule_op} || 'AND',
            rules => $rule
        );
    }
    else {
        $args->{rule} = Nim::Rule->new({ module => 'Always' });
    }

    $args;
}

1;

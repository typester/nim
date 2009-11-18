package Nim::Rule;
use strict;

sub new {
    my($class, $config) = @_;

    if (my $exp = $config->{expression}) {
        $config->{module} = 'Expression';
    }

    my $module = delete $config->{module};
    $module = "Nim::Rule::$module";
    Any::Moose::load_class($module) unless Any::Moose::is_class_loaded($module);

    $module->new($config);
}

1;




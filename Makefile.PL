use inc::Module::Install;
name 'Nim';
all_from 'lib/Nim.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;

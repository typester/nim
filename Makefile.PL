use inc::Module::Install;
name 'Nim';
all_from 'lib/Nim.pm';

requires 'Any::Moose' => '0.10';
requires 'Try::Tiny';
requires 'Path::Class';
requires 'URI::Template';
requires 'DateTime';
requires 'DateTime::Format::W3CDTF';
requires 'DateTime::Format::HTTP';
requires 'URI::Escape';
requires 'Text::Markdown';
requires 'Text::Hatena';
requires 'List::Util';
requires 'YAML::Syck';
requires 'Plack';
requires 'Text::MicroTemplate::Extended' => '0.06';

test_requires 'Test::More';
use_test_base;
author_tests('xt');

auto_include;
auto_install;
auto_set_repository;

WriteAll;

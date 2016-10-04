requires 'Module::Load';
requires 'Mojo::DOM';
requires 'Moose';
requires 'Template';
requires 'Text::Hyphen';
requires 'namespace::autoclean';
requires 'perl', '5.010001';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
    requires 'Module::Install';
    requires 'Test::Memory::Cycle';
    requires 'Test::More';
};

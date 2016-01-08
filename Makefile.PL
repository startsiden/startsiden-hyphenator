use inc::Module::Install;

name 'Startsiden-Hyphenator';

# These override things fetched by 'all_from' below.
# They must come *before* the call to 'all_from'.
perl_version '5.010001';
license 'proprietary'; # the license type ('all_from' needs this)

all_from 'lib/Startsiden/Hyphenator.pm';

configure_requires 'Module::Install' => 0;

requires 'Module::Load';
requires 'Mojo::DOM';
requires 'Moose';
requires 'Template';
requires 'Text::Hyphen';

test_requires 'Test::More';
test_requires 'Test::Memory::Cycle';
#dpkg_requires 'texlive-lang-norwegian';

# Perl modules needed at run-time

tests_recursive;

WriteAll;

#!/usr/bin/perl

use Encode;
use File::Basename;
use File::Slurp;

my ($language) = @ARGV;

help() unless defined $language;
 
sub help {
  printf "Usage: %s <language>\n",  basename $0;
}

my $content = File::Slurp::read_file( get_tex_file($language), binmode => ':utf8' ) ;
 
my @words;
my @exceptions;

$content =~ s{ % .*? \n}{}gmsx;

if ($content =~ m{ \\patterns \s* \{ \s* (.*?) \s* \} }gmsx) {
  @words = split /\s+/, $1;
}

if ($content =~ m{ \\hyphenation \s* \{ \s* (.*?) \} }gmsx) {
  @exceptions = split /\s+/, $1;
}

print Encode::encode_utf8 "package Text::Hyphen::" . ucfirst($language) . ";

use strict;
use warnings;

use utf8;
use base 'Text::Hyphen';

sub _PATTERNS {
    return [qw(
        @words
    )];
}

sub _EXCEPTIONS {
    return [qw(
        @exceptions
    )];
}

1;
";

sub get_tex_file {
   my ($language) = @_;
   # squeeze, wheezy
   my $pattern_dirs = [qw(
     /usr/share/texmf-texlive/tex/generic/hyph-utf8/patterns/
     /usr/share/texlive/texmf-dist/tex/generic/hyph-utf8/patterns/tex/
   )];
   foreach my $pattern_dir (@{$pattern_dirs}) {
     return $pattern_dir . 'hyph-' . $language . '.tex' if -e $pattern_dir;
   }
}



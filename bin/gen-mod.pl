#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Encode;
use File::Basename;
use File::Slurp;

my ($language, $target_language, $pre_generate) = @ARGV;

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

use Text::Hyphen;

*Text::Hyphen::_PATTERNS   = sub { [ map { $_ } @words ] };
*Text::Hyphen::_EXCEPTIONS = sub { [ map { $_ } @exceptions ] };

my $t = Text::Hyphen->new();
$Data::Dumper::Indent = 0;
my $PREGEN_TRIE = Dumper($t->{trie});
{
    no warnings 'uninitialized';
    $PREGEN_TRIE =~ s{\s*|'([\w|\d+])'}{$1}gmx;
};

print Encode::encode_utf8 "package Text::Hyphen::" . ucfirst($target_language || $language) . ';
# Generated with '."$0 @ARGV".'
use strict;
use warnings;

use utf8;
use base q{Text::Hyphen};

my $VAR1;
';

if ($pre_generate) {
    print Encode::encode_utf8 $PREGEN_TRIE;
}

print Encode::encode_utf8 '
sub new {
    my ($proto, @fields) = @_;
    my $class = ref $proto || $proto;

    my $self = { @fields };
    
    $self->{min_word}   ||= 5;
    $self->{min_prefix} ||= 2;
    $self->{min_suffix} ||= 2;

    $self->{trie} = $VAR1 || {};

    bless $self, $class;

    $VAR1 || $self->_load_patterns;

    return $self;
}

';

if ( ! $pre_generate ) {
    print Encode::encode_utf8 '
sub _PATTERNS {
    return [qw(
        ' . "@words" . '
    )];
}
    ';
}

print Encode::encode_utf8 '
sub _EXCEPTIONS {
    return [qw(
        ' . "@exceptions" . '
    )];
}

1;
';

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



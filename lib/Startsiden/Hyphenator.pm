package Startsiden::Hyphenator;

use English qw/-no_match_vars/;
use Module::Load;
use Moo;
use utf8;
use Text::Hyphen::No_pregen;

our $VERSION = '1.11';

# TODO add Memoization with memory limit

has 'delim' => (
  is => 'rw',
  default => "\x{00AD}",
);

has 'threshold' => (
  is => 'rw',
  default => 10,
);

has 'language' => (
  is => 'rw',
  default => 'no_pregen',
);

has 'leftmin' => (
  is => 'rw',
  default => 3, 
);

has 'rightmin' => (
  is => 'rw',
  default => 3, 
);

has 'hyphenator' => (
  is => 'rw',
  lazy => 1,
  default => sub {
    my $self = shift;

    my $module = 'Text::Hyphen::' . ucfirst $self->language;

    eval { 
       Module::Load::load $module;
       1;
    } or do {
       die "Error loading '$module', language '" . $self->language . "' not supported: $EVAL_ERROR";
    };

    return $module->new(
      min_prefix => $self->leftmin,
      min_suffix => $self->rightmin,
      min_word   => $self->threshold,
    );
  }
);

sub hyphenate {
  my ($self, $text, $delim, $threshold) = @_;

  $threshold ||= $self->threshold;
  $delim     ||= $self->delim;

  # trim and store leading space
  $text =~ m{ \A (\s+)    }gmx;
  my $prefix_space  = $1 || q{};

  # trim and store trailing space
  $text =~ m{    (\s+) \z }gmx;
  my $postfix_space = $1 || q{};

  # replace em dashes and hyphens with trailing non-breaking space to avoid ending up with the hyphen on its own line
  $text =~ s{ \A ([-–]) \s+ }{–\xa0}gmx;

  # split on spaces and tabs, then on dashes, words might be hyphenated already
  # and join again after running hyphenation on it
  $text = join ' ', map { 
      join '-', map { 
          $self->hyphenate_word($_, $delim, $threshold) 
      } $_ eq "-" ? ("-") : split /-/, $_;
  # Note only " " and \t, so that other types of spaces (like non-breaking space \xa0 doesn't match)
  } split m{[ \t]}, $text; 

  return join '', $prefix_space, $text, $postfix_space;
}

sub hyphenate_word {
  my ($self, $word, $delim, $threshold) = @_;

  $threshold ||= $self->threshold;
  $delim     ||= $self->delim;

  return $word if length $word < $threshold;

  my $orig_threshold = $self->hyphenator->{min_word};
  $self->hyphenator->{min_word} = $threshold;

  $word = $self->hyphenator->hyphenate($word, $delim);
  $self->hyphenator->{min_word} = $orig_threshold;

  return $word;

  my $number = 0;
  my $pos;
  for $pos ($self->hyphenator->hyphenate($word)) {
    substr($word, $pos + $number, 0) = $delim;
    $number++;
  }

  return $word;
}

1;

=head1 NAME

Startsiden::Hyphenator - Hyphenate strings bases on LaTeX rules

=head1 VERSION

Version 0.01

=head1 SYNOPSIS   

    use Startsiden::Hyphenator;

    my $h = Startsiden::Hyphenator->new({ delim => ',', leftmin => 2, rightmin => 2 });

    # 'Bul,jon,pakke,mes,ter,as,sis,tent'
    $h->hyphenate('Buljonpakkemesterassistent');

See tests for more inputs and expected outputs

=head1 DESCRIPTION

This module breaks up words and inserts a given delimiter (soft hyphen unicode character by default).
It supports different arguments to decide how long a word should be before it should be hyphenated, 
and what the minimum amount of characters should be on the left and right side of the word. You can
also set the hyphenation sign it should use, and which language the hyphenation rules should follow.

=head1 ATTRIBUTES

=over

=item delim

What character to use as a delimiter on the returning string.
Default: soft hyphen unicode character (\x0a)

=item threshold

Threshold that decides how long a word should be before it is hyphenated, an integer describing amount of characters.
Default: 10

=item language

The hyphenation rules will be based on this language (Default: Norwegian (no))

=item file

Which file to get the hyphenation rules from.
Default: '/usr/share/texlive/texmf-dist/tex/generic/hyph-utf8/patterns/tex/hyph-' $self->language . '.tex'
         or '/usr/share/texmf-texlive/tex/generic/hyph-utf8/patterns/tex/hyph-' $self->language . '.tex'
         depending on Debian version.

=item leftmin

Minimum amount of characters should be left unhyphenated at the beginning (left) of the word.

=item rightmin

Minimum amount of characters should be left unhyphenated at the end (right) of the word.

=item hyphenator

The hyphenator object
Default: TeX::Hyphen

=back

=head1 METHODS

=over

=item C<hyphenate($string, $delim, $threshold)>

Returns a hyphenated string

=back

=head1 SEE ALSO

=over 4

=item * L<TeX::Hyphen>

=back

=head1 BUGS

Please report any bugs or feature requests to http://bugs.startsiden.no/,

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Startsiden::Hyphenator

=head1 AUTHOR

Nicolas Mendoza, C<< <nicolas.mendoza@startsiden.no> >>

=head1 COPYRIGHT & LICENSE

All Rights reserved to ABC Startsiden © 2014


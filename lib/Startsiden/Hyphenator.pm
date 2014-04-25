package Startsiden::Hyphenator;

use Moose;
use utf8;
use Readonly;
use TeX::Hyphen;

our $VERSION = '1.00';

# TODO add Memoization with memory limit

has 'delim' => (
  is => 'rw',
  default => "-\n",
);

has 'threshold' => (
  is => 'rw',
  default => 10,
);

has 'language' => (
  is => 'rw',
  default => 'no',
);

has 'file' => (
  is => 'rw',
  lazy => 1,
  default => sub {
      my ($self) = @_; 
      return '/usr/share/texlive/texmf-dist/tex/generic/hyph-utf8/patterns/tex/hyph-' . $self->language . '.tex'; 
  },
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

    TeX::Hyphen->new(
      'file' => $self->file,
      'style' => 'czech',
      leftmin => $self->leftmin,
      rightmin => $self->rightmin,
    ) or die 'Unable to load file: ' . $self->file() . q{. Did you install 'texlive-lang-norwegian' or similar?};
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

  my $number = 0;
  my $pos;
  for $pos ($self->hyphenator->hyphenate($word)) {
    substr($word, $pos + $number, 0) = $delim;
    $number++;
  }

  return $word;
}

1;

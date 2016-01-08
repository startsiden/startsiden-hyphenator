use strict;
use warnings;

use Startsiden::Hyphenator;
use Test::More;
use Time::HiRes qw(time);

my $start = time;
my $h = Startsiden::Hyphenator->new(delim => ',', language => 'no');

unless ( $h->is_enabled ) {
    plan skip_all => 'Hyphenator is disabled';
}

is $h->hyphenate('kjempelangt'), 'kjempe,langt', 'Correct hyphenation';
my $stop = time;

my $loop_start = time;
my $loops = 100;
for my $i (0..$loops) {
   my $h2 = Startsiden::Hyphenator->new();
   is $h->hyphenate("kjempelangt"), 'kjempe,langt', "Correction hyphenation $i";;
}
my $loop_stop = time;

my $elapsed_one  = $stop - $start;
my $elapsed_loop = $loop_stop - $loop_start;

ok(
   ($elapsed_loop < (2*$elapsed_one)),
   sprintf "%d consecutive hyphens, should be faster than 2x one hyphenation: %.3f < 2 x %.3f",
       ($loops, $elapsed_loop, $elapsed_one)
);

# pre-generated language
my $p_start = time;

my $p = Startsiden::Hyphenator->new(language => 'no_pregen', delim => ',');

is $p->hyphenate('kjempelangt'), 'kjempe,langt', 'Correct hyphenation';
my $p_stop = time;

my $p_loop_start = time;
my $p_loops = 100;
for my $i (0..$p_loops) {
   my $p2 = Startsiden::Hyphenator->new();
   is $p->hyphenate("kjempelangt"), 'kjempe,langt', "Correction hyphenation $i";;
}
my $p_loop_stop = time;

my $p_elapsed_one  = $p_stop - $p_start;
my $p_elapsed_loop = $p_loop_stop - $p_loop_start;

ok(
   ($p_elapsed_one < $elapsed_one),
   sprintf "Pre-generated hyphenator, should be much faster normal hyphenator: %.3f < %.3f",
       ($p_elapsed_one, $elapsed_one)
);


done_testing;


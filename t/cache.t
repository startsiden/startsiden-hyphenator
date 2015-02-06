use strict;
use warnings;

use Startsiden::Hyphenator;
use Test::More;
use Time::HiRes qw(time);

my $start = time;
my $h = Startsiden::Hyphenator->new(delim => ',');
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
   (2*$elapsed_one) > $elapsed_loop, 
   sprintf "%d consecutive hyphens, should be faster than 2x one hyphenation: %.3f > %.3f", 
       ($loops, $elapsed_one, $elapsed_loop)
); 

done_testing;


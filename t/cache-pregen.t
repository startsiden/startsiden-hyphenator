use strict;
use warnings;

use Startsiden::Hyphenator;
use Test::More;
use Time::HiRes qw(time);
delete $INC{'Text/Hyphen/No_pregen.pm'};

my $start = time;
my $h = Startsiden::Hyphenator->new(delim => ',', language => 'no_pregen');

if ( $h->is_enabled ) {
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
}
else {
    is $h->hyphenate('kjempelangt'), 'kjempelangt', 'Correct hyphenation';
}

done_testing;

# Copied from SeDenne - using a really long word ;)
use strict;
use warnings;
use utf8;
use Test::More;
use Startsiden::Hyphenator;
use Template;

my $h = Startsiden::Hyphenator->new;

unless ( $h->is_enabled ) {
    plan skip_all => 'Hyphenator is disabled';
}

my $tt = Template->new(
   PLUGINS => {hyphenator => 'Startsiden::Template::Plugin::Hyphenator'},
);

my $output;
$tt->process(\'[% USE Hyphenator ","; "menneskerettighetsorganisasjonssekretærkursmateriellet" | hyphen %]', undef, \$output);
is($output, 'men,neske,ret,tig,hets,or,ga,ni,sa,sjons,sek,re,tær,kurs,ma,te,ri,el,let', 'Plugin works');

done_testing;

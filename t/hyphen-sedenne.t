# Copied from SeDenne - using a really long word ;)
use strict;
use warnings;
use utf8;
use Test::More;
use Startsiden::Hyphenator;
use Template;

my $h = Startsiden::Hyphenator->new;

my $tt = Template->new(
   PLUGINS => {hyphenator => 'Startsiden::Template::Plugin::Hyphenator'},
);

my $output;

if ( $h->is_enabled ) {
    $tt->process(\'[% USE Hyphenator ","; "menneskerettighetsorganisasjonssekretærkursmateriellet" | hyphen %]', undef, \$output);
    is($output, 'men,neske,ret,tig,hets,or,ga,ni,sa,sjons,sek,re,tær,kurs,ma,te,ri,el,let', 'Plugin works');
}
else {
    $tt->process(\'[% USE Hyphenator ","; "menneskerettighetsorganisasjonssekretærkursmateriellet" | hyphen %]', undef, \$output);
    is($output, 'menneskerettighetsorganisasjonssekretærkursmateriellet', 'Plugin works');
}

done_testing;

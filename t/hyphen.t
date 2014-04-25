use strict;
use warnings;

use utf8;

use Test::More;

use Startsiden::Hyphenator;

my $h = Startsiden::Hyphenator->new({ delim => ',', leftmin => 2, rightmin => 2 });
is($h->hyphenate('Buljonpakkemesterassistent'), 'Bul,jon,pakke,mes,ter,as,sis,tent', 'Helper works');
is($h->hyphenate('En del små ord som aldri blir delt'), 'En del små ord som aldri blir delt', 'Helper does not interfere with small words');
is($h->hyphenate('Seinfeld beskylder Lego-filmen for vitsetyveri'),  'Seinfeld beskylder Lego-filmen for vitse,ty,ve,ri', 'Words already hyphenated should not get two consecutive dashes');

is($h->hyphenate('- Æsjabæsj, sa mannen'), "–\x{00A0}Æ,sjabæ,sj, sa mannen", 'Citation fix-up, so that it does not wrap');

is($h->hyphenate('lalala - lalala'), 'lalala - lalala', 'Helper works with spaces and dashes');

is($h->hyphenate('lalala '), 'lalala ', 'Helper works with ending space');

my $h2 = Startsiden::Hyphenator->new({ delim => ',', threshold => 2 });
is($h2->hyphenate('stjernen'), 'stjer,nen', 'Helper works using lower threshold');

use Template;
my $tt = Template->new(
   PLUGIN_BASE => 'Startsiden::Template::Plugin',
);

my $output;
$tt->process(\'[% USE Hyphenator ","; "Buljonpakkemesterassistent" | hyphen %]', undef, \$output);
is($output, 'Bul,jon,pakke,mes,ter,as,sis,tent', 'Plugin works');

my $output2;
$tt->process(\'[% USE Hyphenator "," 3; "stjernen" | hyphen %]', undef, \$output2);
is($output2, 'stjer,nen', 'Plugin works using lower threshold');

(done_testing && exit 0) unless eval { require Mojo::DOM; 1; };

my $output3;
$tt->process(\q{[% USE Hyphenator "," 3; '<b class="lol" style="color: #ff000">stjernen</b>' | hyphen %]}, undef, \$output3);
is($output3, '<b class="lol" style="color: #ff000">stjer,nen</b>', 'Plugin works using lower threshold and HTML');

my $output4;
$tt->process(\q{[% USE Hyphenator "," 3; '<span>Bakgrunn: </span><span>Some text</span>' | hyphen %]}, undef, \$output4);
is($output4, '<span>Bak,grunn: </span><span>Some text</span>', 'Plugin works using lower threshold and HTML');

done_testing;

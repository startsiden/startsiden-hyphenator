use strict;
use warnings;

use utf8;

use Test::More;
use Test::Memory::Cycle;

use Startsiden::Hyphenator;

my $h = Startsiden::Hyphenator->new({ delim => ',', leftmin => 2, rightmin => 2 });
is($h->hyphenate('Buljonpakkemesterassistent'), 'Bul,jon,pakke,mes,ter,as,sis,tent', 'Helper works');
is($h->hyphenate('En del små ord som aldri blir delt'), 'En del små ord som aldri blir delt', 'Helper does not interfere with small words');
is($h->hyphenate('Seinfeld beskylder Lego-filmen for vitsetyveri'),  'Seinfeld beskylder Lego-filmen for vitse,ty,ve,ri', 'Words already hyphenated should not get two consecutive dashes');

is($h->hyphenate('- Æsjabæsj, sa mannen'), "–\x{00A0}Æsjabæsj, sa mannen", 'Citation fix-up, so that it does not wrap');

is($h->hyphenate('lalala - lalala'), 'lalala - lalala', 'Helper works with spaces and dashes');

is($h->hyphenate('lalala  '), 'lalala  ', 'Helper works with ending space');

is($h->hyphenate('  lalala'), '  lalala', 'Helper works with starting space');

is($h->hyphenate(' lalala '), ' lalala ', 'Helper works with both starting and ending space');

my $h2 = Startsiden::Hyphenator->new({ delim => ',', threshold => 2 });
is($h2->hyphenate('stjernen'), 'stjer,nen', 'Helper works using lower threshold');

my $h3 = Startsiden::Hyphenator->new();
is($h3->hyphenate("vitsetyveri"), "vitse\x{00AD}ty\x{00AD}veri", 'Correct default value');

use Template;
my $tt = Template->new(
   PLUGIN_BASE => 'Startsiden::Template::Plugin',
   ENCODING => 'utf8',
   STRICT => 1,
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

TODO: {
    local $TODO = "Dynamic filter not implemented";
    my $output5;
    $tt->process(\q{[% USE Hyphenator; '<span>Bakgrunn: </span><span>Some text</span>' | hyphen(",", 3) %]}, undef, \$output5);
    is($output5, '<span>Bak,grunn: </span><span>Some text</span>', 'Plugin works using lower threshold and HTML');

    my $output6;
    $tt->process(\q{[% USE Hyphenator delim = ",", threshold = 3 %][% '<span>Bakgrunn: </span><span>Some text</span>' | hyphen %]}, undef, \$output6);
    is($output6, '<span>Bak,grunn: </span><span>Some text</span>', 'Plugin works using lower threshold and HTML and named parameters in use call');

    my $output7;
    $tt->process(\q{[% USE Hyphenator %][% FILTER $Hyphenator delim => ",", threshold => 3 %]<span>Bakgrunn: </span><span>Some text</span>[% END %]}, undef, \$output7);
    is($output7, '<span>Bak,grunn: </span><span>Some text</span>', 'Plugin works using lower threshold and HTML, and named parameters in filter call');
}

memory_cycle_ok($tt, 'No memory cycles');

done_testing;

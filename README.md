# NAME

Startsiden::Hyphenator - Hyphenate strings bases on LaTeX rules

# VERSION

Version 1.13

# SYNOPSIS

    use Startsiden::Hyphenator;

    my $h = Startsiden::Hyphenator->new({ delim => ',', leftmin => 2, rightmin => 2 });

    # 'Bul,jon,pakke,mes,ter,as,sis,tent'
    $h->hyphenate('Buljonpakkemesterassistent');

See tests for more inputs and expected outputs

# DESCRIPTION

This module breaks up words and inserts a given delimiter (soft hyphen unicode character by default).
It supports different arguments to decide how long a word should be before it should be hyphenated,
and what the minimum amount of characters should be on the left and right side of the word. You can
also set the hyphenation sign it should use, and which language the hyphenation rules should follow.

By default, the hyphenator inserts soft hyphens (http://www.fileformat.info/info/unicode/char/00AD/index.htm). This can be changed when including the plugin:
    \[% USE Hyphenator ","; "menneskerettighetsorganisasjonssekretærkursmateriellet" | hyphen %\]

For usage examples, check out the tests. Such as https://github.com/startsiden/startsiden-hyphenator/blob/master/t/hyphen.t#L11 and https://github.com/startsiden/startsiden-hyphenator/blob/master/t/hyphen-s#

# ATTRIBUTES

- delim

    What character to use as a delimiter on the returning string.
    Default: soft hyphen unicode character (\\x0a)

- threshold

    Threshold that decides how long a word should be before it is hyphenated, an integer describing amount of characters.
    Default: 10

- language

    The hyphenation rules will be based on this language (Default: Norwegian (no))

- file

    Which file to get the hyphenation rules from.
    Default: '/usr/share/texlive/texmf-dist/tex/generic/hyph-utf8/patterns/tex/hyph-' $self->language . '.tex'
             or '/usr/share/texmf-texlive/tex/generic/hyph-utf8/patterns/tex/hyph-' $self->language . '.tex'
             depending on Debian version.

- leftmin

    Minimum amount of characters should be left unhyphenated at the beginning (left) of the word.

- rightmin

    Minimum amount of characters should be left unhyphenated at the end (right) of the word.

- hyphenator

    The hyphenator object
    Default: TeX::Hyphen

# METHODS

- `hyphenate($string, $delim, $threshold)`

    Returns a hyphenated string

# SEE ALSO

- [TeX::Hyphen](https://metacpan.org/pod/TeX::Hyphen)

# BUGS

Please report any bugs or feature requests to http://bugs.startsiden.no/,

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Startsiden::Hyphenator

# AUTHOR

Nicolas Mendoza, `<nicolas.mendoza@startsiden.no>`

# COPYRIGHT & LICENSE

All Rights reserved to ABC Startsiden © 2014

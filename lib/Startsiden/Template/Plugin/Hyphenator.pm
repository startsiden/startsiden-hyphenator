package Startsiden::Template::Plugin::Hyphenator;

use warnings;
use strict;

use Startsiden::Hyphenator;

# This will die if Template::Toolkit is not in use, but then this plugin is not needed.
use Template::Plugin::Filter;
use parent qw( Template::Plugin::Filter );

my $hyphenator;

sub init {
    my ($self) = @_;
    $self->{has_mojo_dom} = eval { require Mojo::DOM; 1; };
    warn "Mojo::DOM not found, will not be able to hyphenate HTML" unless $self->{has_mojo_dom};
    $hyphenator ||= Startsiden::Hyphenator->new();
    $self->install_filter('hyphen');

    return $self;
}

sub filter {
    my ($self, $text) = @_;

    my $args      = $self->{_ARGS};
    my $delim     = $args->[0] || "\x{00AD}";
    my $threshold = $args->[1] || 10;

    if ($self->{has_mojo_dom}) {
        my $d = Mojo::DOM->new($text);
        $d->all_contents->map( sub {
            $_->content( $hyphenator->hyphenate($_->content, $delim, $threshold) ) if $_->node eq 'text';
            $_;
        });
        return "$d";
    } else {
        return $hyphenator->hyphenate($text, $delim, $threshold);
    }
}

1;

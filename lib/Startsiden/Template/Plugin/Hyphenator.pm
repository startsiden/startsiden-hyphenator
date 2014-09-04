package Startsiden::Template::Plugin::Hyphenator;

use warnings;
use strict;

use Startsiden::Hyphenator;

# This will die if Template::Toolkit is not in use, but then this plugin is not needed.
use Template::Plugin::Filter;
use parent qw( Template::Plugin::Filter );
use Scalar::Util 'weaken';

our $DYNAMIC = 0 unless defined $DYNAMIC;

my $HAS_MOJO_DOM = eval { require Mojo::DOM; 1; };
warn "Mojo::DOM not found, will not be able to hyphenate HTML" unless $HAS_MOJO_DOM;

my $hyphenator;

sub new {
    my ($class, $context, @args) = @_;
    my $config = @args && ref $args[-1] eq 'HASH' ? pop(@args) : { };

    # look for $DYNAMIC
    my $dynamic;
    {
        no strict 'refs';
        $dynamic = ${"$class\::DYNAMIC"};
    }
    $dynamic = $DYNAMIC unless defined $dynamic;

    my $self = bless {
        _CONTEXT => $context,
        _DYNAMIC => $dynamic,
        _ARGS    => \@args,
        _CONFIG  => $config,
    }, $class;

    $hyphenator ||= Startsiden::Hyphenator->new();

    return $self->init($config)
        || $class->error($self->error());
}


sub init {
    my ($self, $config) = @_;
    my $name = $self->{ _CONFIG }->{ name } || 'hyphen';
    $self->install_filter($name);
    return $self;
}


sub factory {
    my $self = shift;
    my $this = $self;
    weaken($this);

    if ($self->{ _DYNAMIC }) {
        return $self->{ _DYNAMIC_FILTER } ||= [ sub {
            my ($context, @args) = @_;
            my $config = ref $args[-1] eq 'HASH' ? pop(@args) : { };
        
            return sub {
                $this->filter(shift, \@args, $config);
            };
        }, 1 ];
    }
    else {
        return $self->{ _STATIC_FILTER } ||= sub {
            $this->filter(shift);
        };
    }
}

sub filter {
    my ($self, $text, $args, $config) = @_;

    $args      = $self->merge_args($args);
    $config    = $self->merge_config($config);

    my $delim     = $args->[0] || $config->{delimiter} || "\x{00AD}";
    my $threshold = $args->[1] || $config->{threshold} || 10;

    if ($HAS_MOJO_DOM) {
        my $d = Mojo::DOM->new($text);
        $d->all_contents->map( sub {
            $_->content( $hyphenator->hyphenate($_->content, $delim, $threshold) ) if $_->node eq 'text';
            $_;
        });
        return "$d";
    } else {
        return $hyphenator->hyphenate($text, $delim, $threshold);
    }

    return $text;
}


sub merge_config {
    my ($self, $newcfg) = @_;
    my $owncfg = $self->{ _CONFIG };
    return $owncfg unless $newcfg;
    return { %$owncfg, %$newcfg };
}


sub merge_args {
    my ($self, $newargs) = @_;
    my $ownargs = $self->{ _ARGS };
    return $ownargs unless $newargs;
    return [ @$ownargs, @$newargs ];
}


sub install_filter {
    my ($self, $name) = @_;
    $self->{ _CONTEXT }->define_filter( $name => $self->factory() );
    return $self;
}

1;

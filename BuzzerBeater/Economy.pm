#
#  $Id: Economy.pm,v 1.2 2009-04-04 12:43:38 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Economy;

use XML::Twig;
use Carp;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->_initialize(@_);
    return $self;
}

sub _initialize {
    my $self = shift;

    if (@_) {
        my $args = shift;
        $self->setFromXml( $args->{xml} ) if ( exists $args->{xml} );
    }
}

sub setFromXml {
    my $self = shift;
    my $xml  = shift;

    my $twig = XML::Twig->new(
        twig_handlers => {

            #economy  => sub { _parse_economy( $self, @_ ) },
            lastWeek => sub { _parse_week( $self, @_ ) },
            thisWeek => sub { _parse_week( $self, @_ ) },
        }
    );
    $twig->parse($xml);    # safe_parse or croak?

    my $el = $twig->root->first_child();
    if ( $el->gi ne 'economy' ) {
        carp "Unexpected child element processing economy xml: " . $el->gi;
    }
    return $self;
}

sub _parse_week {
    my ( $self, $twig, $week ) = @_;

    foreach my $entry ( $week->children ) {
        if ( $entry->gi eq 'matchRevenue' ) {
            $self->{ $week->gi }->{ $entry->gi }->{ $entry->att('matchid') }
                = $entry->text;
        }
        else {
            $self->{ $week->gi }->{ $entry->gi } = $entry->text;
        }
    }
}

##############################################################################
#
#  API

sub balance { my $self = shift; return $self->thisWeek->{current}; }

sub playerSalaries {
    my $self = shift;
    return -$self->thisWeek->{playerSalaries};
}
sub thisWeek { my $self = shift; return $self->{thisWeek}; }
sub lastWeek { my $self = shift; return $self->{lastWeek}; }

1;

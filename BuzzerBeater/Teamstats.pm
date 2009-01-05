#
#  $Id: Teamstats.pm,v 1.1 2009-01-05 05:32:53 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Teamstats;

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

    my $twig = new XML::Twig(
        twig_handlers => {
            teamStats  => sub { _parse_averages( $self, @_ ) },
            teamTotals => sub { _parse_totals( $self,   @_ ) },
        }
    );
    $twig->parse($xml);    # safe_parse or croak?

    my $root = $twig->root;
    my $el   = $root->first_child();

    if ($el->gi ne 'teamStats'        # "averages" mode
        && $el->gi ne 'teamTotals'    # "totals" mode
        )
    {
        carp "Unexpected child element processing teamstats xml: " . $el->gi;
    }
    return $self;
}

sub _parse_totals {
    my ( $self, $twig, $totals ) = @_;
    $self->{id}     = $totals->att('teamid');
    $self->{season} = $totals->att('season');

    #  Loop over the players, get their ID and totals
    foreach my $player ( $totals->children('player') ) {

        my $player_id = $player->att('id');
        foreach my $stat ( $player->first_child('totals')->children ) {
            $self->{teamTotals}->{$player_id}->{ $stat->gi } = $stat->text;
        }
    }
}

sub _parse_averages { }

#  API
sub id     { my $self = shift; return $self->{id} }
sub season { my $self = shift; return $self->{season} }

sub teamTotals {
    my $self = shift;

    my %total;
    foreach my $player_data ( values %{ $self->{teamTotals} } ) {
        while ( my ( $stat, $stat_value ) = each %{$player_data} ) {
            $total{$stat} += $stat_value;
        }
    }

    return \%total;
}

1;

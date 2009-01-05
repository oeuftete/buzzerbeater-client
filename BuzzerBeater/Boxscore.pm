#
#  $Id: Boxscore.pm,v 1.3 2009-01-05 05:32:53 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Boxscore;

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
            match    => sub { _parse_match( $self, @_ ) },
            awayTeam => sub { _parse_team( $self,  @_ ) },
            homeTeam => sub { _parse_team( $self,  @_ ) },
        }
    );
    $twig->parse($xml);    # safe_parse or croak?

    my $root = $twig->root;
    my $el   = $root->first_child();

    if ( $el->gi ne 'match' ) {
        carp "Unexpected child element processing boxscore xml: " . $el->gi;
    }
    return $self;
}

sub _parse_match {
    my ( $self, $twig, $match ) = @_;
    $self->{id}          = $match->att('id');
    $self->{type}        = $match->att('type');
    $self->{effortDelta} = $match->first_child_text('effortDelta');
}

sub _parse_team {
    my ( $self, $twig, $team ) = @_;
    my $team_entry = $self->{ $team->gi } = {};

    $team_entry->{id} = $team->att('id');

    # TODO This is inelegant.
    $team_entry->{offStrategy} = $team->first_child_text('offStrategy');
    $team_entry->{defStrategy} = $team->first_child_text('defStrategy');

    my $totals = $team->first_child('boxscore')->first_child('teamTotals');
    foreach my $c ( $totals->children ) {
        $team_entry->{boxscore}->{teamTotals}->{ $c->gi } = $c->text;
    }

    #  Make the teamTotals structures be accessible either by 'homeTeam'
    #  and 'awayTeam' or by the two team IDs.
}

sub id   { my $self = shift; return $self->{id} }
sub away { my $self = shift; return $self->{awayTeam} }
sub home { my $self = shift; return $self->{homeTeam} }

sub teamTotals {
    my $self = shift;
    my $k    = shift;

    croak "homeTeam, awayTeam, or a team id must be specified"
        if ( !defined($k) );

    #  The user can ask for 'homeTeam' or 'awayTeam' or a team ID.
    if ( $k eq 'homeTeam' || $k eq 'awayTeam' ) {
        return $self->{$k}->{boxscore}->{teamTotals};
    }
    elsif ( $k == $self->home->{id} ) {
        return $self->{homeTeam}->{boxscore}->{teamTotals};
    }
    elsif ( $k == $self->away->{id} ) {
        return $self->{awayTeam}->{boxscore}->{teamTotals};
    }
    return;
}

sub effortDelta { my $self = shift; return $self->{effortDelta} }

# TODO: Should this have mappings for the various types?
sub type { my $self = shift; return $self->{type} }

#  Searches for players by id or name.

1;

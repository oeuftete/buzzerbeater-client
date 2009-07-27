#
#  $Id$
#

require 5.10.0;

use strict;
use warnings;

package BuzzerBeater::Boxscore;

use feature 'switch';

use XML::Twig;
use Carp;

use BuzzerBeater::Common::Utils qw(is_match_type);

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
        $self->_setFromXml( $args->{xml} ) if ( exists $args->{xml} );
    }
}

sub _setFromXml {
    my $self = shift;
    my $xml  = shift;

    my $twig = XML::Twig->new(
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

    foreach
        my $top_child (qw(offStrategy defStrategy shortName teamName score))
    {
        $team_entry->{$top_child} = $team->first_child_text($top_child);
        if ( $top_child eq 'score' ) {
            $team_entry->{partials} = [ split /,/,
                $team->first_child($top_child)->att('partials') ];
        }
    }

    my $totals = $team->first_child('boxscore')->first_child('teamTotals');
    foreach my $c ( $totals->children ) {
        $team_entry->{boxscore}->{teamTotals}->{ $c->gi } = $c->text;
    }

    my $ratings = $team->first_child('ratings');
    foreach my $r ( $ratings->children ) {
        $team_entry->{boxscore}->{ratings}->{ $r->gi } = $r->text;
    }

    #  Make the teamTotals structures be accessible either by 'homeTeam' and
    #  'awayTeam' or by the two team IDs.
}

sub id   { my $self = shift; return $self->{id} }
sub away { my $self = shift; return $self->{awayTeam} }
sub home { my $self = shift; return $self->{homeTeam} }

#  Given a team, return the opponent's section
sub opponent {
    my ( $self, $k ) = @_;
    my $o = $self->_home_or_away( $k, 1 );

    if ( defined $o ) {
        return $o;
    }
    return;
}

#  Return $self->away or $self->home based on a few different tests.
#
sub _home_or_away {
    my ( $self, $k, $reverse ) = @_;

    my $home_team;
    given ($k) {
        when (/^home(?:Team)?/)    { $home_team = 1; }
        when (/^away(?:Team)?/)    { $home_team = 0; }
        when ( $self->home->{id} ) { $home_team = 1; }
        when ( $self->away->{id} ) { $home_team = 0; }
    }

    if ( defined $home_team ) {
        return ( $home_team xor $reverse ) ? $self->home : $self->away;
    }
    return;
}

sub teamTotals {
    my ( $self, $k ) = @_;

    my $team = $self->_home_or_away($k)
        or croak "Unable to determine teamTotals for team [$k]";

    return $team->{boxscore}->{teamTotals};
}

sub ratings {
    my ( $self, $k ) = @_;

    my $team = $self->_home_or_away($k)
        or croak "Unable to determine ratings for team [$k]";

    return $team->{boxscore}->{ratings};
}

sub bbstat {
    my ( $self, $k, $args ) = @_;

    my $normalize;
    if ( defined $args ) {
        $normalize = $args->{normalize};
    }

    my $r = $self->ratings($k);

    my $bbstat = 0;
    while ( my ( $type, $val ) = each %$r ) {
        $val =~ s!(\d+)(?:\.([36]))?!
          3*($1 - 1) + ( defined($2) ? $2/3 + 1 : 1 )
          !ex;
        $bbstat += $val;
    }

    my @partials = @{ $self->{$k}->{partials} };
    if ( $normalize && scalar @partials > 4 ) {
        $bbstat *=  48.0 / ( 48.0 + ( 5.0 * ( scalar @partials - 4 ) ) );
        require Math::Round;
        $bbstat = Math::Round::round($bbstat);
    }

    return $bbstat;
}

sub effortDelta { my $self = shift; return $self->{effortDelta} }

# TODO: Should this have mappings for the various types?
sub type { my $self = shift; return $self->{type} }

sub is_competitive {
    my $self = shift;
    return is_match_type( $self->type, 'competitive' );
}

#  Searches for players by id or name.

1;

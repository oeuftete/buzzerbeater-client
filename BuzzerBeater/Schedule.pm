#
#  $Id: Schedule.pm,v 1.4 2009-04-04 14:19:18 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Schedule;

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

    $self->{matches} = [];
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
            schedule => sub { _parse_schedule( $self, @_ ) },
            match    => sub { _parse_match( $self,    @_ ) },
        }
    );
    $twig->parse($xml);

    my $el = $twig->root->first_child();
    if ( $el->gi ne 'schedule' ) {
        carp "Unexpected child element processing schedule xml: " . $el->gi;
    }
    return $self;
}

#  XML parser bits

sub _parse_schedule {

    my ( $self, $twig, $schedule ) = @_;
    $self->{teamid} = $schedule->att('teamid');
    $self->{season} = $schedule->att('season');
}

sub _parse_match {
    my ( $self, $twig, $match ) = @_;

    my $m = {};    # Match data to push on to our object
    while ( my ( $att_name, $att_value ) = each %{ $match->atts } ) {
        $m->{$att_name} = $att_value;
    }
    foreach my $team ( $match->children ) {
        _parse_team( $m, $team );
    }

    push @{ $self->{matches} }, $m;
}

sub _parse_team {
    my ( $m, $team ) = @_;

    my $team_entry = $m->{ $team->gi } = {};
    $team_entry->{id} = $team->att('id');

    # TODO This is inelegant.
    $team_entry->{name}  = $team->first_child_text('teamName');
    $team_entry->{score} = $team->first_child_text('score');
}

#  API

sub teamid { my $self = shift; return $self->{teamid} }
sub season { my $self = shift; return $self->{season} }

sub matches {
    my ( $self, $params ) = @_;

    my @m = @{ $self->{matches} };

    if ( exists( $params->{type} ) ) {
        my @_temp = grep { is_match_type( $_->{type}, $params->{type} ) } @m;
        @m = @_temp;
    }

    #  Filter only completed games if asked.
    if ( exists( $params->{completed} ) && $params->{completed} ) {
        my @_temp = grep { $_->{homeTeam}->{score} ne '' } @m;
        @m = @_temp;
    }

    return \@m;
}

sub competitive_matches {
    my $self = shift;
    my $p = shift || {};
    return $self->matches( { type => 'competitive', %{$p} } );
}

1;

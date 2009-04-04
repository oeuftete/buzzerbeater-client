#
#  $Id: Standings.pm,v 1.3 2009-04-04 13:02:52 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Standings;

use Encode;
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

    my $twig = XML::Twig->new();
    $twig->parse($xml);    # safe_parse or croak?

    my $root = $twig->root;
    my $el   = $root->first_child();

    if ( $el->gi eq 'standings' ) {
        $self->{season}  = $el->att('season');
        $self->{league}  = encode_utf8( $el->first_child_text('league') );
        $self->{country} = encode_utf8( $el->first_child_text('country') );

        my $regular_season = $el->first_child('regularSeason');

        my @conference_names = ( 'Big 8', 'Great 8' );
        my $conference_counter = 0;

        foreach my $conference ( $regular_season->children ) {
            my @team_standings;
            my $place_counter = 1;
            foreach my $team_in_conf ( $conference->children ) {
                my $t;

                $t->{id}         = $team_in_conf->att('id');
                $t->{conference} = $conference_names[$conference_counter];

                $t->{place} = $place_counter;
                $place_counter++;

                foreach my $team_in_conf_data ( $team_in_conf->children ) {
                    $t->{ $team_in_conf_data->gi }
                        = encode_utf8( $team_in_conf_data->text );
                }
                push @team_standings, $t;
            }
            $self->{conference}->{ $conference_names[$conference_counter] }
                = \@team_standings;
            $conference_counter++;
        }
    }

    else {
        carp "Unexpected child element processing standings xml: " . $el->gi;
    }
    return $self;
}

sub team {
    my $self    = shift;
    my $team_id = shift;

    while ( my ( $conf_name, $conf_team ) = each %{ $self->{conference} } ) {
        foreach my $t ( @{$conf_team} ) {
            return $t if ( $t->{id} == $team_id );
        }
    }
    return;
}

sub league     { my $self = shift; return $self->{league} }
sub conference { my $self = shift; return $self->{conference} }
sub country    { my $self = shift; return $self->{country} }

1;

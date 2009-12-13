package BuzzerBeater::Task::LeagueWinners;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

extends 'BuzzerBeater::Task::Base';

has 'country' => ( is => 'rw', isa => 'Int', );
has 'season'  => ( is => 'rw', isa => 'Int', );
has 'level'   => ( is => 'rw', isa => 'Int', default => 1, );

sub run {
    my $self = shift;

    my %w;    # Winner hash

    #  Get the desired league id from that country.
    my $_leagues = $self->client->leagues(
        {   params => {
                countryid => $self->country,
                level     => $self->level,
            }
        }
    );

    #  Loop over the leagues
    while ( my ( $league_id, $league_name ) = each %{ $_leagues->leagues } ) {

        #  Get the standings for the league.
        my $standings = $self->client->standings(
            {   params => {
                    leagueid => $league_id,
                    ( $self->season ? ( season => $self->season ) : () ),
                }
            }
        );

        #  Extract the winner.
        my $winner_id = $standings->league_winner;

        #  TODO: This data structure blows.
        $w{$league_id}->{name}   = $league_name;
        $w{$league_id}->{winner} = undef;

        #  Get the winner's details
        if ( defined $winner_id ) {
            my $winner = $self->client->teaminfo(
                { params => { teamid => $winner_id, } } );
            $w{$league_id}->{winner} = $winner;
        }
    }
    return {
        country => $self->country,
        winners => {%w},
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

BuzzerBeater::Task::LeagueWinners - Get a list of league winners.

=head1 SYNOPSIS
        
    use BuzzerBeater::Task::LeagueWinners;

    my $bblw = BuzzerBeater::Task::LeagueWinners->new(
        client => $bb,
        );
    my $output = $bblw->run;

    # ... then feed it to a template or whatever

=head1 DESCRIPTION


=head2 METHODS

=over

=item new

=item run

=back

=head1 AUTHOR

Ken Crowell <ken@oeuftete.com>

=head1 LICENCE AND COPYRIGHT

Copyright 2009, Ken Crowell (ken@oeuftete.com)

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See perldoc perlartistic.

=cut

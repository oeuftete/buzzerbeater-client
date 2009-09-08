package BuzzerBeater::Task::Prospectus;
use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use BuzzerBeater::Client;
use List::Util qw(sum);
use Carp qw(croak);

subtype 'BB_Client' => as 'Object' =>
    where { $_->isa('BuzzerBeater::Client') };

coerce 'BB_Client' => from 'HashRef' => via {
    my $bb = BuzzerBeater::Client->new;
    $bb->login(
        {   params => {
                login => $_->{login},
                code  => $_->{code},
            }
        }
    );
    return $bb;
};

has 'client' => (
    is     => 'ro',
    isa    => 'BB_Client',
    coerce => 1,
);

has 'id' => (
    is  => 'rw',
    isa => 'Int',
);

sub run {
    my $self = shift;

    my $output = {};

    my $teaminfo
        = $self->client->teaminfo( { params => { teamid => $self->id } } )
        || croak "Failed to retrieve teaminfo for ["
        . $self->id . "]: "
        . $self->client->lastError;
    my $roster
        = $self->client->roster( { params => { teamid => $self->id } } )
        || croak "Failed to retrieve roster for ["
        . $self->id . "]: "
        . $self->client->lastError;
    my $standings
        = $self->client->standings(
        { params => { leagueid => $teaminfo->leagueid, } } )
        ->team( $self->id )
        || croak "Failed to retrieve standings for ["
        . $self->id . "]: "
        . $self->client->lastError;

    #  Compute a bunch of crap.
    my %computed_data;

    {
        my @roster_players = @{ $roster->players };
        $computed_data{age}
            = sum( map { $_->basic('age') } @roster_players ) /
            scalar @roster_players;
        $computed_data{salary}
            = sum( map { $_->basic('salary') } @roster_players ) / 1000.0;
        $computed_data{salary_average}
            = $computed_data{salary} / scalar @roster_players;
    }
    $computed_data{pyth} = pyth_record($standings);
    $computed_data{point_differential}
        = ( $standings->{pf} > $standings->{pa} ? '+' : '' )
        . ( $standings->{pf} - $standings->{pa} );

    $self->compute_schedule_data( \%computed_data );

    #  Data for the template
    $output->{teaminfo}       = $teaminfo;
    $output->{team_standings} = $standings;
    $output->{roster}         = $roster;
    $output->{computed}       = \%computed_data;

    #  Subs for the template
    require Lingua::EN::Numbers::Ordinate;
    $output->{ordinate} = \&Lingua::EN::Numbers::Ordinate::ordinate;

    return $output;
}

sub pyth_record {
    my $s        = shift;
    my $exponent = 10;

    my $g = $s->{wins} + $s->{losses};

    my $pct;
    eval {
        $pct
            = $s->{pf}**$exponent
            / ( $s->{pf}**$exponent + $s->{pa}**$exponent )
    };
    $pct = 0 if $@;

    return [ $g * $pct, $g * ( 1.0 - $pct ) ];
}

sub compute_schedule_data {
    my ( $self, $computed ) = @_;

    my $bb = $self->client;

    #  Gather the information from the schedule.
    my $schedule = $bb->schedule( { params => { teamid => $self->id, } } )
        || croak "Failed to retrieve standings for ["
        . $self->id . "]: "
        . $bb->lastError;

    my $team_stats;
    for my $i ( -2 .. 2 ) {
        $computed->{effortDelta}->{$i} = 0;
    }

    my $matches = $schedule->matches( { completed => 1 } );

    $computed->{max_bbstat} = [ undef, 0 ];
    my %opponents;
    my $n_competitive_matches = 0;

    foreach my $match ( @{$matches} ) {
        my $box = $bb->boxscore( { params => { matchid => $match->{id} } } );

        #  TODO: What do the main methods do when they crap out?
        if ( ref($box) ne 'BuzzerBeater::Boxscore' ) {
            warn "Problem obtaining boxscore for match ["
                . $match->{id}
                . "].  Skipping";
            next;
        }

        #  Generate a bbstat value, and track the max value with the match id.
        #  Keep the latest one.
        my $bbstat = $box->bbstat( $self->id, { normalize => 1, } );
        if ( $bbstat >= $computed->{max_bbstat}->[1] ) {
            $computed->{max_bbstat} = [ $box, $bbstat ];
        }

        #  Only tally stats for competitive matches.
        next unless $box->is_competitive;

        $n_competitive_matches++;

        my $effortDelta = $box->effortDelta;

        my $team_section = $box->home;
        if ( $team_section->{id} != $self->id ) {
            $team_section = $box->away;
            $effortDelta *= -1;    # flip sign when away team is the target
        }
        $computed->{effortDelta}->{$effortDelta}++;

        #  Find their offensive and defensive tactic.
        $computed->{offStrategy}->{ $team_section->{offStrategy} }++;
        $computed->{defStrategy}->{ $team_section->{defStrategy} }++;

        #  Tally up some team totals for later per-game averaging
        my $opponent_id
            = ( $self->id == $box->home->{id} )
            ? $box->away->{id}
            : $box->home->{id};
        $opponents{$opponent_id} = 1;    # Store in case we need it

        while ( my ( $stat, $stat_value )
            = each %{ $box->teamTotals( $self->id ) } )
        {
            $computed->{team_totals}->{$stat} += $stat_value;
        }

        while ( my ( $stat, $stat_value )
            = each %{ $box->teamTotals($opponent_id) } )
        {
            $computed->{opponent_totals}->{$stat} += $stat_value;
        }
    }

    $computed->{offensive_tactics}
        = join ', ',
        map { $_->{name} . ' ' . $_->{uses} }
        sorted_strategies( $computed->{offStrategy} );

    $computed->{defensive_tactics}
        = join ', ',
        map { $_->{name} . ' ' . $_->{uses} }
        sorted_strategies( $computed->{defStrategy} );

    $computed->{total_matches} = $n_competitive_matches;
}

sub sorted_strategies {
    my $h = shift;

    #  Map the strategy names returned by the API to something useful.
    my %name_map = (

        # Offense
        Base       => 'Base Offense',
        Push       => 'Push the Ball',
        LookInside => 'Look Inside',
        LowPost    => 'Low Post',
        RunAndGun  => 'Run and Gun',

        # Defense
        ManToMan  => 'Man to Man',
        '23Zone'  => '2-3 Zone',
        '32Zone'  => '3-2 Zone',
        '131Zone' => '1-3-1 Zone',
        Press     => 'Full Court Press',
    );

    return my @s = sort { $b->{uses} <=> $a->{uses} }
        map {
        {   name => ( exists( $name_map{$_} ) ? $name_map{$_} : $_ ),
            uses => $h->{$_}
        }
        } keys %{$h};
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

BuzzerBeater::Task::Prospectus - Provide the core application for my BB
prospectus tool.

=head1 SYNOPSIS
        
    use BuzzerBeater::Task::Prospectus;

    my $bbp = BuzzerBeater::Task::Prospectus->new(
        client => $bb,
        id => $id,
        );
    my $output = $bbp->run;

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

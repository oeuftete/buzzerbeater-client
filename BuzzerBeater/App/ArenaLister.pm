#!/usr/bin/env perl
#
#  $Id$
#

use strict;
use warnings;

package BuzzerBeater::App::ArenaLister;

use Getopt::Long;
use Pod::Usage;

use Local::BB;

run() unless caller();

sub run {
    my %opts = ( 'max-level' => 3, );
    process_options( \%opts );

    my $bb = Local::BB->new;

    #  Get the leagueid for 1..max-level
    my @leagues = league_ids( $bb, $opts{'max-level'}, $opts{'country'} );

    #  For each leagueid, get each team from the standings
    my @teams = team_ids( $bb, \@leagues );

    #  For each team, get their BB::Arena.  Store in hash of
    #    ( teamid => BB::Arena )
    my %arenas = arena_details( $bb, \@teams );

    #  Return list sorted by descending $arena->size.
    for my $a ( sort { $b->size <=> $a->size } values %arenas ) {
        printf "%-40s: %6d\n", $a->name, $a->size;
    }
}

sub arena_details {
    my ( $bb, $t_id ) = @_;

    my %a;
    for my $t (@$t_id) {
        $a{$t} = $bb->arena( { params => { teamid => $t } } );
    }
    return %a;
}

sub team_ids {
    my ( $bb, $l_id ) = @_;

    my @t;
    for my $l (@$l_id) {
        my $s = $bb->standings( { params => { leagueid => $l } } );
        for my $team_standings ( values %{ $s->conference } ) {
            push @t, map { $_->{id} } @$team_standings;
        }
    }
    return @t;
}

sub league_ids {
    my ( $bb, $ml, $country ) = @_;

    my @l;
    for my $level ( 1 .. $ml ) {
        my $leagues = $bb->leagues(
            {   params => {
                    level     => $level,
                    countryid => $country,
                }
            }
        );
        push @l, keys %{ $leagues->leagues };
    }
    return @l;
}

sub process_options {

    my $o = shift;

    GetOptions(
        'help!'       => \$o->{help},
        'man!'        => \$o->{man},
        'country=s'   => \$o->{country},
        'max-level=i' => \$o->{'max-level'},
    ) or pod2usage( -verbose => 1 ) && exit;

    pod2usage( -verbose => 1 ) && exit if defined $o->{help};
    pod2usage( -verbose => 2 ) && exit if defined $o->{man};

    pod2usage( -verbose => 1 ) && exit if !defined $o->{country};
    return;
}

########################################################################

=head1 NAME

ArenaLister.pm - List the largest arenas in a given country.

=head1 VERSION

$Id$

=head1 USAGE

    # perl ArenaLister.pm --country Canada
    # perl ArenaLister.pm --country 4


=head1 OPTIONS

=over 8

=item B<--country>

The country name (TODO) or ID to generate data for.  Required.

=item B<--max-level>

The maximum level depth of the league system to search.
Optional (Default: 3).

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=back


=head1 AUTHOR

Ken Crowell <oeuftete@gmail.com>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 Ken Crowell <oeuftete@gmail.com>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See perldoc perlartistic.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1;

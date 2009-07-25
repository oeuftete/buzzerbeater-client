#
#  $Id$
#
use utf8;
use strict;
use warnings;

use Test::More;
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Boxscore',
        'BuzzerBeater::Boxscore pod is covered' );
}

my $bb = BuzzerBeater::Client->new;

{
    my $xml_input = read_file('t/files/boxscore.xml');
    isa_ok( my $box = $bb->boxscore( { xml => $xml_input } ),
        'BuzzerBeater::Boxscore' );

    is( $box->id,                  6351345,     'Match id' );
    is( $box->type,                'league.rs', 'Match type' );
    is( $box->effortDelta,         0,           'Effort delta' );
    is( $box->away->{id},          24867,       'Away team id' );
    is( $box->home->{id},          24818,       'Home team id' );
    is( $box->home->{offStrategy}, 'Push',      'Home offStrategy' );
    is( $box->home->{teamName},
        'Cape Sable Sculpins',
        'Check home team name'
    );
    is( $box->home->{shortName}, 'CSI', 'Check home short name' );

    ok( $box->is_competitive, 'This is a competitive match' );

    #  Check the _home_or_away logic
    is( $box->_home_or_away('home')->{offStrategy},
        'Push', '_home_or_away: home' );
    is( $box->_home_or_away('homeTeam')->{offStrategy},
        'Push', '_home_or_away: homeTeam' );
    is( $box->_home_or_away(24818)->{offStrategy},
        'Push', '_home_or_away: by ID' );
    is( $box->_home_or_away('foo'),
        undef, '_home_or_away: garbage returns undef' );

    is( $box->opponent(24818)->{id}, 24867, 'Opponent by id' );
    is( $box->opponent('home')->{id}, 24867,
        'Opponent by not the home team' );

    is( $box->teamTotals('homeTeam')->{fga}, 104, 'Home team total' );
    is( $box->teamTotals(24818)->{fga},      104, 'Team total by ID' );
    is( $box->teamTotals('awayTeam')->{oreb}, 16,
        'Check an away team total' );

    is( $box->ratings('homeTeam')->{offensiveFlow},
        '5.6', 'Check ratings read' );

    #  This actually should be 106 on the regular displayed version, but
    #  the offensive flow is rounded differently in the API version.
    is( $box->bbstat('homeTeam'), 107, 'BBstat calculation' );
}

{
    my $xml_input = read_file('t/files/boxscore_utf8_opponent.xml');
    isa_ok( my $box = $bb->boxscore( { xml => $xml_input } ),
        'BuzzerBeater::Boxscore' );
    is( $box->opponent(24818)->{teamName},
        'BC Törööö',
        'Opponent teamname with utf-8'
    );
}
done_testing;

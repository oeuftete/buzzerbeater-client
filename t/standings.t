#
#  $Id$
#
use utf8;
use strict;
use warnings;

use Test::More;
use File::Slurp;
use Encode;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Standings',
        'BuzzerBeater::Standings pod is covered' );
}

my $bb = BuzzerBeater::Client->new();

{
    my $xml_input = read_file('t/files/standings.xml');
    isa_ok( my $standings = $bb->standings( { xml => $xml_input } ),
        'BuzzerBeater::Standings' );
    is( $standings->league,  'Naismith', 'Check league name' );
    is( $standings->country, 'Canada',   'Check country name' );

    {
        isa_ok( my $conf = $standings->conference->{'Big 8'}, 'ARRAY' );
        is( $conf->[0]->{id}, 24809, 'ID of first place team' );
    }

    {
        isa_ok( my $team_standings = $standings->team(24818), 'HASH' );
        is( $team_standings->{id}, 24818, 'Same team id back we supplied' );
        is( $team_standings->{pf}, 1077,  'Points for correct' );
        is( $team_standings->{conference},
            'Great 8', 'Conference name correct' );
    }

    is( $standings->team(1), undef,
        'team returns undef if team not in standings' );
    is( $standings->league_winner, undef,
        'No playoff winner during regular season' );
}

{
    my $xml_input = read_file('t/files/standings_completed_playoffs.xml');
    isa_ok( my $standings = $bb->standings( { xml => $xml_input } ),
        'BuzzerBeater::Standings' );
    is( $standings->league_winner, 58425, 'Correctly determined winner' );
}

{
    my $xml_input = read_file('t/files/standings_finals_in_progress.xml');
    isa_ok( my $standings = $bb->standings( { xml => $xml_input } ),
        'BuzzerBeater::Standings' );

    is( $standings->league_winner, undef,
        'No playoff winner ongoing finals' );
}

{
    my $xml_input = read_file('t/files/standings_utf8_team_names.xml');
    isa_ok( my $standings = $bb->standings( { xml => $xml_input } ),
        'BuzzerBeater::Standings' );

    isa_ok( my $team_standings = $standings->team(25331), 'HASH' );
    is( $team_standings->{teamName}, '吸血鬼', 'Chinese team name' );
}

done_testing;

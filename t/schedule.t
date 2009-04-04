#
#  $Id: schedule.t,v 1.2 2009-04-04 14:19:18 ken Exp $
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;

BEGIN { use_ok('BuzzerBeater::Client'); }

my $user         = 'oeuftete';
my $access_code  = 'alphonse';
my $agent        = 'oeuftete-test-app/0.1';
my $login_params = { params => { login => $user, code => $access_code } };

my $bb = BuzzerBeater::Client->new;

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set' );

my $schedule;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $schedule = $bb->schedule, 'BuzzerBeater::Schedule' );
}

my $xml_input = read_file('t/files/schedule.xml');
isa_ok( $schedule = $bb->schedule( { xml => $xml_input } ),
    'BuzzerBeater::Schedule' );

is( $schedule->teamid(), 24818, 'Check team id' );
is( $schedule->season(), 6,     'Check season' );

is( scalar @{ $schedule->matches() },
    40, 'Correct number of matches returned' );

is( scalar @{ $schedule->matches( { type => 'WRONG' } ) },
    40, 'All matches returned with bad filter' );

is( scalar @{ $schedule->matches( { completed => 1 } ) },
    31, 'Correct number of completed matches returned' );

is( scalar @{ $schedule->matches( { type => 'friendly' } ) },
    1, 'Correct number of scrimmages returned' );

is( scalar @{ $schedule->matches( { type => 'bbb' } ) },
    0, 'Correct number of B3 matches returned' );

my @cm = @{ $schedule->matches( { type => 'competitive' } ) };
is( scalar @cm,   31,      'Correct number of competitive matches returned' );
is( $cm[1]->{id}, 6351251, 'Match ID for arbitrary competitive match' );

@cm = @{ $schedule->competitive_matches() };
is( scalar @cm, 31,
    'Correct number of competitive matches returned (shortcut)' );
is( $cm[1]->{id}, 6351251,
    'Match ID for arbitrary competitive match (shortcut)' );

is( scalar @{ $schedule->competitive_matches( { completed => 1 } ) },
    22, 'Correct number of completed competitive matches returned' );


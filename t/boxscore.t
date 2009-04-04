#
#  $Id: boxscore.t,v 1.5 2009-04-04 01:15:29 ken Exp $
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

my $box;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $box = $bb->boxscore, 'BuzzerBeater::Boxscore' );
}

my $xml_input = read_file('t/files/boxscore.xml');
isa_ok( $box = $bb->boxscore( { xml => $xml_input } ),
    'BuzzerBeater::Boxscore' );

is( $box->id,                  6351345,     'Check match id' );
is( $box->type,                'league.rs', 'Check match type' );
is( $box->effortDelta,         0,           'Check effort delta' );
is( $box->away->{id},          24867,       'Check away team id' );
is( $box->home->{id},          24818,       'Check home team id' );
is( $box->home->{offStrategy}, 'Push',      'Check home offStrategy' );

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

is( $box->teamTotals('homeTeam')->{fga},  104, 'Check a home team total' );
is( $box->teamTotals(24818)->{fga},       104, 'Check a team total by ID' );
is( $box->teamTotals('awayTeam')->{oreb}, 16,  'Check an away team total' );

is( $box->ratings('homeTeam')->{offensiveFlow}, '5.6', 'Check ratings read' );

#  This actually should be 106 on the regular displayed version, but
#  the offensive flow is rounded differently in the API version.
is( $box->bbstat('homeTeam'), 107, 'Check bbstat calculation' );

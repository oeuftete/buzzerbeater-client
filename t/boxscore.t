#
#  $Id: boxscore.t,v 1.2 2009-01-05 05:32:54 ken Exp $
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

my $bb = new BuzzerBeater::Client;

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set' );

my $boxscore;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $boxscore = $bb->boxscore, 'BuzzerBeater::Boxscore' );
}

my $xml_input = read_file('t/files/boxscore.xml');
isa_ok( $boxscore = $bb->boxscore( { xml => $xml_input } ),
    'BuzzerBeater::Boxscore' );

is( $boxscore->id,                  6351345,     'Check match id' );
is( $boxscore->type,                'league.rs', 'Check match type' );
is( $boxscore->effortDelta,         0,           'Check effort delta' );
is( $boxscore->away->{id},          24867,       'Check away team id' );
is( $boxscore->home->{id},          24818,       'Check home team id' );
is( $boxscore->home->{offStrategy}, 'Push',      'Check home offStrategy' );

is( $boxscore->teamTotals('homeTeam')->{fga}, 104,
    'Check a home team total' );
is( $boxscore->teamTotals(24818)->{fga}, 104, 'Check a team total by ID' );
is( $boxscore->teamTotals('awayTeam')->{oreb},
    16, 'Check an away team total' );

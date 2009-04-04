#
#  $Id: teamstats.t,v 1.2 2009-04-04 14:19:18 ken Exp $
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

my $bb = BuzzerBeater::Client->new();

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set' );

my $teamstats;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $teamstats = $bb->teamstats, 'BuzzerBeater::Teamstats' );
}

my $xml_input = read_file('t/files/teamstats_totals.xml');
isa_ok( $teamstats = $bb->teamstats( { xml => $xml_input } ),
    'BuzzerBeater::Teamstats' );

is( $teamstats->id,     24818, 'Check team id' );
is( $teamstats->season, 7,     'Check season' );

is( $teamstats->teamTotals->{ast}, 232, 'Team stat total' );

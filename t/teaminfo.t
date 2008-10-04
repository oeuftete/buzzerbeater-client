#
#  $Id: teaminfo.t,v 1.1 2008-10-04 21:04:46 ken Exp $
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

ok( $bb->login($login_params), 'Login successful' );

my $teaminfo;
isa_ok( $teaminfo = $bb->teaminfo, 'BuzzerBeater::Teaminfo' );

my $xml_input = read_file('t/files/teaminfo.xml');
isa_ok( $teaminfo = $bb->teaminfo( { xml => $xml_input } ),
    'BuzzerBeater::Teaminfo' );

is( $teaminfo->league(),   'Naismith', 'Check league name' );
is( $teaminfo->leagueid(), 128,        'Check league ID' );
is( $teaminfo->country(),  'Canada',   'Check country name' );

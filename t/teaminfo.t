#
#  $Id: teaminfo.t,v 1.4 2009-01-05 05:32:54 ken Exp $
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

my $teaminfo;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $teaminfo = $bb->teaminfo, 'BuzzerBeater::Teaminfo' );
}

my $xml_input = read_file('t/files/teaminfo.xml');
isa_ok( $teaminfo = $bb->teaminfo( { xml => $xml_input } ),
    'BuzzerBeater::Teaminfo' );

is( $teaminfo->league,    'Naismith', 'Check league name' );
is( $teaminfo->leagueid,  128,        'Check league ID' );
is( $teaminfo->country,   'Canada',   'Check country name' );
is( $teaminfo->owner,     'oeuftete', 'Check owner' );
is( $teaminfo->shortName, 'CSI',      'Check short name' );

$xml_input = read_file('t/files/teaminfo_bot.xml');
isa_ok( $teaminfo = $bb->teaminfo( { xml => $xml_input } ),
    'BuzzerBeater::Teaminfo' );

is( $teaminfo->owner(), undef, 'Check empty owner on bot' );
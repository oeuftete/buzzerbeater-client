#
#  $Id: economy.t,v 1.1 2009-04-04 12:43:38 ken Exp $
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

my $economy;
SKIP: {
    skip 'Site problems', 2 if $ENV{BB_SITE_PROBLEMS};
    ok( $bb->login($login_params), 'Login successful' );

    isa_ok( $economy = $bb->economy, 'BuzzerBeater::Economy' );
}

my $xml_input = read_file('t/files/economy.xml');
isa_ok( $economy = $bb->economy( { xml => $xml_input } ),
    'BuzzerBeater::Economy' );

is( $economy->balance, 2903213, 'check current balance' );
cmp_ok( $economy->playerSalaries, '==', 211542,
    'check current player salaries' );
is( $economy->lastWeek->{matchRevenue}->{'8440607'},
    334017, 'Check a match\'s revenue from last week' );
is( $economy->thisWeek->{matchRevenue}->{'10335700'},
    90000, 'Check a match\'s revenue from this week' );

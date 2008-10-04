#
use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN { use_ok('BuzzerBeater::Client'); }

my $user         = 'oeuftete';
my $access_code  = 'alphonse';
my $agent        = 'oeuftete-test-app/0.1';
my $login_params = { params => { login => $user, code => $access_code } };

my $bb = new BuzzerBeater::Client;
isa_ok( $bb, 'BuzzerBeater::Client' );

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set' );

ok( $bb->login($login_params), 'Login successful' );
ok( $bb->logout,               'Logout successful' );
ok( !$bb->logout,              'Logout fails when not logged in' );

$login_params
    = { params => { login => $user, code => $access_code . 'xxx' } };
ok( !$bb->login($login_params), 'Bad login fails' );

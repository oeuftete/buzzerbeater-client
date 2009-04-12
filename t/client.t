#
use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN { use_ok('BuzzerBeater::Client'); }

my $user         = 'oeuftete';
my $access_code  = 'alphonse';
my $agent        = 'oeuftete-test-app/0.1';
my $login_params = { params => { login => $user, code => $access_code } };

my $bb = BuzzerBeater::Client->new;
isa_ok( $bb, 'BuzzerBeater::Client' );

{
    my $test_agent = "test-$agent";
    my $new_bb = BuzzerBeater::Client->new( agent => $test_agent );
    is( $new_bb->agent, $test_agent, 'Agent set through new' );
}

$bb->agent($agent);
is( $bb->agent, $agent, 'Agent set and read' );

$bb->debug(1);
is( $bb->debug, 1, 'Debug level set and read' );
$bb->debug(0);

ok( $bb->login($login_params), 'Login successful' );
ok( $bb->logout,               'Logout successful' );
ok( !$bb->logout,              'Logout fails when not logged in' );

$login_params
    = { params => { login => $user, code => $access_code . 'xxx' } };
ok( !$bb->login($login_params), 'Bad login fails' );

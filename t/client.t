#
use strict;
use warnings;

use Test::More;
use Test::Output;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Client',
        'BuzzerBeater::Client pod is covered' );
}

my $user         = 'oeuftete';
my $access_code  = 'alphonse';
my $agent        = 'oeuftete-test-app/0.1';
my $login_params = { params => { login => $user, code => $access_code } };

{
    my $bb = BuzzerBeater::Client->new;
    isa_ok( $bb, 'BuzzerBeater::Client' );

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
}

{
    my $test_agent = "test-$agent";
    my $bb = BuzzerBeater::Client->new( agent => $test_agent );
    is( $bb->agent, $test_agent, 'Agent set through new' );
}

#  Make sure we clean up properly.
{
    my $bb = BuzzerBeater::Client->new;
    $bb->debug(1);
    stderr_like(
        sub { undef $bb },
        qr!Sending.*BBAPI/logout\.aspx!,
        'Logout attempted on destruction.'
    );
}

done_testing;

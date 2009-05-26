#
#  $Id$
#
use strict;
use warnings;

use Test::More qw(no_plan);
use File::Slurp;
use Encode;

BEGIN { use_ok('BuzzerBeater::Client'); }

TODO: {
    eval "use Test::Pod::Coverage";
    todo_skip "Test::Pod::Coverage required for testing pod coverage", 1
        if $@;

    local $TODO = "Pod not written yet!";

    pod_coverage_ok( 'BuzzerBeater::Teaminfo',
        'BuzzerBeater::Teaminfo pod is covered' );
}

my $bb = BuzzerBeater::Client->new;

#  User team
{
    my $xml_input = read_file('t/files/teaminfo.xml');
    isa_ok( my $teaminfo = $bb->teaminfo( { xml => $xml_input } ),
        'BuzzerBeater::Teaminfo' );

    is( $teaminfo->league,    'Naismith',            'League name' );
    is( $teaminfo->leagueid,  128,                   'League ID' );
    is( $teaminfo->country,   'Canada',              'Country name' );
    is( $teaminfo->owner,     'oeuftete',            'Owner' );
    is( $teaminfo->shortName, 'CSI',                 'Short name' );
    is( $teaminfo->teamName,  'Cape Sable Sculpins', 'Team name' );
}

#  Bot team
{
    my $xml_input = read_file('t/files/teaminfo_bot.xml');
    my $teaminfo = $bb->teaminfo( { xml => $xml_input } );

    is( $teaminfo->owner, undef, 'Check empty owner on bot' );
}

#  Ampersands in the name
{
    my $xml_input = read_file('t/files/teaminfo_ampersands.xml');
    my $teaminfo = $bb->teaminfo( { xml => $xml_input } );

    is( $teaminfo->shortName, 'W&C',            'Short name with &' );
    is( $teaminfo->teamName,  'W&C Bball Club', 'Team name with &' );
}

#  Single quotes are mis-entitified and need to be worked around.
#  See http://www.buzzerbeater.com/BBWeb/Forum/read.aspx?thread=87726&m=1
{
    my $xml_input = read_file('t/files/teaminfo_misentitified_aquo.xml');
    my $teaminfo = $bb->teaminfo( { xml => $xml_input } );

    TODO: {
        local $TODO = 'Work around misencoded &aquo;';
        is( $teaminfo->teamName, 'Bobo\'s', 'Team name with \'' );
    }
}

#  The "Turkey Test"
{
    my $xml_input = read_file('t/files/teaminfo_unicode_name_turkish.xml');
    my $teaminfo = $bb->teaminfo( { xml => $xml_input } );

    is( $teaminfo->teamName,
        encode_utf8("k\x{0131}rk\x{0131}srak eagles"),
        'Turkish team name'
    );
}

#  Chinese
{
    my $xml_input = read_file('t/files/teaminfo_unicode_name.xml');
    my $teaminfo = $bb->teaminfo( { xml => $xml_input } );

    is( $teaminfo->teamName,
        encode_utf8("\x{5438}\x{8840}\x{9b3c}"),
        'Chinese team name'
    );
}

#  Chinese owner
{
    my $xml_input = read_file('t/files/teaminfo_unicode_owner.xml');
    my $teaminfo = $bb->teaminfo( { xml => $xml_input } );

    is( $teaminfo->owner,
        encode_utf8("\x{7c98}\x{8c46}\x{5305}"),
        'Chinese team owner'
    );
}

#  Weird unicode owner
{
    my $xml_input = read_file('t/files/teaminfo_unicode_owner_2.xml');
    my $teaminfo = $bb->teaminfo( { xml => $xml_input } );

    is( $teaminfo->owner,
        encode_utf8("mosva\x{261c}"),
        'Weird unicode team owner'
    );
}

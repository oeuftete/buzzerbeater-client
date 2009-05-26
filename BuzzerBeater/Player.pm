#
#  $Id$
#

use strict;
use warnings;

#  Players are instantiated through the XML interface, but also via rosters.
#  Players retrieved via XML directly (i.e. player.aspx) have a retrieved and
#  owner thingy too.

package BuzzerBeater::Player;

use Carp;

use Encode;
use XML::Twig;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    # Set to something since it's optional in the XML
    $self->{injury} = 0;
    $self->{skills} = {};

    $self->_initialize(@_);
    return $self;
}

#
#  TODO:  Moose-ify this?
#  TODO:  The setters may completely go away if the BB::Player construction
#  from BB::Roster is folded into this _setFromXml.
#
#  Get/set player id
sub id {
    my $self = shift;
    if (@_) {
        $self->{id} = shift;
        return $self;
    }
    return $self->{id};
}

#  Get/set player owner
sub owner {
    my $self = shift;
    if (@_) {
        $self->{owner} = shift;
        return $self;
    }
    return $self->{owner};
}

# Get/set the basic (i.e. att-less) top-level fields.
#
# To get, provide the key.
# To set, provide the key and value.
sub basic {
    my $self = shift;

    if ( @_ == 2 ) {
        my ( $basicGi, $basicText ) = @_;
        $self->{$basicGi} = encode_utf8($basicText);
    }
    elsif ( @_ == 1 ) {
        return $self->{ $_[0] };
    }
    return $self;
}

# Get/set the nationality hash.
#
# $obj->{nationality} =
#   { value => 'Country name',
#     id => countryId }
#
# To get, call with no arguments
# To set, call with the name and id
sub nationality {
    my $self = shift;

    if (@_) {
        ( $self->{nationality}->{name}, $self->{nationality}->{id} )
            = map { encode_utf8($_) } @_;
        return $self;
    }
    return $self->{nationality};
}

# Get/set skills.
#
# $obj->{skills} =
#   { gameShape => 8,
#     potential => 7,
#     ...
#   }
#
# To get the whole hash, call with no arguments
# To set a single skill, call with the name and value
sub skills {
    my $self = shift;

    if (@_) {
        my ( $name, $value ) = @_;
        $self->{skills}->{$name} = $value;
        return $self;
    }
    return $self->{skills};
}

# Return the full name.  No set.
#
# TODO: A two argument (or one pair) set?
sub name {
    my $self = shift;
    return $self->basic('firstName') . ' ' . $self->basic('lastName');
}

#  This method uses the formula described by BuzzerBeater user Josef Ka,
#  described at
#  L<http://www.buzzerbeater.com/BBWeb/Forum/read.aspx?thread=46657&m=42>, to
#  predict the salary for a given player ID.  Here's an excerpt from that post:
#  
#      From: Josef Ka
#      To: Rambo VT
#      46657.42 in reply to 46657.41
#      Date: 11/4/2008 4:21:08 AM
#      Salary formulas for BuzzerBeater
#      
#      [...]
#      
#      --
#      UPDATE 2008/11/29
#      
#      Here are two new versions, one for the people who don't believe in ST, FT
#      and EX for salary, and one for those who do. The prediction difference is
#      minimal.
#      
#         JS    JR    OD    HA    DR    PA    IS    ID    RB    BL      const
#      C_ 1,000 1,000 1,008 1,004 1,000 1,000 1,130 1,137 1,129 1,063   298
#      PF 1,071 1,005 1,006 1,001 1,007 1,006 1,110 1,117 1,110 1,065   295
#      SF 1,179 1,077 1,066 1,000 1,000 1,000 1,000 1,059 1,090 1,002   322
#      SG 1,116 1,149 1,115 1,006 1,013 1,000 1,000 1,004 1,061 1,005   307
#      PG 1,028 1,041 1,078 1,079 1,039 1,152 1,002 1,000 1,037 1,000   310
#  
#  [KC: This may be implemented as an option at a later date.]
#  
#      ___JS___JR___OD___HA___ DR___PA___IS___ID___RB___BL___ST___FT___EX___const
#      C_ 1,000 1,000 1,008 1,002 1,000 1,000 1,129 1,138 1,130 1,064 1,000 1,003 1,000 293
#      PF 1,071 1,000 1,008 1,000 1,000 1,007 1,114 1,116 1,110 1,067 1,008 1,000 1,008 277
#      SF 1,177 1,080 1,068 1,000 1,000 1,000 1,000 1,058 1,088 1,002 1,001 1,000 1,006 315
#      SG 1,115 1,142 1,120 1,005 1,016 1,001 1,000 1,001 1,064 1,001 1,008 1,005 1,003 295
#      PG 1,027 1,044 1,078 1,080 1,040 1,152 1,002 1,000 1,035 1,000 1,004 1,000 1,000 300

sub josef_ka {

    my $self = shift;
    
    my $player_skills = $self->skills;
    if (! exists $player_skills->{jumpShot} ) {
        carp "Salary estimation not possible without skills";
        return;
    }

    my %weights = (
        PG => {
            skills => {
                jumpShot   => 1.028,
                range      => 1.041,
                outsideDef => 1.078,
                handling   => 1.079,
                driving    => 1.039,
                passing    => 1.152,
                insideShot => 1.002,
                insideDef  => 1.000,
                rebound    => 1.037,
                block      => 1.000,
            },
            multiplier => 310.0,
        },
        SG => {
            skills => {
                jumpShot   => 1.116,
                range      => 1.149,
                outsideDef => 1.115,
                handling   => 1.006,
                driving    => 1.013,
                passing    => 1.000,
                insideShot => 1.000,
                insideDef  => 1.004,
                rebound    => 1.061,
                block      => 1.005,
            },
            multiplier => 307.0,
        },
        SF => {
            skills => {
                jumpShot   => 1.179,
                range      => 1.077,
                outsideDef => 1.066,
                handling   => 1.000,
                driving    => 1.000,
                passing    => 1.000,
                insideShot => 1.000,
                insideDef  => 1.059,
                rebound    => 1.090,
                block      => 1.002,
            },
            multiplier => 322.0,
        },
        PF => {
            skills => {
                jumpShot   => 1.071,
                range      => 1.005,
                outsideDef => 1.006,
                handling   => 1.001,
                driving    => 1.007,
                passing    => 1.006,
                insideShot => 1.110,
                insideDef  => 1.117,
                rebound    => 1.110,
                block      => 1.065,
            },
            multiplier => 295.0,
        },
        C => {
            skills => {
                jumpShot   => 1.000,
                range      => 1.000,
                outsideDef => 1.008,
                handling   => 1.004,
                driving    => 1.000,
                passing    => 1.000,
                insideShot => 1.130,
                insideDef  => 1.137,
                rebound    => 1.129,
                block      => 1.063,
            },
            multiplier => 298.0,
        },
    );

    my $t             = $weights{ $self->basic('bestPosition') };

    my $salary = $t->{multiplier};

    while ( my ( $skill, $coef ) = each %{ $t->{skills} } ) {
        $salary *= $coef**$player_skills->{$skill};
    }
    return $salary;
}

#  END API
########################################################################

#  Private

sub _initialize {
    my $self = shift;

    if (@_) {
        my $args = shift;
        $self->_setFromXml( $args->{xml} ) if ( exists $args->{xml} );
    }
}

sub _setFromXml {
    my $self = shift;
    my $xml  = shift;

    my $twig = XML::Twig->new();
    $twig->parse($xml);    # safe_parse or croak?

    my $root = $twig->root;
    my $el   = $root->first_child();

    if ( $el->gi eq 'player' ) {

        #  TODO: Copied from Roster!
        $self->id( $el->att('id') );
        $self->owner( $el->att('owner') );

        foreach my $playerEl ( $el->children ) {
            if ( $playerEl->gi eq 'skills' ) {
                foreach my $skill ( $playerEl->children ) {
                    $self->skills( $skill->gi, $skill->text );
                }
            }
            elsif ( $playerEl->gi eq 'nationality' ) {
                $self->nationality( $playerEl->text, $playerEl->att('id') );
            }
            else {
                $self->basic( $playerEl->gi, $playerEl->text );
            }
        }
    }

    else {
        carp "Unexpected child element processing player xml: " . $el->gi;
    }
    return $self;
}

1;

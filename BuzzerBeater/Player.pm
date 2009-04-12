#
#  $Id: Player.pm,v 1.4 2009-04-12 12:25:41 ken Exp $
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

sub _initialize {
    my $self = shift;

    if (@_) {
        my $args = shift;
        $self->setFromXml( $args->{xml} ) if ( exists $args->{xml} );
    }
}

sub setFromXml {
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

#
#  TODO:  Moose-ify this?
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

1;

#
#  $Id$
#

use strict;
use warnings;

package BuzzerBeater::Teaminfo;

use XML::Twig;
use Carp;

use BuzzerBeater::Common::Utils qw(encode_bb_text);

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->_initialize(@_);
    return $self;
}

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

    if ( $el->gi eq 'team' ) {
        $self->{id} = $el->att('id');

        #  Set the basic data
        foreach my $team_data ( $el->children ) {
            $self->{ $team_data->gi } = encode_bb_text( $team_data->text );
        }

        $self->{leagueid}  = $el->first_child('league')->att('id');
        $self->{countryid} = $el->first_child('country')->att('id');

        my $owner = $el->first_child('owner');
        if ($owner) {
            $self->{supporter} = $el->first_child('owner')->att('supporter');
        }

    }

    else {
        carp "Unexpected child element processing teaminfo xml: " . $el->gi;
    }
    return $self;
}

sub league       { my $self = shift; return $self->{league} }
sub leagueid     { my $self = shift; return $self->{leagueid} }
sub country      { my $self = shift; return $self->{country} }
sub is_supporter { my $self = shift; return $self->{supporter} }
sub owner        { my $self = shift; return $self->{owner} }
sub shortName    { my $self = shift; return $self->{shortName} }
sub teamName     { my $self = shift; return $self->{teamName} }
sub id           { my $self = shift; return $self->{id} }

1;

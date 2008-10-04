#
#  $Id: Boxscore.pm,v 1.1 2008-10-04 16:56:38 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Boxscore;

use XML::Twig;
use Carp;

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  $self->_initialize(@_);
  return $self;
}

sub _initialize {
  my $self = shift;

  if (@_) {
    my $args = shift;
    $self->setFromXml($args->{xml}) if (exists $args->{xml});
  }
}

sub setFromXml {
  my $self = shift;
  my $xml = shift;

  my $twig = new XML::Twig;
  $twig->parse($xml); # safe_parse or croak?

  my $root = $twig->root;
  my $el = $root->first_child();

  if ($el->gi eq 'match') {
    $self->{id} = $el->att('id');
    $self->{type} = $el->att('type');
  }

  else {
    carp "Unexpected child element processing roster xml: " .
         $el->gi;
  }
  return $self;
}

sub id      { my $self = shift; return $self->{id} }

# TODO: Should this have mappings for the various types?
sub type    { my $self = shift; return $self->{type} }

#  Searches for players by id or name.

1;

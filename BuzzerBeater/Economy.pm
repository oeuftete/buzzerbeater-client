#
#  $Id: Economy.pm,v 1.1 2008-10-04 16:56:38 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Economy;

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

# my $twig = new XML::Twig;
# $twig->parse($xml); # safe_parse or croak?

# my $root = $twig->root;
# my $el = $root->first_child();

# if ($el->gi eq 'economy') {
#   #  Set teamid
#   $self->{teamid} = $el->att('teamid');

#   #  Set name
#   $self->{name} = $el->first_child_text('name');

#   #  Set seats
#   my $seats = $el->first_child('seats');
#   foreach my $seatType ($seats->children) {
#     $self->{seats}->{$seatType->gi}->{value} =
#       $seatType->text;
#     foreach my $seatPricing ('price', 'nextPrice') {
#       $self->{seats}->{$seatType->gi}->{$seatPricing} =
#         $seatType->att($seatPricing);
#     }
#   }

#   #  Set expansion
#   my $expansion = $el->first_child('expansion');
#   if ($expansion) {
#     $self->{expansion}->{daysLeft} = $expansion->att('daysLeft');
#     foreach my $seatType ($expansion->children) {
#       $self->{expansion}->{$seatType->gi}->{value} =
#         $seatType->text;
#     }
#   }
# }

# else {
#   carp "Unexpected child element processing arena xml: " .
#     $el->gi;
# }
  return $self;
}

#sub teamid      { my $self = shift; return $self->{teamid} }
#sub name        { my $self = shift; return $self->{name} }
#sub seats       { my $self = shift; return $self->{seats} }
#sub expansion   { my $self = shift; return $self->{expansion} }

1;

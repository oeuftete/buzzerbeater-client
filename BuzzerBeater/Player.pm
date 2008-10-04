#
#  $Id: Player.pm,v 1.1 2008-10-04 16:56:38 ken Exp $
#

use strict;
use warnings;

package BuzzerBeater::Player;

use Encode;

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  # Set to something since it's optional in the XML
  $self->{injury} = 0;
  $self->{skills} = {};
  return $self;
}

#  Get/set player id
sub id {
  my $self = shift;
  if (@_) {
    $self->{id} = shift;
    return $self;
  }
  return $self->{id};
}

# Get/set the basic (i.e. att-less) top-level fields.
# 
# To get, provide the key.
# To set, provide the key and value.
sub basic {
  my $self = shift;

  if (@_ == 2) {
    my ($basicGi, $basicText) = @_;
    $self->{$basicGi} = encode_utf8($basicText);
  }
  elsif (@_ == 1) {
    return $self->{$_[0]};
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
    ($self->{nationality}->{value},
     $self->{nationality}->{id}) = map {encode_utf8($_)} @_;
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
    my ($name, $value) = @_;
    $self->{skills}->{$name} = $value;
    return $self;
  }
  return $self->{skills};
}

# Return the full name
sub getName {
  my $self = shift;
  return $self->basic('firstName') . ' ' .
         $self->basic('lastName');
}

1;

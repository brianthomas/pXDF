
# $Id$

package XDF::Delimiter;

# /** COPYRIGHT
#    Delimiter.pm Copyright (C) 2002 Brian Thomas,
#    ADC/GSFC-NASA, Code 631, Greenbelt MD, 20771
#@ 
#    This program is free software; it is licensed under the same terms
#    as Perl itself is. Please refer to the file LICENSE which is contained
#    in the distribution that this file came in.
#@ 
#   This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# */

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# This class handles the delimiter information for delimited IO 
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# */

use XDF::BaseObject;
use XDF::Chars;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $DEFAULT_REPEATABLE = "yes";
my $Class_XML_Node_Name = "delimiter";
my @Local_Class_XML_Attributes = qw (
                                       repeatable
                                       valueObj
                                    );
my @Local_Class_Attributes = (); 

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization -- set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }


# /** classXMLNodeName
# This method returns the class node name for this class.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::BinaryFloatField. 
# */
sub getClassAttributes {
  \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# 
# SET/GET Methods
#

# /** getRepeatable
# */
sub getRepeatable {
   my ($self) = @_;
   return $self->{repeatable};
}

# /** setRepeatable
#     Set the repeatable attribute. 
# */
sub setRepeatable {
   my ($self, $value) = @_;
   $self->{repeatable} = $value;
}

# /** setValue
#     Set the value (with either Chars or NewLine object) of this delimiter.
# */
sub setValue {
   my ($self, $valueObj) = @_;

   if (&XDF::Utility::isValidCharOutput($valueObj)) {
      $self->{valueObj} = $valueObj;
   } else {
      warn "Cant set $valueObj as value of XDF::Delimiter class, ignoring request\n";
   }
}

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{valueObj};
}

# /** getStringValue
#     return the String representation of the delimiter of this object. 
# */
sub getStringValue {
   my ($self) = @_;
   return $self->getValue()->getValue();
}

#
# Private/Protected Methods
#

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->setValue(new XDF::Chars());
  $self->setRepeatable($DEFAULT_REPEATABLE);

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

1;

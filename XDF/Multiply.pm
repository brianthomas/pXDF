
# $Id$

# /** COPYRIGHT
#    Multiply.pm Copyright (C) 2003 Brian Thomas,
#    XML Group GSFC-NASA, Code 630.1, Greenbelt MD, 20771
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# An XDF::Multiply is a class that defines an muliplication component for an XDF::Conversion object.
# */

# /** SYNOPSIS
# */

# /** SEE ALSO
# XDF::Conversion
# */

package XDF::Multiply;

use XDF::ConversionComponent; 

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::ConversionComponent
@ISA = ("XDF::ConversionComponent");

# CLASS DATA
my $Class_XML_Node_Name = "multiply";
my @Local_Class_XML_Attributes = qw (
                             value
                          );
my @Local_Class_Attributes = ();

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::ConversionComponent::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::ConversionComponent::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::Multiply.
# */
sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  return \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Constructor
#

# For ease of construction, lets allow initialization of value from constructor
sub new {
  my ($proto, $attribHashOrValue) = @_;

   my $self;
   if (ref $attribHashOrValue eq 'HASH') {
     $self = $proto->SUPER::new($attribHashOrValue);
     $self->_init();
   } else {
     $self = $proto->SUPER::new();
     $self->_init();
     $self->setValue($attribHashOrValue);
   }

   return $self;
}

# 
# SET/GET Methods
#

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{value};
}

# /** setValue
#     Set the value attribute. 
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{value} = $value;
}

#
# Other Public Methods
#

# /** evaluate
# Evaluate a value using this conversion object. Returns the converted
# value.
# */
sub evaluate { # PROTECTED
   my ($self, $value) = @_;
   return ($value * $self->{value});
}

#
# Private methods 
#

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();

  $self->{value} = 1;

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self, $val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

1;


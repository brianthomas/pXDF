
# $Id$

# /** COPYRIGHT
#    NaturalLogarithm.pm Copyright (C) 2003 Brian Thomas,
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
# An XDF::NaturalLogarithm is a class that defines an natural log component for an XDF::Conversion object.
# */

# /** SYNOPSIS
# */

# /** SEE ALSO
# XDF::Conversion
# */

package XDF::NaturalLogarithm;

use XDF::Component;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Component
@ISA = ("XDF::Component");

# CLASS DATA
my $DEF_BASE = 2.7182881828; # the base value for the logarithm 

my $Class_XML_Node_Name = "naturalLogarithm";
my @Local_Class_XML_Attributes = qw ( );
my @Local_Class_Attributes = ();

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::Component::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::Component::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::NaturalLogarithm.
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

# Override constructor. THis class doesnt take value.
#sub new {
#  my ($proto, $attribHash) = @_;

#   my $self = $proto->SUPER->SUPER::new($attribHash);
#   $self->_init();

#   return $self;
#}

# 
# SET/GET Methods
#

# /** getValue
# Returns the base exponent value, e.g. the value of 'e' (2.718..)
# */
sub getValue { 
   my ($self) = @_;
   return $DEF_BASE;
}

# /** setValue
#     Not allowed for naturalLogarithm. 
# */
sub setValue { # PRIVATE
   my ($self, $value) = @_;
#   $self->{value} = $value;
   error("Cant set value for Natural Logarithm\n"); 
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
   return ($value + $self->{value});
}

#
# Private methods 
#

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();

  $self->{value} = undef; # yes, thats right we dont want this defined 

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


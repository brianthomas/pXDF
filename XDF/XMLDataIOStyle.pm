
package XDF::XMLDataIOStyle;

# $Id$

# /** COPYRIGHT
#    XMLDataIOStyle.pm Copyright (C) 2000 Brian Thomas,
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
# This abstract class indicates how records are to be read/written 
# back out into XDF formatted XML files.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::TaggedXMLDataIOStyle
# XDF::FormattedXMLDataIOStyle
# XDF::DelimitedXMLDataIOStyle
# */

# _parentArray is private so that they dont get 
# written out when we use toXML* methods on this class.

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
# /** dataStyleId
# 
# */
# /** dataStyleIdRef 
# 
# */
# /** encoding
# What encoding to use when writing out XML data.
# */
# /** endian
# What endian to use when writing out binary data.
# */

my $Big_Endian             = 'BigEndian'; 
my $Little_Endian             = 'LittleEndian'; 

my $Def_Encoding           = 'ISO-8859-1';
my $Def_Endian             = $Big_Endian;

my $Untagged_Instruction_Node_Name = "for";

my $Class_XML_Node_Name = "dataStyle";
my @Local_Class_XML_Attributes = qw (
                             dataStyleId
                             dataStyleIdRef
                             encoding
                             endian
                          );
my @Local_Class_Attributes = qw (
                             writeAxisOrderList
                             _parentArray
                          );

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

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of this class.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
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

sub untaggedInstructionNodeName { 
  return $Untagged_Instruction_Node_Name; 
}

#
# GET/SET Methods
#

# /** getDataStyleId
# */
sub getDataStyleId{
   my ($self) = @_;
   return $self->{dataStyleId};
}

# /** setDataStyleId
#     Set the dataStyleId attribute. 
# */
sub setDataStyleId {
   my ($self, $value) = @_;
   $self->{dataStyleId} = $value;
}

# /** getDataStyleIdRef 
# */
sub getDataStyleIdRef {
   my ($self) = @_;
   return $self->{dataStyleIdRef};
}

# /** setDataStyleIdRef 
#     Set the dataStyleIdRef attribute. 
# */
sub setDataStyleIdRef {
   my ($self, $value) = @_;
   $self->{dataStyleIdRef} = $value;
}

# /** getEncoding
# */
sub getEncoding{
   my ($self) = @_;
   return $self->{encoding};
}

# /** setEncoding
#     Set the encoding attribute. 
# */
sub setEncoding {
   my ($self, $value) = @_;

   carp "Cant set encoding to $value, not allowed \n"
      unless (&XDF::Utility::isValidIOEncoding($value));

   $self->{encoding} = $value;
}

# /** getEndian
# */
sub getEndian{
   my ($self) = @_;
   return $self->{endian};
}

# /** setEndian
#     Set the endian attribute. 
# */
sub setEndian {
   my ($self, $value) = @_;

   carp "Cant set endian to $value, not allowed \n"
      unless (&XDF::Utility::isValidEndian($value));

   $self->{endian} = $value;
}

#/** getWriteAxisOrderList 
# This method sets the ordering of the fastest to slowest axis for
# writing out data. The default is to use the parent array
# axisList ordering (field axis first, if it exists, followed by all
# other axes in the order in which they were declared).
# */
sub getWriteAxisOrderList {
  my ($self) =@_;

  my $list_ref = $self->{writeAxisOrderList};
  $list_ref = $self->{_parentArray}->getAxisList() unless
      defined $list_ref || !defined $self->{_parentArray};
  return $list_ref;
}

#/** setWriteAxisOrderList 
# This method sets the ordering of the fastest to slowest axis for
# writing out formatted data. The fastest axis is the last in
# the array. Setting the writeAxisOrderList will effect how the document
# is written out. For the Formatted and Delimited styles, this means how
# the 'for' nodes will appear. There is no effect on Tagged data (at this
# time) for setting the axis order list in any different way.
#*/
sub setWriteAxisOrderList {
  my ($self, $arrayRefValue) = @_;

  if (ref($self) eq 'XDF::TaggedXMLDataIOStyle') {
    warn "setWriteAxisOrderList has no effect currently for TaggedXMLDataIOStyle, Ignoring\n";
    return;
  }

  # you must do it this way, or when the arrayRef changes it changes us here!
  my @list = @{$arrayRefValue};
  $self->{writeAxisOrderList} = \@list;
}

#
# Private Methods 
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init { 
  my ($self) = @_; 

  $self->SUPER::_init();

  $self->{encoding} = $Def_Encoding;
  $self->{endian} = $Def_Endian;

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


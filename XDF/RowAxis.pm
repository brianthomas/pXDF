
package XDF::RowAxis;
 
# Package for XDF::RowAxis
# $Id$

# /** COPYRIGHT
#    RowAxis.pm Copyright (C) 2002 Brian Thomas,
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

use XDF::Axis;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# /** DESCRIPTION 
# */

# /** SYNOPSIS
# 
#    my $axisObj = new XDF::RowAxis(); # create axis, size '1'
#    $axisObj->name("first axis");
#    my $valueObj = new XDF::Value('9');
#    $axisObj->setAxisValue(0,$valueObj); # the axis value at index 0 has value "9" 
#
#    or 
#
#    my $axisObj = new XDF::RowAxis(10); # create axis wi/ length 10 and 10 values numbered 0 thru 9. 
#
#    or 
# 
#    my @axisValueList = qw ( $axisValueObjRef1 $axisValueObjRef2 );
#    my $axisObj = new XDF::RowAxis( { 'name' => 'first axis',
#                                 }
#                               );
#
# */

# inherits from XDF::Axis
@ISA = ("XDF::Axis");

# CLASS DATA
my $DEFAULT_ROW_AXIS_ID = "rowAxis";
my $Class_XML_Node_Name = "rowAxis";

# the order of these attributes IS important.
# 
my @Local_Class_XML_Attributes = qw ( ); 

my @Local_Class_Attributes = qw (); 

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::Axis::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::Axis::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name for XDF::RowAxis; 
# This method takes no arguments may not be changed. 
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
# set/get Methods
#

# /** getAxisId
#     Get the axisId attribute. 
# */
sub getAxisId {
   my ($self) = @_;
   return $DEFAULT_ROW_AXIS_ID;
}

# /** setAxisId
#     Set the axisId attribute. 
# */
sub setAxisId {
   my ($self, $value) = @_;
   error("not allowed to set axisId for RowAxis");
#   $self->{axisId} = $value;
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

  $self->{idRef} = undef;
  $self->{units} = undef;

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;



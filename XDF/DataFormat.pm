
# $Id$

package XDF::DataFormat;

# /** COPYRIGHT
#    DataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::DataFormat is an abstract class used to describe the data format of 
# information held in datacells as specified in either XDF::Field or 
# XDF::Array objects. Note that one should specify the DataFormat object for EITHER
# an Array OR ALL of the Fields. Doing both has no meaning. 
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::Array
# XDF::Field
# XDF::BinaryFloatDataFormat
# XDF::BinaryIntegerDataFormat
# XDF::ExponentialDataFormat
# XDF::FixedDataFormat
# XDF::IntegerDataFormat
# XDF::StringDataFormat
# */

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA

my $Class_XML_Node_Name = ""; # will be filled in by concrete class 
my $DataFormat_Class_XML_Node_Name = "dataFormat";
my @Class_Attributes = qw (
                     lessThanValue
                     lessThanOrEqualValue
                     greaterThanValue
                     greaterThanOrEqualValue
                     infiniteValue
                     infiniteNegativeValue
                     noDataValue
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization -- set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }


# /** lessThanValue
# The STRING value which indicates the less than symbol ("<") within the data cube.
# */
# /** lessThanOrEqualValue
# The STRING value which indicates the less than equal symbol ("=<") within the data cube.
# */
# /** greaterThanValue
# The STRING value which indicates the greater than symbol (">") within the data cube.
# */
# /** greaterThanOrEqualValue
# The STRING value which indicates the greater than equal symbol (">=") within the data cube.
# */
# /** infiniteValue
# The STRING value which indicates the infinite value within the data cube.
# */
# /** infiniteNegativeValue
# The STRING value which indicates the negative infinite value within the data cube.
# */
# /** noDataValue
# The STRING value which indicates the no data value within the data cube.
# */

# /** classXMLNodeName
# This method returns the class node name for this class.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::BinaryFloatField. 
# */
sub classAttributes {
  \@Class_Attributes;
}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# /** bytes
# On success this returns the number of bytes this object describes.
# Undef is returned if not successfull.
# */
sub bytes {
  my ($self) = @_;
  undef;
}

sub toXMLFileHandle {
  my ($self, $fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode,
      $newNodeNameString, $noChildObjectNodeName ) = @_;

   my $output = $self->Pretty_XDF_Output();
   print $fileHandle $indent if $output;
   print $fileHandle "<$DataFormat_Class_XML_Node_Name>";
   $self->Pretty_XDF_Output(0);
   $self->SUPER::toXMLFileHandle($fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode,
      $newNodeNameString, $noChildObjectNodeName);
   $self->Pretty_XDF_Output($output);
   print $fileHandle "</$DataFormat_Class_XML_Node_Name>";
   print $fileHandle "\n" if $output;

}

# Modification History
#
# $Log$
# Revision 1.3  2000/11/29 21:48:45  thomas
# Fix to shrink down inheritance of sub-classes. No
# more *Sytle.pm files. Fix to templateNotation method.
#
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__


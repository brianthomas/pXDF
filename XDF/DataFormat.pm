
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
# XDF::BinaryFloatStyle
# XDF::BinaryFloatDataFormat
# XDF::BinaryIntegerStyle
# XDF::BinaryIntegerDataFormat
# XDF::ExponentStyle
# XDF::ExponentDataFormat
# XDF::FixedStyle
# XDF::FixedDataFormat
# XDF::IntegerStyle
# XDF::IntegerDataFormat
# XDF::StringStyle
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

my $Class_XML_Node_Name = "dataFormat";
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

# Modification History
#
# $Log$
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::DataFormat - Perl Class for DataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::DataFormat is an abstract class used to describe the data format of  information held in datacells as specified in either XDF::Field or  XDF::Array objects. Note that one should specify the DataFormat object for EITHER an Array OR ALL of the Fields. Doing both has no meaning. 

XDF::DataFormat inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::DataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for this class. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item lessThanValue

The STRING value which indicates the less than symbol ("<") within the data cube.  

=item lessThanOrEqualValue

The STRING value which indicates the less than equal symbol ("=<") within the data cube.  

=item greaterThanValue

The STRING value which indicates the greater than symbol (">") within the data cube.  

=item greaterThanOrEqualValue

The STRING value which indicates the greater than equal symbol (">=") within the data cube.  

=item infiniteValue

The STRING value which indicates the infinite value within the data cube.  

=item infiniteNegativeValue

The STRING value which indicates the negative infinite value within the data cube.  

=item noDataValue

The STRING value which indicates the no data value within the data cube.  

=back

=head2 OTHER Methods

=over 4

=item bytes (EMPTY)

On success this returns the number of bytes this object describes. Undef is returned if not successfull. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::DataFormat inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::DataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L< XDF::Array>, L< XDF::Field>, L< XDF::BinaryFloatStyle>, L< XDF::BinaryFloatDataFormat>, L< XDF::BinaryIntegerStyle>, L< XDF::BinaryIntegerDataFormat>, L< XDF::ExponentStyle>, L< XDF::ExponentDataFormat>, L< XDF::FixedStyle>, L< XDF::FixedDataFormat>, L< XDF::IntegerStyle>, L< XDF::IntegerDataFormat>, L< XDF::StringStyle>, L< XDF::StringDataFormat>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

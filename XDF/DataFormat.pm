
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
# XDF::FloatDataFormat
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
my @Class_XML_Attributes = qw (
                     lessThanValue
                     lessThanOrEqualValue
                     greaterThanValue
                     greaterThanOrEqualValue
                     infiniteValue
                     infiniteNegativeValue
                     noDataValue
                          );
my @Class_Attributes = (); 

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

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

# 
# SET/GET Methods
#

# /** getLessThanValue
# */
sub getLessThanValue {
   my ($self) = @_;
   return $self->{LessThanValue};
}

# /** setLessThanValue
#     Set the lessThanValue attribute. 
# */
sub setLessThanValue {
   my ($self, $value) = @_;
   $self->{LessThanValue} = $value;
}

# /** getLessThanOrEqualValue
# */
sub getLessThanOrEqualValue {
   my ($self) = @_;
   return $self->{LessThanOrEqualValue};
}

# /** setLessThanOrEqualValue
#     Set the lessThanOrEqualValue attribute. 
# */
sub setLessThanOrEqualValue {
   my ($self, $value) = @_;
   $self->{LessThanOrEqualValue} = $value;
}

sub getGreaterThanValue {
   my ($self) = @_;
   return $self->{GreaterThanValue};
}

# /** setGreaterThanValue
#     Set the greaterThanValue attribute. 
# */
sub setGreaterThanValue {
   my ($self, $value) = @_;
   $self->{GreaterThanValue} = $value;
}

# /** getGreaterThanOrEqualValue
# */
sub getGreaterThanOrEqualValue {
   my ($self) = @_;
   return $self->{GreaterThanOrEqualValue};
}

# /** setGreaterThanOrEqualValue
#     Set the greaterThanOrEqualValue attribute. 
# */
sub setGreaterThanOrEqualValue {
   my ($self, $value) = @_;
   $self->{GreaterThanOrEqualValue} = $value;
}

# /** getInfiniteValue
# */
sub getInfiniteValue {
   my ($self) = @_;
   return $self->{InfiniteValue};
}

# /** setInfiniteValue
#     Set the infiniteValue attribute. 
# */
sub setInfiniteValue {
   my ($self, $value) = @_;
   $self->{InfiniteValue} = $value;
}

# /** getInfiniteNegativeValue
# */
sub getInfiniteNegativeValue {
   my ($self) = @_;
   return $self->{InfiniteNegativeValue};
}

# /** setInfiniteNegativeValue
#     Set the infiniteNegativeValue attribute. 
# */
sub setInfiniteNegativeValue {
   my ($self, $value) = @_;
   $self->{InfiniteNegativeValue} = $value;
}

# /** getNoDataValue
# */
sub getNoDataValue {
   my ($self) = @_;
   return $self->{NoDataValue};
}

# /** setNoDataValue
#     Set the noDataValue attribute. 
# */
sub setNoDataValue {
   my ($self, $value) = @_;
   $self->{NoDataValue} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

# /** numOfBytes
# This returns the number of bytes this object describes.
# Undef is returned if not successfull.
# */
sub numOfBytes {
  my ($self) = @_;
  undef;
}

#
# Other Public Methods 
#

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


# Modification History
#
# $Log$
# Revision 1.7  2001/02/15 17:50:31  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.6  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.5  2000/12/14 22:11:25  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.4  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
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

=head1 NAME

XDF::DataFormat - Perl Class for DataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::DataFormat is an abstract class used to describe the data format of  information held in datacells as specified in either XDF::Field or  XDF::Array objects. Note that one should specify the DataFormat object for EITHER an Array OR ALL of the Fields. Doing both has no meaning. 

XDF::DataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


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

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

 

=item # Initalization -- set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** lessThanValue

 

=item # The STRING value which indicates the less than symbol ("<") within the data cube.

 

=item # */

 

=item # /** lessThanOrEqualValue

 

=item # The STRING value which indicates the less than equal symbol ("=<") within the data cube.

 

=item # */

 

=item # /** greaterThanValue

 

=item # The STRING value which indicates the greater than symbol (">") within the data cube.

 

=item # */

 

=item # /** greaterThanOrEqualValue

 

=item # The STRING value which indicates the greater than equal symbol (">=") within the data cube.

 

=item # */

 

=item # /** infiniteValue

 

=item # The STRING value which indicates the infinite value within the data cube.

 

=item # */

 

=item # /** infiniteNegativeValue

 

=item # The STRING value which indicates the negative infinite value within the data cube.

 

=item # */

 

=item # /** noDataValue

 

=item # The STRING value which indicates the no data value within the data cube.

 

=item # */

 

=item # /** classXMLNodeName

 

=item # This method returns the class node name for this class.

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classXMLNodeName { 

 

=item }

 

=item # /** classAttributes

 

=item #  This method takes no arguments may not be changed. 

 

=item #  This method returns a list reference containing the names

 

=item #  of the class attributes of XDF::BinaryFloatField. 

 

=item # */

 

=item sub classAttributes {

 

=item }

 

=item # 

 

=item # SET/GET Methods

 

=item #

 

=item # /** getLessThanValue

 

=item # */

 

=item sub getLessThanValue {

 

=item return $self->{LessThanValue};

 

=item }

 

=item # /** setLessThanValue

 

=item #     Set the lessThanValue attribute. 

 

=item # */

 

=item sub setLessThanValue {

 

=item $self->{LessThanValue} = $value;

 

=item }

 

=item # /** getLessThanOrEqualValue

 

=item # */

 

=item sub getLessThanOrEqualValue {

 

=item return $self->{LessThanOrEqualValue};

 

=item }

 

=item # /** setLessThanOrEqualValue

 

=item #     Set the lessThanOrEqualValue attribute. 

 

=item # */

 

=item sub setLessThanOrEqualValue {

 

=item $self->{LessThanOrEqualValue} = $value;

 

=item }

 

=item sub getGreaterThanValue {

 

=item return $self->{GreaterThanValue};

 

=item }

 

=item # /** setGreaterThanValue

 

=item #     Set the greaterThanValue attribute. 

 

=item # */

 

=item sub setGreaterThanValue {

 

=item $self->{GreaterThanValue} = $value;

 

=item }

 

=item # /** getGreaterThanOrEqualValue

 

=item # */

 

=item sub getGreaterThanOrEqualValue {

 

=item return $self->{GreaterThanOrEqualValue};

 

=item }

 

=item # /** setGreaterThanOrEqualValue

 

=item #     Set the greaterThanOrEqualValue attribute. 

 

=item # */

 

=item sub setGreaterThanOrEqualValue {

 

=item $self->{GreaterThanOrEqualValue} = $value;

 

=item }

 

=item # /** getInfiniteValue

 

=item # */

 

=item sub getInfiniteValue {

 

=item return $self->{InfiniteValue};

 

=item }

 

=item # /** setInfiniteValue

 

=item #     Set the infiniteValue attribute. 

 

=item # */

 

=item sub setInfiniteValue {

 

=item $self->{InfiniteValue} = $value;

 

=item }

 

=item # /** getInfiniteNegativeValue

 

=item # */

 

=item sub getInfiniteNegativeValue {

 

=item return $self->{InfiniteNegativeValue};

 

=item }

 

=item # /** setInfiniteNegativeValue

 

=item #     Set the infiniteNegativeValue attribute. 

 

=item # */

 

=item sub setInfiniteNegativeValue {

 

=item $self->{InfiniteNegativeValue} = $value;

 

=item }

 

=item # /** getNoDataValue

 

=item # */

 

=item sub getNoDataValue {

 

=item return $self->{NoDataValue};

 

=item }

 

=item # /** setNoDataValue

 

=item #     Set the noDataValue attribute. 

 

=item # */

 

=item sub setNoDataValue {

 

=item $self->{NoDataValue} = $value;

 

=item }

 

=item # /** getXMLAttributes

 

=item #      This method returns the XMLAttributes of this class. 

 

=item #  */

 

=item sub getXMLAttributes {

 

=item }

 

=item # /** numOfBytes

 

=item # This returns the number of bytes this object describes.

 

=item # Undef is returned if not successfull.

 

=item # */

 

=item sub numOfBytes {

 

=item undef;

 

=item }

 

=item #

 

=item # Other Public Methods 

 

=item #

 

=item sub toXMLFileHandle {

 

=item $newNodeNameString, $noChildObjectNodeName ) = @_;

 

=back

=head2 OTHER Methods

=over 4

=item getLessThanValue (EMPTY)



=item setLessThanValue ($value)

Set the lessThanValue attribute. 

=item getLessThanOrEqualValue (EMPTY)



=item setLessThanOrEqualValue ($value)

Set the lessThanOrEqualValue attribute. 

=item getGreaterThanValue (EMPTY)



=item setGreaterThanValue ($value)

Set the greaterThanValue attribute. 

=item getGreaterThanOrEqualValue (EMPTY)



=item setGreaterThanOrEqualValue ($value)

Set the greaterThanOrEqualValue attribute. 

=item getInfiniteValue (EMPTY)



=item setInfiniteValue ($value)

Set the infiniteValue attribute. 

=item getInfiniteNegativeValue (EMPTY)



=item setInfiniteNegativeValue ($value)

Set the infiniteNegativeValue attribute. 

=item getNoDataValue (EMPTY)



=item setNoDataValue ($value)

Set the noDataValue attribute. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item numOfBytes (EMPTY)

This returns the number of bytes this object describes. Undef is returned if not successfull. 

=item toXMLFileHandle (EMPTY)



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

XDF::DataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::DataFormat inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::Array>, L< XDF::Field>, L< XDF::BinaryFloatDataFormat>, L< XDF::BinaryIntegerDataFormat>, L< XDF::FloatDataFormat>, L< XDF::IntegerDataFormat>, L< XDF::StringDataFormat>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

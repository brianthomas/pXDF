
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
#                     lessThanValue
#                     lessThanOrEqualValue
#                     greaterThanValue
#                     greaterThanOrEqualValue
#                     infiniteValue
#                     infiniteNegativeValue
#                     noDataValue
my @Local_Class_XML_Attributes = qw (
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

## /** getLessThanValue
## */
#sub getLessThanValue {
#   my ($self) = @_;
#   return $self->{LessThanValue};
#}

## /** setLessThanValue
##     Set the lessThanValue attribute. 
## */
#sub setLessThanValue {
#   my ($self, $value) = @_;
#   $self->{LessThanValue} = $value;
#}
#
## /** getLessThanOrEqualValue
## */
#sub getLessThanOrEqualValue {
#   my ($self) = @_;
#   return $self->{LessThanOrEqualValue};
#}
#
# /** setLessThanOrEqualValue
#     Set the lessThanOrEqualValue attribute. 
# */
#sub setLessThanOrEqualValue {
#   my ($self, $value) = @_;
#   $self->{LessThanOrEqualValue} = $value;
#}
#
#sub getGreaterThanValue {
#   my ($self) = @_;
#   return $self->{GreaterThanValue};
#}
#
## /** setGreaterThanValue
##     Set the greaterThanValue attribute. 
## */
#sub setGreaterThanValue {
#   my ($self, $value) = @_;
#   $self->{GreaterThanValue} = $value;
#}
#
## /** getGreaterThanOrEqualValue
## */
#sub getGreaterThanOrEqualValue {
#   my ($self) = @_;
#   return $self->{GreaterThanOrEqualValue};
#}
#
## /** setGreaterThanOrEqualValue
##     Set the greaterThanOrEqualValue attribute. 
## */
#sub setGreaterThanOrEqualValue {
#   my ($self, $value) = @_;
#   $self->{GreaterThanOrEqualValue} = $value;
#}
#
## /** getInfiniteValue
## */
#sub getInfiniteValue {
#   my ($self) = @_;
#   return $self->{InfiniteValue};
#}
#
## /** setInfiniteValue
##     Set the infiniteValue attribute. 
## */
#sub setInfiniteValue {
#   my ($self, $value) = @_;
#   $self->{InfiniteValue} = $value;
#}
#
## /** getInfiniteNegativeValue
## */
#sub getInfiniteNegativeValue {
#   my ($self) = @_;
#   return $self->{InfiniteNegativeValue};
#}
#
## /** setInfiniteNegativeValue
##     Set the infiniteNegativeValue attribute. 
## */
#sub setInfiniteNegativeValue {
#   my ($self, $value) = @_;
#   $self->{InfiniteNegativeValue} = $value;
#}
#
## /** getNoDataValue
## */
#sub getNoDataValue {
#   my ($self) = @_;
#   return $self->{NoDataValue};
#}
#
## /** setNoDataValue
##     Set the noDataValue attribute. 
## */
#sub setNoDataValue {
#   my ($self, $value) = @_;
#   $self->{NoDataValue} = $value;
#}

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

   my $spec = XDF::Specification->getInstance();
   my $output = $spec->isPrettyXDFOutput;
   print $fileHandle $indent if $output;
   print $fileHandle "<$DataFormat_Class_XML_Node_Name>";
   $spec->setPrettyXDFOutput(0);
   $self->SUPER::toXMLFileHandle($fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode,
      $newNodeNameString, $noChildObjectNodeName);
   $spec->setPrettyXDFOutput($output);
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
# Revision 1.14  2001/08/13 19:46:36  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.13  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.12  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.11  2001/04/17 18:56:42  thomas
# Now using Specification Class.
# Properly calling superclass init now
#
# Revision 1.10  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.9  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.8  2001/02/22 19:36:48  thomas
# Yanked lessthanvalue, etc from class
# for the time being. These attributes temp
# reside in either Field or Array.
#
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


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for this class. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item toXMLFileHandle (EMPTY)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DataFormat.

=over 4

=item numOfBytes (EMPTY)

This returns the number of bytes this object describes. Undef is returned if not successfull.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::DataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::DataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L< XDF::Field>, L< XDF::BinaryFloatDataFormat>, L< XDF::BinaryIntegerDataFormat>, L< XDF::FloatDataFormat>, L< XDF::IntegerDataFormat>, L< XDF::StringDataFormat>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

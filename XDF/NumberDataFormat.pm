
# $Id$

package XDF::NumberDataFormat;

# /** COPYRIGHT
#    NumberDataFormat.pm Copyright (C) 2003 Brian Thomas,
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# XDF::NumberDataFormat is an abstract class used to describe the data format of 
# information held in datacells which are numbers. 
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::BinaryFloatDataFormat
# XDF::BinaryIntegerDataFormat
# XDF::FloatDataFormat
# XDF::IntegerDataFormat
# */

use XDF::DataFormat;
#use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::DataFormat
@ISA = ("XDF::DataFormat");

# CLASS DATA

my $Class_XML_Node_Name = ""; # will be filled in by concrete class 
my @Local_Class_XML_Attributes = qw (
                                infiniteValue
                                infiniteNegativeValue
                                noDataValue
                                notANumberValue
                                overFlowValue
                                underFlowValue
                                disabledValue
                          );
my @Local_Class_Attributes = (); 

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::DataFormat::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::DataFormat::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization -- set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

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

# /** getInfiniteValue
# 
# */
sub getInfiniteValue {
   my ($self) = @_;
   return $self->{infiniteValue};
}

# /** setInfiniteValue
#     Set the infiniteValue attribute. 
# */
sub setInfiniteValue {
   my ($self, $value) = @_;
   $self->{infiniteValue} = $value;
}

# /** getInfiniteNegativeValue
# 
# */
sub getInfiniteNegativeValue {
   my ($self) = @_;
   return $self->{infiniteNegativeValue};
}

# /** setInfiniteNegativeValue
#     Set the infiniteNegativeValue attribute. 
# */
sub setInfiniteNegativeValue {
   my ($self, $value) = @_;
   $self->{infiniteNegativeValue} = $value;
}

# /** getNoDataValue
# 
# */
sub getNoDataValue {
   my ($self) = @_;
   return $self->{noDataValue};
}

# /** setNoDataValue
#     Set the noDataValue attribute. 
# */
sub setNoDataValue {
   my ($self, $value) = @_;
   $self->{noDataValue} = $value;
}

# /** getNotANumberValue
# 
# */
sub getNotANumberValue {
   my ($self) = @_;
   return $self->{notANumberValue};
}

# /** setNotANumberValue            
#     Set the notANumberValue attribute. 
# */                            
sub setNotANumberValue {
   my ($self, $value) = @_;
   $self->{notANumberValue} = $value;
}

# /** getOverFlowValue
# 
# */
sub getOverFlowValue {
   my ($self) = @_;
   return $self->{overFlowValue};
}

# /** setOverFlowValue            
#     Set the overFlowValue attribute. 
# */                            
sub setOverFlowValue {
   my ($self, $value) = @_;
   $self->{overFlowValue} = $value;
}

# /** getUnderFlowValue
# 
# */
sub getUnderFlowValue {
   my ($self) = @_;
   return $self->{underFlowValue};
}

# /** setUnderFlowValue            
#     Set the underFlowValue attribute. 
# */                            
sub setUnderFlowValue {
   my ($self, $value) = @_;
   $self->{underFlowValue} = $value;
}

# /** getDisabledValue
# 
# */
sub getDisabledValue {
   my ($self) = @_;
   return $self->{disabledValue};
}

# /** setDisabledValue            
#     Set the disabledValue attribute. 
# */                            
sub setDisabledValue {
   my ($self, $value) = @_;
   $self->{disabledValue} = $value;
}

#
# Private/Protected Methods
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

1;


__END__

=head1 NAME

XDF::NumberDataFormat - Perl Class for NumberDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::NumberDataFormat is an abstract class used to describe the data format of  information held in datacells which are numbers. 

XDF::NumberDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::DataFormat>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::NumberDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for this class. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::NumberDataFormat.

=over 4

=item getInfiniteValue (EMPTY)

 

=item setInfiniteValue ($value)

Set the infiniteValue attribute.  

=item getInfiniteNegativeValue (EMPTY)

 

=item setInfiniteNegativeValue ($value)

Set the infiniteNegativeValue attribute.  

=item getNoDataValue (EMPTY)

 

=item setNoDataValue ($value)

Set the noDataValue attribute.  

=item getNotANumberValue (EMPTY)

 

=item setNotANumberValue ($value)

Set the notANumberValue attribute.  

=item getOverFlowValue (EMPTY)

 

=item setOverFlowValue ($value)

Set the overFlowValue attribute.  

=item getUnderFlowValue (EMPTY)

 

=item setUnderFlowValue ($value)

Set the underFlowValue attribute.  

=item getDisabledValue (EMPTY)

 

=item setDisabledValue ($value)

Set the disabledValue attribute.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::NumberDataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::NumberDataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::NumberDataFormat inherits the following instance (object) methods of L<XDF::DataFormat>:
B<numOfBytes>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::BinaryFloatDataFormat>, L< XDF::BinaryIntegerDataFormat>, L< XDF::FloatDataFormat>, L< XDF::IntegerDataFormat>, L<XDF::DataFormat>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

package XDF::ArrayRefDataFormat;

# /** COPYRIGHT
#    ArrayRefDataFormatFormat.pm Copyright (C) 2003 Brian Thomas,
#    GSFC-NASA, Code 630.1, Greenbelt MD, 20771
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
# XDF::ArrayRefDataFormat is the class that describes array within cell data
# by using an arrayId to locate N-dimensional representation of the data of that cell.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# */

use XDF::StringDataFormat;
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::StringDataFormat
@ISA = ("XDF::StringDataFormat");

# CLASS DATA
my $Class_XML_Node_Name = "arrayRef";
my @Local_Class_XML_Attributes = qw ();
my @Local_Class_Attributes = ();
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::StringDataFormat::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::StringDataFormat::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::BinaryFloatField.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::ArrayRefDataFormat. 
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
# Get/Set Methods
#

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

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


__END__

=head1 NAME

XDF::ArrayRefDataFormat - Perl Class for ArrayRefDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::ArrayRefDataFormat is the class that describes array within cell data by using an arrayId to locate N-dimensional representation of the data of that cell. 

XDF::ArrayRefDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::StringDataFormat>, L<XDF::DataFormat>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::ArrayRefDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::BinaryFloatField. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::ArrayRefDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::ArrayRefDataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::ArrayRefDataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::ArrayRefDataFormat inherits the following instance (object) methods of L<XDF::StringDataFormat>:
B<getLength>, B<setLength>, B<getWidth>, B<setWidth>, B<numOfBytes>, B<fortranNotation>.

=back



=over 4

XDF::ArrayRefDataFormat inherits the following instance (object) methods of L<XDF::DataFormat>:
B<getInfiniteValue>, B<setInfiniteValue>, B<getInfiniteNegativeValue>, B<setInfiniteNegativeValue>, B<getNoDataValue>, B<setNoDataValue>, B<getNotANumberValue>, B<setNotANumberValue>, B<getOverFlowValue>, B<setOverFlowValue>, B<getUnderFlowValue>, B<setUnderFlowValue>, B<getDisabledValue>, B<setDisabledValue>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::StringDataFormat>, L<XDF::Log>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

# $Id$

package XDF::IntegerDataFormat;

# /** COPYRIGHT
#    IntegerDataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# The XDF::IntegerDataFormat class describes the data format of objects which 
# require such description (XDF::Field, XDF::Array).
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::Array
# XDF::DataFormat
# XDF::Field
# XDF::IntegerStyle
# */

use XDF::IntegerStyle;
use XDF::DataFormat;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::DataFormat and XDF::IntegerStyle
# order in @ISA array is important (?)
@ISA = ("XDF::IntegerStyle","XDF::DataFormat");

# CLASS DATA
my $Class_XML_Node_Name = &XDF::DataFormat::classXMLNodeName . "||" . 
                          &XDF::IntegerStyle::classXMLNodeName;
 
my @Class_Attributes = qw (
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};
push @Class_Attributes, @{&XDF::IntegerStyle::classAttributes};

# Initalization -- set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name for this class.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list containing the names
#  of the attributes for this class.
#  This method takes no arguments may not be changed. 
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

1;


__END__

=head1 NAME

XDF::IntegerDataFormat - Perl Class for IntegerDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 The XDF::IntegerDataFormat class describes the data format of objects which  require such description (XDF::Field, XDF::Array). 

XDF::IntegerDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>, L<XDF::IntegerStyle>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::IntegerDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for this class. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes for this class. This method takes no arguments may not be changed.  

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::Object>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::IntegerStyle>:
B<typeHexadecimal>, B<typeOctal>, B<typeDecimal>, B<bytes>.

=back

=back

=head1 SEE ALSO

L< XDF::Array>, L< XDF::DataFormat>, L< XDF::Field>, L< XDF::IntegerStyle>, L<XDF::IntegerStyle>, L<XDF::DataFormat>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

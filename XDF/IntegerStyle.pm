
# $Id$

package XDF::IntegerStyle;

# /** COPYRIGHT
#    IntegerStyle.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::IntegerStyle is an abstract class that describes (ASCII) 
# integer numbers.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::IntegerDataFormat
# XDF::IntegerDataType
# */


use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "integer";
my @Class_Attributes = qw (
                             type
                             width
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

my $Integer_Type_Decimal = 'decimal';
my $Integer_Type_Hex = 'hexadecimal';
my $Integer_Type_Octal = 'octal';

# Something specific to Perl

# This is used by the 'decimal' type
my $Perl_Sprintf_Field_Integer = 'd';

# using long octal format. Technically, should be an error
# to have Octal on Exponent and Fixed formats but we will 
# return the value as regular number 
my $Octal_Perl_Sprintf_Field_Integer = 'lo';

# using long hex format. Should be an error   
my $Hex_Perl_Sprintf_Field_Integer = 'lx';
my $Perl_Regex_Field_Integer = '\d';

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

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::BinaryFloatField. 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
}

# /** typeHexadecimal
# Returns the class value for the hexadecimal type. 
# This method takes no arguments may not be changed. 
# */
sub typeHexadecimal { $Integer_Type_Hex; }
 
# /** typeOctal
# Returns the class value for the octal type. 
# This method takes no arguments may not be changed. 
# */
sub typeOctal { $Integer_Type_Octal; }

# /** typeDecimal
# Returns the class value for the (default) decimal type. 
# This method takes no arguments may not be changed. 
# */
sub typeDecimal { $Integer_Type_Decimal; }

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

  $self->width(0);
  $self->type($Integer_Type_Decimal);

}

# /** bytes
# A convenience method.
# Return the number of bytes this XDF::BinaryFloatField holds.
# */
sub bytes { 
  my ($self) = @_; 
  $self->width; 
} 

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;
  return "A" . $self->width;
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->width;
  my $symbol = $Perl_Regex_Field_Integer;

  # treat the read as a string unless decimal
  $symbol = '\.' unless ($self->type eq $Integer_Type_Decimal);

  my $notation = '(';
  my $before_whitespace = $width - 1;
  $notation .= '\s' . "{0,$before_whitespace}" if($before_whitespace > 0);
  $notation .= $symbol . '{1,' . $width . '}';
  $notation .= ')';

  return $notation;

}

# returns sprintf field notation
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%';
  my $field_symbol = $Perl_Sprintf_Field_Integer;

  $field_symbol = $Octal_Perl_Sprintf_Field_Integer if ($self->type eq $Integer_Type_Octal );
  $field_symbol = $Hex_Perl_Sprintf_Field_Integer if ($self->type eq $Integer_Type_Hex );

  $notation .= $self->width; 
  $notation .= $field_symbol;

  return $notation;
}

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;

  my $notation = "I";
  $notation .= $self->width;
  return $notation;
}


# Modification History
#
# $Log$
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::IntegerStyle - Perl Class for IntegerStyle

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::IntegerStyle is an abstract class that describes (ASCII)  integer numbers. 

XDF::IntegerStyle inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::IntegerStyle.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::BinaryFloatField. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item type

 

=item width

 

=back

=head2 OTHER Methods

=over 4

=item typeHexadecimal (EMPTY)

Returns the class value for the hexadecimal type. This method takes no arguments may not be changed. 

=item typeOctal (EMPTY)

Returns the class value for the octal type. This method takes no arguments may not be changed. 

=item typeDecimal (EMPTY)

Returns the class value for the (default) decimal type. This method takes no arguments may not be changed. 

=item bytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryFloatField holds. 

=item fortranNotation (EMPTY)

The fortran style notation for this object. 

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

XDF::IntegerStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::IntegerStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L< XDF::IntegerDataFormat>, L< XDF::IntegerDataType>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

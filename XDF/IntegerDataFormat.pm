
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
# XDF::IntegerDataFormat is the class that describes (ASCII) 
# integer numbers.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# */


use XDF::DataFormat;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::DataFormat
@ISA = ("XDF::DataFormat");

# CLASS DATA
my $Class_XML_Node_Name = "integer";
my @Class_XML_Attributes = qw (
                             type
                             width
                          );
my @Class_Attributes = ();

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

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};
push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

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

#
# Get/Set Methods
#

# /** getWidth
# */
sub getWidth {
   my ($self) = @_;
   return $self->{Width};
}

# /** setWidth
#     Set the width attribute. 
# */
sub setWidth {
   my ($self, $value) = @_;
   $self->{Width} = $value;
}

# /** getType
# */
sub getType {
   my ($self) = @_;
   return $self->{Type};
}

# /** setType
#     Set the type attribute. 
# */
sub setType {
   my ($self, $value) = @_;
   $self->{Type} = $value;
}

# /** getBytes
# A convenience method.
# Return the number of bytes this XDF::BinaryFloatField holds.
# */
sub getBytes { 
  my ($self) = @_;
  $self->getWidth();
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes { 
  return \@Class_XML_Attributes;
}

#
# Other Public Methods 
#

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;

  my $notation = "I";
  $notation .= $self->{Width};
  return $notation;
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

  $self->{Width} = 0;
  $self->{Type} = $Integer_Type_Decimal;

}

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;
  return "A" . $self->{Width};
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->width;
  my $symbol = $Perl_Regex_Field_Integer;

  # treat the read as a string unless decimal
  $symbol = '\.' unless ($self->{Type} eq $Integer_Type_Decimal);

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

  $field_symbol = $Octal_Perl_Sprintf_Field_Integer if ($self->getType() eq $Integer_Type_Octal );
  $field_symbol = $Hex_Perl_Sprintf_Field_Integer if ($self->getType() eq $Integer_Type_Hex );

  $notation .= $self->{Width}; 
  $notation .= $field_symbol;

  return $notation;
}

# Modification History
#
# $Log$
# Revision 1.6  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.5  2000/12/14 22:11:25  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.4  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.3  2000/11/29 21:50:07  thomas
# Fix to shrink down inheritance of DataFormat classes.
# No more *Style.pm class files. -b.t.
#
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to DataFormat Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::IntegerDataFormat - Perl Class for IntegerDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::IntegerDataFormat is the class that describes (ASCII)  integer numbers. 

XDF::IntegerDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::IntegerDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::BinaryFloatField. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item my $Integer_Type_Decimal = 'decimal';

 

=item my $Integer_Type_Hex = 'hexadecimal';

 

=item my $Integer_Type_Octal = 'octal';

 

=item # Something specific to Perl

 

=item # This is used by the 'decimal' type

 

=item my $Perl_Sprintf_Field_Integer = 'd';

 

=item # using long octal format. Technically, should be an error

 

=item # to have Octal on Exponent and Fixed formats but we will 

 

=item # return the value as regular number 

 

=item my $Octal_Perl_Sprintf_Field_Integer = 'lo';

 

=item # using long hex format. Should be an error   

 

=item my $Hex_Perl_Sprintf_Field_Integer = 'lx';

 

=item my $Perl_Regex_Field_Integer = '\d';

 

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

 

=item push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** classXMLNodeName

 

=item # This method returns the class node name of XDF::BinaryFloatField.

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classXMLNodeName {

 

=item }

 

=item # /** classAttributes

 

=item #  This method returns a list reference containing the names

 

=item #  of the class attributes of XDF::BinaryFloatField. 

 

=item #  This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classAttributes {

 

=item }

 

=item # /** typeHexadecimal

 

=item # Returns the class value for the hexadecimal type. 

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub typeHexadecimal { $Integer_Type_Hex; }

 

=item # /** typeOctal

 

=item # Returns the class value for the octal type. 

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub typeOctal { $Integer_Type_Octal; }

 

=item # /** typeDecimal

 

=item # Returns the class value for the (default) decimal type. 

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub typeDecimal { $Integer_Type_Decimal; }

 

=item #

 

=item # Get/Set Methods

 

=item #

 

=item # /** getWidth

 

=item # */

 

=item sub getWidth {

 

=item return $self->{Width};

 

=item }

 

=item # /** setWidth

 

=item #     Set the width attribute. 

 

=item # */

 

=item sub setWidth {

 

=item $self->{Width} = $value;

 

=item }

 

=item # /** getType

 

=item # */

 

=item sub getType {

 

=item return $self->{Type};

 

=item }

 

=item # /** setType

 

=item #     Set the type attribute. 

 

=item # */

 

=item sub setType {

 

=item $self->{Type} = $value;

 

=item }

 

=item # /** getBytes

 

=item # A convenience method.

 

=item # Return the number of bytes this XDF::BinaryFloatField holds.

 

=item # */

 

=item sub getBytes { 

 

=back

=head2 OTHER Methods

=over 4

=item typeHexadecimal (EMPTY)

Returns the class value for the hexadecimal type. This method takes no arguments may not be changed. 

=item typeOctal (EMPTY)

Returns the class value for the octal type. This method takes no arguments may not be changed. 

=item typeDecimal (EMPTY)

Returns the class value for the (default) decimal type. This method takes no arguments may not be changed. 

=item getWidth (EMPTY)



=item setWidth ($value)

Set the width attribute. 

=item getType (EMPTY)



=item setType ($value)

Set the type attribute. 

=item getBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryFloatField holds. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

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

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<getLessThanValue>, B<setLessThanValue>, B<getLessThanOrEqualValue>, B<setLessThanOrEqualValue>, B<getGreaterThanValue>, B<setGreaterThanValue>, B<getGreaterThanOrEqualValue>, B<setGreaterThanOrEqualValue>, B<getInfiniteValue>, B<setInfiniteValue>, B<getInfiniteNegativeValue>, B<setInfiniteNegativeValue>, B<getNoDataValue>, B<setNoDataValue>, B<toXMLFileHandle>.

=back



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::DataFormat>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

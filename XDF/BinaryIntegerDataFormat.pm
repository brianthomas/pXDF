
# $Id$

package XDF::BinaryIntegerDataFormat;

# /** COPYRIGHT
#    BinaryIntegerDataFormat.pm Copyright (C) 2000 Brian Thomas,
#    ADC/GSFC-NASA, Code 631, Greenbelt MD, 20771
#@ 
#    This program is free software; it is licensed under the same terms
#    as Perl itself is. Please refer to the file LICENSE which is contained
#    in the distribution that this file came in.
#@ 
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# */

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# XDF::BinaryIntegerDataFormat is the class that describes binary integer 
# numbers.
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
my $Def_BinaryInteger_Bits = 32;
my $Def_BinaryInteger_Signed = 'yes';
my $Class_XML_Node_Name = "binaryInteger";
my @Class_Attributes = qw (
                             signed
                             bits
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

# /** bits
# The number of bits this XDF::BinaryIntegerDataFormat holds.
# */
# /** signed
# Whether this XDF::BinaryIntegerDataFormat holds signed or unsigned
# integer. Takes the values of "yes" or "no".
# */

# Something specific to Perl
# We use the "string" style here
my $Perl_Sprintf_Field_BinaryInteger = 's';
my $Perl_Regex_Field_BinaryInteger = '\.';

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class XML node name.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list containing the names
#  of the attributes of this class.
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

sub _init {
  my ($self) = @_;

  $self->bits($Def_BinaryInteger_Bits);
  $self->signed($Def_BinaryInteger_Signed);
}

# /** bytes
# A convenience method.
# Return the number of bytes this XDF::BinaryIntegerDataFormat holds.
# */
sub bytes { 
  my ($self) = @_; 
  return int($self->bits/8); 
}

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;

  my $width = $self->bytes/4; 

  # we have 32 bit numbers as default
  die "XDF::BinaryInteger cant handle > 32 bit Integer Numbers\n" unless ($width <= 1);

  # we hardwired 'BigEndian" response here. Bad!
  my $symbol = $endian eq 'BigEndian' ? "N" : "V";

  return "$symbol";

}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->bytes;
  my $symbol = $Perl_Regex_Field_BinaryInteger;

  my $notation = '(';
#  my $before_whitespace = $width - 1;
#  $notation .= '\s' . "{0,$before_whitespace}" if($before_whitespace > 0);
  $notation .= $symbol . '{' . $width . '}';
  $notation .= ')';

  return $notation;

}

# returns sprintf field notation
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%';
  my $field_symbol = $Perl_Sprintf_Field_BinaryInteger;

  $notation .= $self->width; 
  $notation .= $field_symbol;

  return $notation;
}

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;
  carp "There is no FORTRAN notation for binary data\n";
}

# Modification History
#
# $Log$
# Revision 1.3  2000/11/29 21:50:07  thomas
# Fix to shrink down inheritance of DataFormat classes.
# No more *Style.pm class files. -b.t.
#
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to DataFormat Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::BinaryIntegerDataFormat - Perl Class for BinaryIntegerDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::BinaryIntegerDataFormat is an abstract class that describes binary integer  numbers. 

XDF::BinaryIntegerDataFormat inherits class and attribute methods of L<XDF::DataFormat>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::BinaryIntegerDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item signed

Whether this XDF::BinaryIntegerDataFormat holds signed or unsignedinteger. Takes the values of "yes" or "no".  

=item bits

The number of bits this XDF::BinaryIntegerDataFormat holds.  

=back

=head2 OTHER Methods

=over 4

=item bytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryIntegerDataFormat holds. 

=item fortranNotation (EMPTY)

The fortran style notation for this object. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::DataFormat>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L< XDF::BinaryIntegerDataFormat>, L< XDF::BinaryIntegerDataType>, L<XDF::DataFormat>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

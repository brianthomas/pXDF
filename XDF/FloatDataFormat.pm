
# $Id$

package XDF::FloatDataFormat;

# /** COPYRIGHT
#    FloatDataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::FloatDataFormat is the class that describes (ASCII) 
# floating point numbers. The format is in FORTRAN 'F' style
# unless the exponent attribute is non-zero. In this case 'E'
# style is used (e.g. scientific notation, ex. '1.01E10').
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

# Stuff specific to Perl
my $Perl_Sprintf_Field_Exponent = 'E';
my $Perl_Regex_Field_Exponent = '[Ee][+-]?';
my $Perl_Regex_Field_Float = '\d';
my $Perl_Regex_Field_Integer = '\d';

my $Class_XML_Node_Name = "float";
my @Class_XML_Attributes = qw (
                             width
                             precision
                             exponent
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};
push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

# /** width
# The entire width of this float field, including the 'E'
# should the 'exponent' attribute be non-zero.
# */

# /** precision
# The precision of this float field from the portion to the
# right of the '.' to the exponent that follows the 'E'.
# */

# /** exponent
# */

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::FloatDataFormat.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FloatDataFormat. 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
}

# 
# SET/GET Methods
#

# /** getWidth
#     Get the width attribute. Width specifies the width
#     of the entire float field (e.g. "1.003" has a width of '5').
#     If the 'exponent' attribute is non-zero then the field
#     is to be written in sci. format so that the width includes 
#     the 'E' and any '.' (e.g. "10.333E-3" has a width of '9'). 
# */
sub getWidth {
   my ($self) = @_;
   return $self->{Width};
}

# /** setWidth
#     Set the width attribute. Width specifies the width
#     of the entire float field (e.g. "1.003" has a width of '5').
#     If the 'exponent' attribute is non-zero then the field
#     is to be written in sci. format so that the width includes 
#     the 'E' and any '.' (e.g. "10.333E-3" has a width of '9'). 
# */
sub setWidth {
   my ($self, $value) = @_;
   $self->{Width} = $value;
}


# /** getPrecision
#     Get the precision attribute. This specifies the width
#     of the field to the *right* of the '.' (e.g. "10.333E-3" 
#     has a precision of '3'; "1.004" has a precision of '3'). 
# */
sub getPrecision {
   my ($self) = @_;
   return $self->{Precision};
}

# /** setPrecision
#     Set the precision attribute. This specifies the width
#     of the field to the *right* of the '.' (e.g. "10.333E-3" 
#     has a precision of '3'; "1.004" has a precision of '3'). 
# */
sub setPrecision {
   my ($self, $value) = @_;
   $self->{Precision} = $value;
}

# /** getExponent
#     Get the exponent attribute. This specifies the width
#     of the field to the *right* of the 'E', e.g. "10.333E-3" 
#     has an exponent (width) of "2". When the exponent is zero,
#     then the number is to be written as in FORTRAN 'F' format
#     instead (e.g. "10.004").  
# */
sub getExponent {
   my ($self) = @_;
   return $self->{Exponent};
}

# /** setExponent
#     Set the exponent attribute. This specifies the width
#     of the field to the *right* of the 'E', e.g. "10.333E-3" 
#     has an exponent (width) of "2". When the exponent is zero,
#     then the number is to be written as in FORTRAN 'F' format
#     instead (e.g. "10.004").  
# */
sub setExponent {
   my ($self, $value) = @_;
   $self->{Exponent} = $value;
}

# /** numOfBytes
# Return the number of bytes this XDF::FloatDataFormat holds.
# */
sub numOfBytes { 
  my ($self) = @_;
  return $self->{Width};
}

# /** getXMLAttributes
#    This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
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

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;
  return "A" . $self->numOfBytes(); 
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->{Width};
  my $precision = $self->{Precision};
  my $exponent = $self->{Exponent};
  my $symbol = $Perl_Regex_Field_Exponent;
  my $notation = '(';

  my $float_symbol = $Perl_Regex_Field_Float;
  my $integer_symbol = $Perl_Regex_Field_Integer;

  my $before_whitespace = $width - $precision - 1;
  $notation .= '\s' . "{0,$before_whitespace}" if($before_whitespace > 0);
  my $leading_length = $width - $precision;
  $notation .= $float_symbol . '{1,' . $leading_length . '}\.';
  $notation .= $float_symbol . '{1,' . $precision. '}';
  $notation .= $symbol;
  $notation .= $integer_symbol . '{1,' . $exponent . '}';

  $notation .= ')';

  return $notation;
}

# returns sprintf field notation
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%';
  my $field_symbol = $Perl_Sprintf_Field_Exponent;

  $notation .= $self->{Width}; 
  $notation .= '.' . $self->{Precision};
  $notation .= $field_symbol;

  return $notation;
}

# Modification History
#
# $Log$
# Revision 1.2  2001/02/15 18:27:37  thomas
# removed fortranNotation from class.
#
# Revision 1.1  2001/02/15 17:51:53  thomas
# Initial Version. Created from ExponentialDataFormat. This
# version has problems w/ some IO routines.
#
#
#

1;



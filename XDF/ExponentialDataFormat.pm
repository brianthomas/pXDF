
# $Id$

package XDF::ExponentialDataFormat;

# /** COPYRIGHT
#    ExponentialDataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::ExponentialDataFormat is the class that describes exponential 
# (ASCII) floating point numbers  (e.g. scientific notation, 1E10).
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
my $Exponent_Size = 2; # hmm. I smell a rat here. This probably isnt correct. 
my $Class_XML_Node_Name = "exponent";
my @Class_Attributes = qw (
                             width
                             precision
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

# /** width
# The entire width of this exponential field, including the 'E'
# and its exponential number.
# */

# /** precision
# The precision of this exponential field from the portion to the
# right of the '.' to the exponent that follows the 'E'.
# */

# Stuff specific to Perl
my $Perl_Sprintf_Field_Exponent = 'e';
my $Perl_Regex_Field_Exponent = '[Ee][+-]?';
my $Perl_Regex_Field_Fixed = '\d';
my $Perl_Regex_Field_Integer = '\d';

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::ExponentialDataFormat.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::ExponentialDataFormat. 
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

# /** bytes
# A convenience method.
# Return the number of bytes this XDF::ExponentialDataFormat holds.
# */
sub bytes { 
  my ($self) = @_; 
  $self->width; 
}

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;
  return "A" . $self->bytes; 
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->width;
  my $precision = $self->precision;
  my $symbol = $Perl_Regex_Field_Exponent;
  my $notation = '(';

  my $fixed_symbol = $Perl_Regex_Field_Fixed;
  my $integer_symbol = $Perl_Regex_Field_Integer;

  my $before_whitespace = $width - $precision - 1;
  $notation .= '\s' . "{0,$before_whitespace}" if($before_whitespace > 0);
  my $leading_length = $width - $precision;
  $notation .= $fixed_symbol . '{1,' . $leading_length . '}\.';
  $notation .= $fixed_symbol . '{1,' . $precision. '}';
  $notation .= $symbol;
  $notation .= $integer_symbol . '{1,' . $Exponent_Size . '}';

  $notation .= ')';

  return $notation;
}

# returns sprintf field notation
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%';
  my $field_symbol = $Perl_Sprintf_Field_Exponent;
  $notation .= $self->width; 
  $notation .= '.' . $self->precision;
  $notation .= $field_symbol;

  return $notation;
}

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;

  my $notation = "E";
  $notation .= $self->width; 
  $notation .= '.' . $self->precision;
  return $notation;
}

# Modification History
#
# $Log$
# Revision 1.1  2000/11/28 21:53:41  thomas
# First version. -b.t.
#
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to DataFormat Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__


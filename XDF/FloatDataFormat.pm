
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
# XDF::FloatDataFormat is the class that describes 
#  floating point numbers written as ASCII.
#  Two different output styles are supported. When the exponent attribute
#  is non-zero, numbers are read/written in FORTRAN 'E' format, in all other 
#  cases an 'F' style read/write format is used.
#  Definitions of number fields are for example:
#@ 
#  130050.0000001E-034
#
#         |----|  |--| 
#           P      X 
#  |-----------------|
#         W
#@
#@
#  where 'W' indicates the width of the 'width' attribute.
#  'P' indicates the width of the 'precision' attribute.
#  'X' indicates the width of the 'exponent' attribute.
#@
# The 'E' only exists when there are a positive non-zero 
#  number of 'X'. For example, a FloatDataFormat with the
#  attributes width=8, precision=5 and exponent=0 would describe
#  the following number: "11.00014" 
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
my $Perl_Sprintf_Field_Float= 'f';
my $Perl_Sprintf_Field_Exponent = 'E';
my $Perl_Regex_Field_Exponent = '[Ee][+-]?';
my $Perl_Regex_Field_Float = '\d';
my $Perl_Regex_Field_Integer = '\d';

my $Class_XML_Node_Name = "float";
my @Local_Class_XML_Attributes = qw (
                             width
                             precision
                             exponent
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
push @Class_Attributes, @Class_XML_Attributes;

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

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FloatDataFormat. 
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
   return $self->{width};
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
   $self->{width} = $value;
}


# /** getPrecision
#     Get the precision attribute. This specifies the width
#     of the field to the *right* of the '.' (e.g. "10.333E-3" 
#     has a precision of '3'; "1.004" has a precision of '3'). 
# */
sub getPrecision {
   my ($self) = @_;
   return $self->{precision};
}

# /** setPrecision
#     Set the precision attribute. This specifies the width
#     of the field to the *right* of the '.' (e.g. "10.333E-3" 
#     has a precision of '3'; "1.004" has a precision of '3'). 
# */
sub setPrecision {
   my ($self, $value) = @_;
   $self->{precision} = $value;
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
   return $self->{exponent};
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
   $self->{exponent} = $value;
}

# /** numOfBytes
# Return the number of bytes this XDF::FloatDataFormat holds.
# */
sub numOfBytes { 
  my ($self) = @_;
  return $self->{width};
}

# /** getXMLAttributes
#    This method returns the XMLAttributes of this class. 
#  */
#sub getXMLAttributes {
#  return \@Class_XML_Attributes;
#}

#
# Private Methods 
#

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();
 
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}


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

sub _outputTemplateNotation {
   my ($self, $endian, $encoding) = @_;
   if (defined $self->{exponent} && $self->{exponent} > 1)
   {
      return "%" . $self->{width} . "\." . $self->{precision} . "g";
   } else { 
      return "%" . $self->{width} . "\." . $self->{precision} . "f"; 
   }
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->{width};
  my $precision = $self->{precision};
  my $exponent = $self->{exponent};
  my $notation = '(';

  my $float_symbol = $Perl_Regex_Field_Float;
  my $integer_symbol = $Perl_Regex_Field_Integer;

  # shouldnt I subtract another '1' for the 'E'??
  my $before_whitespace = $width - $precision - 1 - $exponent;

  $notation .= '\s' . "{0,$before_whitespace}" if($before_whitespace > 0);
  my $leading_length = $width - $precision;
  $notation .= $float_symbol . '{1,' . $leading_length . '}\.';
  $notation .= $float_symbol . '{1,' . $precision. '}';
   
  if ($exponent > 0) {
     $notation .= $Perl_Regex_Field_Exponent;
     $notation .= $integer_symbol . '{1,' . $exponent . '}';
  }

  $notation .= ')';

  return $notation;
}

# returns sprintf field notation
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%';

  $notation .= $self->{width}; 
  $notation .= '.' . $self->{precision};
  my $exponent = $self->{exponent};
  if ($exponent > 0) {
     $notation .= $Perl_Sprintf_Field_Exponent;
  } else {
     $notation .= $Perl_Sprintf_Field_Float;
  }

  return $notation;
}

1;


__END__

=head1 NAME

XDF::FloatDataFormat - Perl Class for FloatDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::FloatDataFormat is the class that describes   floating point numbers written as ASCII.   Two different output styles are supported. When the exponent attribute  is non-zero, numbers are read/written in FORTRAN 'E' format, in all other   cases an 'F' style read/write format is used.   Definitions of number fields are for example:  
  130050.0000001E-034         |----|  |--|            P      X   |-----------------|         W 
 
  where 'W' indicates the width of the 'width' attribute.   'P' indicates the width of the 'precision' attribute.   'X' indicates the width of the 'exponent' attribute.  
 The 'E' only exists when there are a positive non-zero   number of 'X'. For example, a FloatDataFormat with the  attributes width=8, precision=5 and exponent=0 would describe  the following number: "11.00014" 

XDF::FloatDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::FloatDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::FloatDataFormat.

=over 4

=item getWidth (EMPTY)

Get the width attribute. Width specifies the widthof the entire float field (e.g. "1.003" has a width of '5'). If the 'exponent' attribute is non-zero then the fieldis to be written in sci. format so that the width includes the 'E' and any '.' (e.g. "10.333E-3" has a width of '9').  

=item setWidth ($value)

Set the width attribute. Width specifies the widthof the entire float field (e.g. "1.003" has a width of '5'). If the 'exponent' attribute is non-zero then the fieldis to be written in sci. format so that the width includes the 'E' and any '.' (e.g. "10.333E-3" has a width of '9').  

=item getPrecision (EMPTY)

Get the precision attribute. This specifies the widthof the field to the *right* of the '.' (e.g. "10.333E-3" has a precision of '3'; "1.004" has a precision of '3').  

=item setPrecision ($value)

Set the precision attribute. This specifies the widthof the field to the *right* of the '.' (e.g. "10.333E-3" has a precision of '3'; "1.004" has a precision of '3').  

=item getExponent (EMPTY)

Get the exponent attribute. This specifies the widthof the field to the *right* of the 'E', e.g. "10.333E-3" has an exponent (width) of "2". When the exponent is zero,then the number is to be written as in FORTRAN 'F' formatinstead (e.g. "10.004").   

=item setExponent ($value)

Set the exponent attribute. This specifies the widthof the field to the *right* of the 'E', e.g. "10.333E-3" has an exponent (width) of "2". When the exponent is zero,then the number is to be written as in FORTRAN 'F' formatinstead (e.g. "10.004").   

=item numOfBytes (EMPTY)

Return the number of bytes this XDF::FloatDataFormat holds.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::FloatDataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FloatDataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::DataFormat>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

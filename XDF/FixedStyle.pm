
# $Id$

package XDF::FixedStyle;

# /** COPYRIGHT
#    FixedStyle.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::FixedStyle is an abstract class that describes (ASCII) 
# fixed (floating point) numbers.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::FixedDataFormat
# XDF::FixedDataType
# */

use XDF::Object;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my $Class_XML_Node_Name = "fixed";
my @Class_Attributes = qw (
                             width
                             precision
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

# /** width
# The entire width of this fixed field.
# */

# /** precision
# The precision of this fixed field which is the number of digits
# to the right of the '.'.
# */

# Something specific to Perl
my $Perl_Sprintf_Field_Fixed = 'f';
my $Perl_Regex_Field_Fixed = '\d';

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::FixedStyle.
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FixedStyle. 
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
   $self->width(0);
   $self->precision(0);
}

# /** bytes
# A convenience method.
# Return the number of bytes this XDF::FixedStyle holds.
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
  my $symbol = $Perl_Regex_Field_Fixed;

  my $notation = '(';

  my $before_whitespace = $width - $precision - 1;
  $notation .= '\s' . "{0,$before_whitespace}" if($before_whitespace > 0);
  my $leading_length = $width - $precision;
  $notation .= '[+-]?' . $symbol . '{1,' . $leading_length . '}\.';
  $notation .= $symbol . '{1,' . $precision. '}';
  $notation .= ')';

  return $notation;
}

# returns sprintf field notation
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%';
  my $field_symbol = $Perl_Sprintf_Field_Fixed;
  my $precision = $self->precision;
  $notation .= $self->width; 
  $notation .= '.' . $precision;
  $notation .= $field_symbol;

  return $notation;
}

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;

  my $notation = "F";
  $notation .= $self->width;
  $notation .= '.' . $self->precision;
  return $notation;
}


1;


__END__

=head1 NAME

XDF::FixedStyle - Perl Class for FixedStyle

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::FixedStyle is an abstract class that describes (ASCII)  fixed (floating point) numbers. 

XDF::FixedStyle inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FixedStyle.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::FixedStyle.  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::FixedStyle.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item width

The entire width of this fixed field.  

=item precision

The precision of this fixed field which is the number of digitsto the right of the '.'.  

=back

=head2 OTHER Methods

=over 4

=item bytes (EMPTY)

A convenience method. Return the number of bytes this XDF::FixedStyle holds. 

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

XDF::FixedStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::FixedStyle inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::FixedDataFormat>, L< XDF::FixedDataType>, L<XDF::Object>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

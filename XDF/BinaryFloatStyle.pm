
# $Id$

# /** COPYRIGHT
#    BinaryFloatStyle.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::BinaryFloatStyle is an abstract class that describes binary floating 
# point numbers.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::BinaryFloatDataType
# XDF::BinaryFloatDataFormat
# */

package XDF::BinaryFloatStyle;

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Def_BinaryFloat_Bits = 32;
my $Class_XML_Node_Name = "binaryFloat";
my @Class_Attributes = qw (
                             bits
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# /** bits
# The number of bits this XDF::BinaryFloatStyle holds.
# */

# Something specific to Perl

# We use the "string" stuff here
my $Perl_Sprintf_Field_BinaryFloat = 's';
my $Perl_Regex_Field_BinaryFloat = '\.';

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
  $self->bits($Def_BinaryFloat_Bits);
}

# /** bytes
# A convenience method.
# Return the number of bytes this XDF::BinaryFloatStyle holds.
# */
sub bytes { 
  my ($self) = @_; 
  return int($self->bits/8); 
}

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;

  my $width = $self->bytes/4; 

  # we have 64 bit numbers as upper limit on size
  die "XDF::BinaryFloatStyle cant handle > 64 bit Numbers\n" unless ($width <= 2);

  my $symbol = "d"; # we always use double to prevent perl rounding 
                    # that can occur for using the 32-bit "f" 
  return "$symbol";

}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->bytes;
  my $symbol = $Perl_Regex_Field_BinaryFloat;

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
  my $field_symbol = $Perl_Sprintf_Field_BinaryFloat;

  $notation .= $self->bytes;
  $notation .= $field_symbol;

  return $notation;
}

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;
  carp "There is no FORTRAN representation for binary data\n";
}

# Modification History
#
# $Log$
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::BinaryFloatStyle - Perl Class for BinaryFloatStyle

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::BinaryFloatStyle is an abstract class that describes binary floating  point numbers. 

XDF::BinaryFloatStyle inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::BinaryFloatStyle.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item bits

The number of bits this XDF::BinaryFloatStyle holds.  

=back

=head2 OTHER Methods

=over 4

=item bytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryFloatStyle holds. 

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

XDF::BinaryFloatStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::BinaryFloatStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L< XDF::BinaryFloatDataType>, L< XDF::BinaryFloatDataFormat>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut


# $Id$

package XDF::StringStyle;

# /** COPYRIGHT
#    StringStyle.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::StringStyle is an abstract class that describes string data.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::StringDataFormat
# XDF::StringDataType
# */


use XDF::Object;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my $Class_XML_Node_Name = "string";
my @Class_Attributes = qw (
                             length
                          );

# /** length
# The width of this string field in characters.
# Normally this translates to the number of bytes the object holds,
# however, note that the encoding of the data is important. When
# the encoding is UTF-16, then the number of bytes effectively is 2x $obj->length.
# */

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

# Something specific to Perl
my $Perl_Sprintf_Field_String = 's';
my $Perl_Regex_Field_String = '.';

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
  my ($self)  = @_;
  $self->length(0);

}

# /** bytes
# A convenience method.
# Return the number of bytes this XDF::StringStyle holds.
# */
sub bytes { 
  my ($self) = @_; 
  $self->length; 
}

sub _templateNotation {
  my ($self) = @_;
  return "A" . $self->bytes;
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->length;
  my $symbol = $Perl_Regex_Field_String;

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
  $notation .= $self->length; 
  $notation .= $Perl_Sprintf_Field_String;

  return $notation;
}

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;

  my $notation = "A";
  $notation .= $self->length;
  return $notation;
}

1;


__END__

=head1 NAME

XDF::StringStyle - Perl Class for StringStyle

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::StringStyle is an abstract class that describes string data. 

XDF::StringStyle inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::StringStyle.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item length

The width of this string field in characters. Normally this translates to the number of bytes the object holds,however, note that the encoding of the data is important. Whenthe encoding is UTF-16, then the number of bytes effectively is 2x $obj->length.  

=back

=head2 OTHER Methods

=over 4

=item bytes (EMPTY)

A convenience method. Return the number of bytes this XDF::StringStyle holds. 

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

XDF::StringStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::StringStyle inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::StringDataFormat>, L< XDF::StringDataType>, L<XDF::Object>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

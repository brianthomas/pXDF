
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

# Stuff specific to Perl
my $Perl_Sprintf_Field_Exponent = 'E';
my $Perl_Regex_Field_Exponent = '[Ee][+-]?';
my $Perl_Regex_Field_Fixed = '\d';
my $Perl_Regex_Field_Integer = '\d';

my $Class_XML_Node_Name = "exponential";
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
# The entire width of this exponential field, including the 'E'
# and its exponential number.
# */

# /** precision
# The precision of this exponential field from the portion to the
# right of the '.' to the exponent that follows the 'E'.
# */

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

# 
# SET/GET Methods
#

# /** getWidth
#     Get the width attribute. Width specifies the width
#     of the entire exponential field including the 'E' and
#     any '.', e.g. "10.333E-3" has a width of "9". 
# */
sub getWidth {
   my ($self) = @_;
   return $self->{Width};
}

# /** setWidth
#     Set the width attribute. Width specifies the width
#     of the entire exponential field including the 'E' and
#     any '.', e.g. "10.333E-3" has a width of "9". 
# */
sub setWidth {
   my ($self, $value) = @_;
   $self->{Width} = $value;
}


# /** getPrecision
#     Get the precision attribute. This specifies the width
#     of the field to the *right* of the '.', e.g. "10.333E-3" 
#     has a precision of "3". 
# */
sub getPrecision {
   my ($self) = @_;
   return $self->{Precision};
}

# /** setPrecision
#     Set the precision attribute. This specifies the width
#     of the field to the *right* of the '.', e.g. "10.333E-3" 
#     has a precision of "3". 
# */
sub setPrecision {
   my ($self, $value) = @_;
   $self->{Precision} = $value;
}

# /** getExponent
#     Get the exponent attribute. This specifies the width
#     of the field to the *right* of the 'E', e.g. "10.333E-3" 
#     has an exponent (width) of "2". 
# */
sub getExponent {
   my ($self) = @_;
   return $self->{Exponent};
}

# /** setExponent
#     Set the exponent attribute. This specifies the width
#     of the field to the *right* of the 'E', e.g. "10.333E-3" 
#     has an exponent (width) of "2". 
# */
sub setExponent {
   my ($self, $value) = @_;
   $self->{Exponent} = $value;
}

# /** getBytes
# A convenience method.
# Return the number of bytes this XDF::ExponentialDataFormat holds.
# */
sub getBytes { 
  my ($self) = @_;
  return $self->{Width};
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

  my $notation = "E";
  $notation .= $self->{Width};
  $notation .= '.' . $self->{Precision};
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

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;
  return "A" . $self->getBytes(); 
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->{Width};
  my $precision = $self->{Precision};
  my $exponent = $self->{Exponent};
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
# Revision 1.4  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.3  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.2  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
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

=head1 NAME

XDF::ExponentialDataFormat - Perl Class for ExponentialDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::ExponentialDataFormat is the class that describes exponential  (ASCII) floating point numbers  (e.g. scientific notation, 1E10). 

XDF::ExponentialDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::ExponentialDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::ExponentialDataFormat. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::ExponentialDataFormat. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

 

=item push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

 

=item # /** width

 

=item # The entire width of this exponential field, including the 'E'

 

=item # and its exponential number.

 

=item # */

 

=item # /** precision

 

=item # The precision of this exponential field from the portion to the

 

=item # right of the '.' to the exponent that follows the 'E'.

 

=item # */

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** classXMLNodeName

 

=item # This method returns the class node name of XDF::ExponentialDataFormat.

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classXMLNodeName {

 

=item }

 

=item # /** classAttributes

 

=item #  This method returns a list reference containing the names

 

=item #  of the class attributes of XDF::ExponentialDataFormat. 

 

=item #  This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classAttributes {

 

=item }

 

=item # 

 

=item # SET/GET Methods

 

=item #

 

=item # /** getWidth

 

=item #     Get the width attribute. Width specifies the width

 

=item #     of the entire exponential field including the 'E' and

 

=item #     any '.', e.g. "10.333E-3" has a width of "9". 

 

=item # */

 

=item sub getWidth {

 

=item return $self->{Width};

 

=item }

 

=item # /** setWidth

 

=item #     Set the width attribute. Width specifies the width

 

=item #     of the entire exponential field including the 'E' and

 

=item #     any '.', e.g. "10.333E-3" has a width of "9". 

 

=item # */

 

=item sub setWidth {

 

=item $self->{Width} = $value;

 

=item }

 

=item # /** getPrecision

 

=item #     Get the precision attribute. This specifies the width

 

=item #     of the field to the *right* of the '.', e.g. "10.333E-3" 

 

=item #     has a precision of "3". 

 

=item # */

 

=item sub getPrecision {

 

=item return $self->{Precision};

 

=item }

 

=item # /** setPrecision

 

=item #     Set the precision attribute. This specifies the width

 

=item #     of the field to the *right* of the '.', e.g. "10.333E-3" 

 

=item #     has a precision of "3". 

 

=item # */

 

=item sub setPrecision {

 

=item $self->{Precision} = $value;

 

=item }

 

=item # /** getExponent

 

=item #     Get the exponent attribute. This specifies the width

 

=item #     of the field to the *right* of the 'E', e.g. "10.333E-3" 

 

=item #     has an exponent (width) of "2". 

 

=item # */

 

=item sub getExponent {

 

=item return $self->{Exponent};

 

=item }

 

=item # /** setExponent

 

=item #     Set the exponent attribute. This specifies the width

 

=item #     of the field to the *right* of the 'E', e.g. "10.333E-3" 

 

=item #     has an exponent (width) of "2". 

 

=item # */

 

=item sub setExponent {

 

=item $self->{Exponent} = $value;

 

=item }

 

=item # /** getBytes

 

=item # A convenience method.

 

=item # Return the number of bytes this XDF::ExponentialDataFormat holds.

 

=item # */

 

=item sub getBytes { 

 

=item return $self->{Width};

 

=item }

 

=item # /** getXMLAttributes

 

=item #      This method returns the XMLAttributes of this class. 

 

=item #  */

 

=item sub getXMLAttributes {

 

=item }

 

=item #

 

=item # Other Public Methods

 

=item #

 

=item # /** fortranNotation

 

=item # The fortran style notation for this object.

 

=item # */

 

=item sub fortranNotation {

 

=item my $notation = "E";

 

=item $notation .= $self->{Width};

 

=item $notation .= '.' . $self->{Precision};

 

=item return $notation;

 

=item }

 

=item #

 

=item # Private Methods 

 

=item #

 

=item # This is called when we cant find any defined method

 

=item # exists already. Used to handle general purpose set/get

 

=item # methods for our attributes (object fields).

 

=item sub AUTOLOAD {

 

=item my ($self,$val) = @_;

 

=back

=head2 OTHER Methods

=over 4

=item getWidth (EMPTY)

Get the width attribute. Width specifies the widthof the entire exponential field including the 'E' andany '.', e.g. "10.333E-3" has a width of "9". 

=item setWidth ($value)

Set the width attribute. Width specifies the widthof the entire exponential field including the 'E' andany '.', e.g. "10.333E-3" has a width of "9". 

=item getPrecision (EMPTY)

Get the precision attribute. This specifies the widthof the field to the *right* of the '.', e.g. "10.333E-3" has a precision of "3". 

=item setPrecision ($value)

Set the precision attribute. This specifies the widthof the field to the *right* of the '.', e.g. "10.333E-3" has a precision of "3". 

=item getExponent (EMPTY)

Get the exponent attribute. This specifies the widthof the field to the *right* of the 'E', e.g. "10.333E-3" has an exponent (width) of "2". 

=item setExponent ($value)

Set the exponent attribute. This specifies the widthof the field to the *right* of the 'E', e.g. "10.333E-3" has an exponent (width) of "2". 

=item getBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::ExponentialDataFormat holds. 

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

XDF::ExponentialDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::ExponentialDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<getLessThanValue>, B<setLessThanValue>, B<getLessThanOrEqualValue>, B<setLessThanOrEqualValue>, B<getGreaterThanValue>, B<setGreaterThanValue>, B<getGreaterThanOrEqualValue>, B<setGreaterThanOrEqualValue>, B<getInfiniteValue>, B<setInfiniteValue>, B<getInfiniteNegativeValue>, B<setInfiniteNegativeValue>, B<getNoDataValue>, B<setNoDataValue>, B<toXMLFileHandle>.

=back



=over 4

XDF::ExponentialDataFormat inherits the following instance methods of L<XDF::BaseObject>:
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

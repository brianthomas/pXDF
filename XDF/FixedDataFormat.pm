
# $Id$

package XDF::FixedDataFormat;

# /** COPYRIGHT
#    FixedDataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::FixedDataFormat is the class that describes (ASCII) 
# fixed (floating point) numbers.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::DataFormat
# */

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::DataFormat
@ISA = ("XDF::DataFormat");

# CLASS DATA
my $Class_XML_Node_Name = "fixed";
my @Class_XML_Attributes = qw (
                             width
                             precision
                          );
my @Class_Attributes = (); 

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};
push @Class_Attributes, @{&XDF::DataFormat::getXMLAttributes};

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
# This method returns the class node name of XDF::FixedDataFormat.
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FixedDataFormat. 
# */
sub classAttributes {
  \@Class_Attributes;
}

# 
# SET/GET Methods
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


# /** getPrecision
# */
sub getPrecision {
   my ($self) = @_;
   return $self->{Precision};
}

# /** setPrecision
#     Set the precision attribute. 
# */
sub setPrecision {
   my ($self, $value) = @_;
   $self->{Precision} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

# /** getBytes
# A convenience method.
# Return the number of bytes this XDF::FixedDataFormat holds.
# */
sub getBytes {  
  my ($self) = @_;
  $self->{Width};
}

#
# Other Public Methods
#

# /** fortranNotation
# The fortran style notation for this object.
# */
sub fortranNotation {
  my ($self) = @_;

  my $notation = "F";
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

sub _init {
   my ($self) = @_;
   $self->{Width} = 0;
   $self->{Precision} = 0;
}

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;
  return "A" . $self->getBytes(); 
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
  $notation .= $self->{Width}; 
  $notation .= '.' . $self->{Precision};
  $notation .= $field_symbol;

  return $notation;
}


# Modification History
#
# $Log$
# Revision 1.5  2000/12/14 22:11:26  thomas
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
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::FixedDataFormat - Perl Class for FixedDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::FixedDataFormat is the class that describes (ASCII)  fixed (floating point) numbers. 

XDF::FixedDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FixedDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::FixedDataFormat.  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes of XDF::FixedDataFormat.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

 

=item push @Class_Attributes, @{&XDF::DataFormat::getXMLAttributes};

 

=item # /** width

 

=item # The entire width of this fixed field.

 

=item # */

 

=item # /** precision

 

=item # The precision of this fixed field which is the number of digits

 

=item # to the right of the '.'.

 

=item # */

 

=item # Something specific to Perl

 

=item my $Perl_Sprintf_Field_Fixed = 'f';

 

=item my $Perl_Regex_Field_Fixed = '\d';

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** classXMLNodeName

 

=item # This method takes no arguments may not be changed. 

 

=item # This method returns the class node name of XDF::FixedDataFormat.

 

=item # */

 

=item sub classXMLNodeName {

 

=item }

 

=item # /** classAttributes

 

=item #  This method takes no arguments may not be changed. 

 

=item #  This method returns a list reference containing the names

 

=item #  of the class attributes of XDF::FixedDataFormat. 

 

=item # */

 

=item sub classAttributes {

 

=item }

 

=item # 

 

=item # SET/GET Methods

 

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

 

=item # /** getPrecision

 

=item # */

 

=item sub getPrecision {

 

=item return $self->{Precision};

 

=item }

 

=item # /** setPrecision

 

=item #     Set the precision attribute. 

 

=item # */

 

=item sub setPrecision {

 

=item $self->{Precision} = $value;

 

=item }

 

=item # /** getXMLAttributes

 

=item #      This method returns the XMLAttributes of this class. 

 

=item #  */

 

=item sub getXMLAttributes {

 

=item }

 

=item # /** getBytes

 

=item # A convenience method.

 

=item # Return the number of bytes this XDF::FixedDataFormat holds.

 

=item # */

 

=item sub getBytes {  

 

=back

=head2 OTHER Methods

=over 4

=item getWidth (EMPTY)



=item setWidth ($value)

Set the width attribute. 

=item getPrecision (EMPTY)



=item setPrecision ($value)

Set the precision attribute. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item getBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::FixedDataFormat holds. 

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

XDF::FixedDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FixedDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<getLessThanValue>, B<setLessThanValue>, B<getLessThanOrEqualValue>, B<setLessThanOrEqualValue>, B<getGreaterThanValue>, B<setGreaterThanValue>, B<getGreaterThanOrEqualValue>, B<setGreaterThanOrEqualValue>, B<getInfiniteValue>, B<setInfiniteValue>, B<getInfiniteNegativeValue>, B<setInfiniteNegativeValue>, B<getNoDataValue>, B<setNoDataValue>, B<toXMLFileHandle>.

=back



=over 4

XDF::FixedDataFormat inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::DataFormat>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut


# $Id$

package XDF::StringDataFormat;

# /** COPYRIGHT
#    StringDataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::StringDataFormat is the class that describes string data.
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
my $Class_XML_Node_Name = "string";
my @Class_XML_Attributes = qw (
                             length
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# /** length
# The width of this string field in characters.
# Normally this translates to the number of bytes the object holds,
# however, note that the encoding of the data is important. When
# the encoding is UTF-16, then the number of bytes effectively is 2x $obj->length.
# */

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};
push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

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

#
# Get/Set Methods
#

# /** getLength
# */
sub getLength {
   my ($self) = @_;
   return $self->{Length};
}

# /** setLength
#     Set the length attribute. 
# */
sub setLength {
   my ($self, $value) = @_;
   $self->{Length} = $value;
}

# /** numOfBytes
# A convenience method.
# Return the number of bytes this XDF::StringDataFormat holds.
# */
sub numOfBytes {
  my ($self) = @_;
  $self->getLength();
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

  my $notation = "A";
  $notation .= $self->getLength();
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
  my ($self)  = @_;
  $self->setLength(0);

}

sub _templateNotation {
  my ($self) = @_;
  return "A" . $self->numOfBytes();
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
  $notation .= $self->getLength; 
  $notation .= $Perl_Sprintf_Field_String;

  return $notation;
}

# Modification History
#
# $Log$
# Revision 1.8  2001/02/15 18:27:37  thomas
# removed fortranNotation from class.
#
# Revision 1.7  2001/02/15 17:50:30  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.6  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
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
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to DataFormat Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::StringDataFormat - Perl Class for StringDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::StringDataFormat is the class that describes string data. 

XDF::StringDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::StringDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # /** length

 

=item # The width of this string field in characters.

 

=item # Normally this translates to the number of bytes the object holds,

 

=item # however, note that the encoding of the data is important. When

 

=item # the encoding is UTF-16, then the number of bytes effectively is 2x $obj->length.

 

=item # */

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

 

=item push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

 

=item # Something specific to Perl

 

=item my $Perl_Sprintf_Field_String = 's';

 

=item my $Perl_Regex_Field_String = '.';

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** classXMLNodeName

 

=item # This method returns the class XML node name.

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classXMLNodeName {

 

=item }

 

=item # /** classAttributes

 

=item #  This method returns a list containing the names

 

=item #  of the attributes of this class.

 

=item #  This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classAttributes {

 

=item }

 

=item #

 

=item # Get/Set Methods

 

=item #

 

=item # /** getLength

 

=item # */

 

=item sub getLength {

 

=item return $self->{Length};

 

=item }

 

=item # /** setLength

 

=item #     Set the length attribute. 

 

=item # */

 

=item sub setLength {

 

=item $self->{Length} = $value;

 

=item }

 

=item # /** numOfBytes

 

=item # A convenience method.

 

=item # Return the number of bytes this XDF::StringDataFormat holds.

 

=item # */

 

=item sub numOfBytes {

 

=back

=head2 OTHER Methods

=over 4

=item getLength (EMPTY)



=item setLength ($value)

Set the length attribute. 

=item numOfBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::StringDataFormat holds. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

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

XDF::StringDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::StringDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<getLessThanValue>, B<setLessThanValue>, B<getLessThanOrEqualValue>, B<setLessThanOrEqualValue>, B<getGreaterThanValue>, B<setGreaterThanValue>, B<getGreaterThanOrEqualValue>, B<setGreaterThanOrEqualValue>, B<getInfiniteValue>, B<setInfiniteValue>, B<getInfiniteNegativeValue>, B<setInfiniteNegativeValue>, B<getNoDataValue>, B<setNoDataValue>, B<toXMLFileHandle>.

=back



=over 4

XDF::StringDataFormat inherits the following instance methods of L<XDF::BaseObject>:
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

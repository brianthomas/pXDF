
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
my @Local_Class_XML_Attributes = qw (
                             length
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
  return $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
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
# Get/Set Methods
#

# /** getLength
# Get the width of this string field in characters.
# Normally this translates to the number of bytes the object holds,
# however, note that the encoding of the data is important. When
# the encoding is UTF-16, then the number of bytes effectively is 2x $obj->length.
# */
sub getLength {
   my ($self) = @_;
   return $self->{length};
}

# /** setLength
#     Set the length attribute. 
# */
sub setLength {
   my ($self, $value) = @_;
   $self->{length} = $value;
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
#sub getXMLAttributes { 
#  return \@Class_XML_Attributes;
#}

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

  $self->SUPER::_init();

  $self->setLength(0);

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _templateNotation {
  my ($self) = @_;
  return "A" . $self->numOfBytes();
}

sub _outputTemplateNotation {
  my ($self, $endian, $encoding) = @_;
  return $self->_templateNotation();
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
# Revision 1.16  2001/08/13 20:56:37  thomas
# updated documentation via utils/makeDoc.pl for the release.
#
# Revision 1.15  2001/08/13 19:50:16  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.14  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.13  2001/05/23 17:24:14  thomas
# change to allow right-justification of ASCII
# numbers.
#
# Revision 1.12  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.11  2001/04/17 18:55:20  thomas
# Properly calling superclass init now
#
# Revision 1.10  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.9  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
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


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::StringDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::StringDataFormat.

=over 4

=item getLength (EMPTY)

Get the width of this string field in characters. Normally this translates to the number of bytes the object holds,however, note that the encoding of the data is important. Whenthe encoding is UTF-16, then the number of bytes effectively is 2x $obj->length.  

=item setLength ($value)

Set the length attribute.  

=item numOfBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::StringDataFormat holds.  

=item fortranNotation (EMPTY)

The fortran style notation for this object.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::StringDataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::StringDataFormat inherits the following instance (object) methods of L<XDF::DataFormat>:
B<toXMLFileHandle>.

=back



=over 4

XDF::StringDataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLString>, B<toXMLFile>.

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

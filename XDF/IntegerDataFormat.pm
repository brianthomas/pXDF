
# $Id$

package XDF::IntegerDataFormat;

# /** COPYRIGHT
#    IntegerDataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::IntegerDataFormat is the class that describes (ASCII) 
# integer numbers.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# */

use XDF::Utility;
use XDF::DataFormat;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::DataFormat
@ISA = ("XDF::DataFormat");

# CLASS DATA
my $Class_XML_Node_Name = "integer";
my @Class_XML_Attributes = qw (
                             type
                             width
                          );
my @Class_Attributes = ();

# perhaps saves cpu use to grab once and store.
my $Integer_Type_Decimal = &XDF::Constants::INTEGER_TYPE_DECIMAL;
my $Integer_Type_Octal = &XDF::Constants::INTEGER_TYPE_OCTAL;
my $Integer_Type_Hex = &XDF::Constants::INTEGER_TYPE_HEX;

# Something specific to Perl
# This is used by the 'decimal' type
my $Perl_Sprintf_Field_Integer = 'd';

# using long octal format. Technically, should be an error
# to have Octal on Exponent and Fixed formats but we will 
# return the value as regular number 
my $Octal_Perl_Sprintf_Field_Integer = 'lo';

# using long hex format. Should be an error   
my $Hex_Perl_Sprintf_Field_Integer = 'lx';
my $Perl_Regex_Field_Integer = '\d';

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};
push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::BinaryFloatField.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::BinaryFloatField. 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
}

#
# Get/Set Methods
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

# /** getType
# */
sub getType {
   my ($self) = @_;
   return $self->{Type};
}

# /** setType
#     Set the type attribute. 
# */
sub setType {
   my ($self, $value) = @_;

   carp "Cant set type to $value, not allowed \n"
      unless (&XDF::Utility::isValidIntegerType($value));
   $self->{Type} = $value;
}

# /** numOfBytes
# A convenience method.
# Return the number of bytes this XDF::BinaryFloatField holds.
# */
sub numOfBytes { 
  my ($self) = @_;
  $self->getWidth();
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
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

sub _init {
  my ($self) = @_;

  $self->{Width} = 0;
  $self->{Type} = $Integer_Type_Decimal;

}

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;
  return "A" . $self->{Width};
}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->width;
  my $symbol = $Perl_Regex_Field_Integer;

  # treat the read as a string unless decimal
  $symbol = '\.' unless ($self->{Type} eq $Integer_Type_Decimal);

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
  my $field_symbol = $Perl_Sprintf_Field_Integer;

  $field_symbol = $Octal_Perl_Sprintf_Field_Integer if ($self->getType() eq $Integer_Type_Octal );
  $field_symbol = $Hex_Perl_Sprintf_Field_Integer if ($self->getType() eq $Integer_Type_Hex );

  $notation .= $self->{Width}; 
  $notation .= $field_symbol;

  return $notation;
}

# Modification History
#
# $Log$
# Revision 1.10  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.9  2001/03/09 21:55:50  thomas
# Moded class data for Integer types to Constants class. Added
# utility check for isValidIntegertype on set type method.
#
# Revision 1.8  2001/02/15 18:27:37  thomas
# removed fortranNotation from class.
#
# Revision 1.7  2001/02/15 17:50:31  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.6  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.5  2000/12/14 22:11:25  thomas
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

XDF::IntegerDataFormat - Perl Class for IntegerDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::IntegerDataFormat is the class that describes (ASCII)  integer numbers. 

XDF::IntegerDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::IntegerDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::BinaryFloatField. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::BinaryFloatField. This method takes no arguments may not be changed.  

=back

=head2 INSTANCE Methods

The following instance methods are defined for XDF::IntegerDataFormat.
=over 4

=item getWidth (EMPTY)

 

=item setWidth ($value)

Set the width attribute.  

=item getType (EMPTY)

 

=item setType ($value)

Set the type attribute.  

=item numOfBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryFloatField holds.  

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

=head2 INHERITED INSTANCE Methods



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>. 

=back



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<toXMLFileHandle>. 

=back



=over 4

XDF::IntegerDataFormat inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>. 

=back

=head1 SEE ALSO

L<XDF::Utility>, L<XDF::DataFormat> 

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

# /** COPYRIGHT
#    BinaryFloatDataFormat.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::BinaryFloatDataFormat is the class that describes binary floating 
# point numbers.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# */

package XDF::BinaryFloatDataFormat;

use XDF::DataFormat;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::DataFormat
@ISA = ("XDF::DataFormat");

# CLASS DATA
my $Def_BinaryFloat_Bits = 32;
my $Class_XML_Node_Name = "binaryFloat";
my @Class_XML_Attributes = qw (
                             bits
                          );
my @Class_Attributes = ();

# add in XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

# add in super class XML attributes
push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

# /** bits
# The number of bits this XDF::BinaryFloatDataFormat holds.
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

#
# GET/SET methods 
#


# /** getBits
# */
sub getBits {
   my ($self) = @_;
   return $self->{Bits};
}

# /** setBits
#     Set the (number of) bits attribute. 
# */
sub setBits {
   my ($self, $value) = @_;

   carp "Cant set bits to value other than 32 or 64 \n" 
      unless (defined $value && ($value == 64 or $value == 32));
   $self->{Bits} = $value;
}

# /** numOfBytes
# A convenience method.
# Return the number of bytes this XDF::BinaryFloatDataFormat holds.
# */
sub numOfBytes { 
  my ($self) = @_; 
  return int(($self->{Bits})/8);
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Private/Protected Methods 
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
  $self->{Bits} = $Def_BinaryFloat_Bits;
}

sub _templateNotation {
  my ($self, $endian, $encoding) = @_;

  my $width = $self->getBits(); 

  # we have 64 bit numbers as upper limit on size
  die "XDF::BinaryFloatDataFormat cant handle > 64 bit Numbers\n" unless ($width <= 64);

  my $symbol = "d"; # we *should* always use double to prevent perl rounding 
                    # that can occur for using the 32-bit "f" 

  # hurm, IF we do this there will be rounding. 
  $symbol = 'f' if ($width <= 32);
  return "$symbol";

}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->numOfBytes();
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
#  my ($self) = @_;
#
#  my $notation = '%';
#  my $field_symbol = $Perl_Sprintf_Field_BinaryFloat;
#
#  $notation .= $self->numOfBytes();
#  $notation .= $field_symbol;
#
#  return $notation;
   carp "_sprintfNotation shouldnt be called for binary numbers\n";
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
# Revision 1.8  2001/02/15 17:50:31  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.7  2001/01/04 22:21:41  thomas
# Bug fix. Was writing double precision when declared
# number of bits was 32 (!). Also fix to prevent
# setting number of bits to value other than 32 or
# 64. -b.t.
#
# Revision 1.6  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.5  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.4  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.3  2000/11/29 21:50:07  thomas
# Fix to shrink down inheritance of DataFormat classes.
# No more *Style.pm class files. -b.t.
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

XDF::BinaryFloatDataFormat - Perl Class for BinaryFloatDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::BinaryFloatDataFormat is the class that describes binary floating  point numbers. 

XDF::BinaryFloatDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::BinaryFloatDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # add in XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

 

=item # add in super class XML attributes

 

=item push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

 

=item # /** bits

 

=item # The number of bits this XDF::BinaryFloatDataFormat holds.

 

=item # */

 

=item # Something specific to Perl

 

=item # We use the "string" stuff here

 

=item my $Perl_Sprintf_Field_BinaryFloat = 's';

 

=item my $Perl_Regex_Field_BinaryFloat = '\.';

 

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

 

=item # GET/SET methods 

 

=item #

 

=item # /** getBits

 

=item # */

 

=item sub getBits {

 

=item return $self->{Bits};

 

=item }

 

=item # /** setBits

 

=item #     Set the (number of) bits attribute. 

 

=item # */

 

=item sub setBits {

 

=item $self->{Bits} = $value;

 

=item }

 

=item # /** numOfBytes

 

=item # A convenience method.

 

=item # Return the number of bytes this XDF::BinaryFloatDataFormat holds.

 

=item # */

 

=item sub numOfBytes { 

 

=back

=head2 OTHER Methods

=over 4

=item getBits (EMPTY)



=item setBits ($value)

Set the (number of) bits attribute. 

=item numOfBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryFloatDataFormat holds. 

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

XDF::BinaryFloatDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::BinaryFloatDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<getLessThanValue>, B<setLessThanValue>, B<getLessThanOrEqualValue>, B<setLessThanOrEqualValue>, B<getGreaterThanValue>, B<setGreaterThanValue>, B<getGreaterThanOrEqualValue>, B<setGreaterThanOrEqualValue>, B<getInfiniteValue>, B<setInfiniteValue>, B<getInfiniteNegativeValue>, B<setInfiniteNegativeValue>, B<getNoDataValue>, B<setNoDataValue>, B<toXMLFileHandle>.

=back



=over 4

XDF::BinaryFloatDataFormat inherits the following instance methods of L<XDF::BaseObject>:
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

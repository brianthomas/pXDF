
# $Id$

package XDF::BinaryIntegerDataFormat;

# /** COPYRIGHT
#    BinaryIntegerDataFormat.pm Copyright (C) 2000 Brian Thomas,
#    ADC/GSFC-NASA, Code 631, Greenbelt MD, 20771
#@ 
#    This program is free software; it is licensed under the same terms
#    as Perl itself is. Please refer to the file LICENSE which is contained
#    in the distribution that this file came in.
#@ 
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# */

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# XDF::BinaryIntegerDataFormat is the class that describes binary integer 
# numbers.
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
my $Def_BinaryInteger_Bits = 32;
my $Def_BinaryInteger_Signed = 'yes';
my $Class_XML_Node_Name = "binaryInteger";
my @Class_XML_Attributes = qw (
                             signed
                             bits
                          );
my @Class_Attributes = ();

#add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

# add in super class XML attributes
push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

# /** bits
# The number of bits this XDF::BinaryIntegerDataFormat holds.
# */
# /** signed
# Whether this XDF::BinaryIntegerDataFormat holds signed or unsigned
# integer. Takes the values of "yes" or "no".
# */

# Something specific to Perl
# We use the "string" style here
my $Perl_Sprintf_Field_BinaryInteger = 's';
my $Perl_Regex_Field_BinaryInteger = '\.';

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
# GET/SET Methods 
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
   carp "Cant set bits to value other than 16, 32 or 64 \n"
      unless (defined $value && ($value == 64 or $value == 32 or $value == 16));
   $self->{Bits} = $value;
}

# /** getSigned
# */
sub getSigned{
   my ($self) = @_;
   return $self->{Signed};
}

# /** setSigned
#     Set the signed attribute. 
# */
sub setSigned {
   my ($self, $value) = @_;
   $self->{Signed} = $value;
}

# /** numOfBytes
# A convenience method.
# Return the number of bytes this XDF::BinaryIntegerDataFormat holds.
# */
sub numOfBytes { 
  my ($self) = @_; 
  return int($self->{Bits}/8); 
}


# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Private/Protected methods 
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

  $self->{Bits} = $Def_BinaryInteger_Bits;
  $self->{Signed} = $Def_BinaryInteger_Signed;
}


# Yes, this is sub-optimal. We dont treat having littleEndian AND
# unsigned or 64-bit AND littleEndian. Need to reformulate a more
# basic subroutine. -b.t. 
sub _templateNotation {
  my ($self, $endian, $encoding) = @_;

  my $width = $self->numOfBytes()/4; 

  # we have 32 bit numbers as default
  die "XDF::BinaryInteger cant handle > 32 bit Integer Numbers\n" unless ($width <= 1);

  #ok, lets find our template symbol
  my $symbol;
  my $bitsize = $self->{Bits};
  # we hardwired 'BigEndian" response here. Bad!
  my $isBigEndian = !defined $endian  || $endian eq 'BigEndian' ? 1 : 0;
  my $isSigned = $self->{Signed};
 
  if ($bitsize <= 16) {
     $symbol = "v";
     $symbol = "n" if $isBigEndian;
  } elsif ($bitsize <= 32) {
     $symbol = "V";
     $symbol = "N" if $isBigEndian;
  } elsif ($bitsize <= 64) {
     # we get a 'quad'. No idea what endianess this is :P.
     $symbol = "Q";
     $symbol = "q" if $isSigned;
  }

  # what if we are signed?
  $symbol = 

  return "$symbol";

}

sub _regexNotation {
  my ($self) = @_;

  my $width = $self->numOfBytes();
  my $symbol = $Perl_Regex_Field_BinaryInteger;

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
  my $field_symbol = $Perl_Sprintf_Field_BinaryInteger;

  $notation .= $self->{Width}; 
  $notation .= $field_symbol;

  return $notation;
}

# Modification History
#
# $Log$
# Revision 1.9  2001/02/15 18:27:37  thomas
# removed fortranNotation from class.
#
# Revision 1.8  2001/02/15 17:50:31  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.7  2001/01/04 22:33:19  thomas
# Fix to properly describe (some) cases for the
# templateNotation. Still have remaining bug of
# not treating all cases of signed, endianess and
# bit size. -b.t.
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

XDF::BinaryIntegerDataFormat - Perl Class for BinaryIntegerDataFormat

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 XDF::BinaryIntegerDataFormat is the class that describes binary integer  numbers. 

XDF::BinaryIntegerDataFormat inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::DataFormat>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::BinaryIntegerDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item #add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::DataFormat::classAttributes};

 

=item # add in super class XML attributes

 

=item push @Class_XML_Attributes, @{&XDF::DataFormat::getXMLAttributes};

 

=item # /** bits

 

=item # The number of bits this XDF::BinaryIntegerDataFormat holds.

 

=item # */

 

=item # /** signed

 

=item # Whether this XDF::BinaryIntegerDataFormat holds signed or unsigned

 

=item # integer. Takes the values of "yes" or "no".

 

=item # */

 

=item # Something specific to Perl

 

=item # We use the "string" style here

 

=item my $Perl_Sprintf_Field_BinaryInteger = 's';

 

=item my $Perl_Regex_Field_BinaryInteger = '\.';

 

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

 

=item # GET/SET Methods 

 

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

 

=item # /** getSigned

 

=item # */

 

=item sub getSigned{

 

=item return $self->{Signed};

 

=item }

 

=item # /** setSigned

 

=item #     Set the signed attribute. 

 

=item # */

 

=item sub setSigned {

 

=item $self->{Signed} = $value;

 

=item }

 

=item # /** numOfBytes

 

=item # A convenience method.

 

=item # Return the number of bytes this XDF::BinaryIntegerDataFormat holds.

 

=item # */

 

=item sub numOfBytes { 

 

=back

=head2 OTHER Methods

=over 4

=item getBits (EMPTY)



=item setBits ($value)

Set the (number of) bits attribute. 

=item getSigned{ (EMPTY)



=item setSigned ($value)

Set the signed attribute. 

=item numOfBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryIntegerDataFormat holds. 

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

XDF::BinaryIntegerDataFormat inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance methods of L<XDF::DataFormat>:
B<getLessThanValue>, B<setLessThanValue>, B<getLessThanOrEqualValue>, B<setLessThanOrEqualValue>, B<getGreaterThanValue>, B<setGreaterThanValue>, B<getGreaterThanOrEqualValue>, B<setGreaterThanOrEqualValue>, B<getInfiniteValue>, B<setInfiniteValue>, B<getInfiniteNegativeValue>, B<setInfiniteNegativeValue>, B<getNoDataValue>, B<setNoDataValue>, B<toXMLFileHandle>.

=back



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance methods of L<XDF::BaseObject>:
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

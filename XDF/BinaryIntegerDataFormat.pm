
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

use XDF::Constants;
use XDF::Utility;
use XDF::DataFormat;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::DataFormat
@ISA = ("XDF::DataFormat");

# CLASS DATA
my $Def_BinaryInteger_Bits = 16;
my $Def_BinaryInteger_Signed = 'yes';
my $Class_XML_Node_Name = "binaryInteger";
my @Class_XML_Attributes = qw (
                             signed
                             bits
                          );
my @Class_Attributes = qw (
                             _templateNotation
                             _unpackTemplateNotation
                          );

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

   carp "Cant set bits to $value, not allowed \n"
      unless (&XDF::Utility::isValidIntegerBits($value));
   $self->{Bits} = $value;
   $self->_updateTemplate;
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
   carp "Cant set signed to $value, not allowed \n"
      unless (&XDF::Utility::isValidBinaryIntegerSigned($value));
   $self->{Signed} = $value;
}

#
# Other Public Methods
# 

#/** convertBitStringToIntegerBits
# Convert the string representation of bits into the binary
# integer bits as specified by an instance of a BinaryIntegerDataFormat object.
# The desired endianness must be supplied.
# The integer bits are returned. 
# */
sub convertBitStringToIntegerBits {
  my ($self, $bitString, $dataEndian) = @_;

  return undef unless defined $bitString && defined $dataEndian;

  # this check could slow down things.
  unless (length($bitString) == $self->{Bits})
  {
     warn "XDF::BinaryIntegerDataFormat->convertBitStringToInteger got different number of bits than specified in the dataformat object, cannot convert passed string.\n";
     return undef;
  }

  if ($dataEndian ne &XDF::Constants::PLATFORM_ENDIAN) {
     $bitString = XDF::Utility::reverseBitStringByteOrder($bitString, $self->{Bits});
  } 

  my $packtemplate = $self->{_templateNotation};
  my $unpacktemplate = $self->{_unpackTemplateNotation};

  return unpack $unpacktemplate, pack $packtemplate, $bitString;

}

#/** convertIntegerToIntegerBits
# Convert the passed number into binary integer bits as specified by 
# the instance of a BinaryIntegerDataFormat object.
# The desired endianness of the output data bits must be supplied.
# The integer bits are returned. 
# */
sub convertIntegerToIntegerBits {
  my ($self, $integerValue, $dataEndian) = @_;

  return undef unless defined $integerValue && defined $dataEndian;
 
  my $bitTemplate = $self->{_templateNotation};
  my $nativeIntegerTemplate = $self->{_unpackTemplateNotation};

  my $bits = pack $nativeIntegerTemplate, $integerValue;

  # if the endianness is different, we have to reverse byte order
  # from what is given.
  if ($dataEndian ne &XDF::Constants::PLATFORM_ENDIAN) {
     my $bitString = unpack $bitTemplate, $bits; 
     $bitString = XDF::Utility::reverseBitStringByteOrder($bitString, $self->{Bits});
     $bits = pack $bitTemplate, $bitString;
  }

  return $bits;

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
  $self->_updateTemplate;
}

sub _templateNotation {
  my ($self) = @_;
  return $self->{_templateNotation};
}

sub _updateTemplate {
  my ($self) = @_;

  my $bits = $self->{Bits};
  $self->{_templateNotation} = "B" . $bits;

  # determine unpack template from number of bits 
  # Yes, we make the assumption here that the platform
  # is POSIX 32 bit machine (e.g short is 16 bits, etc).
  if ($bits == 16) {
     $self->{_unpackTemplateNotation} = "s";
  } elsif ($bits == 32) {
     $self->{_unpackTemplateNotation} = "i";
  } elsif ($bits == 64) {
     $self->{_unpackTemplateNotation} = "l";
  } else {
    die "Got weird number of bits $bits, cant assign unpackTemplate for BinaryIntegerDataFormat.\n";
  }

  # if signed, then perl wants a capital letter
  if ($self->{Signed}) {
     $self->{_unpackTemplateNotation} = ucfirst $self->{_unpackTemplateNotation}; 
  }

}

sub _regexNotation {
  carp "_regexNotation shouldnt be called for binary numbers\n";
}

# returns sprintf field notation
sub _sprintfNotation {
  carp "_sprintfNotation shouldnt be called for binary numbers\n";
}

# Modification History
#
# $Log$
# Revision 1.14  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.13  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.12  2001/03/09 23:10:52  thomas
# added convertIntegerToIntegerBits method.
#
# Revision 1.11  2001/03/09 22:06:40  thomas
# Shunted some class data to Constants class. Added checks from Uiltity
# package on setting some attributes. Added method to correctly change
# bitString into binary representation for integer as proscribed by an
# instance of this class.
#
# Revision 1.10  2001/03/07 23:12:57  thomas
# messing with templateNotation. changed for time being.
#
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


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::BinaryIntegerDataFormat.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class XML node name. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::BinaryIntegerDataFormat.

=over 4

=item getBits (EMPTY)

 

=item setBits ($value)

Set the (number of) bits attribute.  

=item getSigned{ (EMPTY)

 

=item setSigned ($value)

Set the signed attribute.  

=item convertBitStringToIntegerBits ($dataEndian, $bitString)

Convert the string representation of bits into the binaryinteger bits as specified by an instance of a BinaryIntegerDataFormat object. The desired endianness must be supplied. The integer bits are returned.  

=item convertIntegerToIntegerBits ($dataEndian, $integerValue)

Convert the passed number into binary integer bits as specified by the instance of a BinaryIntegerDataFormat object. The desired endianness of the output data bits must be supplied. The integer bits are returned.  

=item numOfBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryIntegerDataFormat holds.  

=back



=head2 INHERITED Class Methods

=over 4



=over 4

The following class methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>. 

=back

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance (object) methods of L<XDF::DataFormat>:
B<toXMLFileHandle>.

=back



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::Constants>, L<XDF::Utility>, L<XDF::DataFormat>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

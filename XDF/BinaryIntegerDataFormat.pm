
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
my @Local_Class_XML_Attributes = qw (
                             signed
                             bits
                          );
my @Local_Class_Attributes = qw (
                             _templateNotation
                             _unpackTemplateNotation
                          );
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

# /** getClassAttributes
#  This method returns a list containing the names
#  of the attributes of this class.
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# GET/SET Methods 
#

# /** getBits
# */
sub getBits {
   my ($self) = @_;
   return $self->{bits};
}

# /** setBits
#     Set the (number of) bits attribute. 
# */
sub setBits {
   my ($self, $value) = @_;

   carp "Cant set bits to $value, not allowed \n"
      unless (&XDF::Utility::isValidIntegerBits($value));
   $self->{bits} = $value;
   $self->_updateTemplate;
}

# /** getSigned
# */
sub getSigned{
   my ($self) = @_;
   return $self->{signed};
}

# /** setSigned
#     Set the signed attribute. 
# */
sub setSigned {
   my ($self, $value) = @_;
   carp "Cant set signed to $value, not allowed \n"
      unless (&XDF::Utility::isValidBinaryIntegerSigned($value));
   $self->{signed} = $value;
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
  unless (length($bitString) == $self->{bits})
  {
     warn "XDF::BinaryIntegerDataFormat->convertBitStringToInteger got different number of bits than specified in the dataformat object, cannot convert passed string.\n";
     return undef;
  }

  if ($dataEndian ne &XDF::Constants::PLATFORM_ENDIAN) {
     $bitString = XDF::Utility::reverseBitStringByteOrder($bitString, $self->{bits});
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
     $bitString = XDF::Utility::reverseBitStringByteOrder($bitString, $self->{bits});
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
  return int($self->{bits}/8); 
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

  $self->SUPER::_init();

  $self->{bits} = $Def_BinaryInteger_Bits;
  $self->{signed} = $Def_BinaryInteger_Signed;
  $self->_updateTemplate;

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _templateNotation {
  my ($self) = @_;
  return $self->{_templateNotation};
}

sub _outputTemplateNotation {
  my ($self) = @_;
  return $self->_templateNotation(); 
} 

sub _updateTemplate {
  my ($self) = @_;

  my $bits = $self->{bits};
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
  if ($self->{signed}) {
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

=item getClassAttributes (EMPTY)

This method returns a list containing the namesof the attributes of this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

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

=item convertBitStringToIntegerBits ($bitString, $dataEndian)

Convert the string representation of bits into the binaryinteger bits as specified by an instance of a BinaryIntegerDataFormat object. The desired endianness must be supplied. The integer bits are returned.  

=item convertIntegerToIntegerBits ($integerValue, $dataEndian)

Convert the passed number into binary integer bits as specified by the instance of a BinaryIntegerDataFormat object. The desired endianness of the output data bits must be supplied. The integer bits are returned.  

=item numOfBytes (EMPTY)

A convenience method. Return the number of bytes this XDF::BinaryIntegerDataFormat holds.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::BinaryIntegerDataFormat inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

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

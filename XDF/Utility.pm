
# $Id$

package XDF::Utility;

# /** COPYRIGHT
#    Utility.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Utility provides various common utility subroutines needed by 
# the XDF package.This class should never be instanciated.
# */

# /** SYNOPSIS
#  use XDF::Utility;
#
#  if (&XDF::Utility::isValidFloatBits($bits) {
#     # code for allowed bit values
#  }
# */

use XDF::Constants;
use strict;
use integer;

# private stuff we need for utility subroutines below 

# CLASS DATA/METHODS

# /** isValidEndian
# Determine if the passed quanity is an allowed value for the endian
# attribute of XMLDataIOStyle objects.
# */
sub isValidEndian { 
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::ENDIAN_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidIntegerType
# Determine if the passed quanity is an allowed value for the type
# attribute of the IntegerDataFormat object.
# */
sub isValidIntegerType { 
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::INTEGER_TYPE_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

sub isValidCharOutput { 
   my ($obj) = @_;

   my $ref = ref($obj);
   if ($ref) {
     return 1 if ($ref eq 'XDF::Chars' or $ref eq 'XDF::NewLine');
   }
   return 0;
}

# /** isValidIOEncoding
# Determine if the passed quanity is an allowed value for the encoding
# attribute of XMLDataIOStyle objects.
# */
sub isValidIOEncoding { 
   my ($value) = @_;
   # ok to be undefined ?
   return 1 unless defined $value;
   for (&XDF::Constants::IO_ENCODINGS_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidAxisSize
# Determine if the passed quanity is an allowed value for the size of
# an XDF::Axis object.
# */
sub isValidAxisSize {
   my ($value) = @_;

   # its not ok to be undefined
   return 0 unless defined $value;
   return 1 if ($value >= &XDF::Constants::DEFAULT_AXIS_SIZE);
   return 0;
}

# /** isValidComplexComponent
# Determine if this value is a valid complex component for Fields.
# */
sub isValidComplexComponent {
   my ($value) = @_;
   for (&XDF::Constants::COMPLEX_COMPONENT_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidUnits
# Determine if the passed quanity is an allowed value for Units (e.g. 
# an object of Units class).
# */
sub isValidUnits {
   my ($value) = @_;

   # its not ok to be undefined
   return 1 if (defined $value && ref($value) =~ m/XDF::Units/);
   return 0;
}

# /** isValidParameterDatatype
# Determine if the passed quanity is an allowed value for the datatype
# attribute of the Parameter object 
# */
sub isValidParameterDatatype { 
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::PARAMETER_DATATYPE_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidDataFormat
# Determine if the passed quanity is an allowed value for the dataformat
# attribute of the Array/Axis/Field objects 
# */
sub isValidDataFormat {
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::DATAFORMAT_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidDataEncoding
# Determine if the passed quanity is an allowed value for the encoding
# attribute of the DataCube object.
# */
sub isValidDataEncoding {
   my ($value) = @_;
   # ok to be undefined ?
   return 1 unless defined $value;
   for (&XDF::Constants::DATA_ENCODING_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidRelationRole
# Determine if the passed quanity is an allowed value for the role  
# attribute of the FieldRelation object.
# */
sub isValidRelationRole { 
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::RELATION_ROLE_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidDataCompression
# Determine if the passed quanity is an allowed value for the compression
# attribute on the DataCube object.
# */
sub isValidDataCompression { 
   my ($value) = @_;
   # it ok to be undefined
   return 1 unless defined $value;
   for (&XDF::Constants::DATA_COMPRESSION_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidLogarithm
# Determine if the passed quanity is an allowed value for the logarithm
# attribute.
# */
sub isValidLogarithm {
   my ($value) = @_;
   # its ok to be undefined
   return 1 unless defined $value;
   for (&XDF::Constants::LOGARITHM_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidReverse
# Determine if the passed quanity is an allowed value for the reverse
# attribute.
# */
sub isValidReverse {
   my ($value) = @_;
   # its not ok to be undefined
   return 0 unless defined $value;
   for (&XDF::Constants::TRUE_FALSE_LIST) { return 1 if ($_ eq $value); }
   return 0;
}


# /** isValidAlgorihtm
# Determine if the passed quanity is an allowed algorithm object.
# */
sub isValidAlgorithm {
   my ($value) = @_;
   return 0 unless defined $value and ref $value;
   for (&XDF::Constants::ALGORITHM_LIST) { return 1 if ($_ eq ref $value); }
   return 0;
}

# /** isValidFloatBits
# Determine if the passed quanity is an allowed value for the bits attribute
# of the BinaryFloatDataFormat object.
# */
sub isValidFloatBits {
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::FLOATING_POINT_BITS_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidIntegerBits
# Determine if the passed quanity is an allowed value for the bits attribute
# of the BinaryIntegerDataFormat object.
# */
sub isValidIntegerBits { 
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::INTEGER_BITS_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidBinaryIntegerSigned
# Determine if the passed quanity is an allowed value for the signed attribute
# of the BinaryIntegerDataFormat object.
# */
sub isValidBinaryIntegerSigned { 
   my ($value) = @_;
   return &_isYesOrNoString($value);
}

# /** isValidLogMsgLevel
# Determine if the passed quanity is an allowed value for the setLogMsgLevel 
# method in Specification.
# */
sub isValidLogMsgLevel {
   my ($value) = @_;
   return 1 if (defined $value && $value <= 3 && $value >= 0);
   return 0;
}

# /** isValidXMLStandalone
# Determine if the passed quanity is an allowed value for the XMLDeclaration
# standalone attribute. 
# */
sub isValidXMLStandalone {
   my ($value) = @_;
   return &_isYesOrNoString($value);
}  

# /** isValidValueSpecial
# Determine if the passed quanity is an allowed value for the special attribute
# of the Value object.
# */
sub isValidValueSpecial { 
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::VALUE_SPECIAL_LIST) { return 1 if ($_ eq $value); }
   return 0;
}

# /** isValidValueInequality
# Determine if the passed quanity is an allowed value for the inequality attribute
# of the Value object.
# */
sub isValidValueInequality { 
   my ($value) = @_;
   return 0 unless defined $value;
   for (&XDF::Constants::VALUE_INEQUALITY_LIST) { return 1 if ($_ eq $value); }
   return 0;
}


# /** isValidTaggedOutputStyle
# Determine if the current TaggedDataStyle object may bechanged to the new output style.
# Requires an array reference be also passed. It is assumed the array is the parent of
# the tagged data style object.
# */
sub isValidTaggedOutputStyle {
  my ($value, $parentArray) = @_;

  return 0 unless ref $parentArray and $parentArray->isa('XDF::Array');
  return 1 if (!$parentArray->hasRowAxis() and !$parentArray->hasColAxis() 
                 and $value eq &XDF::Constants::TAGGED_DEFAULT_OUTPUTSTYLE);
  return 1 if ($parentArray->hasRowAxis() and $value eq &XDF::Constants::TAGGED_BYROW_OUTPUTSTYLE);
  return 1 if ($parentArray->hasRowAxis() and $value eq &XDF::Constants::TAGGED_BYROWANDCELL_OUTPUTSTYLE);
  return 1 if ($parentArray->hasColAxis() and $value eq &XDF::Constants::TAGGED_BYCOL_OUTPUTSTYLE);
  return 1 if ($parentArray->hasColAxis() and $value eq &XDF::Constants::TAGGED_BYCOLANDCELL_OUTPUTSTYLE);
  return 0;
} 

# needed? seems a java thang only
# sub isValidNumberObject { }

#/** reverseBitStringByteOrder
# Reverses the *byte* ordering of the passed bit string. Returns 
# revsersed bitstring.
# */
sub reverseBitStringByteOrder {
  my ($bitString, $numOfBits) = @_;

  if ($numOfBits == 16) {
    return &reverse16BitStringByteOrder($bitString);
  } elsif ($numOfBits == 32) {
    return &reverse32BitStringByteOrder($bitString);
  } elsif ($numOfBits == 64) {
    return &reverse64BitStringByteOrder($bitString);
  } elsif ($numOfBits == 8) {
    return $bitString; # only 1 byte, how you gonna reverse that?
  } else {
    die "reverseBitStringByteOrder cant handle $numOfBits bit bitStrings\n";
  }

}

#/** reverse16BitStringByteOrder
# Reverses the *byte* ordering of the passed 16 bit string. Returns 
# revsersed bitstring.
# */
sub reverse16BitStringByteOrder {
  my ($bitString) = @_;
  $bitString =~ s/(.{8})(.{8})/$2$1/;
  return $bitString;
} 

#/** reverse32BitStringByteOrder
# Reverses the *byte* ordering of the passed 32 bit string. Returns 
# revsersed bitstring.
# */
sub reverse32BitStringByteOrder {
  my ($bitString) = @_;
  $bitString =~ s/(.{8})(.{8})(.{8})(.{8})/$4$3$2$1/;
  return $bitString;
}

#/** reverse64BitStringByteOrder
# Reverses the *byte* ordering of the passed 64 bit string. Returns 
# revsersed bitstring.
# */
sub reverse64BitStringByteOrder {
  my ($bitString) = @_;
  $bitString =~ s/(.{8})(.{8})(.{8})(.{8})(.{8})(.{8})(.{8})(.{8})/$8$7$6$5$4$3$2$1/;
  return $bitString;
}

# Certainly this implementation is bad, very bad. 
# At the minimum we need to make this user configurable 
# at 'perl Makefile.PL' time.
sub getDataDecompressionProgram {
  my ($compression_type) = @_;

  return unless defined $compression_type;

  my $compression_program;
  if ($compression_type eq &XDF::Constants::DATA_COMPRESSION_GZIP() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_GZIP_PATH() . ' -dc ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_BZIP2() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_BZIP2_PATH() . ' -dc ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_COMPRESS() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_COMPRESS_PATH() . ' -dc ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_ZIP() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_UNZIP_PATH() . ' -p ';
  } else {
     die "Error: Data decompression for type: $compression_type NOT Implemented.\n";
  }

  return $compression_program;
}

# Certainly this implementation is bad, very bad. 
# At the minimum we need to make this user configurable 
# at 'perl Makefile.PL' time.
sub getDataCompressionProgram {
  my ($compression_type) = @_;

  return unless defined $compression_type;

  my $compression_program;
  if ($compression_type eq &XDF::Constants::DATA_COMPRESSION_GZIP() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_GZIP_PATH() . ' -c ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_BZIP2() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_BZIP2_PATH() . ' -c ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_COMPRESS() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_COMPRESS_PATH() . ' -c ';
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_ZIP() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_ZIP_PATH() . ' -pq ';
  } else {
     die "Error: Data Compression for type: $compression_type NOT Implemented.\n";
  }

  return $compression_program;
}

# Private

sub _isYesOrNoString {
   my ($string) = @_;
   return 0 unless defined $string;
   return 1 if $string eq 'yes' || $string eq 'no';
   return 0;
}  


1;


__END__

=head1 NAME

XDF::Utility - Perl Class for Utility

=head1 SYNOPSIS

  use XDF::Utility;

  if (&XDF::Utility::isValidFloatBits($bits) {
     # code for allowed bit values
  }


...

=head1 DESCRIPTION

 An XDF::Utility provides various common utility subroutines needed by  the XDF package.This class should never be instanciated. 



=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Utility.

=over 4

=item isValidEndian ($value)

Determine if the passed quanity is an allowed value for the endianattribute of XMLDataIOStyle objects.  

=item isValidIntegerType ($value)

Determine if the passed quanity is an allowed value for the typeattribute of the IntegerDataFormat object.  

=item isValidCharOutput ($obj)

 

=item isValidIOEncoding ($value)

Determine if the passed quanity is an allowed value for the encodingattribute of XMLDataIOStyle objects.  

=item isValidDatatype ($value)

Determine if the passed quanity is an allowed value for the datatypeattribute of the Parameter object and the axisDatatype attribute ofthe Axis object.  

=item isValidDataEncoding ($value)

Determine if the passed quanity is an allowed value for the encodingattribute of the DataCube object.  

=item isValidRelationRole ($value)

Determine if the passed quanity is an allowed value for the role  attribute of the FieldRelation object.  

=item isValidDataCompression ($value)

Determine if the passed quanity is an allowed value for the compressionattribute on the DataCube object.  

=item isValidLogarithm ($value)

Determine if the passed quanity is an allowed value for the logarithmattribute on the Units object.  

=item isValidFloatBits ($value)

Determine if the passed quanity is an allowed value for the bits attributeof the BinaryFloatDataFormat object.  

=item isValidIntegerBits ($value)

Determine if the passed quanity is an allowed value for the bits attributeof the BinaryIntegerDataFormat object.  

=item isValidBinaryIntegerSigned ($value)

Determine if the passed quanity is an allowed value for the signed attributeof the BinaryIntegerDataFormat object.  

=item isValidXMLStandalone ($value)

Determine if the passed quanity is an allowed value for the XMLDeclarationstandalone attribute.  

=item isValidValueSpecial ($value)

Determine if the passed quanity is an allowed value for the special attributeof the Value object.  

=item isValidValueInequality ($value)

Determine if the passed quanity is an allowed value for the inequality attributeof the Value object.  

=item reverseBitStringByteOrder ($bitString, $numOfBits)

Reverses the *byte* ordering of the passed bit string. Returns revsersed bitstring.  

=item reverse16BitStringByteOrder ($bitString)

Reverses the *byte* ordering of the passed 16 bit string. Returns revsersed bitstring.  

=item reverse32BitStringByteOrder ($bitString)

Reverses the *byte* ordering of the passed 32 bit string. Returns revsersed bitstring.  

=item reverse64BitStringByteOrder ($bitString)

Reverses the *byte* ordering of the passed 64 bit string. Returns revsersed bitstring.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::Constants>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

package XDF::Constants;

# /** COPYRIGHT
#    Constants.pm Copyright (C) 2000 Brian Thomas,
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# An XDF::Constants provides various constants as defined in the 
# XDF DTD. This class should never be instanciated as it only holds
# class data. 
# */

# /** SYNOPSIS
# use XDF::Constants;
#
# my $def_big_endian = &XDF::Constants::BIG_ENDIAN;
# */

use XML::DOM;

use strict;
use integer;

use vars qw { $VERSION };

# the version of this module
$VERSION = "0.18-alpha1";

# This is used by XMLElement for referencing a document. Only
# because the DOM spec requires that a document be specified 
# do we do this. Ush. IF only the DocumentFragment (a lighterweight)
# object would suffice. Nevertheless, we can save memory by always
# using this single document.
my $InternalDOMDocument;
my $XDF_DTD_NAME = "XDF_018.dtd"; 

# internal thing. 
my $PCDATA_Attribute = 'value';

my $XML_Spec_Version = '1.0';
my $LittleEndian = 'LittleEndian';
my $BigEndian = 'BigEndian';
my $PlatformEndian = unpack("h*", pack("s", 1)) =~ /^1/ ? $LittleEndian : $BigEndian;

# CLASS DATA/METHODS

sub XDF_DTD_NAME {
 return $XDF_DTD_NAME;
}

sub getInternalDOMDocument { # PRIVATE

  if (!defined $InternalDOMDocument) { 
    $InternalDOMDocument = new XML::DOM::Document();
  }
  return $InternalDOMDocument;
}

sub getPCDATAAttribute { # PRIVATE
  return $PCDATA_Attribute; 
} 

sub XML_SPEC_VERSION { $XML_Spec_Version; }

sub BIG_ENDIAN {  $BigEndian; } 
sub LITTLE_ENDIAN {  $LittleEndian; } 
sub ENDIAN_LIST { (&BIG_ENDIAN, &LITTLE_ENDIAN); }

sub INTEGER_TYPE_DECIMAL { "decimal"; }
sub INTEGER_TYPE_HEX { "hexadecimal"; }
sub INTEGER_TYPE_OCTAL { "octal"; }
sub INTEGER_TYPE_LIST { (&INTEGER_TYPE_DECIMAL, &INTEGER_TYPE_OCTAL, &INTEGER_TYPE_HEX, ); }

sub PLATFORM_ENDIAN { $PlatformEndian; } 

# these are the allowed floating point
# bits sizes for binary data 
sub FLOATING_POINT_BITS_LIST {  (32, 64); }
# these are the allowed integer
# bits sizes for binary data 
sub INTEGER_BITS_LIST {  return (4, 16, 32, 64); } 

sub COMPLEX_COMPONENT_LIST { ("real", "imaginary"); }

sub TAGGED_DEFAULT_OUTPUTSTYLE { "default"; }
sub TAGGED_BYCOL_OUTPUTSTYLE { "byColumn"; }
sub TAGGED_BYCOLANDCELL_OUTPUTSTYLE { "byColumnAndCell"; }
sub TAGGED_BYROW_OUTPUTSTYLE { "byRow"; }
sub TAGGED_BYROWANDCELL_OUTPUTSTYLE { "byRowAndCell"; }
sub SIMPLE_COLUMN_TAG { "column"; }
sub SIMPLE_ROW_TAG { "row"; }
sub SIMPLE_CELL_TAG { "cell"; }

sub IO_ENCODING_UTF_8 { "UTF-8"; }
sub IO_ENCODING_UTF_16 { "UTF-16"; }
sub IO_ENCODING_ISO_8859_1 { "ISO-8859-1"; }
sub IO_ENCODING_ANSI { "ANSI"; }

sub IO_ENCODINGS_LIST {  ( &IO_ENCODING_UTF_8, &IO_ENCODING_UTF_16,
                           &IO_ENCODING_ISO_8859_1, &IO_ENCODING_ANSI ); }

# allowable roles for the (field) relation node
# error | sensitivity | precision | positiveError | negativeError | 
# weight | reference | noteMark
sub RELATION_ROLE_LIST { ( "error" , "sensitivity" , "precision",
                           "positiveError" , "negativeError",
                           "weight" , "reference" , "noteMark" ); 
                       }

# this is used for parameters right now
sub DATATYPE_INTEGER { "integer"; }
sub DATATYPE_FIXED { "fixed"; }
sub DATATYPE_STRING { "string"; }
sub DATATYPE_URL {  "url"; }
sub PARAMETER_DATATYPE_LIST {  ( &DATATYPE_INTEGER, &DATATYPE_FIXED,
                                 &DATATYPE_STRING, &DATATYPE_URL ); }

# this is used for parameters right now
sub DATAFORMAT_ARRAY_REF {  "XDF::ArrayRefDataFormat"; }
sub DATAFORMAT_BINARY_FLOAT {  "XDF::BinaryFloatDataFormat"; }
sub DATAFORMAT_BINARY_INTEGER { "XDF::BinaryIntegerDataFormat"; }
sub DATAFORMAT_INTEGER { "XDF::IntegerDataFormat"; }
sub DATAFORMAT_FLOAT{ "XDF::FloatDataFormat"; }
sub DATAFORMAT_STRING { "XDF::StringDataFormat"; }

sub DATAFORMAT_LIST {  ( &DATAFORMAT_INTEGER, &DATAFORMAT_FLOAT,
                                 &DATAFORMAT_STRING, &DATAFORMAT_BINARY_FLOAT,
                                 &DATAFORMAT_BINARY_INTEGER, &DATAFORMAT_ARRAY_REF
                        ); }

sub DATA_ENCODING_UUENCODED { "uuencoded"; }
sub DATA_ENCODING_BASE64 { "base64"; }
sub DATA_ENCODING_LIST {  ( &DATA_ENCODING_UUENCODED, &DATA_ENCODING_BASE64 ); }

# compression programs... should be auto-updated at "make" time
sub DATA_COMPRESSION_ZIP { "zip"; }
sub DATA_COMPRESSION_GZIP { "gzip"; }
sub DATA_COMPRESSION_BZIP2 { "bzip2"; }
sub DATA_COMPRESSION_XMILL { "XMILL"; }
sub DATA_COMPRESSION_COMPRESS {  "compress"; }
sub DATA_COMPRESSION_GZIP_PATH { "/usr/bin/gzip"; }
sub DATA_COMPRESSION_BZIP2_PATH { "/usr/bin/bzip2"; }
sub DATA_COMPRESSION_COMPRESS_PATH { "/usr/bin/compress"; }
sub DATA_COMPRESSION_UNZIP_PATH { "/usr/bin/unzip"; }
sub DATA_COMPRESSION_ZIP_PATH { "/usr/bin/zip"; }
sub DATA_COMPRESSION_LIST { ( &DATA_COMPRESSION_ZIP, &DATA_COMPRESSION_GZIP,
                              &DATA_COMPRESSION_BZIP2, &DATA_COMPRESSION_XMILL,
                              &DATA_COMPRESSION_COMPRESS ); }

sub LOGARITHM_NATURAL { "natural"; }
sub LOGARITHM_BASE10  { "10"; }
sub LOGARITHM_LIST { (&LOGARITHM_NATURAL, &LOGARITHM_BASE10, ); }

sub TRUE { "true"; }
sub FALSE { "false"; }
sub TRUE_FALSE_LIST { (&TRUE, &FALSE); }
 
sub ALGORITHM_LIST { ("XDF::Polynomial",); }


sub VALUE_INEQUALITY_LESS_THAN { "lessThan"; }
sub VALUE_INEQUALITY_LESS_THAN_OR_EQUAL { "lessThanOrEqual"; }
sub VALUE_INEQUALITY_GREATER_THAN { "greaterThan"; }
sub VALUE_INEQUALITY_GREATER_THAN_OR_EQUAL { "greaterThanOrEqual"; }

sub VALUE_INEQUALITY_LIST { ( &VALUE_INEQUALITY_LESS_THAN,
                              &VALUE_INEQUALITY_LESS_THAN_OR_EQUAL,
                              &VALUE_INEQUALITY_GREATER_THAN,
                              &VALUE_INEQUALITY_GREATER_THAN_OR_EQUAL, 
                            ); }

sub VALUE_SPECIAL_INFINITE { "infinite"; }
sub VALUE_SPECIAL_INFINITE_NEGATIVE { "infiniteNegative"; }
sub VALUE_SPECIAL_NODATA{ "noData"; }
sub VALUE_SPECIAL_NOTANUMBER { "notANumber"; }
sub VALUE_SPECIAL_OVERFLOW { "overflow"; }
sub VALUE_SPECIAL_UNDERFLOW { "underflow"; }

sub VALUE_SPECIAL_LIST { ( &VALUE_SPECIAL_INFINITE,  &VALUE_SPECIAL_INFINITE_NEGATIVE,
                           &VALUE_SPECIAL_NODATA, &VALUE_SPECIAL_NOTANUMBER, &VALUE_SPECIAL_UNDERFLOW,
                           &VALUE_SPECIAL_OVERFLOW ); }

sub DEFAULT_AXIS_SIZE { 1; }

sub DEFAULT_VALUELIST_SIZE { 0; }
#sub DEFAULT_VALUELIST_STEP { 1; }
#sub DEFAULT_VALUELIST_START { 0; }
sub DEFAULT_VALUELIST_DELIMITER { " "; }
sub DEFAULT_VALUELIST_REPEATABLE { "no"; }

sub LOG_WARN_MSG_LEVEL { 2; }
sub LOG_DEBUG_MSG_LEVEL { 1; }
sub LOG_INFO_MSG_LEVEL { 0; }

sub XDF_NOTATION_NAME {
  return 'xdf'; 
}

sub XDF_NOTATION_PUBLICID {
  return 'application/xdf'; 
}

sub XDF_ROOT_NODE_NAME {
  my %hash = &XDF_NODE_NAMES; 
  return $hash{'root'};
}

sub XDF_NODE_NAMES { (
                      'add' => 'add',
                      'array' => 'array',
                      'arrayRef' => 'arrayRef',
                      'axis' => 'axis',
                      'axisUnits' => 'axisUnits',
                      'binaryFloat' => 'binaryFloat',
                      'binaryInteger' => 'binaryInteger',
                      'cell' => 'cell',
                      'chars' => 'chars',
                      'colAxis' => 'colAxis',
                      'column' => 'column',
                      'conversion' => 'conversion',
                      'data' => 'data',
                      'dataStyle' => 'dataStyle',
                      'dataFormat' => 'dataFormat',
                      'doInstruction' => 'doInstruction',
                      'delimiter' => 'delimiter',
                      'delimitedStyle' => 'delimited',
                      'delimitedReadInstructions' => 'delimitedInstruction',
                      'exponent' => 'exponent',
                      'exponentOn' => 'exponentOn',
                      'field' => 'field',
                      'fieldAxis' => 'fieldAxis',
                      'formattedStyle' => 'fixedWidth',
                      'formattedReadInstructions' => 'fixedWidthInstruction',
                      'float' => 'float',
                      'for' => 'for',
                      'fieldGroup' => 'fieldGroup',
                      'index' => 'index',
                      'integer' => 'integer',
                      'logarithmBase' => 'logarithmBase',
                      'naturalLogarithm' => 'naturalLogarithm',
                      'locationOrder' => 'locationOrder',
                      'multiply' => 'multiply',
                      'newline' => 'newLine',
                      'note' => 'note',
                      'notes' => 'notes',
                      'parameter' => 'parameter',
                      'parameterGroup' => 'parameterGroup',
                      'polynomial' => 'polynomial',
                      'root' => 'XDF',   # beware setting this to the same name as structure 
                      'rowAxis' => 'rowAxis',
                      'row' => 'row',
                      'read' => 'dataStyle',
                      'readCell' => 'readCell',
                      'recordTerminator' => 'recordTerminator',
                      'repeat' => 'repeat',
                      'relationship' => 'relation',
                      'skipChar' => 'skip',
                      'structure' => 'structure',
                      'string' => 'string',
                      'taggedStyle' => 'tagged',
                      'tagToAxis' => 'tagToAxis',
                      'td0' => 'd0',
                      'td1' => 'd1',
                      'td2' => 'd2',
                      'td3' => 'd3',
                      'td4' => 'd4',
                      'td5' => 'd5',
                      'td6' => 'd6',
                      'td7' => 'd7',
                      'td8' => 'd8',
                      'unit' => 'unit',
                      'units' => 'units',
                      'unitless' => 'unitless',
                      'valueList' => 'valueList',
                      'valueListAlgorithm' => 'valueListAlgorithm',
                      'value' => 'value',
                      'valueGroup' => 'valueGroup',
                      'vector' => 'unitDirection',
                    );
}

1;


__END__

=head1 NAME

XDF::Constants - Perl Class for Constants

=head1 SYNOPSIS

 use XDF::Constants;

 my $def_big_endian = &XDF::Constants::BIG_ENDIAN;


...

=head1 DESCRIPTION

 An XDF::Constants provides various constants as defined in the  XDF DTD. This class should never be instanciated as it only holds class data. 



=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Constants.

=over 4

=item XDF_DTD_NAME (EMPTY)

 

=item XML_SPEC_VERSION (EMPTY)

 

=item BIG_ENDIAN (EMPTY)

 

=item ENDIAN_LIST (EMPTY)

 

=item INTEGER_TYPE_DECIMAL (EMPTY)

 

=item INTEGER_TYPE_OCTAL (EMPTY)

 

=item PLATFORM_ENDIAN (EMPTY)

 

=item FLOATING_POINT_BITS_LIST (EMPTY)

 

=item INTEGER_BITS_LIST (EMPTY)

 

=item COMPLEX_COMPONENT_LIST (EMPTY)

 

=item TAGGED_DEFAULT_OUTPUTSTYLE (EMPTY)

 

=item TAGGED_BYCOLANDCELL_OUTPUTSTYLE (EMPTY)

 

=item TAGGED_BYROWANDCELL_OUTPUTSTYLE (EMPTY)

 

=item SIMPLE_ROW_TAG (EMPTY)

 

=item IO_ENCODING_UTF_8 (EMPTY)

 

=item IO_ENCODING_ISO_8859_1 (EMPTY)

 

=item IO_ENCODINGS_LIST (EMPTY)

 

=item RELATION_ROLE_LIST (EMPTY)

 

=item DATATYPE_INTEGER (EMPTY)

 

=item DATATYPE_STRING (EMPTY)

 

=item PARAMETER_DATATYPE_LIST (EMPTY)

 

=item DATAFORMAT_ARRAY_REF (EMPTY)

 

=item DATAFORMAT_BINARY_INTEGER (EMPTY)

 

=item DATAFORMAT_FLOAT{ (EMPTY)

 

=item DATAFORMAT_LIST (EMPTY)

 

=item DATA_ENCODING_UUENCODED (EMPTY)

 

=item DATA_ENCODING_LIST (EMPTY)

 

=item DATA_COMPRESSION_ZIP (EMPTY)

 

=item DATA_COMPRESSION_BZIP2 (EMPTY)

 

=item DATA_COMPRESSION_COMPRESS (EMPTY)

 

=item DATA_COMPRESSION_BZIP2_PATH (EMPTY)

 

=item DATA_COMPRESSION_UNZIP_PATH (EMPTY)

 

=item DATA_COMPRESSION_LIST (EMPTY)

 

=item LOGARITHM_NATURAL (EMPTY)

 

=item LOGARITHM_LIST (EMPTY)

 

=item TRUE_FALSE_LIST (EMPTY)

 

=item ALGORITHM_LIST (EMPTY)

 

=item VALUE_INEQUALITY_LESS_THAN (EMPTY)

 

=item VALUE_INEQUALITY_GREATER_THAN (EMPTY)

 

=item VALUE_INEQUALITY_LIST (EMPTY)

 

=item VALUE_SPECIAL_INFINITE (EMPTY)

 

=item VALUE_SPECIAL_NODATA{ (EMPTY)

 

=item VALUE_SPECIAL_OVERFLOW (EMPTY)

 

=item VALUE_SPECIAL_LIST (EMPTY)

 

=item DEFAULT_AXIS_SIZE (EMPTY)

 

=item DEFAULT_VALUELIST_SIZE (EMPTY)

 

=item DEFAULT_VALUELIST_DELIMITER (EMPTY)

 

=item LOG_WARN_MSG_LEVEL (EMPTY)

 

=item LOG_INFO_MSG_LEVEL (EMPTY)

 

=item XDF_NOTATION_NAME (EMPTY)

 

=item XDF_NOTATION_PUBLICID (EMPTY)

 

=item XDF_ROOT_NODE_NAME (EMPTY)

 

=item XDF_NODE_NAMES (EMPTY)

 

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



=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

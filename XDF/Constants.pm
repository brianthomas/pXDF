
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
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
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

# inherits from nothing
#@ISA { (); #"XDF::GenericObject")}

# This is used by XMLElement for referencing a document. Only
# because the DOM spec requires that a document be specified 
# do we do this. Ush. IF only the DocumentFragment (a lighterweight)
# object would suffice. Nevertheless, we can save memory by always
# using this single document.
my $InternalDOMDocument;
my $XDF_DTD_NAME = "XDF_017.dtd"; 

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

sub IO_ENCODING_UTF_8 { "UTF-8"; }
sub IO_ENCODING_UTF_16 { "UTF-16"; }
sub IO_ENCODING_ISO_8859_1 { "ISO-8859-1"; }
sub IO_ENCODING_ANSI { "ANSI"; }

sub IO_ENCODINGS_LIST {  ( &IO_ENCODING_UTF_8, &IO_ENCODING_UTF_16,
                           &IO_ENCODING_ISO_8859_1, &IO_ENCODING_ANSI ); }

# allowable roles for the (field) relation node
sub RELATION_ROLE_LIST { ( "error" , "sensitivity" , "precision",
                           "quality" , "positiveError" , "negativeError",
                           "weight" , "reference" , "noteMark" ); 
                       }

sub DATATYPE_INTEGER { "integer"; }
sub DATATYPE_FIXED { "fixed"; }
sub DATATYPE_STRING { "string"; }
sub DATATYPE_URL {  "url"; }
sub DATATYPE_LIST {  ( &DATATYPE_INTEGER, &DATATYPE_FIXED,
                       &DATATYPE_STRING, &DATATYPE_URL ); }

sub DATA_ENCODING_UUENCODED { "uuencoded"; }
sub DATA_ENCODING_BASE64 { "base64"; }
sub DATA_ENCODING_LIST {  ( &DATA_ENCODING_UUENCODED, &DATA_ENCODING_BASE64 ); }

sub DATA_COMPRESSION_ZIP { "zip"; }
sub DATA_COMPRESSION_GZIP { "gzip"; }
sub DATA_COMPRESSION_BZIP2 { "bzip2"; }
sub DATA_COMPRESSION_XMILL { "XMILL"; }
sub DATA_COMPRESSION_COMPRESS {  "compress"; }

sub DATA_COMPRESSION_LIST { ( &DATA_COMPRESSION_ZIP, &DATA_COMPRESSION_GZIP,
                              &DATA_COMPRESSION_BZIP2, &DATA_COMPRESSION_XMILL,
                              &DATA_COMPRESSION_COMPRESS ); }

sub LOGARITHM_NATURAL { "natural"; }
sub LOGARITHM_BASE10  { "base10"; }
sub LOGARITHM_LIST { (&LOGARITHM_NATURAL, &LOGARITHM_BASE10, ); }

sub DATA_COMPRESSION_GZIP_PATH { "/usr/bin/gzip"; }
sub DATA_COMPRESSION_BZIP2_PATH { "/usr/bin/bzip2"; }
sub DATA_COMPRESSION_COMPRESS_PATH { "/usr/bin/compress"; }
sub DATA_COMPRESSION_UNZIP_PATH { "/usr/bin/unzip"; }
sub DATA_COMPRESSION_ZIP_PATH { "/usr/bin/zip"; }

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

sub VALUE_SPECIAL_LIST { ( &VALUE_SPECIAL_INFINITE,  &VALUE_SPECIAL_INFINITE_NEGATIVE,
                           &VALUE_SPECIAL_NODATA ); }

sub DEFAULT_VALUELIST_STEP { 1; }
sub DEFAULT_VALUELIST_START { 1; }
sub DEFAULT_VALUELIST_REPEATABLE { 0; }
sub DEFAULT_VALUELIST_DELIMITER { " "; }

sub XDF_ROOT_NODE_NAME {
  my %hash = &XDF_NODE_NAMES; 
  return $hash{'root'};
}

sub XDF_NODE_NAMES { (
                      'textDelimiter' => 'textDelimiter',
                      'array' => 'array',
                      'axis' => 'axis',
                      'axisUnits' => 'axisUnits',
                      'binaryFloat' => 'binaryFloat',
                      'binaryInteger' => 'binaryInteger',
                      'data' => 'data',
                      'dataFormat' => 'dataFormat',
                      'field' => 'field',
                      'fieldAxis' => 'fieldAxis',
                      'float' => 'float',
                      'for' => 'for',
                      'fieldGroup' => 'fieldGroup',
                      'index' => 'index',
                      'integer' => 'integer',
                      'locationOrder' => 'locationOrder',
                      'note' => 'note',
                      'notes' => 'notes',
                      'parameter' => 'parameter',
                      'parameterGroup' => 'parameterGroup',
                      'root' => 'XDF',   # beware setting this to the same name as structure 
                      'read' => 'read',
                      'readCell' => 'readCell',
                      'repeat' => 'repeat',
                      'relationship' => 'relation',
                      'skipChar' => 'skipChars',
                      'structure' => 'structure',
                      'string' => 'string',
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
                      'value' => 'value',
                      'valueGroup' => 'valueGroup',
                      'vector' => 'unitDirection',
                    );
}

# Modification History
#
# $Log$
# Revision 1.11  2001/07/02 17:25:49  thomas
# made changes req. from DTD change to FieldRelation Roles.
#
# Revision 1.10  2001/06/21 17:23:26  thomas
# added Logarithm check
#
# Revision 1.9  2001/06/19 21:19:43  thomas
# added compression.
#
# Revision 1.8  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.7  2001/04/25 15:55:58  thomas
# fixed XDF DTD name
#
# Revision 1.6  2001/04/17 18:59:27  thomas
# Added some stuff from BaseObject, and new
# stuff needed by Specifiaction Class.
#
# Revision 1.5  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.4  2001/03/15 22:22:29  thomas
# Transfered XDF_NODE_NAMES and some VALUELIST defines from the
# Reader class to here.
#
# Revision 1.3  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.2  2001/03/09 21:49:57  thomas
# updated perlDocumentation section.
#
# Revision 1.1  2001/03/09 21:07:52  thomas
# Initial version. Copied from Java package.
#
#
#

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

 

=item IO_ENCODING_UTF_8 (EMPTY)

 

=item IO_ENCODING_ISO_8859_1 (EMPTY)

 

=item IO_ENCODINGS_LIST (EMPTY)

 

=item RELATION_ROLE_LIST (EMPTY)

 

=item DATATYPE_INTEGER (EMPTY)

 

=item DATATYPE_STRING (EMPTY)

 

=item DATATYPE_LIST (EMPTY)

 

=item DATA_ENCODING_UUENCODED (EMPTY)

 

=item DATA_ENCODING_LIST (EMPTY)

 

=item DATA_COMPRESSION_ZIP (EMPTY)

 

=item DATA_COMPRESSION_BZIP2 (EMPTY)

 

=item DATA_COMPRESSION_COMPRESS (EMPTY)

 

=item DATA_COMPRESSION_LIST (EMPTY)

 

=item VALUE_INEQUALITY_LESS_THAN (EMPTY)

 

=item VALUE_INEQUALITY_GREATER_THAN (EMPTY)

 

=item VALUE_INEQUALITY_LIST (EMPTY)

 

=item VALUE_SPECIAL_INFINITE (EMPTY)

 

=item VALUE_SPECIAL_NODATA{ (EMPTY)

 

=item VALUE_SPECIAL_LIST (EMPTY)

 

=item DEFAULT_VALUELIST_STEP (EMPTY)

 

=item DEFAULT_VALUELIST_REPEATABLE (EMPTY)

 

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

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

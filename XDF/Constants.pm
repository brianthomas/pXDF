
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

use strict;
use integer;

# inherits from nothing
#@ISA { (); #"XDF::GenericObject")}

my $LittleEndian = 'LittleEndian';
my $BigEndian = 'BigEndian';
my $PlatformEndian = unpack("h*", pack("s", 1)) =~ /^1/ ? $LittleEndian : $BigEndian;

# CLASS DATA/METHODS

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
sub RELATION_ROLE_LIST { ( "errors" , "sensitivity" ,
                           "weights" , "references" ,
                            "noteMarks" ); }

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


# Modification History
#
# $Log$
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



=over 4

=head2 OTHER Methods

=over 4

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



=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.
=back

=over 4

=head2 INHERITED Other Methods

=back

=head1 SEE ALSO



=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

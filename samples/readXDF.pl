#!/usr/bin/perl -w -I ..

# a simple program to show how a user might like to read
# in XDF data file and print it back out.

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

# CVS $Id$

# this is a SIMPLE reading of XDF file. See read_write_any_xml.pl for how to 
# read/write documents with XDF embedded in them. -b.t. 

use XDF::XDF;
use XDF::Reader;
use strict;

my $DEBUG = 0;
my $QUIET = 1;

# test file for reading in XDF files.

  die "Usage: $0 <XDF FILE>\n" unless defined $ARGV[0];

  my $data_separator = "\t";
  my $file = $ARGV[0];

  print STDERR "Reading in XDF object from file: $file \n";

  my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );

  my $XDF = new XDF::XDF();
  $XDF->loadFromXDFFile($file, \%options);

  # configure the output style
  my $spec = XDF::Specification->getInstance;
  $spec->setPrettyXDFOutput(1);  # use pretty print 
  $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation 

  # make this safe for writting, change the external 
  # file name to write out to (should it exist)
  my $index = 0;
  foreach my $arrayObj (@{$XDF->getArrayList}) {
    if (defined $arrayObj->getDataCube()->getHref()) {
       $arrayObj->getDataCube()->getHref()->setSystemId('table'.$index.'.dat');
    }
    $index++;
  }

  print STDOUT $XDF->toXMLString();

  exit 0;



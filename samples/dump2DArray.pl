#!/usr/bin/perl -w -I ..

# a simple program to show how a user might like to read
# in XDF data file and print it back out.

#    ADC/GSFC-NASA, Code 631, Greenbelt MD, 20771

#    This program is free software; it is licensed under the same terms
#    as Perl itself is. Please refer to the file LICENSE which is contained
#    in the distribution that this file came in.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# */

# CVS $Id$

# this is a SIMPLE reading of XDF file. See read_write_any_xml.pl for how to 
# read/write documents with XDF embedded in them. -b.t. 

use XDF::XDF;
use XDF::Specification;
use strict;

my $DEBUG = 0;
my $QUIET = 1;

# test file for reading in XDF files.

  die "Usage: $0 <XDF FILE>\n" unless defined $ARGV[0];

  my $spec = XDF::Specification->getInstance();
  $spec->setLogMessageLevel(0) if $DEBUG;

  my $data_separator = "\t";
  my $file = $ARGV[0];

  print "Reading in XDF object from file: $file \n";

  my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );

  my $XDF = new XDF::XDF();
  $XDF->loadFromXDFFile($file, \%options);

  foreach my $arrayObj (@{$XDF->getArrayList()}) {
    &dump_2D_array(\*STDOUT, $arrayObj);# if ($arrayObj->getDimension() == 2);
  }

  exit 0;

# assume a 2D table and dump it
# (we just dump first 2 axes) 
sub dump_2D_array {
  my ($filehandle, $arrayObj) = @_;

   # safety
   return unless (defined $filehandle && defined $arrayObj);

   my $name = $arrayObj->getName;
   $name = "" unless defined $name;
   my $dim = $arrayObj->getDimension();
   print $filehandle "XDF ARRAY: \"",$name, "\" of dimension: $dim \n";

   if ($dim > 2) {
      print $filehandle "\n ** NOTE: only dumping first 2 dimensions **\n\n";
   }

   # dump the array
   # get the number of indices along each axis 

   # get the cellSize
   my $cellSize = 10;

   if (!$arrayObj->hasFieldAxis()) {
      $cellSize = $arrayObj->getDataFormat->getWidth();
   } 

   my $colAxis;
   my $rowAxis;
   if ($arrayObj->hasColAxis) {
      $colAxis = $arrayObj->getColAxis();
   } else {
      $colAxis = $arrayObj->getAxisList->[0];
   }
   if ($arrayObj->hasRowAxis) {
      $rowAxis = $arrayObj->getRowAxis();
   } else {
      $rowAxis = $arrayObj->getAxisList->[1];
   }

   my @size = ($rowAxis->getSize(), $colAxis->getSize());

   my $locator = $arrayObj->createLocator;

   print $filehandle " horizontal axisId: ",$colAxis->getAxisId()," (size:",$colAxis->getSize(),")\n";
   print $filehandle "   vertical axisId: ",$rowAxis->getAxisId()," (size:",$rowAxis->getSize(),")\n";

   # now print formatted table
   my $halfSize = int($cellSize/2);
   my $otherSize = $cellSize - $halfSize;
   my $lead = " " x $cellSize;
   my $trail = " " x $otherSize;
   my $colLimit = $size[1]-1;
   print $filehandle "$lead";
   foreach my $col (0 .. $colLimit) {
     my $header = sprintf ('%'.$halfSize.'s', $col);
     print $filehandle "$trail$header ";
   }

   my $nrofUnderScore = ($colLimit+1)*($cellSize+1);
   my $underscoreString = "-" x $nrofUnderScore;
   print $filehandle "\n$lead $underscoreString\n";

   foreach my $row (0 .. ($size[0]-1)) {
     my $header = sprintf ('%'.$cellSize.'s', $row);
     print $filehandle "$header|";
     foreach my $col (0 .. $colLimit) {
       $locator->setAxisIndex($rowAxis, $row);
       $locator->setAxisIndex($colAxis, $col);
       my $datum = $arrayObj->getData($locator);
       $datum = " " unless defined $datum;
#       print $filehandle $datum . $data_separator;
       $datum = sprintf ('%'.$cellSize.'s', $datum);
       print $filehandle $datum;
       print $filehandle " " unless $col eq $colLimit;
     }
     print $filehandle "|\n";
   }
   print $filehandle "$lead $underscoreString\n";
}


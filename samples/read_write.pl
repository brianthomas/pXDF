#!/usr/bin/perl -w -I .. 

use XDF::BaseObject;
use XDF::Reader;
use strict;

# /** COPYRIGHT
#    read_write.pl Copyright (C) 2000 Brian Thomas,
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

my $DEBUG = 0;
my $QUIET = 1;

  # test file for reading in XDF files.
  my $file = $ARGV[0];

  print "Reading in XDF object from file: $file \n";

  my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );

  my $reader = new XDF::Reader();
  my $XDF = $reader->parseFile($file, \%options);
# not used anymore
#  my $XDF = &XDF::Reader::createXDFObjectFromFile($file, \%options);

  # configure the output style
  $XDF->Pretty_XDF_Output(1);  # use pretty print 
  $XDF->Pretty_XDF_Output_Indentation("   ");  # use 3 spaces for indentation 

  # write it back out 
  $XDF->toXMLFileHandle(\*STDOUT, 1);

 
  my $arrayObj = @{$XDF->getArrayList()}->[0];

  my $axis0 = @{$arrayObj->getAxisList()}->[0];
  my $axis1 = @{$arrayObj->getAxisList()}->[1];

  my $locator = $arrayObj->createLocator;

  $locator->setAxisIndex($axis0, 1);
  $locator->setAxisIndex($axis1, 2);

  print "DATA at col=1 row=2 (first ARRAY): [", $arrayObj->getData($locator), "]\n";

  # a little example of how to deal with notes
  foreach my $noteObj (@{$arrayObj->getNoteList}) {
     print "NOTE: ";
  
     if ( $noteObj->getValue() ) { # note has text in value

        print $noteObj->getValue();

     } elsif ($noteObj->refNoteObject()) { # note has refObj which holds the text 

        print $noteObj->refNoteObject()->value();

     } else { # EMPTY!! yikes, a wasted note node. 

        print "** EMPTY TEXT **";

     }

     print "\n";
  }

  exit 0;



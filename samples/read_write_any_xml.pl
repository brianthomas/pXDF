#!/usr/bin/perl -w -I .. 

use XDF::DOM::Parser;
use XDF::Specification;

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

my $DEBUG = 1;
my $QUIET = 1;

  unless ($#ARGV >= 0) {
    die "usage: $0 <xmlfile> > output.xml\n";
  }

  # test file for reading in XDF files.
  my $file = $ARGV[0];

  print "Reading in XDF object from file: $file \n";

  my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );

  my $parser = new XDF::DOM::Parser(
                                       NoExpand => 0,
                                       ParseParamEnt => 0,
                                       ExpandParamEnt => 1,
                                   );

  my $XDF_DOM = $parser->parsefile($file);

  my @xdfNodes = @{$XDF_DOM->getXDFElements};

  # just pick off the first object for now
  my $XDF = $xdfNodes[0]->getXDFObject;

# not used anymore
#  my $reader = new XDF::Reader();
#  my $XDF = $reader->parseFile($file, \%options);

  # configure the output style
  my $spec = XDF::Specification->getInstance;
  $spec->setPrettyXDFOutput(1);  # use pretty print 
  $spec->setPrettyXDFOutputIndentation("   ");  # use 3 spaces for indentation 

  # write back out ONLY the XDF portion 
#  $XDF->toXMLFileHandle(\*STDOUT, 1);

  # use this method IF you want the whole document to write 
  # back out again.
  print STDOUT $XDF_DOM->toString;

 
  my $arrayObj = @{$XDF->getArrayList()}->[0];

  my $axis0 = @{$arrayObj->getAxisList()}->[0];
  my $axis1 = @{$arrayObj->getAxisList()}->[1];

  my $locator = $arrayObj->createLocator;

  $locator->setAxisIndex($axis0, 1);
  $locator->setAxisIndex($axis1, 2);

  print STDERR "DATA at col=1 row=2 (first ARRAY): [", $arrayObj->getData($locator), "]\n";

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



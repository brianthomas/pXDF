#!/usr/bin/perl -w -I ..

# another program to show some manipulation of the XDF
# simple stuff - add/remove tickmarks, notes, parameters .. 

# /** COPYRIGHT
#    manipulate.pl Copyright (C) 2000 Brian Thomas,
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

use XDF::Array;
use strict;

  my $XDF = new XDF::Array();

  my $param = $XDF->addParameter({'name' => 'par1',}); 
  $param->addValue(0);
   

  print STDERR "Adding axes to Array\n";
  my $axisObj = $XDF->addAxis({'name' => 'axis1', 'axisId' => "axis1", 'description' => 'the first axis'});
  $XDF->addAxis({'name' => 'axis2', 'description' => 'the second axis'});
  $XDF->addAxis({'name' => 'axis2', 'axisId' => 'axis2', 'description' => 'the second axis'});

  # test for trying to add empty tickmark
  #$axisObj->addAxisValue(); 

  print STDERR "Adding axisValues to first axis.\n";
  $axisObj->addAxisValue(8); 
  my $removeObj = $axisObj->addAxisValue(9); 
  $axisObj->addAxisValue(10); 


  $XDF->addNote({'mark' => '1', 'value' => "one way to add a note"});
  $XDF->addNote("another simpler way to add the note");
  my $remove_obj = $XDF->addNote("A note that I will remove.");

  # test: try to remove the wrong type of object..
  $XDF->removeNote($removeObj);

  # ok, now try to remove the right type of object
  $XDF->removeNote($remove_obj);
  $axisObj->removeAxisValue($removeObj);


  # dump the XDF structure..
  foreach my $axisObj (@{$XDF->getAxisList()}) {
    print "AXIS: ", $axisObj->getName, " ", $axisObj->getDescription, "\n";
    foreach my $val ($axisObj->getAxisValues()) {
       print "      val: $val\n";
    }
  }

  foreach my $obj (@{$XDF->getParamList()}) {
    print "Param: ",$obj->getName(), " ", $obj->getValueList(), "\n";
  }

  foreach my $noteObj (@{$XDF->getNoteList()}) { print "NOTE: ",$noteObj->getValue(), "\n"; }

  exit 0;

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
use XDF::Axis;
use XDF::Parameter;
use strict;

  my $arrayObj = new XDF::Array();

  my $param = new XDF::Parameter ({'name' => 'par1',}); 
  $arrayObj->addParameter($param);
  $param->addValue(0);
   

  print STDERR "Adding axes to Array\n";
  my $axisObj = new XDF::Axis({'name' => 'axis1', 'axisId' => "axis1", 'description' => 'the first axis'});
  my $axisObj2 = new XDF::Axis({'name' => 'axis2', 'description' => 'the second axis'});
  $arrayObj->addAxis($axisObj);
  $arrayObj->addAxis($axisObj2);
  $arrayObj->addAxis($axisObj2);

  # test for trying to add empty tickmark
  #$axisObj->addAxisValue(); 

  print STDERR "Adding axisValues to first axis.\n";
  $axisObj->addAxisValue(new XDF::Value(8)); 
  my $removeObj = new XDF::Value(9); 
  $axisObj->addAxisValue($removeObj);
  $axisObj->addAxisValue(new XDF::Value(10)); 


  my $noteObj1 = new XDF::Note({'mark' => '1', 'value' => "one way to add a note"});
  my $noteObj2 = new XDF::Note("A note I will remove");
  $arrayObj->addNote($noteObj1);
  $arrayObj->addNote($noteObj2);
  my $remove_obj = $noteObj2;

  # test: try to remove the wrong type of object..
  $arrayObj->removeNote($removeObj);

  # ok, now try to remove the right type of object
  $arrayObj->removeNote($remove_obj);
  $axisObj->removeAxisValue($removeObj);


  # dump the XDF array
  foreach my $axisObj (@{$arrayObj->getAxisList()}) {
    print "AXIS: ", $axisObj->getName, " ", $axisObj->getDescription, "\n";
    foreach my $val ($axisObj->getAxisValues()) {
       print "      val: $val\n";
    }
  }

  foreach my $obj (@{$arrayObj->getParamList()}) {
    print "Param: ",$obj->getName(), " ", $obj->getValueList(), "\n";
  }

  foreach my $noteObj (@{$arrayObj->getNoteList()}) { print "NOTE: ",$noteObj->getValue(), "\n"; }

  exit 0;

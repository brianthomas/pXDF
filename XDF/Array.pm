
# $Id$

package XDF::Array;

# /** COPYRIGHT
#    Array.pm Copyright (C) 2000 Brian Thomas,
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
# XDF is the eXtensible Data Structure, which is an XML format designed to contain n-dimensional 
# scientific/mathematical data. XDF::Array is the basic container for the n-dimensional array data.
# It gives access to the array data and its descriptors (such as the array axii, associated
# parameters, notes, etc).
#@   
#@   
# Here is a diagram showing the inter-relations between these components
# of the XDF::Array in a 2-dimensional dataset with no fields.
#@   
#@ 
#@    axisValue -----> "9" "8" "7" "6" "5" "A"  .   .  "?"
#@    axisIndex ----->  0   1   2   3   4   5   .   .   n
#@ 
#@                      |   |   |   |   |   |   |   |   |
#@    axisIndex--\      |   |   |   |   |   |   |   |   |
#@               |      |   |   |   |   |   |   |   |   |
#@    axisValue  |      V   V   V   V   V   V   V   V   V
#@        |      |
#@        V      V      |   |   |   |   |   |   |   |   |
#@      "star 1" 0 --> -====================================> axis 0
#@      "star 2" 1 --> -|          8.1
#@      "star 3" 2 --> -|
#@      "star 4" 3 --> -|
#@      "star 5" 4 --> -|
#@      "star 6" 5 --> -|       7
#@         .     . --> -|
#@         .     . --> -|
#@         .     . --> -|
#@       "??"    m --> -|
#@                      |
#@                      v
#@                    axis 1
#@ 
#@ 
# */

#/** SYNOPSIS
#
# */

#/** SEE ALSO
# XDF::Relationship;
#*/

# use Carp;

use XDF::BaseObjectWithXMLElements;

use XDF::Axis;
use XDF::DataCube;
use XDF::DataFormat;
use XDF::FieldAxis;
use XDF::Locator;
use XDF::Log;
use XDF::Notes;
use XDF::Parameter;
use XDF::ParameterGroup;
use XDF::DelimitedXMLDataIOStyle;
use XDF::Units;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObjectWithXMLElements
@ISA = ("XDF::BaseObjectWithXMLElements");

# CLASS DATA
my $Flag_Decimal = &XDF::Constants::INTEGER_TYPE_DECIMAL;

my $Class_Node_Name = "array";
# order is important, put array node attributes
# first, then fieldAxis, axisList, dataCube, then notes

my @Local_Class_XML_Attributes = qw (
                                name
                                description
                                arrayId
                                appendTo
                                conversion
                                paramList
                                units
                                dataFormat
                                axisList
                                XMLDataIOStyle 
                                relation
                                dataCube
                                notes
                              );
my @Local_Class_Attributes = qw (
                             _paramGroupOwnedHash
                             _locatorList
                          );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# /** name
# The STRING description (short name) of this Array. 
# */
# /** description
# A scalar string description (long name) of this Array. 
# */
# /** arrayId
# A scalar string holding the array Id of this Array. 
# */
# /** axisList
# a SCALAR (ARRAY REF) of the list of L<XDF::Axis> objects held within this array.
# */
# /** paramList
# a SCALAR (ARRAY REF) of the list of L<XDF::Parameter> objects held within in this Array.
# */
# /** notes
# a SCALAR (Obj REF) of the object which holds the list of L<XDF::Note> objects associated with
# this array object.
# */
# /** dataCube
# a SCALAR (OBJECT REF) of the L<XDF::DataCube> object which is a matrix holding the mathematical data
# of this array.
# */
# /** dataFormat
# a SCALAR (OBJECT REF) of the L<XDF::DataFormat> object.
# */
# /** units
# a SCALAR (OBJECT REF) of the L<XDF::Units> object of this array. The XDF::Units object 
# is used to hold the XDF::Unit objects.
# */
# /** fieldAxis
# a SCALAR (OBJECT REF) of the L<XDF::FieldAxis> object.
# */

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# CLASS Methods

# /** classXMLNodeName
# This method returns the class node name of XDF::Array; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName { 
  $Class_Node_Name; 
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Array; 
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes { 
  \@Class_Attributes; 
}

# 
# SET/GET Methods
#

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $self->{name};
}

# /** setName
#     Set the name attribute. 
# */
sub setName {
   my ($self, $value) = @_;
   $self->{name} = $value;
}

# /** getDescription
#   
#  */
sub getDescription {
   my ($self) = @_;
   return $self->{description};
}

# /** setDescription
#     Set the description attribute. 
#  */
sub setDescription {
   my ($self, $value) = @_;
   $self->{description} = $value;
}

# /** getArrayId
#   
# */                 
sub getArrayId {                   
   my ($self) = @_;
   return $self->{arrayId};        
}                               
                                
# /** setArrayId
#     Set the arrayId attribute.   
# */                          
sub setArrayId {
   my ($self, $value) = @_;  
   $self->{arrayId} = $value;   
}

# /** getAppendTo
#   
# */                 
sub getAppendTo {                   
   my ($self) = @_;
   return $self->{appendTo};        
}                               
                                
# /** setAppendTo
#     Set the appendTo attribute.   
# */                          
sub setAppendTo {
   my ($self, $value) = @_;  
   $self->{appendTo} = $value;   
}

# /** getConversion
#   
#  */
sub getConversion {
   my ($self) = @_;
   return $self->{conversion};
}

# /** setConversion
#     Set how to convert values of the data in this array. 
#     Should NOT be set IF there is a field axis in the array.
#  */
sub setConversion {
   my ($self, $value) = @_;

   if ($self->hasFieldAxis && defined $value) {
      error("Cant set conversion in array, has a field axis, ignoring request");
      return;
   }
   $self->{conversion} = $value;
}

# /** getDataCube
# 
#  */
sub getDataCube { # PRIVATE
   my ($self) = @_;
   return $self->{dataCube};
}

# /** getAxisList
# 
#  */
sub getAxisList {
   my ($self) = @_;
   return $self->{axisList};
}

# /** setAxisList
# 
#  */
sub setAxisList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{axisList} = \@list;
}

# /** getParamList
# 
#  */
sub getParamList {
   my ($self) = @_;
   return $self->{paramList};
}

# /** setParamList
# 
#  */
sub setParamList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{paramList} = \@list;
}

# /** getNoteList
# 
#  */
sub getNoteList {
   my ($self) = @_;
   return $self->{notes}->{noteList};
}

# /** setNoteList
# 
#  */
sub setNoteList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{notes}->{noteList} = \@list;
}

# /** getDataFormat
# 
# */
sub getDataFormat {
   my ($self) = @_;
   return $self->{dataFormat};
}

# /** setDataFormat
# Sets the data format *type* for this array. Takes a SCALAR object reference
# as its argument. Allowed objects to pass to this method include 
# L<XDF::BinaryIntegerDataFormat>, L<XDF::BinaryFloatDataFormat>, L<XDF::FloatDataFormat>, 
# L<XDF::IntegerDataFormat>, or L<XDF::StringDataFormat>.
# */
sub setDataFormat {
   my ($self, $value) = @_;

   unless (&XDF::Utility::isValidDataFormat(ref $value)) {
     error("Cant set array DataFormat to $value, not allowed, ignoring \n");
     return;
   }

   $self->{dataFormat} = $value;
}

# /** getNotes
# Returns the notes object held by this object.
# */
sub getNotes { 
  my ($self, $what) = @_;
  return $self->{notes};
}

# /** setNotes
# 
# */
sub setNotes {
   my ($self, $value) = @_;
   $self->{notes} = $value;
}

# /** getUnits
# 
# */
sub getUnits {
   my ($self) = @_;
   return $self->{units};
}

# /** setUnits
# 
# */
sub setUnits {
   my ($self, $value) = @_;

   unless (&XDF::Utility::isValidUnits($value)) {
     error("Cant set array units to $value, not allowed, ignoring \n");
     return;
   }
  
   # no units in case of a field Axis
   if ($self->hasFieldAxis() && !$value->isUnitless()) {
      warn "Cant set array units to $value, array must be unitless if it has a fieldAxis, ignoring \n";
      return;
   }

   $self->{units} = $value;
}

# /** getFieldAxis
# 
# */
sub getFieldAxis {
  my ($self) = @_;
  my $axisObj = @{$self->{axisList}}[0];
  return ref($axisObj) eq 'XDF::FieldAxis' ? $axisObj : undef;
}

# /** getRowAxis
# 
# */
sub getRowAxis {
  my ($self) = @_;
  foreach my $axisObj ( @{$self->{axisList}}) 
  {
     return $axisObj if (ref($axisObj) eq "XDF::RowAxis");
  }
  return undef;
}

# /** getColAxis
# 
# */
sub getColAxis {
  my ($self) = @_;
  foreach my $axisObj ( @{$self->{axisList}}) 
  {
     return $axisObj if (ref($axisObj) eq "XDF::ColAxis"); 
  }
  return undef;
}

# /** setXMLDataIOStyle
# Set the XMLDataIOStyle object for this array.
# */
sub setXMLDataIOStyle {
  my ($self, $val) = @_;

  if (ref $val) {
    $self->{XMLDataIOStyle} = $val;

    # set the parent array to this object
    $self->{XMLDataIOStyle}->setParentArray($self);
  }

}

# /** getRelation
# */
sub getRelation {
   my ($self) = @_;
   return $self->{relation};
}

# /** setRelation
#     Set the relation attribute. 
# */
sub setRelation {
   my ($self, $value) = @_;
   $self->{relation} = $value;
}

# /** getXMLDataIOStyle
# Get the XMLDataIOStyle object for this array.
# Returns a SCALAR (OBJECT REF) holding an instance derived 
# from the abstract class L<XDF::DataIOStyle>.
# */
sub getXMLDataIOStyle {
  my ($self) = @_;
  return $self->{XMLDataIOStyle};
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# /** getDimension
# Get/set the dimension of the L<XDF::DataCube> held within this Array.
# */
sub getDimension {
  my ($self) = @_;
  return $self->{dataCube}->getDimension();
}

# /** getDataFormatList
# Get the dataFormatList for this array. 
# Returns an ARRAY of dataFormat objects.
# */
sub getDataFormatList {
  my ($self) = @_;

  if (defined (my $fieldAxis = $self->getFieldAxis()) ) {
    return $fieldAxis->getDataFormatList();
  } else {
    # no field axis? then we use the dataFormat in the array
    return ($self->getDataFormat()) if defined $self->getDataFormat();
  }

  return (); # opps, nothing defined!! 
}

# /** getCacheDataToDisk
# Determine if the data is being stored in system memory or in
# a (disk) file (e.g. simple database treatment).
# This is needed for large datasets which *wont* fit into memory
# on a given machine -or- may be helpfull to improve IO speed 
# on a medium size dataset which *will* fit in memory but requires 
# the machine to swap. The user must decide when its appropriate
# and your mileage may vary. 
# */
sub getCacheDataToDisk {
  my ($self) = @_;
  return $self->{dataCube}->_getCacheDataToDisk();
}

# /** setCacheDataToDisk
# This *may* work on populated Array but its much more safe
# to only alter this attribute *before* loading the data into the array.
# */
sub setCacheDataToDisk {
  my ($self, $cacheData) = @_;
  $self->{dataCube}->_setCacheDataToDisk($cacheData);
}

#
# Other public methods
#

# /** createLocator
# Create one instance of an L<XDF::Locator> object for this array.
# */
sub createLocator {
  my ($self) = @_;

  my $locatorObj = new XDF::Locator($self);

  # add to list of locators we are keeping track of
  push @{$self->{_locatorList}}, $locatorObj;
  return $locatorObj;
}

# /** addParamGroup
# Insert an XDF::ParameterGroup object into this object.
# This method takes either a reference to an attribute hash OR
# object reference to an existing XDF::ParameterGroup as
# its argument. Attributes in the attribute hash reference should
# correspond to attributes of the L<XDF::ParameterGroup> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::ParameterGroup object.
# returns: 1 on success, 0 on failure.
# */
sub addParamGroup {
  my ($self, $objectRef ) = @_;

  return 0 unless defined $objectRef && ref $objectRef;

  # add the group to the groupOwnedHash
  #%{$self->_paramGroupOwnedHash}->{$objectRef} = $objectRef;
  $self->_paramGroupOwnedHash->{$objectRef} = $objectRef;

  return 1;

}

# /** removeParamGroup
# Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups 
# held within this object. This method takes the hash key 
# its argument. 
# RETURNS : 1 on success, 0 on failure.
# */
sub removeParamGroup {
   my ($self, $hashKey) = @_;
   #return 0 unless (exists %{$self->_paramGroupOwnedHash}->{$hashKey});
   return 0 unless (exists $self->_paramGroupOwnedHash->{$hashKey});
   #delete %{$self->_paramGroupOwnedHash}->{$hashKey};
   delete $self->_paramGroupOwnedHash->{$hashKey};
   return 1;
}

# /** addAxis
# Insert an XDF::Axis object into this object.
# This method takes a reference to an attribute hash OR
# object reference to an existing XDF::Axis as
# its argument. Attributes in the attribute hash reference should
# correspond to attributes of the L<XDF::Axis> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Axis object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addAxis {
  my ($self, $axisObj ) = @_;

  return 0 unless $self->_can_add_axisObj_to_array($axisObj);

  # safety
  if (ref $axisObj eq 'XDF::FieldAxis') {
     return $self->setFieldAxis($axisObj);
  }

  # add this axis to the list 
  push @{$self->{axisList}}, $axisObj; 

  # bump up the number of dimensions
  $self->{dataCube}->{dimension} = $self->{dataCube}->{dimension} + 1;

  $self->getDataCube->_resetDataCube();

  $axisObj->setParentArray($self);

  return 1;
}

sub _isSimpleDataIOStyle {
  my ($self) = @_;

  return 1 if ($self->hasColAxis || $self->hasRowAxis);
  return 0;
}

# Can we add this axisObject to the array?
# 1- check to see that it has an id
# 2- we SHOULD also check that the id is unique but DONT currently.
sub _can_add_axisObj_to_array {
  my ($self, $axisObj) = @_;

  unless (defined $axisObj) {
     error("Can't add undefined Axis object.\n");
     return 0;
  }

  unless (defined $axisObj->getAxisId() ) {
     if (ref $axisObj eq 'XDF::ColAxis' or ref $axisObj eq 'XDF::RowAxis') {
        error("Array needs to assign an axisId to the row/colAxis, as the current axis object doesnt have one defined.\n");
        return 0;
     } else {
        error("Can't add Axis object wi/o axisId attribute defined.\n");
        return 0;
     }
  }

  if (ref $axisObj eq 'XDF::FieldAxis') {

     if($self->hasFieldAxis()) {
        error("Can't add second field axis to array. Remove old FieldAxis object first.\n");
        return 0;
     }

  } elsif (ref $axisObj eq 'XDF::RowAxis') {

     if($self->hasRowAxis()) {
        error("Can't add second row Axis to array. Remove old RowAxis object first.\n");
        return 0;
     }

  #   if(!$self->hasColAxis() && !$self->hasFieldAxis()) {
  #      error("Can't add row Axis to array without a column/field Axis. Please add either a FieldAxis or ColAxis object first.\n");
  #      return 0;
  #   }

     if($self->getDimension() > 1 and !$self->hasColAxis() and !$self->hasRowAxis() and !$self->hasFieldAxis()) {
        error("Can't add row axis to array with regular axes defined. Please remove the other Axis object(s) first.\n");
        return 0;
     }

  } elsif (ref $axisObj eq 'XDF::ColAxis') {

     if($self->hasFieldAxis()) {
        error("Can't add column axis to array, already has FieldAxis. Remove FieldAxis object first.\n");
        return 0;
     }

     if($self->hasColAxis()) {
        error("Can't add second column axis to array. Remove old ColAxis object first.\n");
        return 0;
     }

     if($self->getDimension() > 1 and !$self->hasColAxis() and !$self->hasRowAxis() and !$self->hasFieldAxis()) {
        error("Can't add column axis to array with regular axes defined. Please remove the other Axis object(s) first.\n");
        return 0;
     }

  } elsif (ref $axisObj eq 'XDF::Axis') {

     if ($self->hasColAxis() || $self->hasRowAxis()) {
        error("Can't add plain axis to array which has row/col axes. Remove old ColAxis/RowAxis object(s) first.\n");
        return 0;
     }

  }

  return 1;
}

# /** removeAxis
# Remove an XDF::Axis object from the list of XDF::Axes
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeAxis {
   my ($self, $axisObj) = @_;
   if (defined $axisObj && $self->_remove_from_list($axisObj, $self->{axisList}, 'axisList')) {
     $axisObj->setParentArray(undef);
     $self->{dataCube}->{dimension} = $self->{dataCube}->getDimension() - 1;
     $self->getDataCube->_resetDataCube();
     return 1;
   } else {
     return 0;
   }
}

# /** hasFieldAxis
# 
# */
sub hasFieldAxis {
  my ($self) = @_;
  return defined $self->getFieldAxis() ? 1 : 0;
}

# /** hasRowAxis
# 
# */
sub hasRowAxis {
  my ($self) = @_;
  return defined $self->getRowAxis() ? 1 : 0;
}

# /** hasColAxis 
# 
# */
sub hasColAxis {
  my ($self) = @_;
  return defined $self->getColAxis() ? 1 : 0;
}

# /** addUnit
# Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)
# held in this object.
# This method takes either a reference to an attribute hash OR
# object reference to an existing XDF::Unit as
# its argument. Attributes in the attribute hash reference should
# correspond to attributes of the L<XDF::Unit> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Unit object.
# RETURNS : 1 if successfull, 0 if not. 
sub addUnit {
   my ($self, $unitObj ) = @_;
   return $self->{units}->addUnit($unitObj);
}

# /** removeUnit
# Remove an XDF::Unit object from the list of XDF::Units held in
# the array units reference object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeUnit { 
  my ($self, $indexOrObjectRef) = @_;
  return $self->{units}->removeUnit($indexOrObjectRef); 
}


# /** addParameter 
# Insert an XDF::Parameter object into this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Parameter> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Parameter object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addParameter {
  my ($self, $paramObj ) = @_;

  return 0 unless defined $paramObj && ref($paramObj);

  # add the parameter to the list
  push @{$self->{paramList}}, $paramObj;

  return 1;
}

# /** removeParameter 
# Remove an XDF::Parameter object from the list of XDF::Parameters
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeParameter {
   my ($self, $indexOrObjectRef) = @_;
   return $self->_remove_from_list($indexOrObjectRef, $self->{paramList}, 'paramList');
}

# /** addNote
# Insert an XDF::Note object into the XDF::Notes object held by this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addNote {
   my ($self, $noteObj ) = @_;
   return $self->{notes}->addNote($noteObj);
}

# /** removeNote
# Removes an XDF::Note object from the list of XDF::Note objects
# held within the XDF::Notes object of this object. This method takes 
# either the list index number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  $self->getNotes()->removeNote($what);
}

# /** addData
# Append the SCALAR value onto the requested datacell (via L<XDF::DataCube> LOCATOR REF).
# RETURNS : 1 on success, 0 on failure.
# */
sub addData {
  #my ($self, $locator, $dataValue) = @_;
  my $self = shift;
  return $self->{dataCube}->_addData(@_); #$self->{axisList}, @_);
}

# /** setData
# Set the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF).
# Overwrites existing datacell value if any.
# */
sub setData {
  #my ($self, $locator, $dataValue) = @_;
  my $self = shift;
  $self->{dataCube}->_setData(@_); #$self->{axisList}, @_);
}

sub setRecords {
   my ($self, $locator, $data_array_ref ) = @_;
   $self->{dataCube}->_setRecords($locator, $data_array_ref);
}

sub getRecords {
   my ($self, $locator, $nrofRecords) = @_;
   return $self->{dataCube}->_getRecords($locator, $nrofRecords);
}

# /* removeData
# Remove the requested data from the 
# indicated datacell (via L<XDF::DataCube> LOCATOR REF) in the XDF::DataCube held in this Array. 
# B<NOT CURRENTLY IMPLEMENTED>. 
# */
# sub removeData {
#  my ($self, $locator, $data) = @_;
#  $self->{dataCube}->removeData($locator, $data);
# }

# /** getData
# Retrieve the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF).
# */
sub getData {
  my ($self, $locator ) = @_;
  return $self->{dataCube}->_getData($locator);
}

# /** setFieldAxis
# Set the Field Axis of this Array. If an undef value is passed,
# then the field Axis is removed from the array.
# RETURNS : 1 on success, 0 on failure.
# */
sub setFieldAxis {
  my ($self, $fieldAxisObj) = @_;

  if (defined $fieldAxisObj) {
 
     return 0 unless $self->_can_add_axisObj_to_array($fieldAxisObj);

     # By convention, the fieldAxis is always first axis in the axis list.
     # Make sure that we *replace* the existing fieldAxis, if it exists.
     shift @{$self->{axisList}} if ref(@{$self->{axisList}}[0]) eq 'XDF::FieldAxis';
     unshift @{$self->{axisList}}, $fieldAxisObj;

     # bump up the number of dimensions
     $self->{dataCube}->{dimension} = $self->{dataCube}->getDimension() + 1;

     $self->getDataCube->_resetDataCube();

     $fieldAxisObj->setParentArray($self);

     # undef the units
     # no units in case of a field Axis
     if (!$self->{units}->isUnitless()) {
        info ("Now that array ($self) has a fieldAxis, setting array units to unitless.\n");
     }
     $self->{units}->makeUnitless();

     $self->{conversion} = undef; # cant have this set IF there is a field axis 

     return 1;

  } else {

     # we must have units now
     # $self->{units} = new XDF::Units(); # this isnt true (may want unitless?)

     # remove the field Axis
     return $self->removeFieldAxis();
  }

}

# /** removeFieldAxis
# Removes the L<XDF::FieldAxis> object in this Array.
# Returns 1 on success, 0 on failure.
# */
sub removeFieldAxis { 
   my ($self) = @_; 

   my $fieldAxis;
   if (ref(@{$self->{axisList}}[0]) eq 'XDF::FieldAxis') {
      $fieldAxis = shift @{$self->{axisList}};
      $self->{dataCube}->{dimension} = $self->{dataCube}->{dimension} - 1;
      $fieldAxis->setParentArray(undef);
      $self->getDataCube->_resetDataCube();
      return 1;
   }

   return 0;
}

# /** parseAndLoadDataString
# Cause the given dataString to be read in as directed by 
# the various settings in this array (e.g. XMLDataIOStyle, DataFormat, etc).
# The data String may be either in the Formatted or Delimited DataIOStyles.
# If delayLoad is true, then the data will be cached for later parsing/loading 
# when it is actually demaned by the user. Using this setting speeds loading
# (and then accessing) meta-data in Arrays with large amounts of data.
# */
sub parseAndLoadDataString {
  my ($self, $locator, $dataBlock, $startByte, $endByte, $delayLoad) = @_;
  my $formatObj = $self->getXMLDataIOStyle();
  $self->{dataCube}->_parseAndLoadDataString($dataBlock, $locator, $formatObj, $startByte, $endByte, $delayLoad);
}

# /** reloadAllExternalData
# This method will cause the array to (re)-load all of 
# the External href resource data into itself (again).
# */
sub reloadAllExternalData {
  my ($self) = @_;
  $self->{dataCube}->_load_external_data();
}

# /** hasSpecialIntegers
# Returns true if one or more fields in this array contain non-decimal
# ASCII integer data (binary data are excepted).
# */
sub hasSpecialIntegers {
  my ($self) = @_;

  my @dataFormatList = $self->getDataFormatList();
  return 0 if (!@dataFormatList);

  foreach my $dataType (@dataFormatList) {
    if (ref($dataType) eq 'XDF::IntegerDataFormat') {
      return 1 if $dataType->getType() ne $Flag_Decimal;
    }
  }
  return 0;
}

# /** hasBinaryData
# Returns true if one or more fields in this array contain binary data.
# */
sub hasBinaryData {
  my ($self) = @_;

  my @dataFormatList = $self->getDataFormatList();
  return 0 if (!@dataFormatList);

  foreach my $dataType (@dataFormatList) {
    return 1 if ref($dataType) =~ m/XDF::Binary/;
  }

  return 0;
}


#
# Private Methods
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# private method called from XDF::BaseObject->new
sub _init {
  my ($self) = @_;

  $self->SUPER::_init(); 

  # initalize objects we always have
  $self->{dataCube} = new XDF::DataCube();
  $self->{dataCube}->{_parentArray} = $self; # cross reference w/ dataCube 
  $self->{dataFormat} = new XDF::StringDataFormat();
  $self->{units} = new XDF::Units();
  $self->{notes} = new XDF::Notes();
  $self->setXMLDataIOStyle(new XDF::DelimitedXMLDataIOStyle($self)); # set the default IO style to Delimited

  # initialize lists/hashes 
  $self->{axisList} = [];
  $self->{paramList} = [];

  $self->{_paramGroupOwnedHash} = {};

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# happens when a new axisValue or Field is added to an axis.
# Could REALLY SLOW down the code if you had big operations 
# to do and had one or more locators open. Ugh.
sub _updateAllLocatorInternalLookupIndices {
  my ($self) = @_;

  foreach my $locator (@{$self->{_locatorList}})
  {
     $locator->_updateInternalLookupIndices();
  }
}

# remove a locator from the internal list
# *should* happen when the locator destroys itself
sub _removeLocator {
   my ($self,$locator) = @_;
#   return $self->_remove_from_list($locator, $self->{_locatorList}, 'locatorList');
}


1;


__END__

=head1 NAME

XDF::Array - Perl Class for Array

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 XDF is the eXtensible Data Structure, which is an XML format designed to contain n-dimensional  scientific/mathematical data. XDF::Array is the basic container for the n-dimensional array data.  It gives access to the array data and its descriptors (such as the array axii, associated parameters, notes, etc).     
    
 Here is a diagram showing the inter-relations between these components of the XDF::Array in a 2-dimensional dataset with no fields.     
  
     axisValue -----> "9" "8" "7" "6" "5" "A"  .   .  "?"
     axisIndex ----->  0   1   2   3   4   5   .   .   n
  
                       |   |   |   |   |   |   |   |   |
     axisIndex--\      |   |   |   |   |   |   |   |   |
                |      |   |   |   |   |   |   |   |   |
     axisValue  |      V   V   V   V   V   V   V   V   V
         |      |
         V      V      |   |   |   |   |   |   |   |   |
       "star 1" 0 --> -====================================> axis 0
       "star 2" 1 --> -|          8.1
       "star 3" 2 --> -|
       "star 4" 3 --> -|
       "star 5" 4 --> -|
       "star 6" 5 --> -|       7
          .     . --> -|
          .     . --> -|
          .     . --> -|
        "??"    m --> -|
                       |
                       v
                     axis 1
  
  


XDF::Array inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::BaseObjectWithXMLElements>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Array.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Array; This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

 

=item getClassXMLAttributes (EMPTY)

 

=item addData (EMPTY)

Append the SCALAR value onto the requested datacell (via L<XDF::DataCube> LOCATOR REF). RETURNS : 1 on success, 0 on failure.  

=item setData (EMPTY)

Set the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF). Overwrites existing datacell value if any.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Array.

=over 4

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription (EMPTY)

 

=item setDescription ($value)

Set the description attribute.  

=item getArrayId (EMPTY)

 

=item setArrayId ($value)

Set the arrayId attribute.    

=item getAppendTo (EMPTY)

 

=item setAppendTo ($value)

Set the appendTo attribute.    

=item getLessThanValue (EMPTY)

 

=item setLessThanValue ($value)

Set the lessThanValue attribute.  

=item getLessThanOrEqualValue (EMPTY)

 

=item setLessThanOrEqualValue ($value)

Set the lessThanOrEqualValue attribute.  

=item getGreaterThanValue (EMPTY)

 

=item setGreaterThanValue ($value)

Set the greaterThanValue attribute.  

=item getGreaterThanOrEqualValue (EMPTY)

 

=item setGreaterThanOrEqualValue ($value)

Set the greaterThanOrEqualValue attribute.  

=item getInfiniteValue (EMPTY)

 

=item setInfiniteValue ($value)

Set the infiniteValue attribute.  

=item getInfiniteNegativeValue (EMPTY)

 

=item setInfiniteNegativeValue ($value)

Set the infiniteNegativeValue attribute.  

=item getNoDataValue (EMPTY)

 

=item setNoDataValue ($value)

Set the noDataValue attribute.  

=item getNotANumberValue (EMPTY)

 

=item setNotANumberValue ($value)

Set the notANumberValue attribute.  

=item getOverFlowValue (EMPTY)

 

=item setOverFlowValue ($value)

Set the overFlowValue attribute.  

=item getUnderFlowValue (EMPTY)

 

=item setUnderFlowValue ($value)

Set the underFlowValue attribute.  

=item getDisabledValue (EMPTY)

 

=item setDisabledValue ($value)

Set the disabledValue attribute.  

=item getDataCube (EMPTY)

 

=item getAxisList (EMPTY)

 

=item setAxisList ($arrayRefValue)

 

=item getParamList (EMPTY)

 

=item setParamList ($arrayRefValue)

 

=item getNoteList (EMPTY)

 

=item setNoteList ($arrayRefValue)

 

=item getDataFormat (EMPTY)

 

=item setDataFormat ($value)

Sets the data format *type* for this array. Takes a SCALAR object referenceas its argument. Allowed objects to pass to this method include L<XDF::BinaryIntegerDataFormat>, L<XDF::BinaryFloatDataFormat>, L<XDF::FloatDataFormat>, L<XDF::IntegerDataFormat>, or L<XDF::StringDataFormat>.  

=item getNotes ($what)

Returns the notes object held by this object.  

=item setNotes ($value)

 

=item getUnits (EMPTY)

 

=item setUnits ($value)

 

=item getFieldAxis (EMPTY)

 

=item setXMLDataIOStyle ($val)

Set the XMLDataIOStyle object for this array.  

=item getXMLDataIOStyle (EMPTY)

Get the XMLDataIOStyle object for this array. Returns a SCALAR (OBJECT REF) holding an instance derived from the abstract class L<XDF::DataIOStyle>.  

=item getDimension (EMPTY)

Get/set the dimension of the L<XDF::DataCube> held within this Array.  

=item getDataFormatList (EMPTY)

Get the dataFormatList for this array. Returns an ARRAY of dataFormat objects.  

=item createLocator (EMPTY)

Create one instance of an L<XDF::Locator> object for this array.  

=item addParamGroup ($objectRef)

Insert an XDF::ParameterGroup object into this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::ParameterGroup asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::ParameterGroup> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::ParameterGroup object. returns: 1 on success, 0 on failure.  

=item removeParamGroup ($hashKey)

Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups held within this object. This method takes the hash key its argument. RETURNS : 1 on success, 0 on failure.  

=item addAxis ($axisObj)

Insert an XDF::Axis object into this object. This method takes a reference to an attribute hash ORobject reference to an existing XDF::Axis asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::Axis> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Axis object. RETURNS : 1 on success, 0 on failure.  

=item removeAxis ($axisObj)

Remove an XDF::Axis object from the list of XDF::Axesheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item hasFieldAxis (EMPTY)

 

=item addUnit ($unitObj)

Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)held in this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::Unit asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::Unit> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Unit object. RETURNS : 1 if successfull, 0 if not.  

=item removeUnit ($indexOrObjectRef)

Remove an XDF::Unit object from the list of XDF::Units held inthe array units reference object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item addParameter ($paramObj)

Insert an XDF::Parameter object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Parameter> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Parameter object. RETURNS : 1 on success, 0 on failure.  

=item removeParameter ($indexOrObjectRef)

Remove an XDF::Parameter object from the list of XDF::Parametersheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item addNote ($noteObj)

Insert an XDF::Note object into the XDF::Notes object held by this object. RETURNS : 1 on success, 0 on failure.  

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item setRecords ($locator, $data_array_ref)

 

=item getRecords ($locator, $nrofRecords)

 

=item getData ($locator)

Retrieve the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF).  

=item setFieldAxis ($fieldAxisObj)

Set the Field Axis of this Array. If an undef value is passed,then the field Axis is removed from the array. RETURNS : 1 on success, 0 on failure.  

=item removeFieldAxis (EMPTY)

Removes the L<XDF::FieldAxis> object in this Array. Returns 1 on success, 0 on failure.  

=item hasFieldAxis (EMPTY)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Array inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Array inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::Array inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElements>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObjectWithXMLElements>, L<XDF::Axis>, L<XDF::DataCube>, L<XDF::DataFormat>, L<XDF::FieldAxis>, L<XDF::Locator>, L<XDF::Notes>, L<XDF::Parameter>, L<XDF::ParameterGroup>, L<XDF::DelimitedXMLDataIOStyle>, L<XDF::Units>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

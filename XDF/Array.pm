
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

use Carp;

use XDF::Object;

use XDF::Axis;
use XDF::DataCube;
use XDF::DataFormat;
use XDF::FieldAxis;
use XDF::Locator;
use XDF::Note;
use XDF::Parameter;
use XDF::ParameterGroup;
use XDF::TaggedXMLDataIOStyle;
use XDF::Units;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my $Class_Node_Name = "array";
# order is important, put array node attributes
# first, then fieldAxis, axisList, dataCube, then noteList 
                     #fieldAxis
my @Class_Attributes = qw (
                             name
                             description
                             paramList
                             units
                             dataFormat
                             axisList
                             XmlDataIOStyle 
                             dataCube
                             noteList   
                             _paramGroupOwnedHash
                             _locatorOrder
                          );

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
# /** noteList
# a SCALAR (ARRAY REF) of the list of L<XDF::Note> objects held within this object.
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

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

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
sub classAttributes { 
  \@Class_Attributes; 
}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# private method called from XDF::Object->new
sub _init {
  my ($self) = @_;

  # initalize objects we always have
  $self->dataCube(new XDF::DataCube());
  $self->dataCube->_parentArray($self); # cross reference w/ dataCube 
  $self->units(new XDF::Units());
  $self->XmlDataIOStyle(new XDF::TaggedXMLDataIOStyle()); # set the default IO style to Tagged.

  # initialize variables
  $self->dimension(0);

  # initialize lists/hashes 
  $self->axisList([]);
  $self->paramList([]);
  $self->noteList([]);
  $self->_paramGroupOwnedHash({}); 

}

# /** XmlDataIOStyle
# Get/set the XMLDataIOStyle object for this array.
# Returns a SCALAR (OBJECT REF) holding an instance derived 
# from the abstract class L<XDF::DataIOStyle>.
# */
# Note that we have to use this special method (instead of relying
# on XDF::Object AUTOLOAD) to insure that _parentArray is properly
# updated.
sub XmlDataIOStyle {
  my ($self, $val) = @_;

  $self->{XmlDataIOStyle} = $val if defined $val;
  # set the parent array to this object
  $self->{XmlDataIOStyle}->_parentArray($self);

  return $self->{XmlDataIOStyle};
}

# /** dimension
# Get/set the dimension of the L<XDF::DataCube> held within this Array.
# */
sub dimension {
  my ($self, $dimension) = @_;

  $self->dataCube()->dimension($dimension) if defined $dimension;
  return $self->dataCube()->dimension();
}

# /** createLocator
# Create one instance of an L<XDF::Locator> object for this array.
# */
sub createLocator {
  my ($self) = @_;

  my $locatorObj = new XDF::Locator({'_parentArray' => $self});
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
# RETURNS : an XDF::ParameterGroup object reference on success, undef on failure.
# */
sub addParamGroup {
  my ($self, $objectRefOrAttribHashRef ) = @_;

  return unless defined $objectRefOrAttribHashRef && ref $objectRefOrAttribHashRef;

  my $groupObj;
  if ($objectRefOrAttribHashRef =~ m/XDF::ParameterGroup/) {
    $groupObj = $objectRefOrAttribHashRef;
  } else {
    $groupObj = new XDF::ParameterGroup($objectRefOrAttribHashRef);
  }

  # add the group to the groupOwnedHash
  %{$self->_paramGroupOwnedHash}->{$groupObj} = $groupObj;

  return $groupObj;
}

# /** removeParamGroup
# Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups 
# held within this object. This method takes the hash key 
# its argument. RETURNS : 1 on success, undef on failure.
# */
sub removeParamGroup {
  my ($self, $hashKey) = @_;
  delete %{$self->_paramGroupOwnedHash}->{$hashKey};
}

# /** addAxis
# Insert an XDF::Axis object into this object.
# This method takes a reference to an attribute hash OR
# object reference to an existing XDF::Axis as
# its argument. Attributes in the attribute hash reference should
# correspond to attributes of the L<XDF::Axis> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Axis object.
# RETURNS : an XDF::Axis object reference on success, undef on failure.
# */
sub addAxis {
  my ($self, $attribHashRefOrObjectRef ) = @_;

  my $axisObj = $attribHashRefOrObjectRef;

  if (ref $attribHashRefOrObjectRef eq 'HASH') {
    $axisObj = XDF::Axis->new($attribHashRefOrObjectRef);
  }

  return unless &_can_add_axisObj_to_array($axisObj);

  # add this axis to the list 
  push @{$self->axisList}, $axisObj; 

  # bump up the number of dimensions
  $self->dimension(0) unless defined $self->dimension();
  $self->dimension( $self->dimension() + 1 );

  return $axisObj;
}

# Can we add this axisObject to the array?
# 1- check to see that it has an id
# 2- we SHOULD also check that the id is unique but DONT currently.
sub _can_add_axisObj_to_array {
  my ($axisObj) = @_;

  unless (defined $axisObj and defined $axisObj->axisId ) {
     carp "Can't add Axis object wi/o axisId attribute defined.\n";
     return 0;
  }
  return 1;
}

# /** removeAxis
# Remove an XDF::Axis object from the list of XDF::Axes
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeAxis {
  my ($self, $indexOrObjectRef) = @_;
  # NOT the whole story. We have to deal with clearing up the 
  # DataIOStyle object (see addAxis above)
  $self->_remove_from_list($indexOrObjectRef, $self->axisList(), 'axisList');
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
# RETURNS : an XDF::Unit object if successfull, undef if not. 
sub addUnit { my ($self, $attribHashRefOrObjectRef) = @_;
   my $unitObj = $self->units()->addUnit($attribHashRefOrObjectRef);
   return $unitObj;
}

# /** removeUnit
# Remove an XDF::Unit object from the list of XDF::Units held in
# the array units reference object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeUnit { 
  my ($self, $indexOrObjectRef) = @_;
  return $self->units()->removeUnit($indexOrObjectRef); 
}


# /** addParameter 
# Insert an XDF::Parameter object into this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Parameter> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Parameter object.
# RETURNS : an XDF::Parameter object reference on success, undef on failure.
# */
sub addParameter {
  my ($self, $attribHashReference) = @_;

  my $paramObj = XDF::Parameter->new($attribHashReference);

  # add the parameter to the list
  push @{$self->paramList}, $paramObj;

  return $paramObj;
}

# /** removeParameter 
# Remove an XDF::Parameter object from the list of XDF::Parameters
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeParameter {
  my ($self, $indexOrObjectRef) = @_;
  $self->_remove_from_list($indexOrObjectRef, $self->paramList(), 'paramList');
}

# /** setDataFormat
# Sets the data format *type* for this array (an XDF::DataFormat object
# is held in the attribute $obj->dataFormat, its type is accessible
# as $obj->dataFormat->type). Takes a SCALAR object reference
# as its argument. Allowed objects to pass to this method include 
# L<XDF::BinaryIntegerDataFormat>, L<XDF::BinaryFloatDataFormat>, L<XDF::ExponentDataFormat>, 
# L<XDF::FixedDataFormat>, L<XDF::IntegerDataFormat>, or L<XDF::StringDataFormat>.
# RETURNS an object reference if successfull, undef if not.
# */
sub setDataFormat {
   my ($self, $objectRef) = @_;

   return unless defined $objectRef && ref $objectRef;
   $self->dataFormat(new XDF::DataFormat()) unless defined $self->dataFormat;
   return $self->dataFormat()->type($objectRef);
}

# /** maxDataIndices
# A convenience method [same as $ArrayObj->dataCube()->maxDimensionIndex].
# Returns a SCALAR ARRAY REF of SCALARS (non-negative INTEGERS) which are the maximum index
# values along each dimension (FieldAxis and Axis objects).
# */
sub maxDataIndices {
  my ($self) = @_;
  my @indices = defined $self->dataCube()->maxDimensionIndex() ?
      @{$self->dataCube()->maxDimensionIndex()} : (-1);
  return \@indices;
}

# /** addNote
# Insert an XDF::Note object into the XDF::Notes object held by this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Note> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Note object.
# RETURNS : an XDF::Note object reference on success, undef on failure.
# */
sub addNote {
  my ($self, $info) = @_;

  my $noteObj;
  if(ref $info && $info =~ m/XDF::Note/) {
    $noteObj = $info if(ref $info && $info =~ m/XDF::Note/);
  } else {
    $noteObj = XDF::Note->new($info);
  }

  # add the parameter to the list
  push @{$self->noteList}, $noteObj;

  return $noteObj;
}

# /** removeNote
# Removes an XDF::Note object from the list of XDF::Note objects
# held within the XDF::Notes object of this object. This method takes 
# either the list index number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->noteList(), 'noteList');
}

# /** getNotes
# Convenience method which returns a list of the notes held by this object.
# */
sub getNotes { 
  my ($self, $what) = @_; 
  return @{$self->noteList}; 
}
  
# /** addData
# Append the SCALAR value onto the requested datacell (via L<XDF::DataCube> LOCATOR REF).
# */
sub addData {
  my ($self, $locator, $dataValue) = @_;
  $self->dataCube()->addData($locator, $dataValue);
}

# /** setData
# Set the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF).
# Overwrites existing datacell value if any.
# */
sub setData {
  my ($self, $locator, $dataValue ) = @_;
  $self->dataCube()->setData($locator, $dataValue);
}

# /** removeData
# Remove the requested data from the 
# indicated datacell (via L<XDF::DataCube> LOCATOR REF) in the XDF::DataCube held in this Array. 
# B<NOT CURRENTLY IMPLEMENTED>. 
# */
sub removeData {
  my ($self, $locator, $data) = @_;
  $self->dataCube()->removeData($locator, $data);
}

# /** getData
# Retrieve the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF).
# */
sub getData {
  my ($self, $locator ) = @_;
  return $self->dataCube()->getData($locator);
}

# /** dataFormatList
# Get the dataFormatList for this array. 
# */
sub dataFormatList {
  my ($self) = @_;

  if (defined (my $fieldAxis = $self->fieldAxis()) ) {
    return $fieldAxis->dataFormatList;
  } else {
    # no field axis? then we use the dataFormat in the array
    return ($self->dataFormat()) if defined $self->dataFormat;
  }

  return; # opps, nothing defined!! 
}

# /** addFieldAxis
# A convenience method (same as $Array->fieldAxis($fieldAxisObj)).
# Changes the L<XDF::FieldAxis> object in this Array to the indicated one.
# */
sub addFieldAxis {
  my ($self, $attribHashRefOrObjectRef ) = @_;

  my $fieldAxisObj = $attribHashRefOrObjectRef;
  $fieldAxisObj = XDF::FieldAxis->new($attribHashRefOrObjectRef)
     if ref($attribHashRefOrObjectRef) eq 'HASH';

  return unless &_can_add_axisObj_to_array($fieldAxisObj);

  # By convention, the fieldAxis is always first axis in the axis list.
  # Make sure that we *replace* the existing fieldAxis, if it exists.
  shift @{$self->axisList} if ref(@{$self->axisList}[0]) eq 'XDF::FieldAxis';
  unshift @{$self->axisList}, $fieldAxisObj;

  # bump up the number of dimensions
  $self->dimension(0) unless defined $self->dimension();
  $self->dimension( $self->dimension() + 1 );

  return $fieldAxisObj;
}

# /** removeFieldAxis
# A convenience method (same as $Array->fieldAxis(undef)). 
# Removes the L<XDF::FieldAxis> object in this Array.
# B<CURRENTLY BROKEN>!
# */
sub removeFieldAxis { 
  my ($self) = @_; 

# $self->fieldAxis(undef); # this WONT work!!
#  $self->dimension( $self->dimension() - 1 );
  warn "RemoveField Axis is not currently implemented\n";
}

# /** fieldAxis
# Set/get the fieldAxis in this array. 
# */
sub fieldAxis {
  my ($self, $value) = @_;

  $self->addFieldAxis($value) if defined $value && ref($value);
  my $axisObj = @{$self->axisList}[0];
  return ref($axisObj) eq 'XDF::FieldAxis' ? $axisObj : undef;
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
  
  


XDF::Array inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Array.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Array; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Array; This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

The STRING description (short name) of this Array.  

=item description

A scalar string description (long name) of this Array.  

=item paramList

a SCALAR (ARRAY REF) of the list of L<XDF::Parameter> objects held within in this Array.  

=item units

a SCALAR (OBJECT REF) of the L<XDF::Units> object of this array. The XDF::Units object is used to hold the XDF::Unit objects.  

=item dataFormat

a SCALAR (OBJECT REF) of the L<XDF::DataFormat> object.  

=item axisList

a SCALAR (ARRAY REF) of the list of L<XDF::Axis> objects held within this array.  

=item XmlDataIOStyle 

 

=item dataCube

a SCALAR (OBJECT REF) of the L<XDF::DataCube> object which is a matrix holding the mathematical dataof this array.  

=item noteList   

 

=back

=head2 OTHER Methods

=over 4

=item XmlDataIOStyle ($val)

Get/set the XMLDataIOStyle object for this array. Returns a SCALAR (OBJECT REF) holding an instance derived from the abstract class L<XDF::DataIOStyle>. 

=item dimension ($dimension)

Get/set the dimension of the L<XDF::DataCube> held within this Array. 

=item createLocator (EMPTY)

Create one instance of an L<XDF::Locator> object for this array. 

=item addParamGroup ($objectRefOrAttribHashRef)

Insert an XDF::ParameterGroup object into this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::ParameterGroup asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::ParameterGroup> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::ParameterGroup object. RETURNS : an XDF::ParameterGroup object reference on success, undef on failure. 

=item removeParamGroup ($hashKey)

Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups held within this object. This method takes the hash key its argument. RETURNS : 1 on success, undef on failure. 

=item addAxis ($attribHashRefOrObjectRef)

Insert an XDF::Axis object into this object. This method takes a reference to an attribute hash ORobject reference to an existing XDF::Axis asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::Axis> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Axis object. RETURNS : an XDF::Axis object reference on success, undef on failure. 

=item removeAxis ($indexOrObjectRef)

Remove an XDF::Axis object from the list of XDF::Axesheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item addUnit (EMPTY)

Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)held in this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::Unit asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::Unit> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Unit object. RETURNS : an XDF::Unit object if successfull, undef if not. 

=item removeUnit ($indexOrObjectRef)

Remove an XDF::Unit object from the list of XDF::Units held inthe array units reference object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item addParameter ($attribHashReference)

Insert an XDF::Parameter object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Parameter> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Parameter object. RETURNS : an XDF::Parameter object reference on success, undef on failure. 

=item removeParameter ($indexOrObjectRef)

Remove an XDF::Parameter object from the list of XDF::Parametersheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item setDataFormat ($objectRef)

Sets the data format *type* for this array (an XDF::DataFormat objectis held in the attribute $obj->dataFormat, its type is accessibleas $obj->dataFormat->type). Takes a SCALAR object referenceas its argument. Allowed objects to pass to this method include L<XDF::BinaryIntegerDataFormat>, L<XDF::BinaryFloatDataFormat>, L<XDF::ExponentDataFormat>, L<XDF::FixedDataFormat>, L<XDF::IntegerDataFormat>, or L<XDF::StringDataFormat>. RETURNS an object reference if successfull, undef if not. 

=item maxDataIndices (EMPTY)

A convenience method [same as $ArrayObj->dataCube()->maxDimensionIndex]. Returns a SCALAR ARRAY REF of SCALARS (non-negative INTEGERS) which are the maximum indexvalues along each dimension (FieldAxis and Axis objects). 

=item addNote ($info)

Insert an XDF::Note object into the XDF::Notes object held by this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Note> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Note object. RETURNS : an XDF::Note object reference on success, undef on failure. 

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item getNotes ($what)

Convenience method which returns a list of the notes held by this object. 

=item addData ($dataValue, $locator)

Append the SCALAR value onto the requested datacell (via L<XDF::DataCube> LOCATOR REF). 

=item setData ($dataValue, $locator)

Set the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF). Overwrites existing datacell value if any. 

=item removeData ($data, $locator)

Remove the requested data from the indicated datacell (via L<XDF::DataCube> LOCATOR REF) in the XDF::DataCube held in this Array. B<NOT CURRENTLY IMPLEMENTED>. 

=item getData ($locator)

Retrieve the SCALAR value of the requested datacell (via L<XDF::DataCube> LOCATOR REF). 

=item dataFormatList (EMPTY)

Get the dataFormatList for this array. 

=item addFieldAxis ($attribHashRefOrObjectRef)

A convenience method (same as $Array->fieldAxis($fieldAxisObj)). Changes the L<XDF::FieldAxis> object in this Array to the indicated one. 

=item removeFieldAxis (EMPTY)

A convenience method (same as $Array->fieldAxis(undef)). Removes the L<XDF::FieldAxis> object in this Array. B<CURRENTLY BROKEN>!

=item fieldAxis ($value)

a SCALAR (OBJECT REF) of the L<XDF::FieldAxis> object. Set/get the fieldAxis in this array. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::Object>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::Array inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::Array inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::Object>, L<XDF::Axis>, L<XDF::DataCube>, L<XDF::DataFormat>, L<XDF::FieldAxis>, L<XDF::Locator>, L<XDF::Note>, L<XDF::Parameter>, L<XDF::ParameterGroup>, L<XDF::TaggedXMLDataIOStyle>, L<XDF::Units>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

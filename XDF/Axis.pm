
package XDF::Axis;
 
# Package for XDF::Axis
# $Id$

# /** COPYRIGHT
#    Axis.pm Copyright (C) 2000 Brian Thomas,
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

use XDF::BaseObjectWithXMLElementsAndValueList;
use XDF::UnitDirection;
use XDF::ValueGroup;
use XDF::Constants;
use XDF::Log;
use XDF::Units;
use XDF::Utility;
use XDF::ValueListAlgorithm;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# Note: valueList currently holds both values and vectors

# /** DESCRIPTION 
# There must be one axis (or fieldAxis) for every dimension
# in the datacube. There are n indices for every axis (n>= 1).
# Each axis declaration defines the values of ALL the indices 
# along that dimension. Values of the indices in that axis need 
# not follow any algorthm for progression BUT each must be unique
# within the axis. A unit may be assocated with the axis.
# Note that the unit specified for the axis indices is not the 
# same as the unit of the data held within the data cube.
# */

# /** SYNOPSIS
# 
#    my $axisObj = new XDF::Axis(); # create axis, size '1'
#    $axisObj->name("first axis");
#    my $valueObj = new XDF::Value('9');
#    $axisObj->setAxisValue(0,$valueObj); # the axis value at index 0 has value "9" 
#
#    or 
#
#    my $axisObj = new XDF::Axis(10); # create axis wi/ length 10 and 10 values numbered 0 thru 9. 
#
#    or 
# 
#    my @axisValueList = qw ( $axisValueObjRef1 $axisValueObjRef2 );
#    my $axisObj = new XDF::Axis( { 'name' => 'first axis',
#                                 }
#                               );
#
# */

# inherits from XDF::BaseObjectWithXMLElements
@ISA = ("XDF::BaseObjectWithXMLElementsAndValueList");

# CLASS DATA
# /** name
# The STRING description (short name) of this object.
# */
# /** description
# A scalar string description (long name) of this object.
# */
# /** axisId
# A scalar string holding the axis id of this object. 
# */
# /** axisIdRef 
# A scalar string holding the reference object axisId.
# A reference object is used to supply those attributes
# of the object which have not been set. Note that 
# $obj->axisIdRef is simply what will be written to the XML 
# file if $obj->toXMLFileHandle method is called. You will 
# have to $obj->setObjRef($refObject) to get the referencing 
# functionality within the code.
# */
# /** align
# B<NOT CURRENTLY IMPLEMENTED>
# */
# /** units
# Holds a SCALAR object reference to the XDF::Units object for this axis. 
# */
# /** axisDatatype
# Holds a SCALAR object reference to a single Datatype (L<XDF::DataFormat>) object for this axis. 
# */ 
# /** valueList
# Holds a scalar Array Reference to the list of axisValue objects for this axis.
# */

my $DEFAULT_AXIS_SIZE = &XDF::Constants::DEFAULT_AXIS_SIZE;
my $Class_XML_Node_Name = "axis";

# the order of these attributes IS important.
# 
my @Local_Class_XML_Attributes = qw (
                      name
                      description
                      conversion
                      labelDataFormat
                      units
                      size
                      align
                      axisId
                      axisIdRef
                      valueList
                          ); 

my @Local_Class_Attributes = qw (
                             _parentArray
                             _lastValueIndex
                             _valueGroupOwnedHash
                          ); 

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObjectWithXMLElementsAndValueList::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElementsAndValueList::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name for XDF::Axis; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes { 
  return \@Class_Attributes; 
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}


#
# set/get Methods
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
#  */
sub getDescription {
   my ($self) = @_;
   return $self->{description};
}

# /** setDescription
#  */
sub setDescription {
   my ($self, $value) = @_;
   $self->{description} = $value;
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
#  */
sub setConversion {
   my ($self, $value) = @_;
   $self->{conversion} = $value;
} 

# /** getAxisDatatype
# Deprecated in this version. 
# */
sub getAxisDatatype {
   my ($self) = @_;
#   error("Use of axis->getAxisDatatype is not supported in XDF 0.18, please use axis->getLabelDataFormat instead.\n";
   info("Use of axis->getAxisDatatype is not deprecated in XDF 0.18, please use axis->getLabelDataFormat instead.\n");
   return $self->getLabelDataFormat();
#   return undef;
}

sub setAxisDatatype {
   my ($self, $value) = @_;

#   error("Use of axis->setAxisDatatype is not supported in XDF 0.18, please use axis->setLabelDataFormat instead.\n";
   info("Use of axis->setAxisDatatype is deprecated in XDF 0.18, please use axis->setLabelDataFormat instead.\n");
   return $self->setLabelDataFormat($value);
#   return;
}

# /** getLabelDataFormat
#  Get the description of the format of the axis labeling.
# */
sub getLabelDataFormat {
  my ($self) = @_;
  return $self->{labelDataFormat};
}

# /** setLabelDataFormat
#  Set the description of the format of the axis labeling.
# Thus, if an axis has labeled indices of "0", "1", "2", "3"
# it is appropriate to describe them as either "integerDataFormat"
# or "stringDataFormat" (integer is probably better).
# */
sub setLabelDataFormat {
  my ($self, $value) = @_;

  unless (&XDF::Utility::isValidDataFormat(ref $value)) {
     error("Cant set axis labelDataFormat to ".ref($value).", not allowed, ignoring \n");
     return;
  }

  $self->{labelDataFormat} = $value;

}

# /** getSize
# */
sub getSize {
   my ($self) = @_;
   return $self->{size};
}

# /** setSize
#     Set the size (number of indices) of this axis.
#     This attribute must be a non-zero whole number.
#     Reducing the size of the axis will remove all 
#     the current axisValues from the axis.
#
# */

sub setSize {
   my ($self, $value) = @_;

   if (&XDF::Utility::isValidAxisSize($value)) {
      if ($value < $self->{size})
      {
         info("axis:".$self->getAxisId()."is being shrunk. Releasing all axisValues\n");
         $self->_reset();
      }

      $self->{size} = $value;
      $#{$self->{valueList}} = $value; # change the size of the valueList 

     # As the length changed, so we update array internal datacube 
     if (defined $self->{_parentArray}) {
        $self->{_parentArray}->_updateAllLocatorInternalLookupIndices();
     }

   } else {
      error("Can't set axis size to $value (axis:".$self->getAxisId().")\n");
   } 
}

# /** getUnits
#     An "undef" value means this axis is unitless.
# */
sub getUnits {
   my ($self) = @_;
   return $self->{units};
}

# /** setUnits
#     Set the type of units that the values of this axis are given in.
#     Passing the "undef" value will make this axis unitless.
# */
sub setUnits {
   my ($self, $value) = @_;

   unless (&XDF::Utility::isValidUnits($value)) {
     error("Cant set axis units to $value, not allowed, ignoring \n");
     return;
   }
   $self->{units} = $value;
}

# /** getAxisId
# */
sub getAxisId {
   my ($self) = @_;
   return $self->{axisId};
}

# /** setAxisId
#     Set the axisId attribute. 
# */
sub setAxisId {
   my ($self, $value) = @_;
   $self->{axisId} = $value;
}

# /** getAxisIdRef 
# */
sub getAxisIdRef {
   my ($self) = @_;
   return $self->{axisIdRef};
}

# /** setAxisIdRef
#     Set the axisIdRef attribute. 
# */
sub setAxisIdRef {
   my ($self, $value) = @_;
   $self->{axisIdRef} = $value;
}

# /** getAlign
# */
sub getAlign {
   my ($self) = @_;
   return $self->{align};
}

# /** setAlign
#     Set the align attribute. 
# */
sub setAlign {
   my ($self, $value) = @_;
   $self->{align} = $value;
}

# /** getValueList
#  */
sub getValueList {
   my ($self) = @_;
   return $self->{valueList};
}

# /** setValueList
#  Set the values of the indices on this axis using a passed list. 
#  The passed list may either contain Value objects OR may be an XDF::ValueList object 
#  (either ValueListAlgorithm or ValueListDelimitedList).
#  Either way, (axis) Value objects will be added to the axis and its size set to 
#  the number of Values.
#
#  Note: Using a valueList *object* will result in a more compact description of 
#  the passed values when the parameter is printed out.
#
# */
sub setValueList {
   my ($self, $arrayOrValueListObjRefValue) = @_;

   # clear old list
   $self->_reset();
   $self->addValueList($arrayOrValueListObjRefValue);

}

# /** getLength
# Get the length of this axis (same as the method getSize)
# */
sub getLength {
  my ($self) = @_;
  $self->{size};
}

# /** getAxisValue 
# Returns the axis XDF::Value object at the specified index.
# */ 
sub getAxisValue {
  my ($self, $index) = @_;
  return unless (defined $index && $index >= 0);
  return $self->getAxisValues->[$index];
}

# /** setAxisValue
# Set the value of this axis at the given index.
# */
sub setAxisValue {
  my ($self, $index, $valueObj ) = @_;

  return 0 unless defined $index && $index >= 0;

  if($self->{size} <= $index) {
     error("Cannot setAxisValue as axis is too small. You should increase axis size. Ignoring request.\n");
     return 0;
  }

  unless (defined $valueObj ) {
     #if (defined @{$self->{valueList}}->[$index]) {
     if (defined $self->{valueList}->[$index]) {
        # NO, dont do this...
        #   if the axisValue is presently defined, we lower
        #   the lastvalueIndex by 1
        #   $self->{_lastValueIndex}--;
        #@{$self->{valueList}}->[$index] = undef;
        $self->{valueList}->[$index] = undef;
     }

     # no compact description allowed now 
     $self->_resetBaseValueListObjects();

     return 1;
  }

  unless (ref($valueObj) eq 'XDF::Value' or
          ref($valueObj) eq 'XDF::UnitDirection' )
  {
     $valueObj  = new XDF::Value(); #@{$self->{ValueList}}->[$index];
     $valueObj->setValue($valueObj);
  }

  # if the axisValue is not presently defined, we raise
  # the length of the axis by 1
#  if (!defined @{$self->{valueList}}->[$index]) {

     # also means length changed, so lets update array internal datacube 
#     if (defined $self->{_parentArray}) {
#        $self->{_parentArray}->_updateAllLocatorInternalLookupIndices();
#     }

#   }

   # set the lastValueIndex
   $self->{_lastValueIndex} = $index;

   #@{$self->{valueList}}->[$index] = $valueObj;
   $self->{valueList}->[$index] = $valueObj;

   # no compact description allowed now 
   $self->_resetBaseValueListObjects();

   return 1;
}


# /** getAxisValues 
# This is a convenience method which returns all of the values (as strings) on this axis. 
# */ 
sub getAxisValues {
   my ($self) = @_;

   my @values = ();
   foreach my $axisVal (@{$self->{valueList}}) {
      next unless defined $axisVal;
      push @values, $axisVal->getValue();
   }

   return @values;
}

# /** getParentArray
# */
sub getParentArray { # PRIVATE 
   my ($self) = @_;
   return $self->{_parentArray};
}

# /** setParentArray
# */
sub setParentArray { # PRIVATE
   my ($self, $value) = @_;
   $self->{_parentArray} = $value;
}


#
# Other Public Methods
#

sub new {
  my ($proto, $attribHashOrSize) = @_;

   my $size;
   unless (ref $attribHashOrSize) {
     $size = $attribHashOrSize;
     $attribHashOrSize = undef;
   }
   my $self = $proto->SUPER::new($attribHashOrSize);

   if (defined $size) {
      my $valueListObj = new XDF::ValueListAlgorithm(0,1,$size);
      $self->addAxisValueList($valueListObj);
   }
   return $self;
}

# do a reset of the axis object
sub _reset {
  my ($self) = @_;

  $self->{size} = 0;
  $self->_resetValues();

}

# /** resetValues
# The valueList (which holds either Value or UnitDirection objects) is
# reset to be empty by this method.
# */
sub _resetValues {
   my ($self) = @_;

   # free up all declared values
   $self->{valueList} = []; # has to be this way to avoid deep recursion 
   $#{$self->{valueList}} = 0;
   $self->{_lastValueIndex} = 0;

   # no compact description allowed now 
   $self->_resetBaseValueListObjects();

}

# /** addAxisValue
# Add an XDF::AxisValue object to this axis. 
# The passed value is attached to the last undefined indice at the end of the axis.
# IF all indices on the axis are defined, then the axis size is increased by 1 and
# the axisValue ascribed to the last indice on the axis. HINT: This is a slow operation, 
# it is better to pre-allocate the size of the axis first, and then tack in the values 
# using setAxisValue.
#
# This method returns: 1 on success, 0 on failure.
# */
sub addAxisValue {
  my ($self, $valueObj ) = @_;

   if ($self->_addAxisValue($valueObj)) {

      # no compact description allowed now 
      $self->_resetBaseValueListObjects();
      return 1;

   }

   return 0;

}

# /** addAxisUnitDirection
# Add an XDF::UnitDirection object to this axis. 
# Returns 1 on success , 0 on failure.
# */ 
sub addAxisUnitDirection {
  my ($self, $obj) = @_; 

  if (!defined $obj) {
     error("Cannot add an AxisUnitDirection, no value specified. Ignoring request.\n"); 
     return 0;
  }

  my $index = $self->{_lastValueIndex};

  # have we enough space on the axis?
  if($self->{size} <= $index) {
     # error("Cannot add an AxisUnitDirection, Axis is filled, you should increase axis size. Ignoring request.\n"); 
     $self->setSize($index + 1);
     return $self->addAxisUnitDirection($obj);
  }

#  if (defined @{$self->{valueList}}->[$index]) {
#     # increase the size of the array by pushing
#     push @{$self->{valueList}}, $obj;
#  } else {

     # use a pre-alocated spot that is undefined
     #@{$self->{valueList}}->[$index] = $obj;
     $self->{valueList}->[$index] = $obj;

#  }

  if (defined $self->{_parentArray}) {
     $self->{_parentArray}->_updateAllLocatorInternalLookupIndices();
  }

  # bump up the size of last index
  $self->{_lastValueIndex} = $index + 1;

  # no compact description allowed now 
  $self->_resetBaseValueListObjects();

  return 1;
}

# /** removeAxisValue 
# Remove either an XDF::Value or XDF::UnitDirection object from this axis. 
# Returns 1 on success , 0 on failure.
# */ 
sub removeAxisValue {
  my ($self, $obj) = @_;

  if ($self->_remove_from_list($obj, $self->{ValueList}, 'valueList')) {

     # bump down size of the last axisValue 
#     $self->{_lastAxisValue} = $self->{_lastAxisValue} -1;

     if (defined $self->{_parentArray}) {
        $self->{_parentArray}->_updateAllLocatorInternalLookupIndices();
     }

     # safety
     $self->setSize($DEFAULT_AXIS_SIZE) if ($self->{size} < $DEFAULT_AXIS_SIZE);

     return 1;
  }

  return 0;
}

# /** addAxisValueList
# Append a list of (axis) Values held by the passed ValueListObject (or Array of Values)
# into this Axis object.
# */
sub addAxisValueList {
   my ($self, $arrayOrValueListObjRefValue) = @_;

   unless (ref($arrayOrValueListObjRefValue)) {
     error("axis->setAxisValueList() passed non-reference. Ignoring request.\n");
     return;
   }

   if (ref($arrayOrValueListObjRefValue) eq 'ARRAY') {

      # you must do it this way, or when the arrayRef changes it changes us here!
      if ($#{$arrayOrValueListObjRefValue} >= 0) {
         foreach my $valueObj (@{$arrayOrValueListObjRefValue}) {
            $self->_addAxisValue($valueObj);
         }

         # since we added vanilla values
         # no compact description allowed now 
         $self->_resetBaseValueListObjects();

         return 1;
      }

   }
   elsif (ref($arrayOrValueListObjRefValue) =~ m/^XDF::ValueList/)
   {

       my @values = @{$arrayOrValueListObjRefValue->getValues()};
       if ($#values >= 0) {
          $self->_addValueListObj($arrayOrValueListObjRefValue);
          foreach my $valueObj (@values) {
             $self->_addAxisValue($valueObj);
          }
          return 1;
       } else {
          warn ("axis->addAxisValueList passed ValueList object with 0 values, Ignoring.\n");
       }

   }
   else
   {
      error("Unknown reference object passed to setvalueList in axis:$arrayOrValueListObjRefValue. Dying.\n");
      exit -1;
   }

   return 0;
}

# /** addUnit 
# Add an XDF::Unit object to the XDF::Units object contained in this axis. 
# Returns 1 on success , 0 on failure.
# */ 
sub addUnit { 
   my ($self, $unitObj) = @_;
   return $self->{units}->addUnit($unitObj);
}

# /** removeUnit 
# Remove an XDF::Unit object from the XDF::Units object contained in this axis. 
# Returns 1 on success , 0 on failure.
# */ 
sub removeUnit { 
  my ($self, $indexOrObjectRef) = @_; 
  return $self->{units}->removeUnit($indexOrObjectRef); 
}

# /** addValueGroup 
# Insert a ValueGroup object into this object to group the axisValues. 
# Returns 1 on success , 0 on failure.
# */ 
sub addValueGroup {
  my ($self, $valueGroupObj) = @_;

  unless (defined $valueGroupObj && ref ($valueGroupObj) =~ m/XDF::ValueGroup/) {
     error("Cannot add a valueGroup, no value specified or not a ValueGroup object. Ignoring request.\n"); 
     return 0;
  }

  # add the group to the groupOwnedHash
  #%{$self->{_valueGroupOwnedHash}}->{$valueGroupObj} = $valueGroupObj;
  $self->{_valueGroupOwnedHash}->{$valueGroupObj} = $valueGroupObj;

  return 1;

}

# /** removeValueGroup 
# Remove a ValueGroup object from this object 
# Returns 1 on success , 0 on failure.
# */
sub removeValueGroup { 
   my ($self, $hashKey ) = @_; 
   #if (exists %{$self->{_valueGroupOwnedHash}}->{$hashKey}) {
   #   delete %{$self->{_valueGroupOwnedHash}}->{$hashKey}; 
   #   return 1;
   #}
   if (exists $self->{_valueGroupOwnedHash}->{$hashKey}) {
      delete $self->{_valueGroupOwnedHash}->{$hashKey}; 
      return 1;
   }
   return 0;
}

# /** getIndexFromAxisValue
# Return the axis index for the given (scalar) value. 
# Does not currently work for unitDirection objects that reside
# on an axis.
# Returns -1 if it cant find an index for the given value.
# */
# Note: there is a smarter way to do this. We could keep a private
# hash table of index/value pairs OR use some sort of (Perl) psuedo
# hash table that allows reverse lookups.
sub getIndexFromAxisValue {
  my ($self, $valueOrValueObj) = @_; 

  return unless defined $valueOrValueObj;

  my $value = $valueOrValueObj;
  $value = $value->getValue() if ref($valueOrValueObj);

  my $index;
  foreach $index (0 .. $#{$self->{valueList}}) {
    #my $axisValue = @{$self->{valueList}}->[$index];
    my $axisValue = $self->{valueList}->[$index];
    if (defined $axisValue && $value eq $axisValue->getValue) {
      return $index;
    }
  } 
  return -1;
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

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->{size} = $DEFAULT_AXIS_SIZE;

  $self->{_valueGroupOwnedHash} = {};

  # initialize lists, objects 
  $self->{valueList} = [];
  $#{$self->{valueList}} = $DEFAULT_AXIS_SIZE - 1;
  $self->{_lastValueIndex} = 0;
  $self->{units} = new XDF::Units();

  # set the minimum array size (essentially the size of the axis)
  my $spec = XDF::Specification->getInstance();

  # this variable is needed because $#{$self->{valueList}}
  # is pre-allocated in prior statement, and is not necess.
  # reflective of the real axis size.
#  $self->{length} = 0;

  $self->{_valueListGetMethodName} = "getValueList";

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# private routine. It doenst reset the BaseValueList objects
# as per the public method.
sub _addAxisValue {
  my ($self, $valueObj ) = @_; 
             
  unless (defined $valueObj) {
    # No point in adding an axis value w/o a value for it.
    error("Cannot add an AxisValue, no value specified. Ignoring request.\n");
    return 0; 
  }       
   
  # hmm. if we have a reference object, what happens?
  # I guess this *should* become its own, new object
  # ah the pain of it all. It would seem wiser to just
  # NOT have reference objects at all.

  my $index = $self->{_lastValueIndex};

  # have we enough space on the axis? No?!? 
  # in this case, we increase the axis by 1 and 
  # then 'append' value onto end. This could loop mucho(?) 
  if($self->{size} <= $index) {
     $self->setSize($index + 1);
     return $self->_addAxisValue($valueObj);
  }

  # In the case that the value lies within the size of the axis
  # we use a pre-alocated spot that is undefined
  #@{$self->{valueList}}->[$index] = $valueObj;
  $self->{valueList}->[$index] = $valueObj;

  # bump up the size of last index
  $self->{_lastValueIndex} = $index +1;

  return 1;

}

1;


__END__

=head1 NAME

XDF::Axis - Perl Class for Axis

=head1 SYNOPSIS

 
    my $axisObj = new XDF::Axis(); # create axis, size '1'
    $axisObj->name("first axis");
    my $valueObj = new XDF::Value('9');
    $axisObj->setAxisValue(0,$valueObj); # the axis value at index 0 has value "9" 

    or 

    my $axisObj = new XDF::Axis(10); # create axis wi/ length 10 and 10 values numbered 0 thru 9. 

    or 
 
    my @axisValueList = qw ( $axisValueObjRef1 $axisValueObjRef2 );
    my $axisObj = new XDF::Axis( { 'name' => 'first axis',
                                 }
                               );



...

=head1 DESCRIPTION

 There must be one axis (or fieldAxis) for every dimension in the datacube. There are n indices for every axis (n>= 1).  Each axis declaration defines the values of ALL the indices  along that dimension. Values of the indices in that axis need  not follow any algorthm for progression BUT each must be unique within the axis. A unit may be assocated with the axis.  Note that the unit specified for the axis indices is not the  same as the unit of the data held within the data cube. 

XDF::Axis inherits class and attribute methods of L< = (>, L<XDF::BaseObjectWithXMLElementsAndValueList>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Axis.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::Axis; This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item new ($attribHashOrSize)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Axis.

=over 4

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription (EMPTY)

 

=item setDescription ($value)

 

=item getAxisDatatype (EMPTY)

 

=item setAxisDatatype ($value)

Set the axisDatatype attribute.  

=item getSize (EMPTY)

 

=item setSize ($value)

Set the size (number of indices) of this axis. This attribute must be a non-zero whole number. Changing the size of the axis removes all the axisValuesfrom the axis if the new size is smaller than the old one(So, if you shrink the size of the axis, you have to add the values of the indices back in).  

=item getUnits (EMPTY)

An "undef" value means this axis is unitless.  

=item setUnits ($value)

Set the type of units that the values of this axis are given in. Passing the "undef" value will make this axis unitless.  

=item getAxisId (EMPTY)

 

=item setAxisId ($value)

Set the axisId attribute.  

=item getAxisIdRef (EMPTY)

 

=item setAxisIdRef ($value)

Set the axisIdRef attribute.  

=item getAlign (EMPTY)

 

=item setAlign ($value)

Set the align attribute.  

=item getValueList (EMPTY)

 

=item setValueList ($arrayOrValueListObjRefValue)

Set the values of the indices on this axis using a passed list. The passed list may either contain Value objects OR may be an XDF::ValueList object (either ValueListAlgorithm or ValueListDelimitedList). Either way, (axis) Value objects will be added to the axis and its size set to the number of Values. Note: Using a valueList *object* will result in a more compact description of the passed values when the parameter is printed out.  

=item getLength (EMPTY)

Get the length of this axis (same as the method getSize) 

=item getAxisValue ($index)

Returns the axis XDF::Value object at the specified index.  

=item setAxisValue ($index, $valueObj)

Set the value of this axis at the given index.  

=item getAxisValues (EMPTY)

This is a convenience method which returns all of the values (as strings) on this axis.  

=item addAxisValue ($valueObj)

Add an XDF::AxisValue object to this axis. The passed value is attached to the last undefined indice at the end of the axis. IF all indices on the axis are defined, then the axis size is increased by 1 andthe axisValue ascribed to the last indice on the axis. HINT: This is a slow operation, it is better to pre-allocate the size of the axis first, and then tack in the values using setAxisValue. This method returns: 1 on success, 0 on failure.  

=item addAxisUnitDirection ($obj)

Add an XDF::UnitDirection object to this axis. Returns 1 on success , 0 on failure.  

=item removeAxisValue ($obj)

Remove either an XDF::Value or XDF::UnitDirection object from this axis. Returns 1 on success , 0 on failure.  

=item addAxisValueList ($arrayOrValueListObjRefValue)

Append a list of (axis) Values held by the passed ValueListObject (or Array of Values)into this Axis object.  

=item addUnit ($unitObj)

Add an XDF::Unit object to the XDF::Units object contained in this axis. Returns 1 on success , 0 on failure.  

=item removeUnit ($indexOrObjectRef)

Remove an XDF::Unit object from the XDF::Units object contained in this axis. Returns 1 on success , 0 on failure.  

=item addValueGroup ($valueGroupObj)

Insert a ValueGroup object into this object to group the axisValues. Returns 1 on success , 0 on failure.  

=item removeValueGroup ($hashKey)

Remove a ValueGroup object from this object Returns 1 on success , 0 on failure.  

=item getIndexFromAxisValue ($valueOrValueObj)

Return the axis index for the given (scalar) value. Does not currently work for unitDirection objects that resideon an axis. Returns -1 if it cant find an index for the given value.  

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

L<XDF::BaseObjectWithXMLElementsAndValueList>, L<XDF::UnitDirection>, L<XDF::ValueGroup>, L<XDF::Constants>, L<XDF::Log>, L<XDF::Units>, L<XDF::Utility>, L<XDF::ValueListAlgorithm>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

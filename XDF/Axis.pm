
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

use Carp;
use XDF::BaseObjectWithXMLElementsAndValueList;
use XDF::UnitDirection;
use XDF::ValueGroup;
use XDF::Units;
use XDF::Utility;
use XDF::ValueListAlgorithm;

use strict;
# Does this help??
#use fields qw (
#                      name
#                      description
#                      align
#                      axisId
#                      axisIdRef
#                      valueList
#                      axisUnits
#                      axisDatatype
#                      length
#                      _valueGroupOwnedHash
#              );

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
#    my $axisObj = new XDF::Axis();
#    $axisObj->name("first axis");
#    my $valueObj = new XDF::Value('9');
#    $axisObj->addAxisValue($valueObj); # the axis value at index 0 has value "9" 
#
#    or 
#
#    my $axisObj = new XDF::Axis(10); # create axis wi/ length 10 and 10 values numbered 0 thru 9. 
#
#    or 
# 
#    my @axisValueList = qw ( $axisValueObjRef1 $axisValueObjRef2 );
#    my $axisObj = new XDF::Axis( { 'name' => 'first axis',
#                                   'valueList' => \@axisValueList,
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
# /** axisUnits
# Holds a SCALAR object reference to the XDF::Units object for this axis. 
# */
# /** axisDatatype
# Holds a SCALAR object reference to a single Datatype (L<XDF::DataFormat>) object for this axis. 
# */ 
# /** valueList
# Holds a scalar Array Reference to the list of axisValue objects for this axis.
# */

my $Class_XML_Node_Name = "axis";

# the order of these attributes IS important.
# 
my @Local_Class_XML_Attributes = qw (
                      name
                      description
                      axisDatatype
                      axisUnits
                      align
                      axisId
                      axisIdRef
                      valueList
                          ); 

my @Local_Class_Attributes = qw (
                             length
                             _parentArray
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

# /** getAxisDatatype
# */
sub getAxisDatatype {
   my ($self) = @_;
   return $self->{axisDatatype};
}

# /** setAxisDatatype
#     Set the axisDatatype attribute. 
# */
sub setAxisDatatype {
   my ($self, $value) = @_;

   carp "Cant set axisDatatype to $value, not allowed \n"
      unless (&XDF::Utility::isValidDatatype($value));

   $self->{axisDatatype} = $value;

}

# /** getAxisUnits
# */
sub getAxisUnits {
   my ($self) = @_;
   return $self->{axisUnits};
}

# /** setAxisUnits
#     Set the axisUnits attribute. 
# */
sub setAxisUnits {
   my ($self, $value) = @_;
   $self->{axisUnits} = $value;
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
#  Set the valueList attribute. You may either pass an array of Value
#  objects OR a valueList object (either ValueListAlgorithm or ValueListDelimitedList).
#  Either way, (axis) Value objects will be added to the axis and its size set to their number.
#  Using a valueList *object* will result in a more compact description of 
#  the passed values when the parameter is printed out.
# */
sub setValueList {
   my ($self, $arrayOrValueListObjRefValue) = @_;

   # clear old list
   $self->resetValues();
   $self->addValueList($arrayOrValueListObjRefValue);

}

# /** getLength
# Get the length of this axis (eg number of axis value objects) 
# */
sub getLength {
  my ($self) = @_;
  $self->{length};
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

  unless (defined $valueObj ) {
     if (defined @{$self->{valueList}}->[$index]) {
        # if the axisValue is presently defined, we lower
        # the length of the axis by 1
        $self->{length} = $self->{length} - 1;
        @{$self->{valueList}}->[$index] = undef;
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
  if (!defined @{$self->{valueList}}->[$index]) {
     $self->{length} = $self->{length} + 1;

     # also means length changed, so lets update array internal datacube 
     if (defined $self->{_parentArray}) {
        $self->{_parentArray}->_updateInternalLookupIndices();
     }

   }

   @{$self->{valueList}}->[$index] = $valueObj;

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

# /** resetValues
# The valueList (which holds either Value or UnitDirection objects) is
# reset to be empty by this method.
# */
sub resetValues {
   my ($self) = @_;

   # free up all declared values
   $self->{valueList} = []; # has to be this way to avoid deep recursion 

   # no compact description allowed now 
   $self->_resetBaseValueListObjects();

}

# /** addAxisValue
# Add an XDF::AxisValue object to this axis. 
# RETURNS : 1 on success, 0 on failure.
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
     carp "Cannot add an AxisUnitDirection, no value specified. Ignoring request.\n"; 
     return 0;
  }

  my $index = $self->{length};
  if (defined @{$self->{ValueList}}->[$index]) {
     # increase the size of the array by pushing
     push @{$self->{valueList}}, $obj;
  } else {
     # use a pre-alocated spot that is undefined
     @{$self->{valueList}}->[$index] = $obj;
  }

  if (defined $self->{_parentArray}) {
     $self->{_parentArray}->_updateInternalLookupIndices();
  }

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
     # bump down size of the axis 
     $self->{length} = $self->{length} -1;

     if (defined $self->{_parentArray}) {
        $self->{_parentArray}->_updateInternalLookupIndices();
     }
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

   croak "axis->setAxisValueList() passed non-reference.\n"
      unless (ref($arrayOrValueListObjRefValue));

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
          carp "axis->addAxisValueList passed ValueList object with 0 values, Ignoring.\n";
       }

   }
   else
   {
      croak "Unknown reference object passed to setvalueList in axis:$arrayOrValueListObjRefValue. Dying.\n";
   }

   return 0;
}

# /** addUnit 
# Add an XDF::Unit object to the XDF::Units object contained in this axis. 
# Returns 1 on success , 0 on failure.
# */ 
sub addUnit { 
   my ($self, $unitObj) = @_;
   return $self->{axisUnits}->addUnit($unitObj);
}

# /** removeUnit 
# Remove an XDF::Unit object from the XDF::Units object contained in this axis. 
# Returns 1 on success , 0 on failure.
# */ 
sub removeUnit { 
  my ($self, $indexOrObjectRef) = @_; 
  return $self->{axisUnits}->removeUnit($indexOrObjectRef); 
}

# /** addValueGroup 
# Insert a ValueGroup object into this object to group the axisValues. 
# Returns 1 on success , 0 on failure.
# */ 
sub addValueGroup {
  my ($self, $valueGroupObj) = @_;

  unless (defined $valueGroupObj && ref ($valueGroupObj) =~ m/XDF::ValueGroup/) {
     carp "Cannot add a valueGroup, no value specified or not a ValueGroup object. Ignoring request.\n"; 
     return 0;
  }

  # add the group to the groupOwnedHash
  %{$self->{_valueGroupOwnedHash}}->{$valueGroupObj} = $valueGroupObj;

  return 1;

}

# /** removeValueGroup 
# Remove a ValueGroup object from this object 
# Returns 1 on success , 0 on failure.
# */
sub removeValueGroup { 
   my ($self, $hashKey ) = @_; 
   if (exists %{$self->{_valueGroupOwnedHash}}->{$hashKey}) {
      delete %{$self->{_valueGroupOwnedHash}}->{$hashKey}; 
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
    my $axisValue = @{$self->{valueList}}->[$index];
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

  $self->{axisUnits} = new XDF::Units();
  $self->{axisUnits}->setXMLNodeName("axisUnits");

  $self->{_valueGroupOwnedHash} = {};

  # initialize lists 
  $self->{valueList} = [];

  # set the minimum array size (essentially the size of the axis)
  my $spec = XDF::Specification->getInstance();
  $#{$self->{valueList}} = $spec->getDefaultDataArraySize();

  # this variable is needed because $#{$self->{valueList}}
  # is pre-allocated in prior statement, and is not necess.
  # reflective of the real axis size.
  $self->{length} = 0;

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
    carp "Cannot add an AxisValue, no value specified. Ignoring request.\n";
    return 0; 
  }       
   
  # hmm. if we have a reference object, what happens?
  # I guess this *should* become its own, new object
  # ah the pain of it all. It would seem wiser to just
  # NOT have reference objects at all.

  my $index = $self->{length};

  if (defined @{$self->{valueList}}->[$index]) {
     # increase the size of the array by pushing
     push @{$self->{valueList}}, $valueObj;
  } else {
     # use a pre-alocated spot that is undefined
     @{$self->{valueList}}->[$index] = $valueObj;
  }

  # bump up the size of this axis
  $self->{length} = $self->{length} + 1;

  if (defined $self->{_parentArray}) {
     $self->{_parentArray}->_updateInternalLookupIndices();
  }

  return 1;

}


# Modification History
#
# $Log$
# Revision 1.18  2001/08/13 20:56:10  thomas
# updated documentation via utils/makeDoc.pl for the release.
# Added convience 'new' method.
#
# Revision 1.17  2001/08/13 19:44:45  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
# changed _length field to length.
#
# Revision 1.16  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.15  2001/07/13 21:43:36  thomas
# added methods for ValueList stuff
#
# Revision 1.14  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.13  2001/06/21 15:43:11  thomas
# fix to allow update of internal dataCube
# indices when axis length is changed.
#
# Revision 1.12  2001/04/25 16:00:24  thomas
# changed base class to BaseObjectWithXMLElements
#
# Revision 1.11  2001/04/17 18:57:38  thomas
# Using Specification class now.
# Properly calling superclass init now.
#
# Revision 1.10  2001/03/21 20:19:23  thomas
# Fixed documentation to show addXMLElement, etc. methods in perldoc
#
# Revision 1.9  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.8  2001/03/14 21:32:33  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.7  2001/03/14 16:09:37  thomas
# getIndexFromAxisValue method now returns -1 if it cant find
# the corresponding index (as per Java method). Also, will take
# a valueObject as well as string value.
# addAxisValue and setAxisValue fixed. Previously these where just
# pushing values onto the end of the valueList. The problem is that
# that array is pre-allocated, so the operation resulted in tacking on
# more values to the end of the array. Now we set the value at a
# free index, or if there are no free indices, we add a new one. We
# will probably have to re-visit this issue again in the future.
#
# Revision 1.6  2001/03/09 21:52:11  thomas
# Added utility check on datatype attribute setting.
#
# Revision 1.5  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::Axis - Perl Class for Axis

=head1 SYNOPSIS

 
    my $axisObj = new XDF::Axis();
    $axisObj->name("first axis");
    my $valueObj = new XDF::Value('9');
    $axisObj->addAxisValue($valueObj); # the axis value at index 0 has value "9" 

    or 

    my $axisObj = new XDF::Axis(10); # create axis wi/ length 10 and 10 values numbered 0 thru 9. 

    or 
 
    my @axisValueList = qw ( $axisValueObjRef1 $axisValueObjRef2 );
    my $axisObj = new XDF::Axis( { 'name' => 'first axis',
                                   'valueList' => \@axisValueList,
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

=item getAxisUnits (EMPTY)

 

=item setAxisUnits ($value)

Set the axisUnits attribute.  

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

Set the valueList attribute. You may either pass an array of Valueobjects OR a valueList object (either ValueListAlgorithm or ValueListDelimitedList). Either way, (axis) Value objects will be added to the axis and its size set to their number. Using a valueList *object* will result in a more compact description of the passed values when the parameter is printed out.  

=item getLength (EMPTY)

Get the length of this axis (eg number of axis value objects)  

=item getAxisValue ($index)

Returns the axis XDF::Value object at the specified index.  

=item setAxisValue ($index, $valueObj)

Set the value of this axis at the given index.  

=item getAxisValues (EMPTY)

This is a convenience method which returns all of the values (as strings) on this axis.  

=item resetValues (EMPTY)

The valueList (which holds either Value or UnitDirection objects) isreset to be empty by this method.  

=item addAxisValue ($valueObj)

Add an XDF::AxisValue object to this axis. RETURNS : 1 on success, 0 on failure.  

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



=over 4

XDF::Axis inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElementsAndValueList>:
B<toXMLFileHandle>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObjectWithXMLElementsAndValueList>, L<XDF::UnitDirection>, L<XDF::ValueGroup>, L<XDF::Units>, L<XDF::Utility>, L<XDF::ValueListAlgorithm>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


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
use XDF::BaseObject;
use XDF::UnitDirection;
use XDF::ValueGroup;
use XDF::Units;
use XDF::Value;

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
#                      _length
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
#    $axisObj->addAxisValue(9); # the axis value at index 0 has value "9" 
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

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

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

# the order of these attributes IS important. In order for the ID/IDREF
# stuff to work, _objRef MUST be the last attribute
# 
my @Class_Attributes = qw (
                      name
                      description
                      axisDatatype
                      axisUnits
                      align
                      axisId
                      axisIdRef
                      valueList
                      _length
                      _valueGroupOwnedHash
                          ); 

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name for XDF::Axis; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes for XDF::Axis; 
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

sub _init {
  my ($self) = @_;

  my $unitsObj = $self->axisUnits(new XDF::Units());
  $unitsObj->setXMLNodeName("axisUnits");

  $self->_valueGroupOwnedHash({}); 

  # initialize lists 
  $self->valueList([]);
  
  # set the minimum array size (essentially the size of the axis)
  $#{$self->valueList} = $self->DefaultDataArraySize();

  # this variable is needed because $#{$self->valueList}
  # is pre-allocated in prior statement, and is not necess.
  # reflective of the real axis size.
  $self->_length(0);
}

# /** addAxisValue
# Add an XDF::AxisValue object to this axis. 
# */
sub addAxisValue {
  my ($self, $value ) = @_;

  unless (defined $value) {
    # No point in adding an axis value w/o a value for it.
    carp "Cannot add an AxisValue, no value specified. Ignoring request.\n"; 
    return;
  } 

  my $obj = XDF::Value->new({'value' => $value});

  # hmm. if we have a reference object, what happens?
  # I guess this *should* become its own, new object
  # ah the pain of it all. It would seem wiser to just
  # NOT have reference objects at all.

  # add this axis value to the list
  push @{$self->valueList}, $obj;

  $self->_length($self->_length+1);

  return $obj;
}

# /** setAxisValue
# Set the value of this axis at the given index.
# */
sub setAxisValue {
  my ($self, $index, $valueOrValueObjRef ) = @_;

  return unless defined $index && defined $valueOrValueObjRef;

  my $valueObj = $valueOrValueObjRef;

  unless (ref($valueObj) eq 'XDF::Value' or 
          ref($valueObj) eq 'XDF::UnitDirection' )
  {
    $valueObj  = @{$self->valueList}->[$index];
    $valueObj->value($valueOrValueObjRef);
  } 

  @{$self->valueList}->[$index] = $valueObj;

  return $valueObj;
}

# /** addAxisUnitDirection
# Add an XDF::UnitDirection object to this axis. 
# */ 
sub addAxisUnitDirection {
  my ($self, $attribHashRef) = @_; 

  my $obj = XDF::UnitDirection->new($attribHashRef);
  push @{$self->valueList}, $obj;

  return $obj;
}

# /** removeAxisValue 
# Remove either an XDF::Value or XDF::UnitDirection object from this axis. 
# $what may either be an index value or object reference. 
# */ 
sub removeAxisValue {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->valueList(), 'valueList');
  # bump down size of the axis 
  $self->_length($self->_length()-1);
}

# /** getAxisValue 
# Returns the axis XDF::Value object at the specified index.
# */ 
sub getAxisValue {
  my ($self, $index) = @_;
  return unless (defined $index && $index >= 0);
  return @{$self->valueList()}->[$index];
}

# /** getAxisValues 
# This is a convenience method which returns all of the values (as strings) on this axis. 
# */ 
sub getAxisValues {
   my ($self) = @_;

   my @values = ();
   foreach my $axisVal (@{$self->valueList}) {
      next unless defined $axisVal;
      push @values, $axisVal->value();
   }

   return @values;
}

# /** addUnit 
# Add an XDF::Unit object to the XDF::Units object contained in this axis. 
# */ 
sub addUnit { my ($self, $attribHashRefOrObjectRef) = @_;
   my $unitObj = $self->axisUnits()->addUnit($attribHashRefOrObjectRef);
   return $unitObj;
}

# /** removeUnit 
# Remove an XDF::Unit object from the XDF::Units object contained in this axis. 
# */ 
sub removeUnit { 
  my ($self, $indexOrObjectRef) = @_; 
  return $self->axisUnits()->removeUnit($indexOrObjectRef); 
}

# /** addValueGroup 
# Insert a ValueGroup object into this object to group the axisValues. 
# */ 
sub addValueGroup {
  my ($self, $attribHashRefOrObjectRef) = @_;

  return unless defined $attribHashRefOrObjectRef && ref $attribHashRefOrObjectRef;

  my $groupObj;
  if ($attribHashRefOrObjectRef =~ m/XDF::ValueGroup/) {
    $groupObj = $attribHashRefOrObjectRef;
  } else {
    $groupObj = new XDF::ValueGroup($attribHashRefOrObjectRef);
  }

  # add the group to the groupOwnedHash
  %{$self->_valueGroupOwnedHash}->{$groupObj} = $groupObj;

  return $groupObj;
}

# /** removeValueGroup 
# Remove a ValueGroup object from this object 
# */
sub removeValueGroup { 
  my ($self, $hashKey ) = @_; 
  delete %{$self->_valueGroupOwnedHash}->{$hashKey}; 
}

# /** length
# Get the length of this axis (eg number of axis value objects) 
# */
sub length { 
  my ($self) = @_; 
  return defined $self->_objRef && defined $self->_objRef->_length ? 
          $self->_objRef->_length() : $self->_length(); 
}

# /** getIndexFromValue
# Return the axis index for the given (scalar) value. 
# Does not currently work for unitDirection objects that reside
# on an axis.
# Returns undef if it cant find an index for the given value.
# */
# Note: there is a smarter way to do this. We could keep a private
# hash table of index/value pairs OR use some sort of (Perl) psuedo
# hash table that allows reverse lookups.
sub getIndexFromAxisValue {
  my ($self, $value) = @_; 

  return unless defined $value;

  my $index;
  foreach $index (0 .. $#{$self->valueList}) {
    if ($value eq @{$self->valueList}->[$index]->value) {
      return $index;
    }
  } 
  return;
}

# Modification History
#
# $Log$
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
    $axisObj->addAxisValue(9); # the axis value at index 0 has value "9" 

    or 
 
    my @axisValueList = qw ( $axisValueObjRef1 $axisValueObjRef2 );
    my $axisObj = new XDF::Axis( { 'name' => 'first axis',
                                   'valueList' => \@axisValueList,
                                 }
                               );



...

=head1 DESCRIPTION

 There must be one axis (or fieldAxis) for every dimension in the datacube. There are n indices for every axis (n>= 1).  Each axis declaration defines the values of ALL the indices  along that dimension. Values of the indices in that axis need  not follow any algorthm for progression BUT each must be unique within the axis. A unit may be assocated with the axis.  Note that the unit specified for the axis indices is not the  same as the unit of the data held within the data cube. 

XDF::Axis inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Axis.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::Axis; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::Axis; This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

The STRING description (short name) of this object.  

=item description

A scalar string description (long name) of this object.  

=item axisDatatype

Holds a SCALAR object reference to a single Datatype (L<XDF::DataFormat>) object for this axis.  

=item axisUnits

Holds a SCALAR object reference to the XDF::Units object for this axis.  

=item align

B<NOT CURRENTLY IMPLEMENTED> 

=item axisId

A scalar string holding the axis id of this object.  

=item axisIdRef

A scalar string holding the reference object axisId. A reference object is used to supply those attributesof the object which have not been set. Note that $obj->axisIdRef is simply what will be written to the XML file if $obj->toXMLFileHandle method is called. You will have to $obj->setObjRef($refObject) to get the referencing functionality within the code.  

=item valueList

Holds a scalar Array Reference to the list of axisValue objects for this axis.  

=back

=head2 OTHER Methods

=over 4

=item addAxisValue ($value)

Add an XDF::AxisValue object to this axis. 

=item setAxisValue ($valueOrValueObjRef, $index)

Set the value of this axis at the given index. 

=item addAxisUnitDirection ($attribHashRef)

Add an XDF::UnitDirection object to this axis. 

=item removeAxisValue ($what)

Remove either an XDF::Value or XDF::UnitDirection object from this axis. $what may either be an index value or object reference. 

=item getAxisValue ($index)

Returns the axis XDF::Value object at the specified index. 

=item getAxisValues (EMPTY)

This is a convenience method which returns all of the values (as strings) on this axis. 

=item addUnit (EMPTY)

Add an XDF::Unit object to the XDF::Units object contained in this axis. 

=item removeUnit ($indexOrObjectRef)

Remove an XDF::Unit object from the XDF::Units object contained in this axis. 

=item addValueGroup ($attribHashRefOrObjectRef)

Insert a ValueGroup object into this object to group the axisValues. 

=item removeValueGroup ($hashKey)

Remove a ValueGroup object from this object 

=item length (EMPTY)

Get the length of this axis (eg number of axis value objects) 

=item getIndexFromAxisValue ($value)



=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::Axis inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::Axis inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>, L<XDF::UnitDirection>, L<XDF::ValueGroup>, L<XDF::Units>, L<XDF::Value>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut


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
use XDF::Utility;
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

# the order of these attributes IS important.
# 
my @Class_XML_Attributes = qw (
                      name
                      description
                      axisDatatype
                      axisUnits
                      align
                      axisId
                      axisIdRef
                      valueList
                          ); 

my @Class_Attributes = qw (
                             _length
                             _valueGroupOwnedHash
                          ); 

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

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

#
# set/get Methods
#

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $self->{Name};
}

# /** setName
#     Set the name attribute. 
# */
sub setName {
   my ($self, $value) = @_;
   $self->{Name} = $value;
}

# /** getDescription
#  */
sub getDescription {
   my ($self) = @_;
   return $self->{Description};
}

# /** setDescription
#  */
sub setDescription {
   my ($self, $value) = @_;
   $self->{Description} = $value;
}

# /** getAxisDatatype
# */
sub getAxisDatatype {
   my ($self) = @_;
   return $self->{AxisDatatype};
}

# /** setAxisDatatype
#     Set the axisDatatype attribute. 
# */
sub setAxisDatatype {
   my ($self, $value) = @_;

   carp "Cant set axisDatatype to $value, not allowed \n"
      unless (&XDF::Utility::isValidDatatype($value));

   $self->{AxisDatatype} = $value;

}

# /** getAxisUnits
# */
sub getAxisUnits {
   my ($self) = @_;
   return $self->{AxisUnits};
}

# /** setAxisUnits
#     Set the axisUnits attribute. 
# */
sub setAxisUnits {
   my ($self, $value) = @_;
   $self->{AxisUnits} = $value;
}

# /** getAxisId
# */
sub getAxisId {
   my ($self) = @_;
   return $self->{AxisId};
}

# /** setAxisId
#     Set the axisId attribute. 
# */
sub setAxisId {
   my ($self, $value) = @_;
   $self->{AxisId} = $value;
}

# /** getAxisIdRef 
# */
sub getAxisIdRef {
   my ($self) = @_;
   return $self->{AxisIdRef};
}

# /** setAxisIdRef
#     Set the axisIdRef attribute. 
# */
sub setAxisIdRef {
   my ($self, $value) = @_;
   $self->{AxisIdRef} = $value;
}

# /** getAlign
# */
sub getAlign {
   my ($self) = @_;
   return $self->{Align};
}

# /** setAlign
#     Set the align attribute. 
# */
sub setAlign {
   my ($self, $value) = @_;
   $self->{Align} = $value;
}

# /** getValueList
#  */
sub getValueList {
   my ($self) = @_;
   return $self->{ValueList};
}

# /** setValueList
#  */
sub setValueList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{ValueList} = \@list;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

# /** getLength
# Get the length of this axis (eg number of axis value objects) 
# */
sub getLength {
  my ($self) = @_;
  $self->{_length};
}

#
# Other Public Methods
#

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

  my $index = $self->{_length};

  if (defined @{$self->{ValueList}}->[$index]) {
     # increase the size of the array by pushing
     push @{$self->{ValueList}}, $obj;
  } else {
     # use a pre-alocated spot that is undefined
     @{$self->{ValueList}}->[$index] = $obj;
  }

  # bump up the size of this axis
  $self->{_length} = $self->{_length} + 1;

  return $obj;
}

# /** setAxisValue
# Set the value of this axis at the given index.
# */
sub setAxisValue {
  my ($self, $index, $valueOrValueObjRef ) = @_;

  return unless defined $index && $index >= 0;

  unless (defined $valueOrValueObjRef) {
     if (defined @{$self->{ValueList}}->[$index]) {
        # if the axisValue is presently defined, we lower
        # the length of the axis by 1
        $self->{_length} = $self->{_length} - 1;
        @{$self->{ValueList}}->[$index] = undef;
     }
     return;
  }
    
  my $valueObj = $valueOrValueObjRef;

  unless (ref($valueObj) eq 'XDF::Value' or 
          ref($valueObj) eq 'XDF::UnitDirection' )
  {
    $valueObj  = new XDF::Value(); #@{$self->{ValueList}}->[$index];
    $valueObj->setValue($valueOrValueObjRef);
  } 

  # if the axisValue is not presently defined, we raise
  # the length of the axis by 1
  if (!defined @{$self->{ValueList}}->[$index]) {
     $self->{_length} = $self->{_length} + 1;
  }

  @{$self->{ValueList}}->[$index] = $valueObj;

  return $valueObj;
}

# /** addAxisUnitDirection
# Add an XDF::UnitDirection object to this axis. 
# */ 
sub addAxisUnitDirection {
  my ($self, $attribHashRef) = @_; 

  my $obj = XDF::UnitDirection->new($attribHashRef);

  my $index = $self->{_length};
  if (defined @{$self->{ValueList}}->[$index]) {
     # increase the size of the array by pushing
     push @{$self->{ValueList}}, $obj;
  } else {
     # use a pre-alocated spot that is undefined
     @{$self->{ValueList}}->[$index] = $obj;
  }

  return $obj;
}

# /** removeAxisValue 
# Remove either an XDF::Value or XDF::UnitDirection object from this axis. 
# $what may either be an index value or object reference. 
# */ 
sub removeAxisValue {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->{ValueList}, 'valueList');
  # bump down size of the axis 
  $self->{_length} = $self->{_length} -1;
}

# /** getAxisValue 
# Returns the axis XDF::Value object at the specified index.
# */ 
sub getAxisValue {
  my ($self, $index) = @_;
  return unless (defined $index && $index >= 0);
  return $self->getAxisValues->[$index];
}

# /** getAxisValues 
# This is a convenience method which returns all of the values (as strings) on this axis. 
# */ 
sub getAxisValues {
   my ($self) = @_;

   my @values = ();
   foreach my $axisVal (@{$self->{ValueList}}) {
      next unless defined $axisVal;
      push @values, $axisVal->getValue();
   }

   return @values;
}

# /** addUnit 
# Add an XDF::Unit object to the XDF::Units object contained in this axis. 
# */ 
sub addUnit { my ($self, $attribHashRefOrObjectRef) = @_;
   my $unitObj = $self->{AxisUnits}->addUnit($attribHashRefOrObjectRef);
   return $unitObj;
}

# /** removeUnit 
# Remove an XDF::Unit object from the XDF::Units object contained in this axis. 
# */ 
sub removeUnit { 
  my ($self, $indexOrObjectRef) = @_; 
  return $self->{AxisUnits}->removeUnit($indexOrObjectRef); 
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
  %{$self->{_valueGroupOwnedHash}}->{$groupObj} = $groupObj;

  return $groupObj;
}

# /** removeValueGroup 
# Remove a ValueGroup object from this object 
# */
sub removeValueGroup { 
  my ($self, $hashKey ) = @_; 
  delete %{$self->{_valueGroupOwnedHash}}->{$hashKey}; 
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
  foreach $index (0 .. $#{$self->{ValueList}}) {
    my $axisValue = @{$self->{ValueList}}->[$index];
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

  $self->{AxisUnits} = new XDF::Units();
  $self->{AxisUnits}->setXMLNodeName("axisUnits");

  $self->{_valueGroupOwnedHash} = {};

  # initialize lists 
  $self->{ValueList} = [];

  # set the minimum array size (essentially the size of the axis)
  my $spec = XDF::Specification->getInstance();
  $#{$self->{ValueList}} = $spec->getDefaultDataArraySize();

  # this variable is needed because $#{$self->{ValueList}}
  # is pre-allocated in prior statement, and is not necess.
  # reflective of the real axis size.
  $self->{_length} = 0;

}

# Modification History
#
# $Log$
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

XDF::Axis inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Axis.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::Axis; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::Axis; This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item addUnit (EMPTY)

Add an XDF::Unit object to the XDF::Units object contained in this axis.  

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

 

=item setValueList ($arrayRefValue)

 

=item getLength (EMPTY)

Get the length of this axis (eg number of axis value objects)  

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

=item removeUnit ($indexOrObjectRef)

Remove an XDF::Unit object from the XDF::Units object contained in this axis.  

=item addValueGroup ($attribHashRefOrObjectRef)

Insert a ValueGroup object into this object to group the axisValues.  

=item removeValueGroup ($hashKey)

Remove a ValueGroup object from this object  

=item getIndexFromAxisValue ($valueOrValueObj)

Return the axis index for the given (scalar) value. Does not currently work for unitDirection objects that resideon an axis. Returns -1 if it cant find an index for the given value.  

=back



=head2 INHERITED Class Methods

=over 4



=over 4

The following class methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>. 

=back

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Axis inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Axis inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::UnitDirection>, L<XDF::ValueGroup>, L<XDF::Units>, L<XDF::Utility>, L<XDF::Value>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

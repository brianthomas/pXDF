
# $Id$

package XDF::FieldAxis;

# /** COPYRIGHT
#    FieldAxis.pm Copyright (C) 2000 Brian Thomas,
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
# There must be one axis (or fieldAxis) for every dimension
# in the datacube. There is never more than one field axis in
# a given L<XDF::Array> however. There are n indices for any
# field axis (n >= 1) at which lie one L<XDF::Field>.
#@
#@
# Unlike L<XDF::Axis> no units are assocated 
# with the field axis but rather with each individual field contained
# in the field axis. The units specified for the fields (one for 
# every indice of the field axis) is the same meaning as for the 
# units of XDF::Array. It is illegal to specify BOTH units on the
# array object AND have a field axis.
# */

# /** SYNOPSIS
#
# */

# /** SEE ALSO
# XDF::Array
# XDF::Axis
# */

use Carp;
use XDF::BaseObject;
use XDF::Field;
use XDF::FieldGroup;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_Node_Name = "fieldAxis";
# the order of these attributes IS important. In order for the ID/IDREF
# stuff to work, _objRef MUST be the last attribute
my @Class_Attributes = qw (
                      name
                      description
                      align
                      axisId
                      axisIdRef
                      fieldList
                      _length
                      _fieldGroupOwnedHash
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# /** name
# The STRING description (short name) of this object.
# */
# /** description
# A scalar string description (long name) of this object.
# */
# /** axisId
# A scalar string holding the axis Id of this object. 
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
# /** fieldList
# Holds a scalar ARRAY reference to the list of field objects held by this object.
# */

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name for XDF::FieldAxis; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {

  $Class_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes for XDF::FieldAxis; 
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

  # initialize lists
  $self->fieldList([]);
  $self->_fieldGroupOwnedHash({});

  # set the minimum array size (essentially the size of the axis)
  $#{$self->fieldList} = $self->DefaultDataArraySize();

  $self->_length(0);
}

# /** addField
# Adds a field to this field Axis. Takes either an attribute HASH
# reference (the attributes in the hash must correspond to those
# of L<XDF::Field>) or an XDF::Field object reference as its argument. 
# Returns the field object reference on success, undef on failure.
# */
sub addField {
  my ($self, $attribHashOrObjectRef) = @_;

  my $fieldObj;
  if (ref($attribHashOrObjectRef) eq 'XDF::Field') {
    $fieldObj = $attribHashOrObjectRef;
  } else {
    $fieldObj = XDF::Field->new($attribHashOrObjectRef);
  }
  
  # add the parameter to the list
  push @{$self->fieldList}, $fieldObj;

  # bump up the size
  $self->_length($self->_length + 1);

  return $fieldObj;
}

# /** getField
# Returns the field object reference at specified index on success, undef on failure.
# */
sub getField {
  my ($self, $index) = @_;
  return unless defined $index && $index >= 0;
  return @{$self->fieldList}->[$index];
}

# /** getFields
# Convenience method that returns ALL field objects held in this field axis. 
# Returns a list of field object references (ordered by field axis index). 
# If there are no fields in this field axis, the returned list is empty.
# */
sub getFields { 
  my ($self) = @_; 
  my @list;
  foreach my $field (@{$self->fieldList()}) {
    push @list, $field if defined $field;
  }
  return @list;
}

# /** setField
# Set the field object at indicated index. Returns the field object on
# success, undef on failure.
# */
sub setField {
  my ($self, $index, $fieldObjectRef) = @_;

  return unless defined $index && defined $fieldObjectRef && $index >= 0; 
  splice @{$self->fieldList}, $index, 1, $fieldObjectRef; 
  return $fieldObjectRef;
}

# /** removeField
# Remove a field object from the list of fields
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeField {
  my ($self, $indexOrObjectRef) = @_;
  my $ret_val = $self->_remove_from_list($indexOrObjectRef, $self->fieldList(), 'fieldList');
  $self->_length($self->_length - 1) if defined $ret_val;
  return $ret_val;
}

# /** length
# return the length of this field axis (eg number of field objects) 
# */
sub length { 
  my ($self) = @_; 
  return $self->_length(); 
}

# /** dataFormatList
# Returns a list of all the dataType objects (see L<XDF::DataFormat>) held 
# by the fields in this field axis. The list is ordered according to the order
# of the fields within the field axis. 
# */
sub dataFormatList {
  my ($self) = @_;

  my @list;
  foreach my $field ($self->getFields) {
    if (!defined $field->dataFormat) {
      carp "Error! FieldAxis dataFormatList request has problem: $field does not have dataFormat defined, ignoring (probably will cause an IO error)\n";
    } else { 
      push @list, $field->dataFormat();
    }
  }

  return @list;

}

# /** addFieldGroup 
# Insert a fieldGroup object into this object.
# Returns fieldGroup object on success, undef on failure.
# */ 
sub addFieldGroup {
  my ($self, $attribHashOrObjectRef) = @_;
 
  return unless defined $attribHashOrObjectRef && ref $attribHashOrObjectRef;

  my $fieldGroupObj;
  if ( $attribHashOrObjectRef =~ m/XDF::FieldGroup/) { 
    $fieldGroupObj = $attribHashOrObjectRef;
  } else {
    $fieldGroupObj = new XDF::FieldGroup($attribHashOrObjectRef);
  }

  # add the group to the groupOwnedHash
  %{$self->_fieldGroupOwnedHash}->{$fieldGroupObj} = $fieldGroupObj;

  return $fieldGroupObj;
}

# /** removeFieldGroup 
# Remove a fieldGroup object from this object. 
# */
sub removeFieldGroup {
  my ($self, $hashKey) = @_;
  delete %{$self->_fieldGroupOwnedHash}->{$hashKey};
}

# Modification History
#
# $Log$
# Revision 1.2  2000/10/16 17:38:57  thomas
# Fixed a method that was calling fieldList instead
# of getFields (which accounts for null entries on
# the field list accurately).
# Added Modification History.
# Changed over to BaseObject from Object.pm
#
#
#

1;


__END__

=head1 NAME

XDF::FieldAxis - Perl Class for FieldAxis

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 There must be one axis (or fieldAxis) for every dimension in the datacube. There is never more than one field axis in a given L<XDF::Array> however. There are n indices for any field axis (n >= 1) at which lie one L<XDF::Field>.  
 
 Unlike L<XDF::Axis> no units are assocated  with the field axis but rather with each individual field contained in the field axis. The units specified for the fields (one for  every indice of the field axis) is the same meaning as for the  units of XDF::Array. It is illegal to specify BOTH units on the array object AND have a field axis. 

XDF::FieldAxis inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FieldAxis.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldAxis; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldAxis; This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

The STRING description (short name) of this object.  

=item description

A scalar string description (long name) of this object.  

=item align

B<NOT CURRENTLY IMPLEMENTED> 

=item axisId

A scalar string holding the axis Id of this object.  

=item axisIdRef

A scalar string holding the reference object axisId. A reference object is used to supply those attributesof the object which have not been set. Note that $obj->axisIdRef is simply what will be written to the XML file if $obj->toXMLFileHandle method is called. You will have to $obj->setObjRef($refObject) to get the referencing functionality within the code.  

=item fieldList

Holds a scalar ARRAY reference to the list of field objects held by this object.  

=back

=head2 OTHER Methods

=over 4

=item addField ($attribHashOrObjectRef)

Adds a field to this field Axis. Takes either an attribute HASHreference (the attributes in the hash must correspond to thoseof L<XDF::Field>) or an XDF::Field object reference as its argument. Returns the field object reference on success, undef on failure. 

=item getField ($index)

Returns the field object reference at specified index on success, undef on failure. 

=item getFields (EMPTY)

Convenience method that returns ALL field objects held in this field axis. Returns a list of field object references (ordered by field axis index). If there are no fields in this field axis, the returned list is empty. 

=item setField ($fieldObjectRef, $index)

Set the field object at indicated index. Returns the field object onsuccess, undef on failure. 

=item removeField ($indexOrObjectRef)

Remove a field object from the list of fieldsheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item length (EMPTY)

return the length of this field axis (eg number of field objects) 

=item dataFormatList (EMPTY)

Returns a list of all the dataType objects (see L<XDF::DataFormat>) held by the fields in this field axis. The list is ordered according to the orderof the fields within the field axis. 

=item addFieldGroup ($attribHashOrObjectRef)

Insert a fieldGroup object into this object. Returns fieldGroup object on success, undef on failure. 

=item removeFieldGroup ($hashKey)

Remove a fieldGroup object from this object. 

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

XDF::FieldAxis inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::FieldAxis inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L< XDF::Array>, L< XDF::Axis>, L<XDF::BaseObject>, L<XDF::Field>, L<XDF::FieldGroup>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut


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
#    my $fieldAxisObj = new XDF::FieldAxis();
#    $axisObj->name("first axis");
#    $axisObj->addField($fieldObj); # add a field to this field axis, it is now size '1'
#
#    or 
#
#    my $fieldAxisObj = new XDF::FieldAxis(10,5); # create a field axis wi/ length 10 
#                                                 # and 10 fields named 0 thru 9 each 
#                                                 # with stringDataFormat of length '5'. 
#
# */

# /** SEE ALSO
# XDF::Array
# XDF::Axis
# */

use XDF::BaseObject;
use XDF::Field;
use XDF::Log;
use XDF::StringDataFormat;
use XDF::FieldGroup;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_Node_Name = "fieldAxis";
# the order of these attributes IS important.
my @Local_Class_XML_Attributes = qw (
                      name
                      description
                      align
                      size
                      axisId
                      axisIdRef
                      fieldList
                          );
my @Local_Class_Attributes = qw (
                      _parentArray
                      _fieldGroupOwnedHash
                          );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;


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
  return $Class_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for XDF::FieldAxis; 
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

# /** getDataFormatList
# Returns a list of all the dataType objects (see L<XDF::DataFormat>) held 
# by the fields in this field axis. The list is ordered according to the order
# of the fields within the field axis. 
# */
sub getDataFormatList {
  my ($self) = @_;

  my @list;
  foreach my $field ($self->getFields) {
    if (!defined $field->getDataFormat()) {
      my $name = $field->getName();
      error("Error! FieldAxis dataFormatList request has problem: $field ($name) does not have dataFormat defined, ignoring (probably will cause an IO error)\n");
    } else {
      push @list, $field->getDataFormat();
    }
  }

  return @list;
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

# /** getFieldList
#  */
sub getFieldList {
   my ($self) = @_;
   return $self->{fieldList};
}

# /** setFieldList
#  */
sub setFieldList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{fieldList} = \@list;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
#sub getXMLAttributes {
#  return \@Class_XML_Attributes;
#}

# /** getLength
# return the length of this field axis (eg the number of fields held by this field axis) 
# */
sub getLength {
  my ($self) = @_;
  return $self->{size};
}

# /** getSize
# Return the size (length) of this field axis (eg the number of fields held by this field axis) 
# */
sub getSize {
   my ($self) = @_;
   return $self->{size};
}

#
# Other Public Methods
#

#/** new
# Create a new field axis. Optionally, if you specify the size attribute,
# the axis will be created with that many fields, each having a StringDataFormat
# of $fieldWidth size.
#*/
sub new {
  my ($proto, $attribHashOrSize, $fieldWidth) = @_;

   my $size;
   unless (ref $attribHashOrSize) {
     $size = $attribHashOrSize;
     $attribHashOrSize = undef;
   }
   my $self = $proto->SUPER::new($attribHashOrSize);
   $self->_init();

   # create with fields, as appropriate
   if (defined $size) {
      $fieldWidth = 1 unless defined $fieldWidth;
      foreach my $fieldNumber (0 .. ($size-1)) {
         my $fieldObj = new XDF::Field({'name' => $fieldNumber});
         $fieldObj->setDataFormat(new XDF::StringDataFormat({'length' => $fieldWidth}));
         $self->addField($fieldObj);
      }
   }
   return $self;
}

# /** addField
# Adds a field to this field Axis. 
# Returns 1 on success, 0 on failure.
# */
sub addField {
  my ($self, $fieldObj) = @_;

  unless (defined $fieldObj) {
    # No point in adding a field w/o a value for it.
    error("Cannot add an Field, no fieldObj specified. Ignoring request.\n");
    return 0;
  }

  my $index = $self->{size};

  if (defined @{$self->{fieldList}}->[$index]) {
     # increase the size of the array by pushing
     push @{$self->{fieldList}}, $fieldObj;
  } else {
     # use a pre-alocated spot that is undefined
     @{$self->{fieldList}}->[$index] = $fieldObj;
  }

  # bump up the size of this axis
  $self->{size}++;

  if (defined $self->{_parentArray}) {
     $self->{_parentArray}->_updateInternalLookupIndices();
  }

  # add the parameter to the list
#  push @{$self->{fieldList}}, $fieldObj;

  return 1;

}

# /** getField
# Returns the field object reference at specified index on success, undef on failure.
# */
sub getField {
  my ($self, $index) = @_;
  return unless defined $index && $index >= 0;
  return @{$self->{fieldList}}->[$index];
}

# /** getFields
# Convenience method that returns ALL field objects held in this field axis. 
# Returns a list of field object references (ordered by field axis index). 
# If there are no fields in this field axis, the returned list is empty.
# */
sub getFields { 
  my ($self) = @_; 
  my @list;
  foreach my $field (@{$self->{fieldList}}) {
    push @list, $field if defined $field;
  }
  return @list;
}

# /** setField
# Set the field object at indicated index. This method may also be used to 'remove'
# a field, the user requests that the index location be set to 'undef'. In either
# case this method returns the object that was set at the indicated index. If the
# method cannot set the field at the index location, the method
# returns undef on failure.
# */
sub setField {
  my ($self, $index, $fieldObjectRef) = @_;

  return unless defined $index && $index >= 0;

  # removing a value (setting to 'undef')
  unless (defined $fieldObjectRef) {
     if (defined @{$self->{fieldList}}->[$index]) {
        # if the field at that location is presently defined, we lower
        # the length of the field axis by 1
        $self->{size}--;
        @{$self->{fieldList}}->[$index] = undef;
     }
     return;
  }

  # if a field is not presently defined at the indicated location
  # we raise the length of the axis by 1
  if (!defined @{$self->{fieldList}}->[$index]) {
     $self->{size}++;
    
     # also means that length changed, so we need to update this too
     if (defined $self->{_parentArray}) {
        $self->{_parentArray}->_updateInternalLookupIndices();
     }

  }

  # add the field
  @{$self->{fieldList}}->[$index] = $fieldObjectRef;

#  splice @{$self->{fieldList}}, $index, 1, $fieldObjectRef; 
  return $fieldObjectRef;
}

# /** removeField
# Remove a field object from the list of fields
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeField {
  my ($self, $fieldObj) = @_;

  if ($self->_remove_from_list($fieldObj, $self->{fieldList}, 'fieldList')) {

     $self->{size}--;

     if (defined $self->{_parentArray}) {
        $self->{_parentArray}->_updateInternalLookupIndices();
     }
     return 1;
  }

  return 0;

}


# /** addFieldGroup 
# Insert a fieldGroup object into this object.
# Returns 1 on success, 0 on failure.
# */ 
sub addFieldGroup {
  my ($self, $fieldGroupObj) = @_;
 
  return 0 unless defined $fieldGroupObj && ref $fieldGroupObj;

  # add the group to the groupOwnedHash
  %{$self->{_fieldGroupOwnedHash}}->{$fieldGroupObj} = $fieldGroupObj;

  return 1;
}

# /** removeFieldGroup 
# Remove a fieldGroup object from this object. 
# Returns 1 on success, 0 on failure.
# */
sub removeFieldGroup {
   my ($self, $hashKey) = @_;
   if (exists %{$self->{_fieldGroupOwnedHash}}->{$hashKey}) {
      delete %{$self->{_fieldGroupOwnedHash}}->{$hashKey};
      return 1;
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

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  # initialize lists
  $self->{fieldList} = [];
  $self->{_fieldGroupOwnedHash} = {};
  $self->{size} = 0;

  # DONT do this
  # set the minimum array size (essentially the size of the axis)
  # my $spec= XDF::Specification->getInstance();
  # $#{$self->{fieldList}} = $spec->getDefaultDataArraySize();

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);


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

1;


__END__

=head1 NAME

XDF::FieldAxis - Perl Class for FieldAxis

=head1 SYNOPSIS

 
    my $fieldAxisObj = new XDF::FieldAxis();
    $axisObj->name("first axis");
    $axisObj->addField($fieldObj); # add a field to this field axis, it is now size '1'

    or 

    my $fieldAxisObj = new XDF::FieldAxis(10,5); # create a field axis wi/ length 10 
                                                 # and 10 fields named 0 thru 9 each 
                                                 # with stringDataFormat of length '5'. 



...

=head1 DESCRIPTION

 There must be one axis (or fieldAxis) for every dimension in the datacube. There is never more than one field axis in a given L<XDF::Array> however. There are n indices for any field axis (n >= 1) at which lie one L<XDF::Field>.  
 
 Unlike L<XDF::Axis> no units are assocated  with the field axis but rather with each individual field contained in the field axis. The units specified for the fields (one for  every indice of the field axis) is the same meaning as for the  units of XDF::Array. It is illegal to specify BOTH units on the array object AND have a field axis. 

XDF::FieldAxis inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::FieldAxis.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldAxis; This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldAxis; This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item new ($attribHashOrSize, $fieldWidth)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::FieldAxis.

=over 4

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription (EMPTY)

 

=item setDescription ($value)

 

=item getDataFormatList (EMPTY)

Returns a list of all the dataType objects (see L<XDF::DataFormat>) held by the fields in this field axis. The list is ordered according to the orderof the fields within the field axis.  

=item getAxisId (EMPTY)

 

=item setAxisId ($value)

Set the axisId attribute.  

=item getAxisIdRef (EMPTY)

 

=item setAxisIdRef ($value)

Set the axisIdRef attribute.  

=item getAlign (EMPTY)

 

=item setAlign ($value)

Set the align attribute.  

=item getFieldList (EMPTY)

 

=item setFieldList ($arrayRefValue)

 

=item getLength (EMPTY)

return the length of this field axis (eg number of field objects)  

=item addField ($fieldObj)

Adds a field to this field Axis. Returns 1 on success, 0 on failure.  

=item getField ($index)

Returns the field object reference at specified index on success, undef on failure.  

=item getFields (EMPTY)

Convenience method that returns ALL field objects held in this field axis. Returns a list of field object references (ordered by field axis index). If there are no fields in this field axis, the returned list is empty.  

=item setField ($index, $fieldObjectRef)

Set the field object at indicated index. This method may also be used to 'remove'a field, the user requests that the index location be set to 'undef'. In eithercase this method returns the object that was set at the indicated index. If themethod cannot set the field at the index location, the methodreturns undef on failure.  

=item removeField ($fieldObj)

Remove a field object from the list of fieldsheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=item addFieldGroup ($fieldGroupObj)

Insert a fieldGroup object into this object. Returns 1 on success, 0 on failure.  

=item removeFieldGroup ($hashKey)

Remove a fieldGroup object from this object. Returns 1 on success, 0 on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::FieldAxis inherits the following instance (object) methods of L<XDF::GenericObject>:
B<clone>, B<update>.

=back



=over 4

XDF::FieldAxis inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L< XDF::Axis>, L<XDF::BaseObject>, L<XDF::Field>, L<XDF::StringDataFormat>, L<XDF::FieldGroup>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

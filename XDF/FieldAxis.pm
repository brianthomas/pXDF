
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
# the order of these attributes IS important.
my @Class_XML_Attributes = qw (
                      name
                      description
                      align
                      axisId
                      axisIdRef
                      fieldList
                          );
my @Class_Attributes = qw (
                      _length
                      _fieldGroupOwnedHash
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

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
      carp "Error! FieldAxis dataFormatList request has problem: $field ($name) does not have dataFormat defined, ignoring (probably will cause an IO error)\n";
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

# /** getFieldList
#  */
sub getFieldList {
   my ($self) = @_;
   return $self->{FieldList};
}

# /** setFieldList
#  */
sub setFieldList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{FieldList} = \@list;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

# /** getLength
# return the length of this field axis (eg number of field objects) 
# */
sub getLength {
  my ($self) = @_;
  return $self->{_length};
}

#
# Other Public Methods
#

# /** addField
# Adds a field to this field Axis. Takes either an attribute HASH
# reference (the attributes in the hash must correspond to those
# of L<XDF::Field>) or an XDF::Field object reference as its argument. 
# Returns the field object reference on success, undef on failure.
# */
sub addField {
  my ($self, $attribHashOrObjectRef) = @_;

  unless (defined $attribHashOrObjectRef) {
    # No point in adding a field w/o a value for it.
    carp "Cannot add an Field, no attribHashOrObjectRef specified. Ignoring request.\n";
    return;
  }

  my $fieldObj;
  if (ref($attribHashOrObjectRef) eq 'XDF::Field') {
    $fieldObj = $attribHashOrObjectRef;
  } else {
    $fieldObj = XDF::Field->new($attribHashOrObjectRef);
  }
  
  my $index = $self->{_length};

  if (defined @{$self->{FieldList}}->[$index]) {
     # increase the size of the array by pushing
     push @{$self->{FieldList}}, $fieldObj;
  } else {
     # use a pre-alocated spot that is undefined
     @{$self->{FieldList}}->[$index] = $fieldObj;
  }

  # bump up the size of this axis
  $self->{_length}++;

  # add the parameter to the list
#  push @{$self->{FieldList}}, $fieldObj;

  return $fieldObj;

}

# /** getField
# Returns the field object reference at specified index on success, undef on failure.
# */
sub getField {
  my ($self, $index) = @_;
  return unless defined $index && $index >= 0;
  return @{$self->{FieldList}}->[$index];
}

# /** getFields
# Convenience method that returns ALL field objects held in this field axis. 
# Returns a list of field object references (ordered by field axis index). 
# If there are no fields in this field axis, the returned list is empty.
# */
sub getFields { 
  my ($self) = @_; 
  my @list;
  foreach my $field (@{$self->{FieldList}}) {
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
     if (defined @{$self->{FieldList}}->[$index]) {
        # if the field at that location is presently defined, we lower
        # the length of the field axis by 1
        $self->{_length}--;
        @{$self->{FieldList}}->[$index] = undef;
     }
     return;
  }

  # if a field is not presently defined at the indicated location
  # we raise the length of the axis by 1
  if (!defined @{$self->{FieldList}}->[$index]) {
     $self->{_length}++;
  }

  # add the field
  @{$self->{FieldList}}->[$index] = $fieldObjectRef;

#  splice @{$self->{FieldList}}, $index, 1, $fieldObjectRef; 
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
  my $ret_val = $self->_remove_from_list($indexOrObjectRef, $self->{FieldList}, 'fieldList');
  $self->{_length}-- if defined $ret_val;
  return $ret_val;
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
  %{$self->{_fieldGroupOwnedHash}}->{$fieldGroupObj} = $fieldGroupObj;

  return $fieldGroupObj;
}

# /** removeFieldGroup 
# Remove a fieldGroup object from this object. 
# */
sub removeFieldGroup {
  my ($self, $hashKey) = @_;
  delete %{$self->{_fieldGroupOwnedHash}}->{$hashKey};
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
  $self->{FieldList} = [];
  $self->{_fieldGroupOwnedHash} = {};

  # set the minimum array size (essentially the size of the axis)
  my $spec= XDF::Specification->getInstance();
  $#{$self->{FieldList}} = $spec->getDefaultDataArraySize();

  $self->{_length} = 0;

}


# Modification History
#
# $Log$
# Revision 1.10  2001/04/17 19:00:10  thomas
# Using Specification class now.
# Properly calling superclass init now.
#
# Revision 1.9  2001/03/21 20:19:23  thomas
# Fixed documentation to show addXMLElement, etc. methods in perldoc
#
# Revision 1.8  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.7  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2001/03/14 16:10:36  thomas
# addField and setField fixed. Previously these where just
# pushing fields onto the end of the fieldList. The problem is that
# that array is pre-allocated, so the operation resulted in tacking on
# more fields to the end of the array. Now we set the field at a
# free index, or if there are no free indices, we add a new one. We
# will probably have to re-visit this issue again in the future.
#
# Revision 1.5  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:25  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
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

XDF::FieldAxis inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::FieldAxis.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldAxis; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldAxis; This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

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

=item addField ($attribHashOrObjectRef)

Adds a field to this field Axis. Takes either an attribute HASHreference (the attributes in the hash must correspond to thoseof L<XDF::Field>) or an XDF::Field object reference as its argument. Returns the field object reference on success, undef on failure.  

=item getField ($index)

Returns the field object reference at specified index on success, undef on failure.  

=item getFields (EMPTY)

Convenience method that returns ALL field objects held in this field axis. Returns a list of field object references (ordered by field axis index). If there are no fields in this field axis, the returned list is empty.  

=item setField ($fieldObjectRef, $index)

Set the field object at indicated index. This method may also be used to 'remove'a field, the user requests that the index location be set to 'undef'. In eithercase this method returns the object that was set at the indicated index. If themethod cannot set the field at the index location, the methodreturns undef on failure.  

=item removeField ($indexOrObjectRef)

Remove a field object from the list of fieldsheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=item addFieldGroup ($attribHashOrObjectRef)

Insert a fieldGroup object into this object. Returns fieldGroup object on success, undef on failure.  

=item removeFieldGroup ($hashKey)

Remove a fieldGroup object from this object.  

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

XDF::FieldAxis inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FieldAxis inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L< XDF::Axis>, L<XDF::BaseObject>, L<XDF::Field>, L<XDF::FieldGroup>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

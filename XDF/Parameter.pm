
# $Id$

package XDF::Parameter;

# /** COPYRIGHT
#    Parameter.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Parameter describes a scientific parameter assocated with the 
# L<XDF::Structure> or L<XDF::Array> that it is contained in.
# Parameter is a flexible container for holding what is essentially information 
# about data but is not needed to read/write/manipulate the data in a mathematical sense. 
# */

# /** SYNOPSIS
#
#    my $parameterObj = $dataObj->add_parameter();
#
#    $parameterObj->name('param1');
#    $parameterObj->value(1000);
#
#    my $parameter_name = $parameterObj->name();
#  
# */

# /** SEE ALSO
# XDF::Array
# XDF::ParameterGroup
# XDF::Structure
# */


use XDF::BaseObjectWithXMLElementsAndValueList;
use XDF::ErroredValue;
use XDF::Log;
use XDF::Note;
use XDF::Units;
use XDF::Utility;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);


# inherits from XDF::BaseObjectWithXMLElementsAndValueList 
@ISA = ("XDF::BaseObjectWithXMLElementsAndValueList");

# CLASS DATA
# /** name
# The STRING description (short name) of this object. 
# */
# /** description
# A scalar string description (long name) of this object. 
# */
# /** paramId
# A scalar (STRING)holding the param Id of this object.
# */
# /** paramIdRef 
# A scalar (STRING) holding the parameter id reference to another parameter.
# Note that in order to get the code to use the reference object,
# the $obj->setObjRef($refFieldObj) method should be used.
# */
# /** datatype
# Holds a SCALAR object reference to a single datatype (L<XDF::DataFormat>) object for this axis. 
# */
# */
# /** units
# a SCALAR (OBJECT REF) of the L<XDF::Units> object of this parameter. The XDF::Units object 
# is used to hold the XDF::Unit objects.
# */
# /** noteList
# a SCALAR (ARRAY REF) of the list of L<XDF::Note> objects held within this parameter.
# */
# /** valueList
# a SCALAR (ARRAY REF) of the list of L<XDF::Value> objects held within in this parameter.
# */
my $Class_XML_Node_Name = "parameter";
my @Local_Class_XML_Attributes = qw (
                      name
                      description
                      paramId
                      paramIdRef
                      datatype
                      units
                      valueList
                      noteList
                          );
my @Local_Class_Attributes = qw (
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
# This method returns the class node name of XDF::Parameter.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  return $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FloatDataFormat. 
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
# Get/Set Methods
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

# /** getParamId
# */
sub getParamId {
   my ($self) = @_;
   return $self->{paramId};
}

# /** setParamId
#     Set the paramId attribute. 
# */
sub setParamId {
   my ($self, $value) = @_;
   $self->{paramId} = $value;
}

# /** getParamIdRef
# */
sub getParamIdRef {
   my ($self) = @_;
   return $self->{paramIdRef};
}

# /** setParamIdRef
#     Set the paramIdRef attribute. 
# */
sub setParamIdRef {
   my ($self, $value) = @_;
   $self->{paramIdRef} = $value;
}

# /** getDatatype
# */
sub getDatatype {
   my ($self) = @_;
   return $self->{datatype};
}

# /** setDatatype
#     Set the datatype attribute. 
# */
sub setDatatype {
   my ($self, $value) = @_;

   error("Cant set datatype to $value, not allowed \n") 
      unless (&XDF::Utility::isValidDatatype($value));

   $self->{datatype} = $value;
}

# /** getNoteList
# */
sub getNoteList {
   my ($self) = @_;
   return $self->{noteList};
}

# /** setNoteList
#     Set the noteList attribute. 
# */
sub setNoteList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{noteList} = \@list;
}

# /** getValueList
# */
sub getValueList {
   my ($self) = @_;
   return $self->{valueList};
}

# /** setValueList
#     Set the valueList attribute. You may either pass an array of Value
#     objects OR a valueList object (either ValueListAlgorithm or ValueListDelimitedList).
#     Using a valueList *object* will result in a more compact description of 
#     the passed values when the parameter is printed out.
# */
sub setValueList {
   my ($self, $arrayOrValueListObjRefValue) = @_;

   # clear old list
   $self->resetValues();
   $self->addValueList($arrayOrValueListObjRefValue);

}

# /** getUnits
# */
sub getUnits {
   my ($self) = @_;
   return $self->{units};
}

# /** setUnits
#     Set the units attribute. 
# */
sub setUnits {
   my ($self, $value) = @_;
   $self->{units} = $value;
}

#
# Other Public Methods
#

# /** addValueList
# Append a list of values held by the passed ValueListObject (or Array of Values)
# into this Parameter object.
# */
sub addValueList {
   my ($self, $arrayOrValueListObjRefValue) = @_;

   error("parameter->setValueList() passed non-reference.\n") 
      unless (ref($arrayOrValueListObjRefValue));

   if (ref($arrayOrValueListObjRefValue) eq 'ARRAY') {

      # you must do it this way, or when the arrayRef changes it changes us here!
      if ($#{$arrayOrValueListObjRefValue} >= 0) {
         foreach my $valueObj (@{$arrayOrValueListObjRefValue}) {
            push @{$self->{valueList}}, $valueObj;
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
             push @{$self->{valueList}}, $valueObj;
          }
          return 1;
       } else {
          warn("parameter->addValueList passed ValueList object with 0 values, Ignoring.\n");
       }

   }
   else
   {
      error("Unknown reference object passed to setvalueList in parameter:$arrayOrValueListObjRefValue. Dying.\n");
      exit -1;
   }

   return 0;
}


# /** resetValues
# Remove (reset the valueList) all Value objects held within this object.
# */
sub resetValues {
   my ($self) = @_;

   # free up all declared values
   $self->{valueList} = []; # has to be this way to avoid deep recursion 

   # no compact description allowed now 
   $self->_resetBaseValueListObjects();

}

# /** addValueGroup 
# Insert a valueGroup object into this object.
# Returns 1 on success, 0 on failure.
# */ 
sub addValueGroup {
  my ($self, $valueGroupObj) = @_;
 
  return 0 unless defined $valueGroupObj && ref $valueGroupObj;

  # add the group to the groupOwnedHash
  %{$self->{_valueGroupOwnedHash}}->{$valueGroupObj} = $valueGroupObj;

  return 1;
}

# /** removeValueGroup 
# Remove a valueGroup object from this object. 
# Returns 1 on success, 0 on failure.
# */
sub removeValueGroup {
   my ($self, $hashKey) = @_;
   if (exists %{$self->{_valueGroupOwnedHash}}->{$hashKey}) {
      delete %{$self->{_valueGroupOwnedHash}}->{$hashKey};
      return 1;
   }
   return 0;
}

# /** addValue
# Add an erroredValueObject to this object. 
# Returns 1 on success, 0 on failure. 
# */
sub addValue {
  my ($self, $valueObj) = @_;

  return 0 unless (defined $valueObj && ref $valueObj );

  # add the new value to the list
  push @{$self->{valueList}}, $valueObj;

  # no compact description allowed now 
  $self->_resetBaseValueListObjects();

  return 1;
}

# /** removeValue
# Remove an XDF::Value from the list of values in this parameter object.
# Takes either an index number or object reference as its argument. 
# Returns 1 on success, 0 on failure. 
# */
sub removeValue {
  my ($self, $indexOrObjectRef) = @_;
  my $success = $self->_remove_from_list($indexOrObjectRef, $self->{valueList}, 'valueList');
  if ($success) {
     # no compact description allowed now 
     $self->_resetBaseValueListObjects();
  }
  return $success;
}

# /** addNote
# Insert an XDF::Note object into the XDF::Notes object held by this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addNote {
  my ($self, $noteObj) = @_;

  return 0 unless defined $noteObj && ref $noteObj;

  # add the parameter to the list
  push @{$self->{noteList}}, $noteObj;

  return 1;

}

# /** removeNote
# Removes an XDF::Note object from the list of XDF::Note objects
# held within the XDF::Notes object of this object. This method takes 
# either the list index number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->{noteList}, 'noteList');
}

# /** addUnit
# Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)
# held in this object.
# RETURNS : 1 on success, 0 on failure.
sub addUnit { 
   my ($self, $unitObj) = @_;
   return $self->{units}->addUnit($unitObj);
}

# /** removeUnit
# Remove an XDF::Unit object from the list of XDF::Units held in
# the array units reference object. 
# RETURNS : 1 on success, 0 on failure.
# */
sub removeUnit {
  my ($self, $unitObj) = @_;
  return $self->{units}->removeUnit($unitObj);
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
  # initialize objects
  $self->setUnits(new XDF::Units());

  # initialize lists
  $self->{_valueGroupOwnedHash} = {};
  $self->setNoteList([]);
  $self->setValueList([]);

  $self->{_valueListGetMethodName} = "getValueList";

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


__END__

=head1 NAME

XDF::Parameter - Perl Class for Parameter

=head1 SYNOPSIS


    my $parameterObj = $dataObj->add_parameter();

    $parameterObj->name('param1');
    $parameterObj->value(1000);

    my $parameter_name = $parameterObj->name();
  


...

=head1 DESCRIPTION

 An XDF::Parameter describes a scientific parameter assocated with the  L<XDF::Structure> or L<XDF::Array> that it is contained in.  Parameter is a flexible container for holding what is essentially information  about data but is not needed to read/write/manipulate the data in a mathematical sense. 

XDF::Parameter inherits class and attribute methods of L< = (>, L<XDF::BaseObjectWithXMLElementsAndValueList>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Parameter.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Parameter. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Parameter.

=over 4

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription (EMPTY)

 

=item setDescription ($value)

 

=item getParamId (EMPTY)

 

=item setParamId ($value)

Set the paramId attribute.  

=item getParamIdRef (EMPTY)

 

=item setParamIdRef ($value)

Set the paramIdRef attribute.  

=item getDatatype (EMPTY)

 

=item setDatatype ($value)

Set the datatype attribute.  

=item getNoteList (EMPTY)

 

=item setNoteList ($arrayRefValue)

Set the noteList attribute.  

=item getValueList (EMPTY)

 

=item setValueList ($arrayOrValueListObjRefValue)

Set the valueList attribute. You may either pass an array of Valueobjects OR a valueList object (either ValueListAlgorithm or ValueListDelimitedList). Using a valueList *object* will result in a more compact description of the passed values when the parameter is printed out.  

=item getUnits (EMPTY)

 

=item setUnits ($value)

Set the units attribute.  

=item addValueList ($arrayOrValueListObjRefValue)

Append a list of values held by the passed ValueListObject (or Array of Values)into this Parameter object.  

=item resetValues (EMPTY)

Remove (reset the valueList) all Value objects held within this object.  

=item addValueGroup ($valueGroupObj)

Insert a valueGroup object into this object. Returns 1 on success, 0 on failure.  

=item removeValueGroup ($hashKey)

Remove a valueGroup object from this object. Returns 1 on success, 0 on failure.  

=item addValue ($valueObj)

Add an erroredValueObject to this object. Returns 1 on success, 0 on failure.  

=item removeValue ($indexOrObjectRef)

Remove an XDF::Value from the list of values in this parameter object. Takes either an index number or object reference as its argument. Returns 1 on success, 0 on failure.  

=item addNote ($noteObj)

Insert an XDF::Note object into the XDF::Notes object held by this object. RETURNS : 1 on success, 0 on failure.  

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item addUnit ($unitObj)

Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)held in this object. RETURNS : 1 on success, 0 on failure.  

=item removeUnit ($unitObj)

Remove an XDF::Unit object from the list of XDF::Units held inthe array units reference object. RETURNS : 1 on success, 0 on failure.  

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

L< XDF::Array>, L< XDF::ParameterGroup>, L< XDF::Structure>, L<XDF::Utility>, L<XDF::BaseObjectWithXMLElementsAndValueList>, L<XDF::Note>, L<XDF::Units>, L<XDF::ErroredValue>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

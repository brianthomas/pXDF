
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

use Carp;

use XDF::Utility;
use XDF::BaseObjectWithValueList;
use XDF::Note;
use XDF::Units;
use XDF::ErroredValue;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);


# inherits from XDF::BaseObjectWithValueList
@ISA = ("XDF::BaseObjectWithValueList");

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
my @Class_XML_Attributes = qw (
                      name
                      description
                      paramId
                      paramIdRef
                      datatype
                      units
                      valueList
                      noteList
                          );
my @Class_Attributes = qw (
                          _valueGroupOwnedHash
                       );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObjectWithValueList::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::Parameter.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Parameter. 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
}

#
# Get/Set Methods
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

# /** getParamId
# */
sub getParamId {
   my ($self) = @_;
   return $self->{ParamId};
}

# /** setParamId
#     Set the paramId attribute. 
# */
sub setParamId {
   my ($self, $value) = @_;
   $self->{ParamId} = $value;
}

# /** getParamIdRef
# */
sub getParamIdRef {
   my ($self) = @_;
   return $self->{ParamIdRef};
}

# /** setParamIdRef
#     Set the paramIdRef attribute. 
# */
sub setParamIdRef {
   my ($self, $value) = @_;
   $self->{ParamIdRef} = $value;
}

# /** getDatatype
# */
sub getDatatype {
   my ($self) = @_;
   return $self->{Datatype};
}

# /** setDatatype
#     Set the datatype attribute. 
# */
sub setDatatype {
   my ($self, $value) = @_;

   carp "Cant set datatype to $value, not allowed \n"
      unless (&XDF::Utility::isValidDatatype($value));

   $self->{Datatype} = $value;
}

# /** getNoteList
# */
sub getNoteList {
   my ($self) = @_;
   return $self->{NoteList};
}

# /** setNoteList
#     Set the noteList attribute. 
# */
sub setNoteList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{NoteList} = \@list;
}

# /** getValueList
# */
sub getValueList {
   my ($self) = @_;
   return $self->{ValueList};
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
   return $self->{Units};
}

# /** setUnits
#     Set the units attribute. 
# */
sub setUnits {
   my ($self, $value) = @_;
   $self->{Units} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
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

   croak "parameter->setValueList() passed non-reference.\n"
      unless (ref($arrayOrValueListObjRefValue));

   if (ref($arrayOrValueListObjRefValue) eq 'ARRAY') {

      # you must do it this way, or when the arrayRef changes it changes us here!
      if ($#{$arrayOrValueListObjRefValue} >= 0) {
         foreach my $valueObj (@{$arrayOrValueListObjRefValue}) {
            push @{$self->{ValueList}}, $valueObj;
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
             push @{$self->{ValueList}}, $valueObj;
          }
          return 1;
       } else {
          carp "parameter->addValueList passed ValueList object with 0 values, Ignoring.\n";
       }

   }
   else
   {
      croak "Unknown reference object passed to setvalueList in parameter:$arrayOrValueListObjRefValue. Dying.\n";
   }

   return 0;
}


# /** resetValues
# Remove (reset the valueList) all Value objects held within this object.
# */
sub resetValues {
   my ($self) = @_;

   # free up all declared values
   $self->{ValueList} = []; # has to be this way to avoid deep recursion 

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
  push @{$self->{ValueList}}, $valueObj;

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
  my $success = $self->_remove_from_list($indexOrObjectRef, $self->{ValueList}, 'valueList');
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
  push @{$self->{NoteList}}, $noteObj;

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
  $self->_remove_from_list($what, $self->{NoteList}, 'noteList');
}

# /** addUnit
# Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)
# held in this object.
# RETURNS : 1 on success, 0 on failure.
sub addUnit { 
   my ($self, $unitObj) = @_;
   return $self->{Units}->addUnit($unitObj);
}

# /** removeUnit
# Remove an XDF::Unit object from the list of XDF::Units held in
# the array units reference object. 
# RETURNS : 1 on success, 0 on failure.
# */
sub removeUnit {
  my ($self, $unitObj) = @_;
  return $self->{Units}->removeUnit($unitObj);
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

}

 
# Modification History
#
# $Log$
# Revision 1.13  2001/07/13 21:42:10  thomas
# added ValueList stuff
#
# Revision 1.12  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.11  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.10  2001/04/17 18:51:16  thomas
# properly calling superclass init now
#
# Revision 1.9  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.8  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.7  2001/03/09 21:52:11  thomas
# Added utility check on datatype attribute setting.
#
# Revision 1.6  2000/12/18 16:35:54  thomas
# Fixed Minor problem with getValue/addNote
# in class. -b.t.
#
# Revision 1.5  2000/12/15 22:12:00  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;



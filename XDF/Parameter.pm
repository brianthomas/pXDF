
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

use XDF::BaseObject;
use XDF::Note;
use XDF::Units;
use XDF::ErroredValue;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);


# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

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
my @Class_Attributes = qw (
                      name
                      description
                      paramId
                      paramIdRef
                      datatype
                      units
                      valueList
                      noteList
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

  # initialize objects
  $self->units(new XDF::Units());

  # initialize lists
  $self->noteList([]);
  $self->valueList([]);

}

# note: $info could be either string or attrib hash ref, see
# XDF::Note obj.
# /** addValue
# Add a value to this object. 
# Takes either an attribute HASH reference or object reference as its argument.
# Returns the value object reference on success, undef on failure. 
# */
sub addValue {
  my ($self, $attribHashRefOrStringOrObjectRef) = @_;

  return unless (defined $attribHashRefOrStringOrObjectRef);

  my $valueObj;

  if (ref $attribHashRefOrStringOrObjectRef eq 'XDF::ErroredValue') {
    $valueObj = $attribHashRefOrStringOrObjectRef;
  } else {
    $valueObj = XDF::ErroredValue->new($attribHashRefOrStringOrObjectRef);
  }

  # add the new value to the list
  push @{$self->valueList}, $valueObj;

  return $valueObj;
}

# /** getValues
# A convenience method. Returns a list of values in this parameter. 
# */
sub getValues {
  my ($self) = @_;
  return @{$self->valueList()};
}

# /** removeValue
# Remove an XDF::Value from the list of values in this parameter object.
# Takes either an index number or object reference as its argument. 
# Returns 1 on success, undef on failure. 
# */
sub removeValue {
  my ($self, $indexOrObjectRef) = @_;
  $self->_remove_from_list($indexOrObjectRef, $self->valueList(), 'valueList');
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
# Convenience method which returns a list of the notes held by 
# this object. 
# */
sub getNotes {
  my ($self, $what) = @_;
  return @{$self->noteList};
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
 
# Modification History
#
# $Log$
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

XDF::Parameter inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Parameter.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Parameter. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Parameter. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

The STRING description (short name) of this object.  

=item description

A scalar string description (long name) of this object.  

=item paramId

A scalar (STRING)holding the param Id of this object.  

=item paramIdRef

A scalar (STRING) holding the parameter id reference to another parameter. Note that in order to get the code to use the reference object,the $obj->setObjRef($refFieldObj) method should be used.  

=item datatype

Holds a SCALAR object reference to a single datatype (L<XDF::DataFormat>) object for this axis.  

=item units

a SCALAR (OBJECT REF) of the L<XDF::Units> object of this parameter. The XDF::Units object is used to hold the XDF::Unit objects.  

=item valueList

a SCALAR (ARRAY REF) of the list of L<XDF::Value> objects held within in this parameter.  

=item noteList

a SCALAR (ARRAY REF) of the list of L<XDF::Note> objects held within this parameter.  

=back

=head2 OTHER Methods

=over 4

=item addValue ($attribHashRefOrStringOrObjectRef)

Add a value to this object. Takes either an attribute HASH reference or object reference as its argument. Returns the value object reference on success, undef on failure. 

=item getValues (EMPTY)

A convenience method. Returns a list of values in this parameter. 

=item removeValue ($indexOrObjectRef)

Remove an XDF::Value from the list of values in this parameter object. Takes either an index number or object reference as its argument. Returns 1 on success, undef on failure. 

=item addNote ($info)

Insert an XDF::Note object into the XDF::Notes object held by this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Note> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Note object. RETURNS : an XDF::Note object reference on success, undef on failure. 

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item getNotes ($what)

Convenience method which returns a list of the notes held by this object. 

=item addUnit (EMPTY)

Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)held in this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::Unit asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::Unit> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Unit object. RETURNS : an XDF::Unit object if successfull, undef if not. 

=item removeUnit ($indexOrObjectRef)

Remove an XDF::Unit object from the list of XDF::Units held inthe array units reference object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

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

XDF::Parameter inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::Parameter inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::Array>, L< XDF::ParameterGroup>, L< XDF::Structure>, L<XDF::BaseObject>, L<XDF::Note>, L<XDF::Units>, L<XDF::ErroredValue>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

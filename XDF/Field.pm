
# $Id$

package XDF::Field;

# /** COPYRIGHT
#    Field.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Field describes a field at a given indice on a field axis. 
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::FieldAxis
# XDF::FieldRelationship;
# */

use Carp;
use XDF::Object;
use XDF::DataFormat;
#use XDF::Notes;
use XDF::Units;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);


# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
# /** name
# The STRING description (short name) of this Field. 
# */
# /** description
# A scalar string description (long name) of this Field. 
# */
# /** fieldId
# A scalar string holding the field id of this Field. 
# */
# /** fieldIdRef 
# A scalar string holding the field id reference to another field. 
# Note that in order to get the code to use the reference object,
# the $obj->setObjRef($refFieldObj) method should be used.
# */
# /** class
# The "class" of this field. B<NOT CURRENTLY IMPLEMENTED>
# */
# /** lessThanValue
# The STRING value which indicates the less than symbol ("<") within the data cube
# for data within the slice corresponding to this field.
# */
# /** lessThanOrEqualValue
# The STRING value which indicates the less than equal symbol ("=<") within the data cube
# for data within the slice corresponding to this field.
# */
# /** greaterThanValue
# The STRING value which indicates the greater than symbol (">") within the data cube
# for data within the slice corresponding to this field.
# */
# /** greaterThanOrEqualValue
# The STRING value which indicates the greater than equal symbol (">=") within the data cube
# for data within the slice corresponding to this field.
# */
# /** infiniteValue
# The STRING value which indicates the infinite value within the data cube
# for data within the slice corresponding to this field.
# */
# /** infiniteNegativeValue
# The STRING value which indicates the negative infinite value within the data cube
# for data within the slice corresponding to this field.
# */
# /** noDataValue
# The STRING value which indicates the no data value within the data cube
# for data within the slice corresponding to this field.
# */
# /** noteList
# a SCALAR (ARRAY REF) of the L<XDF::Note> objects held by this field.
# */
# /** dataFormat
# a SCALAR (OBJECT REF) of the L<XDF::DataFormat> object for data within this field.
# */
# /** relation
# a SCALAR (OBJECT REF) of the L<XDF::Relationship> object for this field.
# */
# /** units
# a SCALAR (OBJECT REF) of the L<XDF::Units> object of this field. The XDF::Units object 
# is used to hold the L<XDF::Unit> objects.
# */


my $Class_Node_Name = "field";
my @Class_Attributes = qw (
                      name
                      description
                      fieldId
                      fieldIdRef
                      class
                      lessThanValue
                      lessThanOrEqualValue
                      greaterThanValue
                      greaterThanOrEqualValue
                      infiniteValue
                      infiniteNegativeValue
                      noDataValue
                      units
                      dataFormat
                      relation
                      noteList
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::Field.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {

  $Class_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Field. 
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
  $self->noteList([]);
  $self->units(new XDF::Units());
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
# Convenience method which returns a list of the notes held by this 
# object.
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

1;


__END__

=head1 NAME

XDF::Field - Perl Class for Field

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::Field describes a field at a given indice on a field axis. 

XDF::Field inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Field.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Field. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Field. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

The STRING description (short name) of this Field.  

=item description

A scalar string description (long name) of this Field.  

=item fieldId

A scalar string holding the field id of this Field.  

=item fieldIdRef

A scalar string holding the field id reference to another field. Note that in order to get the code to use the reference object,the $obj->setObjRef($refFieldObj) method should be used.  

=item class

The "class" of this field. B<NOT CURRENTLY IMPLEMENTED> 

=item lessThanValue

The STRING value which indicates the less than symbol ("<") within the data cubefor data within the slice corresponding to this field.  

=item lessThanOrEqualValue

The STRING value which indicates the less than equal symbol ("=<") within the data cubefor data within the slice corresponding to this field.  

=item greaterThanValue

The STRING value which indicates the greater than symbol (">") within the data cubefor data within the slice corresponding to this field.  

=item greaterThanOrEqualValue

The STRING value which indicates the greater than equal symbol (">=") within the data cubefor data within the slice corresponding to this field.  

=item infiniteValue

The STRING value which indicates the infinite value within the data cubefor data within the slice corresponding to this field.  

=item infiniteNegativeValue

The STRING value which indicates the negative infinite value within the data cubefor data within the slice corresponding to this field.  

=item noDataValue

The STRING value which indicates the no data value within the data cubefor data within the slice corresponding to this field.  

=item units

a SCALAR (OBJECT REF) of the L<XDF::Units> object of this field. The XDF::Units object is used to hold the L<XDF::Unit> objects.  

=item dataFormat

a SCALAR (OBJECT REF) of the L<XDF::DataFormat> object for data within this field.  

=item relation

a SCALAR (OBJECT REF) of the L<XDF::Relationship> object for this field.  

=item noteList

a SCALAR (ARRAY REF) of the L<XDF::Note> objects held by this field.  

=back

=head2 OTHER Methods

=over 4

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

The following class attribute methods are inherited from L<XDF::Object>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::Field inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::Field inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::FieldAxis>, L< XDF::FieldRelationship;>, L<XDF::Object>, L<XDF::DataFormat>, L<XDF::Units>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut


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
use XDF::BaseObjectWithXMLElements;
use XDF::DataFormat;
use XDF::Units;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);


# inherits from XDF::BaseObjectWithXMLElements;
@ISA = ("XDF::BaseObjectWithXMLElements");

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
my @Class_XML_Attributes = qw (
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
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElements::classAttributes};

# add in super class XML attributes to our list 
push @Class_XML_Attributes, @{&XDF::BaseObjectWithXMLElements::getXMLAttributes};

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

#
# Get/Set Methods 
#

# /** getName
# */
sub getName{
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
# */
sub getDescription{
   my ($self) = @_;
   return $self->{Description};
}

# /** setDescription
#     Set the description attribute. 
# */
sub setDescription {
   my ($self, $value) = @_;
   $self->{Description} = $value;
}

# /** getFieldId
# */
sub getFieldId{
   my ($self) = @_;
   return $self->{FieldId};
}

# /** setFieldId
#     Set the fieldId attribute. 
# */
sub setFieldId {
   my ($self, $value) = @_;
   $self->{FieldId} = $value;
}

# /** getFieldIdRef
# */
sub getFieldIdRef{
   my ($self) = @_;
   return $self->{FieldIdRef};
}

# /** setFieldIdRef
#     Set the fieldIdRef attribute. 
# */
sub setFieldIdRef {
   my ($self, $value) = @_;
   $self->{FieldIdRef} = $value;
}

# /** getClass
# */
sub getClass {
   my ($self) = @_;
   return $self->{Class};
}

# /** setClass
#     Set the class attribute. 
# */
sub setClass {
   my ($self, $value) = @_;
   $self->{Class} = $value;
}

# /** getLessThanValue
# */
sub getLessThanValue {
   my ($self) = @_;
   return $self->{LessThanValue};
}

# /** setLessThanValue
#     Set the lessThanValue attribute. 
# */
sub setLessThanValue {
   my ($self, $value) = @_;
   $self->{LessThanValue} = $value;
}

# /** getLessThanOrEqualValue
# */
sub getLessThanOrEqualValue {
   my ($self) = @_;
   return $self->{LessThanOrEqualValue};
}

# /** setLessThanOrEqualValue
#     Set the lessThanOrEqualValue attribute. 
# */
sub setLessThanOrEqualValue {
   my ($self, $value) = @_;
   $self->{LessThanOrEqualValue} = $value;
}

sub getGreaterThanValue {
   my ($self) = @_;
   return $self->{GreaterThanValue};
}

# /** setGreaterThanValue
#     Set the greaterThanValue attribute. 
# */
sub setGreaterThanValue {
   my ($self, $value) = @_;
   $self->{GreaterThanValue} = $value;
}

# /** getGreaterThanOrEqualValue
# */
sub getGreaterThanOrEqualValue {
   my ($self) = @_;
   return $self->{GreaterThanOrEqualValue};
}

# /** setGreaterThanOrEqualValue
#     Set the greaterThanOrEqualValue attribute. 
# */
sub setGreaterThanOrEqualValue {
   my ($self, $value) = @_;
   $self->{GreaterThanOrEqualValue} = $value;
}

# /** getInfiniteValue
# */
sub getInfiniteValue {
   my ($self) = @_;
   return $self->{InfiniteValue};
}

# /** setInfiniteValue
#     Set the infiniteValue attribute. 
# */
sub setInfiniteValue {
   my ($self, $value) = @_;
   $self->{InfiniteValue} = $value;
}

# /** getInfiniteNegativeValue
# */
sub getInfiniteNegativeValue {
   my ($self) = @_;
   return $self->{InfiniteNegativeValue};
}

# /** setInfiniteNegativeValue
#     Set the infiniteNegativeValue attribute. 
# */
sub setInfiniteNegativeValue {
   my ($self, $value) = @_;
   $self->{InfiniteNegativeValue} = $value;
}

# /** getNoDataValue
# */
sub getNoDataValue {
   my ($self) = @_;
   return $self->{NoDataValue};
}

# /** setNoDataValue
#     Set the noDataValue attribute. 
# */
sub setNoDataValue {
   my ($self, $value) = @_;
   $self->{NoDataValue} = $value;
}

# /** getUnits
# */
sub getUnits{
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

# /** getDataFormat
# */
sub getDataFormat{
   my ($self) = @_;
   return $self->{DataFormat};
}

# /** setDataFormat
#     Set the dataFormat attribute. 
# */
sub setDataFormat {
   my ($self, $value) = @_;
   $self->{DataFormat} = $value;
}

# /** getRelation
# */
sub getRelation{
   my ($self) = @_;
   return $self->{Relation};
}

# /** setRelation
#     Set the relation attribute. 
# */
sub setRelation {
   my ($self, $value) = @_;
   $self->{Relation} = $value;
}

# /** getNoteList
# */
sub getNoteList{
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

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Other Public Methods
#

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
  push @{$self->{NoteList}}, $noteObj;

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
  $self->_remove_from_list($what, $self->{NoteList}, 'noteList');
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
   my $unitObj = $self->{Units}->addUnit($attribHashRefOrObjectRef);
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
  return $self->{Units}->removeUnit($indexOrObjectRef);
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
  $self->{NoteList} = [];
  $self->{Units} = new XDF::Units();
}

# Modification History
#
# $Log$
# Revision 1.12  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.11  2001/04/23 19:28:01  thomas
# allow XMLElements to be held within field class
#
# Revision 1.10  2001/04/17 18:52:31  thomas
# Properly calling superclass init now
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
# Revision 1.6  2001/02/22 19:37:09  thomas
# Re-insert lessthanvalue, etc in Field class
# for the time being.
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

XDF::Field - Perl Class for Field

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::Field describes a field at a given indice on a field axis. 

XDF::Field inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::BaseObjectWithXMLElements>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Field.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Field. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Field. This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item addUnit (EMPTY)

Insert an XDF::Unit object into the L<XDF::Units> object (e.g. $obj->units)held in this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::Unit asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::Unit> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Unit object. RETURNS : an XDF::Unit object if successfull, undef if not.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Field.

=over 4

=item getName{ (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription{ (EMPTY)

 

=item setDescription ($value)

Set the description attribute.  

=item getFieldId{ (EMPTY)

 

=item setFieldId ($value)

Set the fieldId attribute.  

=item getFieldIdRef{ (EMPTY)

 

=item setFieldIdRef ($value)

Set the fieldIdRef attribute.  

=item getClass (EMPTY)

 

=item setClass ($value)

Set the class attribute.  

=item getLessThanValue (EMPTY)

 

=item setLessThanValue ($value)

Set the lessThanValue attribute.  

=item getLessThanOrEqualValue (EMPTY)

 

=item setLessThanOrEqualValue ($value)

Set the lessThanOrEqualValue attribute.  

=item getGreaterThanValue (EMPTY)

 

=item setGreaterThanValue ($value)

Set the greaterThanValue attribute.  

=item getGreaterThanOrEqualValue (EMPTY)

 

=item setGreaterThanOrEqualValue ($value)

Set the greaterThanOrEqualValue attribute.  

=item getInfiniteValue (EMPTY)

 

=item setInfiniteValue ($value)

Set the infiniteValue attribute.  

=item getInfiniteNegativeValue (EMPTY)

 

=item setInfiniteNegativeValue ($value)

Set the infiniteNegativeValue attribute.  

=item getNoDataValue (EMPTY)

 

=item setNoDataValue ($value)

Set the noDataValue attribute.  

=item getUnits{ (EMPTY)

 

=item setUnits ($value)

Set the units attribute.  

=item getDataFormat{ (EMPTY)

 

=item setDataFormat ($value)

Set the dataFormat attribute.  

=item getRelation{ (EMPTY)

 

=item setRelation ($value)

Set the relation attribute.  

=item getNoteList{ (EMPTY)

 

=item setNoteList ($arrayRefValue)

Set the noteList attribute.  

=item addNote ($info)

Insert an XDF::Note object into the XDF::Notes object held by this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Note> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Note object. RETURNS : an XDF::Note object reference on success, undef on failure.  

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=item removeUnit ($indexOrObjectRef)

Remove an XDF::Unit object from the list of XDF::Units held inthe array units reference object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Field inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Field inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::Field inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElements>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>, B<toXMLFileHandle>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::FieldAxis>, L< XDF::FieldRelationship;>, L<XDF::BaseObjectWithXMLElements>, L<XDF::DataFormat>, L<XDF::Units>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

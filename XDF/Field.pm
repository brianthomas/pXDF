
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
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
# XDF::Relationship;
# */

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
my @Local_Class_XML_Attributes = qw (
                      name
                      description
                      fieldId
                      fieldIdRef
                      complexComponent
                      conversion
                      units
                      dataFormat
                      relation
                      noteList
                          );
my @Local_Class_Attributes = ();


my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

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
sub getClassAttributes {
  \@Class_Attributes;
}

#
# Get/Set Methods 
#

# /** getName
# */
sub getName{
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
# */
sub getDescription{
   my ($self) = @_;
   return $self->{description};
}

# /** setDescription
#     Set the description attribute. 
# */
sub setDescription {
   my ($self, $value) = @_;
   $self->{description} = $value;
}

# /** getFieldId
# */
sub getFieldId{
   my ($self) = @_;
   return $self->{fieldId};
}

# /** setFieldId
#     Set the fieldId attribute. 
# */
sub setFieldId {
   my ($self, $value) = @_;
   $self->{fieldId} = $value;
}

# /** getFieldIdRef
# */
sub getFieldIdRef{
   my ($self) = @_;
   return $self->{fieldIdRef};
}

# /** setFieldIdRef
#     Set the fieldIdRef attribute. 
# */
sub setFieldIdRef {
   my ($self, $value) = @_;
   $self->{fieldIdRef} = $value;
}

# * getClass
# */
#sub getClass {
#   my ($self) = @_;
#   return $self->{class};
#}

#  setClass
#     Set the class attribute. 
# */
#sub setClass {
#   my ($self, $value) = @_;
#   $self->{class} = $value;
#}

# /** getComplexComponent
# */
sub getComplexComponent {
   my ($self) = @_;
   return $self->{complexComponent};
}

# /** setComplexComponent
#     Set the complexComponent Value.
# */
sub setComplexComponent {
   my ($self, $value) = @_;
   unless (&XDF::Utility::isValidComplexComponent($value)) {
     error("Cant set field complexComponent to $value, not allowed, ignoring \n");
     return;
   }
   $self->{complexComponent} = $value;
}

# /** getConversion
#   
#  */
sub getConversion {
   my ($self) = @_;
   return $self->{conversion};
}

# /** setConversion
#     Set how to convert values of the data in this array. 
#  */
sub setConversion {
   my ($self, $value) = @_;
   $self->{conversion} = $value;
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

# /** getDataFormat
# */
sub getDataFormat{
   my ($self) = @_;
   return $self->{dataFormat};
}

# /** setDataFormat
#     Set the dataFormat attribute. 
# */
sub setDataFormat {
   my ($self, $value) = @_;

   unless (&XDF::Utility::isValidDataFormat(ref $value)) {
     error("Cant set field DataFormat to $value, not allowed, ignoring \n");
     return;
   }

   $self->{dataFormat} = $value;
}

# /** getRelation
# */
sub getRelation{
   my ($self) = @_;
   return $self->{relation};
}

# /** setRelation
#     Set the relation attribute. 
# */
sub setRelation {
   my ($self, $value) = @_;
   $self->{relation} = $value;
}

# /** getNoteList
# */
sub getNoteList{
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

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
#sub getXMLAttributes {
#  return \@Class_XML_Attributes;
#}

#
# Other Public Methods
#

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
# held within the XDF::Notes object of this object. 
# RETURNS : 1 on success, 0 on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  return $self->_remove_from_list($what, $self->{noteList}, 'noteList');
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

  # initialize lists
  $self->{noteList} = [];
  $self->{units} = new XDF::Units();

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


__END__

=head1 NAME

XDF::Field - Perl Class for Field

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::Field describes a field at a given indice on a field axis. 

XDF::Field inherits class and attribute methods of L<XDF::BaseObjectWithXMLElements>, L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Field.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Field. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

 

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

=item getComplexComponent (EMPTY)

 

=item setComplexComponent ($value)

Set the complexComponent Value.  

=item getConversion (EMPTY)

 

=item setConversion ($value)

Set how to convert values of the data in this array.  

=item getUnits (EMPTY)

 

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

=item addNote ($noteObj)

Insert an XDF::Note object into the XDF::Notes object held by this object. RETURNS : 1 on success, 0 on failure.  

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. RETURNS : 1 on success, 0 on failure.  

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



=over 4

XDF::Field inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElements>:
B<getClassXMLAttributes>, B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>.

=back



=over 4

XDF::Field inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Field inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::FieldAxis>, L< XDF::Relationship;>, L<XDF::BaseObjectWithXMLElements>, L<XDF::DataFormat>, L<XDF::Units>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

package XDF::Notes;

# /** COPYRIGHT
#    Notes.pm Copyright (C) 2000 Brian Thomas,
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


use XDF::BaseObject;
use XDF::NotesLocationOrder;
use XDF::Note;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "notes";
my @Local_Class_XML_Attributes = qw (
                             locationOrder
                             noteList
                          );
my @Local_Class_Attributes = ( );

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

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

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

# /** getLocationOrder
# */
sub getLocationOrder {
   my ($self) = @_;
   return $self->{locationOrder};
}

# /** setLocationOrder
#     Set the locationOrder attribute. 
# */
sub setLocationOrder {
   my ($self, $value) = @_;
   $self->{locationOrder} = $value;
}

# /** getLocationOrderList
# */
sub getLocationOrderList {
   my ($self) = @_;
   return $self->{locationOrder}->getLocationOrderList();
}

# /** setLocationOrderList
# */
sub setLocationOrderList {
   my ($self, $arrayRefValue) = @_;
   $self->{locationOrder}->setLocationOrderList($arrayRefValue);
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

#
# Other Public Methods
#

# /** addAxisIdToLocatorOrder
# Add an axisId (string) to the list of axes within this object.
# Returns 1 on success, 0 on failure.
# */
sub addAxisIdToLocatorOrder {
   my ($self, $axisId) = @_;
   return $self->{locationOrder}->addAxisIdToLocatorOrder($axisId);
}

#/** addNote
# Add a note object to the list of notes within this XDF::Note object.
# Returns 1 on success, 0 on failure.
# */
sub addNote {
  my ($self, $noteObj ) = @_;

  return 0 unless defined $noteObj && ref $noteObj;

  # add it to our list
  push @{$self->{noteList}}, $noteObj;

  return 1;

}

#/** removeNote
# Remove the passed Note object from the list of notes held within this Notes object.
# Returns 1 on success, 0 on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  return $self->_remove_from_list($what, $self->{noteList}, 'noteList');
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

  $self->{locationOrder} = new XDF::NotesLocationOrder();
  $self->{noteList} = [];

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


__END__

=head1 NAME

XDF::Notes - Perl Class for Notes

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::Notes inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Notes.

=over 4

=item classXMLNodeName (EMPTY)

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Notes.

=over 4

=item getLocationOrder (EMPTY)

 

=item setLocationOrder ($value)

Set the locationOrder attribute.  

=item getLocationOrderList (EMPTY)

 

=item setLocationOrderList ($arrayRefValue)

 

=item getNoteList (EMPTY)

 

=item setNoteList ($arrayRefValue)

Set the noteList attribute.  

=item addAxisIdToLocatorOrder ($axisId)

Add an axisId (string) to the list of axes within this object. Returns 1 on success, 0 on failure.  

=item addNote ($noteObj)

Add a note object to the list of notes within this XDF::Note object. Returns 1 on success, 0 on failure.  

=item removeNote ($what)

Remove the passed Note object from the list of notes held within this Notes object. Returns 1 on success, 0 on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Notes inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Notes inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::NotesLocationOrder>, L<XDF::Note>

=back

=head1 AUTHOR

 

=cut

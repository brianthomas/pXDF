
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
my @Class_XML_Attributes = qw (
                             locationOrder
                             noteList
                          );
my @Class_Attributes = ( );

# push in XML attributes to class attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

sub classAttributes { 
  \@Class_Attributes; 
}

#
# Get/Set Methods
#

# /** getLocationOrder
# */
sub getLocationOrder {
   my ($self) = @_;
   return $self->{LocationOrder};
}

# /** setLocationOrder
#     Set the locationOrder attribute. 
# */
sub setLocationOrder {
   my ($self, $value) = @_;
   $self->{LocationOrder} = $value;
}

# /** getLocationOrderList
# */
sub getLocationOrderList {
   my ($self) = @_;
   return $self->{LocationOrder}->getLocationOrderList();
}

# /** setLocationOrderList
# */
sub setLocationOrderList {
   my ($self, $value) = @_;
   $self->{LocationOrder}->setLocationOrderList($value);
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
   my ($self, $value) = @_;
   $self->{NoteList} = $value;
}

#/** getNotes
# Convience method. Returns an Array of notes held within this object. 
# */
sub getNotes {
  my ($self) = @_;
  return @{$self->{NoteList}};
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

# /** addAxisIdToLocatorOrder
# */
sub addAxisIdToLocatorOrder {
   my ($self, $axisId) = @_;
   $self->{LocationOrder}->addAxisIdToLocatorOrder($axisId);
}

sub addNote {
  my ($self, $info ) = @_;

  return unless defined $info;

  my $noteObj;

  if (ref $info && $info =~ m/XDF::Note/) {
    $noteObj = $info;
  } else {
    $noteObj = new XDF::Note($info);
  }

  # add it to our list
  push @{$self->{NoteList}}, $noteObj;

  return $noteObj;

}

sub removeNote {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->{NoteList}, 'noteList');
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

  $self->{LocationOrder} = new XDF::NotesLocationOrder();
  $self->{NoteList} = [];

}

# Modification History
#
# $Log$
# Revision 1.1  2000/12/14 22:12:15  thomas
# First version. -b.t.
#
#
#

1;


__END__

=head1 NAME

XDF::Notes - Perl Class for Notes

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::Notes inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Notes.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # push in XML attributes to class attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item sub classXMLNodeName { 

 

=item }

 

=item sub classAttributes { 

 

=item }

 

=item #

 

=item # Get/Set Methods

 

=item #

 

=item # /** getLocationOrder

 

=item # */

 

=item sub getLocationOrder {

 

=item return $self->{LocationOrder};

 

=item }

 

=item # /** setLocationOrder

 

=item #     Set the locationOrder attribute. 

 

=item # */

 

=item sub setLocationOrder {

 

=item $self->{LocationOrder} = $value;

 

=item }

 

=item # /** getLocationOrderList

 

=item # */

 

=item sub getLocationOrderList {

 

=back

=head2 OTHER Methods

=over 4

=item getLocationOrder (EMPTY)



=item setLocationOrder ($value)

Set the locationOrder attribute. 

=item getLocationOrderList (EMPTY)



=item setLocationOrderList ($value)



=item getNoteList (EMPTY)



=item setNoteList ($value)

Set the noteList attribute. 

=item getNotes (EMPTY)

Convience method. Returns an Array of notes held within this object. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item addAxisIdToLocatorOrder ($axisId)



=item addNote ($info)



=item removeNote ($what)



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

XDF::Notes inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Notes inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>, L<XDF::NotesLocationOrder>, L<XDF::Note>

=back

=head1 AUTHOR



=cut


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
   my ($self, $arrayRefValue) = @_;
   $self->{LocationOrder}->setLocationOrderList($arrayRefValue);
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
# Revision 1.3  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.2  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
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


=head1 METHODS

=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Notes.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 INSTANCE Methods

The following instance methods are defined for XDF::Notes.
=over 4

=item getLocationOrder (EMPTY)

 

=item setLocationOrder ($value)

Set the locationOrder attribute.  

=item getLocationOrderList (EMPTY)

 

=item setLocationOrderList ($arrayRefValue)

 

=item getNoteList (EMPTY)

 

=item setNoteList ($arrayRefValue)

Set the noteList attribute.  

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

=head2 INHERITED INSTANCE Methods



=over 4

XDF::Notes inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>. 

=back



=over 4

XDF::Notes inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>. 

=back

=head1 SEE ALSO

L<XDF::BaseObject>, L<XDF::NotesLocationOrder>, L<XDF::Note> 

=back

=head1 AUTHOR

 

=cut

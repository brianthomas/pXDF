
# $Id$

package XDF::Note;

# /** COPYRIGHT
#    Note.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Note describes a note within a given notes object.
# */

# /** SYNOPSIS
#  
# */


use Carp;
use XDF::BaseObject;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
# /** mark
# The STRING that describes the mark that represents this note.
# */
# /** noteId
# A scalar string holding the note id of this object. 
# */
# /** noteIdRef 
# A scalar string holding the note id reference to another XDF::Note. 
# Note that in order to get the code to use the reference object,
# the $obj->setObjRef($refObject) method should be used.
# */
# /** location
# The location of this note within a data cube.
# */
# /** value
# The STRING holding the text body of this note.
# */

my $Class_XML_Node_Name = "note";
# the order of these attributes IS important. 
my @Class_XML_Attributes = qw (
                             mark
                             noteId
                             noteIdRef
                             location
                             value
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::Note.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Note. 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
}

#
# Get/Set Methods
#

# /** getMark
# */
sub getMark {
   my ($self) = @_;
   return $self->{Mark};
}

# /** setMark
#     Set the mark attribute. 
# */
sub setMark {
   my ($self, $value) = @_;
   $self->{Mark} = $value;
}

# /** getNoteId
# */
sub getNoteId {
   my ($self) = @_;
   return $self->{NoteId};
}

# /** setNoteId
#     Set the noteId attribute. 
# */
sub setNoteId {
   my ($self, $value) = @_;
   $self->{NoteId} = $value;
}

# /** getNoteIdRef
# */
sub getNoteIdRef {
   my ($self) = @_;
   return $self->{NoteIdRef};
}

# /** setNoteIdRef
#     Set the noteIdRef attribute. 
# */
sub setNoteIdRef {
   my ($self, $value) = @_;
   $self->{NoteIdRef} = $value;
}

# /** getLocation
# */
sub getLocation {
   my ($self) = @_;
   return $self->{Location};
}

# /** setLocation
# Set the datacell that this note applies to within
# an array. Right now this is a space delimited string, HOWEVER,
# we need to shift this over to accepting a location object. -b.t. 
# */
sub setLocation {
   my ($self, $value) = @_;
   $self->{Location} = $value;
}

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{Value};
}

# /** setValue
#     Set the value attribute. 
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{Value} = $value;
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

# /** setXMLAttributes 
# XDF::Note has a special setXMLAttributes method. 
# These objects are so simple they seem to merit 
# special handling. This new setXMLAttributes method takes either
# and attribute Hash reference or a STRING.
# If the input value is a HASH reference, we 
# construct an object from it, else, we 
# just set its value attribute to the contents of 
# the passed STRING. 
sub setXMLAttributes {
  my ($self, $attribHashRefOrString) = @_;

  if (defined $attribHashRefOrString) {
    if (ref($attribHashRefOrString)) {
      $self->SUPER::setXMLAttributes($attribHashRefOrString);
    } else {
      $self->setValue($attribHashRefOrString);
    }
  }

}

sub addText {
  my ($self, $text) = @_;
  return unless defined $text;
  my $oldval = $self->getValue();
  $text = $oldval . $text if defined $oldval; 
  $self->setValue($text);
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

# Modification History
#
# $Log$
# Revision 1.8  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.7  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2000/12/18 16:35:54  thomas
# Fixed Minor problem with getValue/addNote
# in class. -b.t.
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
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::Note - Perl Class for Note

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::Note describes a note within a given notes object. 

XDF::Note inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Note.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Note. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Note. This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Note.

=over 4

=item getMark (EMPTY)

 

=item setMark ($value)

Set the mark attribute.  

=item getNoteId (EMPTY)

 

=item setNoteId ($value)

Set the noteId attribute.  

=item getNoteIdRef (EMPTY)

 

=item setNoteIdRef ($value)

Set the noteIdRef attribute.  

=item getLocation (EMPTY)

 

=item setLocation ($value)

Set the datacell that this note applies to withinan array. Right now this is a space delimited string, HOWEVER,we need to shift this over to accepting a location object. -b.t.  

=item getValue (EMPTY)

 

=item setValue ($value)

Set the value attribute.  

=item setXMLAttributes ($attribHashRefOrString)

XDF::Note has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. Private MethodsThis is called when we cant find any defined methodexists already. Used to handle general purpose set/getmethods for our attributes (object fields). Modification History$Log$
XDF::Note has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. Private MethodsThis is called when we cant find any defined methodexists already. Used to handle general purpose set/getmethods for our attributes (object fields). Modification HistoryRevision 1.8  2001/03/16 19:54:57  thomas
XDF::Note has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. Private MethodsThis is called when we cant find any defined methodexists already. Used to handle general purpose set/getmethods for our attributes (object fields). Modification HistoryDocumentation updated and improved, re-ran makeDoc on file.
XDF::Note has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. Private MethodsThis is called when we cant find any defined methodexists already. Used to handle general purpose set/getmethods for our attributes (object fields). Modification HistoryRevision 1.7  2001/03/14 21:32:34  thomasUpdated perldoc section using new version ofmakeDoc.pl. Revision 1.6  2000/12/18 16:35:54  thomasFixed Minor problem with getValue/addNotein class. -b.t. Revision 1.5  2000/12/15 22:11:59  thomasRegenerated perlDoc section in files. -b.t. Revision 1.4  2000/12/14 22:11:25  thomasBig changes to the API. get/set methods, added Href/Entity stuff, deep cloning,added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_arrayfrom DataCube (not needed) and fixed problems outputing delimited/formattedread nodes. -b.t. Revision 1.3  2000/12/01 20:03:38  thomasBrought Pod docmentation up to date. Bumped up versionnumber. -b.t. Revision 1.2  2000/10/16 17:37:21  thomasChanged over to BaseObject Class from Object Class. Added in History Modification section.  

=item addText ($text)

 

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

XDF::Note inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Note inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

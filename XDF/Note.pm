
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# An XDF::Note describes a note within a given notes object.
# */

# /** SYNOPSIS
#  
# */


use XDF::BaseObject;
#use XDF::Log;

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
my @Local_Class_XML_Attributes = qw (
                             mark
                             noteId
                             noteIdRef
                             location
                             value
                          );
my @Local_Class_Attributes = ();

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

# /** classXMLNodeName
# This method returns the class node name of XDF::Note.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
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

# /** getMark
# */
sub getMark {
   my ($self) = @_;
   return $self->{mark};
}

# /** setMark
#     Set the mark attribute. 
# */
sub setMark {
   my ($self, $value) = @_;
   $self->{mark} = $value;
}

# /** getNoteId
# */
sub getNoteId {
   my ($self) = @_;
   return $self->{noteId};
}

# /** setNoteId
#     Set the noteId attribute. 
# */
sub setNoteId {
   my ($self, $value) = @_;
   $self->{noteId} = $value;
}

# /** getNoteIdRef
# */
sub getNoteIdRef {
   my ($self) = @_;
   return $self->{noteIdRef};
}

# /** setNoteIdRef
#     Set the noteIdRef attribute. 
# */
sub setNoteIdRef {
   my ($self, $value) = @_;
   $self->{noteIdRef} = $value;
}

# /** getLocation
# */
sub getLocation {
   my ($self) = @_;
   return $self->{location};
}

# /** setLocation
# Set the datacell that this note applies to within
# an array. Right now this is a space delimited string, HOWEVER,
# we need to shift this over to accepting a location object. -b.t. 
# */
sub setLocation {
   my ($self, $value) = @_;
   $self->{location} = $value;
}

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{value};
}

# /** setValue
#     Set the value attribute. 
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{value} = $value;
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

#/** addText
# Append text into this XDF::Note object.
# Returns 1 on success, 0 on failure.
# */
sub addText {
  my ($self, $text) = @_;

  return 0 unless defined $text && !ref $text;

   my $oldval = $self->getValue();
   $text = $oldval . $text if defined $oldval; 
   $self->setValue($text);
   return 1;

}
 
#
# Private Methods
# 

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

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

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

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

XDF::Note has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING.  

=item addText ($text)

Append text into this XDF::Note object. Returns 1 on success, 0 on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Note inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Note inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

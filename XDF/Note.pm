
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
# the order of these attributes IS important. In order for the ID/IDREF
# stuff to work, _objRef MUST be the last attribute
my @Class_Attributes = qw (
                             mark
                             noteId
                             noteIdRef
                             location
                             value
                          );

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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# /** update
# XDF::Note has a special update method. 
# These objects are so simple they seem to merit 
# special handling. This new update method takes either
# and attribute Hash reference or a STRING.
# If the input value is a HASH reference, we 
# construct an object from it, else, we 
# just set its value attribute to the contents of 
# the passed STRING. 
sub update {
  my ($self, $attribHashRefOrString) = @_;

  if (defined $attribHashRefOrString) {
    if (ref($attribHashRefOrString) ) {
      $self->SUPER::update($attribHashRefOrString);
    } else {
      $self->value($attribHashRefOrString);
    }
  }

}

sub addText {
  my ($self, $text) = @_;
  return unless defined $text;
  my $oldval = $self->value();
  $text = $oldval . $text if defined $oldval; 
  $self->value($text);
}
 
# /** setLocation
# Indicate the datacell that this note applies to within
# an array.
# */
sub setLocation {
  my ($self, $locator) = @_;


}

# Modification History
#
# $Log$
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

XDF::Note inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Note.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Note. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Note. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item mark

The STRING that describes the mark that represents this note.  

=item noteId

A scalar string holding the note id of this object.  

=item noteIdRef

A scalar string holding the note id reference to another XDF::Note. Note that in order to get the code to use the reference object,the $obj->setObjRef($refObject) method should be used.  

=item location

The location of this note within a data cube.  

=item value

The STRING holding the text body of this note.  

=back

=head2 OTHER Methods

=over 4

=item update ($attribHashRefOrString)

XDF::Note has a special update method. These objects are so simple they seem to merit special handling. This new update method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. 

=item addText ($text)



=item setLocation ($locator)

Indicate the datacell that this note applies to withinan array. 

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

XDF::Note inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::Note inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

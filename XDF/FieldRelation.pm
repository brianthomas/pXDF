
# $Id$

# /** COPYRIGHT
#    FieldRelation.pm Copyright (C) 2000 Brian Thomas,
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

# /** Description
# Denotes a relationship between one XDF::Field object (the parent of
# the XDF::FieldRelation object) and one or more other XDF::Field objects.
# */ 

package XDF::FieldRelation;

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "relation";
my @Class_XML_Attributes = qw (
                             fieldIdRefs
                             role
                          );
my @Class_Attributes = ();

# add in class XML attributes
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

# /** getFieldIdRefs 
# */
sub getFieldIdRefs {
   my ($self) = @_;
   return $self->{FieldIdRefs};
}

# /** setFieldIdRefs 
#     Set the fieldIdRefs attribute. 
# */
sub setFieldIdRefs {
   my ($self, $value) = @_;
   $self->{FieldIdRefs} = $value;
}

# /** getRole 
# */
sub getRole {
   my ($self) = @_;
   return $self->{Role};
}

# /** setRole 
#     Set the role attribute. 
# */
sub setRole {
   my ($self, $value) = @_;
   $self->{Role} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

# /** getRelatedFieldIdRefs
# Convience method which returns an array of related fieldIdRefs.    
# */
sub getRelatedFieldIdRefs {
  my ($self) = @_;
  return split / /, $self->{FieldIdRefs};
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
# Revision 1.5  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
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

XDF::FieldRelation - Perl Class for FieldRelation

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::FieldRelation inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FieldRelation.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # add in class XML attributes

 

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

 

=item # /** getFieldIdRefs 

 

=item # */

 

=item sub getFieldIdRefs {

 

=item return $self->{FieldIdRefs};

 

=item }

 

=item # /** setFieldIdRefs 

 

=item #     Set the fieldIdRefs attribute. 

 

=item # */

 

=item sub setFieldIdRefs {

 

=item $self->{FieldIdRefs} = $value;

 

=item }

 

=item # /** getRole 

 

=item # */

 

=item sub getRole {

 

=item return $self->{Role};

 

=item }

 

=item # /** setRole 

 

=item #     Set the role attribute. 

 

=item # */

 

=item sub setRole {

 

=item $self->{Role} = $value;

 

=item }

 

=item # /** getXMLAttributes

 

=item #      This method returns the XMLAttributes of this class. 

 

=item #  */

 

=item sub getXMLAttributes {

 

=item }

 

=item # /** getRelatedFieldIdRefs

 

=item # Convience method which returns an array of related fieldIdRefs.    

 

=item # */

 

=item sub getRelatedFieldIdRefs {

 

=item return split / /, $self->{FieldIdRefs};

 

=item }

 

=item #

 

=item # Private Methods 

 

=item #

 

=item # This is called when we cant find any defined method

 

=item # exists already. Used to handle general purpose set/get

 

=item # methods for our attributes (object fields).

 

=item sub AUTOLOAD {

 

=item my ($self,$val) = @_;

 

=back

=head2 OTHER Methods

=over 4

=item getFieldIdRefs (EMPTY)



=item setFieldIdRefs ($value)

Set the fieldIdRefs attribute. 

=item getRole (EMPTY)



=item setRole ($value)

Set the role attribute. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item getRelatedFieldIdRefs (EMPTY)

Convience method which returns an array of related fieldIdRefs.    

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

XDF::FieldRelation inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FieldRelation inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>

=back

=head1 AUTHOR



=cut

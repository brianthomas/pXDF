
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
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
}

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

# /** getFieldIdRefs 
# */
sub getFieldIdRefs {
   my ($self) = @_;
   return $self->{fieldIdRefs};
}

# /** setFieldIdRefs 
#     Set the fieldIdRefs attribute. 
# */
sub setFieldIdRefs {
   my ($self, $value) = @_;
   $self->{fieldIdRefs} = $value;
}

# /** getRole 
# */
sub getRole {
   my ($self) = @_;
   return $self->{role};
}

# /** setRole 
#     Set the role attribute. 
# */
sub setRole {
   my ($self, $value) = @_;

   carp "Cant set role to $value, not allowed \n"
      unless (&XDF::Utility::isValidRelationRole($value));

   $self->{role} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
#sub getXMLAttributes {
#  return \@Class_XML_Attributes;
#}

# /** getRelatedFieldIdRefs
# Convience method which returns an array of related fieldIdRefs.    
# */
sub getRelatedFieldIdRefs {
  my ($self) = @_;
  return split / /, $self->{fieldIdRefs};
}

#
# Private Methods 
#

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Class_XML_Attributes);

}

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
# Revision 1.10  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.9  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.8  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.7  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2001/03/09 21:52:41  thomas
# Added Utility check on role attribute.
#
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


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::FieldRelation.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::FieldRelation.

=over 4

=item getFieldIdRefs (EMPTY)

 

=item setFieldIdRefs ($value)

Set the fieldIdRefs attribute.  

=item getRole (EMPTY)

 

=item setRole ($value)

Set the role attribute.  

=item getRelatedFieldIdRefs (EMPTY)

Convience method which returns an array of related fieldIdRefs.     

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::FieldRelation inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FieldRelation inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>

=back

=head1 AUTHOR

 

=cut

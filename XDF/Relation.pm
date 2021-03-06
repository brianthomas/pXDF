
# $Id$

# /** COPYRIGHT
#    Relation.pm Copyright (C) 2000 Brian Thomas,
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
# Denotes a relationship between one XDF::Field (or XDF::Array) object (the parent of
# the XDF::Relation object) and one or more other XDF::Field (or XDF::Array) objects.
# */ 

package XDF::Relation;

use XDF::BaseObject;
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "relation";
my @Local_Class_XML_Attributes = qw (
                             description
                             idRefs
                             role
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

# /** getDescription
# */
sub getDescription {
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


# /** getIdRefs 
# */
sub getIdRefs {
   my ($self) = @_;
   return $self->{idRefs};
}

# /** setIdRefs 
#     Set the idRefs attribute. 
# */
sub setIdRefs {
   my ($self, $value) = @_;
   $self->{idRefs} = $value;
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

   error("Cant set role to $value, not allowed \n")
      unless (&XDF::Utility::isValidRelationRole($value));

   $self->{role} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
#sub getXMLAttributes {
#  return \@Class_XML_Attributes;
#}

# /** getRelatedIdRefs
# Convience method which returns an array of related IdRefs.    
# */
sub getRelatedIdRefs {
  my ($self) = @_;
  return split / /, $self->{idRefs};
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

XDF::Relation - Perl Class for Relation

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::Relation inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Relation.

=over 4

=item classXMLNodeName (EMPTY)

 

=item getClassAttributes (EMPTY)

 

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Relation.

=over 4

=item getDescription (EMPTY)

 

=item setDescription ($value)

Set the description attribute.  

=item getIdRefs (EMPTY)

 

=item setIdRefs ($value)

Set the idRefs attribute.  

=item getRole (EMPTY)

 

=item setRole ($value)

Set the role attribute.  

=item getRelatedIdRefs (EMPTY)

Convience method which returns an array of related IdRefs.     

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Relation inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Relation inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::Log>

=back

=head1 AUTHOR

 

=cut

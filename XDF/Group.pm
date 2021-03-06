
# $Id$

package XDF::Group;

# /** COPYRIGHT
#    Group.pm Copyright (C) 2000 Brian Thomas,
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
# An abstract class for objects which store information about how other objects
# are grouped relative to one another. XDF::Group should never be instanciated.
# */

# /** SYNOPSIS
#
# */

# /** SEE ALSO
# XDF::FieldGroup
# XDF::ParameterGroup
# XDF::ValueGroup
# */

use XDF::BaseObject;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
# /** name
# The STRING description (short name) of this object. 
# */
# /** description
# A scalar string description (long name) of this object. 
# */
my @Local_Class_XML_Attributes = qw (
                             name
                             description
                          );
my @Local_Class_Attributes = qw (
                             _memberObjHash
                          );

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
# Set/Get Methods 
#

# /** getName
# */
sub getName {
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
#  */
sub getDescription {
   my ($self) = @_;
   return $self->{description};
}

# /** setDescription
#  */
sub setDescription {
   my ($self, $value) = @_;
   $self->{description} = $value;
}

#
# Other Public Methods 
#

# /** addMemberObject
# Add an object to this group. 
# Returns: 1 on success, 0 on failure.
# */
sub addMemberObject {
  my ($self, $obj) = @_;

   return 0 unless defined $obj && ref $obj;

   #unless ( exists %{$self->{_memberObjHash}}->{$obj} ) {
   unless ( exists $self->{_memberObjHash}->{$obj} ) {
     #%{$self->{_memberObjHash}}->{$obj} = $obj;
     $self->{_memberObjHash}->{$obj} = $obj;
     return 1;
   }

   return 0;
}

# /** removeMemberObject
# Remove an object from membership in this group. 
# Returns: 1 on success, 0 on failure.
# */
sub removeMemberObject {
  my ($self, $obj) = @_;

  return 0 unless defined $obj && ref $obj;

#  if ( exists %{$self->{_memberObjHash}}->{$obj} ) {
  if ( exists $self->{_memberObjHash}->{$obj} ) {
    #delete %{$self->{_memberObjHash}}->{$obj};
    delete $self->{_memberObjHash}->{$obj};
    return 1;
  }
  return 0;
}

# /** hasMemberObj
# Check if an object belongs to this group. Returns
# 1 if true, undef if false.
# */
sub hasMemberObj {
  my ($self, $obj) = @_;
  return unless defined $obj && ref $obj;
  #return exists %{$self->{_memberObjHash}}->{$obj} ? 1 : undef;
  return exists $self->{_memberObjHash}->{$obj} ? 1 : undef;
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

   $self->{_memberObjHash} = {}; 
  
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


__END__

=head1 NAME

XDF::Group - Perl Class for Group

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 An abstract class for objects which store information about how other objects are grouped relative to one another. XDF::Group should never be instanciated. 

XDF::Group inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Group.

=over 4

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Group.

=over 4

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription (EMPTY)

 

=item setDescription ($value)

 

=item addMemberObject ($obj)

Add an object to this group. Returns: 1 on success, 0 on failure.  

=item removeMemberObject ($obj)

Remove an object from membership in this group. Returns: 1 on success, 0 on failure.  

=item hasMemberObj ($obj)

Check if an object belongs to this group. Returns1 if true, undef if false.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Group inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Group inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::FieldGroup>, L< XDF::ParameterGroup>, L< XDF::ValueGroup>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

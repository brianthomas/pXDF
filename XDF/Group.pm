
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
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
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

use Carp;
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
my @Class_XML_Attributes = qw (
                             name
                             description
                          );
my @Class_Attributes = qw (
                             _memberObjHash
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Group. 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  \@Class_Attributes;
}

#
# Set/Get Methods 
#

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $self->{Name};
}

# /** setName
#     Set the name attribute. 
# */
sub setName {
   my ($self, $value) = @_;
   $self->{Name} = $value;
}

# /** getDescription
#  */
sub getDescription {
   my ($self) = @_;
   return $self->{Description};
}

# /** setDescription
#  */
sub setDescription {
   my ($self, $value) = @_;
   $self->{Description} = $value;
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

# /** addMemberObject
# Add an object to this group. 
# */
sub addMemberObject {
  my ($self, $obj) = @_;

  return unless defined $obj && ref $obj;

  unless ( exists %{$self->{_memberObjHash}}->{$obj} ) {
    %{$self->{_memberObjHash}}->{$obj} = $obj;
    return $obj;
  }

}

# /** removeMemberObject
# Remove an object from membership in this group. 
# */
sub removeMemberObject {
  my ($self, $obj) = @_;

  return unless defined $obj && ref $obj;

  if ( exists %{$self->{_memberObjHash}}->{$obj} ) {
    delete %{$self->{_memberObjHash}}->{$obj};
    return $obj;
  }
}

# /** hasMemberObj
# Check if an object belongs to this group. Returns
# 1 if true, undef if false.
# */
sub hasMemberObj {
  my ($self, $obj) = @_;
  return unless defined $obj && ref $obj;
  return exists %{$self->{_memberObjHash}}->{$obj} ? 1 : undef;
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
}

# Modification History
#
# $Log$
# Revision 1.9  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.8  2001/04/17 18:52:09  thomas
# Properly calling superclass init now
#
# Revision 1.7  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.6  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.5  2000/12/15 22:11:58  thomas
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
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

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

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Group. This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

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

Add an object to this group.  

=item removeMemberObject ($obj)

Remove an object from membership in this group.  

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
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::FieldGroup>, L< XDF::ParameterGroup>, L< XDF::ValueGroup>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

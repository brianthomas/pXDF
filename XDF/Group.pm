
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
use XDF::Object;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
# /** name
# The STRING description (short name) of this object. 
# */
# /** description
# A scalar string description (long name) of this object. 
# */
my @Class_Attributes = qw (
                             name
                             description
                             _memberObjHash
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init { my ($self) = @_; $self->_memberObjHash({}); }

# /** addMemberObject
# Add an object to this group. 
# */
sub addMemberObject {
  my ($self, $obj) = @_;

  return unless defined $obj && ref $obj;

  unless ( exists %{$self->_memberObjHash}->{$obj} ) {
    %{$self->_memberObjHash}->{$obj} = $obj;
    return $obj;
  }

}

# /** removeMemberObject
# Remove an object from membership in this group. 
# */
sub removeMemberObject {
  my ($self, $obj) = @_;

  return unless defined $obj && ref $obj;

  if ( exists %{$self->_memberObjHash}->{$obj} ) {
    delete %{$self->_memberObjHash}->{$obj};
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
  return exists %{$self->_memberObjHash}->{$obj} ? 1 : undef;
}

1;


__END__

=head1 NAME

XDF::Group - Perl Class for Group

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 An abstract class for objects which store information about how other objects are grouped relative to one another. XDF::Group should never be instanciated. 

XDF::Group inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Group.

=over 4

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Group. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

The STRING description (short name) of this object.  

=item description

A scalar string description (long name) of this object.  

=back

=head2 OTHER Methods

=over 4

=item addMemberObject ($obj)

Add an object to this group. 

=item removeMemberObject ($obj)

Remove an object from membership in this group. 

=item hasMemberObj ($obj)

Check if an object belongs to this group. Returns1 if true, undef if false. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::Object>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::Group inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::Group inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::FieldGroup>, L< XDF::ParameterGroup>, L< XDF::ValueGroup>, L<XDF::Object>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

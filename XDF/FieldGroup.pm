
# $Id$

package XDF::FieldGroup;

# /** COPYRIGHT
#    FieldGroup.pm Copyright (C) 2000 Brian Thomas,
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
# An object to store information about how field objects
# are grouped relative to one another. Field Group may hold
# both XDF::Field and XDF::FieldGroups as members. 
# */

# /** SYNOPSIS
#
# */

# /** SEE ALSO
# XDF::Field
# XDF::ParameterGroup
# XDF::ValueGroup
# */

use Carp;
use XDF::Group;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject and XDF::GroupObject
@ISA = ("XDF::Group");

# CLASS DATA
my $Class_Node_Name = "fieldGroup";
my @Class_Attributes = qw ( 
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Group::classAttributes};

# /** classXMLNodeName
# This method returns the class node name for XDF::FieldGroup; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {

  $Class_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes for XDF::FieldGroup; 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {

  \@Class_Attributes;
}

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# /** addFieldGroup 
# Convenience method.
# Insert a field group object into this object.
# */ 
sub addFieldGroup {
  my ($self, $info) = @_;

  return unless defined $info && ref $info;

  my $groupObj;
  if ($info =~ m/XDF::FieldGroup/) {
    $groupObj = $info;
  } else {
    $groupObj = new XDF::FieldGroup($info);
  }

  $self->addMemberObject($groupObj);
}

# /** removeFieldGroup 
# Convenience method.
# Removes a field group object from this object.
# */
sub removeFieldGroup { 
  my ($self, $obj) = @_; 
  $self->removeMemberObject($obj); 
}


# Modification History
#
# $Log$
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

XDF::FieldGroup - Perl Class for FieldGroup

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 An object to store information about how field objects are grouped relative to one another. Field Group may hold both XDF::Field and XDF::FieldGroups as members. 

XDF::FieldGroup inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::Group>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FieldGroup.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldGroup; This method takes no arguments may not be changed.  

=back

=head2 OTHER Methods

=over 4

=item addFieldGroup ($info)

Convenience method. Insert a field group object into this object. 

=item removeFieldGroup ($obj)

Convenience method. Removes a field group object from this object. 

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

XDF::FieldGroup inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::FieldGroup inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::FieldGroup inherits the following instance methods of L<XDF::Group>:
B<addMemberObject>, B<removeMemberObject>, B<hasMemberObj>.

=back

=back

=head1 SEE ALSO

L< XDF::Field>, L< XDF::ParameterGroup>, L< XDF::ValueGroup>, L<XDF::Group>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

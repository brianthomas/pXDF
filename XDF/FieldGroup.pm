
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

use XDF::Group;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject and XDF::GroupObject
@ISA = ("XDF::Group");

# CLASS DATA
my $Class_Node_Name = "fieldGroup";
my @Local_Class_XML_Attributes = ();
my @Local_Class_Attributes = qw ( );
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::Group::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::Group::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;


# /** classXMLNodeName
# This method returns the class node name for XDF::FieldGroup; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for XDF::FieldGroup; 
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}


# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

#
# Get/Set Methods
#

#
# Other Public Methods
#

# /** addFieldGroup 
# Convenience method.
# Insert a field group object into this object.
# RETURNS: 1 on success, 0 on failure.
# */ 
sub addFieldGroup {
  my ($self, $fieldGroupObj) = @_;
  return $self->addMemberObject($fieldGroupObj);
}

# /** removeFieldGroup 
# Convenience method.
# Removes a field group object from this object.
# RETURNS: 1 on success, 0 on failure.
# */
sub removeFieldGroup { 
  my ($self, $obj) = @_; 
  return $self->removeMemberObject($obj); 
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

XDF::FieldGroup - Perl Class for FieldGroup

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 An object to store information about how field objects are grouped relative to one another. Field Group may hold both XDF::Field and XDF::FieldGroups as members. 

XDF::FieldGroup inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::Group>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::FieldGroup.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::FieldGroup.

=over 4

=item addFieldGroup ($fieldGroupObj)

Convenience method. Insert a field group object into this object. RETURNS: 1 on success, 0 on failure.  

=item removeFieldGroup ($obj)

Convenience method. Removes a field group object from this object. RETURNS: 1 on success, 0 on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::FieldGroup inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FieldGroup inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::FieldGroup inherits the following instance (object) methods of L<XDF::Group>:
B<getName>, B<setName>, B<getDescription>, B<setDescription>, B<addMemberObject>, B<removeMemberObject>, B<hasMemberObj>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Field>, L< XDF::ParameterGroup>, L< XDF::ValueGroup>, L<XDF::Group>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

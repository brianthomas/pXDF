
# $Id$

package XDF::ValueGroup;

# /** COPYRIGHT
#    ValueGroup.pm Copyright (C) 2000 Brian Thomas,
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
# An object to store information about how value objects
# are grouped relative to one another. Value Group may hold
# both XDF::Value (and objects derived from XDF::Value, like XDF::ErroredValue)
# and XDF::ValueGroup objects as members. 
# */

# /** SYNOPSIS
#
# */

# /** SEE ALSO
# XDF::ErroredValue
# XDF::FieldGroup
# XDF::ParameterGroup
# XDF::Value
# */


use Carp;
use XDF::Group;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object and XDF::GroupObject
@ISA = ("XDF::Group");

# CLASS DATA
my $Class_XML_Node_Name = "valueGroup";
my @Class_Attributes = qw ( 
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Group::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name for XDF::FieldGroup; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {

  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes for XDF::FieldGroup; 
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

# /** addValueGroup 
# Convenience method.
# Insert a valueGroup object into this object 
# */ 
sub addValueGroup {
  my ($self, $info) = @_;

  return unless defined $info && ref $info;

  my $groupObj;
  if ($info =~ m/XDF::ValueGroup/) {
    $groupObj = $info;
  } else {
    $groupObj = new XDF::ValueGroup($info);
  }

  $self->addMemberObject($groupObj);
}

# /** removeValueGroup 
# Convenience method.
# Remove a fieldGroup object from this object 
# */
sub removeValueGroup { 
  my ($self, $obj) = @_; 
  $self->removeMemberObject($obj); 
}

1;


__END__

=head1 NAME

XDF::ValueGroup - Perl Class for ValueGroup

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 An object to store information about how value objects are grouped relative to one another. Value Group may hold both XDF::Value (and objects derived from XDF::Value, like XDF::ErroredValue) and XDF::ValueGroup objects as members. 

XDF::ValueGroup inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Group>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::ValueGroup.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldGroup; This method takes no arguments may not be changed.  

=back

=head2 OTHER Methods

=over 4

=item addValueGroup ($info)

Convenience method. Insert a valueGroup object into this object 

=item removeValueGroup ($obj)

Convenience method. Remove a fieldGroup object from this object 

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

XDF::ValueGroup inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::ValueGroup inherits the following instance methods of L<XDF::Group>:
B<addMemberObject>, B<removeMemberObject>, B<hasMemberObj>.

=back



=over 4

XDF::ValueGroup inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::ErroredValue>, L< XDF::FieldGroup>, L< XDF::ParameterGroup>, L< XDF::Value>, L<XDF::Group>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

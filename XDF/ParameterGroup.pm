
# $Id$

package XDF::ParameterGroup;

# /** COPYRIGHT
#    ParameterGroup.pm Copyright (C) 2000 Brian Thomas,
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
# An object to store information about how parameter objects
# are grouped relative to one another. Parameter group 
# objects may hold both XDF::Parameter and XDF::ParameterGroup objects as members. 
# */

# /** SYNOPSIS
#
# */

# /** SEE ALSO
# XDF::FieldGroup 
# XDF::Parameter
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
my $Class_XML_Node_Name = "parameterGroup";
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

# /** 
# Convenience method.
# Insert a parameterGroup object into this object 
# */ 
sub addParamGroup {
  my ($self, $info) = @_;

  return unless defined $info && ref $info;

  my $groupObj;
  if ($info =~ m/XDF::ParameterGroup/) {
    $groupObj = $info;
  } else {
    $groupObj = new XDF::ParameterGroup($info);
  }

  $self->addMemberObject($groupObj);
}

# /** 
# Convenience method.
# Remove a parameterGroup object from this object 
# */
sub removeParamGroup { my ($self, $obj) = @_; $self->removeMemberObject($obj); }

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

XDF::ParameterGroup - Perl Class for ParameterGroup

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 An object to store information about how parameter objects are grouped relative to one another. Parameter group  objects may hold both XDF::Parameter and XDF::ParameterGroup objects as members. 

XDF::ParameterGroup inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>, L<XDF::Group>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::ParameterGroup.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldGroup; This method takes no arguments may not be changed.  

=back

=head2 OTHER Methods

=over 4

=item addParamGroup ($info)



=item removeParamGroup (EMPTY)



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

XDF::ParameterGroup inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::ParameterGroup inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::ParameterGroup inherits the following instance methods of L<XDF::Group>:
B<addMemberObject>, B<removeMemberObject>, B<hasMemberObj>.

=back

=back

=head1 SEE ALSO

L< XDF::FieldGroup >, L< XDF::Parameter>, L< XDF::ValueGroup>, L<XDF::Group>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

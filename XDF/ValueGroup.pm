
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

# inherits from XDF::BaseObject and XDF::GroupObject
@ISA = ("XDF::Group");

# CLASS DATA
my $Class_XML_Node_Name = "valueGroup";
my @Class_XML_Attributes = (); 
my @Class_Attributes = ();

# add in super class attributes
push @Class_Attributes, @{&XDF::Group::classAttributes};
push @Class_Attributes, @{&XDF::Group::getXMLAttributes};

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

#
# Set/Get Methods
#

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes; 
}   
  
#   
# Other Public Methods 
# 

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
# Revision 1.8  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.7  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.6  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.5  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:27  thomas
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

XDF::ValueGroup - Perl Class for ValueGroup

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 An object to store information about how value objects are grouped relative to one another. Value Group may hold both XDF::Value (and objects derived from XDF::Value, like XDF::ErroredValue) and XDF::ValueGroup objects as members. 

XDF::ValueGroup inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::Group>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::ValueGroup.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::ValueGroup.

=over 4

=item addValueGroup ($info)

Convenience method. Insert a valueGroup object into this object  

=item removeValueGroup ($obj)

Convenience method. Remove a fieldGroup object from this object  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::ValueGroup inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::ValueGroup inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::ValueGroup inherits the following instance (object) methods of L<XDF::Group>:
B<getName>, B<setName>, B<getDescription>, B<setDescription>, B<addMemberObject>, B<removeMemberObject>, B<hasMemberObj>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::ErroredValue>, L< XDF::FieldGroup>, L< XDF::ParameterGroup>, L< XDF::Value>, L<XDF::Group>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

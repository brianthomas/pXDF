
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
my @Class_XML_Attributes = qw ( 
                          );
my @Class_Attributes = qw ( 
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::Group::getClassAttributes};
push @Class_Attributes, @{&XDF::Group::getClassXMLAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name for XDF::FieldGroup; 
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  return $Class_XML_Node_Name;
}

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
# SET/GET MEthods 
#

#
# Other Public Methods
#

# /** 
# Convenience method.
# Insert a parameterGroup object into this object 
# Returns 1 on success, 0 on failure.
# */ 
sub addParamGroup {
  my ($self, $paramGroupObj) = @_;
  return $self->addMemberObject($paramGroupObj);
}

# /** 
# Convenience method.
# Remove a parameterGroup object from this object 
# Returns 1 on success, 0 on failure.
# */
sub removeParamGroup { 
   my ($self, $paramGroupObj) = @_; 
   return $self->removeMemberObject($paramGroupObj); 
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
# Revision 1.9  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.8  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.7  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.6  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
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

XDF::ParameterGroup inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::Group>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::ParameterGroup.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for XDF::FieldGroup; This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item removeParamGroup (EMPTY)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::ParameterGroup.

=over 4

=item addParamGroup ($info)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::ParameterGroup inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::ParameterGroup inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::ParameterGroup inherits the following instance (object) methods of L<XDF::Group>:
B<getName>, B<setName>, B<getDescription>, B<setDescription>, B<addMemberObject>, B<removeMemberObject>, B<hasMemberObj>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::FieldGroup >, L< XDF::Parameter>, L< XDF::ValueGroup>, L<XDF::Group>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

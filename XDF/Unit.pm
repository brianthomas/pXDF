
# $Id$

package XDF::Unit;

# /** COPYRIGHT
#    Unit.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Unit describes a unit within a given units object.
# */

# /** SYNOPSIS
#  
# */


use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "unit";
my @Class_XML_Attributes = qw (
                             power
                             value
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# /** power
# The power of this unit. Takes a SCALAR number value.
# */ 
# /** value
# The value of this unit (e.g. "m" or "cm" or "km", etc)
# */

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method returns the class node name of XDF::Unit.
# This method takes no arguments may not be changed. 
# */
sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Unit. 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {

  \@Class_Attributes;
}

#
# Get/Set Methods
#

# /** getPower
# */
sub getPower {
   my ($self) = @_;
   return $self->{Power};
}

# /** setPower
#     Set the power attribute. 
# */
sub setPower {
   my ($self, $value) = @_;
   $self->{Power} = $value;
}

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{Value};
}

# /** setValue
#     Set the value attribute. 
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{Value} = $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes { 
  return \@Class_XML_Attributes;
}

#
# other Public methods
#

# Override XDF::BaseObject::setXMLAttributes. Special new method for Value objects.
# /** setXMLAttributes
# XDF::Unit has a special setXMLAttributes method. 
# These objects are so simple they seem to merit 
# special handling. This new setXMLAttributes method takes either
# and attribute Hash reference or a STRING.
# If the input value is a HASH reference, we 
# construct an object from it, else, we 
# just set its value attribute to the contents of 
# the passed STRING. 
# */
sub setXMLAttributes {
  my ($self, $info ) = @_;

  # these objects are so simple they seem to merit 
  # special handling. If $info is a reference, we assume
  # it is an attribute hash (as per other objects). Else,
  # we assume its a string, and the value of the note.
  if (defined $info) {
    if (ref($info) ) {
      $self->SUPER::setXMLAttributes($info);
    } else {
      $self->setValue($info);
    }
  }

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

XDF::Unit - Perl Class for Unit

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::Unit describes a unit within a given units object. 

XDF::Unit inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Unit.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Unit. This method takes no arguments may not be changed.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Unit. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # /** power

 

=item # The power of this unit. Takes a SCALAR number value.

 

=item # */ 

 

=item # /** value

 

=item # The value of this unit (e.g. "m" or "cm" or "km", etc)

 

=item # */

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** classXMLNodeName

 

=item # This method returns the class node name of XDF::Unit.

 

=item # This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classXMLNodeName {

 

=item }

 

=item # /** classAttributes

 

=item #  This method returns a list reference containing the names

 

=item #  of the class attributes of XDF::Unit. 

 

=item #  This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classAttributes {

 

=item \@Class_Attributes;

 

=item }

 

=item #

 

=item # Get/Set Methods

 

=item #

 

=item # /** getPower

 

=item # */

 

=item sub getPower {

 

=item return $self->{Power};

 

=item }

 

=item # /** setPower

 

=item #     Set the power attribute. 

 

=item # */

 

=item sub setPower {

 

=item $self->{Power} = $value;

 

=item }

 

=item # /** getValue

 

=item # */

 

=item sub getValue {

 

=item return $self->{Value};

 

=item }

 

=item # /** setValue

 

=item #     Set the value attribute. 

 

=item # */

 

=item sub setValue {

 

=item $self->{Value} = $value;

 

=item }

 

=item # /** getXMLAttributes

 

=item #      This method returns the XMLAttributes of this class. 

 

=item #  */

 

=item sub getXMLAttributes { 

 

=item }

 

=item #

 

=item # other Public methods

 

=item #

 

=item # Override XDF::BaseObject::setXMLAttributes. Special new method for Value objects.

 

=item # /** setXMLAttributes

 

=item # XDF::Unit has a special setXMLAttributes method. 

 

=item # These objects are so simple they seem to merit 

 

=item # special handling. This new setXMLAttributes method takes either

 

=item # and attribute Hash reference or a STRING.

 

=item # If the input value is a HASH reference, we 

 

=item # construct an object from it, else, we 

 

=item # just set its value attribute to the contents of 

 

=item # the passed STRING. 

 

=item # */

 

=item sub setXMLAttributes {

 

=item # these objects are so simple they seem to merit 

 

=item # special handling. If $info is a reference, we assume

 

=item # it is an attribute hash (as per other objects). Else,

 

=item # we assume its a string, and the value of the note.

 

=item if (defined $info) {

 

=item if (ref($info) ) {

 

=back

=head2 OTHER Methods

=over 4

=item getPower (EMPTY)



=item setPower ($value)

Set the power attribute. 

=item getValue (EMPTY)



=item setValue ($value)

Set the value attribute. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item setXMLAttributes ($info)

XDF::Unit has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. 

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

XDF::Unit inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Unit inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

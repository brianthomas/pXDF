
# $Id$

# this can holds a value (magnitude) + direction
# may specify imaginary or physical vector

package XDF::UnitDirection;

# /** COPYRIGHT
#    UnitDirection.pm Copyright (C) 2000 Brian Thomas,
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


use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "unitDirection";
my @Class_XML_Attributes = qw (
                             name
                             description
                             complex
                             axisIdRef
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

sub classAttributes { 
  \@Class_Attributes; 
}

#
# Get/Set Methods
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

# /** getAxisIdRef
#  */
sub getAxisIdRef {
   my ($self) = @_;
   return $self->{AxisIdRef};
}

# /** setAxisIdRef
#  */
sub setAxisIdRef {
   my ($self, $value) = @_;
   $self->{AxisIdRef} = $value;
}

# /** getComplex
#  */
sub getComplex {
   my ($self) = @_;
   return $self->{Complex};
}

# /** setComplex
#  */
sub setComplex {
   my ($self, $value) = @_;
   $self->{Complex} = $value;
}

# Q: what is the (scalar) "value" of this vector?
# /** value
# Returns the "value" of this unit direction (and you thought that it
# would be '1', heh). We assume its value is the axisIdRef IF 
# thats defined; we use the name or description otherwise.
# Basically put here to make XDF::AxisUnitDirection have consistent interface
# with XDF::Value.
# */
sub getValue {
  my ($self) = @_;

  my $value = $self->{AxisIdRef};
  $value = $self->{Name} unless defined $value;
  $value = $self->{Description} unless defined $value;

  return $value;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
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
# Revision 1.5  2000/12/15 22:12:00  thomas
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

XDF::UnitDirection - Perl Class for UnitDirection

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::UnitDirection inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::UnitDirection.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item sub classXMLNodeName { 

 

=item }

 

=item sub classAttributes { 

 

=item }

 

=item #

 

=item # Get/Set Methods

 

=item #

 

=item # /** getName

 

=item # */

 

=item sub getName {

 

=item return $self->{Name};

 

=item }

 

=item # /** setName

 

=item #     Set the name attribute. 

 

=item # */

 

=item sub setName {

 

=item $self->{Name} = $value;

 

=item }

 

=item # /** getDescription

 

=item #  */

 

=item sub getDescription {

 

=item return $self->{Description};

 

=item }

 

=item # /** setDescription

 

=item #  */

 

=item sub setDescription {

 

=item $self->{Description} = $value;

 

=item }

 

=item # /** getAxisIdRef

 

=item #  */

 

=item sub getAxisIdRef {

 

=item return $self->{AxisIdRef};

 

=item }

 

=item # /** setAxisIdRef

 

=item #  */

 

=item sub setAxisIdRef {

 

=item $self->{AxisIdRef} = $value;

 

=item }

 

=item # /** getComplex

 

=item #  */

 

=item sub getComplex {

 

=item return $self->{Complex};

 

=item }

 

=item # /** setComplex

 

=item #  */

 

=item sub setComplex {

 

=item $self->{Complex} = $value;

 

=item }

 

=item # Q: what is the (scalar) "value" of this vector?

 

=item # /** value

 

=item # Returns the "value" of this unit direction (and you thought that it

 

=item # would be '1', heh). We assume its value is the axisIdRef IF 

 

=item # thats defined; we use the name or description otherwise.

 

=item # Basically put here to make XDF::AxisUnitDirection have consistent interface

 

=item # with XDF::Value.

 

=item # */

 

=item sub getValue {

 

=item my $value = $self->{AxisIdRef};

 

=item $value = $self->{Name} unless defined $value;

 

=item $value = $self->{Description} unless defined $value;

 

=item return $value;

 

=item }

 

=item # /** getXMLAttributes

 

=item #      This method returns the XMLAttributes of this class. 

 

=item #  */

 

=item sub getXMLAttributes {

 

=item }

 

=item #

 

=item # Private Methods

 

=item #

 

=item # This is called when we cant find any defined method

 

=item # exists already. Used to handle general purpose set/get

 

=item # methods for our attributes (object fields).

 

=item sub AUTOLOAD {

 

=item my ($self,$val) = @_;

 

=back

=head2 OTHER Methods

=over 4

=item getName (EMPTY)



=item setName ($value)

Set the name attribute. 

=item getDescription (EMPTY)



=item setDescription ($value)



=item getAxisIdRef (EMPTY)



=item setAxisIdRef ($value)



=item getComplex (EMPTY)



=item setComplex ($value)



=item getValue (EMPTY)



=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

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

XDF::UnitDirection inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::UnitDirection inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO



=back

=head1 AUTHOR



=cut

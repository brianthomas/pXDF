
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


#use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "unitDirection";
my @Local_Class_XML_Attributes = qw (
                             name
                             description
                             complex
                             axisIdRef
                          );
my @Local_Class_Attributes = ();


my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
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
# Get/Set Methods
#

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $self->{name};
}

# /** setName
#     Set the name attribute. 
# */
sub setName {
   my ($self, $value) = @_;
   $self->{name} = $value;
}

# /** getDescription
#  */
sub getDescription {
   my ($self) = @_;
   return $self->{description};
}

# /** setDescription
#  */
sub setDescription {
   my ($self, $value) = @_;
   $self->{description} = $value;
}

# /** getAxisIdRef
#  */
sub getAxisIdRef {
   my ($self) = @_;
   return $self->{axisIdRef};
}

# /** setAxisIdRef
#  */
sub setAxisIdRef {
   my ($self, $value) = @_;
   $self->{axisIdRef} = $value;
}

# /** getComplex
#  */
sub getComplex {
   my ($self) = @_;
   return $self->{complex};
}

# /** setComplex
#  */
sub setComplex {
   my ($self, $value) = @_;
   $self->{complex} = $value;
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

  my $value = $self->{axisIdRef};
  $value = $self->{name} unless defined $value;
  $value = $self->{description} unless defined $value;

  return $value;
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

XDF::UnitDirection - Perl Class for UnitDirection

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::UnitDirection inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::UnitDirection.

=over 4

=item classXMLNodeName (EMPTY)

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::UnitDirection.

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

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::UnitDirection inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::UnitDirection inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4



=back

=head1 AUTHOR

 

=cut


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
my @Class_Attributes = qw (
                             name
                             description
                             complex
                             axisIdRef
                          );

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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# Q: what is the (scalar) "value" of this vector?
# /** value
# Returns the "value" of this unit direction (and you thought that it
# would be '1', heh). We assume its value is the axisIdRef IF 
# thats defined; we use the name or description otherwise.
# Basically put here to make XDF::AxisUnitDirection have consistent interface
# with XDF::Value.
# */
sub value {
  my ($self) = @_;

  my $value = $self->axisIdRef();
  $value = $self->name() unless defined $value;
  $value = $self->description() unless defined $value;

  return $value;
}

# Modification History
#
# $Log$
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

=item name

 

=item description

 

=item complex

 

=item axisIdRef

 

=back

=head2 OTHER Methods

=over 4

=item value (EMPTY)

Returns the "value" of this unit direction (and you thought that itwould be '1', heh). We assume its value is the axisIdRef IF thats defined; we use the name or description otherwise. Basically put here to make XDF::AxisUnitDirection have consistent interfacewith XDF::Value. 

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
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::UnitDirection inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO



=back

=head1 AUTHOR



=cut

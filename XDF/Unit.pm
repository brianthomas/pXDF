
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


use XDF::Object;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my $Class_XML_Node_Name = "unit";
my @Class_Attributes = qw (
                             power
                             value
                          );

# /** power
# The power of this unit. Takes a SCALAR number value.
# */ 
# /** value
# The value of this unit (e.g. "m" or "cm" or "km", etc)
# */

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# Override XDF::Object::update. Special new method for Value objects.
# /** update
# XDF::Unit has a special update method. 
# These objects are so simple they seem to merit 
# special handling. This new update method takes either
# and attribute Hash reference or a STRING.
# If the input value is a HASH reference, we 
# construct an object from it, else, we 
# just set its value attribute to the contents of 
# the passed STRING. 
# */
sub update {
  my ($self, $info ) = @_;

  # these objects are so simple they seem to merit 
  # special handling. If $info is a reference, we assume
  # it is an attribute hash (as per other objects). Else,
  # we assume its a string, and the value of the note.
  if (defined $info) {
    if (ref($info) ) {
      $self->SUPER::update($info);
    } else {
      $self->value($info);
    }
  }

}

1;


__END__

=head1 NAME

XDF::Unit - Perl Class for Unit

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::Unit describes a unit within a given units object. 

XDF::Unit inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


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

=item power

The power of this unit. Takes a SCALAR number value.  

=item value

The value of this unit (e.g. "m" or "cm" or "km", etc) 

=back

=head2 OTHER Methods

=over 4

=item update ($info)

XDF::Unit has a special update method. These objects are so simple they seem to merit special handling. This new update method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. 

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

XDF::Unit inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<setObjRef>.

=back



=over 4

XDF::Unit inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::Object>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

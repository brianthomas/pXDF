
# $Id$

package XDF::ErroredValue;

# /** COPYRIGHT
#    ErroredValue.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::ErroredValue describes a single scalar (number or string) 
# that has an associated error value. XDF::Parameter uses this object
# to store its (mathematical) value. 
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::Value
# XDF::Parameter
# */

use XDF::Value;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::Value
@ISA = ("XDF::Value");

# CLASS DATA
# /** valueId
# A scalar string holding the value id of this object. 
# */
# /** valueIdRef 
# A scalar string holding the value id reference to another value. 
# Note that in order to get the code to use the reference object,
# the $obj->setObjRef($refFieldObj) method should be used.
# */
# /** value
# Holds the scalar STRING that is this value.
# */

my @Class_Attributes = qw (
                             upperErrorValue
                             lowerErrorValue
                             errorValue
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::Value::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Value. 
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

# special new method for Value objects.
# /** update
# XDF::Value has a special update method. 
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

# Modification History
#
# $Log$
# Revision 1.3  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::ErroredValue - Perl Class for ErroredValue

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::ErroredValue describes a single scalar (number or string)  that has an associated error value. XDF::Parameter uses this object to store its (mathematical) value. 

XDF::ErroredValue inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::Value>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::ErroredValue.

=over 4

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Value. This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item upperErrorValue

 

=item lowerErrorValue

 

=item errorValue

 

=back

=head2 OTHER Methods

=over 4

=item update ($info)

XDF::Value has a special update method. These objects are so simple they seem to merit special handling. This new update method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its value attribute to the contents of the passed STRING. 

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

XDF::ErroredValue inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<setObjRef>.

=back



=over 4

XDF::ErroredValue inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::Value>, L< XDF::Parameter>, L<XDF::Value>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

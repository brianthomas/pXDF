
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
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

my @Local_Class_XML_Attributes = qw (
                             upperErrorValue
                             lowerErrorValue
                          );
my @Local_Class_Attributes = qw ( );
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::Value::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::Value::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::Value. 
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# SET/GET Methods
#

# /** getUpperErrorValue
# */
sub getUpperErrorValue{
   my ($self) = @_;
   return $self->{upperErrorValue};
}

# /** setUpperErrorValue
#     Set the upperErrorValue attribute. 
# */
sub setUpperErrorValue {
   my ($self, $value) = @_;
   $self->{upperErrorValue} = $value;
}

# /** getLowerErrorValue
# */
sub getLowerErrorValue {
   my ($self) = @_;
   return $self->{lowerErrorValue};
}

# /** setLowerErrorValue
#     Set the lowerErrorValue attribute. 
# */
sub setLowerErrorValue {
   my ($self, $value) = @_;
   $self->{lowerErrorValue} = $value;
}

# /** getErrorValues
#   A convience method which returns an array reference holding 
#   the value of the lowerErrorValue and upperErrorValue attributes. 
# */
sub getErrorValues {
   my ($self) = @_;
   my @values = ($self->{lowerErrorValue}, $self->{upperErrorValue});
   return \@values;
}

# /** setErrorValue
#     Sets the value of both the upperErrorValue and lowerErrorValue
#     attributes to the passed value.
# */
sub setErrorValue {
   my ($self, $value) = @_;
   $self->{upperErrorValue} = $value;
   $self->{lowerErrorValue} = $value;
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

XDF::ErroredValue - Perl Class for ErroredValue

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::ErroredValue describes a single scalar (number or string)  that has an associated error value. XDF::Parameter uses this object to store its (mathematical) value. 

XDF::ErroredValue inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::Value>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::ErroredValue.

=over 4

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::Value. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::ErroredValue.

=over 4

=item getUpperErrorValue{ (EMPTY)

 

=item setUpperErrorValue ($value)

Set the upperErrorValue attribute.  

=item getLowerErrorValue (EMPTY)

 

=item setLowerErrorValue ($value)

Set the lowerErrorValue attribute.  

=item getErrorValues (EMPTY)

A convience method which returns an array reference holding the value of the lowerErrorValue and upperErrorValue attributes.  

=item setErrorValue ($value)

Sets the value of both the upperErrorValue and lowerErrorValueattributes to the passed value.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::ErroredValue inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::ErroredValue inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::ErroredValue inherits the following instance (object) methods of L<XDF::Value>:
B<getValueId{>, B<setValueId>, B<getValueIdRef>, B<setValueIdRef>, B<getSpecial{>, B<setSpecial>, B<getInequality>, B<setInequality>, B<getValue>, B<setValue>, B<setXMLAttributes>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Value>, L< XDF::Parameter>, L<XDF::Value>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

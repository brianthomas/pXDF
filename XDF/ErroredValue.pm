
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

my @Class_XML_Attributes = qw (
                             upperErrorValue
                             lowerErrorValue
                          );
my @Class_Attributes = ();

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::Value::classAttributes};
push @Class_XML_Attributes, @{&XDF::Value::getXMLAttributes};

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

#
# SET/GET Methods
#

# /** getUpperErrorValue
# */
sub getUpperErrorValue{
   my ($self) = @_;
   return $self->{UpperErrorValue};
}

# /** setUpperErrorValue
#     Set the upperErrorValue attribute. 
# */
sub setUpperErrorValue {
   my ($self, $value) = @_;
   $self->{UpperErrorValue} = $value;
}

# /** getLowerErrorValue
# */
sub getLowerErrorValue {
   my ($self) = @_;
   return $self->{LowerErrorValue};
}

# /** setLowerErrorValue
#     Set the lowerErrorValue attribute. 
# */
sub setLowerErrorValue {
   my ($self, $value) = @_;
   $self->{LowerErrorValue} = $value;
}

# /** getErrorValues
#   A convience method which returns an array reference holding 
#   the value of the lowerErrorValue and upperErrorValue attributes. 
# */
sub getErrorValues {
   my ($self) = @_;
   my @values = ($self->{LowerErrorValue}, $self->{UpperErrorValue});
   return \@values;
}

# /** setErrorValue
#     Sets the value of both the upperErrorValue and lowerErrorValue
#     attributes to the passed value.
# */
sub setErrorValue {
   my ($self, $value) = @_;
   $self->{UpperErrorValue} = $value;
   $self->{LowerErrorValue} = $value;
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
# Revision 1.5  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
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

=item # add in class XML attributes

 

=item push @Class_Attributes, @Class_XML_Attributes;

 

=item # add in super class attributes

 

=item push @Class_Attributes, @{&XDF::Value::classAttributes};

 

=item push @Class_XML_Attributes, @{&XDF::Value::getXMLAttributes};

 

=item # Initalization

 

=item # set up object attributes.

 

=item for my $attr ( @Class_Attributes ) { $field{$attr}++; }

 

=item # /** classAttributes

 

=item #  This method returns a list reference containing the names

 

=item #  of the class attributes of XDF::Value. 

 

=item #  This method takes no arguments may not be changed. 

 

=item # */

 

=item sub classAttributes {

 

=item }

 

=item #

 

=item # SET/GET Methods

 

=item #

 

=item # /** getUpperErrorValue

 

=item # */

 

=item sub getUpperErrorValue{

 

=item return $self->{UpperErrorValue};

 

=item }

 

=item # /** setUpperErrorValue

 

=item #     Set the upperErrorValue attribute. 

 

=item # */

 

=item sub setUpperErrorValue {

 

=item $self->{UpperErrorValue} = $value;

 

=item }

 

=item # /** getLowerErrorValue

 

=item # */

 

=item sub getLowerErrorValue {

 

=item return $self->{LowerErrorValue};

 

=item }

 

=item # /** setLowerErrorValue

 

=item #     Set the lowerErrorValue attribute. 

 

=item # */

 

=item sub setLowerErrorValue {

 

=item $self->{LowerErrorValue} = $value;

 

=item }

 

=item # /** getErrorValues

 

=item #   A convience method which returns an array reference holding 

 

=item #   the value of the lowerErrorValue and upperErrorValue attributes. 

 

=item # */

 

=item sub getErrorValues {

 

=back

=head2 OTHER Methods

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

XDF::ErroredValue inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::ErroredValue inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLNotationHash>, B<toXMLFileHandle>, B<toXMLFile>.

=back



=over 4

XDF::ErroredValue inherits the following instance methods of L<XDF::Value>:
B<getValueId{>, B<setValueId>, B<getValueIdRef>, B<setValueIdRef>, B<getSpecial{>, B<setSpecial>, B<getInequality{>, B<setInequality>, B<getValue{>, B<setValue>, B<setXMLAttributes>.

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

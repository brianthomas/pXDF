
# $Id$

# /** COPYRIGHT
#    Value.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Value holds mathematical values. XDF::ErroredValue inherits
# from this object; this object is also used
# at every indice on an XDF::Axis object to denote the coordinate
# value of a given index. The XDF::Value can holds a scalar value. To hold a vector 
# (unit direction) value use XDF::UnitDirection instead.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Axis
# XDF::ErroredValue
# XDF::ValueListAlgorithm
# XDF::ValueListDelimitedList
# XDF::UnitDirection
# */

package XDF::Value;

use XDF::BaseObject;
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "value";
my @Local_Class_XML_Attributes = qw (
                             valueId
                             valueIdRef
                             special
                             inequality
                             value
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

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::Value.
# */
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
# SET/GET Methods
#

# /** getValueId
# */
sub getValueId{
   my ($self) = @_;
   return $self->{valueId};
}

# /** setValueId
#     Set the valueId attribute. 
# */
sub setValueId {
   my ($self, $value) = @_;
   $self->{valueId} = $value;
}

# /** getValueIdRef 
# */
sub getValueIdRef {
   my ($self) = @_;
   return $self->{valueIdRef};
}

# /** setValueIdRef 
#     Set the valueIdRef attribute. 
# */
sub setValueIdRef {
   my ($self, $value) = @_;
   $self->{valueIdRef} = $value;
}

# /** getSpecial
# */
sub getSpecial{
   my ($self) = @_;
   return $self->{special};
}

# /** setSpecial
#     Set the special attribute. 
# */
sub setSpecial {
   my ($self, $value) = @_;

   error("Cant set special to $value, not allowed \n") 
      unless (&XDF::Utility::isValidValueSpecial($value));

   $self->{special} = $value;
}

# /** getInequality
# */
sub getInequality {
   my ($self) = @_;
   return $self->{inequality};
}

# /** setInequality
#     Set the inequality attribute. 
# */
sub setInequality {
   my ($self, $value) = @_;

   error("Cant set special to $value, not allowed \n") 
      unless (&XDF::Utility::isValidValueInequality($value));

   $self->{inequality} = $value;
}

# /** getValue
# */
sub getValue {
   my ($self) = @_;
   return $self->{value};
}

# /** setValue
#     Set the value attribute. 
# */
sub setValue {
   my ($self, $value) = @_;
   $self->{value} = $value;
}

#
# Other Public Methods
#

# special new method for Value objects.
# /** setXMLAttributes
# XDF::ErrorValue has a special setXMLAttributes method. 
# These objects are so simple they seem to merit 
# special handling. This new setXMLAttributes method takes either
# and attribute Hash reference or a STRING.
# If the input value is a HASH reference, we 
# construct an object from it, else, we 
# just set its upperErrorValue AND lowerErrorValue attributes to the 
# contents of the passed STRING. 
# */
sub setXMLAttributes {
  my ($self, $info) = @_;

  # these objects are so simple they seem to merit 
  # special handling. If $info is a reference, we assume
  # it is an attribute hash (as per other objects). Else,
  # we assume its a string, and the value of the errorValue.
  if (defined $info) {
    if (ref($info) ) {
      $self->SUPER::setXMLAttributes($info);
    } else {
      $self->{value} = $info;
    }
  }
}

#
# Private methods 
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
  my ($self, $val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}


1;


__END__

=head1 NAME

XDF::Value - Perl Class for Value

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::Value holds mathematical values. XDF::ErroredValue inherits from this object; this object is also used at every indice on an XDF::Axis object to denote the coordinate value of a given index. The XDF::Value can holds a scalar value. To hold a vector  (unit direction) value use XDF::UnitDirection instead. 

XDF::Value inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Value.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::Value.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Value.

=over 4

=item getValueId{ (EMPTY)

 

=item setValueId ($value)

Set the valueId attribute.  

=item getValueIdRef (EMPTY)

 

=item setValueIdRef ($value)

Set the valueIdRef attribute.  

=item getSpecial{ (EMPTY)

 

=item setSpecial ($value)

Set the special attribute.  

=item getInequality (EMPTY)

 

=item setInequality ($value)

Set the inequality attribute.  

=item getValue (EMPTY)

 

=item setValue ($value)

Set the value attribute.  

=item setXMLAttributes ($info)

XDF::ErrorValue has a special setXMLAttributes method. These objects are so simple they seem to merit special handling. This new setXMLAttributes method takes eitherand attribute Hash reference or a STRING. If the input value is a HASH reference, we construct an object from it, else, we just set its upperErrorValue AND lowerErrorValue attributes to the contents of the passed STRING.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Value inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Value inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Axis>, L< XDF::ErroredValue>, L< XDF::ValueListAlgorithm>, L< XDF::ValueListDelimitedList>, L< XDF::UnitDirection>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

# /** COPYRIGHT
#    NaturalLogarithm.pm Copyright (C) 2003 Brian Thomas,
#    XML Group GSFC-NASA, Code 630.1, Greenbelt MD, 20771
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
# An XDF::NaturalLogarithm is a class that defines an natural log component for an XDF::Conversion object.
# */

# /** SYNOPSIS
# */

# /** SEE ALSO
# XDF::Conversion
# */

package XDF::NaturalLogarithm;

use XDF::ConversionComponent;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::ConversionComponent
@ISA = ("XDF::ConversionComponent");

# CLASS DATA
my $DEF_BASE = 2.7182881828; # the base value for the logarithm 

my $Class_XML_Node_Name = "naturalLogarithm";
my @Local_Class_XML_Attributes = qw ( );
my @Local_Class_Attributes = ();

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::ConversionComponent::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::ConversionComponent::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::NaturalLogarithm.
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
# Constructor
#

# Override constructor. THis class doesnt take value.
#sub new {
#  my ($proto, $attribHash) = @_;

#   my $self = $proto->SUPER->SUPER::new($attribHash);
#   $self->_init();

#   return $self;
#}

# 
# SET/GET Methods
#

# /** getValue
# Returns the base exponent value, e.g. the value of 'e' (2.718..)
# */
sub getValue { 
   my ($self) = @_;
   return $DEF_BASE;
}

# /** setValue
#     Not allowed for naturalLogarithm. 
# */
sub setValue { # PRIVATE
   my ($self, $value) = @_;
#   $self->{value} = $value;
   error("Cant set value for Natural Logarithm\n"); 
}

#
# Other Public Methods
#

# /** evaluate
# Evaluate a value using this conversion object. Returns the converted
# value.
# */
sub evaluate { # PROTECTED
   my ($self, $value) = @_;
   return (log $value);
}

#
# Private methods 
#

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();

  $self->{value} = undef; # yes, thats right we dont want this defined 

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

XDF::NaturalLogarithm - Perl Class for NaturalLogarithm

=head1 SYNOPSIS

...

=head1 DESCRIPTION

 An XDF::NaturalLogarithm is a class that defines an natural log component for an XDF::Conversion object. 

XDF::NaturalLogarithm inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::ConversionComponent>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::NaturalLogarithm.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::NaturalLogarithm.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::NaturalLogarithm.

=over 4

=item getValue (EMPTY)

Returns the base exponent value, e.g. the value of 'e' (2.718..) 

=item evaluate ($value)

Evaluate a value using this conversion object. Returns the convertedvalue.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::NaturalLogarithm inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::NaturalLogarithm inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Conversion>, L<XDF::ConversionComponent>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

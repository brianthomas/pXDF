
# $Id$

package XDF::Polynomial;

# /** COPYRIGHT
#    Polynomial.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::Polynomial describes a type of algorithm. It is used in other
# XDF objects to describe/generate numerical values.
# */

# /** SYNOPSIS
#  
# */

# /** SEE ALSO
# XDF::ValueListAlgorithm
# */

use XDF::BaseObject;
use XDF::Constants;
use XDF::Utility;
use XDF::Log;

use strict;
#use integer; # Important! dont want to round off our values! 

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "polynomial";
my @Local_Class_XML_Attributes = qw (
                             reverse
                             logarithm
                             size
                             value
                          );
my @Local_Class_Attributes = qw (
                                   _parent
                                   _coefficientList
                                );

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
# This method returns the class node name of XDF::Polynomial.
# This method takes no arguments may not be changed. 
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
# Get/Set Methods
#

# /** getSize
# Get the number of values to calculate.
# */
sub getSize {
   my ($self) = @_;
   return $self->{size};
}

# /** setSize
# Set the number of values to calculate.
# */
sub setSize {
   my ($self, $value) = @_;
   $self->{size} = $value;
}
 
# /** getReverse
# Determine whether or not the numerical sequence is reversed. 
# */
sub getReverse {
   my ($self) = @_;
   return $self->{reverse};
}

# /** setReverse
# Set whether or not the numerical sequence is reversed. 
# */
sub setReverse {
   my ($self, $value) = @_;
   unless (&XDF::Utility::isValidReverse($value)) { 
     &error("Cant set polynomial reverse to $value, not allowed \n"); 
     return;
   }
   $self->{reverse} = $value;
}

# /** getLogarithm
# Determine whether or not output values are logrithmic or not.
# */
sub getLogarithm {
   my ($self) = @_;
   return $self->{logarithm};
}

# /** setLogarithm
#     Set the logarithm attribute. Values may be "10", "natural" or undef (e.g. not logarithmic)
# */
sub setLogarithm {
   my ($self, $value) = @_;
   unless (&XDF::Utility::isValidLogarithm($value)) { 
     &error("Cant set polynomial logarithm to $value, not allowed \n"); 
     return;
   }
   $self->{logarithm} = $value;
}

# /** getOwner
# Return the owner (parent) object of this polynomial.
# */
sub getOwner {
   my ($self) = @_;
   return $self->{_parent};
}

# /** setCoefficients
# Set the list of coefficients on this polynomial.
# Calling this will re-generate numbers in the parent object (if any).
# */
sub setCoefficients {
   my ($self, $coefficientListRef) = @_;

   if (ref $coefficientListRef)
   {
      $self->{coefficientList} = $coefficientListRef;
      my $value = join " ", @$coefficientListRef;
      chomp $value;
      $self->{value} = $value;
      if (ref $self->{_parent}) 
      {
         $self->{_parent}->_initValuesFromParams();
      }
   }
}

# /** getCoefficients
# Return the list of coefficients used to generate the list of values.
# */
sub getCoefficients {
   my ($self) = @_;
   return $self->{coefficientList};
}

# /** getValues
# return a list of numerical values as described by the attributes of this polynomial.
# */
sub getValues {
  my ($self) = @_;


  my @values;
  my $algorithm;
  my $reverse = $self->getReverse();
  my $additional = "";

  foreach my $i (0 .. $#{$self->getCoefficients()}) {
     #my $coeff = @{$self->getCoefficients()}->[$i];
     my $coeff = $self->getCoefficients()->[$i];
     $algorithm .= "+" if ($i);
     $algorithm .= "($coeff";
     $algorithm .= "*(\$x**$i)" if ($i);
     $algorithm .= ")";
  }

  if ($algorithm) {
    my $size = $self->getSize();
    my @sequence = 0 .. ($size-1);
    if ($reverse and $reverse eq &XDF::Constants::TRUE )
    {
       @sequence = reverse @sequence;
    }

    my $log = $self->getLogarithm();
    if (defined $log) {
      $algorithm = "_log10($algorithm)" if $log eq &XDF::Constants::LOGARITHM_BASE10;
      $algorithm = "log($algorithm)" if $log eq &XDF::Constants::LOGARITHM_NATURAL;
    }

    # now calculate the values
    foreach my $x (@sequence) 
    {
       my $value = eval $algorithm;
       push @values, $value;
    }
  }

  return \@values;
}

#
# Private Methods
#

sub _log10 {
  my $n = shift;
  return log($n)/log(10);
}

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();
  
  $self->{_coefficientList} = [];
  $self->{value} = "0";

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

XDF::Polynomial - Perl Class for Polynomial

=head1 SYNOPSIS

  


...

=head1 DESCRIPTION

 An XDF::Polynomial describes a type of algorithm. It is used in other XDF objects to describe/generate numerical values. 

XDF::Polynomial inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Polynomial.

=over 4

=item classXMLNodeName (EMPTY)

This method returns the class node name of XDF::Polynomial. This method takes no arguments may not be changed.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Polynomial.

=over 4

=item getSize (EMPTY)

Get the number of values to calculate.  

=item setSize ($value)

Set the number of values to calculate.  

=item getReverse (EMPTY)

Determine whether or not the numerical sequence is reversed.  

=item setReverse ($value)

Set whether or not the numerical sequence is reversed.  

=item getLogarithm (EMPTY)

Determine whether or not output values are logrithmic or not.  

=item setLogarithm ($value)

Set the logarithm attribute. Values may be "10", "natural" or undef (e.g. not logarithmic) 

=item getOwner (EMPTY)

Return the owner (parent) object of this polynomial.  

=item setCoefficients ($coefficientListRef)

Set the list of coefficients on this polynomial. Calling this will re-generate numbers in the parent object (if any).  

=item getCoefficients (EMPTY)

Return the list of coefficients used to generate the list of values.  

=item getValues (EMPTY)

return a list of numerical values as described by the attributes of this polynomial.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Polynomial inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Polynomial inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::ValueListAlgorithm>, L<XDF::BaseObject>, L<XDF::Constants>, L<XDF::Utility>, L<XDF::Log>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

# /** COPYRIGHT
#    ValueListAlgorithm.pm Copyright (C) 2000 Brian Thomas,
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
# ValueListAlgorithm will create a list of values from a simple (linear) algorithm. 
# The ValueList object may be then passed on and used by other objects
# to populate the list of values they hold.
# The formula for the creation of new Value objects is as follows:
# currentValue = currentStep * stepValue + startValue. The 
# size parameter determines how many values to enter into the
# object. A desirable feature of using the ValueList object is that it result in
# a more compact format for describing the values so added to other objects
# when they are written out using the toXMLFileHandle method.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Axis
# XDF::Parameter
# XDF::ValueListDelimitedList
# */

package XDF::ValueListAlgorithm;

use XDF::BaseObject;
use XDF::Log;
use XDF::Value;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "valueListAlgorithm";
my @Local_Class_XML_Attributes = qw (
                              valueListId
                              valueListIdRef
                              algorithm
                           );
                           #   noDataValue 
                           #   infiniteValue 
                           #   infiniteNegativeValue
                           #   notANumberValue 
                           #   overflowValue 
                           #   underflowValue
my @Local_Class_Attributes = qw ( 
                             values
                           );
                             #_definedSpecialsHash
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::ValueListAlgorithm.
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
# Constructors
# 

# /** new
# We use default values for start, step, and size unless they are defined.
# The other parameters are optional and will remain undefined unless specified by the user.
# */
sub new { 
  my ($proto, $attribHashRef) = @_;

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($attribHashRef);

  return $self;
}


# 
# SET/GET Methods
#

# /** getValueListId
# */
sub getValueListId {
   my ($self) = @_;
   return $self->{valueListId};
}

# /** setValueListId
#     Set the valueListId attribute. 
# */
sub setValueListId {
   my ($self, $value) = @_;
   $self->{valueListId} = $value;
}

# /** getValueListIdRef 
# */
sub getValueListIdRef {
   my ($self) = @_;
   return $self->{valueListIdRef};
}

# /** setValueListIdRef 
#     Set the valueListIdRef attribute. 
# */
sub setValueListIdRef {
   my ($self, $value) = @_;
   $self->{valueListIdRef} = $value;
}

# /** getValues
# Return the list of values held in this object.
# */
sub getValues {
   my ($self) = @_;
   return $self->{values};
}

# /** getAlgorithm
# Return the algorithm used to generate the values held in this object.
# */
sub getAlgorithm {
  my ($self) = @_;
  return $self->{algorithm};
}

# /** setNoDataValue
# Set the particular algorithm to be used in generating the 
# values of this object.
# */
sub setAlgorithm {
  my ($self, $algorithm) = @_;

  if (&XDF::Utility::isValidAlgorithm($algorithm) ) 
  { 

     if ($self->{algorithm}) 
     {
        # unset parent in prior polynomial object
        $self->{algorithm}->{_parent} = undef;
     }

     $self->{algorithm} = $algorithm; 
     $self->{algorithm}->{_parent} = $self;

  } else {
     &error("Cant set algorithm to $algorithm, not allowed \n");
  }

}

# /* getNoDataValue
# Return the particular value in the list that indicates a 'noData' value.
# */
#sub getNoDataValue {
#  my ($self) = @_;
#  return $self->{noDataValue};
#}

# /* setNoDataValue
# Set the particular value in the list that indicates a 'noData' value.
# */
#sub setNoDataValue {
#  my ($self, $value) = @_;
#
#  $self->{noDataValue} = $value;

#  if (defined $value) {
    #%{$self->{_definedSpecialsHash}}->{'noData'} = $value;
#    $self->{_definedSpecialsHash}->{'noData'} = $value;
#  } else {
#    #delete %{$self->{_definedSpecialsHash}}->{'noData'} 
#    delete $self->{_definedSpecialsHash}->{'noData'} 
#       #if exists %{$self->{_definedSpecialsHash}}->{'noData'};
#       if exists $self->{_definedSpecialsHash}->{'noData'};
#  }
#
#}

# /* getInfiniteValue
# Return the particular value in the list that indicates an 'infinite' value.
# */
#sub getInfiniteValue {
#  my ($self) = @_;
#  return $self->{infiniteValue}; 
#}

# /* setInfiniteValue
# Set the particular value in the list that indicates an 'infinite' value.
# */
#sub setInfiniteValue {
#  my ($self, $value) = @_;

#  $self->{infiniteValue} = $value;

#  if (defined $value) {
    #%{$self->{_definedSpecialsHash}}->{'infinite'} = $value;
#    $self->{_definedSpecialsHash}->{'infinite'} = $value;
#  } else {
   # delete %{$self->{_definedSpecialsHash}}->{'infinite'} 
#    delete $self->{_definedSpecialsHash}->{'infinite'} 
      # if exists %{$self->{_definedSpecialsHash}}->{'infinite'};
#       if exists $self->{_definedSpecialsHash}->{'infinite'};
#  }

#}

# /* getInfiniteNegativeValue
# Return the particular value in the list that indicates an 'infiniteNegative' value.
# */
#sub getInfiniteNegativeValue {
#  my ($self) = @_;
#  return $self->{infiniteNegativeValue};
#}

# /* setInfiniteNegativeValue
# Set the particular value in the list that indicates an 'infiniteNegative' value.
# */
#sub setInfiniteNegativeValue {
#  my ($self, $value) = @_;

#  $self->{infiniteNegativeValue} = $value;

#  if (defined $value) {
    #%{$self->{_definedSpecialsHash}}->{'infiniteNegative'} = $value;
#    $self->{_definedSpecialsHash}->{'infiniteNegative'} = $value;
#  } else {
    #delete %{$self->{_definedSpecialsHash}}->{'infiniteNegative'} 
#    delete $self->{_definedSpecialsHash}->{'infiniteNegative'} 
       #if exists %{$self->{_definedSpecialsHash}}->{'infiniteNegative'};
#       if exists $self->{_definedSpecialsHash}->{'infiniteNegative'};
#  }

#}

# /* getNotANumberValue
# Return the particular value in the list that indicates an 'notANumber' value.
# */
#sub getNotANumberValue {
#  my ($self) = @_;
#  return $self->{notANumberValue};
#}

# /* setNotANumberValue
# Set the particular value in the list that indicates an 'notANumber' value.
# */
#sub setNotANumberValue {
#  my ($self, $value) = @_;

#  $self->{notANumberValue} = $value;

#  if (defined $value) {
    #%{$self->{_definedSpecialsHash}}->{'notANumber'} = $value;
#    $self->{_definedSpecialsHash}->{'notANumber'} = $value;
#  } else {
    #delete %{$self->{_definedSpecialsHash}}->{'notANumber'} 
#    delete $self->{_definedSpecialsHash}->{'notANumber'} 
       #if exists %{$self->{_definedSpecialsHash}}->{'notANumber'};
#       if exists $self->{_definedSpecialsHash}->{'notANumber'};
#  }
#
#}

# /* getUnderflowValue
# Return the particular value in the list that indicates an 'underflow' value.
# */
#sub getUnderflowValue {
#  my ($self) = @_;
#  return $self->{underflowValue};
#}

# /* setUnderflowValue
# Set the particular value in the list that indicates an 'underflow' value.
# */
#sub setUnderflowValue {
#  my ($self, $value) = @_;

#  $self->{underflowValue} = $value;

#  if (defined $value) {
    #%{$self->{_definedSpecialsHash}}->{'underflow'} = $value;
#    $self->{_definedSpecialsHash}->{'underflow'} = $value;
#  } else {
    #delete %{$self->{_definedSpecialsHash}}->{'underflow'} 
#    delete $self->{_definedSpecialsHash}->{'underflow'} 
       #if exists %{$self->{_definedSpecialsHash}}->{'underflow'};
#       if exists $self->{_definedSpecialsHash}->{'underflow'};
#  }

#}

# /* getOverflowValue
# Return the particular value in the list that indicates an 'overflow' value.
# */
#sub getOverflowValue {
#  my ($self) = @_;
#  return $self->{overflowValue};
#}

# /* setOverflowValue
# Set the particular value in the list that indicates an 'overflow' value.
# */
#sub setOverflowValue {
#  my ($self, $value) = @_;

#  $self->{overflowValue} = $value;

#  if (defined $value) {
     #%{$self->{_definedSpecialsHash}}->{'overflow'} = $value;
#    $self->{_definedSpecialsHash}->{'overflow'} = $value;
#  } else {
    #delete %{$self->{_definedSpecialsHash}}->{'overflow'} 
    #   if exists %{$self->{_definedSpecialsHash}}->{'overflow'};
#    delete $self->{_definedSpecialsHash}->{'overflow'} 
#       if exists $self->{_definedSpecialsHash}->{'overflow'};
#  }

#}

#
# Other Public Methods
#

#
# Private methods 
#

sub _init {
   my ($self, $attribHashRef) = @_;

   # adds to ordered list of XML attributes
   $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

   $self->setXMLAttributes($attribHashRef) if defined $attribHashRef;

   # this should help speed up init of held value objects 
#   $self->{_definedSpecialsHash} = {};

#   $self->{step} = &XDF::Constants::DEFAULT_VALUELIST_STEP
#      unless defined $self->{step};
     
   $self->{size} = &XDF::Constants::DEFAULT_VALUELIST_SIZE
      unless defined $self->{size};

   $self->{values} = [];
  
   $self->_initValuesFromParams(); 

}

sub _initValuesFromParams {
   my ($self) = @_;

   my @values;

#   my @definedSpecials = keys %{$self->{_definedSpecialsHash}};
#   my $checkSpecials = $#definedSpecials >= 0 ? 1 : 0;

   my $algorithm = $self->getAlgorithm();
   if ($algorithm) {
      foreach my $number (@{$algorithm->getValues()}) 
      {
        #my $thisValue = $self->_create_value_object($number, $checkSpecials);
        my $thisValue = $self->_create_value_object($number, 0);
        push @values, $thisValue;
      }
   }

   $self->{values} = \@values;

}

sub _create_value_object {
   my ($self, $string_val, $checkSpecials, $template) = @_;

   my $valueObj = new XDF::Value();

   if (defined $string_val) {

      if ($checkSpecials) {

#        while (my ($whatSpecial, $value) = each %{$self->{_definedSpecialsHash}}) 
#        {
#           if ($value eq $string_val)
#           {
#               $valueObj->setSpecial($whatSpecial);
#               last;
#           }
#        }  

        # if no special matches, then we use value string as the value
        $valueObj->setValue($string_val) unless $valueObj->getSpecial();

      } else {

         $valueObj->setValue($string_val);

      }
   }

   return $valueObj;
}

#
# Protected/Private Methods
#

sub _basicXMLWriter_alt {
   my ($self, $fileHandle, $indent ) = @_;

   if(!defined $fileHandle) {
      error("Can't write out object, filehandle not defined.\n");
      return;
   }

   $indent = "" unless defined $indent;

   my $spec = XDF::Specification->getInstance();
   my $isPrettyXDFOutput = $spec->isPrettyXDFOutput;

   print $fileHandle $indent if $isPrettyXDFOutput;

   print $fileHandle "<$Class_XML_Node_Name";
   print $fileHandle " start=\"".$self->{start}."\" step=\"".$self->{step}."\" size=\"".$self->{size}."\"";
   print $fileHandle " valueListId=\"".$self->{valueListId}."\"" if (defined $self->{valueListId});
   print $fileHandle " valueListIdRef=\"".$self->{valueListIdRef}."\"" if (defined $self->{valueListIdRef});
   print $fileHandle " noDataValue=\"".$self->{noDataValue}."\"" if (defined $self->{noDataValue});
   print $fileHandle " infiniteValue=\"".$self->{infiniteValue}."\"" if (defined $self->{infiniteValue});
   print $fileHandle " infiniteNegativeValue=\"".$self->{infiniteNegativeValue}."\"" 
                       if (defined $self->{infiniteNegativeValue});
   print $fileHandle " notANumberValue=\"".$self->{notANumberValue}."\"" if (defined $self->{notANumberValue});
   print $fileHandle " overflowValue=\"".$self->{overflowValue}."\"" if (defined $self->{overflowValue});
   print $fileHandle " underflowValue=\"".$self->{underflowValue}."\"" if (defined $self->{underflowValue});
   print $fileHandle "/>";

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

XDF::ValueListAlgorithm - Perl Class for ValueListAlgorithm

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 ValueListAlgorithm will create a list of values from a simple (linear) algorithm.  The ValueList object may be then passed on and used by other objects to populate the list of values they hold.  The formula for the creation of new Value objects is as follows: currentValue = currentStep * stepValue + startValue. The  size parameter determines how many values to enter into the object. A desirable feature of using the ValueList object is that it result in a more compact format for describing the values so added to other objects when they are written out using the toXMLFileHandle method. 

XDF::ValueListAlgorithm inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::ValueListAlgorithm.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::ValueListAlgorithm.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item new ($attribHashRef)

We use default values for start, step, and size unless they are defined. The other parameters are optional and will remain undefined unless specified by the user.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::ValueListAlgorithm.

=over 4

=item getValueListId (EMPTY)

 

=item setValueListId ($value)

Set the valueListId attribute.  

=item getValueListIdRef (EMPTY)

 

=item setValueListIdRef ($value)

Set the valueListIdRef attribute.  

=item getValues (EMPTY)

Return the list of values held in this object.  

=item getAlgorithm (EMPTY)

Return the algorithm used to generate the values held in this object.  

=item setAlgorithm ($algorithm)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::ValueListAlgorithm inherits the following instance (object) methods of L<XDF::GenericObject>:
B<clone>, B<update>.

=back



=over 4

XDF::ValueListAlgorithm inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Axis>, L< XDF::Parameter>, L< XDF::ValueListDelimitedList>, L<XDF::BaseObject>, L<XDF::Log>, L<XDF::Value>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

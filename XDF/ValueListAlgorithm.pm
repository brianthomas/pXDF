
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
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
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
use XDF::Value;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "valueList";
my @Local_Class_XML_Attributes = qw (
                             valueListId
                             valueListIdRef
                             start
                             step
                             size
                             noData
                             infinite
                             infiniteNegative
                             notANumber
                             overflow
                             underflow
                           );
my @Local_Class_Attributes = qw ( 
                             values
                           );
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
# The other parameters are optional (e.g. noDataValue, infiniteValue, ...)
# and will remain undefined unless specified by the user.
# */
sub new { 
  my ($proto, $start, $step, $size, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue ) = @_;

  unless ((!defined $size || $size != 0) && (!defined $step || $step != 0)) {
    croak "Error: $proto got 0 value for either step or size value.\n";
  }

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($start, $step, $size, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue); # init of class specific stuff

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

#
# Other Public Methods
#

#
# Private methods 
#

sub _init {
   my ($self, $start, $step, $size, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue) = @_;

   $self->{start} = defined $start ? $start : &XDF::Constants::DEFAULT_VALUELIST_START;
   $self->{step} = defined $step ? $step : &XDF::Constants::DEFAULT_VALUELIST_STEP;
   $self->{size} = defined $size ? $size : &XDF::Constants::DEFAULT_VALUELIST_SIZE;

   $self->{noDataValue} = $noDataValue;
   $self->{infiniteValue} = $infiniteValue;
   $self->{infiniteNegativeValue} = $infiniteNegativeValue;
   $self->{notANumberValue} = $notANumberValue;
   $self->{overflowValue} = $overflowValue;
   $self->{underflowValue} = $underflowValue;

   $self->{values} = [];
  
   $self->_initValuesFromParams(); 

   # adds to ordered list of XML attributes
   $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _initValuesFromParams {
   my ($self) = @_;

   # now populate values list
   my $currentValue = $self->{start};
   my $step = $self->{step};
   my $size = $self->{size};

   for(my $i = 0; $i < $size; $i++) {
      my $thisValue = $self->_create_value_object($currentValue);
      $currentValue += $step;
      push @{$self->{values}}, $thisValue;
   }

}

sub _create_value_object {
   my ($self, $string_val, %attrib) = @_;

   my $valueObj = new XDF::Value();

   if (defined $string_val) {
      if (defined $self->{infiniteValue} && $self->{infiniteValue} eq $string_val)
      {
         $valueObj->setSpecial('infinite');
      }
      elsif (defined $self->{infiniteNegativeValue} && $self->{infiniteNegativeValue} eq $string_val)
      {
         $valueObj->setSpecial('infiniteNegative');
      }
      elsif (defined $self->{noDataValue} && $self->{noDataValue} eq $string_val)
      {
         $valueObj->setSpecial('noData');
      }
      elsif (defined $self->{notANumberValue} && $self->{notANumberValue} eq $string_val)
      {
         $valueObj->setSpecial('notANumber');
      }
      elsif (defined $self->{underflowValue} && $self->{underflowValue} eq $string_val)
      {
         $valueObj->setSpecial('underflow');
      }
      elsif (defined $self->{overflowValue} && $self->{overflowValue} eq $string_val)
      {
         $valueObj->setSpecial('overflow');
      }
      else
      {
         $valueObj->setValue($string_val);
      }
   }

   return $valueObj;
}

#
# Protected/Private Methods
#

sub _basicXMLWriter {
   my ($self, $fileHandle, $XMLDeclAttribs, $indent ) = @_;

   if(!defined $fileHandle) {
      carp "Can't write out object, filehandle not defined.\n";
      return;
   }

   $indent = "" unless defined $indent;

   my $spec = XDF::Specification->getInstance();
   my $isPrettyXDFOutput = $spec->isPrettyXDFOutput;

   print $fileHandle $indent if $isPrettyXDFOutput;

   print $fileHandle "<valueList start=\"".$self->{start}."\" step=\"".$self->{step}."\" size=\"".$self->{size}."\"";
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

=item new ($start, $step, $size, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue)

We use default values for start, step, and size unless they are defined. The other parameters are optional (e.g. noDataValue, infiniteValue, ...)and will remain undefined unless specified by the user.  

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

=item toXMLFileHandle ($fileHandle, $XMLDeclAttribs, $indent)

 

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
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Axis>, L< XDF::Parameter>, L< XDF::ValueListDelimitedList>, L< XDF::Value>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

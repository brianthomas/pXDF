
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

use XDF::GenericObject;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::GenericObject
@ISA = ("XDF::GenericObject");

# CLASS DATA
my $Class_XML_Node_Name = "valueList";
my @Class_XML_Attributes = qw (
                             Id
                             IdRef
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
my @Class_Attributes = qw ( 
                             values
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::GenericObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name of XDF::ValueListAlgorithm.
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes of XDF::ValueListAlgorithm.
# */
sub classAttributes { 
  \@Class_Attributes; 
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
   return $self->{Id};
}

# /** setValueListId
#     Set the valueListId attribute. 
# */
sub setValueListId {
   my ($self, $value) = @_;
   $self->{Id} = $value;
}

# /** getValueListIdRef 
# */
sub getValueListIdRef {
   my ($self) = @_;
   return $self->{IdRef};
}

# /** setValueListIdRef 
#     Set the valueListIdRef attribute. 
# */
sub setValueListIdRef {
   my ($self, $value) = @_;
   $self->{IdRef} = $value;
}

# /** getValues
# Return the list of values held in this object.
# */
sub getValues {
   my ($self) = @_;
   return $self->{Values};
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Other Public Methods
#

#
# Private methods 
#

sub _init {
   my ($self, $start, $step, $size, $noDataValue, $infiniteValue, $infiniteNegativeValue, $notANumberValue, $overflowValue, $underflowValue) = @_;

   $self->{Start} = defined $start ? $start : &XDF::Constants::DEFAULT_VALUELIST_START;
   $self->{Step} = defined $step ? $step : &XDF::Constants::DEFAULT_VALUELIST_STEP;
   $self->{Size} = defined $size ? $size : &XDF::Constants::DEFAULT_VALUELIST_SIZE;

   $self->{NoData} = $noDataValue;
   $self->{Infinite} = $infiniteValue;
   $self->{InfiniteNegative} = $infiniteNegativeValue;
   $self->{NotANumber} = $notANumberValue;
   $self->{Overflow} = $overflowValue;
   $self->{Underflow} = $underflowValue;

   $self->{Values} = [];
  
   $self->_initValuesFromParams(); 
}

sub _initValuesFromParams {
   my ($self) = @_;

   # now populate values list
   my $currentValue = $self->{Start};
   my $step = $self->{Step};
   my $size = $self->{Size};

   for(my $i = 0; $i < $size; $i++) {
      my $thisValue = $self->_create_value_object($currentValue);
      $currentValue += $step;
      push @{$self->{Values}}, $thisValue;
   }

}

sub _create_value_object {
   my ($self, $string_val, %attrib) = @_;

   my $valueObj = new XDF::Value();

   if (defined $string_val) {
      if (defined $self->{Infinite} && $self->{Infinite} eq $string_val)
      {
         $valueObj->setSpecial('infinite');
      }
      elsif (defined $self->{InfiniteNegative} && $self->{InfiniteNegative} eq $string_val)
      {
         $valueObj->setSpecial('infiniteNegative');
      }
      elsif (defined $self->{NoData} && $self->{NoData} eq $string_val)
      {
         $valueObj->setSpecial('noData');
      }
      elsif (defined $self->{NotANumber} && $self->{NotANumber} eq $string_val)
      {
         $valueObj->setSpecial('notANumber');
      }
      elsif (defined $self->{Underflow} && $self->{Underflow} eq $string_val)
      {
         $valueObj->setSpecial('underflow');
      }
      elsif (defined $self->{Overflow} && $self->{Overflow} eq $string_val)
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

sub toXMLFileHandle {
   my ($self, $fileHandle, $XMLDeclAttribs, $indent ) = @_;

   if(!defined $fileHandle) {
      carp "Can't write out object, filehandle not defined.\n";
      return;
   }

   $indent = "" unless defined $indent;

   my $spec = XDF::Specification->getInstance();
   my $isPrettyXDFOutput = $spec->isPrettyXDFOutput;

   print $fileHandle $indent if $isPrettyXDFOutput;

   print $fileHandle "<valueList start=\"",$self->{Start},
                    "\" step=\"",$self->{Step},
                    "\" size=\"",$self->{Size},"\"";

   print $fileHandle " valueListId=\"",$self->{Id},"\"" if (defined $self->{Id});
   print $fileHandle " valueListIdRef=\"",$self->{IdRef},"\"" if (defined $self->{IdRef});
   print $fileHandle " noDataValue=\"",$self->{NoData},"\"" if (defined $self->{NoData});
   print $fileHandle " infiniteValue=\"",$self->{Infinite},"\"" if (defined $self->{Infinite});
   print $fileHandle " infiniteNegativeValue=\"",$self->{InfiniteNegative},"\"" 
                       if (defined $self->{InfiniteNegative});
   print $fileHandle " notANumberValue=\"",$self->{NotANumber},"\"" if (defined $self->{NotANumber});
   print $fileHandle " overflowValue=\"",$self->{Overflow},"\"" if (defined $self->{Overflow});
   print $fileHandle " underflowValue=\"",$self->{Underflow},"\"" if (defined $self->{Underflow});
   print $fileHandle "/>";

   print $fileHandle "\n" if $isPrettyXDFOutput;

}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self, $val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# Modification History
#
# $Log$
# Revision 1.1  2001/07/13 21:38:14  thomas
# Initial Version
#
#
#

1;



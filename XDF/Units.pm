
# $Id$

package XDF::Units;

# /** COPYRIGHT
#    Units.pm Copyright (C) 2000 Brian Thomas,
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


use XDF::BaseObject;
use XDF::Log;
use XDF::Utility;
use XDF::Unit;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Unit_Devide_Symbol = '/';
my $Class_No_Unit_Child_Node_Name = "unitless";
my $Class_XML_Node_Name = "units";
my @Local_Class_XML_Attributes = qw (
                             factor
                             system
                             logarithm
                             unitList
                          );
my @Local_Class_Attributes = qw (
                             XMLNodeName
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

# /** classNoUnitChildNodeName
# Name of the child node to print in the toXMLFileHandle method when an 
# XDF::Units object contains NO XDF::Unit child objects.
# */
sub classNoUnitChildNodeName {
  $Class_No_Unit_Child_Node_Name;
}

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

# /** getFactor
# */
sub getFactor {
   my ($self) = @_;
   return $self->{factor};
}

# /** setFactor
#     Set the factor attribute. 
# */
sub setFactor {
   my ($self, $value) = @_;
   $self->{factor} = $value;
}

# /** getSystem
# */
sub getSystem {
   my ($self) = @_;
   return $self->{system};
}

# /** setSystem
#     Set the system attribute. 
# */
sub setSystem {
   my ($self, $value) = @_;
   $self->{system} = $value;
}

# /** getLogarithm
# */
sub getLogarithm {
   my ($self) = @_;
   return $self->{logarithm};
}

# /** setLogarithm
#     Set the logarithm attribute. 
# */
sub setLogarithm {
   my ($self, $value) = @_;
   unless (&XDF::Utility::isValidLogarithm($value)) { 
     error("Cant set units logarithm to $value, not allowed \n"); 
     return;
   }
   $self->{logarithm} = $value;
}

# /** getUnitList
# */
sub getUnitList {
   my ($self) = @_;
   return $self->{unitList};
}

# /** setUnitList
#     Set the unitList attribute. 
# */
sub setUnitList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{unitList} = \@list;
}

# /** getXMLNodeName
# */
sub getXMLNodeName {
   my ($self) = @_;
   return $self->{XMLNodeName};
}

# /** setXmlNodeName
# Change the xml node name for this object.
# */ 
sub setXMLNodeName {
  my ($self, $val) = @_;
  $self->{XMLNodeName} = $val;
}

# assemble all of the all the units in my lists and return it as a string.
# Yes, its flakey. I put here as convenience method.
sub getValue {
  my ($self) = @_;

  my $string;

  $string .= $self->getFactor() if defined $self->getFactor();

  foreach my $unitObj (@{$self->{unitList}}) {
    $string .= $unitObj->getValue();
    $string .= "**" . $unitObj->getPower() if ref($unitObj) !~ m/Unitless/ and defined $unitObj->getPower();
    $string .= " ";
  }

  chomp $string if $string;

  return $string;
}

#/** getUnits
# Convience method. Returns an Array of units held within this object. 
# */
sub getUnits {
  my ($self) = @_;
  return @{$self->{unitList}};
}

#
# Other Public Methods
#

# /** isUnitless
# Returns true ("1") if this objects lacks any child unit objects.
# */
sub isUnitless {
  my ($self) = @_;

  return 1 if #${$self->{unitList}} < 0;
  return 0;
}

# /** makeUnitless
# Releases all child unit objects, thus making this a "unitless" Units 
# object.
# */
sub makeUnitless {
  my ($self) = @_;
  $self->{unitList} = [];
}

#/** addUnit
# Add an XDF::Unit Object to the list of units within this XDF::Units object.
# RETURNS : 1 on success, 0 on failure.
#*/
sub addUnit {
  my ($self, $unitObj) = @_;

  return 0 unless defined $unitObj && ref $unitObj;

  # add it to our list
  push @{$self->{unitList}}, $unitObj;

  return 1;

}

#/** removeUnit
# 
# RETURNS : 1 on success, 0 on failure.
#*/
sub removeUnit {
  my ($self, $what) = @_;
  return $self->_remove_from_list($what, $self->{unitList}, 'unitList');
}

#
# Protected/Private Methods
#

sub _basicXMLWriter {
  my ($self, $fileHandle, $indent, $dontCloseNode ) = @_;

  if ($#{$self->{unitList}} > -1) { 
     $self->SUPER::_basicXMLWriter($fileHandle, $indent, $dontCloseNode);
  } else {
     $self->SUPER::_basicXMLWriter($fileHandle, $indent, 
                                   $dontCloseNode, $Class_No_Unit_Child_Node_Name);
  }
                                # $dontCloseNode, $self->{XMLNodeName}, 
                                #$Class_No_Unit_Child_Node_Name);
}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->{unitList} = [];
  $self->{XMLNodeName} = $Class_XML_Node_Name;
  
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}


1;


__END__

=head1 NAME

XDF::Units - Perl Class for Units

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::Units inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Units.

=over 4

=item classNoUnitChildNodeName (EMPTY)

Name of the child node to print in the toXMLFileHandle method when an XDF::Units object contains NO XDF::Unit child objects.  

=item classXMLNodeName (EMPTY)

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Units.

=over 4

=item getFactor (EMPTY)

 

=item setFactor ($value)

Set the factor attribute.  

=item getSystem (EMPTY)

 

=item setSystem ($value)

Set the system attribute.  

=item getLogarithm (EMPTY)

 

=item setLogarithm ($value)

Set the logarithm attribute.  

=item getUnitList (EMPTY)

 

=item setUnitList ($arrayRefValue)

Set the unitList attribute.  

=item getXMLNodeName (EMPTY)

 

=item setXMLNodeName ($val)

 

=item getValue (EMPTY)

 

=item getUnits (EMPTY)

Convience method. Returns an Array of units held within this object.  

=item addUnit ($unitObj)

Add an XDF::Unit Object to the list of units within this XDF::Units object. RETURNS : 1 on success, 0 on failure.  

=item removeUnit ($what)

RETURNS : 1 on success, 0 on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Units inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Units inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::Utility>, L<XDF::Unit>

=back

=head1 AUTHOR

 

=cut


# $Id$

# /** COPYRIGHT
#    Conversion.pm Copyright (C) 2003 Brian Thomas,
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
# An XDF::Conversion object holds mathematical equations.
# Conversion allows expression of an algorithm to be applied to whatever "value"
# or set of values is held by the parent node. In the case of an array or field
# it is the data. In the case of an axis, it applies to the meaning of the axis 
# indice values.
#@
# One can string together a sequence of operations to be applied to the 
# stored data values. Applications would have the ability to optionally 
# apply this and to invert it when storing. The sense of the algorithm is
# that familiar to old HP users: RPN ("Reverse Polish Notation").
# For example the algorithm " 10 ^ (50 * ln (45 x + 89)) " would be written 
# in the XML as:
#@
# <conversion>
#    <multiply>45</multiply>
#    <add>89</add>
#    <naturalLogarithm/>
#    <multiply>50</multiply>
#    <exponentOn>10</exponentOn>
# </conversion>
#@
# where each of the child nodes of conversion specifies a "component" of the 
# conversion. Each of these components are objects in their own right and are
# "owned" by the parent conversion.
#@ 
# Convienient evaluation of any particular value by a conversion may be done using
# the "evaluate" method of the class, see the synopsis for an example.
# */

# /** SYNOPSIS
#
#  # create a conversion for the equation " (10 * x) + 1"
#  my $conversion = new XDF::Conversion();
#
#  # add in components that make our equation
#  $conversion->addComponent(new XDF::Multiply("10"));
#  $conversion->addComponent(new XDF::Add("1"));
#
#  my $value = 1;
#  my $new_value = $conversion->evaluate($value);
#
#  # prints out "11"
#  print STDOUT "my converted value is :",$new_value,"\n"; 
#
# */

# /** SEE ALSO
# */

package XDF::Conversion;

use XDF::BaseObject;
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "conversion";
my @Local_Class_XML_Attributes = qw (
                             componentList
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
# This method returns the class node name of XDF::Conversion.
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

sub getComponents {
  my ($self) = @_;
  return $self->{componentList};
}

#
# Other Public Methods
#

# /** addComponent 
# Insert an XDF::Component object into this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Component> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Component object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addComponent {
  my ($self, $componentObj ) = @_;

  return 0 unless defined $componentObj && ref($componentObj);

  # add the componenteter to the list
  push @{$self->{componentList}}, $componentObj;

  return 1;
}

# /** removeComponent 
# Remove an XDF::Component object from the list of XDF::Components
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeComponent {
   my ($self, $indexOrObjectRef) = @_;
   return $self->_remove_from_list($indexOrObjectRef, $self->{componentList}, 'componentList');
}

# /** evaluate
# Evaluate a value using this conversion object. Returns the coverted
# value.
# */
sub evaluate {
  my ($self, $value) = @_;

  # step thru all the components and evaluate with each in turn
  foreach my $component (@{$self->{componentList}}) {
     $value = $component->evaluate($value);
  }
  return $value;
}

#
# Private methods 
#

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init();

  $self->{componentList} = [];

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

XDF::Conversion - Perl Class for Conversion

=head1 SYNOPSIS


  # create a conversion for the equation " (10 * x) + 1"
  my $conversion = new XDF::Conversion();

  # add in components that make our equation
  $conversion->addComponent(new XDF::Multiply("10"));
  $conversion->addComponent(new XDF::Add("1"));

  my $value = 1;
  my $new_value = $conversion->evaluate($value);

  # prints out "11"
  print STDOUT "my converted value is :",$new_value,"\n"; 



...

=head1 DESCRIPTION

 An XDF::Conversion object holds mathematical equations.  Conversion allows expression of an algorithm to be applied to whatever "value" or set of values is held by the parent node. In the case of an array or field it is the data. In the case of an axis, it applies to the meaning of the axis  indice values.  
 One can string together a sequence of operations to be applied to the  stored data values. Applications would have the ability to optionally  apply this and to invert it when storing. The sense of the algorithm is that familiar to old HP users: RPN ("Reverse Polish Notation").  For example the algorithm " 10 ^ (50 * ln (45 x + 89)) " would be written  in the XML as: 
 <conversion>    <multiply>45</multiply>    <add>89</add>    <naturalLogarithm/>    <multiply>50</multiply>    <exponentOn>10</exponentOn> </conversion> 
 where each of the child nodes of conversion specifies a "component" of the  conversion. Each of these components are objects in their own right and are "owned" by the parent conversion.   
 Convienient evaluation of any particular value by a conversion may be done using the "evaluate" method of the class, see the synopsis for an example. 

XDF::Conversion inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Conversion.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::Conversion.  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Conversion.

=over 4

=item getComponents (EMPTY)

 

=item addComponent ($componentObj)

Insert an XDF::Component object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Component> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Component object. RETURNS : 1 on success, 0 on failure.  

=item removeComponent ($indexOrObjectRef)

Remove an XDF::Component object from the list of XDF::Componentsheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item evaluate ($value)

Evaluate a value using this conversion object. Returns the covertedvalue.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Conversion inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Conversion inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<getXMLAttribute>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::Log>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

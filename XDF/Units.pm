
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
use XDF::Utility;
use XDF::Unit;
use Carp;

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
     carp "Cant set units logarithm to $value, not allowed \n"; 
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

sub toXMLFileHandle {
  my ($self, $fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode ) = @_;
  $self->SUPER::toXMLFileHandle($fileHandle, $XMLDeclAttribs, $indent, 
                                $dontCloseNode, $self->{XMLNodeName}, 
                                $Class_No_Unit_Child_Node_Name);
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

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->{unitList} = [];
  $self->{XMLNodeName} = $Class_XML_Node_Name;
  
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# Modification History
#
# $Log$
# Revision 1.14  2001/08/13 20:56:37  thomas
# updated documentation via utils/makeDoc.pl for the release.
#
# Revision 1.13  2001/08/13 19:50:16  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.12  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.11  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.10  2001/06/21 17:33:43  thomas
# added logarithm attribute
#
# Revision 1.9  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.8  2001/04/17 18:51:16  thomas
# properly calling superclass init now
#
# Revision 1.7  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.6  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.5  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

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

=item toXMLFileHandle ($fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode)

 

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
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::Utility>, L<XDF::Unit>

=back

=head1 AUTHOR

 

=cut

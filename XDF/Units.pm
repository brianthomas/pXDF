
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
my @Class_XML_Attributes = qw (
                             factor
                             system
                             unitList
                          );
my @Class_Attributes = qw (
                             XMLNodeName
                          );

# push in XML attributes to class attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

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
  $Class_XML_Node_Name; 
}

sub classAttributes { 
  \@Class_Attributes; 
}

#
# Get/Set Methods
#

# /** getFactor
# */
sub getFactor {
   my ($self) = @_;
   return $self->{Factor};
}

# /** setFactor
#     Set the factor attribute. 
# */
sub setFactor {
   my ($self, $value) = @_;
   $self->{Factor} = $value;
}

# /** getSystem
# */
sub getSystem {
   my ($self) = @_;
   return $self->{System};
}

# /** setSystem
#     Set the system attribute. 
# */
sub setSystem {
   my ($self, $value) = @_;
   $self->{System} = $value;
}

# /** getUnitList
# */
sub getUnitList {
   my ($self) = @_;
   return $self->{UnitList};
}

# /** setUnitList
#     Set the unitList attribute. 
# */
sub setUnitList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{UnitList} = \@list;
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

  foreach my $unitObj (@{$self->{UnitList}}) {
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
  return @{$self->{UnitList}};
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

sub addUnit {
  my ($self, $info ) = @_;

  return unless defined $info;

  my $unitObj;

  if (ref $info && $info =~ m/XDF::Unit/) {
    $unitObj = $info;
  } else {
    $unitObj = new XDF::Unit($info);
  }

  # add it to our list
  push @{$self->{UnitList}}, $unitObj;

  return $unitObj;

}

sub removeUnit {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->{UnitList}, 'unitList');
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
  $self->{UnitList} = [];
  $self->{XMLNodeName} = $Class_XML_Node_Name;
}

# Modification History
#
# $Log$
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

 

=item classAttributes (EMPTY)

 

=item getXMLAttributes (EMPTY)

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

=item getUnitList (EMPTY)

 

=item setUnitList ($arrayRefValue)

Set the unitList attribute.  

=item getXMLNodeName (EMPTY)

 

=item setXMLNodeName ($val)

 

=item getValue (EMPTY)

 

=item getUnits (EMPTY)

Convience method. Returns an Array of units held within this object.  

=item addUnit ($info)

 

=item removeUnit ($what)

 

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
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::Unit>

=back

=head1 AUTHOR

 

=cut

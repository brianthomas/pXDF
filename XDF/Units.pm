
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
my @Class_Attributes = qw (
                             factor
                             system
                             unitList
                             _xmlNodeName
                          );

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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init { 
  my ($self) = @_; $self->unitList([]); 
  $self->_xmlNodeName($Class_XML_Node_Name);
}

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
  push @{$self->unitList()}, $unitObj;

  return $unitObj;

}

sub removeUnit {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->unitList(), 'unitList');
}

# /** setXmlNodeName
# Change the xml node name for this object.
# Returns the new name if successfull, undef if it fails.
# */ 
sub setXMLNodeName {
  my ($self, $val) = @_;
  return unless defined $val;
  $self->_xmlNodeName($val);
}

# assemble all of the all the units in my lists and return it as a string.
# Yes, its flakey. I put here as convenience method.
sub value {
  my ($self) = @_;

  my $string;

  $string .= $self->factor() if defined $self->factor();

  foreach my $unitObj (@{$self->unitList()}) {
    $string .= $unitObj->value();
    $string .= "**" . $unitObj->power() if ref($unitObj) !~ m/Unitless/ and defined $unitObj->power();
    $string .= " ";
  }

  chomp $string if $string;

  return $string;
}

sub toXMLFileHandle {
  my ($self, $fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode ) = @_;
  $self->SUPER::toXMLFileHandle($fileHandle, $XMLDeclAttribs, $indent, 
                                $dontCloseNode, $self->_xmlNodeName, 
                                $Class_No_Unit_Child_Node_Name);
}

sub getUnits {
  my ($self) = @_;
  return @{$self->unitList};
}

# Modification History
#
# $Log$
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

XDF::Units inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Units.

=over 4

=item classNoUnitChildNodeName (EMPTY)

Name of the child node to print in the toXMLFileHandle method when an XDF::Units object contains NO XDF::Unit child objects.  

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item factor

 

=item system

 

=item unitList

 

=back

=head2 OTHER Methods

=over 4

=item addUnit ($info)



=item removeUnit ($what)



=item setXMLNodeName ($val)



=item value (EMPTY)



=item toXMLFileHandle ($dontCloseNode, $indent, $XMLDeclAttribs, $fileHandle)



=item getUnits (EMPTY)



=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::Units inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFile>.

=back



=over 4

XDF::Units inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back

=back

=head1 SEE ALSO

L<XDF::BaseObject>, L<XDF::Unit>

=back

=head1 AUTHOR



=cut


# $Id$

package XDF::NotationNode;

# /** COPYRIGHT
#    NotationNode.pm Copyright (C) 2002 Brian Thomas,
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
#
# The NotationNode class is nothing more than a simple object that holds information
#  concerning the notations within a Doctype.
# */

#/** SYNOPSIS
#
# */

use Carp;

use XDF::BaseObject;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = '!NOTATION'; 
my @Local_Class_Attributes = qw (
                             name
                             base
                             systemId
                             publicId
                          );

my @Local_Class_XML_Attributes = qw (
                          );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
#push @Class_XML_Attributes, @{&XDF::BaseObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FloatDataFormat. 
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

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# 
# Get/Set Methods
#

# /** getBase
# */
sub getBase {
   my ($self) = @_;
   return $self->{base};
}

# /** setBase
#     Set the entity base attribute. 
# */
sub setBase {
   my ($self, $value) = @_;
   $self->{base} = $value;
}

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $self->{name};
}

# /** setName
#     Set the name attribute. 
# */
sub setName {
   my ($self, $value) = @_;
   $self->{name} = $value;
}

# /** getPublicId
#  */
sub getPublicId {
   my ($self) = @_;
   return $self->{publicId};
}

# /** setPublicId
#     Set the pubId attribute. 
#  */
sub setPublicId {
   my ($self, $value) = @_;
   $self->{publicId} = $value;
}

# /** getSystemId
#  */
sub getSystemId {
   my ($self) = @_;
   return $self->{systemId};
}

# /** setSystemId
#     Set the system Id attribute. 
#  */
sub setSystemId {
   my ($self, $value) = @_;
   $self->{systemId} = $value;
}

#
# Private
# 

# empty,nothing happens here
sub _init { }

sub _basicXMLWriter {
  my ($self, $fileHandle, $indent, $dontCloseNode, 
      $newNodeNameString, $noChildObjectNodeName) = @_;

  if(!defined $fileHandle) {
    carp "Can't write out object, filehandle not defined.\n";
    return;
  }

  $indent = "" unless defined $indent;

  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;

  print $fileHandle $indent if $niceOutput;

  my $sysId = $self->getSystemId();
  my $pubId = $self->getPublicId();

  print $fileHandle "<". $self->classXMLNodeName . " " . $self->getName();

  print $fileHandle " PUBLIC \"$pubId\"" if (defined $pubId); 
  print $fileHandle " SYSTEM \"$sysId\"" if (defined $sysId); 

  print $fileHandle ">";

  return $self->classXMLNodeName;


}


1;


__END__

=head1 NAME

XDF::NotationNode - Perl Class for NotationNode

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 The NotationNode class is nothing more than a simple object that holds information  concerning the notations within a Doctype. 

XDF::NotationNode inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::NotationNode.

=over 4

=item classXMLNodeName (EMPTY)

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::NotationNode.

=over 4

=item getBase (EMPTY)

 

=item setBase ($value)

Set the entity base attribute.  

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getPublicId (EMPTY)

 

=item setPublicId ($value)

Set the pubId attribute.  

=item getSystemId (EMPTY)

 

=item setSystemId ($value)

Set the system Id attribute.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::NotationNode inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::NotationNode inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

package XDF::DocumentType;

# /** COPYRIGHT
#    DocumentType.pm Copyright (C) 2002 Brian Thomas,
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
# The DocumentType class is nothing more than a simple object that holds information
#  concerning the href and its associated (XML) ENTITY reference.
# */

#/** SYNOPSIS
#
# */

use Carp;

use XDF::BaseObject;
use XDF::NotationNode;
use XDF::Constants;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = '!DOCTYPE'; 
my $XDF_ROOT_NODE_NAME = &XDF::Constants::XDF_ROOT_NODE_NAME;
my @Local_Class_Attributes = qw (
                             owner
                          );

my @Local_Class_XML_Attributes = qw (
                             publicId
                             systemId
                             notationList
                          );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
#push @Class_XML_Attributes, @{&XDF::GenericObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::GenericObject::getClassAttributes};

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

# special constructor

# only allow Array objects to create locators
sub new { 
  my ($proto, $ownerXDF) = @_;

  unless (ref $ownerXDF eq 'XDF::XDF') {
    croak "Error: $proto requires an XDF object reference\n";
  }

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($ownerXDF); # init of class specific stuff

  return $self;
}

# 
# Get/Set Methods
#

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $XDF_ROOT_NODE_NAME;
}

# /** getPublicId
#  */
sub getPublicId {
   my ($self) = @_;
   return $self->{publicId};
}

# /** setPublicId
#     Set the publicId attribute. 
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
#     Set the systemId attribute. 
#  */
sub setSystemId {
   my ($self, $value) = @_;
   $self->{systemId} = $value;
}

#/** getEntities 
#  returns a list reference of the entities in this XDF document 
#*/
sub getEntities {
  my ($self) = @_;
  my @objList = @{$self->getOwner()->_find_All_child_Href_Objects()};
  return \@objList;
}

# /** getNotations 
# returns a list reference of Notation entities held in this documentType 
# */
sub getNotations {
  my ($self) = @_;
  return $self->{notationList};
}

# /** getNotations 
#  get the owner XDF object of this documentType.
# */
sub getOwner () {
  my ($self) = @_;
  return $self->{Owner};
}


#
# Other Public methods
#

# /** addNotation 
# Add a notationNode to this documentType.
# */
sub addNotation {
   my ($self, $notationNode) = @_;
   push @{$self->{notationList}}, $notationNode;
}

# /** removeNotation 
# remove a notation from this documentType
# */
sub removeNotation {
   my ($self, $notationNode) = @_;
   return $self->_remove_from_list($notationNode, $self->{notationList}, 'notationList');
}

#
# Private
# 

sub _init {
  my ($self, $owner) = @_;

  $self->SUPER::_init();

  # set defaults
  $self->{Owner} = $owner;
  $self->{notationList} = []; 
    
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);
  
}

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
  my $more_indent = $spec->getPrettyXDFOutputIndentation;
  my $next_indent = $indent . $more_indent;

  print $fileHandle $indent if $niceOutput;

  my $systemId = $self->getSystemId();
  my $publicId = $self->getPublicId();

  print $fileHandle "<". $self->classXMLNodeName . " " . $self->getName();

  print $fileHandle " PUBLIC \"$publicId\"" if ($publicId); 
  print $fileHandle " SYSTEM \"$systemId\"" if ($systemId); 


  # any entities and notations need to now be written.
  my @entityObjList = @{$self->getEntities()};
  my @notationObjList = @{$self->getNotations()};

  # if we have any, then we must print out
  if ($#entityObjList > -1) {

     print $fileHandle " [";
     print $fileHandle "\n" if $niceOutput;

     # whip thru the list of entity objects
     foreach my $entityObj (@entityObjList) {
        $entityObj->toXMLFileHandle($fileHandle, $next_indent);
     }

     # we need to "auto-magically" add the xdf notation node, if it doesnt exist in the list
     # BUT there are Href entity objects
     if ($#notationObjList == -1)
     {
        warn "xdf notation missing!, adding new XDF::NotationNode to DocumentType object:$self. You should double-check entities for correct/missing NDATA!\n";
        my $xdfNotation = new XDF::NotationNode();
        $xdfNotation->setName(&XDF::Constants::XDF_NOTATION_NAME);
        $xdfNotation->setPublicId(&XDF::Constants::XDF_NOTATION_PUBLICID);
        $self->addNotation($xdfNotation);

        # have to re-update
        @notationObjList = @{$self->getNotations()};
     }

  }

  # print notations if we have any
  if ($#notationObjList > -1) {

     if ($#entityObjList == -1)
     {
        print $fileHandle " [";
        print $fileHandle "\n" if $niceOutput;
     }

     foreach my $notationObj (@notationObjList) {
        $notationObj->toXMLFileHandle($fileHandle, $next_indent);
     }

  }

  # close node
  if ($#entityObjList > -1 || $#notationObjList > -1)
  {
     print $fileHandle "]";
  }
  print $fileHandle ">";

  return $self->classXMLNodeName;

}


1;


__END__

=head1 NAME

XDF::DocumentType - Perl Class for DocumentType

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 The DocumentType class is nothing more than a simple object that holds information  concerning the href and its associated (XML) ENTITY reference. 

XDF::DocumentType inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DocumentType.

=over 4

=item classXMLNodeName (EMPTY)

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=item new ($ownerXDF)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DocumentType.

=over 4

=item getName (EMPTY)

 

=item getPublicId (EMPTY)

 

=item setPublicId ($value)

Set the publicId attribute.  

=item getSystemId (EMPTY)

 

=item setSystemId ($value)

Set the systemId attribute.  

=item getEntities (EMPTY)

returns a list reference of the entities in this XDF document  

=item getNotations (EMPTY)

returns a list reference of Notation entities held in this documentType get the owner XDF object of this documentType.  

=item getOwner (EMPTY)

 

=item addNotation ($notationNode)

Add a notationNode to this documentType.  

=item removeNotation ($notationNode)

remove a notation from this documentType 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::DocumentType inherits the following instance (object) methods of L<XDF::GenericObject>:
B<clone>, B<update>.

=back



=over 4

XDF::DocumentType inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObject>, L<XDF::NotationNode>, L<XDF::Constants>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

# /** COPYRIGHT
#    XMLElementNode.pm Copyright (C) 2000 Brian Thomas,
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
# An XDF::XMLElementNode object contains node information for XML element nodes which are
# held inside the an XDF structure or array.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Array
# XDF::Structure
# */

package XDF::XMLElementNode;

use XML::DOM;
use XDF::Constants;
use XDF::Specification;
use Carp;

use strict;
use integer;

#use vars qw ($AUTOLOAD @ISA);
use vars qw { $AUTOLOAD @ISA };

# inherits from XML::DOM::Attr
@ISA = ("XML::DOM::Element"); 

# CLASS DATA
my $Class_XML_Node_Name = ""; # doesnt have one!! 
my @Class_Attributes = (); # none!, we should probably fix this 

# /** getClassAttributes
# This method returns a list reference containing the names
# of the class attributes of XDF::XMLElementNode.
# Note that for XDF::XMLElementNode this is an empty list. Any attributes
# that this class has are inherited from XML::DOM::Element, a class
# outside of the XDF package.
# */
sub getClassAttributes { 
  return \@Class_Attributes; 
}

#/** new
# Creates a new XMLElementNode. $tagName variable must be specified, 
# but $ownerDoc is not needed.
#*/
sub new {
   my ($proto, $tagName, $ownerDoc) = @_;

   die "XDF::XMLElementNode::new requires you define the value of tagName.\n"
       unless defined $tagName and $tagName ne "";

   my $class = ref ($proto) || $proto;

   # Well we have to declare a document. feh. Its not 
   # good that we have to use FULL DOM Document, too bad DocumentFragment 
   # wont do, as its more lightweight. Still, we can just reference a single
   # declared document from the constants class as a memory saver.
   #$ownerDoc = new XML::DOM::Document() unless defined $ownerDoc;
   $ownerDoc = &XDF::Constants::getInternalDOMDocument unless defined $ownerDoc;
   my $self = XML::DOM::Document::createElement($ownerDoc, $tagName); 
   bless ($self, $class); # re-bless into this class 

   return $self;
}

# need to override this method in BaseObject (via GenericObject)
sub AUTOLOAD { # PRIVATE 
  # do nothing
}

# /** getXMLElementNodeList 
# Similar to the getChildNodes method except that it only returns
# the children which are of type XMLElementNode. 
# */
sub getXMLElementNodeList {
  my ($self) = @_;
 
  my @list;
  foreach my $child ($self->getChildNodes()) {
     next unless ref($child) eq 'XDF::XMLElementNode'; 
     push @list, $child;
  }

  return \@list;
}

# /** addXMLElementNode
# Aliased to the appendChild method. 
# Returns : 1 on success , 0 on failure.
# */
sub addXMLElementNode {
  my ($self, $xmlElementObjRef) = @_;

   return 0 unless defined $xmlElementObjRef && ref $xmlElementObjRef;

   # change owner document to that of this one
   $xmlElementObjRef->setOwnerDocument($self->getOwnerDocument);
   $self->appendChild($xmlElementObjRef);

   return 1;
}

# /** removeXMLElementNode
# Aliased to the removeChild method. Will only remove child
# XMLElementNode nodes. 
# Returns : 1 on success , 0 on failure.
# */
sub removeXMLElementNode {
   my ($self, $xmlElementObjRef) = @_;
   return 0 unless defined $xmlElementObjRef && ref($xmlElementObjRef);
   $self->removeChild($xmlElementObjRef);
   return 1;
}

# /** setXMLElementNodeList 
# May reset the childNode list to that passed. 
# This method will reject any $listRef which is undefined. 
# This method will not append any non-XDF::XMLElementNode objects 
# in the list.
# */
sub setXMLElementNodeList {
  my ($self, $listRef) = @_;

  return unless defined $listRef;

  # remove old nodes
  foreach my $child ($self->getChildNodes) {
    $self->removeChild($child);
  }

  # add in new list
  foreach my $newchild (@{$listRef}) {
     next unless ref($newchild) eq 'XDF::XMLElementNode';
     $self->appendChild($newchild);
  }

}

# 
# SET/GET Methods
# 

# /** getCData {
# A short cut method. Finds all of the child TEXT_NODEs and returns
# concatenated value of all as a string.
# */
sub getCData {
   my ($self) = @_;
   # concat all child Text Nodes together

   my $CDATA_string; 
   foreach my $childNode ($self->getChildNodes) {
      if ($childNode->getNodeTypeName eq 'TEXT_NODE') {
          $CDATA_string .= $childNode->getNodeValue;
      }
   }

   return $CDATA_string;
}

# /** appendCData
#     Append character data into this node. This is a short cut method,
#   it actually creates a child TEXT_NODE to hold the CDATA and then 
#   appends it as a child of the XMLElementNode.
# */
sub appendCData {
   my ($self, $text) = @_;

   return unless defined $text;

   my $textNode = $self->getOwnerDocument->createTextNode($text);
   $self->appendChild($textNode);
}

# /** setCData
#     Set the character data of this node. This is a short cut method,
#   it actually deletes all existing child TEXT_NODES and then creates 
#   a new, single child TEXT_NODE to hold the CDATA within the element.
# */
sub setCData {
   my ($self, $text) = @_;

   foreach my $childNode ($self->getChildNodes) {
      if ($childNode->getNodeTypeName eq 'TEXT_NODE') {
         $self->removeChild($childNode);
         $childNode->dispose; # free memory 
      }
   }

   return unless defined $text;

   my $textNode = $self->getOwnerDocument->createTextNode($text);
   $self->appendChild($textNode);
}

sub getXMLAttributes {
  my ($self) = @_;

   die "Error: getXMLAttributes not implemented for this class yet ($self) \n";
}


#
# Other Public Methods
#

#/** toXMLFileHandle
#*/
sub toXMLFileHandle {
   my ($self, $fileHandle, $indent) = @_;

   $indent = "" unless defined $indent;
   my $spec = XDF::Specification->getInstance();

   my $Pretty_XDF_Output = $spec->isPrettyXDFOutput;
   my $Pretty_XDF_Output_Indent = $spec->getPrettyXDFOutputIndentation;

   # open the node
   print $fileHandle $indent if $Pretty_XDF_Output;
   print $fileHandle "<" . $self->getTagName();


   # print attribs
   #for ($self->{parentElement}->getAttributes->getValues) {
   for ($self->getAttributes->getValues) {
      print $fileHandle " ".$_->getName."=\"".$_->getValue."\"";
   }

   # print child nodes OR CDATA 
   my @childXMLElementNodes; # generic XML nodes we need to print 
   @childXMLElementNodes = @{$self->getXMLElementNodeList}; # if defined $self->getXMLElementNodeList;
   if (defined $self->getCData
        || $#childXMLElementNodes > -1
     )
   {

     # close the opening node decl 
     print $fileHandle ">";

     # print the CData (or child nodes)
     if (defined $self->getCData) {
        print $fileHandle $self->getCData;
     }

     for (@childXMLElementNodes) {
        print $fileHandle "\n" if $Pretty_XDF_Output;
        $_->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indent);
        print $fileHandle $indent if $Pretty_XDF_Output;
     }

     # closing node decl 
     print $fileHandle "</". $self->getTagName .">";

   } else {
      # just close the node
      print $fileHandle "/>";
   }

   print $fileHandle "\n" if $Pretty_XDF_Output;

}

#
# Private methods 
#

1;


__END__

=head1 NAME

XDF::XMLElementNode - Perl Class for XMLElementNode

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::XMLElementNode object contains node information for XML element nodes which are held inside the an XDF structure or array. 

XDF::XMLElementNode inherits class and attribute methods of L<XML::DOM::Element>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::XMLElementNode.

=over 4

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::XMLElementNode. Note that for XDF::XMLElementNode this is an empty list. Any attributesthat this class has are inherited from XML::DOM::Element, a classoutside of the XDF package.  

=item new ($tagName, $ownerDoc)

Creates a new XMLElementNode. $tagName variable must be specified, but $ownerDoc is not needed.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::XMLElementNode.

=over 4

=item getXMLElementNodeList (EMPTY)

Similar to the getChildNodes method except that it only returnsthe children which are of type XMLElementNode.  

=item addXMLElementNode ($xmlElementObjRef)

Aliased to the appendChild method. Returns : 1 on success , 0 on failure.  

=item removeXMLElementNode ($xmlElementObjRef)

Aliased to the removeChild method. Will only remove childXMLElementNode nodes. Returns : 1 on success , 0 on failure.  

=item setXMLElementNodeList ($listRef)

May reset the childNode list to that passed. This method will reject any $listRef which is undefined. This method will not append any non-XDF::XMLElementNode objects in the list.  

=item getCData (EMPTY)

 

=item appendCData ($text)

Append character data into this node. This is a short cut method,it actually creates a child TEXT_NODE to hold the CDATA and then appends it as a child of the XMLElementNode.  

=item setCData ($text)

Set the character data of this node. This is a short cut method,it actually deletes all existing child TEXT_NODES and then creates a new, single child TEXT_NODE to hold the CDATA within the element.  

=item getXMLAttributes (EMPTY)

 

=item toXMLFileHandle ($fileHandle, $indent)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L< XDF::Structure>, L<XDF::Constants>, L<XDF::Specification>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

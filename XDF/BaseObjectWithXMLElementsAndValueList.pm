# $Id$

# /** COPYRIGHT
#    BaseObjectWithXMLElementsAndValueList.pm Copyright (C) 2000 Brian Thomas,
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
# A 'super base object' which can hold XMLElements.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Array
# XDF::Structure
# */

package XDF::BaseObjectWithXMLElementsAndValueList;

use XDF::BaseObjectWithXMLElements;
use XDF::BaseObjectWithValueList;
use Carp;

use strict;
use integer;

use vars qw {@ISA %field};

# inherits from XDF::BaseObjectWithXMLElements and
# XDF::BaseObjectWithValueList
# order here sets precedence on which overloaded method is called.
@ISA = (
         "XDF::BaseObjectWithXMLElements", 
         "XDF::BaseObjectWithValueList",
       );

# CLASS DATA
my @Class_Attributes = qw (
                          );

my @Class_XML_Attributes = qw (
                              );

# add in super class XML attributes
#push @Class_XML_Attributes, @{&XDF::BaseObject::classXMLAttributes};

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElements::classAttributes};
push @Class_Attributes, @{&XDF::BaseObjectWithValueList::classAttributes};

# Initalization - set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this object;
#  This method takes no arguments may not be changed. 
# */
sub classAttributes {
  return \@Class_Attributes;
}

sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#/** toXMLFileHandle
#
#*/
sub toXMLFileHandle {
  my ($self, $fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName, $isRootNode  ) = @_;

  if(!defined $fileHandle) {
    carp "Can't write out object, filehandle not defined.\n";
    return;
  }

  $indent = "" unless defined $indent;

  my $spec = XDF::Specification->getInstance();
  my $Pretty_XDF_Output = $spec->isPrettyXDFOutput;
  my $Pretty_XDF_Output_Indentation = $spec->getPrettyXDFOutputIndentation;

  if (defined $XMLDeclAttribs) {
     $indent = "";
     # write the XML && DOCTYPE decl
     $self->_write_XML_decl_to_file_handle($fileHandle, $XMLDeclAttribs, $spec);
  }

  # We need to invoke a little bit of Voodoo to keep the DTD happy; 
  # the first structure node is always called by the root node name
  # also, we may have nodes (w/o attributes) that just hold other nodes.
  my $nodename = $self->classXMLNodeName;
  $nodename = $newNodeNameString if defined $newNodeNameString;

  # open this node, print its attributes
  if ($nodename) {
      print $fileHandle $indent if $Pretty_XDF_Output;
      $nodename = $spec->getXDFRootNodeName if ( (defined $XMLDeclAttribs || $isRootNode)
                                           && $self =~ m/XDF::Structure/);
      print $fileHandle "<" . $nodename;
  }

  my ($attribListRef, $objListRef, $objPCDATA) = $self->_getXMLInfo();
  my @objList = @{$objListRef};

  # print out attributes
  $self->_printAttributes($fileHandle, $attribListRef);

  # now, does this object own others? if so print them
  my @childXMLElements; # generic XML nodes we need to print 
  @childXMLElements = @{$self->{_childXMLElementList}} if defined $self->{_childXMLElementList};
  if ( $#objList > -1
       or $#childXMLElements > -1
       or defined $objPCDATA
       or defined $noChildObjectNodeName)
  {

    # close the opening node
    print $fileHandle ">";
    print $fileHandle "\n" if $Pretty_XDF_Output && !defined $objPCDATA;

    # by definition these are printed first 
    for (@childXMLElements) {
      $_->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indentation);
    }

    # these are objects owned by this one, print them out too 
    for (@objList) {

      if (ref($_) =~ m/ARRAY/ ) { # if its a list..

         $indent = $self->_doObjectListtoXMLFileHandle($_, $fileHandle, $indent, $Pretty_XDF_Output, 
                                                       $Pretty_XDF_Output_Indentation);


      } elsif (ref($_) =~ m/XDF::/) { # if its an XDF object

         $indent = $self->_deal_with_closing_group_nodes($_, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
         $indent = $self->_deal_with_opening_group_nodes($_, $fileHandle, $indent, $Pretty_XDF_Output_Indentation);
         $_->toXMLFileHandle($fileHandle, undef, $indent . $Pretty_XDF_Output_Indentation);

      } else {

        die "BaseObject.pm got weird reference: $_\n";

      }


    }

    # print out the PCDATA
    if(defined $objPCDATA) {
      print $fileHandle $objPCDATA;
    }

    # if their are no children, then we print out the noChildObjectNodeName
    if ( $#objList < 0 and !defined $objPCDATA and
         defined $noChildObjectNodeName )
    {
       print $fileHandle "$indent$Pretty_XDF_Output_Indentation" if $Pretty_XDF_Output;
       print $fileHandle "<$noChildObjectNodeName/>";
       print $fileHandle "\n" if $Pretty_XDF_Output;
    }

    # Ok, no deal with closing this node
    $indent = $self->_deal_with_closing_group_nodes($self, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
    print $fileHandle $indent if $Pretty_XDF_Output && !defined $objPCDATA;
    if(!$dontCloseNode) {
       print $fileHandle "</". $nodename . ">";
    }

  } else {

    if ($dontCloseNode) {
      # It may not have sub-objects, but we dont want to close it
      # (this happens for group objects).
      print $fileHandle ">";
    } else {
      # no sub-objects, just close this node
      print $fileHandle "/>";
    }

  }

  print $fileHandle "\n" if $Pretty_XDF_Output;

}

sub _init {
  my ($self) = @_;

  # we cant do the following because of the multiple inheritance
  # thing. I guess that this is telling me to either 1) not use multi-inheritance
  # or 2) change the way that fields are initialized by classes.
  # $self->SUPER::_init();
 
  $self->{_hasValueListCompactDescription} = 0;
  $self->{_valueListObjects} = [];

  $self->{_childXMLElementList} = [];

  $self->{_openGroupNodeHash} = {}; # used only by toXMLFileHandle
  $self->{_groupMemberHash} = {}; # init of groupMember Hash (all objects have) 
  


}

# Modification History
#
# $Log$
# Revision 1.1  2001/07/13 21:38:54  thomas
# Initial Version
#
#
#

1;


# $Id$

# /** COPYRIGHT
#    BaseObjectWithXMLElements.pm Copyright (C) 2000 Brian Thomas,
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

package XDF::BaseObjectWithXMLElements;

use XDF::BaseObject;
use Carp;

use strict;
use integer;

use vars qw {@ISA %field};

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my @Class_Attributes = qw (
                             _childXMLElementList
                          );

my @Class_XML_Attributes = qw (
                              );

# add in super class XML attributes
#push @Class_XML_Attributes, @{&XDF::BaseObject::classXMLAttributes};

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

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

# /** addXMLElement
# Add a child XMLElement object to this one.
# Returns 1 on success, 0 on failure.
# */
sub addXMLElement {
  my ($self, $xmlElementObj) = @_;

  return 0 unless defined $xmlElementObj && ref $xmlElementObj;
  push @{$self->getXMLElementList}, $xmlElementObj;

  return 1;
}

# /** removeXMLElement
# Remove a child XMLElement object to this one.
# Returns 1 on success, 0 on failure.
# */
sub removeXMLElement {
   my ($self, $xmlElementObj) = @_;

   return 0 unless defined $xmlElementObj && ref $xmlElementObj;
   die "removeXMLElement not implemented yet.\n";

}

# /** getXMLElementList 
# 
# */
sub getXMLElementList {
  my ($self) = @_;
  return $self->{_childXMLElementList};
}

# /** setXMLElementList 
# 
# */
sub setXMLElementList {
  my ($self, $listRef) = @_;
  $self->{_childXMLElementList} = $listRef;
}

sub _init {
  my ($self) = @_;
  $self->SUPER::_init();
  $self->{_childXMLElementList} = []; # init of child XML object list (all objects have) 
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

         $indent = $self->_objectToXMLFileHandle($fileHandle, $_, $indent,
                                                 $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);

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

# Modification History
#
# $Log$
# Revision 1.5  2001/07/13 21:43:19  thomas
# small changes to yank code out of toXMLFileHandle and put in sub-methods
#
# Revision 1.4  2001/07/06 18:29:12  thomas
# stripped out unneeded nodenames stuff in toXMLFileHandle.
# Fixed bug in group printing in toXMLFileHandle.
#
# Revision 1.3  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.2  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.1  2001/04/17 18:45:34  thomas
# New class derived from BaseObject. Allows holding
# of XMLElements within the object.
#
#
#

1;


__END__

=head1 NAME

XDF::BaseObjectWithXMLElements - Perl Class for BaseObjectWithXMLElements

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 A 'super base object' which can hold XMLElements. 

XDF::BaseObjectWithXMLElements inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::BaseObjectWithXMLElements.

=over 4

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this object;This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::BaseObjectWithXMLElements.

=over 4

=item addXMLElement ($xmlElementObjRef)

 

=item removeXMLElement ($xmlElementObjRef)

 

=item getXMLElementList (EMPTY)

 

=item setXMLElementList ($listRef)

 

=item toXMLFileHandle ($fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName, $isRootNode)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::BaseObjectWithXMLElements inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::BaseObjectWithXMLElements inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L< XDF::Structure>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

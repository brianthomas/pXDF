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
# */
sub addXMLElement {
  my ($self, $xmlElementObjRef) = @_;

  push @{$self->getXMLElementList}, $xmlElementObjRef;
  return $xmlElementObjRef;
}

# /** removeXMLElement
# 
# */
sub removeXMLElement {
   my ($self, $xmlElementObjRef) = @_;
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
  my $nodeNameString = $self->classXMLNodeName;
  $nodeNameString = $newNodeNameString if defined $newNodeNameString;

  #my @nodenames = split /\|\|/, $nodeNameString;
  my @nodenames = ("$nodeNameString");

  foreach my $node (0 .. $#nodenames) {
    my $nodename = $nodenames[$node];
    # open this node, print its attributes
    if ($nodename) {
      print $fileHandle $indent if $Pretty_XDF_Output;
      $nodename = $spec->getXDFRootNodeName if ( (defined $XMLDeclAttribs || $isRootNode)
                                           && $self =~ m/XDF::Structure/);
      print $fileHandle "<" . $nodename;
      if( $node ne $#nodenames ) {
        print $fileHandle ">";
        print $fileHandle "\n" if $Pretty_XDF_Output;
        $indent .= $Pretty_XDF_Output_Indentation;
      }
    }
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
        foreach my $obj (@{$_}) {
           next unless defined $obj; # can happen because we allocate memory with
                                     # $DefaultDataArraySize, making undef spots possible

           $indent = $self->_deal_with_opening_group_nodes($obj, $fileHandle, $indent, $Pretty_XDF_Output_Indentation);
           $indent = $self->_deal_with_closing_group_nodes($obj, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
           $obj->toXMLFileHandle($fileHandle, undef, $indent . $Pretty_XDF_Output_Indentation);

        }
      } elsif (ref($_) =~ m/XDF::/) { # if its an XDF object

         $indent = $self->_deal_with_opening_group_nodes($_, $fileHandle, $indent, $Pretty_XDF_Output_Indentation);
         $indent = $self->_deal_with_closing_group_nodes($_, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
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
    if ($#nodenames > -1) {
      $indent = $self->_deal_with_closing_group_nodes($self, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
      print $fileHandle $indent if $Pretty_XDF_Output && !defined $objPCDATA;
      if(!$dontCloseNode) {
        # Im not sure that this is correct at ALL. 
        foreach my $nodename (reverse @nodenames) {
          $nodename = $spec->getXDFRootNodeName if ((defined $XMLDeclAttribs || $isRootNode)
                                               && $self =~ m/XDF::Structure/);
          print $fileHandle "</". $nodename . ">";
        }
      }
    }

  } else {

    if ($dontCloseNode) {
      # It may not have sub-objects, but we dont want to close it
      # (this happens for group objects).
      print $fileHandle ">" if $#nodenames > -1;
    } else {
      # no sub-objects, just close this node
      print $fileHandle "/>" if $#nodenames > -1;
      foreach my $node (reverse(0 .. ($#nodenames-1))) {
        $indent =~ s/$Pretty_XDF_Output_Indentation//; # peel off some of the indent 
        my $nodename = $nodenames[$node];
        print $fileHandle "\n$indent" if $Pretty_XDF_Output;
        print $fileHandle "</". $nodename . ">";
      }
    }

  }

  print $fileHandle "\n" if $Pretty_XDF_Output && $#nodenames > -1;

}

# Modification History
#
# $Log$
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
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

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

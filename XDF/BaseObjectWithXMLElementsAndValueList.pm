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
use XDF::Log;

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
my @Local_Class_Attributes = qw (
                          );

my @Local_Class_XML_Attributes = qw (
                              );


my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
# (multiple inheritance)
push @Class_XML_Attributes, @{&XDF::BaseObjectWithValueList::getClassXMLAttributes};
push @Class_XML_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassAttributes};
push @Class_Attributes, @{&XDF::BaseObjectWithValueList::getClassAttributes};
#push @Class_Attributes, @{&XDF::BaseObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization - set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this object;
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  return \@Class_Attributes;
}

sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# 
# Protected/Private Methods
#

sub _basicXMLWriter {
  my ($self, $fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName ) = @_;

  if(!defined $fileHandle) {
    error("Can't write out object, filehandle not defined.\n");
    return;
  }

  $indent = "" unless defined $indent;

  my $spec = XDF::Specification->getInstance();
  my $Pretty_XDF_Output = $spec->isPrettyXDFOutput;
  my $Pretty_XDF_Output_Indentation = $spec->getPrettyXDFOutputIndentation;

  # We need to invoke a little bit of Voodoo to keep the DTD happy; 
  # the first structure node is always called by the root node name
  # also, we may have nodes (w/o attributes) that just hold other nodes.
  my $nodename = $self->classXMLNodeName;
  $nodename = $newNodeNameString if defined $newNodeNameString;

  # open this node, print its attributes
  if ($nodename) {
      print $fileHandle $indent if $Pretty_XDF_Output;
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
         $_->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indentation);

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
  
  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

1;


__END__

=head1 NAME

XDF::BaseObjectWithXMLElementsAndValueList - Perl Class for BaseObjectWithXMLElementsAndValueList

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 A 'super base object' which can hold XMLElements. 

XDF::BaseObjectWithXMLElementsAndValueList inherits class and attribute methods of L< = (>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::BaseObjectWithXMLElementsAndValueList.

=over 4

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this object;This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

 

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

L< XDF::Array>, L< XDF::Structure>, L<XDF::BaseObjectWithXMLElements>, L<XDF::BaseObjectWithValueList>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

package XDF::BaseObject;

# /** COPYRIGHT
#    BaseObject.pm Copyright (C) 2000 Brian Thomas,
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

# /** DESCRIPTION
# XDF is the eXtensible Data Structure, which is an XML format designed to contain 
# n-dimensional scientific/mathematical data.
#@
#@
# XDF::BaseObject is the base class that all other XDF object classes inherit from.
# It supplies general use methods to these sub classes. (Diagram of object structure??) 
#@ 
#@
# Most other XDF objects inherit the methods of XDF::BaseObject.
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::Array
# XDF::Axis
# XDF::DataCube
# XDF::FieldAxis
# */

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

use XDF::GenericObject;
use Carp;

use strict;
use integer;

use vars qw ($VERSION @ISA %field);

# the version of this module
$VERSION = "0.17-beta1";

# inherits from XDF::GenericObject
@ISA = ("XDF::GenericObject");

# XDF::BaseObject CLASS Data

# Public Data

# Users MIGHT want to set these values, the following class data/attributes 
# have get/set methods.

my $Pretty_XDF_Output = 0; # IF TRUE then user gets indentation, carrage returns that make
                           # the output of toXMLFile* methods human readable. 

my $Pretty_XDF_Output_Indentation = "  "; # Indentation to use for pretty print 

my $DefaultDataArraySize = 1000; # Number stuff for holding data. We want to 
                                 # have a minimum array size for numbers (axis, dataCube, etc.)
                                 # This is what we declare as a default 

my $replaceNewlineWithEntityInOutputAttribute = 1;

my %XML_NOTATION_HASH;

# Private CLASS Data. 

# ALL CAPS STUFF: these aren't meant to be changed by users of the package, only
# by the maintainers, which is why they have no set/get methods.

my $XML_STRUCTURE_VERSION = "1.0";
my $XDF_ROOT_NODE_NAME = "XDF";
my $XDF_DTD_NAME = "XDF_0.17.dtd";
my $PCDATA_ATTRIBUTE = 'value';    # Used by toXMLFileHandle method. This says that
                                   # when we get an attribute in an object with this name
                                   # we print it as PCDATA of the object node rather than 
                                   # as an attribute when its value is scalar, eg attribute="value"


# CLASS DATA
my @Class_Attributes = qw (
                             _openGroupNodeHash
                             _groupMemberHash
                             _childXMLElementList
                          );

my @Class_XML_Attributes = qw (
                              );

# add in super class attributes
push @Class_Attributes, @{&XDF::GenericObject::classAttributes};

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

#
# Methods ..
#

# /** addXMLElement
# 
# */
sub addXMLElement {
  my ($self, $xmlElementObjRef) = @_;

  push @{$self->{_ChildXMLElementList}}, $xmlElementObjRef;
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
  return $self->{_ChildXMLElementList};
}

# /** setXMLElementList 
# 
# */
sub setXMLElementList {
  my ($self, $listRef) = @_;
  $self->{_ChildXMLElementList} = $listRef;
}

# /** addToGroup
# Add this object as a member of a group.
# */
sub addToGroup {
  my ($self, $groupObj) = @_;

  return unless defined $groupObj && ref $groupObj;

  # make sure its not already a member!
  unless (exists %{$self->{_groupMemberHash}}->{$groupObj}) {
    $groupObj->addMemberObject($self);
    %{$self->{_groupMemberHash}}->{$groupObj} = $groupObj;
    return $groupObj;
  } else {
     carp "Can't add to group: $self already a member of $groupObj\n"; 
  }

}

# /** removeFromGroup
# Remove this object from membership in a group.
# */ 
sub removeFromGroup {
  my ($self, $groupObj) = @_;

  return unless defined $groupObj && ref $groupObj;

  # make sure its a member!
  if (exists %{$self->{_groupMemberHash}}->{$groupObj}) {
    $groupObj->removeMemberObject($self);
    delete %{$self->{_groupMemberHash}}->{$groupObj};
    return $groupObj;
  } else {
    carp "Can't delete from group: $self not a member of $groupObj\n"; 
  }

}

# /** isGroupMember
# Determine if this object is a member of the reference Group object.
# Returns 1 if true, undef if false.
# */
sub isGroupMember { 
  my ($self, $groupObj) = @_;
  return unless defined $groupObj && ref $groupObj;
  return exists %{$self->{_groupMemberHash}}->{$groupObj} ? 1 : undef;
}

# /** setXMLAttributes
#   Set the XML attributes of this object using a passed Hashtable ref.
# */
sub setXMLAttributes { 
  my ($self, $attribHashRef) = @_;
  while (my ($attrib, $value) = each (%{$attribHashRef}) ) { 
     $self->{ucfirst $attrib} = $value; # set the attribute value 
  }
}

#/** setXMLNotationHash
# Set the baseobject class field NotationHash. This will be 
# printed out with other XMLDeclarations in a toXMLFileHandle call. 
# */
sub setXMLNotationHash {
  my ($self, $attribHashRef) = @_;
  my %newhash;
  while (my ($attrib, $value) = each (%{$attribHashRef}) ) { 
     $newhash{$attrib} = $value;
  }
  %XML_NOTATION_HASH = %newhash;
}

# a few Class Methods..

# /** Pretty_XDF_Output
# If a non-zero value is supplied then pretty XDF output format will be used 
# when the toXMLFileHandle/toXMLFile methods are called.
#@
# The default setting is 0.
# */
sub Pretty_XDF_Output {
  my ($self, $value) = @_;
  $Pretty_XDF_Output = $value if defined $value;
  return $Pretty_XDF_Output;
}

# /** Pretty_XDF_Output_Indentation
# This sets value of the indentation to use if pretty XDF output format is turned on.
#@
# The default setting is 2 spaces.
# */
sub Pretty_XDF_Output_Indentation {
  my ($self, $value) = @_;
  $Pretty_XDF_Output_Indentation = $value if defined $value;
  return $Pretty_XDF_Output_Indentation;
}

# /** 
# This value indicates the initial size of each L<XDF::Axis>/L<XDF::FieldAxis> (the 
# number of axisValues/fields along the axis) and the number of data cells within a 
# dimension of the dataCube (L<XDF::DataCube>). If more axisValues/fields/datacells are placed on a 
# given Axis/FieldAxis or data in a unallocated spot within the dataCube then the 
# package allocates the needed memory and enlarges the dataCube/Axis objects as it is needed. 
#@
#@
# This automated allocation is slow however, so it is desirable, IF you know how big your 
# arrays will be, to pre-set this value to encompass your data set. Doing so will to improve 
# efficenecy. Note that if you are having keeping all of your data in memory (a multi-dimensional 
# dataset) it may be desirable to DECREASE the value. 
#@
#@
# The default value is 1000. 
# */
sub DefaultDataArraySize {
  my ($self, $value) = @_;
  $DefaultDataArraySize = $value if defined $value;
  return $DefaultDataArraySize;
}

# now some instance methods ...

# /** toXMLFileHandle
# Write this structure and all the objects it owns to the supplied filehandle 
# in XML (XDF) format. The first argument is the name of the filehandle and is required. 
# The second, optional, argument indicates whether/how to write out the XML declaration at 
# the beginning of the file. This second argument may either be a string or hash table. 
# As a string is means simply to write the XML declaration and DOCTYPE. As a hash table, 
# the attributes of the XML declaration are arranged in attribute/value pairs, e.g.
# 
#  %XMLDeclAttribs = ( 'version' => "1.0",
#                      'standalone => 'no',
#                    );
# */
# write this object and all the objects it owns
# to the supplied filehandle in XML (XDF) format. 
# Im not entirely happy with this code. I had to 
# hardwire a number of things to enforce DTD compliance.
# -b.t.
sub toXMLFileHandle {
  my ($self, $fileHandle, $XMLDeclAttribs, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName, $isRootNode  ) = @_;

  if(!defined $fileHandle) {
    carp "Can't write out object, filehandle not defined.\n";
    return;
  }

  $indent = "" unless defined $indent;

  if (defined $XMLDeclAttribs) {
     $indent = ""; #$Pretty_XDF_Output_Indentation;
     # write the XML && DOCTYPE decl
     $self->_write_XML_decl_to_file_handle($fileHandle, $XMLDeclAttribs);
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
      $nodename = $XDF_ROOT_NODE_NAME if ( (defined $XMLDeclAttribs || $isRootNode) 
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
  @childXMLElements = @{$self->{_ChildXMLElementList}} if defined $self->{_ChildXMLElementList};
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

           $indent = $self->_deal_with_opening_group_nodes($obj, $fileHandle, $indent);
           $indent = $self->_deal_with_closing_group_nodes($obj, $fileHandle, $indent);
           $obj->toXMLFileHandle($fileHandle, undef, $indent . $Pretty_XDF_Output_Indentation); 

        }
      } elsif (ref($_) =~ m/XDF::/) { # if its an XDF object

         $indent = $self->_deal_with_opening_group_nodes($_, $fileHandle, $indent);
         $indent = $self->_deal_with_closing_group_nodes($_, $fileHandle, $indent);
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
      $indent = $self->_deal_with_closing_group_nodes($self, $fileHandle, $indent);
      print $fileHandle $indent if $Pretty_XDF_Output && !defined $objPCDATA;
      if(!$dontCloseNode) {
        # Im not sure that this is correct at ALL. 
        foreach my $nodename (reverse @nodenames) {
          $nodename = $XDF_ROOT_NODE_NAME if ((defined $XMLDeclAttribs || $isRootNode)
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

#/** toXMLString
#  Similar to toXMLFileHandle method, takes the same arguments barring the
#  first (e.g. the FileHandle reference) which is not needed for this method.
#  Returns a string XML representation of the object.
# */
sub toXMLString {
   my ($self, $XMLDeclAttribs, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName, $isRootNode  ) = @_;

   # we will capture output to special filehandle class
   # defined at the end of this this file 
   tie *CAPTURE, '_fileHandleToString';
   $self->toXMLFileHandle(\*CAPTURE, $XMLDeclAttribs, $indent, $dontCloseNode, 
                          $newNodeNameString, $noChildObjectNodeName, $isRootNode);
   my $string = <CAPTURE>;
   untie *CAPTURE;

   return $string;
}

sub _printAttributes {
  my ($self, $fileHandle, $listRef) = @_;

  foreach my $attrib (@{$listRef}) {
    next if $attrib =~ /^_/;
    my $val = $self->{ucfirst $attrib};
    if ($replaceNewlineWithEntityInOutputAttribute && $val) {
       $val =~ s/\n/&#10;/g; # newline gets entity 
       $val =~ s/\r/&#13;/g; # carriage return gets entity 
    }

    if (defined $val) {
       print $fileHandle " $attrib=\"";
       print $fileHandle $val;
       print $fileHandle "\"";
    }
  }
}

sub _getXMLInfo {
  my ($self) = @_;

  my $objPCDATA;
  my @objList = ();
  my @attribs;

 
  #foreach my $attrib (@{$self->classAttributes}) {
  foreach my $attrib (@{$self->getXMLAttributes}) {
    # DONT show private attributes (which have a leading underscore)
    #next if $attrib =~ m/XMLNodeName/;
    #next if $attrib =~ m/^_/;
    
    my $val = $self->{ucfirst $attrib}; # get attribute value 
    next unless defined $val;

    if (ref $val) {
      if ($val !~ m/ARRAY/ or $#{$val} > -1) {

        # What to not include?  I dont like 'hard-wiring'
        # this stuff here, but thats the most reasonable solution at this point. 
        # Our list:
        # 
        # 1- dont include empty notelists, 
        # 2- dont include empty unitlists (removed), 
        if (    (ref($val) ne 'XDF::Notes' or  $#{$val->getNoteList()} > -1)
#             && (ref($val) ne 'XDF::Units' or  $#{$val->getUnitList()} > -1)
           )
        { 
          push @objList, $val;
        }
      }
    } else {
      if ($attrib eq $PCDATA_ATTRIBUTE) {
        $objPCDATA = $val;
      } else {
        push @attribs, $attrib;
      }
    }
  }

  return (\@attribs, \@objList, $objPCDATA);
}

# deal with group stuff here. Open all groups not previously opened 
sub _deal_with_opening_group_nodes {
  my ($self, $obj, $fileHandle, $indent) = @_;

  foreach my $group (keys %{$obj->{_groupMemberHash}}) {
    unless (exists %{$self->{_openGroupNodeHash}}->{$group}) {
      my $groupObj = %{$obj->{_groupMemberHash}}->{$group};
      $indent .= $Pretty_XDF_Output_Indentation; # add some indent 
      $groupObj->toXMLFileHandle($fileHandle, undef, $indent, 1); 
      %{$self->{_openGroupNodeHash}}->{$group} = $groupObj;
    }
  }

  return $indent;
}

# close all groups not in this object
sub _deal_with_closing_group_nodes {
  my ($self, $obj, $fileHandle, $indent) = @_;
 
  foreach my $openGroup (keys %{$self->{_openGroupNodeHash}}) {
    unless (exists %{$obj->{_groupMemberHash}}->{$openGroup}) {
       my $groupNodeName = %{$self->{_openGroupNodeHash}}->{$openGroup}->classXMLNodeName;
       # close this node
       print $fileHandle $indent if $Pretty_XDF_Output;
       print $fileHandle "</" . $groupNodeName . ">";
       print $fileHandle "\n" if $Pretty_XDF_Output;
       # delete from list
       delete %{$self->{_openGroupNodeHash}}->{$openGroup};
       $indent =~ s/$Pretty_XDF_Output_Indentation//; # peel off some of the indent 
    }
  }
  return $indent;
}


# /** toXMLFile
# This is a convenience method which allows writing of this structure and all 
# the objects it owns to the indicated file in XML (XDF) format. The first argument 
# is the name of the file and is required. The supplied filename will be OVERWRITTEN, 
# not appended to. The second, optional, argument has the same meaning as for toXMLFileHandle.
# */
sub toXMLFile {
  my ($self, $file, $XMLDeclAttribs) = @_;

  if(!open(FILE, ">$file")) {
    carp "Can't open file: $file for writing.\n";
    return;
  }

  # write myself out
  $self->toXMLFileHandle(\*FILE, $XMLDeclAttribs);

  close FILE;

}

# private method
sub _write_XML_decl_to_file_handle {
  my ($self, $fileHandle, $XMLDeclAttribs) = @_;

# write the XML && DOCTYPE decl
  if (defined $XMLDeclAttribs) {
    print $fileHandle "<?xml ";
    if (ref $XMLDeclAttribs) {

      while (my ($attrib, $value) = each (%{$XMLDeclAttribs}) ) { 
        print $fileHandle " $attrib=\"",$value,"\"";
      } 
      #foreach my $attrib (keys %{$XMLDeclAttribs}) {
      #  print $fileHandle " $attrib=\"",%{$XMLDeclAttribs}->{$attrib},"\"";
      #}
    } else {
      print $fileHandle "version =\"$XML_STRUCTURE_VERSION\"";
    }
    print $fileHandle "?>\n";
    print $fileHandle "<!DOCTYPE $XDF_ROOT_NODE_NAME SYSTEM \"$XDF_DTD_NAME\"";

    # find all XML Href entities
    my @HrefList = @{$self->_find_All_child_Href_Objects()};
    my $entityString;
    for (@HrefList) {
       $entityString .= "  <!ENTITY " . $_->getName();
       $entityString .= " BASE \"" . $_->getBase() . "\"" if defined $_->getBase();
       $entityString .= " PUBLIC \"" . $_->getPubId() . "\"" if defined $_->getPubId();
       $entityString .= " SYSTEM \"" . $_->getSysId() . "\"" if defined $_->getSysId();
       $entityString .= " NDATA " . $_->getNdata() if defined $_->getNdata();
       $entityString .= ">\n";
    }

    # find all XML notation
    my $notationString;
    while (my ($name, $notHashRef) = each (%XML_NOTATION_HASH)) { 
       my %notationHash = %{$notHashRef};
       $notationString .= "  <!NOTATION $name";
       $notationString .= " BASE \"" . $notationHash{'base'} . "\"" if defined $notationHash{'base'};
       $notationString .= " PUBLIC \"" . $notationHash{'pubid'}. "\"" if defined $notationHash{'pubid'};
       $notationString .= " SYSTEM \"" . $notationHash{'sysid'}. "\"" if defined $notationHash{'sysid'};
       $notationString .= ">\n";
    }

    if (defined $entityString or defined $notationString) {
      print $fileHandle " [\n";
      print $fileHandle "$entityString" if (defined $entityString);
      print $fileHandle "$notationString" if (defined $notationString);
      print $fileHandle "]";
    }
    print $fileHandle ">\n";

  }

}

sub _find_All_child_Href_Objects {
  my ($self) = @_;

  my @list;

  if (ref($self) eq 'XDF::Structure') {
     foreach my $arrayObj (@{$self->getArrayList()}) { 
        my $hrefObj = $arrayObj->getDataCube()->getHref();
        push @list, $hrefObj if defined $hrefObj;
     }

     foreach my $structObj (@{$self->getStructList()}) { 
        push @list, @{$structObj->_find_All_child_Href_Objects()};
     }
  }

  return \@list;
}

# End BaseObject Class

#
# THe fileHandleToString class.
#

############################
package _fileHandleToString;
############################

sub TIEHANDLE {
  my $class = shift;
  my $self = bless {}, $class;
  $self->{'MSG'} = "";
  return $self;
}

sub PRINT {
  my ($self, $msg) = @_;
  $self->{'MSG'} .= $msg;
}

sub READLINE {
  my ($self) = @_;
  #print STDERR "My object got msg:[",$self->{'MSG'},"]\n";
  return $self->{'MSG'};
}


# Modification History
#
# $Log$
# Revision 1.13  2001/03/23 22:21:45  thomas
# *** empty log message ***
#
# Revision 1.12  2001/03/23 20:37:17  thomas
# added toXMLString method. Added new parameter
# $isRootNode to toXMLFileHandle to allow printing
# of structure object node as 'XDF' instead of
# 'structure'. Broke up _printAttrributes lines
# so that _fileHandleToString would work correctly.
#
# Revision 1.11  2001/03/21 20:19:23  thomas
# Fixed documentation to show addXMLElement, etc. methods in perldoc
#
# Revision 1.10  2001/03/21 20:18:01  thomas
# Added methods for XMLElement class. Fixed
# toXMLFileHandle method so these would print
# out.
#
# Revision 1.9  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.8  2001/03/14 22:09:31  thomas
# updated Version name of package.
#
# Revision 1.7  2001/03/14 21:32:33  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2001/03/14 21:29:45  thomas
# Minor documentation change.
#
# Revision 1.5  2001/01/02 02:39:31  thomas
# Minor fix to prevent spurious messages from
# toXMLFileHandle when only filehandle is passed
# (but not the indent, etc). -b.t.
#
# Revision 1.4  2000/12/15 22:12:53  thomas
# Added <!ENTITY> and <!NOTATION> output to the DOCTYPE
# declaration line at the header of a file when XMLDecl are
# defined in toXMLFileHandle method call. -b.t.
#
# Revision 1.3  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.2  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.1  2000/10/16 17:39:45  thomas
# The old Object.pm. Moved to BaseObject name for consistency
# with the Java code base.
#
#
#

1;


__END__

=head1 NAME

XDF::BaseObject - Perl Class for BaseObject

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 XDF is the eXtensible Data Structure, which is an XML format designed to contain  n-dimensional scientific/mathematical data.  
 
 XDF::BaseObject is the base class that all other XDF object classes inherit from.  It supplies general use methods to these sub classes. (Diagram of object structure??)   
 
 Most other XDF objects inherit the methods of XDF::BaseObject. 

XDF::BaseObject inherits class and attribute methods of L<XDF::GenericObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::BaseObject.

=over 4

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this object;This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

 

=item toXMLFileHandle (EMPTY)

Write this structure and all the objects it owns to the supplied filehandle in XML (XDF) format. The first argument is the name of the filehandle and is required. The second, optional, argument indicates whether/how to write out the XML declaration at the beginning of the file. This second argument may either be a string or hash table. As a string is means simply to write the XML declaration and DOCTYPE. As a hash table, the attributes of the XML declaration are arranged in attribute/value pairs, e.g. %XMLDeclAttribs = ( 'version' => "1.0",'standalone => 'no',); 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::BaseObject.

=over 4

=item addXMLElement ($xmlElementObjRef)

 

=item removeXMLElement ($xmlElementObjRef)

 

=item getXMLElementList (EMPTY)

 

=item setXMLElementList ($listRef)

 

=item addToGroup ($groupObj)

Add this object as a member of a group.  

=item removeFromGroup ($groupObj)

Remove this object from membership in a group.  

=item isGroupMember ($groupObj)

Determine if this object is a member of the reference Group object. Returns 1 if true, undef if false.  

=item setXMLAttributes ($attribHashRef)

Set the XML attributes of this object using a passed Hashtable ref.  

=item setXMLNotationHash ($attribHashRef)

Set the baseobject class field NotationHash. This will be printed out with other XMLDeclarations in a toXMLFileHandle call.  

=item Pretty_XDF_Output ($value)

If a non-zero value is supplied then pretty XDF output format will be used when the toXMLFileHandle/toXMLFile methods are called. @The default setting is 0.  

=item Pretty_XDF_Output_Indentation ($value)

This sets value of the indentation to use if pretty XDF output format is turned on. @The default setting is 2 spaces.  

=item DefaultDataArraySize ($value)

 

=item toXMLFile ($XMLDeclAttribs, $file)

This is a convenience method which allows writing of this structure and all the objects it owns to the indicated file in XML (XDF) format. The first argument is the name of the file and is required. The supplied filename will be OVERWRITTEN, not appended to. The second, optional, argument has the same meaning as for toXMLFileHandle.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::BaseObject inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::Array>, L< XDF::Axis>, L< XDF::DataCube>, L< XDF::FieldAxis>, L<XDF::GenericObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

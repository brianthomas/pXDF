
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
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

use Tie::IxHash;
use XDF::GenericObject;
use XDF::Specification;
use XDF::Log;

use strict;
use integer;

use vars qw (@ISA %field);

# inherits from XDF::GenericObject
@ISA = ("XDF::GenericObject");

# XDF::BaseObject CLASS Data

# CLass Data

# Users MIGHT want to set these values, the following class data/attributes 
# have get/set methods.

my $replaceNewlineWithEntityInOutputAttribute = 1;

# Private CLASS Data. 

# Used by toXMLFileHandle method. This says that
# when we get an attribute in an object with this name
# we print it as PCDATA of the object node rather than 
# as an attribute when its value is scalar, eg attribute="value"
my $PCDATA_ATTRIBUTE = &XDF::Constants::getPCDATAAttribute;

# CLASS DATA
my @Local_Class_Attributes = qw (
                             _openGroupNodeHash
                             _groupMemberHash
                             _hasXMLAttribHash
                             _XMLAttribOrder
                          );
my @Local_Class_XML_Attributes = qw (
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

#/** getClassXMLAttributes
# Return a list ref of the XML attributes for this class.
#*/
sub getClassXMLAttributes {
  return \@Class_XML_Attributes; 
}

#/** getXMLAttributes
# Return a list reference of the XML attributes held by this object. 
# This list *may* differ from that returned by getClassXMLAttributes
# as new, user-defined Attributes may have been added to this instance. 
#*/
sub getXMLAttributes {
  my ($self) = @_;
  return $self->{_XMLAttribOrder};
}

# /** setXMLAttributes
#   Set the XML attributes of this object using a passed Hashtable ref.
# */
sub setXMLAttributes { 
  my ($self, $attribHashRef) = @_;
  while (my ($attrib, $value) = each (%{$attribHashRef}) ) {
     $self->setXMLAttribute($attrib,$value);
  }
}

#/** getXMLAttribute
# Return the value of an XML attribute.
#*/
sub getXMLAttribute 
{
   my ($self, $attrib) = @_;

   return unless (defined $attrib);

   die "Cannot get private XML attribute (starts with underscore)\n"
      if ($attrib =~ m/^_/);

   if (exists $self->{_hasXMLAttribHash}{$attrib})
   {
      return $self->{$attrib};
   }

}

#/** setXMLAttribute
# Set the value of an XML Attribute.
#*/
sub setXMLAttribute {
   my ($self, $attrib, $value) = @_;

   return unless (defined $attrib);

   die "Cannot set private XML attribute (starts with underscore)\n"
      if ($attrib =~ m/^_/);

   if (exists $self->{_hasXMLAttribHash}{$attrib}) {
      $self->{$attrib} = $value; # set the attribute value 
   } else {
      $self->addXMLAttribute($attrib,$value);
   }

}

sub addXMLAttribute {
   my ($self, $attrib, $value) = @_;

   return 0 unless (defined $attrib);

   die "Cannot add private XML attribute (starts with underscore)\n"
      if ($attrib =~ m/^_/);

   if (!exists $self->{_hasXMLAttribHash}{$attrib}) {

      $self->{_hasXMLAttribHash}{$attrib} = 1;

      $self->{$attrib} = $value; # set the attribute value 

      # append onto order list
      push @{$self->{_XMLAttribOrder}}, $attrib;

      return 1;      

   } else {
      error("$attrib already exists within $self, cannot addXMLAttribute, Ignoring\n");
      return 0;      
   }

}

sub _appendAttribsToXMLAttribOrder {
  my ($self, $listRef) = @_;

  foreach my $attrib (@$listRef) { 
     $self->{_hasXMLAttribHash}{$attrib} = 1;
     push @{$self->{_XMLAttribOrder}}, $attrib;
  }

}

#
# Methods ..
#

# /** addToGroup
# Add this object as a member of a group.
# Returns : 1 on success, 0 on failure.
# */
sub addToGroup {
  my ($self, $groupObj) = @_;

  return 0 unless defined $groupObj && ref $groupObj;

  # make sure its not already a member!
  #unless (exists %{$self->{_groupMemberHash}}->{$groupObj}) {
  unless (exists $self->{_groupMemberHash}->{$groupObj}) {
    $groupObj->addMemberObject($self);
    #%{$self->{_groupMemberHash}}->{$groupObj} = $groupObj;
    $self->{_groupMemberHash}->{$groupObj} = $groupObj;
    return 1;
  } else {
     error("Can't add to group: $self already a member of $groupObj\n"); 
     return 0;
  }

}

# /** removeFromGroup
# Remove this object from membership in a group.
# */ 
sub removeFromGroup {
  my ($self, $groupObj) = @_;

  return unless defined $groupObj && ref $groupObj;

  # make sure its a member!
  if (exists $self->{_groupMemberHash}->{$groupObj}) {
    $groupObj->removeMemberObject($self);
    delete $self->{_groupMemberHash}->{$groupObj};
    return $groupObj;
  } else {
    error("Can't delete from group: $self not a member of $groupObj\n"); 
  }

}

# /** isGroupMember
# Determine if this object is a member of the reference Group object.
# Returns 1 if true, undef if false.
# */
sub isGroupMember { 
  my ($self, $groupObj) = @_;
  return unless defined $groupObj && ref $groupObj;
  #return exists %{$self->{_groupMemberHash}}->{$groupObj} ? 1 : undef;
  return exists $self->{_groupMemberHash}->{$groupObj} ? 1 : undef;
}


# /** toXMLFileHandle
# Write this structure and all the objects it owns to the supplied filehandle 
# in XML (XDF) format. The first argument is the name of the filehandle and is required. 
# */
# write this object and all the objects it owns
# to the supplied filehandle in XML (XDF) format. 
# Im not entirely happy with this code. I had to 
# hardwire a number of things to enforce DTD compliance.
# -b.t.
sub toXMLFileHandle {
   my ($self, $fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName) = @_;

   $self->_basicXMLWriter($fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName);
   print $fileHandle "\n" if XDF::Specification->getInstance()->isPrettyXDFOutput;
}

#/** toXMLString
#  Print out the XML representation of this object.
#  Similar to toXMLFileHandle method, takes the same arguments barring the
#  first (e.g. the FileHandle reference) which is not needed for this method.
#  Caution: IF you ask for the string reprentation of an XDF object that has
#  Href Entities (e.g. data nodes which point to external files) you will only
#  get the meta-data, not the (external) data. IF you want the data, then you
#  will have to manipulate the XDF object *before* using this method to remove
#  the Href Entities, and thereby force the data back into the XML representation.
#  Returns a string XML representation of the object.
# */
sub toXMLString {
  my ($self, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName ) = @_;

   # we will capture output to special filehandle class
   # defined at the end of this this file 
   tie *CAPTURE, '_fileHandleToString';
   $self->toXMLFileHandle(\*CAPTURE, $indent, $dontCloseNode,
                          $newNodeNameString, $noChildObjectNodeName );
   my $string = <CAPTURE>;
   untie *CAPTURE;

   return $string;
}

# /** toXMLFile
# This is a convenience method which allows writing of this object and all 
# the objects it owns to the indicated file in XML (XDF) format. The first argument 
# is the name of the file and is required. The supplied filename will be OVERWRITTEN, 
# not appended to. The second, optional, argument has the same meaning as for toXMLFileHandle.
# */
sub toXMLFile {
  my ($self, $file) = @_;

  if(!open(FILE, ">$file")) {
    error("Can't open file: $file for writing.\n");
    return;
  }

  # write myself out
  $self->toXMLFileHandle(\*FILE);

  close FILE;

}

#
# Private/Protected Methods
#

sub _basicXMLWriter { 
  my ($self, $fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName) = @_;

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

  if ( $#objList > -1 
       or defined $objPCDATA 
       or defined $noChildObjectNodeName) 
  {

    # close the opening node
    print $fileHandle ">";
    print $fileHandle "\n" if $Pretty_XDF_Output && !defined $objPCDATA;

    # these are objects owned by this one, print them out too 
    for (@objList) { 

      if (ref($_) =~ m/ARRAY/ ) { # if its a list..

         $indent = $self->_objectToXMLFileHandle($fileHandle, $_, $indent, 
                                                 $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);

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
       # In general, we cant allow angle brackets to be printed out in PCDATA, 
       # these little devils screw up the XML parse of the file the next time 
       # it is read. Replace them with cooresponding entities &lt; and &gt; 
       $objPCDATA =~ s/</&lt;/gs;
       $objPCDATA =~ s/>/&gt;/gs;
       # now print the PCDATA
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

    # Ok, now deal with closing this node
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

sub _objectToXMLFileHandle { 
   my ($self, $fileHandle, $listRef, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation) = @_;

   foreach my $obj (@{$listRef}) {
      next unless defined $obj; # can happen because we allocate memory with
                                     # $DefaultDataArraySize, making undef spots possible

      $indent = $self->_deal_with_closing_group_nodes($obj, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation);
      $indent = $self->_deal_with_opening_group_nodes($obj, $fileHandle, $indent, $Pretty_XDF_Output_Indentation);
      $obj->toXMLFileHandle($fileHandle, $indent . $Pretty_XDF_Output_Indentation);

   }

   return $indent;
}

# Note: it will only print attributes with scalar values
# those with references are ignored.
sub _printAttributes {
  my ($self, $fileHandle, $listRef) = @_;

  foreach my $attrib (@{$listRef}) {
    next if $attrib =~ /^_/;
    my $val = $self->{$attrib};
    next if ref($val);

    if (defined $val) {

       # xml Violation if we dont do this
       $val =~ s/&/&amp;/g; # ampersand gets entity 
       $val =~ s/</&lt;/g; # lessthan gets entity 
       $val =~ s/"/&quot;/g; # quote gets entity 
       $val =~ s/>/&gt;/g; # greaterthan gets entity 

       if ($replaceNewlineWithEntityInOutputAttribute) {
         $val =~ s/\n/&#10;/g; # newline gets entity 
         $val =~ s/\r/&#13;/g; # carriage return gets entity 
       }

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

  #foreach my $attrib (@{$self->getClassXMLAttributes}) {
  foreach my $attrib (@{$self->getXMLAttributes}) {
    # DONT show private attributes (which have a leading underscore)
    #next if $attrib =~ m/XMLNodeName/;
    #next if $attrib =~ m/^_/;
    
#if (ref ($self) eq 'XDF::FormattedXMLDataIOStyle') { print STDERR "got XML attribute: $attrib\n"; }
#if (ref ($self) eq 'XDF::Axis') { print STDERR "got XML attribute: $attrib\n"; }

    my $val = $self->{$attrib}; # get attribute value 
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
  my ($self, $obj, $fileHandle, $indent, $Pretty_XDF_Output_Indentation ) = @_;

  foreach my $group (keys %{$obj->{_groupMemberHash}}) {
    #unless (exists %{$self->{_openGroupNodeHash}}->{$group}) {
    unless (exists $self->{_openGroupNodeHash}->{$group}) {
      #my $groupObj = %{$obj->{_groupMemberHash}}->{$group};
      my $groupObj = $obj->{_groupMemberHash}->{$group};
      $indent .= $Pretty_XDF_Output_Indentation; # add some indent 
      $groupObj->toXMLFileHandle($fileHandle, $indent, 1); 
      #%{$self->{_openGroupNodeHash}}->{$group} = $groupObj;
      $self->{_openGroupNodeHash}->{$group} = $groupObj;
    }
  }

  return $indent;
}

# close all groups not in this object
sub _deal_with_closing_group_nodes {
  my ($self, $obj, $fileHandle, $indent, $Pretty_XDF_Output, $Pretty_XDF_Output_Indentation) = @_;

  foreach my $openGroup (keys %{$self->{_openGroupNodeHash}}) {
    #unless (exists %{$obj->{_groupMemberHash}}->{$openGroup}) {
    unless (exists $obj->{_groupMemberHash}->{$openGroup}) {
       #my $groupNodeName = %{$self->{_openGroupNodeHash}}->{$openGroup}->classXMLNodeName;
       my $groupNodeName = $self->{_openGroupNodeHash}->{$openGroup}->classXMLNodeName;
       # close this node
       print $fileHandle $indent if $Pretty_XDF_Output;
       print $fileHandle "</" . $groupNodeName . ">";
       print $fileHandle "\n" if $Pretty_XDF_Output;
       # delete from list
       #delete %{$self->{_openGroupNodeHash}}->{$openGroup};
       delete $self->{_openGroupNodeHash}->{$openGroup};
       $indent =~ s/$Pretty_XDF_Output_Indentation//; # peel off some of the indent 
    }
  }
  return $indent;
}


# private method
sub _init {
  my ($self) = @_;

  $self->{_openGroupNodeHash} = {}; # used only by toXMLFileHandle
  $self->{_groupMemberHash} = {}; # init of groupMember Hash (all objects have) 
  tie %{$self->{_groupMemberHash}}, "Tie::IxHash";
  $self->{_hasXMLAttribHash} = {}; # init of xmlAttributes of this object
  $self->{_XMLAttribOrder} = []; # init of xmlAttribute order of this object

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

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

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this object;This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

Return a list ref of the XML attributes for this class.  

=item getXMLAttribute (EMPTY)

Return the value of an XML attribute.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::BaseObject.

=over 4

=item getXMLAttributes (EMPTY)

Return a list reference of the XML attributes held by this object. This list *may* differ from that returned by getClassXMLAttributesas new, user-defined Attributes may have been added to this instance.  

=item setXMLAttributes ($attribHashRef)

Set the XML attributes of this object using a passed Hashtable ref.  

=item setXMLAttribute ($attrib, $value)

Set the value of an XML Attribute.  

=item addXMLAttribute ($attrib, $value)

 

=item addToGroup ($groupObj)

Add this object as a member of a group. Returns : 1 on success, 0 on failure.  

=item removeFromGroup ($groupObj)

Remove this object from membership in a group.  

=item isGroupMember ($groupObj)

Determine if this object is a member of the reference Group object. Returns 1 if true, undef if false.  

=item toXMLFileHandle ($fileHandle, $indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName)

Write this structure and all the objects it owns to the supplied filehandle in XML (XDF) format. The first argument is the name of the filehandle and is required.  

=item toXMLString ($indent, $dontCloseNode, $newNodeNameString, $noChildObjectNodeName)

Print out the XML representation of this object. Similar to toXMLFileHandle method, takes the same arguments barring thefirst (e.g. the FileHandle reference) which is not needed for this method. Caution: IF you ask for the string reprentation of an XDF object that hasHref Entities (e.g. data nodes which point to external files) you will onlyget the meta-data, not the (external) data. IF you want the data, then youwill have to manipulate the XDF object *before* using this method to removethe Href Entities, and thereby force the data back into the XML representation. Returns a string XML representation of the object.  

=item toXMLFile ($file)

This is a convenience method which allows writing of this object and all the objects it owns to the indicated file in XML (XDF) format. The first argument is the name of the file and is required. The supplied filename will be OVERWRITTEN, not appended to. The second, optional, argument has the same meaning as for toXMLFileHandle.  

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

L< XDF::Array>, L< XDF::Axis>, L< XDF::DataCube>, L< XDF::FieldAxis>, L<XDF::GenericObject>, L<XDF::Specification>, L<XDF::Log>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


package XDF::TaggedXMLDataIOStyle;

# /** COPYRIGHT
#    TaggedXMLDataIOStyle.pm Copyright (C) 2000 Brian Thomas,
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


# $Id$

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */


# /** DESCRIPTION
# This class indicates how records are to be read/written 
# back out into XDF formatted XML files with tagged data sections.
# */

# /** SYNOPSIS
# 
# */


use XDF::XMLDataIOStyle;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::XMLDataIOStyle");

# CLASS DATA
my $Tag_To_Axis_Node_Name = "tagToAxis";
my @Local_Class_XML_Attributes = ();
my @Local_Class_Attributes = qw (
                             _tagHash
                             _parentArray
                             _HAS_INIT_AXIS_TAGS
                          );
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::Group::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::Group::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization - set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
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


#
# Get/Set Methods
#

# /** setAxisTag
# Set an association between an XDF data tag and axis reference.
# One day we will hopefully be able to support user defined tags, but for the 
# time being you will have to stick to those specified by the XDF DTD
# (e.g. "d0","d1", ... "d8"). Note that choosing the wrong tag name will break 
# the current XDF DTD, so go with the defaults (e.g. DONT use this method) 
# if you dont know what you are doing here.
# */
sub setAxisTag {
  my ($self, $tag, $axisId ) = @_;

  unless (defined $tag  && defined $axisId ) {
    warn "Missing information: need tag AND axisId for addAxisTag. Ignoring request.\n";
    return;
  }

  $self->_initAxisTags();

  # insert in hash table, return tag value
  return %{$self->{_tagHash}}->{$axisId} = $tag;

}

sub getAxisTag {
  my ($self, $axisId ) = @_;
  $self->_initAxisTags();
  return %{$self->{_tagHash}}->{$axisId};
}

# /** getXMLDataIOStyleTags
# Return an axis ordered list (ARRAY REF) of tags to be used to write tagged data.
# */
sub getAxisTags {
  my ($self) = @_;

  $self->_initAxisTags();

  my @tags;
  foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
    my $axisId = $axisObj->getAxisId();
    push @tags, %{$self->{_tagHash}}->{$axisId};
  }
  return @tags;

}

#
# Other Public MEthods
#

# /** toXMLFileHandle
# Write this object out to a filehandle in XDF formatted XML.
# */
sub toXMLFileHandle {
  my ($self, $fileHandle, $junk, $indent) = @_;

  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;

  $indent = "" unless defined $indent;
  my $more_indent = $indent . $spec->getPrettyXDFOutputIndentation;

  print $fileHandle "$indent" if $niceOutput;

  # open the read block
  print $fileHandle "<" . $self->classXMLNodeName;

  # get attribute info
  my ($attribListRef) = $self->_getXMLInfo();
  # print attributes
  $self->_printAttributes($fileHandle,$attribListRef); 

  print $fileHandle ">";
  print $fileHandle "\n" if $niceOutput;

  my @tags = $self->getAxisTags;
  #foreach my $axisObj ( @{$self->{_parentArray}->getAxisList()} ) {
  foreach my $axisObj ( @{$self->getWriteAxisOrderList()} ) {
    my $axisId = $axisObj->getAxisId();
    my $tag = shift @tags;
    print $fileHandle "$more_indent" if $niceOutput;
    # next 5 lines: have to break up printing of '"' or toXMLString will behave badly
    print $fileHandle "<$Tag_To_Axis_Node_Name axisIdRef=\"";
    print $fileHandle $axisId . "\"";
    print $fileHandle " tag=\"";
    print $fileHandle $tag;
    print $fileHandle "\"/>";

    print $fileHandle "\n" if $niceOutput;
  }

  # close the read block
  print $fileHandle "$indent" if $niceOutput;
  print $fileHandle "</" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

}

#
# Private Methods
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

  $self->SUPER::_init();

  $self->{_tagHash} = {};

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

  return $self;

}

sub _initAxisTags {
  my ($self) = @_;

   return if $self->{_HAS_INIT_AXIS_TAGS};
   return unless defined $self->{_parentArray};

   my $counter = $#{$self->{_parentArray}->getAxisList()};
   foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
     my $axisId = $axisObj->getAxisId();
     my $tag = 'd' . $counter--; # the default 
     %{$self->{_tagHash}}->{$axisId} = $tag;
   }

   $self->{_HAS_INIT_AXIS_TAGS} = 1;
}

# /** _removeAxisTag
# Remove an axis tag from the tag hash. This should be PROTECTED
# and occur only when axis is being removed (ie available to array obj only).
# */
sub _removeAxisTag {
  my ($self, $axisId) = @_;
  delete %{$self->{_tagHash}}->{"$axisId"};
}


# Modification History
#
# $Log$
# Revision 1.16  2001/08/13 19:50:16  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.15  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.14  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.13  2001/04/17 19:00:51  thomas
# Using Specification class now.
# Properly calling superclass init now.
#
# Revision 1.12  2001/03/26 18:16:37  thomas
# yanked overriding method of setWriteAxisOrderList,
# makes docs look messy.
#
# Revision 1.11  2001/03/26 18:12:24  thomas
# use writeAxisOrderList in toXMLFileHandle.
#
# Revision 1.10  2001/03/23 20:38:40  thomas
# broke up printing of attributes in toXMLFileHandle
# so that toXMLString will work properly.
#
# Revision 1.9  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.8  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.7  2001/03/02 20:28:16  thomas
# Last fix not right. Now working for all cases.
#
# Revision 1.6  2001/03/02 19:59:29  thomas
# added getAxisTag method. fixed init. need to consider when axis is added
# in the array.
#
# Revision 1.5  2000/12/15 22:11:59  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::TaggedXMLDataIOStyle - Perl Class for TaggedXMLDataIOStyle

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 This class indicates how records are to be read/written  back out into XDF formatted XML files with tagged data sections. 

XDF::TaggedXMLDataIOStyle inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::XMLDataIOStyle>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::TaggedXMLDataIOStyle.

=over 4

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of this class. This method takes no arguments may not be changed.  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::TaggedXMLDataIOStyle.

=over 4

=item setAxisTag ($tag, $axisId)

Set an association between an XDF data tag and axis reference. One day we will hopefully be able to support user defined tags, but for the time being you will have to stick to those specified by the XDF DTD(e.g. "d0","d1", ... "d8"). Note that choosing the wrong tag name will break the current XDF DTD, so go with the defaults (e.g. DONT use this method) if you dont know what you are doing here.  

=item getAxisTag ($axisId)

 

=item getAxisTags (EMPTY)

 

=item toXMLFileHandle ($fileHandle, $junk, $indent)

Write this object out to a filehandle in XDF formatted XML.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::TaggedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::XMLDataIOStyle>:
B<untaggedInstructionNodeName>, B<getReadId{>, B<setReadId>, B<getReadIdRef>, B<setReadIdRef>, B<getEncoding{>, B<setEncoding>, B<getEndian{>, B<setEndian>, B<getWriteAxisOrderList>, B<setWriteAxisOrderList>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::XMLDataIOStyle>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

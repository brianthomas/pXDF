
# $Id$

# /** COPYRIGHT
#    DelimitedXMLDataIOStyle.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::DelimitedDataIOStyle is a class that indicates how delimited ASCII 
# records are to be read in.
# */

package XDF::DelimitedXMLDataIOStyle;

use XDF::XMLDataIOStyle;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::XMLDataIOStyle");

# CLASS DATA

my $Def_Delimiter = " ";
my $Def_Repeatable = "yes";
my $Def_Record_Terminator = "\n";

my $Class_XML_Node_Name = "textDelimiter";
# the order of these attributes IS important. 
# Note: _parentArray isnt needed by TextDelimiter, but is supplied for 
# compatablity w/ FormattedReadStyle (the other untagged Read style at this time)
my @Class_XML_Attributes = qw (
                             delimiter
                             repeatable
                             recordTerminator
                          );

my @Class_Attributes = qw (
                             writeAxisOrderList
                          );

# add in super class attributes
push @Class_XML_Attributes, @{&XDF::XMLDataIOStyle::getClassXMLAttributes};

## add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::XMLDataIOStyle::getClassAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

sub getClassAttributes { 
  \@Class_Attributes; 
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# 
# SET/GET Methods
#

# /** getDelimiter
# */
sub getDelimiter {
   my ($self) = @_;
   return $self->{delimiter};
}

# /** setDelimiter
#     Set the delimiter attribute. 
# */
sub setDelimiter {
   my ($self, $value) = @_;
   $self->{delimiter} = $value;
}

# /** getRepeatable
# */
sub getRepeatable {
   my ($self) = @_;
   return $self->{repeatable};
}

# /** setRepeatable
#     Set the repeatable attribute. 
# */
sub setRepeatable {
   my ($self, $value) = @_;
   $self->{repeatable} = $value;
}

# /** getRecordTerminator
# */
sub getRecordTerminator {
   my ($self) = @_;
   return $self->{recordTerminator};
}

# /** setRecordTerminator
#     Set the recordTerminator attribute. 
# */
sub setRecordTerminator {
   my ($self, $value) = @_;
   $self->{recordTerminator} = $value;
}

#
# Other Public methods 
#

sub toXMLFileHandle {
  my ($self, $fileHandle, $junk, $indent) = @_;

  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;

  $indent = "" unless defined $indent;
  my $more_indent = $spec->getPrettyXDFOutputIndentation;

  print $fileHandle "$indent" if $niceOutput;

  # open the read block, print attributes 
  print $fileHandle "<" . $self->SUPER::classXMLNodeName;
  # print out attributes
  $self->_printAttributes($fileHandle, $self->SUPER::getClassAttributes);
  print $fileHandle ">";
  print $fileHandle "\n" if $niceOutput;

  my @indent;
  my $Untagged_Instruction_Node_Name = $self->untaggedInstructionNodeName();
  my $next_indent = $indent . $more_indent;
  #foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
 # we write this out in the *reverse* ordering. Why? because XDF
  # DTD wants the fastest axis to be *last*
  foreach my $axisObj (reverse @{$self->getWriteAxisOrderList()}) {
    my $axisId = $axisObj->getAxisId();
    push @indent, $next_indent;
    print $fileHandle "$next_indent" if $niceOutput;
    # next 3 lines: have to break up printing of '"' or toXMLString will behave badly
    print $fileHandle "<$Untagged_Instruction_Node_Name axisIdRef=\"";
    print $fileHandle $axisId;
    print $fileHandle "\">";

    print $fileHandle "\n" if $niceOutput;
    $next_indent .= $more_indent;
  }

  # now dump our single node here
  print $fileHandle "$next_indent" if $niceOutput;
  print $fileHandle "<" . $self->classXMLNodeName;
  # print out attributes
  $self->_printAttributes($fileHandle, \@Class_XML_Attributes);
  print $fileHandle "/>";
  print $fileHandle "\n" if $niceOutput;

  #close the instructions
  for (reverse @indent) {
    print $fileHandle "$_" if $niceOutput;
    print $fileHandle "</$Untagged_Instruction_Node_Name>";
    print $fileHandle "\n" if $niceOutput;
  }

  # close the read block
  print $fileHandle "$indent" if $niceOutput;
  print $fileHandle "</" . $self->SUPER::classXMLNodeName . ">";
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

  # set these defaults. 
  $self->{delimiter} = $Def_Delimiter;
  $self->{repeatable} = $Def_Repeatable;
  $self->{recordTerminator} = $Def_Record_Terminator;

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Class_XML_Attributes);

}

# /** Returns (Perl) regular expression notation for reading in data. */
sub _regexNotation {
  my ($self) = @_;

  my $notation = '(.*?)[';
  
  $notation .= $self->{delimiter};
  $notation .= '|' . $self->{recordTerminator} . ']';
  $notation .= '+' if $self->{repeatable} eq 'yes';
  return $notation;
}

# /** Returns (Perl) sprintf expression notation for writing data. */
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%s' . $self->{delimiter};

  return $notation;
}

# Modification History
#
# $Log$
# Revision 1.13  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.12  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.11  2001/04/17 18:56:11  thomas
# Now using Specifiaction class.
# Properly calling superclass init now
#
# Revision 1.10  2001/03/26 18:10:58  thomas
# moved setWriteAxisORder list and getWriteAxisOrderList
# up to superclass. fixed toXMLFileHandle to write out
# AxisOrder in *reverse* of getWriteAxisOrder list (fastest
# axis should be written last, as the DTD proscribes).
#
# Revision 1.9  2001/03/23 20:38:40  thomas
# broke up printing of attributes in toXMLFileHandle
# so that toXMLString will work properly.
#
# Revision 1.8  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.7  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.6  2001/03/14 16:36:11  thomas
# No changes, just line layout changed.
#
# Revision 1.5  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.4  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.3  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::DelimitedXMLDataIOStyle - Perl Class for DelimitedXMLDataIOStyle

=head1 SYNOPSIS

...

=head1 DESCRIPTION

 XDF::DelimitedDataIOStyle is a class that indicates how delimited ASCII  records are to be read in. 

XDF::DelimitedXMLDataIOStyle inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::XMLDataIOStyle>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DelimitedXMLDataIOStyle.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DelimitedXMLDataIOStyle.

=over 4

=item getDelimiter (EMPTY)

 

=item setDelimiter ($value)

Set the delimiter attribute.  

=item getRepeatable (EMPTY)

 

=item setRepeatable ($value)

Set the repeatable attribute.  

=item getRecordTerminator (EMPTY)

 

=item setRecordTerminator ($value)

Set the recordTerminator attribute.  

=item toXMLFileHandle ($fileHandle, $junk, $indent)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::XMLDataIOStyle>:
B<untaggedInstructionNodeName>, B<getReadId{>, B<setReadId>, B<getReadIdRef>, B<setReadIdRef>, B<getEncoding{>, B<setEncoding>, B<getEndian{>, B<setEndian>, B<getWriteAxisOrderList>, B<setWriteAxisOrderList>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::XMLDataIOStyle>

=back

=head1 AUTHOR

 

=cut

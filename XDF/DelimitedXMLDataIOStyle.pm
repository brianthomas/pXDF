
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
my @My_XML_Attributes = qw (
                             delimiter
                             repeatable
                             recordTerminator
                          );
my @Class_XML_Attributes = @My_XML_Attributes;

my @Class_Attributes = qw (
                             writeAxisOrderList
                          );

## add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::XMLDataIOStyle::classAttributes};
push @Class_XML_Attributes, @{&XDF::XMLDataIOStyle::getXMLAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

sub classAttributes { 
  \@Class_Attributes; 
}

# 
# SET/GET Methods
#

# /** getDelimiter
# */
sub getDelimiter {
   my ($self) = @_;
   return $self->{Delimiter};
}

# /** setDelimiter
#     Set the delimiter attribute. 
# */
sub setDelimiter {
   my ($self, $value) = @_;
   $self->{Delimiter} = $value;
}

# /** getRepeatable
# */
sub getRepeatable {
   my ($self) = @_;
   return $self->{Repeatable};
}

# /** setRepeatable
#     Set the repeatable attribute. 
# */
sub setRepeatable {
   my ($self, $value) = @_;
   $self->{Repeatable} = $value;
}

# /** getRecordTerminator
# */
sub getRecordTerminator {
   my ($self) = @_;
   return $self->{RecordTerminator};
}

# /** setRecordTerminator
#     Set the recordTerminator attribute. 
# */
sub setRecordTerminator {
   my ($self, $value) = @_;
   $self->{RecordTerminator} = $value;
}

#/** getWriteAxisOrderList 
# This method sets the ordering of the fastest to slowest axis for
# writing out delimited data. The default is to use the parent array
# axisList ordering.
# */
sub getWriteAxisOrderList {
  my ($self) =@_;
  my $list_ref = $self->{WriteAxisOrderList}; 
  $list_ref = $self->{_parentArray}->getAxisList() unless 
      defined $list_ref || !defined $self->{_parentArray};
  return $list_ref;
} 

#/** setWriteAxisOrderList 
# This method sets the ordering of the fastest to slowest axis for
# writing out delimited data. The fastest axis is the last in
# the array.
# */
sub setWriteAxisOrderList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{WriteAxisOrderList} = \@list;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Other Public methods 
#

sub toXMLFileHandle {
  my ($self, $fileHandle, $junk, $indent) = @_;

  my $niceOutput = $self->Pretty_XDF_Output;

  $indent = "" unless defined $indent;
  my $more_indent = $self->Pretty_XDF_Output_Indentation;

  print $fileHandle "$indent" if $niceOutput;

  # open the read block, print attributes 
  print $fileHandle "<" . $self->SUPER::classXMLNodeName;
  # print out attributes
  $self->_printAttributes($fileHandle, $self->SUPER::classAttributes);
  print $fileHandle ">";
  print $fileHandle "\n" if $niceOutput;

  my @indent;
  my $Untagged_Instruction_Node_Name = $self->untaggedInstructionNodeName();
  my $next_indent = $indent . $more_indent;
  foreach my $axisObj (@{$self->getWriteAxisOrderList()}) {
    my $axisId = $axisObj->getAxisId();
    push @indent, $next_indent;
    print $fileHandle "$next_indent" if $niceOutput;
    print $fileHandle "<$Untagged_Instruction_Node_Name axisIdRef=\"$axisId\">";
    print $fileHandle "\n" if $niceOutput;
    $next_indent .= $more_indent;
  }

  # now dump our single node here
  print $fileHandle "$next_indent" if $niceOutput;
  print $fileHandle "<" . $self->classXMLNodeName;
  # print out attributes
  $self->_printAttributes($fileHandle, \@My_XML_Attributes);
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

  # set these defaults. 
  $self->{Delimiter} = $Def_Delimiter;
  $self->{Repeatable} = $Def_Repeatable;
  $self->{RecordTerminator} = $Def_Record_Terminator;

}

# /** Returns (Perl) regular expression notation for reading in data. */
sub _regexNotation {
  my ($self) = @_;

  my $notation = '(.*?)[';
  
  $notation .= $self->{Delimiter};
  $notation .= '|' . $self->{RecordTerminator} . ']';
  $notation .= '+' if $self->{Repeatable} eq 'yes';
  return $notation;
}

# /** Returns (Perl) sprintf expression notation for writing data. */
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%s' . $self->{Delimiter};

  return $notation;
}

# Modification History
#
# $Log$
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


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::DelimitedXMLDataIOStyle.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item writeAxisOrderList

 

=back

=head2 OTHER Methods

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

=item getWriteAxisOrderList (EMPTY)

This method sets the ordering of the fastest to slowest axis forwriting out delimited data. The default is to use the parent arrayaxisList ordering. 

=item setWriteAxisOrderList ($arrayRefValue)

This method sets the ordering of the fastest to slowest axis forwriting out delimited data. The fastest axis is the last inthe array. 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item toXMLFileHandle ($indent, $junk, $fileHandle)



=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>.

=back



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance methods of L<XDF::XMLDataIOStyle>:
B<untaggedInstructionNodeName>, B<getReadId{>, B<setReadId>, B<getReadIdRef>, B<setReadIdRef>, B<getEncoding{>, B<setEncoding>, B<getEndian{>, B<setEndian>.

=back

=back

=head1 SEE ALSO

L<XDF::XMLDataIOStyle>

=back

=head1 AUTHOR



=cut


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
#use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::XMLDataIOStyle");

# CLASS DATA

my $Def_Delimiter = " ";
my $Def_Repeatable = "yes";
my $Def_Record_Terminator = "\n";

my $Class_XML_Node_Name = "delimited";
# the order of these attributes IS important. 
# Note: _parentArray isnt needed by TextDelimiter, but is supplied for 
# compatablity w/ FormattedReadStyle (the other untagged Read style at this time)
my @Local_Class_XML_Attributes = qw (
                             delimiter
                             recordTerminator
                          );

my @Local_Class_Attributes = qw (
                             writeAxisOrderList
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
# Private/Protected methods 
#

sub _basicXMLWriter {
  my ($self, $fileHandle, $indent) = @_;

  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;

  $indent = "" unless defined $indent;
  my $more_indent = $spec->getPrettyXDFOutputIndentation;

  print $fileHandle $indent if $niceOutput;

  # open the read block, print attributes 
  print $fileHandle "<" . $self->SUPER::classXMLNodeName;
  # print out attributes
  $self->_printAttributes($fileHandle, $self->SUPER::getXMLAttributes);
  print $fileHandle ">";
  print $fileHandle "\n" if $niceOutput;

  my $next_indent = $indent . $more_indent;
  my $next_indent2 = $next_indent . $more_indent;
  my $next_indent3 = $next_indent2 . $more_indent;

  # print delimited info
  print $fileHandle $next_indent if $niceOutput;
  print $fileHandle "<" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

  print $fileHandle $next_indent2 if $niceOutput;
  print $fileHandle "<delimitedInstruction>";
  print $fileHandle "\n" if $niceOutput;

  # print attributes
  $self->getDelimiter()->_basicXMLWriter($fileHandle, $next_indent3);
  print $fileHandle "\n" if $niceOutput;
  $self->getRecordTerminator()->_basicXMLWriter($fileHandle, $next_indent3);
  print $fileHandle "\n" if $niceOutput;

  print $fileHandle $next_indent2 if $niceOutput;
  print $fileHandle "</delimitedInstruction>";
  print $fileHandle "\n" if $niceOutput;
  
  my @indent;
  my $Untagged_Instruction_Node_Name = $self->untaggedInstructionNodeName();
  #foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
 # we write this out in the *reverse* ordering. Why? because XDF
  # DTD wants the fastest axis to be *last*
  foreach my $axisObj (reverse @{$self->getWriteAxisOrderList()}) {
    my $axisId = $axisObj->getAxisId();
    push @indent, $next_indent2;
    print $fileHandle "$next_indent2" if $niceOutput;
    # next 3 lines: have to break up printing of '"' or toXMLString will behave badly
    print $fileHandle "<$Untagged_Instruction_Node_Name axisIdRef=\"";
    print $fileHandle $axisId;
    print $fileHandle "\">";

    print $fileHandle "\n" if $niceOutput;
    $next_indent2 .= $more_indent;
  }

  # now dump our single node here
  print $fileHandle $next_indent2 if $niceOutput;
  print $fileHandle "<doInstruction/>";
  print $fileHandle "\n" if $niceOutput;

  #close the instructions
  for (reverse @indent) {
    print $fileHandle "$_" if $niceOutput;
    print $fileHandle "</$Untagged_Instruction_Node_Name>";
    print $fileHandle "\n" if $niceOutput;
  }

  # close the whole block
  print $fileHandle $next_indent if $niceOutput;
  print $fileHandle "</" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

  print $fileHandle "$indent" if $niceOutput;
  print $fileHandle "</" . $self->SUPER::classXMLNodeName . ">";

}

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
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# /** Returns (Perl) regular expression notation for reading in data. */
sub _regexNotation {
  my ($self) = @_;

  my $notation = '(.*?)[';

  my $delimiterObj = $self->getDelimiter();
  
  $notation .= $delimiterObj->getStringValue();
  $notation .= '|' . $self->getRecordTerminator()->getStringValue() . ']';
  $notation .= '+' if $delimiterObj->getRepeatable() eq 'yes';
  return $notation;
}

# /** Returns (Perl) sprintf expression notation for writing data. */
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%s' . $self->getDelimiter->getStringValue();

  return $notation;
}

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

 

=item getClassAttributes (EMPTY)

 

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DelimitedXMLDataIOStyle.

=over 4

=item getDelimiter (EMPTY)

 

=item setDelimiter ($value)

Set the delimiter attribute.  

=item getRecordTerminator (EMPTY)

 

=item setRecordTerminator ($value)

Set the recordTerminator attribute.  

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
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::XMLDataIOStyle>:
B<untaggedInstructionNodeName>, B<getDataStyleId{>, B<setDataStyleId>, B<getDataStyleIdRef>, B<setDataStyleIdRef>, B<getEncoding{>, B<setEncoding>, B<getEndian{>, B<setEndian>, B<getWriteAxisOrderList>, B<setWriteAxisOrderList>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::XMLDataIOStyle>

=back

=head1 AUTHOR

 

=cut


# $Id$

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# NOTE: There appears to be some chaff still in this class. Clean it up!!

# /** COPYRIGHT
#    FormattedXMLDataIOStyle.pm Copyright (C) 2000 Brian Thomas,
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
# This class indicates how records are to be read in for formatted 
# (untagged) text format.
# */

# /** SEE ALSO
# XDF::XMLDataIOStyle
# */

package XDF::FormattedXMLDataIOStyle;

use XDF::BaseObject;
use XDF::Constants;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::XMLDataIOStyle
@ISA = ("XDF::XMLDataIOStyle");

# private 
my %XDF_node_name = &XDF::Constants::XDF_NODE_NAMES;
my $InstructionNodeName = $XDF_node_name{'formattedReadInstructions'};

# CLASS DATA
my $Class_XML_Node_Name = "fixedWidth";
my @Local_Class_XML_Attributes = qw (
                                 formatCmdList
                              );
my @Local_Class_Attributes = qw (
                          );
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::XMLDataIOStyle::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::XMLDataIOStyle::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName {
  $Class_XML_Node_Name;
}

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FloatDataFormat. 
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

# /** getFormatCmdList
#  */
sub getFormatCmdList {
   my ($self) = @_;
   return $self->{formatCmdList};
}

# /** setFormatCmdList
#  */
sub setFormatCmdList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{formatCmdList} = \@list;
}

#sub getFormatCommands {
#  my ($self) = @_;
#  return $self->getFormatCmdList();
#}

#sub getFormatCommand {
#  my ($self, $index, $expandRepeatCommands) = @_;
#
#  return unless defined $index && $index >= 0;
#
#  my @list;
#  if ($expandRepeatCommands) {
#    @list = $self->getCommands();
#  } else { 
#    @list = $self->getFormatCommands();
#  }
#
#  return $list[$index];
#}

# /** getCommands
#    This convenience method returns the command list (as
#    an ARRAY Ref). Repeat commands are expanded into their 
#    component parts.  
# */
sub getCommands () {
  my ($self) = @_;

  my @commandList = ();

  foreach my $obj (@{$self->{formatCmdList}}) {
     if (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
       my $count = $obj->getCount();
       my @repeatCommandList = $obj->getCommands();
       while ($count-- > 0) {
          push @commandList, @repeatCommandList;
       }
     } else {
        push @commandList, $obj;
     }
   }

   return @commandList;
}

sub numOfBytes {
  my ($self) = @_;

  my $bytes = 0;

  my @dataFormatList = $self->{_parentArray}->getDataFormatList();

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant determine Formatted ReadStyle byte size w/o defined dataFormat.\n";
    return;
  }

  foreach my $obj ($self->getCommands()) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $bytes += $readObj->numOfBytes();
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $bytes += $obj->numOfBytes();
    } else {
      warn "Unknown format cmd in $self bytes: $obj, ignoring\n";
    }
  }

  return $bytes;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
#sub getXMLAttributes {
#  return \@Class_XML_Attributes;
#}

#
# Other Public Methods
#

# /** addFormatCommand
# Add a FormattedIOCmd object to the list in this object.
# These child objects are used to direct how the XDF formatted
# data should be read in.
# Returns 1 on success, 0 on failure. 
# */
#
sub addFormatCommand {
  my ($self, $obj) = @_;

  return 0 unless defined $obj && ref $obj;

  # push into our array
  push @{$self->{formatCmdList}}, $obj;

  return 1;
}

#
# Protected/Private methods
#

sub _basicXMLWriter {
  my ($self, $fileHandle, $indent) = @_;

  my $spec = XDF::Specification->getInstance();
  my $niceOutput = $spec->isPrettyXDFOutput;

  $indent = "" unless defined $indent;
  my $more_indent = $spec->getPrettyXDFOutputIndentation;

  my $next_indent = $indent . $more_indent;
  my $next_indent2 = $next_indent . $more_indent;
  my $next_indent3 = $next_indent2 . $more_indent;

  print $fileHandle "$indent" if $niceOutput;

  # open the read block, print attributes 
  print $fileHandle "<" . $self->SUPER::classXMLNodeName;
  # print out attributes
  $self->_printAttributes($fileHandle, $self->SUPER::getXMLAttributes);
  print $fileHandle ">";
  print $fileHandle "\n" if $niceOutput;

  print $fileHandle $next_indent if $niceOutput;
  print $fileHandle "<" . $self->classXMLNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

  print $fileHandle $next_indent2 if $niceOutput;
  print $fileHandle "<" . $InstructionNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

  # now dump our format commands here the trusty generic method
  for (@{$self->getFormatCmdList()}) {
     $_->toXMLFileHandle($fileHandle, $next_indent3);
  }

  print $fileHandle $next_indent2 if $niceOutput;
  print $fileHandle "</" . $InstructionNodeName . ">";
  print $fileHandle "\n" if $niceOutput;

  my @indent;
  my $Untagged_Instruction_Node_Name = $self->untaggedInstructionNodeName();
  #foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
  # we write this out in the *reverse* ordering. Why? because XDF
  # DTD wants the fastest axis to be *last*
  foreach my $axisObj (reverse @{$self->getWriteAxisOrderList()}) {
    my $axisId = $axisObj->getAxisId();
    push @indent, $next_indent2;
    print $fileHandle $next_indent2 if $niceOutput;
    # next 3 lines: have to break up printing of '"' or toXMLString will behave badly
    print $fileHandle "<$Untagged_Instruction_Node_Name axisIdRef=\"";
    print $fileHandle $axisId;
    print $fileHandle "\">";
    print $fileHandle "\n" if $niceOutput;
    $next_indent2 .= $more_indent;
  }

  print $fileHandle $next_indent2 if $niceOutput;
  print $fileHandle "<doInstruction/>";
  print $fileHandle "\n" if $niceOutput;

  #close the instructions
  for (reverse @indent) {
    print $fileHandle "$_" if $niceOutput;
    print $fileHandle "</$Untagged_Instruction_Node_Name>";
    print $fileHandle "\n" if $niceOutput;
  }

  # close the read block

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

  # set defaults
  $self->{formatCmdList} = []; 

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _regexNotation {
  my ($self) = @_;
  my $notation;

  my @dataFormatList = $self->{_parentArray}->getDataFormatList();

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj ($self->getCommands()) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $notation .= $readObj->_regexNotation();
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $notation .= $obj->_regexNotation();
    } else {
      warn "Unknown format cmd in $self _regexNotation: $obj, ignoring\n";
    }
  }

  return $notation;

}

# this is only called from dataCube
sub _outputSkipCharArray { 
  my ($self) =@_; 
  my @outArray;

  my @dataFormatList = $self->{_parentArray}->getDataFormatList();
  
  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }
  
  foreach my $obj ($self->getCommands()) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      push @outArray, undef; # push in a holding spot for the data
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      push @outArray, $obj->getOutput();
    } else {
      warn "Unknown format cmd in $self outputSkipCharArray $obj, ignoring\n";
    }
  }

  return @outArray;
}

sub _templateNotation {
  my ($self, $input) = @_;

  my $notation;
  my $endian = $self->getEndian();
  my $encoding = $self->getEncoding();

  my @dataFormatList = $self->{_parentArray}->getDataFormatList();

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj ($self->getCommands()) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $notation .= $readObj->_templateNotation($endian,$encoding,$input);
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $notation .= $obj->_templateNotation($endian,$encoding,$input);
    } else { 
      # everything else, which nothing right now, so throw an error
      warn "Got weird formattedIOCmd in $self : $obj , ignoring it.\n";
    }
  }

  return $notation;

}

sub _sprintfNotation {
  my ($self) = @_;
  my $notation;

  my @dataFormatList = $self->{_parentArray}->getDataFormatList();

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj ($self->getCommands()) {
   if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $notation .= $readObj->_sprintfNotation(); 
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $notation .= $obj->_sprintfNotation(); 
    } else {
      warn "Got weird formattedIOCmd in $self : $obj , ignoring it.\n";
    }
  }

  return $notation;
}

1;



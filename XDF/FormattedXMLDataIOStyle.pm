
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
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::XMLDataIOStyle
@ISA = ("XDF::XMLDataIOStyle");

# CLASS DATA
my @Class_XML_Attributes = qw (
                                 formatCmdList
                              );
my @Class_Attributes = qw (
                             writeAxisOrderList
                          );

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::XMLDataIOStyle::classAttributes};
push @Class_XML_Attributes, @{&XDF::XMLDataIOStyle::getXMLAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes for XDF::Structure; 
# */
sub classAttributes {
  return \@Class_Attributes;
}

#
# Get/Set Methods
#

# /** getFormatCmdList
#  */
sub getFormatCmdList {
   my ($self) = @_;
   return $self->{FormatCmdList};
}

# /** setFormatCmdList
#  */
sub setFormatCmdList {
   my ($self, $value) = @_;
   $self->{FormatCmdList} = $value;
}

sub getFormatCommands {
  my ($self) = @_;
  return $self->getFormatCmdList();
}

sub getFormatCommand {
  my ($self, $index, $expandRepeatCommands) = @_;

  return unless defined $index && $index >= 0;

  my @list;
  if ($expandRepeatCommands) {
    @list = @{$self->getCommands()};
  } else { 
    @list = $self->getFormatCommands();
  }

  return $list[$index];
}

#/** getWriteAxisOrderList 
# This method sets the ordering of the fastest to slowest axis for
# writing out formatted data. The default is to use the parent array
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
# writing out formatted data. The fastest axis is the last in
# the array.
# */
sub setWriteAxisOrderList {
  my ($self, $arrayRefValue) = @_;
  $self->{WriteAxisOrderList} = $arrayRefValue;
}

# /** getCommands
#    This convenience method returns the command list (as
#    an ARRAY Ref). Repeat commands are expanded into their 
#    component parts.  
# */
sub getCommands () {
  my ($self) = @_;

  my @commandList = ();

  foreach my $obj (@{$self->{FormatCmdList}}) {
     if (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
       my $count = $obj->getCount();
       my @repeatCommandList = @{$obj->getCommands()};
       while ($count-- > 0) {
          push @commandList, @repeatCommandList;
       }
     } else {
        push @commandList, $obj;
     }
   }

   return \@commandList;
}

sub getBytes {
  my ($self) = @_;

  my $bytes = 0;

  my @dataFormatList = $self->{_parentArray}->getDataFormatList();

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant determine Formatted ReadStyle byte size w/o defined dataFormat.\n";
    return;
  }

  foreach my $obj (@{$self->getCommands()}) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $bytes += $readObj->getBytes();
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $bytes += $obj->getBytes();
    } else {
      warn "Unknown format cmd in $self bytes: $obj, ignoring\n";
    }
  }

  return $bytes;
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes {
  return \@Class_XML_Attributes;
}

#
# Other Public Methods
#

# perhaps we should be adding full-blown objects here, but
# it doesnt seem to be justified. 
sub addFormatCommand {
  my ($self, $obj) = @_;

  return unless defined $obj && ref $obj;

  # push into our array
  push @{$self->{FormatCmdList}}, $obj;

  return $obj;
}

# Is this needed still? -b.t.
sub hasSpecialIntegers {
  my ($self) = @_;
  my @dataFormatList = $self->{_parentArray}->getDataFormatList();

  if (!@dataFormatList) {
    carp "Error: cant look for special type IntegerFields w/o defined dataFormat\n";
  }

  foreach my $dataType (@dataFormatList) {
    if (ref($dataType) eq 'XDF::IntegerField') {
      return 1 if $dataType->getType() ne $dataType->typeDecimal; 
    }
  }

  return 0;
}

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

  # now dump our format commands here the trusty generic method
  for (@{$self->getFormatCmdList()}) {
     $_->toXMLFileHandle($fileHandle, $junk, $next_indent);
  }

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
# Private Methods (note stuff like *Notation methods arent really private or protected. bleh) 
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

  # set defaults
  $self->{FormatCmdList} = []; 

}

sub _regexNotation {
  my ($self) = @_;
  my $notation;

  my @dataFormatList = $self->{_parentArray}->getDataFormatList();

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj (@{$self->getCommands()}) {
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
  
  foreach my $obj (@{$self->getCommands()}) {
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

  foreach my $obj (@{$self->getCommands()}) {
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

  foreach my $obj (@{$self->getCommands()}) {
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


# Modification History
#
# $Log$
# Revision 1.5  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.4  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.3  2000/11/28 19:39:10  thomas
# Fix to formatted  reads. Implemented getCommands
# method. -b.t.
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

XDF::FormattedXMLDataIOStyle - Perl Class for FormattedXMLDataIOStyle

=head1 SYNOPSIS

...

=head1 DESCRIPTION

 This class indicates how records are to be read in for formatted  (untagged) text format. 

XDF::FormattedXMLDataIOStyle inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::XMLDataIOStyle>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FormattedXMLDataIOStyle.

=over 4

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes for XDF::Structure;  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item writeAxisOrderList

 

=back

=head2 OTHER Methods

=over 4

=item getFormatCmdList (EMPTY)



=item setFormatCmdList ($value)



=item getFormatCommands (EMPTY)



=item getFormatCommand ($expandRepeatCommands, $index)



=item getWriteAxisOrderList (EMPTY)

This method sets the ordering of the fastest to slowest axis forwriting out formatted data. The default is to use the parent arrayaxisList ordering. 

=item setWriteAxisOrderList ($arrayRefValue)

This method sets the ordering of the fastest to slowest axis forwriting out formatted data. The fastest axis is the last inthe array. 

=item getCommands (EMPTY)

This convenience method returns the command list (asan ARRAY Ref). Repeat commands are expanded into their component parts.  

=item getBytes (EMPTY)



=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item addFormatCommand ($obj)



=item hasSpecialIntegers (EMPTY)



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

XDF::FormattedXMLDataIOStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FormattedXMLDataIOStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFile>.

=back



=over 4

XDF::FormattedXMLDataIOStyle inherits the following instance methods of L<XDF::XMLDataIOStyle>:
B<untaggedInstructionNodeName>, B<getReadId{>, B<setReadId>, B<getReadIdRef>, B<setReadIdRef>, B<getEncoding{>, B<setEncoding>, B<getEndian{>, B<setEndian>.

=back

=back

=head1 SEE ALSO

L< XDF::XMLDataIOStyle>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

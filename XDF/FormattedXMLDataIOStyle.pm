
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
  $self->_printAttributes($fileHandle, $self->SUPER::getXMLAttributes);
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


# Modification History
#
# $Log$
# Revision 1.21  2001/08/13 19:48:30  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.20  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.19  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.18  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.17  2001/04/17 19:00:10  thomas
# Using Specification class now.
# Properly calling superclass init now.
#
# Revision 1.16  2001/03/26 18:11:15  thomas
# moved setWriteAxisORder list and getWriteAxisOrderList
# up to superclass. fixed toXMLFileHandle to write out
# AxisOrder in *reverse* of getWriteAxisOrder list (fastest
# axis should be written last, as the DTD proscribes).
#
# Revision 1.15  2001/03/23 20:38:40  thomas
# broke up printing of attributes in toXMLFileHandle
# so that toXMLString will work properly.
#
# Revision 1.14  2001/03/16 19:54:56  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.13  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.12  2001/03/14 21:30:21  thomas
# Removed getFormatCommands.
#
# Revision 1.11  2001/03/14 16:41:48  thomas
# removed self->WriteReadAxisOrder in _init
# because _parentArray may not be defined.
#
# Revision 1.10  2001/03/14 16:36:31  thomas
# No changes, just line layout changed.
#
# Revision 1.9  2001/03/09 21:54:59  thomas
# removed hasSPecialIntegers method. Now code is in reader.
#
# Revision 1.8  2001/03/07 23:12:00  thomas
# getCommands changed to return ARRAY instead of ARRAY ref.
#
# Revision 1.7  2001/02/15 17:50:31  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.6  2000/12/15 22:12:00  thomas
# Regenerated perlDoc section in files. -b.t.
#
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


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::FormattedXMLDataIOStyle.

=over 4

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes for XDF::Structure;  

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::FormattedXMLDataIOStyle.

=over 4

=item getFormatCmdList (EMPTY)

 

=item setFormatCmdList ($arrayRefValue)

 

=item getCommands (EMPTY)

This convenience method returns the command list (asan ARRAY Ref). Repeat commands are expanded into their component parts.   

=item numOfBytes (EMPTY)

 

=item addFormatCommand ($obj)

 

=item toXMLFileHandle ($fileHandle, $junk, $indent)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::FormattedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::FormattedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::FormattedXMLDataIOStyle inherits the following instance (object) methods of L<XDF::XMLDataIOStyle>:
B<untaggedInstructionNodeName>, B<getReadId{>, B<setReadId>, B<getReadIdRef>, B<setReadIdRef>, B<getEncoding{>, B<setEncoding>, B<getEndian{>, B<setEndian>, B<getWriteAxisOrderList>, B<setWriteAxisOrderList>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::XMLDataIOStyle>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

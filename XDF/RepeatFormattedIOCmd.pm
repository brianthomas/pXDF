
# $Id$

package XDF::RepeatFormattedIOCmd;

# /** COPYRIGHT
#    RepeatFormattedIOCmd.pm Copyright (C) 2000 Brian Thomas,
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


use XDF::FormattedIOCmd;
use Carp;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::FormattedIOCmd");

# CLASS DATA
my $Def_Count = 1;
my $Class_XML_Node_Name = "repeat";
my @Class_XML_Attributes = qw (
                             count
                             formatCmdList
                          );
my @Class_Attributes = ();

# add in super class XML attributes
push @Class_XML_Attributes, @{&XDF::FormattedIOCmd::getClassXMLAttributes};

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::FormattedIOCmd::getClassAttributes};

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

# /** getCount
# */
sub getCount {
   my ($self) = @_;
   return $self->{count};
}

# /** setCount
#     Set the count attribute. 
# */
sub setCount {
   my ($self, $value) = @_;
   $self->{count} = $value;
}

# /** getFormatCmdList
# */
sub getFormatCmdList {
   my ($self) = @_;
   return $self->{formatCmdList};
}

# /** setFormatCmdList
#     Set the formatCmdList attribute. 
# */
sub setFormatCmdList {
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{formatCmdList} = \@list;
}

sub numOfBytes {
  my ($self, $dataFormatListRef ) = @_;

  my $bytes = 0;

  my @dataFormatList = @{$dataFormatListRef};

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
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
      # everything else, which nothing right now, so throw an error
      warn "Got weird formattedIOCmd in $self : $obj , ignoring it.\n";
    }
  }

  return ($bytes, \@dataFormatList);
}

# /** Convenience method that returns the command list. Repeat
#    commands are expanded into their component parts. 
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

#
# Other Public MEthods
#

#/** addFormatCommand
# Returns 1 on succes, 0 on failure.
# */
sub addFormatCommand {
  my ($self, $obj) = @_;

  return 0 unless defined $obj && ref $obj;

  # push into our array
  push @{$self->{formatCmdList}}, $obj;

  return 1;
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

   $self->setFormatCmdList([]);
   $self->setCount($Def_Count);

   # adds to ordered list of XML attributes
   $self->_appendAttribsToXMLAttribOrder(\@Class_XML_Attributes);

}

# this is only called from dataCube
sub _outputSkipCharArray {        
  my ($self, $dataFormatListRef) = @_;

  my @outArray;

  my @dataFormatList = @{$dataFormatListRef};

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj (@{$self->{formatCmdList}}) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      push @outArray, undef; # push in a holding spot for the data
    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
      my ($arr_ref, $dataListRef) = $obj->_outputSkipCharArray(\@dataFormatList);
      @dataFormatList = @{$dataListRef};
      push @outArray, @{$arr_ref};
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      push @outArray, $obj->getOutput();
    } else {
      warn "Unknown format cmd in $self : $obj\n";
    }
  }
  
  my @repeat_array = @outArray;
  for (my $x = 1; $x <= ($self->getCount - 1); $x++) { push @outArray, @repeat_array; }

  return (\@outArray, \@dataFormatList);
}

sub _templateNotation {
  my ($self, $dataFormatListRef, $endian, $encoding, $input ) = @_;

  my $notation; my @dataFormatList;

  if (!defined $dataFormatListRef 
       or !(@dataFormatList = @{$dataFormatListRef}) 
       or $#dataFormatList < 0) 
  {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }
  

  foreach my $obj (@{$self->{formatCmdList}}) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
print STDERR "Repeat add notation:[".$readObj->_templateNotation($endian,$encoding,$input)."]\n"; 
      $notation .= $readObj->_templateNotation($endian,$encoding,$input); 
    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
      my ($repeat_notation, $dataListRef) = $obj->_templateNotation(\@dataFormatList, $endian, $encoding, $input);
      @dataFormatList = @{$dataListRef};
      $notation .= $repeat_notation;
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $notation .= $obj->_templateNotation($endian,$encoding,$input);
    } else {
      warn "Unknown format cmd in $self : $obj\n";
    }
  }

  my $repeat_notation = $notation;
  for (my $x = 1; $x <= ($self->getCount() - 1); $x++) { $notation .= $repeat_notation; }

print STDERR "Repeat gets notation:[".$notation."]\n"; 
  return ($notation, \@dataFormatList);
}

sub _regexNotation {
  my ($self, $dataFormatListRef) = @_;
  my $notation;

  my @dataFormatList = @{$dataFormatListRef};

  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj (@{$self->{formatCmdList}}) { 
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $notation .= $readObj->_regexNotation();
    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
      my ($repeat_notation, $dataListRef) = $obj->_regexNotation(\@dataFormatList); 
      @dataFormatList = @{$dataListRef};
      $notation .= $repeat_notation;
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $notation .= $obj->_regexNotation();
    } else {
      warn "Got weird formattedIOCmd in $self : $obj , ignoring it.\n";
    }
  }

  my $repeat_notation = $notation;
  for (my $x = 1; $x <= ($self->getCount() - 1); $x++) { $notation .= $repeat_notation; }

  return ($notation, \@dataFormatList);

}

sub _sprintfNotation {
  my ($self, $listRef) = @_;
  my $notation;
  
  my @dataFormatList = @{$listRef};
  
  if (!@dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }
  
  foreach my $obj (@{$self->{formatCmdList}}) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $notation .= $readObj->_sprintfNotation();
    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
      my ($repeat_notation, $dataListRef) = $obj->_sprintfNotation(\@dataFormatList);
      @dataFormatList = @{$dataListRef};
      $notation .= $repeat_notation;
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $notation .= $obj->_sprintfNotation();
    } else {
      warn "Got weird formattedIOCmd in $self : $obj , ignoring it.\n";
    }
  }

  my $repeat_notation = $notation;
  for ( my $x = 1; $x <= ($self->getCount() - 1); $x++) { $notation .= $repeat_notation; }

  return ($notation, \@dataFormatList);

}

# Modification History
#
# $Log$
# Revision 1.15  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.14  2001/06/29 21:07:12  thomas
# changed public add (and remove) methods to
# conform to Java API standard: e.g. return boolean
# rather than an object. Also, these methods only
# accept an object (in general) as input (instead of an attribute hash).
#
# Revision 1.13  2001/04/25 16:01:31  thomas
# updated documentation
#
# Revision 1.12  2001/04/17 18:55:20  thomas
# Properly calling superclass init now
#
# Revision 1.11  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.10  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.9  2001/03/07 23:11:23  thomas
# getCommands returns ARRAY rather than ARRAY REF.
#
# Revision 1.8  2001/02/15 17:50:30  thomas
# changed getBytes to numOfBytes method as per
# java API.
#
# Revision 1.7  2001/01/02 17:41:46  thomas
# changed 1 .. $number statements in methods
# in anticipation of running package on platforms
# with small or no virtual memory. -b.t.
#
# Revision 1.6  2000/12/15 22:11:59  thomas
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
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::RepeatFormattedIOCmd - Perl Class for RepeatFormattedIOCmd

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::RepeatFormattedIOCmd inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::FormattedIOCmd>, L<XDF::BaseObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::RepeatFormattedIOCmd.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::RepeatFormattedIOCmd.

=over 4

=item getCount (EMPTY)

 

=item setCount ($value)

Set the count attribute.  

=item getFormatCmdList (EMPTY)

 

=item setFormatCmdList ($arrayRefValue)

Set the formatCmdList attribute.  

=item numOfBytes ($dataFormatListRef)

 

=item getCommands (EMPTY)

 

=item addFormatCommand ($obj)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::RepeatFormattedIOCmd inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::RepeatFormattedIOCmd inherits the following instance (object) methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::FormattedIOCmd>

=back

=head1 AUTHOR

 

=cut

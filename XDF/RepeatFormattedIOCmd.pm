
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
use XDF::Log;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::FormattedIOCmd");

# CLASS DATA
my $Def_Count = 1;
my $Class_XML_Node_Name = "repeat";
my @Local_Class_XML_Attributes = qw (
                             count
                             formatCmdList
                          );
my @Local_Class_Attributes = ();
my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::FormattedIOCmd::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::FormattedIOCmd::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;


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
    error("Error: cant read Formatted ReadStyle w/o defined dataFormat\n");
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
      error("Got weird formattedIOCmd in $self : $obj , ignoring it.\n");
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
   $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

# this is only called from dataCube
sub _outputSkipCharArray {        
  my ($self, $dataFormatListRef) = @_;

  my @outArray;

  my @dataFormatList = @{$dataFormatListRef};

  if (!@dataFormatList or $#dataFormatList < 0) {
    error("Error: cant read Formatted ReadStyle w/o defined dataFormat\n");
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
      error("Unknown format cmd in $self : $obj\n");
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
    error("Cant read Formatted ReadStyle w/o defined dataFormat\n");
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
      error("Unknown format cmd in $self : $obj\n");
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
    error("Error: cant read Formatted ReadStyle w/o defined dataFormat\n");
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
      error("Got weird formattedIOCmd in $self : $obj , ignoring it.\n");
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
    error("Error: cant read Formatted ReadStyle w/o defined dataFormat\n");
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
      error("Got weird formattedIOCmd in $self : $obj , ignoring it.\n");
    }
  }

  my $repeat_notation = $notation;
  for ( my $x = 1; $x <= ($self->getCount() - 1); $x++) { $notation .= $repeat_notation; }

  return ($notation, \@dataFormatList);

}

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

 

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::FloatDataFormat. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

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

Returns 1 on succes, 0 on failure.  

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
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::FormattedIOCmd>

=back

=head1 AUTHOR

 

=cut


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
my @Class_Attributes = qw (
                             count
                             formatCmdList
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::FormattedIOCmd::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

sub classAttributes { 
  \@Class_Attributes; 
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
   $self->formatCmdList([]);
   $self->count($Def_Count);
}

sub addFormatCommand {
  my ($self, $obj) = @_;

  return unless defined $obj && ref $obj;

  # push into our array
  push @{$self->formatCmdList}, $obj;

  return $obj;
}

# /** Convenience method that returns the command list. Repeat
#    commands are expanded into their component parts. 
# */
sub getCommands () {
  my ($self) = @_;

  my @commandList = ();

  foreach my $obj (@{$self->formatCmdList}) {
     if (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
       my $count = $obj->count();
       while ($count-- > 0) {
          push @commandList, $obj->getCommands();
       }
     } else {
        push @commandList, $obj;
     }
   }

   return @commandList;
}

sub bytes {
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
      $bytes += $readObj->bytes;
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $bytes += $obj->bytes;
    } else {
      # everything else, which nothing right now, so throw an error
      warn "Got weird formattedIOCmd in $self : $obj , ignoring it.\n";
    }
  }

  return ($bytes, \@dataFormatList);
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

  foreach my $obj (@{$self->formatCmdList}) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      push @outArray, undef; # push in a holding spot for the data
    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
      my ($arr_ref, $dataListRef) = $obj->_outputSkipCharArray(\@dataFormatList);
      @dataFormatList = @{$dataListRef};
      push @outArray, @{$arr_ref};
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      push @outArray, $obj->output;
    } else {
      warn "Unknown format cmd in $self : $obj\n";
    }
  }
  
  my @repeat_array = @outArray;
  for (1 .. ($self->count - 1)) { push @outArray, @repeat_array; }

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
  

  foreach my $obj (@{$self->formatCmdList}) {
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
  for (1 .. ($self->count - 1)) { $notation .= $repeat_notation; }

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

  foreach my $obj (@{$self->formatCmdList}) { 
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
  for (1 .. ($self->count - 1)) { $notation .= $repeat_notation; }

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
  
  foreach my $obj (@{$self->formatCmdList}) {
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
  for (1 .. ($self->count - 1)) { $notation .= $repeat_notation; }

  return ($notation, \@dataFormatList);

}

# Modification History
#
# $Log$
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


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::RepeatFormattedIOCmd.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item count

 

=item formatCmdList

 

=back

=head2 OTHER Methods

=over 4

=item addFormatCommand ($obj)



=item getCommands (EMPTY)



=item bytes ($dataFormatListRef)



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

XDF::RepeatFormattedIOCmd inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::RepeatFormattedIOCmd inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::FormattedIOCmd>

=back

=head1 AUTHOR



=cut

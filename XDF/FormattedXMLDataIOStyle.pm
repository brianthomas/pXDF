
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

my @Class_Attributes = qw (
                             formatCmdList
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::XMLDataIOStyle::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

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

  # set these defaults. 
  $self->formatCmdList([]); 

}

# perhaps we should be adding full-blown objects here, but
# it doesnt seem to be justified. 
sub addFormatCommand {
  my ($self, $obj) = @_;

  return unless defined $obj && ref $obj;

  # push into our array
  push @{$self->formatCmdList}, $obj;

  return $obj;
}

sub getFormatCommands { 
  my ($self) = @_; 
  return @{$self->formatCmdList}; 
}

sub getFormatCommand {
  my ($self, $index) = @_;

  return unless defined $index && $index >= 0;
  my $this_index = 0;
  my $obj;
  ($obj, $this_index) = &_do_search_for_Text_Format_Cmd($self, $this_index, $index);

  return $obj if $this_index == $index;

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


# VERY Sloppy and hasty algorithm. Needs to be redone. In fact, the
# idea of separate skipChar, Text and Repeat format command objects is bad. 
sub _do_search_for_Text_Format_Cmd { 
    my ($obj, $this_index, $index) = @_;

    while (@{$obj->formatCmdList}) {
      my $obj = $_;

      if($obj =~ m/XDF::Repeat/) {
        my @list = $obj->getFormatCommands();
        my $count = $obj->count;
        while ($count-- > 0) {
          $this_index += $#list;
          if ($this_index >= $index) {
            my $no = $#list - ($this_index - $index);
            $obj = $list[$no];
   
            ($obj, $this_index) = &_do_search_for_Text_Format_Cmd($obj, $this_index, $index)
               if ($obj =~ m/XDF::Repeat/);
            return ($obj, $this_index);
          }
        } 

      } else { 
        return ($obj, $this_index) if $this_index == $index;
      }
      $this_index++;
    }

    return ($obj, $this_index);
}

sub _regexNotation {
  my ($self) = @_;
  my $notation;

  my @dataFormatList = $self->_parentArray->dataFormatList;

  if (!defined @dataFormatList or $#dataFormatList < 0) {
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
      warn "Unknown format cmd in $self _regexNotation: $obj, ignoring\n";
    }
  }
#  $notation .= $self->recordTerminator;
  return $notation;

}

sub bytes { 
  my ($self) = @_; 

  my $bytes = 0;
 
  my @dataFormatList = $self->_parentArray->dataFormatList;

  if (!defined @dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant determine Formatted ReadStyle byte size w/o defined dataFormat.\n";
    return;
  }

  foreach my $obj ($self->getCommands()) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $bytes += $readObj->bytes;
#    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
#      my ($repeat_byte_size, $dataListRef) = $obj->bytes(\@dataFormatList);
#      @dataFormatList = @{$dataListRef};
#      $bytes += $repeat_byte_size;
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $bytes += $obj->bytes;
    } else {
      warn "Unknown format cmd in $self bytes: $obj, ignoring\n";
    }
  }

  return $bytes;
} 

sub hasSpecialIntegers {
  my ($self) = @_;
  my @dataFormatList = $self->_parentArray->dataFormatList;

  if (!defined @dataFormatList) {
    carp "Error: cant look for special type IntegerFields w/o defined dataFormat\n";
  }

  foreach my $dataType (@dataFormatList) {
    if (ref($dataType) eq 'XDF::IntegerField') {
      return 1 if $dataType->type ne $dataType->typeDecimal; 
    }
  }

  return 0;
}

# this is only called from dataCube
sub _outputSkipCharArray { 
  my ($self) =@_; 
  my @outArray;

  my @dataFormatList = $self->_parentArray->dataFormatList;
  
  if (!defined @dataFormatList or $#dataFormatList < 0) {
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
      warn "Unknown format cmd in $self outputSkipCharArray $obj, ignoring\n";
    }
  }

  return @outArray;
}

sub _OldtemplateNotation {
  my ($self, $input) = @_;
 
  my $notation;
  my $endian = $self->endian;
  my $encoding = $self->encoding;

  my @dataFormatList = $self->_parentArray->dataFormatList;

  if (!defined @dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj (@{$self->formatCmdList}) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $notation .= $readObj->_templateNotation($endian,$encoding,$input);
    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
      my ($repeat_notation, $dataListRef) = $obj->_templateNotation(\@dataFormatList,$endian,$encoding, $input);
      @dataFormatList = @{$dataListRef};
      $notation .= $repeat_notation;
    } elsif (ref($obj) eq 'XDF::SkipCharFormattedIOCmd') {
      $notation .= $obj->_templateNotation($endian,$encoding,$input);
    } else { 
      # everything else, which nothing right now, so throw an error
      warn "Got weird formattedIOCmd in $self : $obj , ignoring it.\n";
    }
  }

  return $notation;

}

sub _templateNotation {
  my ($self, $input) = @_;

  my $notation;
  my $endian = $self->endian;
  my $encoding = $self->encoding;

  my @dataFormatList = $self->_parentArray->dataFormatList;

  if (!defined @dataFormatList or $#dataFormatList < 0) {
    carp "Error: cant read Formatted ReadStyle w/o defined dataFormat\n";
    return;
  }

  foreach my $obj ($self->getCommands()) {
    if(ref($obj) eq 'XDF::ReadCellFormattedIOCmd') {
      my $readObj = shift @dataFormatList;
      push (@dataFormatList, $readObj); # its a circular list
      $notation .= $readObj->_templateNotation($endian,$encoding,$input);
    } elsif (ref($obj) eq 'XDF::RepeatFormattedIOCmd') {
      my ($repeat_notation, $dataListRef) = $obj->_templateNotation(\@dataFormatList,$endian,$encoding, $input);
      @dataFormatList = @{$dataListRef};
      $notation .= $repeat_notation;
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

  my @dataFormatList = $self->_parentArray->dataFormatList;

  if (!defined @dataFormatList or $#dataFormatList < 0) {
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

  return $notation;
}


# Modification History
#
# $Log$
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

XDF::FormattedXMLDataIOStyle inherits class and attribute methods of L<XDF::BaseObject>, L<XDF::GenericObject>, L<XDF::XMLDataIOStyle>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::FormattedXMLDataIOStyle.

=over 4

=item classAttributes (EMPTY)

 

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item formatCmdList

 

=back

=head2 OTHER Methods

=over 4

=item addFormatCommand ($obj)



=item getFormatCommands (EMPTY)



=item getFormatCommand ($index)



=item bytes (EMPTY)



=item hasSpecialIntegers (EMPTY)



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

XDF::FormattedXMLDataIOStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFile>.

=back



=over 4

XDF::FormattedXMLDataIOStyle inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::FormattedXMLDataIOStyle inherits the following instance methods of L<XDF::XMLDataIOStyle>:
B<toXMLFileHandle>.

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


# $Id$

# ok ok, Im lazy. I should have this as an object. I'll fix later if
# its an issue. -b.t.

package XDF::ReadCellFormattedIOCmd;

# /** COPYRIGHT
#    ReadCellFormattedIOCmd.pm Copyright (C) 2000 Brian Thomas,
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

# inherits from XDF::Object
@ISA = ("XDF::FormattedIOCmd");

# CLASS DATA
my $Class_XML_Node_Name = "readCell";
my @Class_Attributes = qw ( 
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

# Protected method
sub _templateNotation {
  my ($self, $dataFormatListRef, $endian, $encoding, $input ) = @_;
}

# Protected method
sub _regexNotation {
  my ($self, $dataFormatListRef) = @_;
}

# Protected method
sub _sprintfNotation {
  my ($self, $listRef) = @_;
}

1;


__END__

=head1 NAME

XDF::ReadCellFormattedIOCmd - Perl Class for ReadCellFormattedIOCmd

=head1 SYNOPSIS

...

=head1 DESCRIPTION

XDF::ReadCellFormattedIOCmd inherits class and attribute methods of L<XDF::FormattedIOCmd>, L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::ReadCellFormattedIOCmd.

=over 4

=item classXMLNodeName (EMPTY)

 

=item classAttributes (EMPTY)

 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::Object>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::ReadCellFormattedIOCmd inherits the following instance methods of L<XDF::FormattedIOCmd>:
B<bytes>.

=back



=over 4

XDF::ReadCellFormattedIOCmd inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::ReadCellFormattedIOCmd inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::FormattedIOCmd>

=back

=head1 AUTHOR



=cut

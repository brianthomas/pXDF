
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
# the order of these attributes IS important. In order for the ID/IDREF
# stuff to work, _objRef MUST be the last attribute
# Note: _parentArray isnt needed by TextDelimiter, but is supplied for 
# compatablity w/ FormattedReadStyle (the other untagged Read style at this time)
# _parentReadObj not used here right now either 
my @Class_Attributes = qw (
                             delimiter
                             repeatable
                             recordTerminator
                             _parentReadObj
                             _parentArray
                          );

# add in super class attributes
push @Class_Attributes, @{&XDF::XMLDataIOStyle::classAttributes};

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

  # set these defaults. 
  $self->delimiter($Def_Delimiter);
  $self->repeatable($Def_Repeatable);
  $self->recordTerminator($Def_Record_Terminator);

}

# /** Returns (Perl) regular expression notation for reading in data. */
sub _regexNotation {
  my ($self) = @_;

  my $notation = '(.*?)[';
  
  $notation .= $self->delimiter();
  $notation .= '|' . $self->recordTerminator . ']';
  $notation .= '+' if $self->repeatable eq 'yes';
  return $notation;
}

# /** Returns (Perl) sprintf expression notation for writing data. */
sub _sprintfNotation {
  my ($self) = @_;

  my $notation = '%s' . $self->delimiter();

  return $notation;
}

# Modification History
#
# $Log$
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

=item delimiter

 

=item repeatable

 

=item recordTerminator

 

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
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFile>.

=back



=over 4

XDF::DelimitedXMLDataIOStyle inherits the following instance methods of L<XDF::XMLDataIOStyle>:
B<toXMLFileHandle>.

=back

=back

=head1 SEE ALSO

L<XDF::XMLDataIOStyle>

=back

=head1 AUTHOR



=cut

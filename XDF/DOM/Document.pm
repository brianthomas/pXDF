
# $Id$

# /** COPYRIGHT
#    Document.pm Copyright (C) 2000 Brian Thomas,
#    ADC/GSFC-NASA, Code 631, Greenbelt MD, 20771
#@ 
#    This program is free software; it is licensed under the same terms
#    as Perl itself is. Please refer to the file LICENSE which is contained
#    in the distribution that this file came in.
#@ 
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# */

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION 
#
# */

# /** SYNOPSIS
#
#  # ($document is an XDF::Document object)
#
#  my $XDFObj = new XDF::XDF();
#  my $xdfNode = $document->createXDFElement($XDFObj); 
#
#  $document->appendChild($xdfNode);
#
# */

# /** SEE ALSO
# XDF::DOM::Parser
# XDF::DOM::Element
# XDF::XDF
# */

package XDF::DOM::Document;

use XDF::DOM;
use XDF::DOM::Element;
use vars qw { @ISA };

@ISA = ( "XML::DOM::Document" );

my $XDF_INDEX;

sub new {
  my ($proto, %args) = @_;

  my $self = $proto->SUPER::new (%args);
  bless $self, $proto;
  return $self;
}

#/** createXDFElement
# Creates an XDF element node. Returns an XDF::DOM::Element which
# may be inserted within the document. 
#*/
sub createXDFElement {
   my ($self, $XDFObjectRef) = @_;
   return new XDF::DOM::Element($self, $XDFObjectRef);
}

sub getXDFElements {
  my ($self) = @_;

  my $xdfElements = $self->getElementsByTagName($XDF::DOM::XDF_ROOT_NAME);
  my $size = $xdfElements->getLength;
  my @list;
 
  for (my $i = 0; $i < $size; $i++)
  {
      my $node = $xdfElements->item ($i);
      push @list, $node;
  }
  
  return \@list;
}

# just an alias
sub toXMLString {
  my ($self) = @_;
  return $self->toString();
}

1;


__END__

=head1 NAME

XDF::DOM::Document - Perl Class for DOM::Document

=head1 SYNOPSIS


  # ($document is an XDF::Document object)

  my $XDFObj = new XDF::XDF();
  my $xdfNode = $document->createXDFElement($XDFObj); 

  $document->appendChild($xdfNode);



...

=head1 DESCRIPTION



XDF::DOM::Document inherits class and attribute methods of L<XML::DOM::Document>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DOM::Document.

=over 4

=item new (%args)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DOM::Document.

=over 4

=item createXDFElement ($XDFObjectRef)

Creates an XDF element node. Returns an XDF::DOM::Element whichmay be inserted within the document.  

=item getXDFElements (EMPTY)

 

=item toXMLString (EMPTY)

 

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 SEE ALSO



=over 4

L< XDF::DOM::Parser>, L< XDF::DOM::Element>, L< XDF::XDF>, L<XDF::DOM>, L<XDF::DOM::Element>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

# /** COPYRIGHT
#    Element.pm Copyright (C) 2000 Brian Thomas,
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
# my $obj = new XDF::DOM::Parser(%options);
# my $document = $obj->parsefile($ARGV[0]);
#
# my $xdfElements = $document->getElementsByTagName('XDF');
# my $size = $xdfElements->getLength;
#
#    for (my $i = 0; $i < $size; $i++)
#    {
#        my $xdfElementNode = $xdfElements->item ($i);
#        my $obj = $xdfElementNode->getXDFObject;
#        print STDERR $xdfElementNode, ' ', $obj, "\n";
#        print STDERR $obj->toXMLString(), "\n";
#    }
#
# */

# /** SEE ALSO
# XDF::DOM
# XDF::DOM::Parser
# */

package XDF::DOM::Element;

use XML::DOM;

use vars qw (@ISA);
@ISA = ( "XML::DOM::Element" );

#
# A special XML Element Node that represents an XDF object
# within a DOM.
#

# Class Data
my $XDFOBJECT_INDEX;

# Public Methods

# Class

# /** new
# 
#*/
sub new {
   my ($proto, $ownerDoc, $XDFObject) = @_;

   die "Cannot instanciate an XDF::DOM::Element without an owner document" 
         unless defined $ownerDoc && ref($ownerDoc);

   die "Cannot instanciate an XDF::DOM::Element without an XDF object" 
         unless defined $ownerDoc && ref($ownerDoc);

   my $self = $proto->SUPER::new($ownerDoc, $XDF::DOM::XDF_ROOT_NAME);
   bless $self, $proto;
   $self->_init($XDFObject);

   return $self;
}

# Instance

#/** getXDFObject 
# Get the XDF object associated with this XDF::Element.
#*/
sub getXDFObject {
  my ($self) = @_;
  return @{$self}->[$XDFOBJECT_INDEX];
}

#/** setXDFObject 
# Set the XDF object associated with this XDF::Element.
#*/
sub setXDFObject {
  my ($self, $value) = @_;
  @{$self}->[$XDFOBJECT_INDEX] = $value;
}

#/** appendChild
# This method is NOT enabled. Dont try to use it (!).
#*/
sub appendChild {
  die "ERROR: cannot appendChild to XDF::DOM::Element\n";
}

#/** removeChild
# This method is NOT enabled. Dont try to use it (!).
#*/
sub removeChild {
  die "ERROR: cannot removeChild on XDF::DOM::Element\n";
}

#/** replaceChild
# This method is NOT enabled. Dont try to use it (!).
#*/
sub replaceChild {
  die "ERROR: cannot replaceChild on XDF::DOM::Element\n";
}

# just an alias
sub toXMLString {
  my ($self) = @_;
  return $self->toString();
}

#
# Protected Methods
#

#/** print 
# Overrides the print method from XML::DOM::Element so that the
# XDF object held in this Element node will print correctly. For
# Internal use only. 
#*/
sub print { # PRIVATE
   my ($self, $FILE) = @_;

   my $obj = $self->getXDFObject();

#   my $spec = XDF::Specification->getInstance;
   if (defined $obj) {
    # $obj->Pretty_XDF_Output(1);
#     $spec->setPrettyXDFOutput(1); # huh? 
     my $string = $obj->toXMLString(undef,undef,undef,undef,undef,1);
     $FILE->print($string);
   } else { 
     $FILE->print("<$XDF::DOM::XDF_ROOT_NAME/>\n");
   }
}

#
# Private
# 

sub _init {
   my ($self, $XDFObject) = @_; 

   # more crappiness. The object is declared as an array so 
   # we need to record the index under which to store various
   # fields local to this object.
   push @{$self}, $XDFObject;
   $XDFOBJECT_INDEX = $#$self;

}

# Modification History
#
# $Log$
# Revision 1.3  2001/08/13 19:52:21  thomas
# added alias method 'toXMLString'. Fixed toString to
# *not* add newline at the end of printout.
#
# Revision 1.2  2001/04/17 18:48:54  thomas
# now blessed properly. Removed pretty output
# stuff. What was I thinking here??
#
# Revision 1.1  2001/03/23 21:55:14  thomas
# Initial Version
#
#
#

1;


__END__

=head1 NAME

XDF::DOM::Element - Perl Class for DOM::Element

=head1 SYNOPSIS


 my $obj = new XDF::DOM::Parser(%options);
 my $document = $obj->parsefile($ARGV[0]);

 my $xdfElements = $document->getElementsByTagName('XDF');
 my $size = $xdfElements->getLength;

    for (my $i = 0; $i < $size; $i++)
    {
        my $xdfElementNode = $xdfElements->item ($i);
        my $obj = $xdfElementNode->getXDFObject;
        print STDERR $xdfElementNode, ' ', $obj, "\n";
        print STDERR $obj->toXMLString(), "\n";
    }



...

=head1 DESCRIPTION



XDF::DOM::Element inherits class and attribute methods of L<XML::DOM::Element>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DOM::Element.

=over 4

=item new ($ownerDoc, $XDFObject)

 

=item appendChild (EMPTY)

This method is NOT enabled. Dont try to use it (!).  

=item removeChild (EMPTY)

This method is NOT enabled. Dont try to use it (!).  

=item replaceChild (EMPTY)

This method is NOT enabled. Dont try to use it (!).  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DOM::Element.

=over 4

=item getXDFObject (EMPTY)

Get the XDF object associated with this XDF::Element.  

=item setXDFObject ($value)

Set the XDF object associated with this XDF::Element.  

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

L< XDF::DOM>, L< XDF::DOM::Parser>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

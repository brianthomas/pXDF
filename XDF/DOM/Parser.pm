
# $Id$

# /** COPYRIGHT
#    DOM.pm Copyright (C) 2000 Brian Thomas,
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
# XDF::DOM is extends the L<XML::DOM> class and inherits all
# of its methods and attributes. XDF::DOM allows the reading
# writing and manipulation of any XML document which embeds XDF within
# it. 
#@
# Rather than having to manipulate the XDF portion of the DOM with clumsy
# DOM methods, the XDF portions of the document may be operated on using 
# XDF methods viz L<XDF::DOM::Element>. 
#@ 
# The options of 'debug' and 'quiet' may be specified to the XDF::DOM::Parser
# in addtion to those options allowed for the XML::DOM::Parser class. 
#@ 
# */

# /** SYNOPSIS
#
# use XDF::DOM::Parser;
#
#  # note: KeepCDATA not available option for XDF::DOM::Parser
# my %options = ( 
#                 quiet => 0,
#                 debug => 1,
#                 NoExpand => 1,
#                 ParseParamEnt => 0,
#               );
#
# my $obj = new XDF::DOM::Parser(%options);
# my $document = $obj->parsefile($ARGV[0]);
#
# my $xdfElements = $document->getElementsByTagName('XDF');
# my $size = $xdfElements->getLength;
#
#    for (my $i = 0; $i < $size; $i++)
#    {
#        my $node = $xdfElements->item ($i);
#        my $obj = $node->getXDFObject;
#        print STDERR $node, ' ', $obj, "\n";
#        print STDERR $obj->toXMLString(), "\n";
#    }
# 
#
# */

package XDF::DOM::Parser; 

use XDF::DOM;
use XDF::DOM::Element;
use XDF::Log;

use XDF::Reader; 

use strict;
use integer;

use vars qw( @ISA @SupportedHandlers );

# inherits from non-validating XML::DOM::Parser
@ISA = ( "XML::DOM::Parser" );

# These XML::Parser handlers are currently supported by XML::DOM
@SupportedHandlers = qw( Init Final Char Start End Default Doctype
                         CdataStart CdataEnd XMLDecl Entity Notation Proc 
                         Default Comment Attlist Element Unparsed );
my $DEBUG = 0;
my $QUIET = 1;
my $VALIDATE = 0;

sub new {
    my ($proto, %args) = @_;

    my %handlers = ();
    for (@SupportedHandlers)
    {
        my $domHandler = "XDF::Parser::Dom::$_";
        $handlers{$_} = \&$domHandler;
    }
    $args{Handlers} = \%handlers;
    my $debug = $DEBUG;
    my $quiet = $QUIET;
    my $validate = $VALIDATE;
    my $dontLoadYet = 0;

    if ( exists $args{'debug'}) { $debug = $args{'debug'}; }
    if ( exists $args{'quiet'}) { $quiet = $args{'quiet'}; }
    if ( exists $args{'validate'}) { $validate = $args{'validate'}; }
    if ( exists $args{'dontLoadHrefData'}) { $dontLoadYet = $args{'dontLoadHrefData'}; }

    my $self = $proto->SUPER::new (%args);
    $self->{'DEBUG'} = $debug;
    $self->{'QUIET'} = $quiet;
    $self->{'VALIDATE'} = $validate;
    $self->{'DONT_LOAD_DATA_YET'} = $dontLoadYet;

    return $self;
} 

# may parse filehandle or string
sub parse {
   my ($self, $scalar) = @_;
   
   die "XDF::DOM::Parser can't parse with out a passed parameter!\n" unless defined $scalar; 

   my $document = $self->SUPER::parse($scalar);
   return $self->_do_document_parse($document);

}

# just an alias for backward compatablitiy 
#sub parsestring {
#   my ($self) = shift;
#   return $self->parse(@_);
#}

# DONT implement this, it causes hideous problems right now
#sub parsefile {
#   my ($self, $file ) = @_;

#   die "XDF::DOM::Parser can't parse with out a filename.\n" unless defined $file;
#   die "XDF::DOM::Parser can't parse $file into as it doesnt exist!!\n" unless (-e $file);

#   my $document = $self->SUPER::parse($file);

#   return $self->_do_document_parse($document);
#}

#
# Private Methods
#

sub _do_document_parse {
   my ($self, $document) = @_;

   # ok, so now get the XDF nodes, remember their location within the
   # DOM and then clip them out.

   my $xdfElements = $document->getElementsByTagName($XDF::DOM::XDF_ROOT_NAME);
   my $size = $xdfElements->getLength;

   # transfer entities to XDF object??
   #my @entityList = $document->getDoctype->getEntities->getValues;
   #for (@entityList) {
   #   print STDERR "ENTITY: ", $_, "\n";
   #} 

   # now, for each XDF node go thru and parse it (and its child nodes)
   # into XDF objects.
   for (my $i = 0; $i < $size; $i++)
   {

      my $node = $xdfElements->item ($i);

      my $XDFObject = $self->_parseNodeIntoXDFObject($node);

      # ok, now get the parent node of this (could be the document 
      # itself) and remove the XDF child node from it (and the master DOM)
      # then add the new xdfnode in its place
      my $parentNode = $node->getParentNode();

      #first: remove the whitespace nodes that trail XDF node
      $parentNode->normalize();
      my $removeOk = 0;
      foreach my $childNode ($parentNode->getChildNodes) {
        if ($childNode eq $node) {
          $removeOk = 1;
          next;
        }

        if ($removeOk && $childNode->getNodeTypeName eq 'TEXT_NODE') {
           $parentNode->removeChild($childNode);
           $childNode->dispose;
           last; # since we normalized, there should only be one 
        }
      }

      # add the DOM node location and the XDF to a list
      my $xdfNode = new XDF::DOM::Element($document, $XDFObject);
      $parentNode->replaceChild($xdfNode, $node);
      $node->dispose;


   }

   return $document;
}

sub _parseNodeIntoXDFObject {
   my ($self,$node) = @_;

   # no need for XDF::DOM::Document here, XML::DOM will do 
   my $miniDOM = new XML::DOM::Document( { KeepCDATA => 1} );

   # the doctype object holds all the entity refs and whatnot. Lets just
   # copy it and append onto the mini dom, should it exist (which it may not). 
   my $oldowner = $node->getOwnerDocument();
   my $newdoctype;
   if (ref $oldowner->getDoctype) {
      $newdoctype = $oldowner->getDoctype->cloneNode(1);
      $newdoctype->setOwnerDocument($miniDOM);
      $miniDOM->setDoctype($newdoctype);
   }
   
   # now clone  the old nodes and append into the new document 
   my $newnode = $node->cloneNode(1);
   $newnode->setOwnerDocument($miniDOM);
   $miniDOM->appendChild($newnode);

   my %options = ('validate' => $self->{'VALIDATE'}, 'quiet' => $self->{'QUIET'}, 'debug' => $self->{'DEBUG'}, 'dontLoadHrefData' => $self->{'DONT_LOAD_DATA_YET'});
   my $reader = new XDF::Reader(\%options);
   my $XDFObject = $reader->parseString($miniDOM->toString());

   # remove XMLDecl and XMLDocumentType as this info is 
   # now stored in the overall document, not in the XDF object
   $XDFObject->setDocumentType(undef);
   $XDFObject->setXMLDeclaration(undef);

   return $XDFObject;
}


1;


__END__

=head1 NAME

XDF::DOM::Parser;  - Perl Class for DOM::Parser; 

=head1 SYNOPSIS


 use XDF::DOM::Parser;

  # note: KeepCDATA not available option for XDF::DOM::Parser
 my %options = ( 
                 quiet => 0,
                 debug => 1,
                 NoExpand => 1,
                 ParseParamEnt => 0,
               );

 my $obj = new XDF::DOM::Parser(%options);
 my $document = $obj->parsefile($ARGV[0]);

 my $xdfElements = $document->getElementsByTagName('XDF');
 my $size = $xdfElements->getLength;

    for (my $i = 0; $i < $size; $i++)
    {
        my $node = $xdfElements->item ($i);
        my $obj = $node->getXDFObject;
        print STDERR $node, ' ', $obj, "\n";
        print STDERR $obj->toXMLString(), "\n";
    }
 



...

=head1 DESCRIPTION

 XDF::DOM is extends the L<XML::DOM> class and inherits all of its methods and attributes. XDF::DOM allows the reading writing and manipulation of any XML document which embeds XDF within it.  
 Rather than having to manipulate the XDF portion of the DOM with clumsy DOM methods, the XDF portions of the document may be operated on using  XDF methods viz L<XDF::DOM::Element>.   
 The options of 'debug' and 'quiet' may be specified to the XDF::DOM::Parser in addtion to those options allowed for the XML::DOM::Parser class.   


XDF::DOM::Parser;  inherits class and attribute methods of L<XML::DOM::Parser>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::DOM::Parser; .

=over 4

=item new (%args)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::DOM::Parser; .

=over 4

=item parse ($scalar)

 

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

L<XDF::DOM>, L<XDF::DOM::Element>, L<XDF::Reader; >

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

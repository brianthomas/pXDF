
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
# */

# /** SYNOPSIS
#
# use XDF::DOM::Parser;
#
#  # note: KeepCDATA not available option for XDF::DOM::Parser
# my %options = ( 
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

#/** SEE ALSO
#
#*/

#################
package XDF::DOM;
#################

use XML::DOM;
use XDF::Constants;

use integer;
use strict;

use vars qw (@ISA $XDF_ROOT_NAME);

# inherits from XML::DOM
@ISA = ("XML::DOM");

# Class Data
my %XDFNodeName = &XDF::Constants::XDF_NODE_NAMES;
$XDF_ROOT_NAME = $XDFNodeName{'root'};
    

# An internal class, extended from XML::Parser::Dom
#

# PRIVATE

###########################
package XDF::Parser::Dom;
###########################

use XDF::DOM::Document;

use vars qw( @ISA $AUTOLOAD %inherited_class_method);
@ISA = ( "XML::Parser::Dom" );

# *sigh* all methods in XML::Parser::Dom are class methods, and
# I cant get AUTOLOAD to call them correctly (having trouble with
# exec. Lets just try the following.
%inherited_class_method = ( 
              'Attlist' => sub { XML::Parser::Dom::Attlist(@_) }, 
              'CdataStart' => sub { XML::Parser::Dom::CdataStart(@_) }, 
              'CdataEnd' => sub { XML::Parser::Dom::CdataEnd(@_) }, 
              'Char' => sub { XML::Parser::Dom::Char(@_) }, 
              'Comment' => sub { XML::Parser::Dom::Comment(@_) }, 
              'Default' => sub { XML::Parser::Dom::Default(@_) }, 
              'Doctype' => sub { XML::Parser::Dom::Doctype(@_) }, 
              'Element' => sub { XML::Parser::Dom::Element(@_) }, 
              'Entity' => sub { XML::Parser::Dom::Entity(@_) }, 
              'End' => sub { XML::Parser::Dom::End(@_) }, 
              'ExternEnt' => sub { XML::Parser::Dom::ExternEnt(@_) }, 
              'Final' => sub { XML::Parser::Dom::Final(@_) }, 
              'Notation' => sub { XML::Parser::Dom::Notation(@_) }, 
              'Proc' => sub { XML::Parser::Dom::Proc(@_) }, 
              'Start' => sub { XML::Parser::Dom::Start(@_) }, 
              'Unparsed' => sub { XML::Parser::Dom::Unparsed(@_) }, 
              'XMLDecl' => sub { XML::Parser::Dom::XMLDecl(@_) }, 
           );
              #'Init' => sub { XML::Parser::Dom::Init(@_) }, 

sub AUTOLOAD {

  my (@input) = @_;
  (my $method = $AUTOLOAD) =~  s/.*:://;

  if (exists $inherited_class_method{$method}) {
     $inherited_class_method{$method}->(@_);
  } else {
     die "XDF::Parser::Dom is missing requested method: $method. Aborting parse!\n";
  } 

}

# and more crappiness. Have to use class variables in SUPER class package.
# why isnt XML::Parser::Dom instanciated??! Err.
# We need to override a few variables here
sub Init { # PRIVATE 

    $XML::Parser::Dom::_DP_elem = $XML::Parser::Dom::_DP_doc = new XDF::DOM::Document();
    $XML::Parser::Dom::_DP_doctype = new XML::DOM::DocumentType ($XML::Parser::Dom::_DP_doc);
    $XML::Parser::Dom::_DP_doc->setDoctype ($XML::Parser::Dom::_DP_doctype);
 
    # no choice, we NEED cdata sections to parse data correctly
    # with the XDF::Reader
    $XML::Parser::Dom::_DP_keep_CDATA = 1; # hardwired $XML::Parser::Dom::_[0]->{KeepCDATA};

    # Prepare for document prolog
    $XML::Parser::Dom::_DP_in_prolog = 1; 

    # We haven't passed the root element yet
    $XML::Parser::Dom::_DP_end_doc = 0;

    # Expand parameter entities in the DTD by default

    $XML::Parser::Dom::_DP_expand_pent = defined $_[0]->{ExpandParamEnt} ?
                                        $_[0]->{ExpandParamEnt} : 1;
    if ($XML::Parser::Dom::_DP_expand_pent)
    {
        $_[0]->{DOM_Entity} = {};
    }

    $XML::Parser::Dom::_DP_level = 0;

    undef $XML::Parser::Dom::_DP_last_text;

}

1;


__END__

=head1 NAME

XDF::DOM - Perl Class for DOM

=head1 SYNOPSIS


 use XDF::DOM::Parser;

  # note: KeepCDATA not available option for XDF::DOM::Parser
 my %options = ( 
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

XDF::DOM inherits class and attribute methods of L<XML::DOM>.


=head1 METHODS

=over 4



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 SEE ALSO



=over 4

L<>, L<XDF::Constants>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

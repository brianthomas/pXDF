
# $Id$

# /** COPYRIGHT
#    Specification.pm Copyright (C) 2000 Brian Thomas,
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

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# /** DESCRIPTION
# An XDF::Specification is a singleton object which contains various information
# needed by all other XDF classes on how to operate. 
# */

# /** SYNOPSIS
# 
# */

# /** SEE ALSO
# XDF::BaseObject
# */

package XDF::Specification;

use XDF::Constants;

use vars qw { $Singleton };

# CLASS DATA
my $Class_XML_Node_Name = ""; # doesnt have one!! 

my $DefaultDataArraySize = 1000; # Number stuff for holding data. We want to 
                                 # have a minimum array size for numbers (axis, dataCube, etc.)
                                 # This is what we declare as a default 

my $DefaultPrettyXDFOutput = 0;
my $DefaultPrettyXDFOutputIndentation = "   ";

# holds our instance of this class
$Singleton = new XDF::Specification;

# 
# SET/GET Methods (all class methods!!) 
# 

#/** getInstance
# Return the singleton holding the specification information.
#*/
sub getInstance {
   return $Singleton;
}

#/** isPrettyXDFOutput
# Get the output XDF format style. If 'true' (non-zero) then
# nicely formatted XML is to be outputted from any call to a toXML* method. 
#*/
sub isPrettyXDFOutput {
  my ($self) = @_;
  return $Singleton->{prettyXDFOutput};
}

#/** setPrettyXDFOutput
# Set this to true (non-zero) for nicely formatted XML output from any call to a 
# toXML* method. Setting this value will change the runtime behavior of all 
# XDF Objects within an application.
#*/
sub setPrettyXDFOutput {
   my ($self, $value) = @_;
   return unless defined $value && !ref($value);
   $Singleton->{prettyXDFOutput} = $value;
}


#/** getPrettyXDFOutputIndentation 
# Gets the indentation string that will be used for every nesting level within an output XDF. For
# example, if the string consists of 3 spaces, then a doubly nested node will be indented 6 spaces, its
# parent node will be indented 3 spaces and the root node will not be indented at all. 
#*/
sub getPrettyXDFOutputIndentation {
   my ($self) = @_;
   return $Singleton->{prettyXDFOutputIndentation}; 
}

#/** setPrettyXDFOutputIndentation 
#   Set the indentation string for PrettyXDFOutput. You aren't limited to just spaces here, ANY
#   sequence of characters may be used to indent your XDF documents.
#*/
sub setPrettyXDFOutputIndentation {
   my ($self, $value) = @_;
   return unless defined $value && !ref($value);
   $Singleton->{prettyXDFOutputIndentation} = $value;
}

# /** getDefaultDataArraySize
# This value indicates the initial size of each L<XDF::Axis>/L<XDF::FieldAxis> (the 
# number of axisValues/fields along the axis) and the number of data cells within a 
# dimension of the dataCube (L<XDF::DataCube>). If more axisValues/fields/datacells are placed on a 
# given Axis/FieldAxis or data in a unallocated spot within the dataCube then the 
# package allocates the needed memory and enlarges the dataCube/Axis objects as it is needed. 
#@
#@
# This automated allocation is slow however, so it is desirable, IF you know how big your 
# arrays will be, to pre-set this value to encompass your data set. Doing so will to improve 
# efficenecy. Note that if you are having keeping all of your data in memory (a multi-dimensional 
# dataset) it may be desirable to DECREASE the value. 
#@
#@
# The default value is 1000. 
# */
sub getDefaultDataArraySize {
  my ($self) = @_;
  return $Singleton->{dataArraySize}; 
}

#/** setDefaultDataArraySize
# Whatever new value is set currently only applies to objects created *after* 
# this method is called. 
#*/
sub setDefaultDataArraySize {
  my ($self, $value) = @_;
  return unless defined $value && !ref($value);
  $Singleton->{dataArraySize} = $value;
}

# getXMLNotationHash
# Get the output XML NotationHash for all XDF objects. 
# Returns a reference to a Hash object.
#sub getXMLNotationHash {
#  my ($self) = @_;
#  return $Singleton->{xmlNotationHash};
#}

# setXMLNotationHash
# Set the output XML NotationHash for all XDF objects. This will be 
# printed out with other XMLDeclarations in a toXMLFileHandle call. 
# */
#sub setXMLNotationHash {
#  my ($self, $attribHashRef) = @_;
#
#  return unless defined $attribHashRef;
#
#  # have to do it this way or we get ref to orig hash.
#  my %newhash;
#  while (my ($attrib, $value) = each (%{$attribHashRef}) ) {
#     $newhash{$attrib} = $value;
#  }
#  $Singleton->{xmlNotationHash} = \%newhash; 
#}

#/** getXMLSpecVersion
# Get the XML version of this package. This cooresponds to the XML spec version that this package
# uses to write out XDF.
# This method should probably be in XDF::Constants class instead as user shouldnt be able to change.
#*/
#sub getXMLSpecVersion {
#  my ($self) = @_;
#  return $Singleton->{xmlSpecVersion};
#}

#sub getXDFRootNodeName {
#  my ($self) = @_;
#  return $Singleton->{xdfRootNodeName};
#}

#sub getXDFDTDName {
#  my ($self) = @_;
#  return $Singleton->{xdfDTDName};
#}

#/**getPCDATAAttribute 
# Used by toXMLFileHandle method. This says that
# when we get an attribute in an object with this name
# we print it as PCDATA of the object node rather than 
# as an attribute when its value is scalar, eg attribute="value"
# Cant imagine why this is public and usefull to programers.
# Should be removed.
#*/
sub getPCDATAAttribute { # PRIVATE 
  my ($self) = @_;
  return &XDF::Constants::getPCDATAAttribute();
}

#
# Private Methods 
# 

sub new { # PRIVATE
    my($proto) = @_;

    return $Singleton if defined $Singleton;

    my $class = ref ($proto) || $proto;

    $Singleton = bless ({}, $class);

    # init
    $Singleton->{prettyXDFOutput} = $DefaultPrettyXDFOutput;
    $Singleton->{prettyXDFOutputIndentation} = $DefaultPrettyXDFOutputIndentation; 
    $Singleton->{dataArraySize} = $DefaultDataArraySize;
    #my %emptyHash; 
    #$Singleton->{xmlNotationHash} = \%emptyHash;
    #$Singleton->{xmlSpecVersion} = &XDF::Constants::XML_SPEC_VERSION;
    #$Singleton->{xdfRootNodeName} = &XDF::Constants::XDF_ROOT_NODE_NAME;
    #$Singleton->{xdfDTDName} = &XDF::Constants::XDF_DTD_NAME;

    return $Singleton;
}


1;


__END__

=head1 NAME

XDF::Specification - Perl Class for Specification

=head1 SYNOPSIS

 


...

=head1 DESCRIPTION

 An XDF::Specification is a singleton object which contains various information needed by all other XDF classes on how to operate. 



=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Specification.

=over 4

=item getInstance (EMPTY)

Return the singleton holding the specification information.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Specification.

=over 4

=item isPrettyXDFOutput (EMPTY)

Get the output XDF format style. If 'true' (non-zero) thennicely formatted XML is to be outputted from any call to a toXML* method.  

=item setPrettyXDFOutput ($value)

Set this to true (non-zero) for nicely formatted XML output from any call to a toXML* method. Setting this value will change the runtime behavior of all XDF Objects within an application.  

=item getPrettyXDFOutputIndentation (EMPTY)

Gets the indentation string that will be used for every nesting level within an output XDF. Forexample, if the string consists of 3 spaces, then a doubly nested node will be indented 6 spaces, itsparent node will be indented 3 spaces and the root node will not be indented at all.  

=item setPrettyXDFOutputIndentation ($value)

Set the indentation string for PrettyXDFOutput. You aren't limited to just spaces here, ANYsequence of characters may be used to indent your XDF documents.  

=item getDefaultDataArraySize (EMPTY)

This value indicates the initial size of each L<XDF::Axis>/L<XDF::FieldAxis> (the number of axisValues/fields along the axis) and the number of data cells within a dimension of the dataCube (L<XDF::DataCube>). If more axisValues/fields/datacells are placed on a given Axis/FieldAxis or data in a unallocated spot within the dataCube then the package allocates the needed memory and enlarges the dataCube/Axis objects as it is needed. @@This automated allocation is slow however, so it is desirable, IF you know how big your arrays will be, to pre-set this value to encompass your data set. Doing so will to improve efficenecy. Note that if you are having keeping all of your data in memory (a multi-dimensional dataset) it may be desirable to DECREASE the value. @@The default value is 1000.  

=item setDefaultDataArraySize ($value)

Whatever new value is set currently only applies to objects created *after* this method is called.  

=item getXMLNotationHash (EMPTY)

Get the output XML NotationHash for all XDF objects. Returns a reference to a Hash object.  

=item setXMLNotationHash ($attribHashRef)

Set the output XML NotationHash for all XDF objects. This will be printed out with other XMLDeclarations in a toXMLFileHandle call.  

=item getXMLSpecVersion (EMPTY)

Get the XML version of this package. This cooresponds to the XML spec version that this packageuses to write out XDF. This method should probably be in XDF::Constants class instead as user shouldnt be able to change.  

=item getXDFRootNodeName (EMPTY)

 

=item getXDFDTDName (EMPTY)

 

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

L< XDF::BaseObject>, L<XDF::Constants>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut



# this is meant to be an internal class of the XDF Reader

# $Id$

# /** COPYRIGHT
#    Reader.pm Copyright (C) 2001 Brian Thomas,
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
# This is meant to be a private, internal class of the XDF Reader
# */

# /** AUTHOR
#    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
#    XML Group <http://xml.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */


package XDF::Reader::ValueList;

use XDF::GenericObject;
#use XDF::Log qw/:error :warn/;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::GenericObject
@ISA = ("XDF::GenericObject");

# CLASS DATA
my @Local_Class_Attributes = qw (
                             attribs
                             parentNode
                             isDelimitedCase
                          );
my @Class_Attributes;
#my @Class_XML_Attributes;

# add in local class XML attributes
#push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
#push @Class_XML_Attributes, @{&XDF::GenericObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::GenericObject::getClassAttributes};

# add in local to overall class
#push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# 
# Constructors
# 

# /** new
# We use default values for start, step, and size unless they are defined.
# */
sub new {
  my ($proto, $attribs_ref) = @_;

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  my %hash;
  $self->_init($attribs_ref);

  return $self;
}

# 
# SET/GET Methods
#

# /** getValueListId
# */
sub getValueListId {
   my ($self) = @_;
   return $self->{Attribs}{valueListId};
}

# /** setValueListId
#     Set the valueListId attribute. 
# */
sub setValueListId {
   my ($self, $value) = @_;
   $self->{Attribs}{valueListId} = $value;
}

# /** getValueListIdRef 
# */
sub getValueListIdRef {
   my ($self) = @_;
   return $self->{Attribs}{valueListIdRef};
}

# /** setValueListIdRef 
#     Set the valueListIdRef attribute. 
# */
sub setValueListIdRef {
   my ($self, $value) = @_;
   $self->{Attribs}{valueListIdRef} = $value;
}

# /** getParentNodeName 
# */
sub getParentNodeName {
   my ($self) = @_;
   return $self->{ParentNodeName};
}

# /** setParentNodeName 
# */
sub setParentNodeName {
   my ($self, $value) = @_;
   $self->{ParentNodeName} = $value;
}

# /** getIsDelimitedCase 
# */
sub getIsDelimitedCase {
   my ($self) = @_;
   return $self->{IsDelimitedCase};
}

# /** setIsDelimitedCase 
# */
sub setIsDelimitedCase {
   my ($self, $value) = @_;
   $self->{IsDelimitedCase} = $value;
}

# /** getAttributes
#      This method returns the Attributes of this class as a hash. 
#  */
sub getAttributes {
  my ($self) = @_;
  return $self->{Attribs};
}

sub getStart { my ($self) = @_; return $self->{Attribs}{start}; }
sub getStep { my ($self) = @_; return $self->{Attribs}{step}; }
sub getSize { my ($self) = @_; return $self->{Attribs}{size}; }
sub getDelimiter { my ($self) = @_; return $self->{Attribs}{delimiter}; }
sub getRepeatable { my ($self) = @_; return $self->{Attribs}{repeatable}; }

#sub getInfinite { my ($self) = @_; return $self->{Attribs}{infiniteValue}; }
#sub getInfiniteNegative { my ($self) = @_; return $self->{Attribs}{infiniteNegativeValue}; }
#sub getNoData{ my ($self) = @_; return $self->{Attribs}{noDataValue}; }
#sub getNotANumber { my ($self) = @_; return $self->{Attribs}{notANumberValue}; }
#sub getOverflow { my ($self) = @_; return $self->{Attribs}{overflowValue}; }
#sub getUnderflow { my ($self) = @_; return $self->{Attribs}{underflowValue}; }

sub _init {
   my ($self, $attribs_ref) = @_;

   if (defined $attribs_ref) {

      my %attribs = %{$attribs_ref};

      $attribs{start} = &XDF::Constants::DEFAULT_VALUELIST_START
         unless defined $attribs{start};
      $attribs{step} = &XDF::Constants::DEFAULT_VALUELIST_STEP
         unless defined $attribs{step};
      $attribs{size} = &XDF::Constants::DEFAULT_VALUELIST_SIZE
         unless defined $attribs{size};
      $attribs{delimiter} = &XDF::Constants::DEFAULT_VALUELIST_DELIMITER
         unless defined $attribs{delimiter};
      $attribs{repeatable} = &XDF::Constants::DEFAULT_VALUELIST_REPEATABLE
         unless defined $attribs{repeatable};

      $self->{Attribs} = \%attribs;

   } else {

      my %hash;
      $hash{start} = &XDF::Constants::DEFAULT_VALUELIST_START;
      $hash{step} = &XDF::Constants::DEFAULT_VALUELIST_STEP;
      $hash{size} = &XDF::Constants::DEFAULT_VALUELIST_SIZE;
      $hash{delimiter} = &XDF::Constants::DEFAULT_VALUELIST_DELIMITER;
      $hash{repeatable} = &XDF::Constants::DEFAULT_VALUELIST_REPEATABLE;
      $self->{Attribs} = \%hash;
   }

   $self->setIsDelimitedCase(0);

}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self, $val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

1;


__END__

=head1 NAME

XDF::Reader::ValueList - Perl Class for Reader::ValueList

=head1 SYNOPSIS

...

=head1 DESCRIPTION

 This is meant to be a private, internal class of the XDF Reader

XDF::Reader::ValueList inherits class and attribute methods of L<XDF::GenericObject>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Reader::ValueList.

=over 4

=item new ($attribs_ref)

We use default values for start, step, and size unless they are defined. 

=item getStart (EMPTY)

 

=item getSize (EMPTY)

 

=item getRepeatable (EMPTY)

 

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Reader::ValueList.

=over 4

=item getValueListId (EMPTY)

 

=item setValueListId ($value)

Set the valueListId attribute.  

=item getValueListIdRef (EMPTY)

 

=item setValueListIdRef ($value)

Set the valueListIdRef attribute.  

=item getParentNodeName (EMPTY)

 

=item setParentNodeName ($value)

 

=item getIsDelimitedCase (EMPTY)

 

=item setIsDelimitedCase ($value)

 

=item getAttributes (EMPTY)

This method returns the Attributes of this class as a hash.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Reader::ValueList inherits the following instance (object) methods of L<XDF::GenericObject>:
B<getClassAttributes>, B<clone>, B<update>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::GenericObject>

=back

=head1 AUTHOR

    Brian Thomas  (brian.thomas@gsfc.nasa.gov)
    XML Group <http://xml.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

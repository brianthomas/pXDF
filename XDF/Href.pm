
# $Id$

package XDF::Href;

# /** COPYRIGHT
#    Href.pm Copyright (C) 2000 Brian Thomas,
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
#
# The HREF object is nothing more than a simple hash that holds the name of the
# href and its associated ENTITY reference.
# */

#/** SYNOPSIS
#
# */

use Carp;

use XDF::GenericObject;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

@ISA = ("XDF::GenericObject");

# CLASS DATA
my @Local_Class_Attributes = qw (
                             Name
                             Base
                             SysId
                             PubId
                             Ndata
                          );

my @Local_Class_XML_Attributes = qw (
                          );

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
#push @Class_XML_Attributes, @{&XDF::GenericObject::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::GenericObject::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Class_XML_Attributes;

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::FloatDataFormat. 
#  This method takes no arguments may not be changed. 
# */
sub getClassAttributes {
  return \@Class_Attributes;
}

# /** getClassXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getClassXMLAttributes {
  return \@Class_XML_Attributes;
}

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

# 
# Get/Set Methods
#

# /** getBase
# */
sub getBase {
   my ($self) = @_;
   return $self->{Base};
}

# /** setBase
#     Set the entity base attribute. 
# */
sub setBase {
   my ($self, $value) = @_;
   $self->{Base} = $value;
}

# /** getName
# */
sub getName {
   my ($self) = @_;
   return $self->{Name};
}

# /** setName
#     Set the name attribute. 
# */
sub setName {
   my ($self, $value) = @_;
   $self->{Name} = $value;
}

# /** getNdata
# */
sub getNdata {
   my ($self) = @_;
   return $self->{Ndata};
}

# /** setNdata
#     Set the ndata attribute. 
# */
sub setNdata {
   my ($self, $value) = @_;
   $self->{Ndata} = $value;
}


# /** getPubId
#  */
sub getPubId {
   my ($self) = @_;
   return $self->{PubId};
}

# /** setPubId
#     Set the pubId attribute. 
#  */
sub setPubId {
   my ($self, $value) = @_;
   $self->{PubId} = $value;
}

# /** getSysId
#  */
sub getSysId {
   my ($self) = @_;
   return $self->{SysId};
}

# /** setSysId
#     Set the sysId attribute. 
#  */
sub setSysId {
   my ($self, $value) = @_;
   $self->{SysId} = $value;
}

#
# Private
# 

# empty,nothing happens here
sub _init { }

# Modification History
#
# $Log$
# Revision 1.5  2001/08/13 19:49:15  thomas
# bug fix: use only local XML attributes for appendAttribs in _init
#
# Revision 1.4  2001/07/23 15:58:07  thomas
# added ability to add arbitary XML attribute to class.
# getXMLattributes now an instance method, we
# have old class method now called getClassXMLAttributes.
#
# Revision 1.3  2001/03/16 19:54:57  thomas
# Documentation updated and improved, re-ran makeDoc on file.
#
# Revision 1.2  2001/03/14 21:32:34  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.1  2000/12/14 22:12:15  thomas
# First version. -b.t.
#
#
#

1;


__END__

=head1 NAME

XDF::Href - Perl Class for Href

=head1 SYNOPSIS




...

=head1 DESCRIPTION

 The HREF object is nothing more than a simple hash that holds the name of the href and its associated ENTITY reference. 

XDF::Href inherits class and attribute methods of L<XDF::GenericObject>.


=head1 METHODS

=over 4

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Href.

=over 4

=item getBase (EMPTY)

 

=item setBase ($value)

Set the entity base attribute.  

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getNdata (EMPTY)

 

=item setNdata ($value)

Set the ndata attribute.  

=item getPubId (EMPTY)

 

=item setPubId ($value)

Set the pubId attribute.  

=item getSysId (EMPTY)

 

=item setSysId ($value)

Set the sysId attribute.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Href inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::GenericObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


# $Id$

package XDF::Structure;

# /** COPYRIGHT
#    Structure.pm Copyright (C) 2000 Brian Thomas,
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
# XDF is the eXtensible Data Structure, which is an XML format
# designed to contain n-dimensional scientific/mathematical data.
#@   
#@   
# The XDF can hold both tagged and untagged data and may serve as
# a wrapper around many kinds of legacy data.
#@   
#@   
# XDF::Structure is a means of grouping/associating L<XDF::Parameter> objects, which hold 
# scientific content of the data, and L<XDF::Array> objects which hold the mathematical content 
# of the data. If an XDF::Structure holds a parameter with several XDF::Array objects then the 
# parameter is assumed to be applicable to all of the array child nodes. Sub-structure (e.g. other 
# XDF::Structure objects) may be held within a structure to create more fine-grained associations
# between parameters and arrays.
# */

#/** SYNOPSIS
#
#    use XDF::Structure;
#  
#    my %attributes = ( 
#                       'name' => 'A default name',
#                       'paramList' => @paramObjRefList,
#                       'arrayList' => @arrayRefList,
#                     );
#
#    # initialize new object w/ attribute hash
#    my $structObj = XDF::Structure->new(%attributes);
#
#    # overwrite the name attribute w/ new value, set the description 
#    $structObj->name("My Structure");
#    $structObj->name("This data was found under under a cabinet. It looks important.");
#
#    # add an XDF::Array object to the structure
#    push $structObj->arrayList, $arrayObj;
#
#    ...
#
#    # for another filled in structure..
#
#    # print out all it parameters names 
#    foreach my $paramObj (@{$structObj2->paramList()}) {
#       print STDOUT "parameter name: ",$paramObj->name(),"\n"; 
#    }
#    
#    # replace the list of arrays owned by this structure with
#    # a new one.
#
#    $structObj2->arrayList(@newArrayRefList);
#
#   ...
#
#    # create a structure from a file
#
#    my $XDFStructObj = new XDF::Structure();
#
#    # read method makes a call to XDF::Reader. %options
#    # has same meaning here as for createXDFObjectfromFile 
#    # method in XDF::Reader.
#
#    $XDFStructObj = $XDFStructObj->read($file, \%options);
#
# */

use Carp;

use XDF::Object;
use XDF::Array;
use XDF::Reader;
use XDF::Parameter;
use XDF::ParameterGroup;

use strict;
use integer;

use vars qw ($AUTOLOAD @ISA %field);

# inherits from XDF::Object
@ISA = ("XDF::Object");

# CLASS DATA
my $Class_XML_Node_Name = "structure";
my @Class_Attributes = qw (
                             name
                             description
                             paramList
                             structList
                             arrayList
                             noteList
                             _paramGroupOwnedHash
                          ); 

# Description of class attributes: 
# /** name
# A scalar string containing the name of this XDF::Structure. 
# */
# /** description
# A scalar string containing the description (long name) of this XDF::Structure. 
# */
# /** paramList
# A scalar list reference to the XDF::Parameter objects held by this XDF::Structure.
# */
# /** structList
# A scalar list reference to the XDF::Structure objects held by this XDF::Structure.
# */
# /** arrayList
# A scalar list reference to the XDF::Array objects held by this XDF::Structure.
# */

# add in super class attributes
push @Class_Attributes, @{&XDF::Object::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# /** classXMLNodeName
# This method takes no arguments may not be changed. 
# This method returns the class node name for XDF::Structure; 
# */
sub classXMLNodeName { 
  return $Class_XML_Node_Name; 
}

# /** classAttributes
#  This method takes no arguments may not be changed. 
#  This method returns a list reference containing the names
#  of the class attributes for XDF::Structure; 
# */
sub classAttributes { 

  return \@Class_Attributes; 
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

  # initialize lists
  $self->structList([]);
  $self->paramList([]);
  $self->arrayList([]);
  $self->noteList([]);
  $self->_paramGroupOwnedHash({});

}

# /** addNote
# Insert an XDF::Note object into the XDF::Notes object held by this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Note> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Note object.
# RETURNS : an XDF::Note object reference on success, undef on failure.
# */
sub addNote {
  my ($self, $info) = @_;

  my $noteObj;
  if(ref $info && $info =~ m/XDF::Note/) {
    $noteObj = $info if(ref $info && $info =~ m/XDF::Note/);
  } else {
    $noteObj = XDF::Note->new($info);
  }

  # add the parameter to the list
  push @{$self->noteList}, $noteObj;

  return $noteObj;
}

# /** removeNote
# Removes an XDF::Note object from the list of XDF::Note objects
# held within the XDF::Notes object of this object. This method takes 
# either the list index number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  $self->_remove_from_list($what, $self->noteList(), 'noteList');
}

# /** getNotes
# Convenience method which returns a list of the notes held by the XDF::Notes
# object of this object. 
# */
sub getNotes {
  my ($self, $what) = @_;
  return @{$self->noteList};
}

# /** addParameter 
# Insert an XDF::Parameter object into this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Parameter> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Parameter object.
# RETURNS : an XDF::Parameter object reference on success, undef on failure.
# */
sub addParameter {
  my ($self, $attribHashReference) = @_;

  my $paramObj = XDF::Parameter->new($attribHashReference);

  # add the parameter to the list
  push @{$self->paramList}, $paramObj;

  return $paramObj;
}

# /** removeParameter 
# Remove an XDF::Parameter object from the list of XDF::Parameters
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeParameter {
  my ($self, $indexOrObjectRef) = @_;
  $self->_remove_from_list($indexOrObjectRef, $self->paramList(), 'paramList');
}

# /** addStructure
# Insert an XDF::Structure object into this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Structure> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Structure object.
# RETURNS : an XDF::Structure object reference on success, undef on failure.
# */
sub addStructure {
   my ($self, $attribHashReference) = @_;

  my $structObj = XDF::Structure->new($attribHashReference);

  # add the new structure to the list
  push @{$self->structList}, $structObj;

  return $structObj;
}

# /** removeStructure
# Remove an XDF::Structure object from the list of XDF::Structures
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeStructure {
  my ($self, $indexOrObjectRef) = @_; 
  $self->_remove_from_list($indexOrObjectRef, $self->structList(), 'structList');
}

# /** addArray
# Insert an XDF::Array object into this object.
# This method may optionally take a reference to an attribute hash as
# its argument. Attributes in the attribute hash should
# correspond to attributes of the L<XDF::Array> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::Array object.
# RETURNS : an XDF::Array object reference on success, undef on failure.
# */
sub addArray {
  my ($self, $attribHashReference) = @_;

  my $arrayObj = XDF::Array->new($attribHashReference);

  # add the parameter to the list
  push @{$self->arrayList}, $arrayObj;

  return $arrayObj;
}

# /** removeArray
# Remove an XDF::Array object from the list of XDF::Arrays
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, undef on failure.
# */
sub removeArray {
  my ($self, $indexOrObjectRef) = @_; 
  $self->_remove_from_list($indexOrObjectRef, $self->arrayList(), 'arrayList');
}

# /** addParamGroup
# Insert an XDF::ParameterGroup object into this object.
# This method takes either a reference to an attribute hash OR
# object reference to an existing XDF::ParameterGroup as
# its argument. Attributes in the attribute hash reference should
# correspond to attributes of the L<XDF::ParameterGroup> object. 
# The attribute/value pairs in the attribute hash reference are
# used to initialize the new XDF::ParameterGroup object.
# RETURNS : an XDF::ParameterGroup object reference on success, undef on failure.
# */
sub addParamGroup {
  my ($self, $objectRefOrAttribHashRef ) = @_;

  my $info = $objectRefOrAttribHashRef;
  return unless defined $info && ref $info;

  my $groupObj;
  if ($info =~ m/XDF::ParameterGroup/) {
    $groupObj = $info;
  } else {
    $groupObj = new XDF::ParameterGroup($info);
  }

  # add the group to the groupOwnedHash
  %{$self->_paramGroupOwnedHash}->{$groupObj} = $groupObj;

  return $groupObj;
}

# /** removeParamGroup
# Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups 
# held within this object. This method takes the hash key 
# its argument. RETURNS : 1 on success, undef on failure.
# */
sub removeParamGroup { 
  my ($self, $hashKey) = @_; 
  delete %{$self->_paramGroupOwnedHash}->{$hashKey}; 
}

# /** read
# Read in an XML file using XDF::Reader. 
# Returns the structure read in on success, undef on failure.
# */
sub read {
  my ($self, $file, $optionsHashRef) = @_;
  &XDF::Reader::createXDFObjectFromFile($file, $optionsHashRef);
}

1;


__END__

=head1 NAME

XDF::Structure - Perl Class for Structure

=head1 SYNOPSIS


    use XDF::Structure;
  
    my %attributes = ( 
                       'name' => 'A default name',
                       'paramList' => @paramObjRefList,
                       'arrayList' => @arrayRefList,
                     );

    # initialize new object w/ attribute hash
    my $structObj = XDF::Structure->new(%attributes);

    # overwrite the name attribute w/ new value, set the description 
    $structObj->name("My Structure");
    $structObj->name("This data was found under under a cabinet. It looks important.");

    # add an XDF::Array object to the structure
    push $structObj->arrayList, $arrayObj;

    ...

    # for another filled in structure..

    # print out all it parameters names 
    foreach my $paramObj (@{$structObj2->paramList()}) {
       print STDOUT "parameter name: ",$paramObj->name(),"\n"; 
    }
    
    # replace the list of arrays owned by this structure with
    # a new one.

    $structObj2->arrayList(@newArrayRefList);

   ...

    # create a structure from a file

    my $XDFStructObj = new XDF::Structure();

    # read method makes a call to XDF::Reader. %options
    # has same meaning here as for createXDFObjectfromFile 
    # method in XDF::Reader.

    $XDFStructObj = $XDFStructObj->read($file, \%options);



...

=head1 DESCRIPTION

 XDF is the eXtensible Data Structure, which is an XML format designed to contain n-dimensional scientific/mathematical data.     
    
 The XDF can hold both tagged and untagged data and may serve as a wrapper around many kinds of legacy data.     
    
 XDF::Structure is a means of grouping/associating L<XDF::Parameter> objects, which hold  scientific content of the data, and L<XDF::Array> objects which hold the mathematical content  of the data. If an XDF::Structure holds a parameter with several XDF::Array objects then the  parameter is assumed to be applicable to all of the array child nodes. Sub-structure (e.g. other  XDF::Structure objects) may be held within a structure to create more fine-grained associations between parameters and arrays. 

XDF::Structure inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::Object>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::Structure.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name for XDF::Structure;  

=item classAttributes (EMPTY)

This method takes no arguments may not be changed. This method returns a list reference containing the namesof the class attributes for XDF::Structure;  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item name

A scalar string containing the name of this XDF::Structure.  

=item description

A scalar string containing the description (long name) of this XDF::Structure.  

=item paramList

A scalar list reference to the XDF::Parameter objects held by this XDF::Structure.  

=item structList

A scalar list reference to the XDF::Structure objects held by this XDF::Structure.  

=item arrayList

A scalar list reference to the XDF::Array objects held by this XDF::Structure.  

=item noteList

 

=back

=head2 OTHER Methods

=over 4

=item addNote ($info)

Insert an XDF::Note object into the XDF::Notes object held by this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Note> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Note object. RETURNS : an XDF::Note object reference on success, undef on failure. 

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item getNotes ($what)

Convenience method which returns a list of the notes held by the XDF::Notesobject of this object. 

=item addParameter ($attribHashReference)

Insert an XDF::Parameter object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Parameter> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Parameter object. RETURNS : an XDF::Parameter object reference on success, undef on failure. 

=item removeParameter ($indexOrObjectRef)

Remove an XDF::Parameter object from the list of XDF::Parametersheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item addStructure ($attribHashReference)

Insert an XDF::Structure object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Structure> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Structure object. RETURNS : an XDF::Structure object reference on success, undef on failure. 

=item removeStructure ($indexOrObjectRef)

Remove an XDF::Structure object from the list of XDF::Structuresheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item addArray ($attribHashReference)

Insert an XDF::Array object into this object. This method may optionally take a reference to an attribute hash asits argument. Attributes in the attribute hash shouldcorrespond to attributes of the L<XDF::Array> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::Array object. RETURNS : an XDF::Array object reference on success, undef on failure. 

=item removeArray ($indexOrObjectRef)

Remove an XDF::Array object from the list of XDF::Arraysheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, undef on failure. 

=item addParamGroup ($objectRefOrAttribHashRef)

Insert an XDF::ParameterGroup object into this object. This method takes either a reference to an attribute hash ORobject reference to an existing XDF::ParameterGroup asits argument. Attributes in the attribute hash reference shouldcorrespond to attributes of the L<XDF::ParameterGroup> object. The attribute/value pairs in the attribute hash reference areused to initialize the new XDF::ParameterGroup object. RETURNS : an XDF::ParameterGroup object reference on success, undef on failure. 

=item removeParamGroup ($hashKey)

Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups held within this object. This method takes the hash key its argument. RETURNS : 1 on success, undef on failure. 

=item read ($optionsHashRef, $file)

Read in an XML file using XDF::Reader. Returns the structure read in on success, undef on failure. 

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

XDF::Structure inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>, B<setObjRef>.

=back



=over 4

XDF::Structure inherits the following instance methods of L<XDF::Object>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L<XDF::Object>, L<XDF::Array>, L<XDF::Reader>, L<XDF::Parameter>, L<XDF::ParameterGroup>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

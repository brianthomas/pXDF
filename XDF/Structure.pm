
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
# XDF::Structure is a means of grouping/associating XDF::Parameter objects, which hold 
# scientific content of the data, and XDF::Array objects which hold the mathematical content 
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
#    $structObj->setName("My Structure");
#    $structObj->setDescription("This data was found under under a cabinet. It looks important.");
#
#    # add an XDF::Array object to the structure
#    $structObj->addArray($arrayObj);
#
#    ...
#
#    # for another filled in structure..
#
#    # print out all it parameters names 
#    foreach my $paramObj (@{$structObj2->getParamList()}) {
#       print STDOUT "parameter name: ",$paramObj->getName(),"\n"; 
#    }
#    
#    # replace the list of arrays owned by this structure with
#    # a new one.
#
#    $structObj2->setArrayList(\@newArrayRefList);
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
#    $XDFStructObj = $XDFStructObj->loadFromXDFFile($file, \%options);
#
#    # create a structure from a file (alternative method) 
#
#    my $reader = new XDF::Reader();
#    my $XDFStructObj2 = $reader->parseFile($file, \%options);
#
# */

use Carp;

use XDF::BaseObjectWithXMLElements;
use XDF::Array;
use XDF::Parameter;
use XDF::ParameterGroup;
#use XDF::Reader;

use strict;
use integer;

use vars qw ($AUTOLOAD @ISA %field);

# inherits from XDF::BaseObjectWithXMLElements 
@ISA = ("XDF::BaseObjectWithXMLElements");

# CLASS DATA
my $Class_XML_Node_Name = "structure";
# NOTE: if you ADD/Change an attribute here, make sure it is
# properly re-inited in the _init method or you will be sorry!!!
my @Local_Class_XML_Attributes = qw (
                                 name
                                 description
                                 paramList
                                 structList
                                 arrayList
                                 noteList
                              ); 
my @Local_Class_Attributes = qw (
                             _paramGroupOwnedHash
                          ); 

my @Class_Attributes;
my @Class_XML_Attributes;

# add in local class XML attributes
push @Local_Class_Attributes, @Local_Class_XML_Attributes;

# get super class attributes
push @Class_XML_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassXMLAttributes};
push @Class_Attributes, @{&XDF::BaseObjectWithXMLElements::getClassAttributes};

# add in local to overall class
push @Class_XML_Attributes, @Local_Class_XML_Attributes;
push @Class_Attributes, @Local_Class_Attributes;


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

# /** getClassAttributes
#  This method returns a list reference containing the names
#  of the class attributes for this class.
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

# 
# SET/GET Methods
#

# /** getName
# */
sub getName { 
   my ($self) = @_; 
   return $self->{name}; 
}

# /** setName
#     Set the name attribute. 
# */
sub setName { 
   my ($self, $value) = @_; 
   $self->{name} = $value; 
}

# /** getDescription
#  */
sub getDescription { 
   my ($self) = @_; 
   return $self->{description}; 
}

# /** setDescription
#  */
sub setDescription { 
   my ($self, $value) = @_; 
   $self->{description} = $value; 
}

# /** getArrayList
#  */
sub getArrayList { 
   my ($self) = @_; 
   return $self->{arrayList}; 
}

# /** setArrayList
#  */
sub setArrayList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{arrayList} = \@list; 
}

# /** getStructList
#  */
sub getStructList { 
   my ($self) = @_; 
   return $self->{structList}; 
}

# /** setStructList
#  */
sub setStructList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{structList} = \@list; 
}

# /** getParamList
#  */
sub getParamList { 
   my ($self) = @_; 
   return $self->{paramList}; 
}

# /** setParamList
#  */
sub setParamList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{paramList} = \@list; 
}

# /** getNoteList
#  */
sub getNoteList { 
   my ($self) = @_; 
   return $self->{noteList}; 
}

# /** setNoteList
#  */
sub setNoteList { 
   my ($self, $arrayRefValue) = @_;
   # you must do it this way, or when the arrayRef changes it changes us here!
   my @list = @{$arrayRefValue};
   $self->{noteList} = \@list; 
}

#
# Other Public Methods 
#

# /** addNote
# Insert an XDF::Note object into the XDF::Notes object held by this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addNote {
  my ($self, $noteObj) = @_;

  return 0 unless defined $noteObj && ref $noteObj;

  # add the parameter to the list
  push @{$self->{noteList}}, $noteObj;

  return 1;
}

# /** removeNote
# Removes an XDF::Note object from the list of XDF::Note objects
# held within the XDF::Notes object of this object. This method takes 
# either the list index number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeNote {
  my ($self, $what) = @_;
  return $self->_remove_from_list($what, $self->{noteList}, 'noteList');
}

# /** addParameter 
# Insert an XDF::Parameter object into this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addParameter {
  my ($self, $paramObj) = @_;

  return 0 unless defined $paramObj && ref $paramObj;

  # add the parameter to the list
  push @{$self->{paramList}}, $paramObj;

  return 1;
}

# /** removeParameter 
# Remove an XDF::Parameter object from the list of XDF::Parameters
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeParameter {
  my ($self, $indexOrObjectRef) = @_;
  return $self->_remove_from_list($indexOrObjectRef, $self->{paramList}, 'paramList');
}

# /** addStructure
# Insert an XDF::Structure object into this object.
# RETURNS :  1 on success, 0 on failure.
# */
sub addStructure {
   my ($self, $structObj) = @_;

   return 0 unless defined $structObj && ref $structObj;

   # add the new structure to the list
   push @{$self->{structList}}, $structObj;

   return 1;
}

# /** removeStructure
# Remove an XDF::Structure object from the list of XDF::Structures
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeStructure {
  my ($self, $indexOrObjectRef) = @_; 
  return $self->_remove_from_list($indexOrObjectRef, $self->{structList}, 'structList');
}

# /** addArray
# Insert an XDF::Array object into this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addArray {
   my ($self, $arrayObj) = @_;

   return 0 unless defined $arrayObj && ref $arrayObj;

   # add the parameter to the list
   push @{$self->{arrayList}}, $arrayObj;

   return 1;
}

# /** removeArray
# Remove an XDF::Array object from the list of XDF::Arrays
# held within this object. This method takes either the list index 
# number or an object reference as its argument.
# RETURNS : 1 on success, 0 on failure.
# */
sub removeArray {
  my ($self, $indexOrObjectRef) = @_; 
  return $self->_remove_from_list($indexOrObjectRef, $self->{arrayList}, 'arrayList');
}

# /** addParamGroup
# Insert an XDF::ParameterGroup object into this object.
# RETURNS : 1 on success, 0 on failure.
# */
sub addParamGroup {
  my ($self, $groupObj) = @_;

  return 0 unless defined $groupObj && ref $groupObj;

  # add the group to the groupOwnedHash
  %{$self->{_paramGroupOwnedHash}}->{$groupObj} = $groupObj;

  return 1;
}

# /** removeParamGroup
# Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups 
# held within this object. This method takes the hash key 
# its argument. RETURNS : 1 on success, 0 on failure.
# */
sub removeParamGroup { 
   my ($self, $hashKey) = @_; 
   if (exists %{$self->{_paramGroupOwnedHash}}->{$hashKey}) {
      delete %{$self->{_paramGroupOwnedHash}}->{$hashKey}; 
      return 1;
   }
   return 0;
}

# /* loadFromXDFFile
# Read in an XML file into this structure. The current structure, 
# if it has any components, is overrided and lost. 
# */
#sub loadFromXDFFile {
#  my ($self, $file, $optionsHashRef) = @_;

#  my $reader = new XDF::Reader($optionsHashRef);
#  $self->_init(); # clear out old structure
#  $reader->setReaderStructureObject($self);
#  $self = $reader->parseFile($file);
#}

#
# Private Methods 
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;
  
  $self->SUPER::_init(); 

  # re-initialize attribs
  # this is only needed for Structure and not other XDF objects because
  # of the needs of the loadXDFFromFile method (in the sub-class XDF) 
  $self->{name} = undef; 
  $self->{description} = undef; 

  # initialize lists
  $self->{structList} = [];
  $self->{paramList} = [];
  $self->{arrayList} = [];
  $self->{noteList} = [];

  $self->{_paramGroupOwnedHash} = {};

  # adds to ordered list of XML attributes
  $self->_appendAttribsToXMLAttribOrder(\@Local_Class_XML_Attributes);

}

sub _find_All_child_Href_Objects {
  my ($self) = @_;

  my @list;

  if (ref($self) eq 'XDF::XDF') {
     foreach my $arrayObj (@{$self->getArrayList()}) {  
        my $hrefObj = $arrayObj->getDataCube()->getHref();
        push @list, $hrefObj if defined $hrefObj;
     }
  
     foreach my $structObj (@{$self->getStructList()}) { 
        push @list, @{$structObj->_find_All_child_Href_Objects()};
     }
  }

  return \@list;
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
    $structObj->setName("My Structure");
    $structObj->setDescription("This data was found under under a cabinet. It looks important.");

    # add an XDF::Array object to the structure
    $structObj->addArray($arrayObj);

    ...

    # for another filled in structure..

    # print out all it parameters names 
    foreach my $paramObj (@{$structObj2->getParamList()}) {
       print STDOUT "parameter name: ",$paramObj->getName(),"\n"; 
    }
    
    # replace the list of arrays owned by this structure with
    # a new one.

    $structObj2->setArrayList(\@newArrayRefList);

   ...

    # create a structure from a file

    my $XDFStructObj = new XDF::Structure();

    # read method makes a call to XDF::Reader. %options
    # has same meaning here as for createXDFObjectfromFile 
    # method in XDF::Reader.

    $XDFStructObj = $XDFStructObj->loadFromXDFFile($file, \%options);

    # create a structure from a file (alternative method) 

    my $reader = new XDF::Reader();
    my $XDFStructObj2 = $reader->parseFile($file, \%options);



...

=head1 DESCRIPTION

 XDF is the eXtensible Data Structure, which is an XML format designed to contain n-dimensional scientific/mathematical data.     
    
 The XDF can hold both tagged and untagged data and may serve as a wrapper around many kinds of legacy data.     
    
 XDF::Structure is a means of grouping/associating XDF::Parameter objects, which hold  scientific content of the data, and XDF::Array objects which hold the mathematical content  of the data. If an XDF::Structure holds a parameter with several XDF::Array objects then the  parameter is assumed to be applicable to all of the array child nodes. Sub-structure (e.g. other  XDF::Structure objects) may be held within a structure to create more fine-grained associations between parameters and arrays. 

XDF::Structure inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>, L<XDF::BaseObjectWithXMLElements>.


=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Structure.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name for XDF::Structure;  

=item getClassAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes for this class. This method takes no arguments may not be changed.  

=item getClassXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class.  

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Structure.

=over 4

=item getName (EMPTY)

 

=item setName ($value)

Set the name attribute.  

=item getDescription (EMPTY)

 

=item setDescription ($value)

 

=item getArrayList (EMPTY)

 

=item setArrayList ($arrayRefValue)

 

=item getStructList (EMPTY)

 

=item setStructList ($arrayRefValue)

 

=item getParamList (EMPTY)

 

=item setParamList ($arrayRefValue)

 

=item getNoteList (EMPTY)

 

=item setNoteList ($arrayRefValue)

 

=item addNote ($noteObj)

Insert an XDF::Note object into the XDF::Notes object held by this object. RETURNS : 1 on success, 0 on failure.  

=item removeNote ($what)

Removes an XDF::Note object from the list of XDF::Note objectsheld within the XDF::Notes object of this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item addParameter ($paramObj)

Insert an XDF::Parameter object into this object. RETURNS : 1 on success, 0 on failure.  

=item removeParameter ($indexOrObjectRef)

Remove an XDF::Parameter object from the list of XDF::Parametersheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item addStructure ($structObj)

Insert an XDF::Structure object into this object. RETURNS :  1 on success, 0 on failure.  

=item removeStructure ($indexOrObjectRef)

Remove an XDF::Structure object from the list of XDF::Structuresheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item addArray ($arrayObj)

Insert an XDF::Array object into this object. RETURNS : 1 on success, 0 on failure.  

=item removeArray ($indexOrObjectRef)

Remove an XDF::Array object from the list of XDF::Arraysheld within this object. This method takes either the list index number or an object reference as its argument. RETURNS : 1 on success, 0 on failure.  

=item addParamGroup ($groupObj)

Insert an XDF::ParameterGroup object into this object. RETURNS : 1 on success, 0 on failure.  

=item removeParamGroup ($hashKey)

Remove an XDF::ParameterGroup object from the hash table of XDF::ParameterGroups held within this object. This method takes the hash key its argument. RETURNS : 1 on success, 0 on failure.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4



=over 4

XDF::Structure inherits the following instance (object) methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::Structure inherits the following instance (object) methods of L<XDF::BaseObject>:
B<getXMLAttributes>, B<setXMLAttributes>, B<setXMLAttribute>, B<addXMLAttribute>, B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<toXMLFileHandle>, B<toXMLString>, B<toXMLFile>.

=back



=over 4

XDF::Structure inherits the following instance (object) methods of L<XDF::BaseObjectWithXMLElements>:
B<addXMLElement>, B<removeXMLElement>, B<getXMLElementList>, B<setXMLElementList>.

=back

=back

=back

=head1 SEE ALSO



=over 4

L<XDF::BaseObjectWithXMLElements>, L<XDF::Array>, L<XDF::Parameter>, L<XDF::ParameterGroup>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut

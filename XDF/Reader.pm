
package XDF::Reader;

# a module to read in XDF files, both in 
# tagged and untagged formats.

# $Id$

# /** COPYRIGHT
#    Reader.pm Copyright (C) 2000 Brian Thomas,
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


# TODO
# - We also need to allow options to 
#     1 - use parser other than Expat (?)
#     2 - allow passing of addtional start/end handlers for user-defined nodes
#

# /** DESCRIPTION
# This class allows the user to create XDF objects from XDF files. 
# XDF::Reader will read in both Binary and ASCII data and tagged/delimited/
# and formatted XDF data styles are supported.
# */

# /** AUTHOR 
#    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
#    Astronomical Data Center <http://adc.gsfc.nasa.gov>
#    NASA/Goddard Space Flight Center
# */

# VERSION HISTORY
# 0.01 : Jun  6 2000 : first version, supports only tagged data
# 0.05 : Jun  7 2000 : Using the Java interface moved it over to OO
#                      can now read and store all metadata in XDF.
#                      Cant yet write out Viewer table tho.
# 0.10 : Jun  8 2000 : Fully functional for converting tagged XDF
#                      to viewer formated tables. Used a kludge, 
#                      $IGNORE_WHITESPACE_ONLY_DATA to avoid trying to
#                      add in text (formating) nodes :P 
# 0.15 : Jun  9 2000 : Now its a module, separated out viewer code, now
#                      we do the right thing, just return an XDF object. 
#                      Another, user-specified program can write the viewer file.
# 0.17 : Jul 21 2000 : Finally got the ID/IDREF stuff sorted out.
# 0.17d: Aug  1 2000 : Added in validating parser.

# /** SYNOPSIS
#
#    my $DEBUG = 1;
#
#    # test file for reading in XDF files.
#
#    my $file = $ARGV[0];
#    my %options = ('quiet' => $DEBUG, 'validate' => 0);
#
#    my $XDFReader = new XDF::Reader(\%options);
#    my $XDFObject = $XDFReader->parseFile($file);
#
# */

use XML::DOM;

use XDF::Array;
use XDF::BinaryFloatDataFormat;
use XDF::BinaryIntegerDataFormat;
use XDF::Constants;
use XDF::DelimitedXMLDataIOStyle;
use XDF::Field;
use XDF::FieldRelation;
use XDF::FloatDataFormat;
use XDF::FormattedXMLDataIOStyle;
use XDF::Href;
use XDF::IntegerDataFormat;
use XDF::Parameter;
use XDF::RepeatFormattedIOCmd;
use XDF::ReadCellFormattedIOCmd;
use XDF::SkipCharFormattedIOCmd;
use XDF::StringDataFormat;
use XDF::Structure;
use XDF::XMLDataIOStyle;
use XDF::XMLElement;

use vars qw ($VERSION %field);

# look for the checker, if its installed use it
# otherwise, fall back to the (regular) non-validating
# version of the parser
BEGIN {
  unless (eval "use XML::Checker::Parser" ) {
     use XML::Parser;
  }
} 

use strict;
use integer;

                              #lastFieldGroupParentObject
                              #tagCount
                              #lastUnitsObject
my @Class_Attributes = qw (
                              Options
                              startElementHandler
                              endElementHandler
                              charDataHandler
                              defaultHandler
                              XDF
                              currentStructure
                              currentArray
                              currentDatatypeObject
                              currentFormatObjectList
                              currentArrayAxes
                              currentNodePath
                              currentValueList
                              currentValueGroupList
                              currentFieldGroupList
                              currentParamGroupList
                              currentDataTagLevel
                              dataTagLevel
                              Notation
                              UnParsedEntity
                              Entity
                              taggedLocatorObject
                              dataFormatAttribRef;
                              dataIOStyleAttribRef;
                              nrofWarnings
                              cdataIsArrayData
                              ArrayObj
                              AxisObj
                              FieldObj
                              NoteObj
                              XMLDataIOStyleObj
                              dataBlock
                              dataNodeLevel
                              readAxisOrderList
                              readAxisOrderHash
                              noteLocatorOrder
                              lastObjList
                              lastNoteObject
                              lastUnitObject
                              lastParamObject
                              lastNotesParentObject
                              lastParamGroupParentObject
                              lastValueGroupParentObject
                          );

#
# CLASS DATA
#

$VERSION = "0.17"; # the version of this module, what version of XDF
                   # it will read in.
my $Flag_Decimal = &XDF::Constants::INTEGER_TYPE_DECIMAL;
my $Flag_Octal = &XDF::Constants::INTEGER_TYPE_OCTAL;
my $Flag_Hex = &XDF::Constants::INTEGER_TYPE_HEX;
my $Def_ValueList_Step = &XDF::Constants::DEFAULT_VALUELIST_STEP;
my $Def_ValueList_Start = &XDF::Constants::DEFAULT_VALUELIST_START;
my $Def_ValueList_Repeatable = &XDF::Constants::DEFAULT_VALUELIST_REPEATABLE;
my $Def_ValueList_Delimiter = &XDF::Constants::DEFAULT_VALUELIST_DELIMITER;
my %XDF_node_name = &XDF::Constants::XDF_NODE_NAMES;

# this is a BAD thing. I have been having troubles distinguishing between
# important whitespace (e.g. char data within a data node) and text nodes
# that are purely for the layout of the XML document. Right now I use the 
# CRUDE distinquishing characteristic that fluff (eg. only there for the sake
# of formatting the output doc) text nodes are all whitespace.
# Used by TAGGED data arrays
my $IGNORE_WHITESPACE_ONLY_DATA = 1;

# OPTIONS for running the parser
my $MAX_WARNINGS = 10; # how many warnings we can have before termination. 
                       # Set to 0 for unlimited warnings 
my $DEBUG = 0; # for printing out debug information from class methods 
my $QUIET = 1; # if enabled it suppresses warnings from class methods 
my $PARSER_MSG_THRESHOLD = 200; # we print all messages equal to and below this threshold

my %Default_Handler = ( 'start' => sub { &_default_start_handler(@_); }, 
                        'end' => sub { &_null_cmd(); },
                        'cdata' => sub { &_default_cdata_handler(@_); },
                      );

# dispatch table for the start node handler of the parser
my %Start_Handler = (
                       $XDF_node_name{'array'}        => sub { &_array_node_start(@_); },
                       $XDF_node_name{'axis'}         => sub { &_axis_node_start(@_); },
                       $XDF_node_name{'axisUnits'}    => sub { &_axisUnits_node_start(@_); },
                       $XDF_node_name{'binaryFloat'}  => sub { &_binaryFloatField_node_start(@_); },
                       $XDF_node_name{'binaryInteger'} => sub { &_binaryIntegerField_node_start(@_); },
                       $XDF_node_name{'data'}         => sub { &_data_node_start(@_); },
                       $XDF_node_name{'dataFormat'}   => sub { &_dataFormat_node_start(@_); },
                       $XDF_node_name{'field'}        => sub { &_field_node_start(@_); },
                       $XDF_node_name{'fieldAxis'}    => sub { &_fieldAxis_node_start(@_); },
                       $XDF_node_name{'float'}        => sub { &_floatField_node_start(@_); },
                       $XDF_node_name{'for'}          => sub { &_for_node_start(@_); },
                       $XDF_node_name{'fieldGroup'}   => sub { &_fieldGroup_node_start(@_); },
                       $XDF_node_name{'index'}        => sub { &_note_index_node_start(@_); },
                       $XDF_node_name{'integer'}      => sub { &_integerField_node_start(@_); },
                       $XDF_node_name{'locationOrder'}=> sub { &_null_cmd(@_); },
                       $XDF_node_name{'note'}         => sub { &_note_node_start(@_); },
                       $XDF_node_name{'notes'}        => sub { &_notes_node_start(@_); },
                       $XDF_node_name{'parameter'}    => sub { &_parameter_node_start(@_); },
                       $XDF_node_name{'parameterGroup'} => sub { &_parameterGroup_node_start(@_); },
                       $XDF_node_name{'read'}         => sub { &_read_node_start(@_);},
                       $XDF_node_name{'readCell'}     => sub { &_readCell_node_start(@_);},
                       $XDF_node_name{'repeat'}       => sub { &_repeat_node_start(@_); },
                       $XDF_node_name{'relationship'} => sub { &_field_relationship_node_start(@_); },
                       $XDF_node_name{'root'}         => sub { &_root_node_start(@_); },
                       $XDF_node_name{'skipChar'}     => sub { &_skipChar_node_start(@_); },
                       $XDF_node_name{'string'}       => sub { &_stringField_node_start(@_); },
                       $XDF_node_name{'structure'}    => sub { &_structure_node_start(@_); },
                       $XDF_node_name{'tagToAxis'}    => sub { &_tagToAxis_node_start(@_);},
                       $XDF_node_name{'td0'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td1'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td2'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td3'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td4'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td5'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td6'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td7'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'td8'}          => sub { &_dataTag_node_start(@_);},
                       $XDF_node_name{'textDelimiter'}=> sub { &_asciiDelimiter_node_start(@_); },
                       $XDF_node_name{'unit'}         => sub { &_unit_node_start(@_); },
                       $XDF_node_name{'units'}        => sub { &_units_node_start(@_); },
                       $XDF_node_name{'unitless'}     => sub { &_unitless_node_start(@_); },
                       $XDF_node_name{'value'}        => sub { &_null_cmd(@_); },
                       $XDF_node_name{'valueGroup'}   => sub { &_valueGroup_node_start(@_); },
                       $XDF_node_name{'valueList'}    => sub { &_valueList_node_start(@_); },
                       $XDF_node_name{'vector'}       => sub { &_vector_node_start(@_); } ,
                    );

# dispatch table for the end element handler of the parser
my %End_Handler = (
                       $XDF_node_name{'array'}        => sub { &_array_node_end(@_); },
                       $XDF_node_name{'data'}         => sub { &_data_node_end(@_); },
                       $XDF_node_name{'fieldGroup'}   => sub { &_fieldGroup_node_end(@_); },
                       $XDF_node_name{'notes'}        => sub { &_notes_node_end(@_); },
                       $XDF_node_name{'parameterGroup'} => sub { &_parameterGroup_node_end(@_); },
                       $XDF_node_name{'read'}         => sub { &_read_node_end(@_); },
                       $XDF_node_name{'repeat'}       => sub { &_repeat_node_end(@_); },
                       $XDF_node_name{'td0'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td1'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td2'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td3'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td4'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td5'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td6'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td7'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'td8'}          => sub { &_dataTag_node_end(@_);},
                       $XDF_node_name{'valueGroup'}   => sub { &_valueGroup_node_end(@_); },
                  );

# dispatch table for the chardata handler of the parser
my %CharData_Handler = (

                          $XDF_node_name{'note'}=> sub { &_note_node_charData(@_); },
                          $XDF_node_name{'unit'}=> sub { &_unit_node_charData(@_); },
                          $XDF_node_name{'valueList'}=> sub { &_valueList_node_charData(@_); },
                          $XDF_node_name{'value'}=> sub { &_value_node_charData(@_); },
                    );

#
# Class Attribute Initalization
#

for my $attr ( @Class_Attributes ) { $field{$attr}++; }

#
# Class methods
#

#/** getStructure
# returns the structure that the reader parses into.
#*/
sub getReaderStructureObject {
  my ($self) = @_;
  return $self->{XDF};
}

#/** setReaderStructureObject 
# sets the structure that the reader parses into.
#*/
sub setReaderStructureObject {
  my ($self, $structure) = @_;
  $self->{XDF} = $structure;
}

#/** getVersion
# returns the version of the XDF DTD supported by this parser.
#*/
sub getVersion {
  return $VERSION;
}

# /** parseFile
# Reads in the given file and returns a full XDF Perl object (an L<XDF::Structure>
#  with at least one L<XDF::Array>). A second HASH argument may be supplied to 
# specify runtime options for the XDF::Reader.
# */
sub parseFile {
   my ($self, $file, $optionsHashRef) = @_;

   open (FILE, $file) or die "$0 cant open $file\n";
   $self->parseFileHandle(\*FILE, $optionsHashRef);
   close FILE;

   return $self->{XDF};
}

# /** parseFileHandle
# Similar to parseFile but takes an open filehandle as an 
# argument (so you can parse ANY open fileHandle, e.g. files, sockets, etc.
# Whatever Perl supports.).
# */
sub parseFileHandle {
  my ($self, $handle, $optionsHashRef) = @_;

  $self->{Options} = $optionsHashRef if defined $optionsHashRef && ref($optionsHashRef);

  if ($self->{Options}->{validate} && ! eval { new XML::Checker::Parser } ) {
    warn "Validating parser module (XML::Checker::Parser) not available on this system, using default non-validating parser XML::Parser.\n";
    $self->{Options}->{validate} = 0;
  }

  if ($self->{Options}->{validate} ) {

    my $parser = &_create_validating_parser($optionsHashRef);

    eval {
       local $XML::Checker::FAIL = sub { $self->_my_fail(@_); };
       $parser->parse($handle);
    };

    # Either XML::Parser (expat) threw an exception or my_fail() died.
    if ($@) {
       my ($msg, $loc) = split "\n", $@;
       print "MSG: $msg\n"; # the error message 
       print "$loc\n"; # print location 
    }

  } else {

    my $parser = $self->_create_parser();
    $parser->parse($handle);

  }

   return $self->{XDF};
}

# /** parseString
# Reads in the given string and returns a full XDF Perl object (an L<XDF::Structure>
# with at least one L<XDF::Array>). A second HASH argument may be supplied to 
# specify runtime options for the XDF::Reader.
# */
sub parseString {
  my ($self, $string, $optionsHashRef) = @_;

  $self->{Options} = $optionsHashRef if defined $optionsHashRef && ref($optionsHashRef);

  if ($self->{Options}->{validate} && ! eval { new XML::Checker::Parser } ) {
    warn "Validating parser module (XML::Checker::Parser) not available on this system, using default non-validating parser XML::Parser.\n";
    $self->{Options}->{validate} = 0;
  }

  if ($self->{Options}->{validate} ) {

    my $parser = &_create_validating_parser($optionsHashRef);
    
    eval {
       local $XML::Checker::FAIL = sub { $self->_my_fail(@_); };
       $parser->parse($string);
    };
    
    # Either XML::Parser (expat) threw an exception or my_fail() died.
    if ($@) {
       my ($msg, $loc) = split "\n", $@;
       print "MSG: $msg\n"; # the error message 
       print "$loc\n"; # print location 
    }

  } else {

    my $parser = $self->_create_parser();
    $parser->parse($string);

  }

  return $self->{XDF};
 
}

#
# Object M E T H O D S 
#

#
# PUBLIC Methods
#

# /** new
# Create a new reader object. Returns the reader object if successfull.
# It takes an optional argument of an option HASH Reference  
# to initialize the object options.  
# */
sub new {
  my ($proto, $optionsHashRef) = @_;

  my $class = ref ($proto) || $proto;
  my $self = bless( { }, $class);

  $self->_init($optionsHashRef);

  return $self;

}

#/** addStartElementHandlers
# Add new handlers to the internal XDF::Parser start element handler. The form of  
# the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; 
# If a 'nodename' for a handler already exists in the XDF start handler table,  
# this method will override it with the new handler. 
#*/
sub addStartElementHandlers {
  my ($self, %newHandlers) = @_;

  # merge into existing XDF handlers
  while ( my ($k, $v) = each (%newHandlers)) {
     $self->{startElementHandler}->{$k} = $v;
  }

}

#/** addEndElementHandlers
# Add new handlers to the internal XDF::Parser end element handler. The form of  
# the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; 
# If a 'nodename' for a handler already exists in the XDF end handler table,  
# this method will override it with the new handler. 
#*/
sub addEndElementHandlers {
  my ($self, %newHandlers) = @_;

  # merge into existing XDF handlers
  while ( my ($k, $v) = each (%newHandlers)) {
     $self->{endElementHandler}->{$k} = $v;
  }

}

#/** addCharDataHandlers
# Add new handlers to the internal XDF::Parser CDATA element handler. The form of  
# the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; 
# If a 'nodename' for a handler already exists in the XDF CDATA handler table,  
# this method will override it with the new handler. 
#*/
sub addCharDataHandlers {
  my ($self, %newHandlers) = @_;

  # merge into existing XDF handlers
  while ( my ($k, $v) = each (%newHandlers)) {
     $self->{charDataHandler}->{$k} = $v;
  }

}

#/** setDefaultStartElementHandler
# This sets the subroutine which will handle all nodes which DONT match  
# an entry within the start element handler table. 
#*/
sub setDefaultStartElementHandler {
  my ($self, $codeRef) = @_;
  return unless defined $codeRef;
  $self->{defaultHandler}->{'start'} = $codeRef;
}

#/** setDefaultEndElementHandler
# This sets the subroutine which will handle all nodes which DONT match  
# an entry within the end element handler table. 
#*/
sub setDefaultEndElementHandler {
  my ($self, $codeRef) = @_;
  return unless defined $codeRef;
  $self->{defaultHandler}->{'end'} = $codeRef;
}

#/** setDefaultCharDataHandler
# This sets the subroutine which will handle all nodes which DONT match  
# an entry within the CDATA handler table. 
#*/
sub setDefaultCharDataHandler {
  my ($self, $codeRef) = @_;
  return unless defined $codeRef;
  $self->{defaultHandler}->{'cdata'} = $codeRef;
}

#
# SAX Parser Handlers (Protected) 
#

sub _handle_doctype {
   my ($self, $parser_ref, @stuff) = @_;
   &_printDebug("H_DOCTYPE: ");
   foreach my $thing (@stuff) { &_printDebug($thing.", ") if defined $thing; }
   &_printDebug("\n");
}

sub _handle_xml_decl {
   my ($self, $parser_ref, @stuff) = @_;
   &_printDebug("H_XML_DECL: ");
   foreach my $thing (@stuff) { &_printDebug($thing.", ") if defined $thing; }
   &_printDebug("\n");
}

# store these in the entity array
sub _handle_unparsed {
  my ($self, $parser_ref, $entity, $base, $sysid, $pubid, $notation) = @_;

   my $msgstring = "H_UNPARSED: $entity";
   #$self->{UnParsedEntity}->{$entity} = {}; # add a new entry;
   $self->{Entity}->{$entity} = {}; # add a new entry;

   if (defined $base) {
      $msgstring .= ", Base:$base";
      #${$self->{UnParsedEntity}->{$entity}}{'base'} = $base;
      ${$self->{Entity}->{$entity}}{'base'} = $base;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      #${$self->{UnParsedEntity}->{$entity}}{'sysid'} = $sysid;
      ${$self->{Entity}->{$entity}}{'sysid'} = $sysid;
   }

   if (defined $pubid) {
      $msgstring .= " PUB:$pubid";
      #${$self->{UnParsedEntity}->{$entity}}{'pubid'} = $pubid;
      ${$self->{Entity}->{$entity}}{'pubid'} = $pubid;
   }

   if (defined $notation) {
      $msgstring .= " NOTATION:$notation";
      #${$self->{UnParsedEntity}->{$entity}}{'notation'} = $notation;
      ${$self->{Entity}->{$entity}}{'notation'} = $notation;
   }

   $msgstring .= "\n";
   &_printDebug($msgstring);

}

sub _handle_notation {
  my ($self, $parser_ref, $notation, $base, $sysid, $pubid) = @_;

   my $msgstring = "H_NOTATION: $notation ";
   $self->{Notation}->{$notation} = {}; # add a new entry

   if (defined $base) {
      $msgstring .= ", Base:$base";
      ${$self->{Notation}->{$notation}}{'base'} = $base;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$self->{Notation}->{$notation}}{'sysid'} = $sysid;
   }

   if (defined $pubid) {
      $msgstring .= " PUB:$pubid";
      ${$self->{Notation}->{$notation}}{'pubid'} = $pubid;
   }

   $msgstring .= "\n";
   &_printDebug($msgstring);

}

sub _handle_element {
   my ($self, $parser_ref, $name, $model) = @_; 
   &_printDebug("H_ELEMENT: $name [$model]\n"); 
}

# do we really need this? attribute list from entity defs 
sub _handle_attlist {
   my ($self, $parser_ref, $elname, $attname, $type, $default, $fixed) = @_; 
   &_printDebug("H_ATTLIST: $elname [");
   &_printDebug($attname) if defined $attname;
   &_printDebug(" | ");
   &_printDebug($type) if defined $type;
   &_printDebug(" | ");
   &_printDebug($default) if defined $default;
   &_printDebug(" | ");
   &_printDebug($fixed) if defined $fixed;
   &_printDebug(" ]\n");
}

sub _handle_start {
   my ($self, $parser_ref, $element, @attribinfo) = @_; 

   &_printDebug("H_START: $element \n"); 

   my %attrib_hash = &_make_attrib_array_a_hash(@attribinfo);

   # 1.add this node to the current path
   push @{$self->{currentNodePath}}, $element;

   # 2. run the start handler. All start handlers SHOULD return a corresponding
   # xdf object that they create at this step. 
   my $obj;
   if ( exists $self->{startElementHandler}->{$element}) {

      # run the appropriate start handler
      $obj = $self->{startElementHandler}->{$element}->($self, %attrib_hash);

   } 
   else 
   {
      $obj =  $self->_exec_default_Start_Handler($element, \%attrib_hash);
   }

   # 3. record the object that corresponds to this XML node (remember that we
   # dont always have an object defined, some XML nodes have no coorsponending
   # xdf object so $obj may equal undef.
   push @{$self->{lastObjList}}, $obj;

}

sub _handle_end {
   my ($self, $parser_ref, $element) = @_;

   &_printDebug("H_END: $element\n");

   # peel off the last element in the current path
   my $last_element = pop @{$self->{currentNodePath}};

   die "error last element not $element!! (was: $last_element) \n" 
       unless ($element eq $last_element);

   if (exists $self->{endElementHandler}->{$element} ) {

      $self->{endElementHandler}->{$element}->($self);

   } else {

      $self->_exec_default_End_Handler($element);

   } 

   pop @{$self->{lastObjList}};

}

sub _handle_char {
   my ($self, $parser_ref, $string) = @_;

   &_printDebug("H_CHAR:".join '/', @{$self->{currentNodePath}} ."[$string]\n");

   # we need to know what the current node is in order to 
   # know what to do with this data, however, 
   # early on when reading the DOCTYPE, other nodes we can get 
   # text nodes which are not meaningful to us. Ignore all
   # charcter data until we open the root node.

   my $curr_node = $self->_currentNodeName();

   if (defined $curr_node) { 

     if(exists $self->{charDataHandler}->{$curr_node} ) {
       
        $self->{charDataHandler}->{$curr_node}->($self, $string); 

     } else {

       # perhaps we are reading in data at the moment??

       if ($self->{dataNodeLevel} > 0) { 

          $self->_data_node_charData($string) 

       } else { 

         # do nothing with other character data
         $self->_exec_default_CData_Handler($string);

       }

     }

   } 

}

# ignore comments
sub _handle_comment {
   my ($self, $parser_ref, $data) = @_;
   &_print_extreme_debug("H_COMMENT: $data\n");
}

sub _handle_final {
   my ($self, $parser_ref) = @_;
   &_printDebug("H_FINAL \n");

   # set the entity, notation and unparsed lists for the XDF structure
   my $spec= XDF::Specification->getInstance();
   $spec->setXMLNotationHash($self->{Notation});
  # $self->{XDF}->setXMLInternalEntityHash(\%Entity);
  # $self->{XDF}->setXMLUnparsedEntityHash(\%UnParsedEntity);
   # pass the populated structure back to calling routine
   return $self->{XDF};
}

sub _handle_init {
   my ($self, $parser_ref) = @_;
   &_printDebug("H_INIT \n");
}

sub _handle_proc {
   my ($self, $parser_ref, $target, $data) = @_;
   &_printDebug("H_PROC: $target [$data] \n");
}

sub _handle_cdata_start {
   my ($self, $parser_ref) = @_;
   &_printDebug( "H_CDATA_START \n");
   $self->{cdataIsArrayData} = 1;
}

sub _handle_cdata_end {
   my ($self, $parser_ref) = @_;
   &_printDebug("H_CDATA_END \n");
   $self->{cdataIsArrayData} = undef;
}

# things like entity definitions get passed here
sub _handle_default {
   my ($self, $parser_ref, $string) = @_;
   &_printDebug("H_DEFAULT:[$string]\n");

   # well, i dont know what else can go here, but for now
   # lets assume its entities in the character data ONLY.
   # So we just pass this off to the _handle_character method.
   # (yes, we could specify in the parser decl, but perhaps
   # above assumtion ISNT right, then we will need this ).
#   $self->_handle_char($parser_ref, $string);

}
  
sub _handle_external_ent {
   my ($self, $parser_ref, $base, $sysid, $pubid) = @_;

   my $entityString = "H_EXTERN_ENT: ";
   $entityString .= ", Base:$base" if defined $base;
   $entityString .= ", SYS:$sysid" if defined $sysid;
   $entityString .= " PUB:$pubid" if defined $pubid;
   $entityString .= "\n";
   &_printDebug($entityString);

}

sub _handle_entity {
   my ($self, $parser_ref, $name, $val, $sysid, $pubid, $ndata) = @_;

   my $msgstring = "H_ENTITY: $name";
   $self->{Entity}{$name} = {}; # add a new entry;

   if (defined $val) {
      $msgstring .= ", VAL:$val";
      ${$self->{Entity}{$name}}{'value'} = $val;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$self->{Entity}{$name}}{'sysid'} = $sysid;
   }
  
   if (defined $pubid) {
      $msgstring .= ", PUB:$pubid";
      ${$self->{Entity}{$name}}{'pubid'} = $pubid;
   }

   if (defined $ndata) {
      $msgstring .= " NDATA:$ndata";
      ${$self->{Entity}{$name}}{'ndata'} = $ndata;
   }

   $msgstring .= "\n";
   &_printDebug($msgstring);

}

#
# ------------ END XML PARSER HANDLERS -----------
#

#
# SAX Document HANDLERS (Private? perhaps should be protected, hurmm)  
#

sub _asciiDelimiter_node_end { 
  my ($self) = @_;
  pop @{$self->{currentFormatObjectList}}; 
}

sub _asciiDelimiter_node_start {
  my ($self, %attrib_hash) = @_;

  # if this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  # set the format object in the current array
  if ( defined $self->{dataIOStyleAttribRef}) {
    $self->{currentArray}->setXMLDataIOStyle(new XDF::DelimitedXMLDataIOStyle($self->{dataIOStyleAttribRef}));
    $self->{currentArray}->getXMLDataIOStyle->setXMLAttributes(\%attrib_hash);

    my $readId = $self->{currentArray}->getXMLDataIOStyle()->getReadId();
    if (defined $readId ) {
       $self->_printWarning( "Danger: More than one read node with readId=\"$readId\", using latest node.\n" )
           if defined $self->{XMLDataIOStyleObj}{$readId};
       $self->{XMLDataIOStyleObj}{$readId} = $self->{currentArray}->getXMLDataIOStyle();
    }

    $self->{dataIOStyleAttribRef} = undef;
    push @{$self->{currentFormatObjectList}}, $self->{currentArray}->getXMLDataIOStyle();

  }

  return $self->{currentArray}->getXMLDataIOStyle();
}

sub _array_node_end {
  my ($self) = @_;

   # well, well, which array will we deal with here?
   # if an appendto is specified, then we will try to append this array
   # to the specified one, otherwise, the current array is added to 
   # the current structure.
   my $arrayAppendId = $self->{currentArray}->getAppendTo();
   if (defined $arrayAppendId)
   {
      # we just add it to the designated array
      my $arrayToAppendTo = $self->{ArrayObj}->{$arrayAppendId};
      &_appendArrayToArray($arrayToAppendTo, $self->{currentArray});
   }
   else
   {
      # add the current array and add this array to current structure 
      my $retarray = $self->{currentStructure}->addArray($self->{currentArray});
   }

}

sub _array_node_start {
  my ($self, %attrib_hash) = @_;

  # these are attribtes that go on the dataFormat, not the array
  #my @attribList = qw /lessThanValue lessThanOrEqualValue infiniteValue 
  #                      infiniteNegativeValue greaterThanValue greaterThanOrEqualValue 
  #                      noDataValue/;
  #my %dataFormatAttrib;
  #for (@attribList) {
  #   if (exists($attrib_hash{$_})) {
  #      $dataFormatAttrib{$_} = $attrib_hash{$_};
  #   }
  #}

  #$self->{currentArray} = $self->{currentStructure}->addArray(\%attrib_hash);

  my $newarray = new XDF::Array(\%attrib_hash);

  # add this array to our list of arrays if it has an ID
  if ($newarray && (my $arrayId = $newarray->getArrayId)) {
     $self->{ArrayObj}->{$arrayId} = $newarray;
  }

  $self->{currentArray} = $newarray;
  $self->{currentDatatypeObject} = $self->{currentArray};
  $self->{currentArrayAxes} = {};

  return $newarray;
}

sub _axis_node_start {
  my ($self, %attrib_hash) = @_;

  my $axisObj = new XDF::Axis(\%attrib_hash);

  # record this axis
  $self->{currentArrayAxes}{$axisObj->getAxisId} = $axisObj if defined $axisObj->getAxisId;

  # add in reference object, if it exists 
  if (exists($attrib_hash{'axisIdRef'})) {

     my $id = $attrib_hash{'axisIdRef'};

     # clone from the reference object
     $axisObj = $self->{AxisObj}->{$id}->clone();

     # override with local values
     $axisObj->setXMLAttributes(\%attrib_hash);
     $axisObj->setAxisId($self->_getUniqueIdName($id, \%{$self->{AxisObj}})); # set ID attribute to unique name 
     $axisObj->setAxisIdRef(undef); # unset IDREF attribute 
     
     # record this axis under its parent id 
     $self->{currentArrayAxes}{$id} = $axisObj;

  }

  # add this object to the lookup table, if it has an ID
  #if ((my $axisId = $attrib_hash{'axisId'}) && !$self->{currentArray}->getAppendTo()) {
  if ((my $axisId = $axisObj->getAxisId) && !$self->{currentArray}->getAppendTo()) {
     $self->_printWarning( "Danger: More than one axis node with axisId=\"$axisId\", using latest node.\n" )
           if defined $self->{AxisObj}->{$axisId};
     $self->{AxisObj}->{$axisId} = $axisObj;
  }

  $axisObj = $self->{currentArray}->addAxis($axisObj);

  $self->{currentDatatypeObject} = $axisObj;

  return $axisObj;
}

sub _axisUnits_node_start { 
  my ($self, %attrib_hash) = @_;
  # do nothing
  return undef;
}

sub _binaryFloatField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->{currentDatatypeObject};
  
  my $dataFormatObj;
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataFormatObj = $dataTypeObj->setDataFormat(new XDF::BinaryFloatDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string dataformat in $dataTypeObj, ignoring\n";
  
  }

  return $dataFormatObj;
}

sub _binaryIntegerField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->{currentDatatypeObject};
  
  my $dataFormatObj;
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataFormatObj = $dataTypeObj->setDataFormat(new XDF::BinaryIntegerDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string data format in $dataTypeObj, ignoring\n";
  
  }

  return $dataFormatObj;

}

sub _dataTag_node_start {
  my ($self, %attrib_hash) = @_;

  $self->{currentDataTagLevel}++;

  return undef;
}

sub _dataTag_node_end {
  my ($self) = @_;

  $self->{taggedLocatorObject}->next() if ($self->{currentDataTagLevel} == $self->{dataTagLevel});
  $self->{currentDataTagLevel}--;

}
  
# what to do when we know this character data IS coming from within
# the data node
sub _data_node_charData {
  my ($self, $string) = @_;

  my $readObj = $self->{currentArray}->getXMLDataIOStyle();

  if (ref ($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

    # dont add this data unless it has more than just whitespace
    if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {

#       &_printDebug("ADDING DATA to ($self->{taggedLocatorObject}) : [$string]\n");
       $self->{dataTagLevel} = $self->{currentDataTagLevel};
       $self->{currentArray}->addData($self->{taggedLocatorObject}, $string);
    }

  } elsif (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle' or
           ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' )
  {

    if ($self->{cdataIsArrayData}) {
       # accumulate CDATA in the GLOBAL $self->{dataBlock} for later reading
       $self->{dataBlock} .= $string;
    }

  } else {

     die "UNSUPPORTED data_node_charData style\n";

  }

}

sub _data_node_end {
  my ($self) = @_;

  # we stopped reading datanode, lower count by one
  $self->{dataNodeLevel}--;

  # we might still be nested within a data node
  # if so, return now to accumulate more data within the DATABLOCK
  return unless $self->{dataNodeLevel} == 0;

  # now read in untagged data (both delimited/formmatted styles) 
  # from the $self->{dataBlock}

  # Note: unfortunately we are reduced to using regex style matching
  # instead of a buffer read in formatted reads. Come back and
  # improve this later if possible.

  my $formatObj = $self->{currentArray}->getXMLDataIOStyle();

  if ( ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle' or
       ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle' ) {

    my $regex; my $template; my $recordSize;
    my $data_has_special_integers = &_arrayHasSpecialIntegers($self->{currentArray});
    my $data_has_binary_values = &_arrayHasBinaryData($self->{currentArray});
    my $endian = $formatObj->getEndian();

    # set up appropriate instructions for reading
    if ( ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle' ) {
      $template  = $formatObj->_templateNotation(1);
      $recordSize = $formatObj->numOfBytes();
    } elsif(ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {
      $regex = $formatObj->_regexNotation();
      if ($data_has_binary_values) {
         die "Cannot read binary data within a delimited array, aborting read.\n";
      }
    }

    my $locator = $self->{currentArray}->createLocator();

    # this is done because we read these in the reverse order in which
    # the API demands the axes, e.g. first axis is the 'fast' one, whereas
    # reading the XDF node by node we get the fastest last in the array.
    @{$self->{readAxisOrderList}} = reverse @{$self->{readAxisOrderList}}; 

    # needed for the appendTo stuff
    my @temparray = @{$self->{readAxisOrderList}};
    $self->{readAxisOrderHash}->{$self->{currentArray}} = \@temparray;

    $locator->setIterationOrder(\@{$self->{readAxisOrderList}});
    $formatObj->setWriteAxisOrderList(\@{$self->{readAxisOrderList}});
    my @dataFormat = $self->{currentArray}->getDataFormatList;

    &_print_extreme_debug("locator[$locator] has axisOrder:[",join ',', @{$self->{readAxisOrderList}},"]\n");

    while ( $self->{dataBlock} ) {

      my @data;

      if ( ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle' ) {

        $self->{dataBlock} =~ s/(.{$recordSize})//s; 
        die "Read Error: short read on datablock, improper specified format? (expected size=$recordSize)\n" unless $1; 

        @data = unpack($template, $1);

       # In part because we are using a regex mechanism below,
       # it doesnt make sense to store binary data in delimited manner,
       # so we only see it as a fixed Formatted case.
       # this may have to be re-evaluated in the future. -b.t.
        @data = &_deal_with_binary_data(\@dataFormat, \@data, $endian)
           if $data_has_binary_values;

      } elsif(ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {

        $_ = $self->{dataBlock}; 
        @data = m/$regex/;

        # remove data from data 'resevoir' (yes, there is probably a one-liner
        # for these two statements, but I cant think of it :P
        $self->{dataBlock} =~ s/$regex//;

      } else {
        die "Unknown Untagged read format: ",ref($formatObj),", exiting.\n";
      }

      # if we got data, fire it into the array
      if ($#data > -1) {

        @data = &_deal_with_special_integer_data(\@dataFormat, \@data)
           if $data_has_special_integers;

        for (@data) {
#          &_printDebug("ADDING DATA [$locator]($self->{currentArray}) : [".$_."]\n");
          $self->{currentArray}->setData($locator, $_);
          $locator->next();
        }

      } else {

        my $line = join ' ', @data; 
        $self->_printWarning( "Unable to get data! Regex:[$regex] failed on Line: [$line]\n");

      }

      last unless $self->{dataBlock} !~ m/^\s*$/;

    }

  } else {

    # Tagged case: do nothing

  }

}

# we have now read in ALL of the axis that will 
# exist, lets now decipher how to read the tags
sub _data_node_start {
  my ($self, %attrib_hash) = @_;

  # we only need to do this for the first time we enter
  if ($self->{dataNodeLevel} == 0) { 

    # href is special
    if (exists $attrib_hash{'href'}) { 
       my $hrefObj = new XDF::Href(); 
       my $hrefName = $attrib_hash{'href'};

       # this shouldnt happen, but does for unconsidered cases.
       die "XDF::Reader Internal bug: Href Entity $hrefName is not defined. Aborting parse.\n" 
           unless exists $self->{Entity}->{$hrefName}; 

       $hrefObj->setName($hrefName);
       $hrefObj->setSysId(${$self->{Entity}->{$hrefName}}{'sysid'});
       $hrefObj->setBase(${$self->{Entity}->{$hrefName}}{'base'});
       $hrefObj->setNdata(${$self->{Entity}->{$hrefName}}{'ndata'});
       $hrefObj->setPubId(${$self->{Entity}->{$hrefName}}{'pubid'});
       $self->{currentArray}->getDataCube()->setHref($hrefObj);
       delete $attrib_hash{'href'}; # prevent over-writing object with string 

    }

    # update the array dataCube with XML attributes
    $self->{currentArray}->getDataCube()->setXMLAttributes(\%attrib_hash);

  }

  my $readObj = $self->{currentArray}->getXMLDataIOStyle();

  # these days, this should always be defined.
  if (defined $readObj) {

     if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle') {
       $self->{taggedLocatorObject} = $self->{currentArray}->createLocator;
     } else {
       # A safety. We clear datablock when this is the first datanode we 
       # have entered DATABLOCK is used in cases where we read in untagged data
       $self->{dataBlock} = "" if $self->{dataNodeLevel} == 0; 
     }
       
     if (defined (my $href = $self->{currentArray}->getDataCube()->getHref())) {
        # add to the datablock
        $self->{dataBlock} .= $self->_getHrefData($href);
     }

     # this declares we are now reading data, 
     $self->{dataNodeLevel}++; # entered a datanode, raise the count 

  } else {
    die "No read object defined in array. Exiting.\n";
  }

  return $self->{currentArray}->getDataCube;
}

sub _dataFormat_node_start {
  my ($self, %attrib_hash) = @_;
  # save attribs for latter
  $self->{dataFormatAttribRef} = \%attrib_hash;
  return undef;
}

sub _field_node_start {
  my ($self, %attrib_hash) = @_;

   #my $_parentNodeName = $self->_parentNodeName();

   my $fieldObj = $self->{currentArray}->getFieldAxis()->addField(\%attrib_hash);

   # add this object to all open groups
   foreach my $groupObj (@{$self->{currentFieldGroupList}}) { $fieldObj->addToGroup($groupObj); }

   #if(defined $fieldObj && exists($attrib_hash{'fieldId'})) {
   if(defined $fieldObj && (my $id = $fieldObj->getFieldId)) {
      #my $id = $attrib_hash{'fieldId'};
      $self->_printWarning("More than one field node with fieldId=\"$id\", using latest node.\n") 
            if defined $self->{FieldObj}->{$id};
       $self->{FieldObj}->{$id} = $fieldObj;
   }

   $self->{currentDatatypeObject} = $fieldObj;

   return $fieldObj;
}

sub _fieldAxis_node_start {
  my ($self, %attrib_hash) = @_;

   my $axisObj = new XDF::FieldAxis(\%attrib_hash);

   # record this axis
   my $id = $axisObj->getAxisId();
   $self->{currentArrayAxes}->{$id} = $axisObj if defined $id;

   # add in reference object, if it exists 
   if (exists($attrib_hash{'axisIdRef'})) {
      my $id = $attrib_hash{'axisIdRef'};

      # clone from the reference object
      $axisObj = $self->{AxisObj}->{$id}->clone();

      # override with local values
      $axisObj->setXMLAttributes(\%attrib_hash);
      $axisObj->setAxisId($self->_getUniqueIdName($id, \%{$self->{AxisObj}})); # set ID attribute to unique name 
      $axisObj->setAxisIdRef(undef); # unset IDREF attribute 

      # record this axis under its parent id 
      $self->{currentArrayAxes}{$id} = $axisObj;
   }

   # add this object to the lookup table, if it has an ID
   #if ((my $axisId = $attrib_hash{'axisId'})) {
   if ((my $axisId = $axisObj->getAxisId) && !$self->{currentArray}->getAppendTo()) {
      $self->_printWarning( "More than one axis node with axisId=\"$axisId\", using latest node.\n" )
            if defined $self->{AxisObj}->{$axisId};
      $self->{AxisObj}->{$axisId} = $axisObj;
   }

   # add the axis object to the array
   $self->{currentArray}->addFieldAxis($axisObj, undef, 1);

   return $axisObj;
}

sub _fieldGroup_node_end { 
   my ($self) = @_;
   pop @{$self->{currentFieldGroupList}}; 
}

sub _fieldGroup_node_start {
  my ($self, %attrib_hash) = @_;

  my $_parentNodeName = $self->_parentNodeName();

  my $fieldGroupObj;

  if($_parentNodeName eq $XDF_node_name{'fieldAxis'} ) {

    $fieldGroupObj = $self->{currentArray}->getFieldAxis()->addFieldGroup(\%attrib_hash);

  } elsif($_parentNodeName eq $XDF_node_name{'fieldGroup'} ) {

    my $lastGroupObj = $self->{currentFieldGroupList}[$#{$self->{currentFieldGroupList}}];
    $fieldGroupObj = $lastGroupObj->addFieldGroup(\%attrib_hash);

  } else {

     die" weird parent node $_parentNodeName for fieldGroup";

  }

  # add this object to all open groups
  foreach my $groupObj (@{$self->{currentFieldGroupList}}) { $fieldGroupObj->addToGroup($groupObj); }

  # add to the list of open fieldGroups
  push @{$self->{currentFieldGroupList}}, $fieldGroupObj;

  return $fieldGroupObj;
}


sub _field_relationship_node_start {
  my ($self, %attrib_hash) = @_;

   my $fieldObj = $self->_lastFieldObj();
   my $relObj = $fieldObj->setRelation(new XDF::FieldRelation(\%attrib_hash));

   return $relObj;
}

sub _floatField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->{currentDatatypeObject};
  
  my $dataFormatObj;
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataFormatObj = $dataTypeObj->setDataFormat(new XDF::FloatDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string data type/format in $dataTypeObj, ignoring\n";
  
  }

  return $dataFormatObj;
}

sub _for_node_start {              
  my ($self, %attrib_hash) = @_;

  # for node sets the iteration order for how we will setData
  # in the datacube (important for delimited and formatted reads).
  if (defined (my $id = $attrib_hash{'axisIdRef'})) {
    my $axisObj = $self->{currentArrayAxes}->{$id};
    $axisObj = $self->{AxisObj}->{$id} unless defined $axisObj;
    push @{$self->{readAxisOrderList}}, $axisObj;
  } else {
    &_printError("Error: got for node without axisIdRef, aborting read.\n");
    exit (-1); 
  }

  return undef;
}

sub _integerField_node_start {
  my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->{currentDatatypeObject};
  
  my $dataFormatObj;
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataFormatObj = $dataTypeObj->setDataFormat(new XDF::IntegerDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string data type/format in $dataTypeObj, ignoring\n";
  
  }

  return $dataFormatObj;
}

sub _note_node_charData {
  my ($self, $string) = @_;

  if (defined $self->{lastNoteObject}) {
    # add string as the value of the note
    $self->{lastNoteObject}->addText($string);

  } else {

    # error! did they specify a value on an idRef'd node??
    $self->_printWarning("Weird error: tried to put value on non-existent note!($string)\n"); 

  }

}

# this, along with notes_*, needs to be re-written proper
sub _note_node_start {
  my ($self, %attrib_hash) = @_;

   # note: note nodes sometimes appear within notes node,
   # use $self->{lastNotesParentObject} to determine if this is the case
   # (yes this is crappy)
   my $parent_node = defined $self->{lastNotesParentObject} ? $XDF_node_name{'array'} : undef;
   $parent_node = $self->_parentNodeName() unless defined $parent_node;
  
   my $noteObj = new XDF::Note(\%attrib_hash);

   # does this object have a noteIdRef? If so, we clone a copy
   if (exists($attrib_hash{'noteIdRef'})) {
      my $id = $attrib_hash{'noteIdRef'};

      # clone from the reference object
      $noteObj = $self->{NoteObj}{$id}->clone();


      # override with local values
      $noteObj->setXMLAttributes(\%attrib_hash);
      $noteObj->setNoteId($self->_getUniqueIdName($id, \%{$self->{NoteObj}})); # set ID attribute to unique name 
      $noteObj->setNoteIdRef(undef); # unset IDREF attribute 
   }

   # Does this object have a noteId? if so, add to our roster of notes 
   if ((my $id = $noteObj->getNoteId())) {
         $self->_printWarning("More than one note node with noteId=\"$id\", using latest node.\n")
            if defined $self->{NoteObj}{$id};
         $self->{NoteObj}{$id} = $noteObj;
   }

   my $addNoteObj;
   if ($parent_node eq $XDF_node_name{'array'}) {
         $addNoteObj = $self->{currentArray};
   } elsif ($parent_node eq $XDF_node_name{'field'}) {
         $addNoteObj = $self->_lastFieldObj();
   } elsif ($parent_node eq $XDF_node_name{'parameter'}) {
         $addNoteObj = $self->{lastParamObject};
   } else {
         $self->_printWarning( "Unknown parent node: $parent_node for note. Ignoring\n");
   }

   if (defined $addNoteObj) {
      $noteObj = $addNoteObj->addNote($noteObj);
   }

   $self->{lastNoteObject} = $noteObj;

   return $noteObj;
}

sub _note_index_node_start {
   my ($self, %attrib_hash) = @_;
   push @{$self->{noteLocatorOrder}}, $attrib_hash{'axisIdRef'};
   return undef;
}

sub _notes_node_end {
   my ($self) = @_;

   my $notesParentObj = $self->{lastNotesParentObject};

   if (exists $notesParentObj->{Notes}) { 
      my $notesObj = $notesParentObj->{Notes}; 
      for (@{$self->{noteLocatorOrder}}) { $notesObj->addAxisIdToLocatorOrder($_); }
   }

   # reset the location order 
   @{$self->{noteLocatorOrder}} = ();
   
   # clear notes object
   $self->{lastNotesParentObject} = undef;
}

sub _notes_node_start {
   my ($self, %attrib_hash) = @_;

   my $_parentNodeName = $self->_parentNodeName();

   my $obj;
   if ($_parentNodeName eq $XDF_node_name{'field'}) {
        $obj = $self->_lastFieldObj();
   } elsif ($_parentNodeName eq $XDF_node_name{'parameter'}) {
        $obj = $self->{lastParamObject};
   } elsif ($_parentNodeName eq $XDF_node_name{'array'}) {
        $obj = $self->{currentArray};
   } else {
        die "Weird parent $_parentNodeName for notes object\n";
   }

   $self->{lastNotesParentObject} = $obj if defined $obj; # ->notes() if defined $obj;

   #special handling: notes object comes 'pre-defined' in parent,
   # so go to the parent to find it.
   my $notesObj = defined $obj ? $obj->getNotes : undef;
   return $notesObj;
}

sub _parameter_node_start {
   my ($self, %attrib_hash) = @_;

   my $_parentNodeName = $self->_parentNodeName();

   my $paramObj;
   if($_parentNodeName eq $XDF_node_name{'array'} ) {

        $paramObj = $self->{currentArray}->addParameter(\%attrib_hash);

   } elsif($_parentNodeName eq $XDF_node_name{'root'}
              || $_parentNodeName eq $XDF_node_name{'structure'})
   { 

        $paramObj = $self->{currentStructure}->addParameter(\%attrib_hash);

   } elsif($_parentNodeName eq $XDF_node_name{'parameterGroup'} ) {

#        $LAST_GROUP_OBJECT->addObject(new XDF::Parameter(\%attrib_hash));
        # for now, just add as regular parameter 
       $paramObj = $self->{lastParamGroupParentObject}->addParameter(\%attrib_hash);

   } else {
       die" weird parent node $_parentNodeName for parameter";
   }

   # add this object to all open groups
   foreach my $groupObj (@{$self->{currentParamGroupList}}) { $paramObj->addToGroup($groupObj); }

   $self->{lastParamObject} = $paramObj;

   return $paramObj;
}

sub _parameterGroup_node_end { 
   my ($self) = @_;
   pop @{$self->{currentParamGroupList}}; 
}

sub _parameterGroup_node_start {
   my ($self, %attrib_hash) = @_;
  
  my $_parentNodeName = $self->_parentNodeName();

  my $paramGroupObj;

  if($_parentNodeName eq $XDF_node_name{'array'} ) {

    $paramGroupObj = $self->{currentArray}->addParamGroup(\%attrib_hash);
    $self->{lastParamGroupParentObject} = $self->{currentArray};

  } elsif($_parentNodeName eq $XDF_node_name{'root'}
              || $_parentNodeName eq $XDF_node_name{'structure'})
  {

    $paramGroupObj = $self->{currentStructure}->addParamGroup(\%attrib_hash);
    $self->{lastParamGroupParentObject} = $self->{currentStructure};

  } elsif($_parentNodeName eq $XDF_node_name{'parameterGroup'} ) {

    my $lastGroupObj = $self->{currentParamGroupList}[$#{$self->{currentParamGroupList}}]; 
    $paramGroupObj = $lastGroupObj->addParamGroup(\%attrib_hash);

  } else {

     die" weird parent node $_parentNodeName for parameterGroup";

  }

  # add this object to all open groups
  foreach my $groupObj (@{$self->{currentParamGroupList}}) { $paramGroupObj->addToGroup($groupObj); }

  # now add it to the list
  push @{$self->{currentParamGroupList}}, $paramGroupObj;

  return $paramGroupObj;
}

sub _read_node_end {
  my ($self) = @_;

  my $readObj = $self->{currentArray}->getXMLDataIOStyle();

  die "Fatal: No XMLDataIOStyle defined for this array!, exiting" unless defined $readObj;

  # initialization for XDF::Reader specific internal GLOBALS
  if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

# is this needed??
#    # zero out all the tags
#    foreach my $tag ($readObj->getAxisTags()) {
#      $self->{tagCount}->{$tag} = 0;
#    }

  } elsif (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle' or
           ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' ) 
  {
     # do nothing
  } else {
     die "Dont know what do with this read style (",$readObj->style(),").\n";
  } 

}

sub _read_node_start { 
   my ($self, %attrib_hash) = @_;

  # zero this out for upcoming read 
  @{$self->{readAxisOrderList}} = ();

  # clear out the format command object array
  # (its used by Formatted reads only, but this is reasonable 
  # spot to do this).
  @{$self->{currentFormatObjectList}} = ();

  # do we have an idREf? if so, copy the object, otherwise we will 
  # save these for later, when we know what kind of dataIOstyle we got
  # use reference object, if refId exists 
  my $readIdRef = $attrib_hash{'readIdRef'};
  my $readObj;
  if (defined $readIdRef) {

     # clone from the reference object
     $readObj = $self->{XMLDataIOStyleObj}{$readIdRef}->clone();

     # override with local values
     $readObj->setXMLAttributes(\%attrib_hash);

     # set ID attribute to unique name 
     $readObj->setReadId($self->_getUniqueIdName($readIdRef, \%{$self->{XMLDataIOStyleObj}}));
     $readObj->setReadIdRef(undef); # unset IDREF attribute 

     $self->{currentArray}->setXMLDataIOStyle($readObj);

     push @{$self->{currentFormatObjectList}}, $self->{currentArray}->getXMLDataIOStyle();

     # populate readorder array. We will have problems if someone specifies
     # readIdRef AND has child for nodes on the read node. fef.  
     my $oldArrayObj = $self->{XMLDataIOStyleObj}{$readIdRef}->{_parentArray}; #shouldnt be allowed to do this 
     foreach my $oldAxisObj (@{$self->{readAxisOrderHash}{$oldArrayObj}}) {
        my $axisObj = $self->{currentArrayAxes}->{$oldAxisObj->getAxisId};
        if (defined $axisObj) {
          push @{$self->{readAxisOrderList}}, $axisObj; 
        } else {
          die "Bad code error: axisObj not found in CURRENT_ARRAY_AXES.\n";
        }
     }
   
     # add this object to the lookup array
     my $id = $readObj->getReadId();
     $self->{XMLDataIOStyleObj}{$id} = $readObj;

  } else { 
     $self->{dataIOStyleAttribRef} = \%attrib_hash;
  }

  return $readObj;

}

sub _readCell_node_start { 
   my ($self, %attrib_hash) = @_;

  # if this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  if ( defined $self->{dataIOStyleAttribRef}) {
    $self->{currentArray}->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($self->{dataIOStyleAttribRef}));

    my $readId = $self->{currentArray}->getXMLDataIOStyle()->getReadId();
    if (defined $readId ) {
       $self->_printWarning( "Danger: More than one read node with readId=\"$readId\", using latest node.\n" )          
           if defined $self->{XMLDataIOStyleObj}{$readId};
       $self->{XMLDataIOStyleObj}{$readId} = $self->{currentArray}->getXMLDataIOStyle();

    }

    $self->{dataIOStyleAttribRef} = undef;
    push @{$self->{currentFormatObjectList}}, $self->{currentArray}->getXMLDataIOStyle();
  } 

  my $formatObj = $self->_currentFormatObject();
  my $readCellObj = $formatObj->addFormatCommand(new XDF::ReadCellFormattedIOCmd(\%attrib_hash));

  return $readCellObj;
}

sub _repeat_node_end { 
   my ($self) = @_;
   pop @{$self->{currentFormatObjectList}}; 
}

sub _repeat_node_start {
   my ($self, %attrib_hash) = @_;

  # If this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  if ( defined $self->{dataIOStyleAttribRef}) {
    $self->{currentArray}->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($self->{dataIOStyleAttribRef}));

    my $readId = $self->{currentArray}->getXMLDataIOStyle()->getReadId();
    if ( defined $readId ) {
       $self->_printWarning( "Danger: More than one read node with readId=\"$readId\", using latest node.\n" )          
           if defined $self->{XMLDataIOStyleObj}{$readId};
       $self->{XMLDataIOStyleObj}{$readId} = $self->{currentArray}->getXMLDataIOStyle();

    }

    $self->{dataIOStyleAttribRef} = undef;
    push @{$self->{currentFormatObjectList}}, $self->{currentArray}->getXMLDataIOStyle();
  } 

  my $formatObj = $self->_currentFormatObject();
  my $repeatObj = $formatObj->addFormatCommand(new XDF::RepeatFormattedIOCmd(\%attrib_hash));
 
  push @{$self->{currentFormatObjectList}}, $repeatObj;

  return $repeatObj;
}

sub _root_node_start { 
   my ($self, %attrib_hash) = @_;
  
  # this is just like a "structure" node.
  # but is always the first one.
  # $self->{XDF} = XDF::Structure->new(\%attrib_hash);
  $self->{XDF}->setXMLAttributes(\%attrib_hash);
  $self->{currentStructure} = $self->{XDF};

  my $spec= XDF::Specification->getInstance();
  $spec->setDefaultDataArraySize($self->{Options}->{axisSize})
      if defined $self->{Options}->{axisSize};

  return $self->{currentStructure};
}

sub _skipChar_node_start {
   my ($self, %attrib_hash) = @_;

  # If this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  if ( defined $self->{dataIOStyleAttribRef}) {
    $self->{currentArray}->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($self->{dataIOStyleAttribRef}));

    my $readId = $self->{currentArray}->getXMLDataIOStyle()->getReadId();
    if (defined $readId ) {
       $self->_printWarning( "Danger: More than one read node with readId=\"$readId\", using latest node.\n" )          
           if defined $self->{XMLDataIOStyleObj}{$readId};
       $self->{XMLDataIOStyleObj}{$readId} = $self->{currentArray}->getXMLDataIOStyle();

    }

    $self->{dataIOStyleAttribRef} = undef;
    push @{$self->{currentFormatObjectList}}, $self->{currentArray}->getXMLDataIOStyle();
  }

  my $formatObj = $self->_currentFormatObject();
  my $skipCharObj = $formatObj->addFormatCommand(new XDF::SkipCharFormattedIOCmd(\%attrib_hash));

  return $skipCharObj;
}

sub _stringField_node_start {
   my ($self, %attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$self->{dataFormatAttribRef}}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = $self->{currentDatatypeObject}; 
  my $dataFormatObj;
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) { 

     $dataFormatObj = $dataTypeObj->setDataFormat(new XDF::StringDataFormat(\%merged_hash));

  } else {

    warn "Unknown parent object, cant set string dataformat in $dataTypeObj, ignoring\n";

  }
  return $dataFormatObj;
}

sub _structure_node_start {
  my ($self, %attrib_hash) = @_;

   if (!defined $self->{XDF}) {
      $self->{XDF} = XDF::Structure->new(\%attrib_hash);
      $self->{currentStructure} = $self->{XDF};
   } else {
      my $structObj = $self->{currentStructure}->addStructure(\%attrib_hash);
      $self->{currentStructure} = $structObj;
   }
   
   return $self->{currentStructure};
}

sub _tagToAxis_node_start {
   my ($self, %attrib_hash) = @_;

  # well, if we see tagToAxis nodes, must have tagged data, the 
  # default style. No need for initing further. 
  if ( defined $self->{dataIOStyleAttribRef}) {
    $self->{currentArray}->setXMLDataIOStyle(new XDF::TaggedXMLDataIOStyle($self->{dataIOStyleAttribRef}));

    my $readId = $self->{currentArray}->getXMLDataIOStyle()->getReadId();
    if (defined $readId) {
       $self->_printWarning( "Danger: More than one read node with readId=\"$readId\", using latest node.\n" )          
           if defined $self->{XMLDataIOStyleObj}->{$readId};
       $self->{XMLDataIOStyleObj}->{$readId} = $self->{currentArray}->getXMLDataIOStyle();

    }

  }

  $self->{dataIOStyleAttribRef} = undef;

  # add in the axis, tag information
  $self->{currentArray}->getXMLDataIOStyle()->setAxisTag($attrib_hash{'tag'}, $attrib_hash{'axisIdRef'});

  return undef;
}

sub _unit_node_charData {
  my ($self, $string) = @_;

  if (defined $self->{lastUnitObject}) {
    # add string as the value of the note
    $self->{lastUnitObject}->setValue($string);

  } else {

    # error! did they specify a value on an idRef'd node??
    $self->_printWarning( "Crazy error! tried to put value on non-existent note!($string)\n");

  }

}

sub _unit_node_start {
   my ($self, %attrib_hash) = @_;

  my $_parentNodeName = $self->_grandParentNodeName();

  my $unitObj;

  if ($_parentNodeName eq $XDF_node_name{'field'} ) {

     # add the unit to the last parameter node in grandparent
      my $fieldObj = $self->_lastFieldObj();

      $unitObj = $fieldObj->addUnit(\%attrib_hash);

  } elsif ($_parentNodeName eq $XDF_node_name{'axis'} ) {

      my $axisObj = $self->_lastAxisObj();
      $unitObj = $axisObj->addUnit(\%attrib_hash);

  } elsif ($_parentNodeName eq $XDF_node_name{'array'} ) {

      $unitObj = $self->{currentArray}->addUnit(\%attrib_hash);

  } elsif ($_parentNodeName eq $XDF_node_name{'parameter'} ) {

      my $paramObj = $self->{lastParamObject};
      $unitObj = $paramObj->addUnit(\%attrib_hash);

  } else {

      $self->_printWarning( "Got Weird parent node ($_parentNodeName) for unit. \n");

  }

  $self->{lastUnitObject} = $unitObj;

  return $unitObj;
}

sub _units_node_start { 
   my ($self, %attrib_hash) = @_;
  # do nothing
  return undef;
}

sub _unitless_node_start {
   my ($self, %attrib_hash) = @_;
  # do nothing
  return undef;
}

sub _value_node_charData {
  my ($self, $string) = @_;

  my $parent_node = $self->_parentNodeName();

  my $valueObj;

  if ($parent_node eq $XDF_node_name{'parameter'} ) {

     # add the value in $string to last parameter node in grandparent
     my $paramObj = $self->{lastParamObject};
     $valueObj = $paramObj->addValue($string);

  } elsif ($parent_node eq $XDF_node_name{'axis'} ) {

     # add the value in $string to last axis node in current array 
     my $axisObj = $self->_lastAxisObj();
     $valueObj = $axisObj->addAxisValue($string);

  } elsif ( $parent_node eq $XDF_node_name{'valueGroup'} ) {

    if (ref($self->{lastValueGroupParentObject}) eq 'XDF::Parameter') {

       $valueObj = $self->{lastValueGroupParentObject}->addValue($string);

    } elsif (ref($self->{lastValueGroupParentObject}) eq 'XDF::Axis') {

       $valueObj = $self->{lastValueGroupParentObject}->addAxisValue($string);

    } else {
      my $name = ref($self->{lastValueGroupParentObject});
      die " ERROR: UNKNOWN valueGroupParent object ($name), can't treat for value.\n";
    }
     
  } else {

     die " ERROR: UNKNOWN parent node ($parent_node), can't treat for value.\n";

  }

  # add this object to all open groups
  foreach my $groupObj (@{$self->{currentValueGroupList}}) { $valueObj->addToGroup($groupObj); }

}

sub _valueGroup_node_end { 
   my ($self) = @_;
   pop @{$self->{currentValueGroupList}}; 
}

sub _valueGroup_node_start {
   my ($self, %attrib_hash) = @_;

  my $_parentNodeName = $self->_parentNodeName();

  my $valueGroupObj;

  if( $_parentNodeName eq $XDF_node_name{'axis'} ) {

    my $axisObj = $self->_lastAxisObj();
    $valueGroupObj = $axisObj->addValueGroup(\%attrib_hash);
    $self->{lastValueGroupParentObject} = $axisObj;

  } elsif($_parentNodeName eq $XDF_node_name{'parameter'} ) {

    my $paramObj = $self->{lastParamObject};
    $valueGroupObj = $paramObj->addValueGroup(\%attrib_hash);
    $self->{lastValueGroupParentObject} = $paramObj;

  } elsif($_parentNodeName eq $XDF_node_name{'valueGroup'} ) {

    my $lastGroupObj = $self->{currentValueGroupList}->[$#{$self->{currentValueGroupList}}];
    $valueGroupObj = $lastGroupObj->addValueGroup(\%attrib_hash);

  } else {

     die" weird parent node $_parentNodeName for valueGroup";

  }

  foreach my $groupObj (@{$self->{currentValueGroupList}}) { $valueGroupObj->addToGroup($groupObj); }

  # now add it to the list
  push @{$self->{currentValueGroupList}}, $valueGroupObj;

  return $valueGroupObj;
}

sub _valueList_node_charData {
  my ($self, $string) = @_;

  # split up string based on declared delimiter
  my $delimiter = '/' . $self->{currentValueList}->{'delimiter'};
  if ($self->{currentValueList}->{'repeatable'} eq 'yes') {
    $delimiter .= '+/';
  } else {
    $delimiter .= '/';
  } 
  my @values;
  eval " \@values = split $delimiter, \$string ";

  my @valueObjList = ();

  # need dispatch list for this too
  if ($self->{currentValueList}->{'parent_node'} eq $XDF_node_name{'axis'} )
  {

      # adding values to the last axis in the array
      my $axisObj = $self->_lastAxisObj();
      foreach my $val (@values) { 
         push @valueObjList, $axisObj->addAxisValue($val); 
      }

  } elsif ($self->{currentValueList}->{'parent_node'} eq $XDF_node_name{'parameter'} ) {

     # adding values to the last axis in the array
     my $paramObj = $self->{lastParamObject};
     foreach my $val (@values) { 
        push @valueObjList, $paramObj->addValue($val); 
     }

  } elsif ($self->{currentValueList}->{'parent_node'} eq $XDF_node_name{'valueGroup'} ) {

     my $method;
     if (ref($self->{lastValueGroupParentObject}) eq 'XDF::Parameter') {
       $method = "addValue";
     } elsif (ref($self->{lastValueGroupParentObject}) eq 'XDF::Axis') {
        $method = "addAxisValue";
     } else {
       my $name = ref($self->{lastValueGroupParentObject});
       die " ERROR: UNKNOWN valueGroupParent object ($name), can't treat for valueList.\n";
     }

     # adding values to the last axis in the array
     foreach my $val (@values) { 
       push @valueObjList, $self->{lastValueGroupParentObject}->$method($val);
     }

  } else {

     die " ERROR: UNKNOWN parent node (",$self->{currentValueList}->{'parent_node'},") can't treat for valueList.\n";

  }

  # add these new value objects to all open groups
  foreach my $groupObj (@{$self->{currentValueGroupList}}) { 
    foreach my $valueObj (@valueObjList) { $valueObj->addToGroup($groupObj); }
  }

}

sub _valueList_node_start { 
   my ($self, %attrib_hash) = @_;

   my $parent_node = $self->_parentNodeName();

   my @values = &_get_valueList_node_values(%attrib_hash);

   # IT could be that no values exist because they are stored
   # in PCDATA rather than as alorithm (treat in char data handler
   # in this case).
   if($#values != -1 ) {
    
     my @valueObjList = ();

     # adding values to the last axis in the array
     if ($parent_node eq $XDF_node_name{'axis'}) {

        my $axisObj = $self->_lastAxisObj();
        foreach my $val (@values) { 
           push @valueObjList, $axisObj->addAxisValue($val); 
        }

      } elsif($parent_node eq $XDF_node_name{'valueGroup'}) {

        my $method;
        if (ref($self->{lastValueGroupParentObject}) eq 'XDF::Parameter') {
           $method = "addValue";
        } elsif (ref($self->{lastValueGroupParentObject}) eq 'XDF::Axis') {
           $method = "addAxisValue";
        } else {
           my $name = ref($self->{lastValueGroupParentObject});
           die " ERROR: UNKNOWN valueGroupParent object ($name), can't treat for valueList.\n";
        }

        foreach my $val (@values) { 
           push @valueObjList, $self->{lastValueGroupParentObject}->$method($val); 
        }

      } elsif($parent_node eq $XDF_node_name{'parameter'}) {

         my $paramObj = $self->{lastParamObject};
         foreach my $val (@values) { 
            push @valueObjList, $paramObj->addValue($val); 
         }

      } else {

        die "Value List node got weird parent node: $parent_node\n";

      }

      # add these new value objects to all open groups
      foreach my $groupObj (@{$self->{currentValueGroupList}}) {
        foreach my $valueObj (@valueObjList) { $valueObj->addToGroup($groupObj); }
      }

   } else {

         $self->{currentValueList}->{'parent_node'} = $parent_node;
         $self->{currentValueList}->{'delimiter'} = defined $attrib_hash{'delimiter'} ?
               $attrib_hash{'delimiter'} : $Def_ValueList_Delimiter;
         $self->{currentValueList}->{'repeatable'} = defined $attrib_hash{'repeatable'} ?
               $attrib_hash{'repeatable'} : $Def_ValueList_Repeatable;

   }

   return undef;
}

sub _vector_node_start { 
   my ($self, %attrib_hash) = @_;

  my $parent_node = $self->_parentNodeName();

  my $axisValueObj;
  if ($parent_node eq $XDF_node_name{'axis'}) {

     my $axisObj = $self->_lastAxisObj();
     my $axisValueObj = $axisObj->addAxisUnitDirection(\%attrib_hash);

  } else {
        $self->_printWarning( "$XDF_node_name{'vector'} node not supported for $parent_node yet. Ignoring node.\n");
  }

  return $axisValueObj; 

}

#
# Other misc subroutines needed for the SaxDocumentHandler
#

# 
# Protected methods
#

sub _printDebug { 
   my ($msg) = @_; 
   print STDERR $msg if $DEBUG; 
}

sub _print_extreme_debug { 
   my ($msg) = @_; 
   print STDERR $msg if $DEBUG > 1; 
}

sub _printError { 
   my ($msg) = @_; 
   print STDERR $msg; 
}

sub _printWarning {
  my ($self, $msg) = @_;
  warn "$msg";
  die "$0 exiting, too many warnings.\n" if ($self->{Options}->{maxWarnings} > 0 && 
                                             $self->{nrofWarnings}++ > $self->{Options}->{maxWarnings});
}

sub _currentFormatObject {
  my ($self)=@_;
  return $self->{currentFormatObjectList}->[$#{$self->{currentFormatObjectList}}]; 
}

sub _lastObj {
  my ($self)=@_;
  return @{$self->{lastObjList}}->[$#{$self->{lastObjList}}];
}

sub _lastFieldObj {
  my ($self)=@_;
  my @list = $self->{currentArray}->getFieldAxis()->getFields;
  return $list[$#list];
}

sub _lastAxisObj {
  my ($self)=@_;
  return @{$self->{currentArray}->getAxisList()}->[$#{$self->{currentArray}->getAxisList()}]; 
}

#/** _currentNodeName
# Find the node name of the node the parser is currently working on.
#*/
sub _currentNodeName {
  my ($self)=@_;
  return $self->{currentNodePath}->[$#{$self->{currentNodePath}}]; 
}

#/** _parentNodeName
# Find the node name of the parent to the current node the parser
# is currently working on.
#*/
sub _parentNodeName {
   my ($self)=@_;
   return $self->{currentNodePath}->[$#{$self->{currentNodePath}}-1]; 
}

#/** _grandParentNodeName
# Find the node name of the grandparent to the current node the parser
# is currently working on.
#*/
sub _grandParentNodeName {
  my ($self)=@_;
  return $self->{currentNodePath}->[$#{$self->{currentNodePath}}-2]; 
}

#/** _getUniqueIdName
# Given a key value and a hash table reference, this will find a unique key value
# which is returned.
# */
sub _getUniqueIdName {
   my ($self, $id, $hash_ref) = @_;
   my %hash = %{$hash_ref};
  
   # this will create axes with name that has trailing zeros 
   while (exists $hash{$id}) { $id .= '0'; }

   return $id;
}
 

#
# Private methods
#

sub _null_cmd { }

sub _getCurrentDataDeCompression {
  my ($self)= @_;

  my $compression_type = $self->{currentArray}->getDataCube()->getCompression();
  return $self->_dataDecompressionProgram($compression_type);
}

# only perl needs this. Need as private method?
# Certainly this implementation is bad, very bad. 
# At the minimum we need to put this info in constants
# class and make it user configurable at make time.
sub _dataDecompressionProgram {
  my ($self, $compression_type) = @_;

  return unless defined $compression_type;
  
  my $compression_program;
  if ($compression_type eq &XDF::Constants::DATA_COMPRESSION_GZIP() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_GZIP_PATH() . ' -dc '; 
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_BZIP2() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_BZIP2_PATH() . ' -dc '; 
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_COMPRESS() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_COMPRESS_PATH() . ' -dc '; 
  } elsif ($compression_type eq &XDF::Constants::DATA_COMPRESSION_ZIP() ) {
     $compression_program = &XDF::Constants::DATA_COMPRESSION_UNZIP_PATH() . ' -p '; 
  } else {
     die "Data decompression for type: $compression_type NOT Implemented. Aborting read.\n";
  }
  
  return $compression_program;
}

sub _init {
  my ($self, $optionsHashRef) = @_;

  $self->{XDF} = new XDF::Structure; # reference to the toplevel XDF structure we are populating
  $self->{currentFormatObjectList} = []; 
  $self->{currentFieldGroupList} = []; 
  $self->{currentParamGroupList} = []; 
  $self->{currentValueGroupList} = []; 
  $self->{currentArrayAxes} = {};

  $self->{readAxisOrderList} = []; # @{$self->{readAxisOrderList} = ();
  $self->{readAxisOrderHash} = {}; # %ReadAxisOrder;

  #$self->{dataFormatAttribRef};  # used for holding on to the attrib_hash of a 'read' node
                                 # for later when we know what kind of DataFormat obj to use

  #$self->{dataIOStyleAttribRef}; # used for holding on to the attrib_hash of a 'read' node
                                 # for later when we know what kind of DataIOStyle obj to use

  # needed to capture internal entities.
  $self->{Notation} = {}; # hash 
  $self->{Entity} = {}; # hash
  $self->{UnParsedEntity} = {};

  # needed to allow many supporting subroutines (like _parentNodeName) 
  # to work. Indicates our current position within the Document as we are
  # parsing it. 
  $self->{currentNodePath} = []; # array

  # global (switch) variables 
  #$self->{cdataIsArrayData};    # Tells us when we are accepting char_data as data 
  $self->{dataNodeLevel} = 0;   # how nested we are within a set of datanodes. 
  $self->{currentDataTagLevel} = 0; # how nested we are within d0/d1/d2 data tags
  $self->{dataTagLevel} = 0;         # the level where the actual char data is

  # our options reference array
  $self->{Options} = defined $optionsHashRef && ref($optionsHashRef) ? $optionsHashRef : {}; # hash 
  $self->{Options}->{msgThresh} = $PARSER_MSG_THRESHOLD unless defined $self->{Options}->{msgThresh};
  $self->{Options}->{maxWarnings} = $MAX_WARNINGS unless defined $self->{Options}->{maxWarnings};
  $self->{Options}->{quiet} = $QUIET unless defined $self->{Options}->{quiet};
  $DEBUG = $self->{Options}->{debug} if defined $self->{Options}->{debug};

#print STDERR "reader debug is ",$DEBUG,"\n";
#print STDERR "reader quiet is ",$self->{Options}->{quiet},"\n";

  # lookup hashes of handlers 
  $self->{startElementHandler} = \%Start_Handler;
  $self->{endElementHandler} = \%End_Handler;
  $self->{charDataHandler} = \%CharData_Handler;
  $self->{defaultHandler} = \%Default_Handler;

  #$self->{dataBlock}; # collects/holds the cdata for eventual untagged read 
  
  # next thing is needed for tagged reads only 
# needed??
#  $self->{tagCount} = {}; # hash; (tagged read only) stores the number count of each 
#                          # tag read in 

  # allows us to store the ordering of the axisIDRef's in 
  # the notes locationOrder tag (so we can cross link it)
  $self->{noteLocatorOrder} = []; # array
  
  # need this in order to properly simulate action of valueList node
  my %valueListHash = ( 'parent_node' => "",
                        'delimiter' => "",
                        'repeatable' => "",
                      );
  $self->{currentValueList} = \%valueListHash;

  # hashes to keep track of various
  # ID's (so we can use IDREF mech to reference objects)
  $self->{ArrayObj} = {}; # hash
  $self->{AxisObj} = {};
  $self->{FieldObj} = {};
  $self->{XMLDataIOStyleObj} = {};
  $self->{NoteObj} = {};

  $self->{nrofWarnings} = 0; # a counter that is compared to $MAX_WARNINGS to see if we halt 

  $self->{lastObjList} = []; # a list of objects, should map roughly to xml node traversal order 
                             # but may contain null entries since not all XML nodes coorespond to XDF objects.
}

sub _create_parser {
  my ($self) = @_;
  
  my $nameSpaces = 0;
  my $parseParamEnt = 0;
  my $noExpand = 0;
  
#  if (defined $optionsHashRef) {
#    my %option = %{$optionsHashRef};
    $noExpand = $self->{Option}->{noExpand} if exists $self->{Option}->{noExpand};
    $nameSpaces = $self->{Option}->{namespaces} if exists $self->{Option}->{namespaces};
    $parseParamEnt = $self->{Option}->{parseParamEnt} if exists $self->{Option}->{parseParamEnt};
#  }

   my $parser = new XML::Parser(  
                                ParseParamEnt => $parseParamEnt,
                                NoExpand => $noExpand,
                                Namespaces => $nameSpaces,
                                Handlers => {
                                     Start => sub { &_handle_start($self, @_); },
                                     End   => sub { &_handle_end($self, @_); },
                                     Init =>  sub { &_handle_init($self, @_); }, 
                                     Final => sub { &_handle_final($self, @_); },
                                     Char  => sub { &_handle_char($self, @_); },
                                     Proc =>  sub { &_handle_proc($self, @_); },
                                     Comment => sub { &_handle_comment($self, @_); },
                                     CdataStart => sub { &_handle_cdata_start($self, @_); },
                                     CdataEnd => sub { &_handle_cdata_end($self, @_); },
                                     ExternEnt => sub { &_handle_external_ent($self, @_); },
                                     Entity =>  sub { &_handle_entity($self, @_); },
                                     Element => sub { &_handle_element($self, @_); },
                                     XMLDecl => sub { &_handle_xml_decl($self, @_); },
                                     Notation => sub { &_handle_notation($self, @_); },
                                     Unparsed => sub { &_handle_unparsed($self, @_); },
                                     Doctype => sub { &_handle_doctype($self, @_); },
                                     Attlist => sub { &_handle_attlist($self, @_); },
                                     Default => sub { &_handle_default($self, @_); },
                                            }
                              );

  return $parser;

}

sub _create_validating_parser {
  my ($optionsHashRef) = @_;

  my $noExpand = 0;
  my $nameSpaces = 0;
  my $parseParamEnt = 0;

  if (defined $optionsHashRef) {
    my %option = %{$optionsHashRef};
    $noExpand = $option{'noExpand'} if exists $option{'noExpand'};
    $nameSpaces = $option{'namespaces'} if exists $option{'namespaces'};
    $parseParamEnt = $option{'parseParamEnt'} if exists $option{'parseParamEnt'};
  }

   my $parser = new XML::Checker::Parser (
                                ParseParamEnt => $parseParamEnt,
                                NoExpand => $noExpand,
                                Namespaces => $nameSpaces,
                                Handlers => {
                                     Start => \&_handle_start,
                                     End   => \&_handle_end,
                                     Init => \&_handle_init,
                                     Final => \&_handle_final,
                                     Char  => \&_handle_char,
                                     Proc => \&_handle_proc,
                                     Comment => \&_handle_comment,
                                     CdataStart => \&_handle_cdata_start,
                                     CdataEnd => \&_handle_cdata_end,
                                     ExternEnt => \&_handle_external_ent,
                                     Entity => \&_handle_entity,
                                     Element => \&_handle_element,
                                     XMLDecl => \&_handle_xml_decl,
                                     Notation => \&_handle_notation,
                                     Unparsed => \&_handle_unparsed,
                                     Doctype => \&_handle_doctype,
                                     Attlist => \&_handle_attlist,
                                     Default => \&_handle_default,
                                            }
                              );

}

# Throws an exception (with die) when an error is encountered, this
# will stop the parsing process.
# Don't die if a warning or info message is encountered, just print a message.
sub _my_fail {
   my $self = shift;
   my $code = shift;
   die XML::Checker::error_string ($code, @_) if $code < 200;
   XML::Checker::_printError ($code, @_) if $code < $self->{Options}->{msgThresh};
}

sub _change_integerField_data_to_flagged_format {
  my ($integerFormatObj, $datum ) = @_;

  return $datum unless (defined $integerFormatObj);

  my $formatflag = $integerFormatObj->type();
  return $datum unless defined $formatflag;

  if ($formatflag eq $Flag_Decimal ) {

    return $datum; # do nothing 

  } elsif ($formatflag eq $Flag_Octal ) {

    return oct($datum);

  } elsif ($formatflag eq $Flag_Hex ) {

    return hex($datum);

  } else {

    &_printError("XDF::Reader does'nt understand integer type: $formatflag\n");
    return $datum;
  }

}


sub _make_attrib_array_a_hash {
  my (@array) = @_;

  my %hash;

  while (@array) {
     my $var = shift @array;
     my $val = shift @array;
     &_printError( "duplicate attributes for $var, overwriting\n")
       unless !defined $hash{$var} || $QUIET;
     $hash{$var} = $val;
  }

  return %hash;
}

sub _deal_with_binary_data {
  my ($dataFormatListRef, $data_ref, $endian) = @_;

  my @data = @{$data_ref};
  my @dataFormatList = @{$dataFormatListRef};

  foreach my $dat_no (0 .. $#dataFormatList) {
     if ( ref($dataFormatList[$dat_no]) eq 'XDF::BinaryIntegerDataFormat') {
        $data[$dat_no] = $dataFormatList[$dat_no]->convertBitStringToIntegerBits($data[$dat_no], $endian);
     } elsif ( ref($dataFormatList[$dat_no]) eq 'XDF::BinaryFloatDataFormat') {
        $data[$dat_no] = $dataFormatList[$dat_no]->convertBitStringToFloatBits($data[$dat_no], $endian);
     }
  }

  return @data;
}

sub _arrayHasSpecialIntegers {
  my ($array) = @_;

  my @dataFormatList = $array->getDataFormatList();
  return 0 if (!@dataFormatList);

  foreach my $dataType (@dataFormatList) {
    if (ref($dataType) eq 'XDF::IntegerDataFormat') {
      return 1 if $dataType->getType() ne $Flag_Decimal;
    }
  }
  return 0;
}

sub _arrayHasBinaryData {
  my ($array) = @_;

  my @dataFormatList = $array->getDataFormatList();
  return 0 if (!@dataFormatList);

  foreach my $dataType (@dataFormatList) {
    return 1 if ref($dataType) =~ m/XDF::Binary/;
  }

  return 0;
}

# Treatment for hex, octal reads
# that can occur in formatted data
sub _deal_with_special_integer_data {
  my ($dataFormatListRef, $data_ref) = @_;

  my @data = @{$data_ref};
  my @dataFormatList = @{$dataFormatListRef};

  foreach my $dat_no (0 .. $#dataFormatList) {
    $data[$dat_no] = &_change_integerField_data_to_flagged_format($dataFormatList[$dat_no], $data[$dat_no] )
                if ref($dataFormatList[$dat_no]) eq 'XDF::IntegerDataFormat';
  }

  return @data;
}

# very limited. We want to just treat the linear
# insertion case 
sub _get_valueList_node_values {
  my (%attrib) = @_;

  my $size = $attrib{'size'};
  my $start = defined $attrib{'start'} ? $attrib{'start'} : $Def_ValueList_Start;
  my $step = defined $attrib{'step'} ? $attrib{'step'} : $Def_ValueList_Step ;

  my @values = ();

  if (!defined $attrib{'delimiter'}) {
     my $val = $start;
     while ($size-- > 0) {
        push @values, $val;
        $val += $step;
     }

  } # else {
    # warn "This code cant treat this case for valueList.\n"; 
  # }

  return @values;
}

# this is the actual default start handler for the Reader.
# (see Default_Handler hash)
# This subroutine WONT be used if the user uses the method
# setDefaultStartHandler().
sub _default_start_handler {
   my ($self,$e, $attrib_hash_ref) = @_;

   my $parentNodeName = $self->_parentNodeName();
   my $newelement;

   # the DTD sez that if we get non-xdf defined nodes, it IS 
   # allowed as long as these are children of the following 
   # XDF defined nodes, OR are children of a non-XDF defined node
   # (e.g. the child of one of these nodes, which we call 'XDF::XMLElement')
   if( $parentNodeName eq $XDF_node_name{'structure'} 
       || $parentNodeName eq $XDF_node_name{'root'} 
     ) 
   {

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->{currentStructure}->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'array'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->{currentArray}->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'fieldAxis'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->{currentArray}->getFieldAxis->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'axis'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->_lastAxisObj->addXMLElement($newelement);

   } elsif( $parentNodeName eq $XDF_node_name{'field'} ) { 

     $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
     $self->_lastFieldObj()->addXMLElement($newelement);

   } else {

      my $lastObj = $self->_lastObj; 
      if (defined $lastObj && ref($lastObj) eq 'XDF::XMLElement') {

         $newelement = &_create_new_XMLelement($e, $attrib_hash_ref);
         $lastObj->addXMLElement($newelement);

      } else {
         $self->_printWarning("Warning: ILLEGAL NODE:[$e] (child of $parentNodeName) encountered. Ignoring.\n") 
            unless $self->{Options}->{quiet}; 
      }

   }

   return $newelement;
}

# create a new XML element from passed attributes
sub _create_new_XMLelement {
  my ($name, $attrib_hash_ref) = @_;

   my $newelement = new XDF::XMLElement($name);
#   $newelement->setTagName($name);
   while ( my ($key, $value) = each %{$attrib_hash_ref}) {
#        my $attribObj = new XDF::XMLAttribute($key);
#        $attribObj->setName($key);
#        $attribObj->setValue($value);
        $newelement->setAttribute($key, $value);
   }
   return $newelement;
}

# this is the actual default CDATA handler for the Reader.
# This subroutine WONT be used if the user uses the method
# setCharDataHandler()
sub _default_cdata_handler {
   my ($self, $string) = @_;

   if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {
      my $lastObj = $self->_lastObj();
      if (defined $lastObj) {
         if (ref($lastObj) eq 'XDF::XMLElement') {
           $lastObj->appendCData($string);
         } else {
            $self->_printWarning("Warning: cant do anything with CDATA:[$string] for ".ref($lastObj).". Ignoring.\n"); 
         }
      } else {
         my $nodename = $self->_currentNodeName();
         $self->_printWarning("Warning: CDATA encountered for $nodename:[$string]. Ignoring.\n"); 
      }
   }

}

# execute the appropriate start handler
sub _exec_default_Start_Handler {
   my ($self, $element, $attrib_hash_ref) = @_;

   if ( exists $self->{defaultHandler}->{'start'}) {
      $self->{defaultHandler}->{'start'}->($self, $element, $attrib_hash_ref);
   }
   else
   {
      die "ERROR: default start handler NOT defined. Cannot continue parsing\n";
   }
}

# execute the appropriate end handler
sub _exec_default_End_Handler {
   my ($self, $element) = @_;

   if ( exists $self->{defaultHandler}->{'end'}) {
      $self->{defaultHandler}->{'end'}->($self, $element);
   }
   else
   {
      die "ERROR: default end handler NOT defined. Cannot continue parsing\n";
   }
}

# execute the appropriate Cdata handler
sub _exec_default_CData_Handler {
   my ($self, $string) = @_;

   if ( exists $self->{defaultHandler}->{'cdata'}) {
      $self->{defaultHandler}->{'cdata'}->($self, $string);
   }
   else
   {
      die "ERROR: default char data handler NOT defined. Cannot continue parsing\n";
   }
}

# only deals with files right now. Bleah.
# we need some form of entityResolving in Perl to do this right.
sub _getHrefData {
   my ($self, $href) = @_;

   my $file;
   my $text; 

   if (defined $href->getSysId) {
       $file = $href->getBase() if $href->getBase();
       $file .= $href->getSysId();

   my $openstatement = $file;
   my $compression_prog = $self->_getCurrentDataDeCompression;

   if (defined $compression_prog) {
       $openstatement = " $compression_prog $openstatement|";
   }

       undef $/; #input rec separator, once newline, now nothing.
                 # will cause whole file to be read in one whack 
       #my $can_open = open(DATAFILE, $file);
       my $can_open = open(DATAFILE, $openstatement);
       if (!$can_open) {
          print STDERR "Cant open $file, aborting read of this data file.\n";
          return "";
       }
       # binmode(DATAFILE); # needed ?
       $text = <DATAFILE>;
       close DATAFILE;

   } else {
      die "XDF::Reader can't read Href data, SYSID is not defined!\n";
   }
   return $text;
} 


# this code copied almost verbatim from the original Java
sub _appendArrayToArray {
   my ($arrayToAppendTo, $arrayToAdd) = @_;

   &_printDebug("appendArrayToArray\n");
   if (defined $arrayToAppendTo)
   {

      my @origAxisList = @{$arrayToAppendTo->getAxisList};
      my @addAxisList = @{$arrayToAdd->getAxisList};
      my %correspondingAddAxis;
      my %correspondingOrigAxis;

      &_printDebug("Getting array alignments \n");
      # 1. determine the proper alignment of the axes between both arrays
      #    Then cross-reference each in lookup Hashtables.
      foreach my $origAxis (@origAxisList)
      {

         #AxisInterface origAxis = (AxisInterface) iter.next();
         my $align = $origAxis->getAlign();

         # search the list of the other array for a matching axis 
         my $gotAMatch = 0;
             #Iterator iter2 = addAxisList.iterator();
         foreach my $addAxis (@addAxisList)
         {

            #AxisInterface addAxis = (AxisInterface) iter2.next();
            my $thisAlign = $addAxis->getAlign();
            if(defined $thisAlign)
            {
               if($thisAlign eq $align)
               {
                   $correspondingAddAxis{$origAxis->getAxisId()} = $addAxis;
                   $correspondingOrigAxis{$addAxis->getAxisId()} = $origAxis;
                   $gotAMatch = 1;
                   last;
                }
             } else {
                warn "Cant align axes, axis missing defined align attribute. Aborting.\n";
                #return $arrayToAppendTo;
             }
          }

          # no match?? then alignments are mis-specified.
          if (!$gotAMatch) {
              warn "Cant align axes, axis has align attribute that is mis-specified. Aborting.\n";
              #return $arrayToAppendTo;
          }

      }

      &_printDebug("Appending axisvalues to array axis\n");
      # 2. "Append" axis values to original axis. Because
      # there are 2 different ways to add in data we either
      # have a pre-existing axis value, in which case we dont
      # need to expand the existing axis, or there is no pre-existing
      # value so we tack it in. We need to figure out here if an
      # axis value already exists, and if it doesnt then we add it in. 
      foreach my $origAxis (@origAxisList)
      {

         #   AxisInterface origAxis = (AxisInterface) iter3.next();
         my $addAxis = $correspondingAddAxis{$origAxis->getAxisId};

         if (ref($addAxis) eq 'XDF::Axis' && ref($origAxis) eq 'XDF::Axis')
         {
            my @valuesToAdd = $addAxis->getAxisValues();
            foreach my $value (@valuesToAdd) {
               if (( $origAxis->getIndexFromAxisValue($value)) == -1) 
               {
                  $origAxis->addAxisValue($value);
               }
            }

         } elsif (ref($addAxis) eq 'XDF::FieldAxis' && ref($origAxis) eq 'XDF::FieldAxis') {

            # both are fieldAxis
            die "Dont know how to merge field Axis data. Aborting array appendTo operation.";

         } else {
            # mixed class Axes?!? (e.g. a fieldAxis id matches Axis id??!? Error!!)
            die "Dont know how to merge this data. Aborting array appendTo operation.";
         }

      }

      # 3. Append data from one array to the other appropriately 
      my $origLocator = $arrayToAppendTo->createLocator();
      my $addLocator = $arrayToAdd->createLocator();

      while ($addLocator->hasNext())
      {

         #try {

         #retrieve the data
         my $data = $arrayToAdd->getData($addLocator);

         # set up the origLocator
         my @locatorAxisList = @{$addLocator->getIterationOrder()};
         #Iterator iter5 = locatorAxisList.iterator();
         &_printDebug("Appending data to array($arrayToAppendTo)(");
         foreach my $addAxis (@locatorAxisList) {

            #Axis addAxis = (Axis) iter5.next();
            my $thisAxisValue = $addLocator->getAxisValue($addAxis);
            my $thisAxis = $correspondingOrigAxis{$addAxis->getAxisId()};

            #try {
               $origLocator->setAxisIndexByAxisValue($thisAxis, $thisAxisValue);
               &_printDebug($origLocator->getAxisIndex($thisAxis).",");

             #} catch (AxisLocationOutOfBoundsException e) {
                #       Log.errorln("Weird axis out of bounds error for append array.");
             #}
         }

         # add in the data as appropriate.
         &_printDebug(") => [$data]\n");

         #try {

         $arrayToAppendTo->setData($origLocator, $data);

         # // orig Java block
         #   if (data instanceof Double)
         #      arrayToAppendTo.setData(origLocator, (Double) data);
         #          else if (data instanceof Integer)
         #              arrayToAppendTo.setData(origLocator, (Integer) data);
         #          else if (data instanceof String )
         #              arrayToAppendTo.setData(origLocator, (String) data);
         #          else
         #              Log.errorln("Cant understand class of data !(Double|Integer|String). ignoring append");
         #
         # } catch (SetDataException e) {
         #    Log.errorln("Cant setData. Ignoring append");
         # }

         #} catch (NoDataException e) {
         #       // do nothing for NoDataValues??
         #    }

         $addLocator->next(); # go to next location
      }

   } else {
      warn "Cannot append to null array. Ignoring request.";
   }

  # return $arrayToAppendTo;
}


# /** ADDITIONAL SECTION Reader Options
# The following options are currently supported:
#@   
#@ 
#@ 'validate'   => Set the reader to use a validating parser (XML::Parser::Checker). 
#@                 Defaults to 0 ('no'). 
#@   
#@ 'msgThresh'  => Set the reader parser message threshold. Messages BELOW this 
#@                 number will be displayed. Has no effect unless XML::Parser::Checker
#@                 is the parser. Defaults to 200. 
#@   
#@ 'noExpand'   => Don't expand entities in output if true. Default is false. 
#@
#@ 'nameSpaces' => When this option is given with a true value, then the parser does namespace
#@                 processing. By default, namespace processing is turned off.
#@
#@ 'parseParamEnt' => Unless standalone is set to "yes" in the XML declaration, setting this to
#@                    a true value allows the external DTD to be read, and parameter entities
#@                    to be parsed and expanded. The default is false. 
#@
#@ 'quiet'      => Set the reader to run quietly. Defaults to 1 ('yes'). 
#@ 
#@ 'axisSize'   => Set the number of indices to allocate along each dimension. This
#@                 can speed up large file reads. Defaults to $XDF::BaseObject::DefaultDataArraySize. 
#@ 
#@ 'maxWarning" => Change the maximum allowed number of warnings before the XDF::Reader
#@                 will halt its parse of the input file/fileHandle. 
#@ 
# */

# Modification History
#
# $Log$
# Revision 1.29  2001/06/21 15:44:48  thomas
# commented out addData dbug statement
# in vain attempt to improve read performance.
#
# Revision 1.28  2001/06/19 21:21:39  thomas
# added reading of compressed files.
#
# Revision 1.27  2001/05/29 21:09:58  thomas
# small fix in _init for optionshashref.
#
# Revision 1.26  2001/04/17 19:01:26  thomas
# Using Specification class now. Made
# changes to accomodate new XMLElement class.
#
# Revision 1.25  2001/04/10 22:08:33  thomas
# removed handle_attlist for time being; put unparsed enties
# into the entity list, and default handler no longer sends
# stuff the to the chardata handler (it does noting right now).
#
# Revision 1.24  2001/03/26 18:17:38  thomas
# added some internal documentation.
#
# Revision 1.23  2001/03/23 20:39:27  thomas
# Added parseString method.
#
# Revision 1.22  2001/03/21 20:41:35  thomas
# minor bug fix: misspelled 'fieldAxis' at line 2540 or so.
# removed commented out _deal_with_options.
# removed minor debuging lines.
#
# Revision 1.21  2001/03/21 20:20:23  thomas
# Fixed all start Handlers so that they return the object they create.
# Added _lastObj method.
# Added code for treatment of adding XMLElements to the XDF structure.
#
# Revision 1.20  2001/03/16 22:48:02  thomas
# fixes to valueListGroup.
#
# Revision 1.19  2001/03/16 19:51:24  thomas
# Fully converted to object oriented. Improved
# documentation too.
#
# Revision 1.18  2001/03/15 22:23:32  thomas
# Interim class while I change reader over to a real object class.
# For the time being it works for static class call, but object hooks
# not yet implemented.
#
# Revision 1.17  2001/03/14 21:32:35  thomas
# Updated perldoc section using new version of
# makeDoc.pl.
#
# Revision 1.16  2001/03/14 17:13:25  thomas
# Wherent updating the global ID/IDFEF object
# tables properly, as a result not generating
# unique Id's properly after the first cloned object.
# Now fixed.
#
# Revision 1.15  2001/03/14 16:44:12  thomas
# Fixes to the ReadId/IdRef problem (but some issues remain).
# Added AppendArrayToArray method (for appentTo functionality).
# This also required adding array_node_end handler. Minor changes
# based on other method call changes within the API. Moved some
# debuging messages over from "print STDERR" to appropriate
# '_printDebug' and added '_printError' method.
#
# Revision 1.14  2001/03/12 17:28:30  thomas
# Added ReadId/IdRef code. Will break in cases where
# readIdRef AND child for node exists on the read node.
#
# Revision 1.13  2001/03/09 21:58:23  thomas
# Moved $Flag_Decimal, Flag_Octal, etc to use the Constants class. Changed code
# so that binary reads now conform to the XDF standard (non-native floating point
# reading now supported)
#
# Revision 1.12  2001/03/01 21:12:24  thomas
# small fix: reversed readAxisOrder. This solved a bug in the
# locator having to (un)reverse the order back. -b.t.
#
# Revision 1.11  2001/02/22 19:39:42  thomas
# changed locator getAxisLocation call to new name getAxisIndex
#
# Revision 1.10  2001/02/15 18:30:12  thomas
# Added FloatDataFormat. Removed ExponentialDataFormat and FixedDataFormat
# from handler. Changed getBytes method call to numOfBytes.
#
# Revision 1.9  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.8  2000/12/14 22:11:26  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.7  2000/12/05 16:31:13  thomas
# Changed default behavior of XML Parser. parseParamEnt and
# Namespace may be options passed to the parser via the
# options hash. -b.t.
#
# Revision 1.6  2000/12/01 20:03:38  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.5  2000/11/28 21:54:29  thomas
# Changed ExponentDataFormat name to ExponentialDataFormat.
# Reflected change in the reader. -b.t.
#
# Revision 1.4  2000/11/28 19:43:26  thomas
# No change, just formatting of lines. -b.t.
#
# Revision 1.3  2000/11/01 22:25:28  thomas
# Minor cleanup of code. (where??) -b.t.
#
# Revision 1.2  2000/10/16 17:37:21  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::Reader - Perl Class for Reader

=head1 SYNOPSIS


    my $DEBUG = 1;

    # test file for reading in XDF files.

    my $file = $ARGV[0];
    my %options = ('quiet' => $DEBUG, 'validate' => 0);

    my $XDFReader = new XDF::Reader(\%options);
    my $XDFObject = $XDFReader->parseFile($file);



...

=head1 DESCRIPTION

 This class allows the user to create XDF objects from XDF files.  XDF::Reader will read in both Binary and ASCII data and tagged/delimited/ and formatted XDF data styles are supported. 



=head1 METHODS

=over 4

=head2 CLASS Methods

The following methods are defined for the class XDF::Reader.

=over 4

=item getVersion (EMPTY)

returns the version of the XDF DTD supported by this parser.  

=item new ($optionsHashRef)

Create a new reader object. Returns the reader object if successfull. It takes an optional argument of an option HASH Reference  to initialize the object options.   

=back

=head2 INSTANCE (Object) Methods

The following instance (object) methods are defined for XDF::Reader.

=over 4

=item getReaderStructureObject (EMPTY)

 

=item setReaderStructureObject ($structure)

sets the structure that the reader parses into.  

=item parseFile ($file, $optionsHashRef)

Reads in the given file and returns a full XDF Perl object (an L<XDF::Structure>with at least one L<XDF::Array>). A second HASH argument may be supplied to specify runtime options for the XDF::Reader.  

=item parseFileHandle ($handle, $optionsHashRef)

Similar to parseFile but takes an open filehandle as an argument (so you can parse ANY open fileHandle, e.g. files, sockets, etc. Whatever Perl supports.).  

=item parseString ($string, $optionsHashRef)

Reads in the given string and returns a full XDF Perl object (an L<XDF::Structure>with at least one L<XDF::Array>). A second HASH argument may be supplied to specify runtime options for the XDF::Reader.  

=item addStartElementHandlers (%newHandlers)

Add new handlers to the internal XDF::Parser start element handler. The form of  the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; If a 'nodename' for a handler already exists in the XDF start handler table,  this method will override it with the new handler.  

=item addEndElementHandlers (%newHandlers)

Add new handlers to the internal XDF::Parser end element handler. The form of  the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; If a 'nodename' for a handler already exists in the XDF end handler table,  this method will override it with the new handler.  

=item addCharDataHandlers (%newHandlers)

Add new handlers to the internal XDF::Parser CDATA element handler. The form of  the entries in the passed hash should be 'nodename' => sub { &handler_for_nodename(@_); }; If a 'nodename' for a handler already exists in the XDF CDATA handler table,  this method will override it with the new handler.  

=item setDefaultStartElementHandler ($codeRef)

This sets the subroutine which will handle all nodes which DONT match  an entry within the start element handler table.  

=item setDefaultEndElementHandler ($codeRef)

This sets the subroutine which will handle all nodes which DONT match  an entry within the end element handler table.  

=item setDefaultCharDataHandler ($codeRef)

This sets the subroutine which will handle all nodes which DONT match  an entry within the CDATA handler table.  

=back



=head2 INHERITED Class Methods

=over 4

=back



=head2 INHERITED INSTANCE Methods

=over 4

=back

=back

=head1 Reader Options 



=over 4

 The following options are currently supported:    
  
  'validate'   => Set the reader to use a validating parser (XML::Parser::Checker). 
                  Defaults to 0 ('no'). 
    
  'msgThresh'  => Set the reader parser message threshold. Messages BELOW this 
                  number will be displayed. Has no effect unless XML::Parser::Checker
                  is the parser. Defaults to 200. 
    
  'noExpand'   => Don't expand entities in output if true. Default is false. 
 
  'nameSpaces' => When this option is given with a true value, then the parser does namespace
                  processing. By default, namespace processing is turned off.
 
  'parseParamEnt' => Unless standalone is set to "yes" in the XML declaration, setting this to
                     a true value allows the external DTD to be read, and parameter entities
                     to be parsed and expanded. The default is false. 
 
  'quiet'      => Set the reader to run quietly. Defaults to 1 ('yes'). 
  
  'axisSize'   => Set the number of indices to allocate along each dimension. This
                  can speed up large file reads. Defaults to $XDF::BaseObject::DefaultDataArraySize. 
  
  'maxWarning" => Change the maximum allowed number of warnings before the XDF::Reader
                  will halt its parse of the input file/fileHandle. 
  


=back

=head1 SEE ALSO



=over 4

L<XDF::Array>, L<XDF::BinaryFloatDataFormat>, L<XDF::BinaryIntegerDataFormat>, L<XDF::Constants>, L<XDF::DelimitedXMLDataIOStyle>, L<XDF::Field>, L<XDF::FieldRelation>, L<XDF::FloatDataFormat>, L<XDF::FormattedXMLDataIOStyle>, L<XDF::Href>, L<XDF::IntegerDataFormat>, L<XDF::Parameter>, L<XDF::RepeatFormattedIOCmd>, L<XDF::ReadCellFormattedIOCmd>, L<XDF::SkipCharFormattedIOCmd>, L<XDF::StringDataFormat>, L<XDF::Structure>, L<XDF::XMLDataIOStyle>, L<XDF::XMLElement>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center
 

=cut


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
# This module (XDF::Reader is not currently an object) allows the user to create 
# XDF objects from XDF files.  Currently XDF::Reader will only read in ASCII data. 
# Both tagged/untagged(formated/delimited) XDF data styles are supported.
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
#
#    my $DEBUG = 0;
#    my $QUIET = 1;
#
#    # test file for reading in XDF files.
#
#    my $file = $ARGV[0];
#    my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );
#
#    my $XDF = &XDF::Reader::createXDFObjectFromFile($file, \%options);
#
# */

use XDF::Array;
use XDF::BinaryFloatDataFormat;
use XDF::BinaryIntegerDataFormat;
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

use vars qw ($VERSION);

# look for the checker, if its installed use it
# otherwise, fall back to the (regular) non-validating
# version of the parser
BEGIN {
  unless (eval "use XML::Checker::Parser" ) {
     use XML::Parser;
  }
} 

# the version of this module, what version of XDF
# it will read in.
$VERSION = "0.17";

use strict;
use integer;

my $XDF; # reference to the top level structure object
         # and is the only thing passed back from the reader 

# GLOBAL VARIABLES: Information about the current array
# that the reader needs to keep track of
# Probably we can do a bit better than to have all of these.
# A good way to go is to have a "LAST_OBJECT_CREATED" global
# that we can plug stuff into. One exception is we DO need to
# keep track of the CURRENT STRUCTURE/CURRENT ARRAY STUFF.
my $CURRENT_STRUCTURE;
my $CURRENT_ARRAY;
my $LAST_NOTE_OBJECT;
my $LAST_NOTES_PARENT_OBJ;
my $LAST_UNIT_OBJECT;
my $LAST_UNITS_OBJECT;
my $LAST_PARAM_OBJECT;
my $CURRENT_DATATYPE_OBJECT;
my @CURRENT_FORMAT_OBJECT = (); # used for untagged reads only
my @CURRENT_FIELDGROUP_OBJECT = (); 
my @CURRENT_PARAMGROUP_OBJECT = (); 
my @CURRENT_VALUEGROUP_OBJECT = (); 
my %CURRENT_ARRAY_AXES; # = {};
my $LAST_PARAMGROUP_PARENT_OBJECT;
my $LAST_VALUEGROUP_PARENT_OBJECT;

my $TAGGED_LOCATOR_OBJ; 
my @READAXISORDER = ();

my $DataIOStyle_Attrib_Ref; # used for holding on to the attrib_hash of a 'read' node
                            # for later when we know what kind of DataIOStyle obj to use
my $Data_Format_Attrib_Ref;


# needed to capture internal entities.
my %Notation;
my %Entity;
my %UnParsedEntity;

# needed to allow many supporting subroutines (like parent_node_name) 
# to work. Indicates our current position within the Document as we are
# parsing it. 
my @CURRENT_NODE_PATH = ();

my $NROF_WARNING = 0; # a counter that is compared to $MAX_WARNINGS to see if we halt 

# global (switch) variables 
my $CDATA_IS_ARRAY_DATA; # Tells us when we are accepting char_data as data 
my $DATA_NODE_LEVEL = 0;     # how nested we are within a set of datanodes. 
my $CURRENT_DATA_TAG_LEVEL = 0; # how nested we are within d0/d1/d2 data tags
my $DATA_TAG_LEVEL = 0;         # the level where the actual char data is

# this is a BAD thing. I have been having troubles distinguishing between
# important whitespace (e.g. char data within a data node) and text nodes
# that are purely for the layout of the XML document. Right now I use the 
# CRUDE distinquishing characteristic that fluff (eg. only there for the sake
# of formatting the output doc) text nodes are all whitespace.
# Used by TAGGED data arrays
my $IGNORE_WHITESPACE_ONLY_DATA = 1;

# other globals...

my $DATABLOCK; # collects/holds the cdata for eventual untagged read 

# next thing is needed for tagged reads only 
my %TAG_COUNT;  # (tagged read only) stores the number count of each 
                # tag read in 

# allows us to store the ordering of the axisIDRef's in 
# the notes locationOrder tag (so we can cross link it)
my @NOTE_LOCATOR_ORDER;

# need this in order to properly simulate action of valueList node
my %CURRENT_VALUELIST = ( 'parent_node' => "",
                          'delimiter' => "",
                        );

# GLobal hashes to keep track of various
# ID's (so we can use IDREF mech to reference objects)
my %AxisObj;
my %FieldObj;
my %FormatObj;
my %NoteObj;

# options for running the parser
my $MAX_WARNINGS = 10; # how many warnings we can have before termination. 
                       # Set to 0 for unlimited warnings 
my $DEBUG = 0; # for printing out debug information 
my $QUIET = 1; # if enabled it suppresses warnings 
my $DEF_ARRAY_AXIS_SIZE; # if defined, it will set this at start before loading.
my $USE_VALIDATING_PARSER; # if true, it will use the XML::Parser::Checker 
my $PARSER_MSG_THRESHOLD = 200; # we print all messages equal to and below this threshold
  
# GLOBAL CONSTANTS. 

#my $Tagged_Read_Style  = &XDF::XMLDataIOStyle::taggedXMLDataIOStyleName();
#my $UnTagged_Read_Style  = &XDF::XMLDataIOStyle::untaggedXMLDataIOStyleName();

my $Flag_Hex = &XDF::IntegerDataFormat::typeHexadecimal();
my $Flag_Decimal = &XDF::IntegerDataFormat::typeDecimal();
my $Flag_Octal = &XDF::IntegerDataFormat::typeOctal();

# Now, Some defines based on XDF DTD 
# change these to reflect new namings of same nodes as they occur.
                      #'exponent' => 'exponential',
my %XDF_node_name = ( 
                      'textDelimiter' => 'textDelimiter',
                      'array' => 'array',
                      'axis' => 'axis',
                      'axisUnits' => 'axisUnits',
                      'binaryFloat' => 'binaryFloat',
                      'binaryInteger' => 'binaryInteger',
                      'data' => 'data',
                      'dataFormat' => 'dataFormat',
                      'field' => 'field',
                      'fieldAxis' => 'fieldAxis',
                      'float' => 'float',
                      'for' => 'for',
                      'fieldGroup' => 'fieldGroup',
                      'index' => 'index',
                      'integer' => 'integer',
                      'locationOrder' => 'locationOrder',
                      'note' => 'note',
                      'notes' => 'notes',
                      'parameter' => 'parameter',
                      'parameterGroup' => 'parameterGroup',
                      'root' => 'XDF',   # beware setting this to the same name as structure 
                      'read' => 'read',
                      'readCell' => 'readCell',
                      'repeat' => 'repeat',
                      'relationship' => 'relation',
                      'skipChar' => 'skipChars',
                      'structure' => 'structure',
                      'string' => 'string',
                      'tagToAxis' => 'tagToAxis',
                      'td0' => 'd0',
                      'td1' => 'd1',
                      'td2' => 'd2',
                      'td3' => 'd3',
                      'td4' => 'd4',
                      'td5' => 'd5',
                      'td6' => 'd6',
                      'td7' => 'd7',
                      'td8' => 'd8',
                      'unit' => 'unit',
                      'units' => 'units',
                      'unitless' => 'unitless',
                      'valueList' => 'valueList',
                      'value' => 'value',
                      'valueGroup' => 'valueGroup',
                      'vector' => 'unitDirection',
                    );

# dispatch table for the start node handler of the parser
                     #  $XDF_node_name{'exponent'}     => sub { &exponentField_node_start(@_); },
my %Start_Handler = (
                       $XDF_node_name{'array'}        => sub { &array_node_start(@_); },
                       $XDF_node_name{'axis'}         => sub { &axis_node_start(@_); },
                       $XDF_node_name{'axisUnits'}    => sub { &axisUnits_node_start(@_); },
                       $XDF_node_name{'binaryFloat'}  => sub { &binaryFloatField_node_start(@_); },
                       $XDF_node_name{'binaryInteger'} => sub { &binaryIntegerField_node_start(@_); },
                       $XDF_node_name{'data'}         => sub { &data_node_start(@_); },
                       $XDF_node_name{'dataFormat'}   => sub { &dataFormat_node_start(@_); },
                       $XDF_node_name{'field'}        => sub { &field_node_start(@_); },
                       $XDF_node_name{'fieldAxis'}    => sub { &fieldAxis_node_start(@_); },
                       $XDF_node_name{'float'}        => sub { &floatField_node_start(@_); },
                       $XDF_node_name{'for'}          => sub { &for_node_start(@_); },
                       $XDF_node_name{'fieldGroup'}   => sub { &fieldGroup_node_start(@_); },
                       $XDF_node_name{'index'}        => sub { &note_index_node_start(@_); },
                       $XDF_node_name{'integer'}      => sub { &integerField_node_start(@_); },
                       $XDF_node_name{'locationOrder'}=> sub { &null_cmd(@_); },
                       $XDF_node_name{'note'}         => sub { &note_node_start(@_); },
                       $XDF_node_name{'notes'}        => sub { &notes_node_start(@_); },
                       $XDF_node_name{'parameter'}    => sub { &parameter_node_start(@_); },
                       $XDF_node_name{'parameterGroup'} => sub { &parameterGroup_node_start(@_); },
                       $XDF_node_name{'read'}         => sub { &read_node_start(@_);},
                       $XDF_node_name{'readCell'}     => sub { &readCell_node_start(@_);},
                       $XDF_node_name{'repeat'}       => sub { &repeat_node_start(@_); },
                       $XDF_node_name{'relationship'} => sub { &field_relationship_node_start(@_); },
                       $XDF_node_name{'root'}         => sub { &root_node_start(@_); },
                       $XDF_node_name{'skipChar'}     => sub { &skipChar_node_start(@_); },
                       $XDF_node_name{'string'}       => sub { &stringField_node_start(@_); },
                       $XDF_node_name{'structure'}    => sub { &structure_node_start(@_); },
                       $XDF_node_name{'tagToAxis'}    => sub { &tagToAxis_node_start(@_);},
                       $XDF_node_name{'td0'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td1'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td2'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td3'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td4'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td5'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td6'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td7'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'td8'}          => sub { &dataTag_node_start(@_);},
                       $XDF_node_name{'textDelimiter'}=> sub { &asciiDelimiter_node_start(@_); },
                       $XDF_node_name{'unit'}         => sub { &unit_node_start(@_); },
                       $XDF_node_name{'units'}        => sub { &units_node_start(@_); },
                       $XDF_node_name{'unitless'}     => sub { &unitless_node_start(@_); },
                       $XDF_node_name{'value'}        => sub { &null_cmd(@_); },
                       $XDF_node_name{'valueGroup'}   => sub { &valueGroup_node_start(@_); },
                       $XDF_node_name{'valueList'}    => sub { &valueList_node_start(@_); },
                       $XDF_node_name{'vector'}       => sub { &vector_node_start(@_); } ,
                    );


# dispatch table for the chardata handler of the parser
my %CharData_Handler = (

                          $XDF_node_name{'note'}=> sub { &note_node_charData(@_); },
                          $XDF_node_name{'unit'}=> sub { &unit_node_charData(@_); },
                          $XDF_node_name{'valueList'}=> sub { &valueList_node_charData(@_); },
                          $XDF_node_name{'value'}=> sub { &value_node_charData(@_); },
                    );

# dispatch table for the end node handler of the parser
my %End_Handler = (
                       $XDF_node_name{'data'}         => sub { &data_node_end(); },
                       $XDF_node_name{'fieldGroup'}   => sub { &fieldGroup_node_end(@_); },
                       $XDF_node_name{'notes'}        => sub { &notes_node_end(); },
                       $XDF_node_name{'parameterGroup'} => sub { &parameterGroup_node_end(@_); },
                       $XDF_node_name{'read'}         => sub { &read_node_end(); },
                       $XDF_node_name{'repeat'}       => sub { &repeat_node_end(@_); },
                       $XDF_node_name{'td0'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td1'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td2'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td3'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td4'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td5'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td6'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td7'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'td8'}          => sub { &dataTag_node_end(@_);},
                       $XDF_node_name{'valueGroup'}   => sub { &valueGroup_node_end(@_); },
                  );

# Finally, some globals to help us do Valuelist nodes 
my $Def_ValueList_Step = 1;
my $Def_ValueList_Start = 1;
my $Def_ValueList_Repeatable = 0;
my $Def_ValueList_Delimiter = " ";



# M E T H O D S 


# PUBLIC Methods

# /** createXDFObjectFromFile
# Reads in the given file and returns a full XDF Perl object (an L<XDF::Structure>
#  with at least one L<XDF::Array>). A second HASH argument may be supplied to 
# specify runtime options for the XDF::Reader.
# */
sub createXDFObjectFromFile {
  my ($file, $optionsHashRef) = @_;

  open (FILE, $file) or die "$0 cant open $file\n";
  my $RetObject = &createXDFObjectFromFileHandle(\*FILE, $optionsHashRef);
  close FILE;

  return $RetObject;
}

# /** createXDFObjectFromFileHandle
# Similar to createXDFObjectFromFile but takes an open filehandle as an 
# argument (so you can parse ANY open fileHandle, e.g. files, sockets, etc.
# Whatever Perl supports.).
# */
sub createXDFObjectFromFileHandle {
  my ($handle, $optionsHashRef) = @_; 

  &deal_with_options($optionsHashRef) if defined $optionsHashRef;

  if ($USE_VALIDATING_PARSER && ! eval { new XML::Checker::Parser } ) {
    warn "Validating parser module (XML::Checker::Parser) not available on this system, using default non-validating parser XML::Parser.\n";
    $USE_VALIDATING_PARSER = 0;
  }

  if ($USE_VALIDATING_PARSER) {

    my $parser = &create_validating_parser($optionsHashRef);

    eval {
       local $XML::Checker::FAIL = \&my_fail;
       $parser->parse($handle);
    };

    # Either XML::Parser (expat) threw an exception or my_fail() died.
    if ($@) {
       my ($msg, $loc) = split "\n", $@;
       print "MSG: $msg\n"; # the error message 
       print "$loc\n"; # print location 
    }

  } else {

    my $parser = &create_parser($optionsHashRef);
    $parser->parse($handle);
  }

  return $XDF;
}

# PRIVATE methods (all others) 

# /** PRIVATE METHODS */

sub create_parser {
  my ($optionsHashRef) = @_;
 
  my $nameSpaces = 0;
  my $parseParamEnt = 0;
  my $noExpand = 0;

  if (defined $optionsHashRef) {
    my %option = %{$optionsHashRef};
    $noExpand = $option{'noExpand'} if exists $option{'noExpand'}; 
    $nameSpaces = $option{'namespaces'} if exists $option{'namespaces'}; 
    $parseParamEnt = $option{'parseParamEnt'} if exists $option{'parseParamEnt'}; 
  }
  
   my $parser = new XML::Parser(  
                                ParseParamEnt => $parseParamEnt,
                                NoExpand => $noExpand,
                                Namespaces => $nameSpaces,
                                Handlers => { 
                                     Start => \&handle_start,
                                     End   => \&handle_end,
                                     Init => \&handle_init, 
                                     Final => \&handle_final,
                                     Char  => \&handle_char,
                                     Proc => \&handle_proc, 
                                     Comment => \&handle_comment, 
                                     CdataStart => \&handle_cdata_start,
                                     CdataEnd => \&handle_cdata_end,
                                     ExternEnt => \&handle_external_ent,
                                     Entity => \&handle_entity,
                                     Element => \&handle_element,
                                     Attlist => \&handle_attlist,
                                     XMLDecl => \&handle_xml_decl,
                                     Notation => \&handle_notation,
                                     Unparsed => \&handle_unparsed,
                                     Doctype => \&handle_doctype,
                                     Default => \&handle_default,
                                            }
                              );

}

sub create_validating_parser {
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
                                     Start => \&handle_start,
                                     End   => \&handle_end,
                                     Init => \&handle_init, 
                                     Final => \&handle_final,
                                     Char  => \&handle_char,
                                     Proc => \&handle_proc, 
                                     Comment => \&handle_comment, 
                                     CdataStart => \&handle_cdata_start,
                                     CdataEnd => \&handle_cdata_end,
                                     ExternEnt => \&handle_external_ent,
                                     Entity => \&handle_entity,
                                     Element => \&handle_element,
                                     Attlist => \&handle_attlist,
                                     XMLDecl => \&handle_xml_decl,
                                     Notation => \&handle_notation,
                                     Unparsed => \&handle_unparsed,
                                     Doctype => \&handle_doctype,
                                     Default => \&handle_default,
                                            }
                              );

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
#@ 'debug'      => Set the reader to run with debugging messages. Defaults to 0 ('no'). 
#@ 
#@ 'axisSize'   => Set the number of indices to allocate along each dimension. This
#@                 can speed up large file reads. Defaults to $XDF::BaseObject::DefaultDataArraySize. 
#@ 
#@ 'maxWarning" => Change the maximum allowed number of warnings before the XDF::Reader
#@                 will halt its parse of the input file/fileHandle. 
#@ 
# */

sub deal_with_options {
  my ($options_ref) = @_;

  while (my ($option, $value) = each (%{$options_ref})) {
     if($option eq 'quiet') {
        $QUIET = $value;
     } elsif($option eq 'debug') {
        $DEBUG = $value;
     } elsif($option eq 'axisSize') {
        $DEF_ARRAY_AXIS_SIZE = $value;
     } elsif($option eq 'validate') {
         $USE_VALIDATING_PARSER = $value;
     } elsif($option eq 'msgThresh') {
       $PARSER_MSG_THRESHOLD = $value;
     } elsif($option eq 'maxWarning') {
       $MAX_WARNINGS = $value;
     } elsif( $option eq 'noExpand'
             or $option eq 'parseParamEnt'
             or $option eq 'namespaces'
            ) 
     {
       # do nothing here. The parser will use these
     } else {
        print STDERR "Unknown option: $option, Ignoring\n" unless $QUIET;
     }
  }

}


# first things first, the document handler methods
sub handle_doctype {
   #my ($parser_ref,  $name, $sysid, $pubid, $internal) = @_;
   my ($parser_ref,  @stuff) = @_;
   &print_debug("H_DOCTYPE: ");
   foreach my $thing (@stuff) { &print_debug($thing.", ") if defined $thing; }
   &print_debug("\n");
}

sub handle_xml_decl {
   #my ($parser_ref, $version, $encoding, $standalone ) = @_; 
   my ($parser_ref,  @stuff) = @_;
   &print_debug("H_XML_DECL: ");
   foreach my $thing (@stuff) { &print_debug($thing.", ") if defined $thing; }
   &print_debug("\n");
}

sub handle_unparsed {
  my ($parser_ref, $entity, $base, $sysid, $pubid, $notation) = @_;

   my $msgstring = "H_UNPARSED: $entity";
   $UnParsedEntity{$entity} = {}; # add a new entry;

   if (defined $base) {
      $msgstring .= ", Base:$base";
      ${$UnParsedEntity{$entity}}{'base'} = $base;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$UnParsedEntity{$entity}}{'sysid'} = $sysid;
   }

   if (defined $pubid) {
      $msgstring .= " PUB:$pubid";
      ${$UnParsedEntity{$entity}}{'pubid'} = $pubid;
   }

   if (defined $notation) {
      $msgstring .= " NOTATION:$notation";
      ${$UnParsedEntity{$entity}}{'notation'} = $notation;
   }

   $msgstring .= "\n";
   &print_debug($msgstring);

}

sub handle_notation {
  my ($parser_ref, $notation, $base, $sysid, $pubid) = @_;

   my $msgstring = "H_NOTATION: $notation ";
   $Notation{$notation} = {}; # add a new entry

   if (defined $base) {
      $msgstring .= ", Base:$base";
      ${$Notation{$notation}}{'base'} = $base;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$Notation{$notation}}{'sysid'} = $sysid;
   }

   if (defined $pubid) {
      $msgstring .= " PUB:$pubid";
      ${$Notation{$notation}}{'pubid'} = $pubid;
   }

   $msgstring .= "\n";
   &print_debug($msgstring);

}

sub handle_element {
   my ($parser_ref, $name, $model) = @_; 
   &print_debug("H_ELEMENT: $name [$model]\n"); 
}

sub handle_attlist {
   my ($parser_ref, $elname, $attname, $type, $default, $fixed) = @_; 
   &print_debug("H_ATTLIST: $elname [$attname | $type | $default | $fixed]\n"); 
}

sub handle_start {
   my ($parser_ref, $element, @attribinfo) = @_; 

   &print_debug("H_START: $element \n"); 

   my %attrib_hash = &make_attrib_array_a_hash(@attribinfo);

   # add this node to the current path
   push @CURRENT_NODE_PATH, $element;

   if ( exists $Start_Handler{$element}) {

      # run the appropriate start handler
      $Start_Handler{$element}->(%attrib_hash);

   } 
   else 
   {
      &print_warning ("Warning: UNKNOWN NODE [$element] encountered.\n") unless $QUIET;
   }

}

sub handle_end {
   my ($parser_ref, $element) = @_;

   &print_debug("H_END: $element\n");

   # peel off the last element in the current path
   my $last_element = pop @CURRENT_NODE_PATH;

   die "error last element not $element!! (was: $last_element) \n" 
       unless ($element eq $last_element);

   if (exists $End_Handler{$element} ) {

      $End_Handler{$element}->();

   } else {

     # do nothing

   } 

}

sub handle_char {
   my ($parser_ref, $string) = @_;

   &print_debug("H_CHAR:".join '/', @CURRENT_NODE_PATH ."[$string]\n");

   # we need to know what the current node is in order to 
   # know what to do with this data, however, 
   # early on when reading the DOCTYPE, other nodes we can get 
   # text nodes which are not meaningful to us. Ignore all
   # charcter data until we open the root node.

   my $curr_node = &current_node_name();

   if (defined $curr_node) { 

     if(exists $CharData_Handler{$curr_node} ) {
       
        $CharData_Handler{$curr_node}->($string); 

     } else {

       # perhaps we are reading in data at the moment??

       if ($DATA_NODE_LEVEL > 0) { 

          &data_node_charData($string) 

       } else { 

         # do nothing with other character data

       }

     }

   }

}

# ignore comments
sub handle_comment {
   my ($parser_ref, $data) = @_;
   &print_extreme_debug("H_COMMENT: $data\n");
}

sub handle_final {
   my ($parser_ref) = @_;
   &print_debug("H_FINAL \n");

   # set the entity, notation and unparsed lists for the XDF structure
   $XDF->setXMLNotationHash(\%Notation);
  # $XDF->setXMLInternalEntityHash(\%Entity);
  # $XDF->setXMLUnparsedEntityHash(\%UnParsedEntity);
   # pass the populated structure back to calling routine
   return $XDF;
}

sub handle_init {
   my ($parser_ref) = @_;
   &print_debug("H_INIT \n");
}

sub handle_proc {
   my ($parser_ref, $target, $data) = @_;
   &print_debug("H_PROC: $target [$data] \n");
}

sub handle_cdata_start {
   my ($parser_ref) = @_;
   &print_debug( "H_CDATA_START \n");
   $CDATA_IS_ARRAY_DATA = 1;
}

sub handle_cdata_end {
   my ($parser_ref) = @_;
   &print_debug("H_CDATA_END \n");
   $CDATA_IS_ARRAY_DATA = undef;
}

# things like entity definitions get passed here
sub handle_default {
   my ($parser_ref, $string) = @_;
   &print_debug("H_DEFAULT: $string \n");

   # well, i dont know what else can go here, but for now
   # lets assume its entities in the character data ONLY.
   # So we just pass this off to the handle_character method.
   # (yes, we could specify in the parser decl, but perhaps
   # above assumtion ISNT right, then we will need this ).
   &handle_char($parser_ref, $string);
}
  
sub handle_external_ent {
   my ($parser_ref, $base, $sysid, $pubid) = @_;

   my $entityString = "H_EXTERN_ENT: ";
   $entityString .= ", Base:$base" if defined $base;
   $entityString .= ", SYS:$sysid" if defined $sysid;
   $entityString .= " PUB:$pubid" if defined $pubid;
   $entityString .= "\n";
   &print_debug($entityString);

}

sub handle_entity {
   my ($parser_ref, $name, $val, $sysid, $pubid, $ndata) = @_;

   my $msgstring = "H_ENTITY: $name";
   $Entity{$name} = {}; # add a new entry;

   if (defined $val) {
      $msgstring .= ", VAL:$val";
      ${$Entity{$name}}{'value'} = $val;
   }

   if (defined $sysid) {
      $msgstring .= ", SYS:$sysid";
      ${$Entity{$name}}{'sysid'} = $sysid;
   }
  
   if (defined $pubid) {
      $msgstring .= ", PUB:$pubid";
      ${$Entity{$name}}{'pubid'} = $pubid;
   }

   if (defined $ndata) {
      $msgstring .= " NDATA:$ndata";
      ${$Entity{$name}}{'ndata'} = $ndata;
   }

   $msgstring .= "\n";
   &print_debug($msgstring);

}

# ------------ END XML PARSER HANDLERS -----------

sub asciiDelimiter_node_end { pop @CURRENT_FORMAT_OBJECT; }

sub asciiDelimiter_node_start {
  my (%attrib_hash) = @_;

  # if this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  # set the format object in the current array
  if ( defined $DataIOStyle_Attrib_Ref) {
    $CURRENT_ARRAY->setXMLDataIOStyle(new XDF::DelimitedXMLDataIOStyle($DataIOStyle_Attrib_Ref));
    $CURRENT_ARRAY->getXMLDataIOStyle->setXMLAttributes(\%attrib_hash);
    $DataIOStyle_Attrib_Ref = undef;
    push @CURRENT_FORMAT_OBJECT, $CURRENT_ARRAY->getXMLDataIOStyle();
  }

  push @CURRENT_FORMAT_OBJECT, $CURRENT_ARRAY->getXMLDataIOStyle();

}

sub array_node_start {
  my (%attrib_hash) = @_;

  $CURRENT_ARRAY = $CURRENT_STRUCTURE->addArray(\%attrib_hash);
  $CURRENT_DATATYPE_OBJECT = $CURRENT_ARRAY;
  my %tmpHash;
  %CURRENT_ARRAY_AXES = %tmpHash;

}

sub axis_node_start {
  my (%attrib_hash) = @_;

  my $axisObj = new XDF::Axis(\%attrib_hash);

  # add in reference object, if it exists 
  if (exists($attrib_hash{'axisIdRef'})) {

     my $id = $attrib_hash{'axisIdRef'};

     # clone from the reference object
     $axisObj = $AxisObj{$id}->clone();

     # override with local values
     $axisObj->setXMLAttributes(\%attrib_hash);
     $axisObj->setAxisId(&getUniqueIdName($id, \%AxisObj)); # set ID attribute to unique name 
     $axisObj->setAxisIdRef(undef); # unset IDREF attribute 
     
     # record this axis under its parent id 
     $CURRENT_ARRAY_AXES{$id} = $axisObj;
  }

  # add this object to the lookup table, if it has an ID
  if ((my $axisId = $attrib_hash{'axisId'})) {
     &print_warning( "Danger: More than one axis node with axisId=\"$axisId\", using latest node.\n" )
           if defined $AxisObj{$axisId};
     $AxisObj{$axisId} = $axisObj;
  }

  $axisObj = $CURRENT_ARRAY->addAxis($axisObj);

  $CURRENT_DATATYPE_OBJECT = $axisObj;

}

sub axisUnits_node_start { 
  my (%attrib_hash) = @_; 
  # do nothing
}

sub binaryFloatField_node_start {
  my (%attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$Data_Format_Attrib_Ref}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = &current_dataType_obj();
  
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataTypeObj->setDataFormat(new XDF::BinaryFloatDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string dataformat in $dataTypeObj, ignoring\n";
  
  }

}

sub binaryIntegerField_node_start {
  my (%attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$Data_Format_Attrib_Ref}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = &current_dataType_obj();
  
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataTypeObj->setDataFormat(new XDF::BinaryIntegerDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string data format in $dataTypeObj, ignoring\n";
  
  }

}

sub dataTag_node_start {

  my (%attrib_hash) = @_;
  $CURRENT_DATA_TAG_LEVEL++;

}

sub dataTag_node_end {

  $TAGGED_LOCATOR_OBJ->next() if ($CURRENT_DATA_TAG_LEVEL == $DATA_TAG_LEVEL);
  $CURRENT_DATA_TAG_LEVEL--;

}
  
# what to do when we know this character data IS coming from within
# the data node
sub data_node_charData {
  my ($string) = @_;

  my $readObj = $CURRENT_ARRAY->getXMLDataIOStyle();

  if (ref ($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

    # dont add this data unless it has more than just whitespace
    if (!$IGNORE_WHITESPACE_ONLY_DATA || $string !~ m/^\s*$/) {

       &print_debug("ADDING DATA to ($TAGGED_LOCATOR_OBJ) : [$string]\n");
       $DATA_TAG_LEVEL = $CURRENT_DATA_TAG_LEVEL;
       $CURRENT_ARRAY->addData($TAGGED_LOCATOR_OBJ, $string);
    }

  } elsif (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle' or
           ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' )
  {

    if ($CDATA_IS_ARRAY_DATA) {
       # accumulate CDATA in the GLOBAL $DATABLOCK for later reading
       $DATABLOCK .= $string;
    }

  } else {

     die "UNSUPPORTED data_node_charData style\n";

  }

}

sub data_node_end {

  # we stopped reading datanode, lower count by one
  $DATA_NODE_LEVEL--;

  # we might still be nested within a data node
  # if so, return now to accumulate more data within the DATABLOCK
  return unless $DATA_NODE_LEVEL == 0;

  # now read in untagged data (both delimited/formmatted styles) 
  # from the $DATABLOCK

  # Note: unfortunately we are reduced to using regex style matching
  # instead of a buffer read in formatted reads. Come back and
  # improve this later if possible.

  my $formatObj = $CURRENT_ARRAY->getXMLDataIOStyle();

  if ( ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle' or
       ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle' ) {

    my $regex; my $template; my $recordSize;
    my $data_has_special_integers = 0;

    # set up appropriate instructions for reading
    if ( ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle' ) {
      $template  = $formatObj->_templateNotation(1);
      $recordSize = $formatObj->numOfBytes();
      $data_has_special_integers = $formatObj->hasSpecialIntegers;
    } elsif(ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {
      $regex = $formatObj->_regexNotation();
    }

    my $locator = $CURRENT_ARRAY->createLocator();
    $locator->setIterationOrder(\@READAXISORDER);
    $formatObj->setWriteAxisOrderList(\@READAXISORDER);

    while ( $DATABLOCK ) {

      my @data;

      if ( ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle' ) {

        $DATABLOCK =~ s/(.{$recordSize})//s; 
        die "Read Error: short read on datablock, improper specified format? (expected size=$recordSize)\n" unless $1; 

        @data = unpack($template, $1);

        @data = &deal_with_special_integer_data($CURRENT_ARRAY->getDataFormatList, \@data) 
           if $data_has_special_integers; 

      } elsif(ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {

        $_ = $DATABLOCK; 
        @data = m/$regex/;
        # remove data from data 'resevoir' (yes, there is probably a one-liner
        # for these two statements, but I cant think of it :P
        $DATABLOCK =~ s/$regex//;

      } else {
        die "Unknown Untagged read format: ",ref($formatObj),", exiting.\n";
      }

      # if we got data, fire it into the array
      if ($#data > -1) {

        for (@data) {
          $CURRENT_ARRAY->addData($locator, $_);
if(0) {
my $locationPos;
my $locationName;
for (@{$locator->getIterationOrder()}) {
   $locationName .= $_->getAxisId() . ",";
   $locationPos .= $locator->getAxisLocation($_) . ",";
}
chop $locationName;
print STDERR "ADDING DATA [$locationName]($locationPos) : [$_]\n";
}

          &print_debug("ADDING DATA [$locator]($CURRENT_ARRAY) : [$_]\n");
          $locator->next();
        }

      } else {

        my $line = join ' ', @data; 
        &print_warning( "Unable to get data! Regex:[$regex] failed on Line: [$line]\n");

      }

      last unless $DATABLOCK !~ m/^\s*$/;

    }

  } else {

    # Tagged case: do nothing

  }

}

# we have now read in ALL of the axis that will 
# exist, lets now decipher how to read the tags
sub data_node_start {
  my (%attrib_hash) = @_;

  # we only need to do this for the first time we enter
  if ($DATA_NODE_LEVEL == 0) { 

    # href is special
    if (exists $attrib_hash{'href'}) { 
       my $hrefObj = new XDF::Href(); 
       my $hrefName = $attrib_hash{'href'};
       $hrefObj->setName($hrefName);
       $hrefObj->setSysId(${$Entity{$hrefName}}{'sysid'});
       $hrefObj->setBase(${$Entity{$hrefName}}{'base'});
       $hrefObj->setNdata(${$Entity{$hrefName}}{'ndata'});
       $hrefObj->setPubId(${$Entity{$hrefName}}{'pubid'});
       $CURRENT_ARRAY->getDataCube()->setHref($hrefObj);
       delete $attrib_hash{'href'}; # prevent over-writing object with string 
    }

    # update the array dataCube with XML attributes
    $CURRENT_ARRAY->getDataCube()->setXMLAttributes(\%attrib_hash);

  }

  my $readObj = $CURRENT_ARRAY->getXMLDataIOStyle();

  # these days, this should always be defined.
  if (defined $readObj) {

     if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle') {
       $TAGGED_LOCATOR_OBJ = $CURRENT_ARRAY->createLocator;
     } else {
       # A safety. We clear datablock when this is the first datanode we 
       # have entered DATABLOCK is used in cases where we read in untagged data
       $DATABLOCK = "" if $DATA_NODE_LEVEL == 0; 
     }
       
     if (defined (my $href = $CURRENT_ARRAY->getDataCube()->getHref())) {
        # add to the datablock
        $DATABLOCK .= &_getHrefData($href);
     }

     # this declares we are now reading data, 
     $DATA_NODE_LEVEL++; # entered a datanode, raise the count 

  } else {
    die "No read object defined in array. Exiting.\n";
  }

}

sub dataFormat_node_start {
  my (%attrib_hash) = @_;
  # save attribs for latter
  $Data_Format_Attrib_Ref = \%attrib_hash;
}

sub exponentField_node_start {
  my (%attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$Data_Format_Attrib_Ref}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = &current_dataType_obj();
  
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataTypeObj->setDataFormat(new XDF::ExponentialDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string data type/format in $dataTypeObj, ignoring\n";
  
  }

}

sub field_node_start {
   my (%attrib_hash) = @_;

   my $parent_node_name = &parent_node_name();

   my $fieldObj = $CURRENT_ARRAY->getFieldAxis()->addField(\%attrib_hash);

   # add this object to all open groups
   foreach my $groupObj (@CURRENT_FIELDGROUP_OBJECT) { $fieldObj->addToGroup($groupObj); }

   if(defined $fieldObj && exists($attrib_hash{'fieldId'})) {
      my $id = $attrib_hash{'fieldId'};
      &print_warning("More than one field node with fieldId=\"$id\", using latest node.\n") 
            if defined $FieldObj{$id};
       $FieldObj{$id} = $fieldObj;
   }

   $CURRENT_DATATYPE_OBJECT = $fieldObj;

}

sub fieldAxis_node_start {
   my (%attrib_hash) = @_;

   my $axisObj = new XDF::FieldAxis(\%attrib_hash);

   # add in reference object, if it exists 
   if (exists($attrib_hash{'axisIdRef'})) {
      my $id = $attrib_hash{'axisIdRef'};

      # clone from the reference object
      $axisObj = $AxisObj{$id}->clone();

      # override with local values
      $axisObj->setXMLAttributes(\%attrib_hash);
      $axisObj->setAxisId(&getUniqueIdName($id, \%AxisObj)); # set ID attribute to unique name 
      $axisObj->setAxisIdRef(undef); # unset IDREF attribute 

      # record this axis under its parent id 
      $CURRENT_ARRAY_AXES{$id} = $axisObj;
   }

   # add this object to the lookup table, if it has an ID
   if ((my $axisId = $attrib_hash{'axisId'})) {
      my $axisId = $attrib_hash{'axisId'};
      &print_warning( "More than one axis node with axisId=\"$axisId\", using latest node.\n" )
            if defined $AxisObj{$axisId};
      $AxisObj{$axisId} = $axisObj;
   }

   # add the axis object to the array
   $CURRENT_ARRAY->addFieldAxis($axisObj, undef, 1);

}

sub fieldGroup_node_end { pop @CURRENT_FIELDGROUP_OBJECT; }

sub fieldGroup_node_start {
  my (%attrib_hash) = @_;

  my $parent_node_name = &parent_node_name();

  my $fieldGroupObj;

  if($parent_node_name eq $XDF_node_name{'fieldAxis'} ) {

    $fieldGroupObj = $CURRENT_ARRAY->getFieldAxis()->addFieldGroup(\%attrib_hash);

  } elsif($parent_node_name eq $XDF_node_name{'fieldGroup'} ) {

    my $lastGroupObj = $CURRENT_FIELDGROUP_OBJECT[$#CURRENT_FIELDGROUP_OBJECT];
    $fieldGroupObj = $lastGroupObj->addFieldGroup(\%attrib_hash);

  } else {

     die" weird parent node $parent_node_name for fieldGroup";

  }

  # add this object to all open groups
  foreach my $groupObj (@CURRENT_FIELDGROUP_OBJECT) { $fieldGroupObj->addToGroup($groupObj); }

  # add to the list of open fieldGroups
  push @CURRENT_FIELDGROUP_OBJECT, $fieldGroupObj;

}


sub field_relationship_node_start {
  my (%attrib_hash) = @_;

   my $fieldObj = &last_field_obj();
   my $relObj = $fieldObj->setRelation(new XDF::FieldRelation(\%attrib_hash));

}

sub floatField_node_start {
  my (%attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$Data_Format_Attrib_Ref}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = &current_dataType_obj();
  
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataTypeObj->setDataFormat(new XDF::FloatDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string data type/format in $dataTypeObj, ignoring\n";
  
  }

}

sub for_node_start {              
  my (%attrib_hash) = @_;

  # well, if we see for nodes, we must have untagged data.
  # lets set the DataIOStyle
  #if ( defined $DataIOStyle_Attrib_Ref) {
#    $CURRENT_ARRAY->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($DataIOStyle_Attrib_Ref))
#  } 
#  $DataIOStyle_Attrib_Ref = undef;

  # for node sets the iteration order for how we will setData
  # in the datacube (important for delimited and formatted reads).
  if (defined (my $id = $attrib_hash{'axisIdRef'})) {
    my $axisObj = $CURRENT_ARRAY_AXES{$id};
    $axisObj = $AxisObj{$id} unless defined $axisObj;
    push @READAXISORDER, $axisObj;
  } else {
    print STDERR "Error: got for node without axisIdRef, aborting read.\n";
    exit (-1); 
  }

  # well, if we see for nodes, we must have untagged data.
  # lets set the DataIOStyle
#  if ( defined $DataIOStyle_Attrib_Ref) {
#    $CURRENT_ARRAY->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($DataIOStyle_Attrib_Ref))
#  } else {
#    die "Weird Reader error! no XMLDataIOStyle attribute reference!\n";
#  } 
#  $DataIOStyle_Attrib_Ref = undef;

#  my $readObj = $CURRENT_ARRAY->getXMLDataIOStyle;

  # add the read axis (its what the for node specifies)
  #$readObj->addReadAxis($attrib_hash{'axisIdRef'});
  #push @READAXISORDER, $AxisObj{$attrib_hash{'axisIdRef'}};

  # Now for something completely sub-optimal: since there can be 
  # more than one 'for' node we may do this more than once.
  # However, wasted CPU cycles are minimized by the fact that there
  # just arent that many axes (e.g. dimensions) in almost any dataset.

  # set the style of the IO (couldnt this be done in hidden way?)
#  $readObj->style($UnTagged_Read_Style);

  # set the format object in the current array
#  $CURRENT_FORMAT_OBJECT[0] = $CURRENT_ARRAY->untaggedReadStyle(new XDF::FormattedReadStyle());

}

sub integerField_node_start {
  my (%attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$Data_Format_Attrib_Ref}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = &current_dataType_obj();
  
  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) {
  
     $dataTypeObj->setDataFormat(new XDF::IntegerDataFormat(\%merged_hash));
  
  } else {
  
    warn "Unknown parent object, cant set string data type/format in $dataTypeObj, ignoring\n";
  
  }

}

sub note_node_charData {
  my ($string) = @_;


  if (defined $LAST_NOTE_OBJECT) {
    # add string as the value of the note
    $LAST_NOTE_OBJECT->addText($string);

  } else {

    # error! did they specify a value on an idRef'd node??
    &print_warning("Weird error: tried to put value on non-existent note!($string)\n"); 

  }

}

# this, along with notes_*, needs to be re-written proper
sub note_node_start {
   my (%attrib_hash) = @_;

   # note: note nodes sometimes appear within notes node,
   # use $LAST_NOTES_PARENT_OBJ to determine if this is the case
   # (yes this is crappy)
   my $parent_node = defined $LAST_NOTES_PARENT_OBJ ? $XDF_node_name{'array'} : undef;
   $parent_node = &parent_node_name() unless defined $parent_node;
  
   my $noteObj = new XDF::Note(\%attrib_hash);

   # does this object have a noteIdRef? If so, we clone a copy
   if (exists($attrib_hash{'noteIdRef'})) {
      my $id = $attrib_hash{'noteIdRef'};

      # clone from the reference object
      $noteObj = $NoteObj{$id}->clone();

      # override with local values
      $noteObj->setXMLAttributes(\%attrib_hash);
      $noteObj->setNoteId(&getUniqueIdName($id, \%NoteObj)); # set ID attribute to unique name 
      $noteObj->setNoteIdRef(undef); # unset IDREF attribute 
   }

   # Does this object have a noteId? if so, add to our roster of notes 
   if ((my $id = $noteObj->getNoteId())) {
         &print_warning("More than one note node with noteId=\"$id\", using latest node.\n")
            if defined $NoteObj{$id};
         $NoteObj{$id} = $noteObj;
   }


   my $addNoteObj;
   if ($parent_node eq $XDF_node_name{'array'}) {
         $addNoteObj = $CURRENT_ARRAY;
   } elsif ($parent_node eq $XDF_node_name{'field'}) {
         $addNoteObj = &last_field_obj();
   } elsif ($parent_node eq $XDF_node_name{'parameter'}) {
         $addNoteObj = &last_parameter_obj();
   } else {
         &print_warning( "Unknown parent node: $parent_node for note. Ignoring\n");
   }

   if (defined $addNoteObj) {
      $noteObj = $addNoteObj->addNote($noteObj);
   }

   $LAST_NOTE_OBJECT = $noteObj;

}

sub note_index_node_start {
   my (%attrib_hash) = @_;
   push @NOTE_LOCATOR_ORDER, $attrib_hash{'axisIdRef'};
}

sub notes_node_end {
   my $notesParentObj = $LAST_NOTES_PARENT_OBJ;

   if (exists $notesParentObj->{Notes}) { 
      my $notesObj = $notesParentObj->{Notes}; 
      for (@NOTE_LOCATOR_ORDER) { $notesObj->addAxisIdToLocatorOrder($_); }
   }

   # reset the location order 
   @NOTE_LOCATOR_ORDER = ();
   
   # clear notes object
   $LAST_NOTES_PARENT_OBJ = undef;
}

sub notes_node_start {
   my (%attrib_hash) = @_;

   my $parent_node_name = &parent_node_name();

   my $obj;
   if ($parent_node_name eq $XDF_node_name{'field'}) {
        $obj = &last_field_obj();
   } elsif ($parent_node_name eq $XDF_node_name{'parameter'}) {
        $obj = &last_parameter_obj();
   } elsif ($parent_node_name eq $XDF_node_name{'array'}) {
        $obj = $CURRENT_ARRAY;
   } else {
        die "Weird parent $parent_node_name for notes object\n";
   }

   $LAST_NOTES_PARENT_OBJ = $obj if defined $obj; # ->notes() if defined $obj;

}

sub parameter_node_start {
   my (%attrib_hash) = @_;

   my $parent_node_name = &parent_node_name();

   my $paramObj;
   if($parent_node_name eq $XDF_node_name{'array'} ) {

        $paramObj = $CURRENT_ARRAY->addParameter(\%attrib_hash);

   } elsif($parent_node_name eq $XDF_node_name{'root'}
              || $parent_node_name eq $XDF_node_name{'structure'})
   { 

        $paramObj = $CURRENT_STRUCTURE->addParameter(\%attrib_hash);

   } elsif($parent_node_name eq $XDF_node_name{'parameterGroup'} ) {

#        $LAST_GROUP_OBJECT->addObject(new XDF::Parameter(\%attrib_hash));
        # for now, just add as regular parameter 
       $paramObj = $LAST_PARAMGROUP_PARENT_OBJECT->addParameter(\%attrib_hash);

   } else {
       die" weird parent node $parent_node_name for parameter";
   }

   # add this object to all open groups
   foreach my $groupObj (@CURRENT_PARAMGROUP_OBJECT) { $paramObj->addToGroup($groupObj); }

   $LAST_PARAM_OBJECT = $paramObj;

}

sub parameterGroup_node_end { pop @CURRENT_PARAMGROUP_OBJECT; }

sub parameterGroup_node_start {
  my (%attrib_hash) = @_;
  
  my $parent_node_name = &parent_node_name();

  my $paramGroupObj;

  if($parent_node_name eq $XDF_node_name{'array'} ) {

    $paramGroupObj = $CURRENT_ARRAY->addParamGroup(\%attrib_hash);
    $LAST_PARAMGROUP_PARENT_OBJECT = $CURRENT_ARRAY;

  } elsif($parent_node_name eq $XDF_node_name{'root'}
              || $parent_node_name eq $XDF_node_name{'structure'})
  {

    $paramGroupObj = $CURRENT_STRUCTURE->addParamGroup(\%attrib_hash);
    $LAST_PARAMGROUP_PARENT_OBJECT = $CURRENT_STRUCTURE;

  } elsif($parent_node_name eq $XDF_node_name{'parameterGroup'} ) {

    my $lastGroupObj = $CURRENT_PARAMGROUP_OBJECT[$#CURRENT_PARAMGROUP_OBJECT]; 
    $paramGroupObj = $lastGroupObj->addParamGroup(\%attrib_hash);

  } else {

     die" weird parent node $parent_node_name for parameterGroup";

  }

  # add this object to all open groups
  foreach my $groupObj (@CURRENT_PARAMGROUP_OBJECT) { $paramGroupObj->addToGroup($groupObj); }

  # now add it to the list
  push @CURRENT_PARAMGROUP_OBJECT, $paramGroupObj;

}

sub read_node_end {

  my $readObj = $CURRENT_ARRAY->getXMLDataIOStyle();

  die "Fatal: No XMLDataIOStyle defined for this array!, exiting" unless defined $readObj;

  # initialization for XDF::Reader specific internal GLOBALS
  if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

    # zero out all the tags
    foreach my $tag ($readObj->getAxisTags()) {
      $TAG_COUNT{$tag} = 0;
    }

  } elsif (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle' or
           ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' ) 
  {
     # do nothing
  } else {
     die "Dont know what do with this read style (",$readObj->style(),").\n";
  } 

}

sub read_node_start { 
  my (%attrib_hash) = @_;

  # save these for later, when we know what kind of dataIOstyle we got
  $DataIOStyle_Attrib_Ref = \%attrib_hash;

  # zero this out for upcoming read 
  @READAXISORDER = ();

  # clear out the format command object array
  # (its used by Formatted reads only, but this is reasonable 
  # spot to do this).
  @CURRENT_FORMAT_OBJECT = (); 

}

sub readCell_node_start { 
  my (%attrib_hash) = @_;

  # if this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  if ( defined $DataIOStyle_Attrib_Ref) {
    $CURRENT_ARRAY->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($DataIOStyle_Attrib_Ref));
    $DataIOStyle_Attrib_Ref = undef;
    push @CURRENT_FORMAT_OBJECT, $CURRENT_ARRAY->getXMLDataIOStyle();
  } 

  my $formatObj = &current_format_obj();
  my $readCellObj = $formatObj->addFormatCommand(new XDF::ReadCellFormattedIOCmd(\%attrib_hash));

}

sub repeat_node_end { pop @CURRENT_FORMAT_OBJECT; }

sub repeat_node_start {
  my (%attrib_hash) = @_;

  # If this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  if ( defined $DataIOStyle_Attrib_Ref) {
    $CURRENT_ARRAY->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($DataIOStyle_Attrib_Ref));
    $DataIOStyle_Attrib_Ref = undef;
    push @CURRENT_FORMAT_OBJECT, $CURRENT_ARRAY->getXMLDataIOStyle();
  } 

  my $formatObj = &current_format_obj();
  my $repeatObj = $formatObj->addFormatCommand(new XDF::RepeatFormattedIOCmd(\%attrib_hash));
 
  push @CURRENT_FORMAT_OBJECT, $repeatObj;

}

sub root_node_start { 
  my (%attrib_hash) = @_;
  
  # this is just like a "structure" node.
  # but is always the first one.
  $XDF = XDF::Structure->new(\%attrib_hash);
  $CURRENT_STRUCTURE = $XDF;

  $XDF->DefaultDataArraySize($DEF_ARRAY_AXIS_SIZE) if defined $DEF_ARRAY_AXIS_SIZE;

}

sub skipChar_node_start {
  my (%attrib_hash) = @_;

  # If this is still defined, we havent init'd an
  # XMLDataIOStyle object for this array yet, do it now. 
  if ( defined $DataIOStyle_Attrib_Ref) {
    $CURRENT_ARRAY->setXMLDataIOStyle(new XDF::FormattedXMLDataIOStyle($DataIOStyle_Attrib_Ref));
    $DataIOStyle_Attrib_Ref = undef;
    push @CURRENT_FORMAT_OBJECT, $CURRENT_ARRAY->getXMLDataIOStyle();
  }

  my $formatObj = &current_format_obj();
  $formatObj->addFormatCommand(new XDF::SkipCharFormattedIOCmd(\%attrib_hash));

}

sub stringField_node_start {
  my (%attrib_hash) = @_;

  # this can waste memory, however these should always be quite small. 
  # see perl cookbook on merging hashes
  my %merged_hash = (%{$Data_Format_Attrib_Ref}, %attrib_hash);

  # create the object, add it to the current datatype holder 
  my $dataTypeObj = &current_dataType_obj(); 

  if (ref($dataTypeObj) eq 'XDF::Field' or ref($dataTypeObj) eq 'XDF::Array' ) { 

     $dataTypeObj->setDataFormat(new XDF::StringDataFormat(\%merged_hash));

  } else {

    warn "Unknown parent object, cant set string dataformat in $dataTypeObj, ignoring\n";

  }

}

sub structure_node_start {
  my (%attrib_hash) = @_;


   if (!defined $XDF) {
      $XDF = XDF::Structure->new(\%attrib_hash);
      $CURRENT_STRUCTURE = $XDF;
   } else {
      my $structObj = $CURRENT_STRUCTURE->addStructure(\%attrib_hash);
      $CURRENT_STRUCTURE = $structObj;
   }
   
}

sub tagToAxis_node_start {
  my (%attrib_hash) = @_;

  # well, if we see tagToAxis nodes, must have tagged data, the 
  # default style. No need for initing further. 
  if ( defined $DataIOStyle_Attrib_Ref) {
    $CURRENT_ARRAY->setXMLDataIOStyle(new XDF::TaggedXMLDataIOStyle($DataIOStyle_Attrib_Ref)) 
  }
  $DataIOStyle_Attrib_Ref = undef;

  # add in the axis, tag information
  $CURRENT_ARRAY->getXMLDataIOStyle()->setAxisTag($attrib_hash{'tag'}, $attrib_hash{'axisIdRef'});

}

sub unit_node_charData {
  my ($string) = @_;


  if (defined $LAST_UNIT_OBJECT) {
    # add string as the value of the note
    $LAST_UNIT_OBJECT->setValue($string);

  } else {

    # error! did they specify a value on an idRef'd node??
    &print_warning( "Crazy error! tried to put value on non-existent note!($string)\n");

  }

}

sub unit_node_start {
  my (%attrib_hash) = @_;

  my $parent_node_name = &grand_parent_node_name();

  my $unitObj;

  if ($parent_node_name eq $XDF_node_name{'field'} ) {

     # add the unit to the last parameter node in grandparent
      my $fieldObj = &last_field_obj();

      $unitObj = $fieldObj->addUnit(\%attrib_hash);

  } elsif ($parent_node_name eq $XDF_node_name{'axis'} ) {

      my $axisObj = &last_axis_obj();
      $unitObj = $axisObj->addUnit(\%attrib_hash);

  } elsif ($parent_node_name eq $XDF_node_name{'array'} ) {

      $unitObj = $CURRENT_ARRAY->addUnit(\%attrib_hash);

  } elsif ($parent_node_name eq $XDF_node_name{'parameter'} ) {

      my $paramObj = &last_parameter_obj();
      $unitObj = $paramObj->addUnit(\%attrib_hash);

  } else {

      &print_warning( "Got Weird parent node ($parent_node_name) for unit. \n");

  }

  $LAST_UNIT_OBJECT = $unitObj;

}

sub units_node_start { 
  my (%attrib_hash) = @_; 
  # do nothing
}

sub unitless_node_start {
  my (%attrib_hash) = @_;
  # do nothing
}

sub value_node_charData {
  my ($string) = @_;

  my $parent_node = &parent_node_name();

  my $valueObj;

  if ($parent_node eq $XDF_node_name{'parameter'} ) {

     # add the value in $string to last parameter node in grandparent
     my $paramObj = &last_parameter_obj();
     $valueObj = $paramObj->addValue($string);

  } elsif ($parent_node eq $XDF_node_name{'axis'} ) {

     # add the value in $string to last axis node in current array 
     my $axisObj = &last_axis_obj();
     $valueObj = $axisObj->addAxisValue($string);

  } elsif ( $parent_node eq $XDF_node_name{'valueGroup'} ) {

    if (ref($LAST_VALUEGROUP_PARENT_OBJECT) eq 'XDF::Parameter') {

       $valueObj = $LAST_VALUEGROUP_PARENT_OBJECT->addValue($string);

    } elsif (ref($LAST_VALUEGROUP_PARENT_OBJECT) eq 'XDF::Axis') {

       $valueObj = $LAST_VALUEGROUP_PARENT_OBJECT->addAxisValue($string);

    } else {
      my $name = ref($LAST_VALUEGROUP_PARENT_OBJECT);
      die " ERROR: UNKNOWN valueGroupParent object ($name), can't treat for value.\n";
    }
     
  } else {

     die " ERROR: UNKNOWN parent node ($parent_node), can't treat for value.\n";

  }

  # add this object to all open groups
  foreach my $groupObj (@CURRENT_VALUEGROUP_OBJECT) { $valueObj->addToGroup($groupObj); }

}

sub valueGroup_node_end { pop @CURRENT_VALUEGROUP_OBJECT; }

sub valueGroup_node_start {
  my (%attrib_hash) = @_;

  my $parent_node_name = &parent_node_name();

  my $valueGroupObj;

  if( $parent_node_name eq $XDF_node_name{'axis'} ) {

    my $axisObj = &last_axis_obj();
    $valueGroupObj = $axisObj->addValueGroup(\%attrib_hash);
    $LAST_VALUEGROUP_PARENT_OBJECT = $axisObj;

  } elsif($parent_node_name eq $XDF_node_name{'parameter'} ) {

    my $paramObj = &last_parameter_obj();
    $valueGroupObj = $paramObj->addValueGroup(\%attrib_hash);
    $LAST_VALUEGROUP_PARENT_OBJECT = $paramObj;

  } elsif($parent_node_name eq $XDF_node_name{'valueGroup'} ) {

    my $lastGroupObj = $CURRENT_VALUEGROUP_OBJECT[$#CURRENT_VALUEGROUP_OBJECT];
    $valueGroupObj = $lastGroupObj->addValueGroup(\%attrib_hash);

  } else {

     die" weird parent node $parent_node_name for valueGroup";

  }

  foreach my $groupObj (@CURRENT_VALUEGROUP_OBJECT) { $valueGroupObj->addToGroup($groupObj); }

  # now add it to the list
  push @CURRENT_VALUEGROUP_OBJECT, $valueGroupObj;

}

sub valueList_node_charData {
  my ($string) = @_;

  # split up string based on declared delimiter
  my $delimiter = '/' . $CURRENT_VALUELIST{'delimiter'};
  if ($CURRENT_VALUELIST{'repeatable'} eq 'yes') {
    $delimiter .= '+/';
  } else {
    $delimiter .= '/';
  } 
  my @values;
  eval " \@values = split $delimiter, \$string ";

  my @valueObjList = ();

  # need dispatch list for this too
  if ($CURRENT_VALUELIST{'parent_node'} eq $XDF_node_name{'axis'} )
  {

      # adding values to the last axis in the array
      my $axisObj = &last_axis_obj();
      foreach my $val (@values) { 
         push @valueObjList, $axisObj->addAxisValue($val); 
      }

  } elsif ($CURRENT_VALUELIST{'parent_node'} eq $XDF_node_name{'parameter'} ) {

     # adding values to the last axis in the array
     my $paramObj = &last_parameter_obj();
     foreach my $val (@values) { 
        push @valueObjList, $paramObj->addValue($val); 
     }

  } elsif ($CURRENT_VALUELIST{'parent_node'} eq $XDF_node_name{'valueGroup'} ) {

     my $method;
     if (ref($LAST_VALUEGROUP_PARENT_OBJECT) eq 'XDF::Parameter') {
       $method = "addValue";
     } elsif (ref($LAST_VALUEGROUP_PARENT_OBJECT) eq 'XDF::Axis') {
        $method = "addAxisValue";
     } else {
       my $name = ref($LAST_VALUEGROUP_PARENT_OBJECT);
       die " ERROR: UNKNOWN valueGroupParent object ($name), can't treat for valueList.\n";
     }

     # adding values to the last axis in the array
     foreach my $val (@values) { 
       push @valueObjList, $LAST_VALUEGROUP_PARENT_OBJECT->$method($val);
     }

  } else {

     die " ERROR: UNKNOWN parent node ($CURRENT_VALUELIST{'parent_node'}, can't treat for valueList.\n";

  }

  # add these new value objects to all open groups
  foreach my $groupObj (@CURRENT_VALUEGROUP_OBJECT) { 
    foreach my $valueObj (@valueObjList) { $valueObj->addToGroup($groupObj); }
  }

}

sub valueList_node_start { 
  my (%attrib_hash) = @_;

   my $parent_node = &parent_node_name();
   my @values = &get_valueList_node_values(%attrib_hash);

   # IT could be that no values exist because they are stored
   # in PCDATA rather than as alorithm (treat in char data handler
   # in this case).
   if($#values != -1 ) {
    
     my @valueObjList = ();

     # adding values to the last axis in the array
     if ($parent_node eq $XDF_node_name{'axis'}) {

        my $axisObj = &last_axis_obj();
        foreach my $val (@values) { 
           push @valueObjList, $axisObj->addAxisValue($val); 
        }

      } elsif($parent_node eq $XDF_node_name{'valueGroup'}) {

        my $method;
        if (ref($LAST_VALUEGROUP_PARENT_OBJECT) eq 'XDF::Parameter') {
           $method = "addValue";
        } elsif (ref($LAST_VALUEGROUP_PARENT_OBJECT) eq 'XDF::Axis') {
           $method = "addAxisValue";
        } else {
           my $name = ref($LAST_VALUEGROUP_PARENT_OBJECT);
           die " ERROR: UNKNOWN valueGroupParent object ($name), can't treat for valueList.\n";
        }

        foreach my $val (@values) { 
           push @valueObjList, $LAST_VALUEGROUP_PARENT_OBJECT->$method($val); 
        }

      } elsif($parent_node eq $XDF_node_name{'parameter'}) {

         my $paramObj = &last_parameter_obj();
         foreach my $val (@values) { 
            push @valueObjList, $paramObj->addValue($val); 
         }

      } else {

        die "Value List node got weird parent node: $parent_node\n";

      }

      # add these new value objects to all open groups
      foreach my $groupObj (@CURRENT_VALUEGROUP_OBJECT) {
        foreach my $valueObj (@valueObjList) { $valueObj->addToGroup($groupObj); }
      }

   } else {

         $CURRENT_VALUELIST{'parent_node'} = $parent_node;
         $CURRENT_VALUELIST{'delimiter'} = defined $attrib_hash{'delimiter'} ?
               $attrib_hash{'delimiter'} : $Def_ValueList_Delimiter;
         $CURRENT_VALUELIST{'repeatable'} = defined $attrib_hash{'repeatable'} ?
               $attrib_hash{'repeatable'} : $Def_ValueList_Repeatable;

   }

}

sub vector_node_start { 
  my (%attrib_hash) = @_;

  my $parent_node = &parent_node_name();

  if ($parent_node eq $XDF_node_name{'axis'}) {

     my $axisObj = &last_axis_obj();
     my $axisValue = $axisObj->addAxisUnitDirection(\%attrib_hash);

     # add in reference object, if it exists
 #    if (exists($attrib_hash{'axisIdRef'})) {
 #         my $axisId = $attrib_hash{'axisIdRef'};
 #         my $refAxisObj = $AxisObj{$axisId};
 #         $axisValue->setObjRef($refAxisObj) if $refAxisObj;
 #    }

  } else {
        &print_warning( "$XDF_node_name{'vector'} node not supported for $parent_node yet. Ignoring node.\n");
  }

}

# Other misc subroutines...

sub print_debug ($) { my ($msg) = @_; print STDERR $msg if $DEBUG; }

sub print_extreme_debug ($) { my ($msg) = @_; print STDERR $msg if $DEBUG > 1; }

sub current_node_name { return $CURRENT_NODE_PATH[$#CURRENT_NODE_PATH]; }

sub null_cmd { }

sub parent_node_name { return $CURRENT_NODE_PATH[$#CURRENT_NODE_PATH-1]; } 

sub getUniqueIdName {
   my ($id, $hash_ref) = @_;
   my %hash = %{$hash_ref};

   # this will create axes with name that has trailing zeros 
   while (exists $hash{$id}) { $id .= '0'; }

   return $id;
}

sub grand_parent_node_name { 
  return $CURRENT_NODE_PATH[$#CURRENT_NODE_PATH-2]; 
} 

# only deals with files right now. Bleah.
sub _getHrefData {
   my ($href) = @_;

   my $file;
   my $text;
   $file = $href->getBase() if $href->getBase();
   $file .= $href->getSysId();
   if (defined $file) {
       undef $/; #input rec separator, once newline, now nothing.
                 # will cause whole file to be read in one whack 
       open(DATAFILE, $file);
       $text = <DATAFILE>;
       close DATAFILE;
   } else {
      die "Can't read Href data, undefined sysId!\n";
   }
   return $text;
}

sub make_attrib_array_a_hash {
  my (@array) = @_; 

  my %hash;

  while (@array) {
     my $var = shift @array;
     my $val = shift @array;
     &print_warning( "duplicate attributes for $var, overwriting\n")
       unless !defined $hash{$var} || $QUIET;
     $hash{$var} = $val;
  }

  return %hash;
}

# very limited. We want to just treat the linear
# insertion case 
sub get_valueList_node_values {
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

sub print_warning {
  my ($msg) = @_;

  warn "$msg";
  die "$0 exiting, too many warnings.\n" if ($MAX_WARNINGS > 0 && $NROF_WARNING++ > $MAX_WARNINGS);

}

# Treatment for hex, octal reads
# that can occur in formatted data
sub deal_with_special_integer_data {
  my ($dataFormatListRef, $data_ref) = @_;

  my @data = @{$data_ref};
  my @dataFormatList = @{$dataFormatListRef};

  foreach my $dat_no (0 .. $#dataFormatList) {
    $data[$dat_no] = &change_integerField_data_to_flagged_format($dataFormatList[$dat_no], $data[$dat_no] )
                if ref($dataFormatList[$dat_no]) =~ m/XDF::Integer/;
  }

  return @data;
}

sub change_integerField_data_to_flagged_format {
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

    &print_warning ("XDF::Reader does'nt understand integer type: $formatflag\n");
    return $datum;
  }

}


sub current_dataType_obj { return $CURRENT_DATATYPE_OBJECT; }

sub current_format_obj { return $CURRENT_FORMAT_OBJECT[$#CURRENT_FORMAT_OBJECT]; }

sub last_field_obj {
 return @{$CURRENT_ARRAY->getFieldAxis()->getFieldList()}[$#{$CURRENT_ARRAY->getFieldAxis()->getFieldList()}];
}

sub last_axis_obj { return @{$CURRENT_ARRAY->getAxisList()}[$#{$CURRENT_ARRAY->getAxisList()}]; }

sub last_parameter_obj { return $LAST_PARAM_OBJECT; }

# Throws an exception (with die) when an error is encountered, this
# will stop the parsing process.
# Don't die if a warning or info message is encountered, just print a message.
sub my_fail {
   my $code = shift;
   die XML::Checker::error_string ($code, @_) if $code < 200;
   XML::Checker::print_error ($code, @_) if $code < $PARSER_MSG_THRESHOLD;
}


# Modification History
#
# $Log$
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



    my $DEBUG = 0;
    my $QUIET = 1;

    # test file for reading in XDF files.

    my $file = $ARGV[0];
    my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );

    my $XDF = &XDF::Reader::createXDFObjectFromFile($file, \%options);



...

=head1 DESCRIPTION

 This module (XDF::Reader is not currently an object) allows the user to create  XDF objects from XDF files.  Currently XDF::Reader will only read in ASCII data.  Both tagged/untagged(formated/delimited) XDF data styles are supported. 



=over 4

=head2 OTHER Methods

=over 4

=item createXDFObjectFromFile ($optionsHashRef, $file)

Reads in the given file and returns a full XDF Perl object (an L<XDF::Structure>with at least one L<XDF::Array>). A second HASH argument may be supplied to specify runtime options for the XDF::Reader. 

=item createXDFObjectFromFileHandle ($optionsHashRef, $handle)

Similar to createXDFObjectFromFile but takes an open filehandle as an argument (so you can parse ANY open fileHandle, e.g. files, sockets, etc. Whatever Perl supports.). 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.
=back

=over 4

=head2 INHERITED Other Methods

=back



=over 4

=head1 Reader Options 

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
  
  'debug'      => Set the reader to run with debugging messages. Defaults to 0 ('no'). 
  
  'axisSize'   => Set the number of indices to allocate along each dimension. This
                  can speed up large file reads. Defaults to $XDF::BaseObject::DefaultDataArraySize. 
  
  'maxWarning" => Change the maximum allowed number of warnings before the XDF::Reader
                  will halt its parse of the input file/fileHandle. 
  


=back

=head1 SEE ALSO

L<XDF::Array>, L<XDF::BinaryFloatDataFormat>, L<XDF::BinaryIntegerDataFormat>, L<XDF::DelimitedXMLDataIOStyle>, L<XDF::Field>, L<XDF::FieldRelation>, L<XDF::FloatDataFormat>, L<XDF::FormattedXMLDataIOStyle>, L<XDF::Href>, L<XDF::IntegerDataFormat>, L<XDF::Parameter>, L<XDF::RepeatFormattedIOCmd>, L<XDF::ReadCellFormattedIOCmd>, L<XDF::SkipCharFormattedIOCmd>, L<XDF::StringDataFormat>, L<XDF::Structure>, L<XDF::XMLDataIOStyle>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut


# $Id$

package XDF::DataCube;

# /** COPYRIGHT
#    DataCube.pm Copyright (C) 2000 Brian Thomas,
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
# Holds the data for a given L<XDF::Array>. It is designed to flexibly expand as data 
# is added/appended onto it. It doesnt treat swaping of large array data out to file currently.
# */

# /** SYNOPSIS
#    my $dataObj = XDF::DataCube->new();
# */

# /** SEE ALSO
# XDF::Array
# */

use Carp;
use XDF::Utility;
use XDF::BaseObject;

# fields pragma requires Perl 5.005 support. what does this do exactly?? 
# It does the following:
# 1- Informats Perl compiler that these are only valid fields
#    in the class
# 2- Creates a package hash named %FIELDS with an entry for each named field.
#
# 3- Causes the Perl compiler to trnslate any pseudo-hash accesses into
#    direct array accesses. 
# Upshot: faster class 
# use fields @Class_Attributes;

use strict;
use integer;

use vars qw ($AUTOLOAD %field @ISA);

# inherits from XDF::BaseObject
@ISA = ("XDF::BaseObject");

# CLASS DATA
my $Class_XML_Node_Name = "data";
my @Class_XML_Attributes = qw (
                             href
                             encoding
                             checksum
                             compression
                          );
                             #_currentLocator
my @Class_Attributes = qw (
                             dimension
                             maxDimensionIndex
                             _parentArray
                             _data
                          );

# /** dimension
# The number of dimensions within this dataCube.
# */
# this shouldnt be publicly possible to set!
# /** maxDimensionIndex
# The maximum index value along each dimension (Axis). Returns an ARRAY of SCALARS (non-negative INTEGERS).
# */
# /** href
# Reference to a separate resource (file, URL, etc) holding the actual data.
# */
# /** checksum
# The MD5 checksum of the data.
# */
# /** compression
# The STRING value which stores the type of compression algoritm used
# to compress the data.
# */

# add in class XML attributes
push @Class_Attributes, @Class_XML_Attributes;

# add in super class attributes
push @Class_Attributes, @{&XDF::BaseObject::classAttributes};

# Initalization
# set up object attributes.
for my $attr ( @Class_Attributes ) { $field{$attr}++; }

# CLASS stuff..

# /** classXMLNodeName
# This method takes no arguments may not be changed. This method returns the class node name of XDF::DataCube.
# */
sub classXMLNodeName { 
  $Class_XML_Node_Name; 
}

# /** classAttributes
#  This method returns a list reference containing the names
#  of the class attributes of XDF::DataCube; 
#  This method takes no arguments may not be changed. 
# */
sub classAttributes { 
  \@Class_Attributes; 
}

#
# Set/Get Methods 
#

# /** getChecksum
# */
sub getChecksum {
   my ($self) = @_;
   return $self->{Checksum};
}

# /** setChecksum
#     Set the checksum attribute. 
# */
sub setChecksum {
   my ($self, $value) = @_;
   $self->{Checksum} = $value;
}

# /** getHref
# */
sub getHref {
   my ($self) = @_;
   return $self->{Href};
}

# /** setHref
#     Set the href attribute. 
# */
sub setHref {
   my ($self, $hrefObjectRef) = @_;
   if (ref($hrefObjectRef) eq 'XDF::Href') {
     $self->{Href} = $hrefObjectRef;
   }
}

# /** getCompression
# */
sub getCompression {
   my ($self) = @_;
   return $self->{Compression};
}

# /** setCompression 
#     Set the compression attribute. 
# */
sub setCompression {
   my ($self, $value) = @_;

   carp "Cant set compression to $value, not allowed \n"
      unless (&XDF::Utility::isValidDataCompression($value));

   $self->{Compression} = $value;
}

# /** getEncoding
# */
sub getEncoding {
   my ($self) = @_;
   return $self->{Encoding};
}

# /** setEncoding
#     Set the encoding attribute. 
# */
sub setEncoding {
   my ($self, $value) = @_;

   carp "Cant set encoding to $value, not allowed \n"
      unless (&XDF::Utility::isValidDataEncoding($value));

   $self->{Encoding} = $value;
}

# /** getDimension
# */
sub getDimension {
   my ($self) = @_;
   return $self->{Dimension};
}

# /** getXMLAttributes
#      This method returns the XMLAttributes of this class. 
#  */
sub getXMLAttributes { 
  return \@Class_XML_Attributes;
}

#
# Other Public methods 
#

# /** toXMLFileHandle
# We overwrite the toXMLFileHandle method supplied by L<XDF::BaseObject> to 
# have some special handling for the XDF::DataCube. The interface for this
# method remains the same however. 
# */
# we dont want to write back out all the attributes, the data
# needs special handling to write out, etc...
sub toXMLFileHandle {
  my ($self, $fileHandle, $junk, 
      $indent, $newNodeNameString, $noChildObjectNodeName ) = @_;

  my $writeHrefAttribute = 0;
  my $niceOutput = $self->Pretty_XDF_Output();
  $indent = "" unless defined $indent;
  my $nodeName = $self->classXMLNodeName;
  $nodeName = $newNodeNameString if defined $newNodeNameString;

  # open the tagged data section
  print $fileHandle $indent if $niceOutput;
  print $fileHandle "<" . $nodeName ;
  print $fileHandle " checksum=\"".$self->{Checksum}."\"" if defined $self->{Checksum};
  print $fileHandle " compression=\"".$self->{Compression}."\"" if defined $self->{Compression};
  print $fileHandle " encoding=\"".$self->{Encoding}."\"" if defined $self->{Encoding};
  print $fileHandle " href=\"".$self->{Href}->getName()."\"" if defined $self->{Href};
  print $fileHandle ">";

  # write the data
  $self->writeDataToFileHandle($fileHandle, $indent );

  # close the tagged data section
  print $fileHandle "</" . $nodeName . ">";
  print $fileHandle "\n" if $niceOutput;


}

# /** writeDataToFileHandle
# Writes out just the data to the proscribed filehandle.
# */
sub writeDataToFileHandle {
  my ($self, $fileHandle, $indent) = @_;

  my $dontPrintCDATATag = 0;
  my $niceOutput = $self->Pretty_XDF_Output();
  $indent = "" unless defined $indent;

  my $readObj = $self->{_parentArray}->getXMLDataIOStyle();

  croak "DataCube can't write out. No format reference object defined.\n"
     unless defined $readObj;

  # a couple of shortcuts
  my $href = $self->{Href};
  my $parentArray = $self->{_parentArray};

  my $dataFileHandle;
  my $dataFileName;
  # check for href
  if ( defined $href ) {

      # BIG assumption: href is a file we want to read/write
      # Better Handling in future is needed
      if (defined $href->getSysId()) {
        $dataFileName = $href->getBase() if defined $href->getBase();
        $dataFileName .= $href->getSysId();
        open(DFH, ">$dataFileName"); # we will write data to another file 
                                     # as specified by the entity
        $dataFileHandle = \*DFH;
        $dontPrintCDATATag = 1;
      } else {
        croak "XDF::DataCube Href lacks SysId attribute, cannot write out data.\n";
      }   

  } else {
    $dataFileHandle = $fileHandle;
  } 

  croak "XDF::DataCube has no valid data filehandle" unless defined $dataFileHandle;

  my $fastestAxis = $parentArray->getAxisList()->[0];
  # stores the NoDataValues for the parentArray,
  # used in writing out when NoDataException is caught
  my @NoDataValues;

  if (defined $parentArray->getFieldAxis()) {
     # NoDataValues = new String[fastestAxis.getLength()];
     my @dataFormatList = $parentArray->getDataFormatList();
     for (my $i = 0; $i <= $#NoDataValues; $i++) {
        my $d =  $dataFormatList[$i];
        if (defined $d && defined $d->getNoDataValue())
        {
           $NoDataValues[$i] = $d->getNoDataValue();
        }
     }
  }
  else 
  {
     # If there is no fieldAxis, then no fields,
     # and hence, only ONE noDataValue.
     $NoDataValues[0] = $parentArray->getNoDataValue();
  }

  # write the data
  #
  if (ref($readObj) eq 'XDF::TaggedXMLDataIOStyle' ) {

     print $dataFileHandle "\n" if $niceOutput;
     &_write_tagged_data($self, $dataFileHandle, $readObj, $indent, $niceOutput);
     print $dataFileHandle "$indent" if $niceOutput;

  } else {

     print $dataFileHandle "<![CDATA[" unless $dontPrintCDATATag;

     if (ref($readObj) eq 'XDF::DelimitedXMLDataIOStyle')
     {
        &_write_untagged_data($self, $dataFileHandle, $readObj, $indent, $niceOutput, $fastestAxis);
     } 
      elsif (ref($readObj) eq 'XDF::FormattedXMLDataIOStyle' )
     {
   #     &_write_untagged_data($self, $dataFileHandle, $readObj, $indent, $niceOutput, $fastestAxis);
        $self->_writeFormattedData($dataFileHandle, $parentArray, $readObj, $fastestAxis, \@NoDataValues );

     } 
     else 
     {
        carp "Unknown read object: $readObj. $self cannot write itself out.\n";
     }

     unless ($dontPrintCDATATag) {
        print $dataFileHandle "]]>";
        print $dataFileHandle "\n$indent" if $niceOutput;
     }

  }

  if ( $dataFileName ) { close DFH; }

}

# /** addData
# This routine will append data to a cell unless directed to do otherwise.
# */
# the self evaluation part will make this SLOW for large arrays. :P
sub addData {
  my ($self, $locator, $data, $no_append ) = @_;

  # safety
  unless (defined $locator && defined $data) {
    carp "Please specify location and data value. Ignoring addData request.";
    return;
  }

  # add the data to the right array in the $self->{_data} list

  # We first check that the location exists! 
  # fix the array if it doesnt
  my $eval_string = &_build_locator_string($self->{_parentArray}, $locator);


  if($no_append) {
    $eval_string = $eval_string . " = \"$data\"";
  } else {
    $eval_string = $eval_string . " .= \"$data\"";
  }

  if (0) {
my $locationPos;
my $locationName;
for (@{$locator->getIterationOrder()}) {
   $locationName .= $_->getAxisId() . ",";
   $locationPos .= $locator->getAxisIndex($_) . ",";
}
chop $locationPos;
chop $locationName;

print STDERR "ADD EVAL STRING ($locationName)($locationPos): $eval_string\n";
  }

  eval " $eval_string; ";

}

# /** removeData
# Data held within the requested datacell is removed. The value of the datacell is set to undef.
# B<NOT CURRENTLY IMPLEMENTED>.
# */
sub removeData {
  carp "Remove_data not currently implemented.\n";
} 
  
# /** setData
# Set the SCALAR value of the requested datacell at indicated location (see LOCATOR REF section).
# Overwrites existing datacell value if any.
# */
sub setData {
  my ($self, $locator, $datum ) = @_;
  $self->addData($locator, $datum, 1);
} 

# /** getData
# Retrieve the SCALAR value of the requested datacell.
# */
# do we need to do some bounds checking here??
sub getData {
  my ($self, $locator) = @_;

  unless (defined $locator and ref($locator) eq 'XDF::Locator') {
    warn "getData method not passed a valid XDF::Locator object, ignoring request\n";
    return;
  }

  my $get_string = "\$self->{_data}";
  foreach my $axisObj (@{$self->{_parentArray}->getAxisList()}) {
     my $loc = $locator->getAxisIndex($axisObj);
     $get_string = $get_string . "->[$loc]";
  }

  my $result = eval "$get_string";
#print STDERR "getData evalstring: [$get_string]\n";
  return $result;

}

#
# Private/Protected(?) Methods 
#

# This is called when we cant find any defined method
# exists already. Used to handle general purpose set/get
# methods for our attributes (object fields).
sub AUTOLOAD {
  my ($self,$val) = @_;
  #&XDF::BaseObject::AUTOLOAD($self, $val, $AUTOLOAD, \%{$XDF::DataCube::FIELDS} );
  &XDF::GenericObject::AUTOLOAD($self, $val, $AUTOLOAD, \%field );
}

sub _init {
  my ($self) = @_;

  # declare the _data attribute as an array 
  # as we add data (below) it may grow in
  # dimensionality, but defaults to 0 at start. 
  $self->{Dimension} = 0;
  $self->{_data} = [];

  # set the minimum array size (essentially the size of the axis)
  $#{$self->{_data}} = $self->DefaultDataArraySize();

}


# Yes, this is crappy. I plan to come back and do it 'right' one day.
#
# Note: we need to consider the case where the user *DIDNT* supply 
# tag names for the axes. In this case, we use 'd0','d1' ...'d8' tag 
# notation.
sub _write_tagged_data {
  my ($self, $fileHandle, $readObj, $indent, $niceOutput) = @_;

  # now we populate the data , if there are any dimensions 
  if ($self->{Dimension} > 0) {

    my @axisList = @{$self->{_parentArray}->getAxisList()};

    # gather info. Find out what tags go w/ which axii
    my @AXIS_TAG = reverse $readObj->getAxisTags(); 

    # now build the formatting stuff. 
    my $data_indent = $indent . $self->Pretty_XDF_Output_Indentation;
    my $startDataRecordTag = $data_indent;
    my $endDataRecordTag = "";
    foreach my $axis (0 .. ($#axisList-1)) {
      $startDataRecordTag .= "<" . $AXIS_TAG[$axis] . ">";
    }
    foreach my $axis (reverse 0 .. ($#axisList-1)) {
      $endDataRecordTag .= "</" . $AXIS_TAG[$axis] . ">";
    }
    $endDataRecordTag .= "\n";
    my $startDataTag = "<" . $AXIS_TAG[$#axisList] . ">";
    my $endDataTag = "</" . $AXIS_TAG[$#axisList] . ">";
    my $emptyDataTag = "<" . $AXIS_TAG[$#axisList] . "/>";
 
    # ok, time to build the eval block that will write out the tagged data
    my $eval_block;
    my $locator = $self->{_parentArray}->createLocator;

    my $more_data = 1;
    my $fast_axis_length = @{$self->{_parentArray}->getAxisList()}->[0]->getLength(); 
    my $dataNumb = 0; 
    while ($more_data) {
       print $fileHandle $startDataRecordTag if ($dataNumb == 0);
       $self->_print_data($fileHandle, $locator, $startDataTag, $endDataTag, $emptyDataTag);
       $dataNumb++;
       if( $dataNumb >= $fast_axis_length ) {
         print $fileHandle $endDataRecordTag;
         $dataNumb = 0;
       }
       $more_data = $locator->next();
    }
  }

}

sub _write_untagged_data {
  my ($self, $fileHandle, $formatObj, $indent, $fastestAxis) = @_;

  # now we populate the data, if there are any dimensions 
  if ($self->{Dimension} > 0) {

    my $sprintfFormat;
    my $terminator;
    my $fast_axis_length;
    my $template;
    my @outArray;

    if (ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') {
      # tis a shame that we dont use the outArray/template system here.
      $sprintfFormat = $formatObj->_sprintfNotation();
      $terminator = $formatObj->getRecordTerminator();
      $fast_axis_length = @{$self->{_parentArray}->getAxisList()}->[0]->getLength(); 
    } elsif (ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle') {
      $template = $formatObj->_templateNotation(0);
      @outArray = $formatObj->_outputSkipCharArray;
    } else {
      die "$self got weird formatobj for untagged output of DataCube: $formatObj\n";
    }

    my $locator = $self->{_parentArray}->createLocator(); 
    $locator->setIterationOrder($formatObj->getWriteAxisOrderList());

    if (ref($formatObj) eq 'XDF::DelimitedXMLDataIOStyle') { 

      my $there_is_more_data = 1;
      my $dataNumb = 0;

      while ($there_is_more_data) {
        my $this_data = $self->getData($locator);
        $dataNumb++;
        if( $dataNumb >= $fast_axis_length ) {
          print $fileHandle $this_data . $terminator;
          $dataNumb = 0;
        } else {
          print $fileHandle sprintf($sprintfFormat, $this_data);
        } 
        $there_is_more_data = $locator->next();
      }

    } elsif (ref($formatObj) eq 'XDF::FormattedXMLDataIOStyle') { 

      my @outData = ();
      my $outArrayNumb = 0;
      my $there_is_more_data = 1;

      while ($there_is_more_data) {
        push @outData, $self->getData($locator) if !defined $outArray[$outArrayNumb];
        $outArrayNumb++;
        while (defined $outArray[$outArrayNumb]) { 
          push @outData, $outArray[$outArrayNumb++];
        }
        if( $outArrayNumb >= $#outArray ) {
          print $fileHandle pack($template, @outData);
          $outArrayNumb = 0;
          @outData = ();
        }
        $there_is_more_data = $locator->next();
      }

    } else {

      die "$self got wierd XMLDataIOStyle object : $formatObj\n";

    }

  }

}

sub _writeFormattedData {
   my ($self, $fileHandle, $parentArray, $readObj, 
       $fastAxisObj, $noDataValRef ) = @_;
 
   my $locator = $parentArray->createLocator();

   my @noDataValues = @{$noDataValRef};
   my $nrofNoDataValues = $#noDataValues;

   # print out the data as appropriate for the format
   my @commands = $readObj->getCommands(); # returns expanded list (no repeat cmds) 

   my $endian = $readObj->getEndian();
   my $nrofCommands = $#commands;
   my $currentCommand = 0;

   # init important dataFormat information into arrays, this 
   # will help speed up long writes.
   my @dataFormat = $parentArray->getDataFormatList();
   my $nrofDataFormats = $#dataFormat;
   my $currentDataFormat = 0;
   my @pattern;
   my @intFlag;
   my @numOfBytes;

   for (my $i = 0; $i <= $nrofDataFormats; $i++) {
      $pattern[$i] = $dataFormat[$i]->_templateNotation(0);

      $numOfBytes[$i] = $dataFormat[$i]->numOfBytes();
      if (ref($dataFormat[$i]) eq 'XDF::IntegerDataFormat')
      {
         $intFlag[$i] = $dataFormat[$i]->getType();
      } else { 
         $intFlag[$i] = undef;
      }
   }

   # loop thru all of the dataCube until finished with all data and commands 
   my $atEndOfDataCube = 0;
   my $backToStartOfDataCube = 0;
   while (!$backToStartOfDataCube)
   {

      my $command = $commands[$currentCommand];

      if($atEndOfDataCube && $locator->getAxisIndex($fastAxisObj) == 0)
      {
          $backToStartOfDataCube = 1;
      }

      if (ref($command) eq 'XDF::ReadCellFormattedIOCmd')
      {

          if ($backToStartOfDataCube) { last; } # dont bother, we'd be re-printing data 

          my $datum = $self->getData($locator);
          if (defined $datum) {
              &_doReadCellFormattedIOCmdOutput( $fileHandle,
                                           $dataFormat[$currentDataFormat],
                                           $numOfBytes[$currentDataFormat],
                                           $pattern[$currentDataFormat],
                                           $endian,
                                           $intFlag[$currentDataFormat],
                                           $datum);

          } else {

              # no data here, hurm. Print the noDataValue. 
              # sloppy algorithm as a result of clean up after Kelly 
              my $noData;

              if ($nrofNoDataValues > 1)
              {
                 $noData = $noDataValues[$locator->getAxisIndex($fastAxisObj)];
              } else {
                 $noData = $noDataValues[0];
              }

              if (defined $noData) {
                 print $fileHandle $noData;
              } else {
                 warn "Can't print out null data: noDataValue NOT defined.\n";
              }

          }

          # advance the data location 
          $locator->next();

          # advance the DataFormat to be used  
          if ($nrofDataFormats > 0)
          {
             $currentDataFormat++;
             if ( $currentDataFormat > $nrofDataFormats)
             {
                      $currentDataFormat = 0;
             }
          }

       }
       elsif (ref($command) eq 'XDF::SkipCharFormattedIOCmd')
       {

          &_doSkipCharFormattedIOCmdOutput ( $fileHandle, $command);

       }
       else
       {
          carp("DataCube cannot write out, unimplemented format command:$command\n");
       }

       if($nrofCommands > 0)
       {
          $currentCommand++;
          if ( $currentCommand > $nrofCommands) {
              $currentCommand = 0;
          }
       }

       if(!$atEndOfDataCube && !$locator->hasNext()) { $atEndOfDataCube = 1; } 


   } # end of while loop 

}

sub _doSkipCharFormattedIOCmdOutput 
{
   my ($fileHandle, $skipCharCommand) = @_;
   print $fileHandle $skipCharCommand->getOutput();
}

sub _doReadCellFormattedIOCmdOutput {
   my ($fileHandle, $thisDataFormat, $formatsize, $template, $endian, $intFlagType, $datum) = @_;

   my $output;
#   my $template = $thisDataFormat->_templateNotation(0);

   if (ref($thisDataFormat) eq 'XDF::StringDataFormat'
        || ref($thisDataFormat) eq 'XDF::FloatDataFormat'
      )
   {
      $output = pack $template, $datum;
   }
   elsif (ref($thisDataFormat) eq 'XDF::IntegerDataFormat') 
   {
     $output = pack $template, $datum;
      if (defined $intFlagType) {
         if ($intFlagType eq XDF::Constants::INTEGER_TYPE_OCTAL) {
            warn "Cant write OCTAL integers yet, aborting cell write";
            return;
         } elsif ($intFlagType eq XDF::Constants::INTEGER_TYPE_HEX) {
            warn "Cant write HEX integers yet, aborting cell write";
            return;
         }
      }
   }
   elsif (ref($thisDataFormat) eq 'XDF::BinaryIntegerDataFormat') 
   {

      $output = $thisDataFormat->convertIntegerToIntegerBits($datum, $endian);

   } 
   elsif (ref($thisDataFormat) eq 'XDF::BinaryFloatDataFormat') 
   {

      $output = $thisDataFormat->convertFloatToFloatBits($datum, $endian);

   } 
   else
   {
      # a failure to communicate :)
      carp("Unknown Dataformat:".ref($thisDataFormat).
           " is not implemented for formatted writes. Aborting.");
      exit(-1);
   }

   # if we have some output, write it
   if (defined $output) {

      # pad with leading spaces
      my $actualsize = length($output);
      while ($actualsize < $formatsize)
      {
         print $fileHandle " ";
         $actualsize++;
      }

      # now write the data out
      print $fileHandle $output;

   } else {
      # throw error
      carp("doReadCell got NO data\n");
   }

}

sub _print_data {
  my ($self, $fileHandle, $locator, $startTag, $endTag, $emptyTag) = @_;

  my $datum = $self->getData($locator);
  if (defined $datum) {
     print $fileHandle $startTag . $datum . $endTag;
  } else {
     print $fileHandle $emptyTag;
  }
}

# private method
sub _build_locator_string {
  my ($parentArray, $locator) = @_;

  my $string = '$self->{_data}';
  foreach my $axisObj (@{$parentArray->getAxisList()}) {
    $string = $string . "->[" . $locator->getAxisIndex($axisObj) . "]";
  }
  return $string;
} 

# Modification History
#
# $Log$
# Revision 1.13  2001/03/13 16:13:20  thomas
# made writeDataToFileHandle public method.
#
# Revision 1.12  2001/03/12 17:27:48  thomas
# Removed unneeded debugging line.
#
# Revision 1.11  2001/03/09 23:07:06  thomas
# Implemented binary data writting under XDF standard
# (non-native float writing now supported). Made
# some calls to the Constant Class rather than
# IntegerDataFormat. Fixed bug in while loop of
# writeFormattedData subroutine.
#
# Revision 1.10  2001/03/09 22:05:31  thomas
# added get/set methods for encoding attribute.
# added Utility check for compression attribute
# value.
#
# Revision 1.9  2001/03/07 23:13:27  thomas
# added binary writing code from the Java package. Not complete yet
# however.
#
# Revision 1.8  2001/03/01 21:10:44  thomas
# remove extrantaneous error reporting.
#
# Revision 1.7  2001/02/22 19:38:17  thomas
# Changed axisLocation calls to axisIndex.
#
# Revision 1.6  2000/12/15 22:11:58  thomas
# Regenerated perlDoc section in files. -b.t.
#
# Revision 1.5  2000/12/14 22:11:25  thomas
# Big changes to the API. get/set methods, added Href/Entity stuff, deep cloning,
# added Href, Notes, NotesLocationOrder nodes/classes. Ripped out _enlarge_array
# from DataCube (not needed) and fixed problems outputing delimited/formatted
# read nodes. -b.t.
#
# Revision 1.4  2000/12/01 20:03:37  thomas
# Brought Pod docmentation up to date. Bumped up version
# number. -b.t.
#
# Revision 1.3  2000/10/16 18:32:22  thomas
# Added in checksum attribute. (Opps!)
#
# Revision 1.2  2000/10/16 17:37:20  thomas
# Changed over to BaseObject Class from Object Class.
# Added in History Modification section.
#
#
#

1;


__END__

=head1 NAME

XDF::DataCube - Perl Class for DataCube

=head1 SYNOPSIS

    my $dataObj = XDF::DataCube->new();


...

=head1 DESCRIPTION

 Holds the data for a given L<XDF::Array>. It is designed to flexibly expand as data  is added/appended onto it. It doesnt treat swaping of large array data out to file currently. 

XDF::DataCube inherits class and attribute methods of L<XDF::GenericObject>, L<XDF::BaseObject>.


=over 4

=head2 CLASS Methods

A change in the value of these class attributes will change the value for ALL instances of XDF::DataCube.

=over 4

=item classXMLNodeName (EMPTY)

This method takes no arguments may not be changed. This method returns the class node name of XDF::DataCube.  

=item classAttributes (EMPTY)

This method returns a list reference containing the namesof the class attributes of XDF::DataCube; This method takes no arguments may not be changed.  

=back

=head2 ATTRIBUTE Methods

These methods set the requested attribute if an argument is supplied to the method. Whether or not an argument is supplied the current value of the attribute is always returned. Values of these methods are always SCALAR (may be number, string, or reference).

=over 4

=item dimension

The number of dimensions within this dataCube.  

=item maxDimensionIndex

The maximum index value along each dimension (Axis). Returns an ARRAY of SCALARS (non-negative INTEGERS).  

=back

=head2 OTHER Methods

=over 4

=item getChecksum (EMPTY)



=item setChecksum ($value)

Set the checksum attribute. 

=item getHref (EMPTY)



=item setHref ($hrefObjectRef)

Set the href attribute. 

=item getCompression (EMPTY)



=item setCompression ($value)

Set the compression attribute. 

=item getDimension (EMPTY)



=item getXMLAttributes (EMPTY)

This method returns the XMLAttributes of this class. 

=item toXMLFileHandle ($newNodeNameString, $indent, $junk, $fileHandle)

We overwrite the toXMLFileHandle method supplied by L<XDF::BaseObject> to have some special handling for the XDF::DataCube. The interface for thismethod remains the same however. 

=item addData ($no_append, $data, $locator)

This routine will append data to a cell unless directed to do otherwise. 

=item removeData (EMPTY)

Data held within the requested datacell is removed. The value of the datacell is set to undef. B<NOT CURRENTLY IMPLEMENTED>. 

=item setData ($datum, $locator)

Set the SCALAR value of the requested datacell at indicated location (see LOCATOR REF section). Overwrites existing datacell value if any. 

=item getData ($locator)

Retrieve the SCALAR value of the requested datacell. 

=back

=over 4

=head2 INHERITED Class Methods

A change in the value of these attributes will change the functioning of ALL instances of these objects that inherit from the indicated super class.


=over 4

The following class attribute methods are inherited from L<XDF::BaseObject>:
B<Pretty_XDF_Output>, B<Pretty_XDF_Output_Indentation>, B<DefaultDataArraySize>.

=back

=back

=over 4

=head2 INHERITED Other Methods



=over 4

XDF::DataCube inherits the following instance methods of L<XDF::GenericObject>:
B<new>, B<clone>, B<update>.

=back



=over 4

XDF::DataCube inherits the following instance methods of L<XDF::BaseObject>:
B<addToGroup>, B<removeFromGroup>, B<isGroupMember>, B<setXMLAttributes>, B<setXMLNotationHash>, B<toXMLFile>.

=back

=back

=head1 SEE ALSO

L< XDF::Array>, L<XDF::BaseObject>

=back

=head1 AUTHOR

    Brian Thomas  (thomas@adc.gsfc.nasa.gov)
    Astronomical Data Center <http://adc.gsfc.nasa.gov>
    NASA/Goddard Space Flight Center


=cut

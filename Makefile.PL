use ExtUtils::MakeMaker;

# /** COPYRIGHT
#    Makefile.PL Copyright (C) 2000 Brian Thomas,
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

# CVS $Id$

require 5.005;
use strict;

my $install_dir = 'XDF';
my $minimum_XML_Parser = 2.30;
my $minimum_XML_DOM = 1.36;
my @extras = ();

push(@extras,
     ABSTRACT_FROM => 'XDF.pm',
     AUTHOR        => 'Brian Thomas (thomas@adc.gsfc.nasa.gov)')
    if ($ExtUtils::MakeMaker::Version >= 5.4301);

# Check for non-standard modules that are used by this library.
$| = 1;
my $missing_modules = 0;

print "Checking for XML::Parser...........";
eval {
    require XML::Parser;
    my $ver = $XML::Parser::VERSION;
    $ver =~ s/_//;
    die "XML::Parser version $minimum_XML_Parser needed, installed module is only $XML::Parser::VERSION\n"
        unless $ver >= $minimum_XML_Parser;
};
if ($@) {
    print " failed\n";
    $missing_modules++;
    print <<EOT;
$@
The XML::Parser module must be installed.

EOT
    sleep(1);  # Don't hurry too much
} else {
    print " ok\n";
}

print "Checking for XML::Checker::Parser..";
eval {
    require XML::Checker::Parser;
};
if ($@) {
    print " missing, only non-validated parsing will be allowed.\n";
    $missing_modules++;
    sleep(1);  # Don't hurry too much
} else {
    print " ok\n";
}

print "Checking for XML::DOM..............";
eval {
    require XML::DOM;
    my $ver = $XML::DOM::VERSION;
    die "XML::DOM version $minimum_XML_DOM needed, installed module is only $XML::DOM::VERSION\n"
        unless $ver >= $minimum_XML_DOM;
};
if ($@) {
    print " missing, XDF::DOM and decendent classes may not be used.\n";
    $missing_modules++;
    sleep(1);  # Don't hurry too much
} else {
    print " ok\n";
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'XDF',
    'VERSION_FROM' => 'XDF/Constants.pm', # finds $VERSION
    dist      => { COMPRESS => 'gzip', SUFFIX => '.gz'},
    PREREQ_PM => { 'XML::Parser' => '2.27', },
    PM => { 
            'XDF/Array.pm'  => "\$(INST_LIBDIR)/$install_dir/Array.pm",
            'XDF/Axis.pm'       => "\$(INST_LIBDIR)/$install_dir/Axis.pm",
            'XDF/BaseObject.pm'     => "\$(INST_LIBDIR)/$install_dir/BaseObject.pm",
            'XDF/BaseObjectWithXMLElements.pm'     => "\$(INST_LIBDIR)/$install_dir/BaseObjectWithXMLElements.pm",
            'XDF/BaseObjectWithValueList.pm'     => "\$(INST_LIBDIR)/$install_dir/BaseObjectWithValueList.pm",
            'XDF/BaseObjectWithXMLElementsAndValueList.pm'     => "\$(INST_LIBDIR)/$install_dir/BaseObjectWithXMLElementsAndValueList.pm",
            'XDF/BinaryFloatDataFormat.pm'      => "\$(INST_LIBDIR)/$install_dir/BinaryFloatDataFormat.pm",
            'XDF/BinaryIntegerDataFormat.pm'      => "\$(INST_LIBDIR)/$install_dir/BinaryIntegerDataFormat.pm",
            'XDF/Chars.pm'      => "\$(INST_LIBDIR)/$install_dir/Chars.pm",
            'XDF/Constants.pm'      => "\$(INST_LIBDIR)/$install_dir/Constants.pm",
            'XDF/DataCube.pm'   => "\$(INST_LIBDIR)/$install_dir/DataCube.pm",
            'XDF/DataFormat.pm'       => "\$(INST_LIBDIR)/$install_dir/DataFormat.pm",
            'XDF/Delimiter.pm'      => "\$(INST_LIBDIR)/$install_dir/Delimiter.pm",
            'XDF/DelimitedXMLDataIOStyle.pm'       => "\$(INST_LIBDIR)/$install_dir/DelimitedXMLDataIOStyle.pm",
            'XDF/DocumentType.pm'      => "\$(INST_LIBDIR)/$install_dir/DocumentType.pm",
            'XDF/DOM.pm'       => "\$(INST_LIBDIR)/$install_dir/DOM.pm",
            'XDF/DOM/Document.pm'       => "\$(INST_LIBDIR)/$install_dir/DOM/Document.pm",
            'XDF/DOM/Element.pm'       => "\$(INST_LIBDIR)/$install_dir/DOM/Element.pm",
            'XDF/DOM/Parser.pm'       => "\$(INST_LIBDIR)/$install_dir/DOM/Parser.pm",
            'XDF/Entity.pm'      => "\$(INST_LIBDIR)/$install_dir/Entity.pm",
            'XDF/ErroredValue.pm'      => "\$(INST_LIBDIR)/$install_dir/ErroredValue.pm",
            'XDF/Field.pm'      => "\$(INST_LIBDIR)/$install_dir/Field.pm",
            'XDF/FieldAxis.pm'  => "\$(INST_LIBDIR)/$install_dir/FieldAxis.pm",
            'XDF/FieldGroup.pm'      => "\$(INST_LIBDIR)/$install_dir/FieldGroup.pm",
            'XDF/FieldRelation.pm'  => "\$(INST_LIBDIR)/$install_dir/FieldRelation.pm",
            'XDF/FloatDataFormat.pm'      => "\$(INST_LIBDIR)/$install_dir/FloatDataFormat.pm",
            'XDF/FormattedIOCmd.pm'      => "\$(INST_LIBDIR)/$install_dir/FormattedIOCmd.pm",
            'XDF/FormattedXMLDataIOStyle.pm'      => "\$(INST_LIBDIR)/$install_dir/FormattedXMLDataIOStyle.pm",
            'XDF/GenericObject.pm'     => "\$(INST_LIBDIR)/$install_dir/GenericObject.pm",
            'XDF/Group.pm'      => "\$(INST_LIBDIR)/$install_dir/Group.pm",
            'XDF/IntegerDataFormat.pm'      => "\$(INST_LIBDIR)/$install_dir/IntegerDataFormat.pm",
            'XDF/Locator.pm'       => "\$(INST_LIBDIR)/$install_dir/Locator.pm",
            'XDF/NewLine.pm'      => "\$(INST_LIBDIR)/$install_dir/NewLine.pm",
            'XDF/NotationNode.pm'      => "\$(INST_LIBDIR)/$install_dir/NotationNode.pm",
            'XDF/Note.pm'       => "\$(INST_LIBDIR)/$install_dir/Note.pm",
            'XDF/Notes.pm'       => "\$(INST_LIBDIR)/$install_dir/Notes.pm",
            'XDF/NotesLocationOrder.pm'       => "\$(INST_LIBDIR)/$install_dir/NotesLocationOrder.pm",
            'XDF/Parameter.pm'  => "\$(INST_LIBDIR)/$install_dir/Parameter.pm",
            'XDF/ParameterGroup.pm'  => "\$(INST_LIBDIR)/$install_dir/ParameterGroup.pm",
            'XDF/ReadCellFormattedIOCmd.pm'     => "\$(INST_LIBDIR)/$install_dir/ReadCellFormattedIOCmd.pm",
            'XDF/Reader.pm'     => "\$(INST_LIBDIR)/$install_dir/Reader.pm",
            'XDF/RecordTerminator.pm'      => "\$(INST_LIBDIR)/$install_dir/RecordTerminator.pm",
            'XDF/Reader/ValueList.pm'     => "\$(INST_LIBDIR)/$install_dir/Reader/ValueList.pm",
            'XDF/RepeatFormattedIOCmd.pm'     => "\$(INST_LIBDIR)/$install_dir/RepeatFormattedIOCmd.pm",
            'XDF/SkipCharFormattedIOCmd.pm'  => "\$(INST_LIBDIR)/$install_dir/SkipCharFormattedIOCmd.pm",
            'XDF/Specification.pm'      => "\$(INST_LIBDIR)/$install_dir/Specification.pm",
            'XDF/StringDataFormat.pm'      => "\$(INST_LIBDIR)/$install_dir/StringDataFormat.pm",
            'XDF/Structure.pm'  => "\$(INST_LIBDIR)/$install_dir/Structure.pm",
            'XDF/TaggedXMLDataIOStyle.pm'       => "\$(INST_LIBDIR)/$install_dir/TaggedXMLDataIOStyle.pm",
            'XDF/Unit.pm'       => "\$(INST_LIBDIR)/$install_dir/Unit.pm",
            'XDF/UnitDirection.pm'   => "\$(INST_LIBDIR)/$install_dir/UnitDirection.pm",
            'XDF/Units.pm'      => "\$(INST_LIBDIR)/$install_dir/Units.pm",
            'XDF/Utility.pm'      => "\$(INST_LIBDIR)/$install_dir/Utility.pm",
            'XDF/Value.pm'      => "\$(INST_LIBDIR)/$install_dir/Value.pm",
            'XDF/ValueGroup.pm'      => "\$(INST_LIBDIR)/$install_dir/ValueGroup.pm",
            'XDF/ValueListAlgorithm.pm'      => "\$(INST_LIBDIR)/$install_dir/ValueListAlgorithm.pm",
            'XDF/ValueListDelimitedList.pm'      => "\$(INST_LIBDIR)/$install_dir/ValueListDelimitedList.pm",
            'XDF/XMLDataIOStyle.pm'      => "\$(INST_LIBDIR)/$install_dir/XMLDataIOStyle.pm",
            'XDF/XMLDeclaration.pm'      => "\$(INST_LIBDIR)/$install_dir/XMLDeclaration.pm",
            'XDF/XMLElementNode.pm'      => "\$(INST_LIBDIR)/$install_dir/XMLElementNode.pm",
            'XDF/XDF.pm'      => "\$(INST_LIBDIR)/$install_dir/XDF.pm",
          },
    @extras

);


#!/usr/bin/perl -w -I ../

# a very simple viewer for XDF files.

# /** COPYRIGHT
#    guiview.pl Copyright (C) 2000 Brian Thomas,
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

# TODO
#
# = Need to edit Axis Unit Values, Array Unit Values

use Tk;
#use Tk::Pane;
#use Tk::TiedListbox;
#use Tk::DialogBox;
#use Tk::FileSelect;
#use XDF::Reader;

BEGIN {

  my $version = $Tk::VERSION;
  my $reqVersion = 800.015;

  die "Your version of Tk is $version, but $reqVersion is needed for $0" unless
      $version >= $reqVersion;

  my @modlist = qw ( 
                     Tk::HList
                     Tk::Pane
                     Tk::TiedListbox
                     Tk::NoteBook
                     Tk::Dialog
                     Tk::DialogBox
                     Tk::FileSelect
                     XDF::DOM::Parser
                     XDF::Specification
                   );
  for(@modlist) {
    die "Could'nt load $_ module, please correct Perl path or install.\n" unless (eval "require $_" );
  }

}

use vars qw/$STRUCTURE_IMAGE $PLAIN_ARRAY_IMAGE $FIELD_ARRAY_IMAGE $XML_ELEMENT_NODE_IMAGE/;

# pragmas
use strict;

# program defs
my $VERSION = "0.5";
my $TOOLNAME = "XDF Viewer Tool";

# GLOBAL Variables
#my $XDF;    # reference to the XDF object of interest
my $XML_FILE; 
my $XDF_DOM; # the parent document holding the XDF object
my $DISPLAY_SIZE = 'normal';
my %WIDGET; # hash table of GUI widget references
my %FRAME;  # hash table of GUI frame references
my @DATA_FRAMES; # the frames which are holding the data 
my $ListBoxSelectionStyle = 'browse';
my $MaxDisplayListBoxHeight = 10;
my @LABELS;
my @LISTBOXES;
my $CURRENT_LISTBOX;
my $ARRAY;
my $CURRENT_HORZ_AXIS;
my $CURRENT_VERT_AXIS;
my $LOCATOR;
my $PRETTY_XDF_OUTPUT = 1;
my $CONFIRM_OUTPUT_CLOBBER = 1;
my $ARRAY_OSTYLE = 'Tagged';
my $ARRAY_DATAFORMAT = 'String';
my $OPEN_ENTRY_WIDGET;
# parser parameters
my $XDF_PARSER_NO_EXPAND = 1;
my $XDF_PARSER_PARSE_PARAM_ENT = 0;
my $XDF_PARSER_EXPAND_PARAM_ENT = 1;

my %XMLDataIOStyle = ( 
                       'XDF::TaggedXMLDataIOStyle' => 'Tagged',
                       'XDF::DelimitedXMLDataIOStyle' => 'Delimited',
                       'XDF::FormattedXMLDataIOStyle' => 'FixedWidth',
                     );
my %XMLDataIOStyleClass = (
                       'Tagged' => 'XDF::TaggedXMLDataIOStyle',
                       'Delimited' => 'XDF::DelimitedXMLDataIOStyle',
                       'FixedWidth' => 'XDF::FormattedXMLDataIOStyle',
                     ); 

my %DataFormatStyle = ( 
                        'XDF::StringDataFormat' => 'String',
                        'XDF::IntegerDataFormat' => 'Integer',
                        'XDF::FloatDataFormat' => 'Float',
                        'XDF::BinaryIntegerDataFormat' => 'BinaryInteger',
                        'XDF::BinaryFloatDataFormat' => 'BinaryFloat',
                     );

my %DataFormatClass = (
                        'String' => 'XDF::StringDataFormat',
                        'Integer' => 'XDF::IntegerDataFormat',
                        'Float' => 'XDF::FloatDataFormat',
                        'BinaryInteger' => 'XDF::BinaryIntegerDataFormat',
                        'BinaryFloat' => 'XDF::BinaryFloatDataFormat',
                     );


my $CURRENT_STRUCTURE;
my $CURRENT_ITEM; # could be an array or structure that is selected from Hlist
my $ARRAY_ATTRIB_EDIT_OPEN = 0;
my $DATA_ATTRIB_EDIT_OPEN = 0;
my $STRUCT_ATTRIB_EDIT_OPEN = 0;
my %AXIS_ATTRIB_EDIT_OPEN;
my @XMLNODE_EDITFRAMES;
my @DATAEDITFRAMES;
my @ARRAYEDITFRAMES;
my @STRUCTEDITFRAMES;
my %AXISEDITFRAMES = ( 'vert' => [], 'horz' => []);
my @OSTYLE_SUBFRAMES;
my @DATAFORMAT_SUBFRAMES;
my @ArrayAttribList = qw ( Name Description ArrayId AppendTo );

# GLOBAL RunTIME Vars
my $DEBUG = 0;
my $QUIET = 1;

# Signal handling
$SIG{'HUP'} = "my_exit";
$SIG{'INT'} = "my_exit";
$SIG{'QUIT'} = "my_exit";

# GUI Config

# my wonderfull color defs
my ( $Red ,$Green, $Blue, $Lite_blue, $Yellow, $Dark_green, $Grey, $Dark_grey, $Medium_grey, $Lite_grey, $White, $Bright_white, $Black, $Purple) =
   ("#c24","#8e7","#50F",   "#7df"  , "#eea",  "#181"    ,"#bbb","#555"    ,"#888",   "#bbb",   "#eee", "#eee", "#000", "#a8a");

my %ListBoxBgColor = (
                        'XDF::StringDataFormat' => $Yellow,
                        'XDF::IntegerDataFormat' => $Green,
                        'XDF::FloatDataFormat' => $Lite_blue,
                        'XDF::BinaryIntegerDataFormat' => $Green,
                        'XDF::BinaryFloatDataFormat' => $Lite_blue,
                     );

my $AxisBoxColor = '#ee3';
my $FieldAxisBoxColor = '#3ee';
my $DataFrameColor = $White;
my $BaseColor = $Lite_grey;
my $XMLNodeColor = $Blue;
my $StructureColor = $Red;
my $ArrayColor = $Green;
my $DataColor = $Purple;
my $EventMouseOverColor = 'yellow';
my $ButtonFgColor = $Black;
my $ButtonBgColor = $White;
my $AddButtonBgColor = $Green;
my $ManButtonBgColor = $Lite_blue;
my $ClearButtonBgColor = $Yellow;
my $DeleteButtonBgColor = $Red;

my $StructAttributeTitle = 'Structure Attributes';
my $ArrayAttributeTitle = 'Array Attributes';
my $DataAttributeTitle = 'Data Attributes';
my $AxisWidgetBaseName = 'Axis_edit_boldlabel';

# Font defs'
my %Fixed_Font = ( 'tiny'   => '-adobe-fixed-medium-r-normal--12-*-*-*-*-*-iso8859-1', 
                   'small'  => '-adobe-fixed-medium-r-normal--14-*-*-*-*-*-iso8859-1',
                   'normal' => '-adobe-fixed-medium-r-normal--18-*-*-*-*-*-iso8859-1',
                   'large'  => '-adobe-fixed-medium-r-normal--24-*-*-*-*-*-iso8859-1'
                 );

my %Fixed_SmallFont = (  'tiny'   => '-adobe-fixed-medium-r-normal-*-10-*-*-*-*-*-iso8859-1',
                         'small'   => '-adobe-fixed-medium-r-normal-*-12-*-*-*-*-*-iso8859-1',
                         'normal'  => '-adobe-fixed-medium-r-normal-*-14-*-*-*-*-*-iso8859-1',
                         'large' => '-adobe-fixed-medium-r-normal-*-16-*-*-*-*-*-iso8859-1',
                      );

my %Fixed_BoldFont  = ( 'tiny'   => '-adobe-fixed-bold-r-normal--12-*-*-*-*-*-iso8859-1',
                        'small'  => '-adobe-fixed-bold-r-normal--14-*-*-*-*-*-iso8859-1',
                        'normal' => '-adobe-fixed-bold-r-normal--18-*-*-*-*-*-iso8859-1',
                        'large'  => '-adobe-fixed-bold-r-normal--24-*-*-*-*-*-iso8859-1'
                      );

my %Helvetica_Font = ( 'tiny'   => '-*-helvetica-medium-r-normal--12-*-*-*-*-*-iso8859-1',
                       'small'  => '-*-helvetica-medium-r-normal--14-*-*-*-*-*-iso8859-1',
                       'normal' => '-*-helvetica-medium-r-normal--18-*-*-*-*-*-iso8859-1',
                       'large'  => '-*-helvetica-medium-r-normal--24-*-*-*-*-*-iso8859-1'
                     );

my %Helvetica_SmallFont = (  'tiny'   => '-*-helvetica-medium-r-normal-*-10-*-*-*-*-*-iso8859-1',
                             'small'   => '-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-iso8859-1',
                             'normal'  => '-*-helvetica-medium-r-normal-*-14-*-*-*-*-*-iso8859-1',
                             'large' => '-*-helvetica-medium-r-normal-*-16-*-*-*-*-*-iso8859-1',
                          );

my %Helvetica_BoldFont  = ( 'tiny'   => '-*-helvetica-bold-r-normal--12-*-*-*-*-*-iso8859-1',
                            'small'  => '-*-helvetica-bold-r-normal--14-*-*-*-*-*-iso8859-1',
                            'normal' => '-*-helvetica-bold-r-normal--18-*-*-*-*-*-iso8859-1',
                            'large'  => '-*-helvetica-bold-r-normal--24-*-*-*-*-*-iso8859-1'
                          );

my %Times_Font = ( 'tiny'   => '-*-times-medium-r-normal--12-*-*-*-*-*-iso8859-1',
                       'small'  => '-*-times-medium-r-normal--14-*-*-*-*-*-iso8859-1',
                       'normal' => '-*-times-medium-r-normal--18-*-*-*-*-*-iso8859-1',
                       'large'  => '-*-times-medium-r-normal--24-*-*-*-*-*-iso8859-1'
                     );

my %Times_SmallFont = (  'tiny'   => '-*-times-medium-r-normal-*-10-*-*-*-*-*-iso8859-1',
                             'small'   => '-*-times-medium-r-normal-*-12-*-*-*-*-*-iso8859-1',
                             'normal'  => '-*-times-medium-r-normal-*-14-*-*-*-*-*-iso8859-1',
                             'large' => '-*-times-medium-r-normal-*-16-*-*-*-*-*-iso8859-1',
                          );

my %Times_BoldFont  = ( 'tiny'   => '-*-times-bold-r-normal--12-*-*-*-*-*-iso8859-1',
                            'small'  => '-*-times-bold-r-normal--14-*-*-*-*-*-iso8859-1',
                            'normal' => '-*-times-bold-r-normal--18-*-*-*-*-*-iso8859-1',
                            'large'  => '-*-times-bold-r-normal--24-*-*-*-*-*-iso8859-1'
                          );


# set up default fonts
my $FONT_STYLE = 'fixed';
my %Font = %Fixed_Font;
my %BoldFont = %Fixed_BoldFont;
my %SmallFont = %Fixed_SmallFont;

# B E G I N  P R O G R A M 

  &argv_loop();

  # init section
  &init_gui();
  &init_mouse_bindings();
  &init_key_bindings();

  &unshow_edit_frames();

  &load_xml_file($XML_FILE);

  &debug("running gui\n");

  # run Tk
  MainLoop;


# S U B R O U T I N E S 

sub init_mouse_bindings 
{ 
   &debug("init mouse bindings\n");
}

sub init_key_bindings 
{ 
    &debug("init key bindings\n");

    $WIDGET{'main'}->bind('<Control-Key-l>' => sub {
                                                      &load_xml_file(&select_file("Load which file?","*.xml")); 
                                                   });
    $WIDGET{'main'}->bind('<Control-Key-L>' => sub {
                                                      &load_xml_file(&select_file("Load which file?","*.xml")); 
                                                   });

    $WIDGET{'main'}->bind('<Control-Key-r>' => sub { &load_xml_file($XML_FILE); });
    $WIDGET{'main'}->bind('<Control-Key-R>' => sub { &load_xml_file($XML_FILE); });

    $WIDGET{'main'}->bind('<Control-Key-s>' => sub { &save_xdf_file($XML_FILE); });
    $WIDGET{'main'}->bind('<Control-Key-S>' => sub { &save_xdf_file($XML_FILE); });

    $WIDGET{'main'}->bind('<Control-Key-a>' => sub { &save_xdf_file(&select_file("Save as file?","*.xml")); }); 
    $WIDGET{'main'}->bind('<Control-Key-A>' => sub { &save_xdf_file(&select_file("Save as file?","*.xml")); }); 

    $WIDGET{'main'}->bind('<Control-Key-q>' => sub { &my_exit();} );
    $WIDGET{'main'}->bind('<Control-Key-Q>' => sub { &my_exit();} );

    $WIDGET{'main'}->bind('<Up>' => sub { &select_Hlist_item($WIDGET{'xml_hlist'}->selectionGet()); }); 
    $WIDGET{'main'}->bind('<Down>' => sub { &select_Hlist_item($WIDGET{'xml_hlist'}->selectionGet()); }); 

#    $WIDGET{'main'}->bind('<Control-Key-c>' => sub { &copy_SelectedItem_cmd(); } );
#    $WIDGET{'main'}->bind('<Control-Key-v>' => sub { &paste_SelectedItem_cmd(); } );
    $WIDGET{'main'}->bind('<Control-Key-x>' => sub { &cut_SelectedItem_cmd(); } );

}

sub argv_loop { 

  #&usage() unless ($#ARGV > -1);

  while ($_ = shift @ARGV) {
   #  print $_, "\n";
    if(/-h/) { &usage();
    } elsif(/-q/) { $QUIET = 1; 
    } elsif(/-v/) { $DEBUG = 1; 
    } else {
      $XML_FILE = $_;
    }
  }

}

sub usage {
   print STDOUT "Usage: $0 <filename> \n";
   &my_exit();
}

sub init_gui { 
  
  &debug("init gui\n");

  $WIDGET{'main'} = new MainWindow();
  $WIDGET{'main'}->configure ( title => "$TOOLNAME v$VERSION", bg => $Grey , height => 30, width => 80);

  # main Frames 
  my $menubarFrame = $WIDGET{'main'}->Frame->pack(side => 'top', fill => 'x');
  my $topFrame     = $WIDGET{'main'}->Frame->pack(expand => 0 , fill => 'both', side => 'top');
  my $leftFrame     = $WIDGET{'main'}->Frame->pack(expand => 0 , fill => 'both', side => 'left');
  my $rightFrame    = $WIDGET{'main'}->Frame->pack(expand => 1 , fill => 'both', side => 'right');

  my $infoFrame    = $rightFrame->Frame->pack(expand => 1 ,fill => 'both', side => 'top');

  my $listFrame = $leftFrame->Frame->pack(expand => 1, fill => 'both', side => 'top');
  #my $listButtonFrame = $leftFrame->Frame->pack(expand => 1, fill => 'both', side => 'bottom');
  my $listButtonFrame = $leftFrame->Frame->pack(expand => 1, fill => 'both', side => 'bottom');

  my $toolLabelFrame  = $topFrame->Frame->pack(side=> 'top', fill => 'both');
  my $fileNameFrame  = $topFrame->Frame->pack(side => 'top', fill => 'both');

  my $infoLabelFrame  = $infoFrame->Frame->pack(expand => 0, side => 'top', fill => 'x');

  my $xmlNodeHeaderFrame  = $infoFrame->Frame->pack(expand => 1, side => 'top', fill => 'both');
  my $xmlNodeAttribEditFrame  = $xmlNodeHeaderFrame->Frame->pack(side => 'bottom', fill => 'both');

  my $structureFrame  = $infoFrame->Frame->pack(expand => 1, side => 'top', fill => 'both');
  my $structureAttribEditFrame  = $structureFrame->Frame->pack(side => 'top', fill => 'both');
  my $structDataFrame = $structureFrame->Frame->pack(expand => 1, fill => 'both', );

  my $arrayHeaderFrame  = $infoFrame->Frame->pack(expand => 1, side => 'top', fill => 'both');
  my $arrayAttribEditFrame  = $arrayHeaderFrame->Frame->pack(side => 'top', fill => 'both');
  my $arrayDataFrame = $infoFrame->Frame->pack(expand => 1, fill => 'both' );

  $FRAME{'xmlNodeHeader'} = $xmlNodeHeaderFrame;
  $FRAME{'xmlNodeAttribEdit'} = $xmlNodeAttribEditFrame;
  $FRAME{'structHeader'} = $structureFrame;
  $FRAME{'arrayHeader'} = $arrayHeaderFrame;
  $FRAME{'structData'} = $structDataFrame;
  $FRAME{'arrayData'} = $arrayDataFrame;

  # configure frames
  $menubarFrame->configure( relief => 'raised', bd => 2, bg => $BaseColor);
  $topFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $listButtonFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $leftFrame ->configure ( relief => 'flat', bd => 2, bg => $Black);
  $infoFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $toolLabelFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $arrayHeaderFrame ->configure ( relief => 'flat', bd => 2, bg => $ArrayColor);
  $arrayAttribEditFrame->configure ( relief => 'flat', bd => 2, bg => $BaseColor);
  $structureAttribEditFrame ->configure ( relief => 'flat', bd => 2, bg => $StructureColor);
#  $xmlNodeHeaderFrame ->configure ( relief => 'flat', bd => 2, bg => $XMLNodeColor);
  $xmlNodeAttribEditFrame ->configure ( relief => 'flat', bd => 2, bg => $Black);
  $fileNameFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $structDataFrame->configure( relief => 'flat', bd => 2, bg => $Black);
  $arrayDataFrame->configure( relief => 'flat', bd => 2, bg => $Black);

  # Widgets
  # menuBar Frame Widgets
  &create_menus($menubarFrame);

  $WIDGET{'ylist_scroll'} = $listFrame->Scrollbar()->pack(side => 'left', expand => 0, fill => 'y');
  $WIDGET{'xlist_scroll'} = $listFrame->Scrollbar(-orient => 'horizontal')->pack(side => 'bottom', expand => 0, fill => 'x');

  $FIELD_ARRAY_IMAGE = $WIDGET{'main'}->Photo (-data => &field_array_image, -format => 'xpm');
  $PLAIN_ARRAY_IMAGE = $WIDGET{'main'}->Photo (-data => &array_image, -format => 'xpm');
  $STRUCTURE_IMAGE = $WIDGET{'main'}->Photo (-data => &structure_image(), -format => 'xpm');
  $XML_ELEMENT_NODE_IMAGE = $WIDGET{'main'}->Photo (-data => &open_xml_element_node_image(), 
                                                    -format => 'xpm');

  $WIDGET{'xml_hlist'} = $listFrame->HList(
                                            -separator => '/', 
                                            -width => 30,
                                            -itemtype => 'imagetext', 
                                            -font => $Font{$DISPLAY_SIZE},
                                          )->pack(fill => 'both', side=> 'top', expand => 0);

  $WIDGET{'xml_hlist'}->configure( -command => sub { &select_Hlist_item($_[0]); });
  $WIDGET{'xml_hlist'}->bind('<Button-1>' => sub { &select_Hlist_item($WIDGET{'xml_hlist'}->selectionGet()); });
  $WIDGET{'xml_hlist'}->bind('<Right>' => sub {
#                                       &show_Hlist_item_children($WIDGET{'xml_hlist'}->selectionGet());
                                           });
  $WIDGET{'xml_hlist'}->bind('<Left>' => sub {
#                                       &hide_Hlist_item_children($WIDGET{'xml_hlist'}->selectionGet());
                                           });


  &add_horizontal_scrollbar_to_widget($WIDGET{'xml_hlist'},$listFrame,'left',$WIDGET{'ylist_scroll'});
  &add_vertical_scrollbar_to_widget($WIDGET{'xml_hlist'},$listFrame,'bottom',$WIDGET{'xlist_scroll'});

  $WIDGET{'list_addXMLNode_button'} = $listButtonFrame->Button(
                                                         -text => 'Add Child XML Node',
                                                         -fg => $ButtonFgColor, -bg => $AddButtonBgColor,
                                                         -state => 'disabled',
                                                         -command => sub { &add_childXMLNode_toCurrentItem_cmd(); },
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                      )->pack(side => 'top'); 

  $WIDGET{'list_addStruct_button'} = $listButtonFrame->Button(
                                                         -text => 'Add Child Structure', 
                                                         -fg => $ButtonFgColor, -bg => $AddButtonBgColor,
                                                         -state => 'disabled', 
                                                         -command => sub { &add_Structure_toCurrentItem_cmd(); },
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                      )->pack(side => 'top'); # expand => 1, fill => 'y');
  $WIDGET{'list_addArray_button'} = $listButtonFrame->Button(
                                                         -text => 'Add Child Array', 
                                                         -fg => $ButtonFgColor, -bg => $AddButtonBgColor,
                                                         -state => 'disabled', 
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                         -command => sub { &add_Array_toCurrentItem_cmd(); },
                                                      )->pack(side => 'top'); # expand => 1, fill => 'y');

  $WIDGET{'list_separate_label'} = $listButtonFrame->Label( -text => ' ', -bg => $BaseColor,
                                                      )->pack( side => 'top', -ipady => 2);

  $WIDGET{'list_copySelect_button'} = $listButtonFrame->Button(
                                                         -text => 'Copy Selection (<Cntl-C>)',
                                                         -fg => $ButtonFgColor, -bg => $ManButtonBgColor,
                                                         -state => 'disabled',
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                         -command => sub { &null_cmd(); },
                                                      )->pack(side => 'top'); # expand => 1, fill => 'y');

  $WIDGET{'list_pasteSelect_button'} = $listButtonFrame->Button(
                                                         -text => 'Paste (<Cntl-V>)',
                                                         -fg => $ButtonFgColor, -bg => $ManButtonBgColor,
                                                         -state => 'disabled',
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                         -command => sub { &null_cmd(); },
                                                      )->pack(side => 'top'); # expand => 1, fill => 'y');

  $WIDGET{'list_cutSelect_button'} = $listButtonFrame->Button(
                                                         -text => 'Cut Selection (<Cntl-X>)',
                                                         -fg => $ButtonFgColor, -bg => $ManButtonBgColor,
                                                         -state => 'disabled',
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                         -command => sub { &cut_SelectedItem_cmd(); },
                                                      )->pack(side => 'top'); # expand => 1, fill => 'y');


  $WIDGET{'tool_boldlabel'} = $toolLabelFrame->Label( text => $TOOLNAME,
                                              bg => $BaseColor, fg => $Black,
                                              font => $BoldFont{$DISPLAY_SIZE},
                                             )->pack(fill => 'x', side=> 'top' );

  $WIDGET{'file_label'} = $fileNameFrame->Label( text => "File Name:",
                                                 bg => $BaseColor, fg => $Black,
                                                 font => $Font{$DISPLAY_SIZE},
                                               )->pack(fill => 'x', side=> 'left' );

  $WIDGET{'info_boldlabel'} = $infoLabelFrame->Label( text => "         Selected Node Properties          ",
                                                  bg => $BaseColor, fg => $Black,
                                                  bd => 2,
                                                  font => $BoldFont{$DISPLAY_SIZE},
                                                )->pack(fill => 'both', side=> 'top' );


  $WIDGET{'xmlNode_notebook_label'} = $xmlNodeAttribEditFrame->Label (
                                                  text => 'XML Element View/Edit',
                                              #    bg => $BaseColor, fg => $Black,
                                                  font => $Font{$DISPLAY_SIZE},
                                                  bd => 2,
                                                      )->pack(side => 'top', fill => 'both');

  $WIDGET{'xmlNode_notebook'} = $xmlNodeAttribEditFrame->NoteBook (-dynamicgeometry => 'false',
                                                        -bg => $BaseColor,
                                                        -font => $Font{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, fill => 'both');
  &configure_xmlNode_notebook($WIDGET{'xmlNode_notebook'});

  $WIDGET{'struct_attrib_edit_label'} = $structureAttribEditFrame->Label ( 
                                                 text => $StructAttributeTitle,
                                                   bg => $BaseColor, fg => $Black,
                                                   bd => 2,
                                                 font => $Font{$DISPLAY_SIZE},
                                                    )->pack(fill => 'both', side=> 'top' );
  &make_widget_highlight_on_mouseover($WIDGET{'struct_attrib_edit_label'});
  $WIDGET{'struct_attrib_edit_label'}->bind('<Double-Button-1>' => 
                                         sub { &edit_struct_attribs($structureFrame); });

  $WIDGET{'struct_edit_label'} = $structDataFrame->Label ( -text => 'Structure View/Edit Functions',
                                                      -font => $Font{$DISPLAY_SIZE},
                                               )->pack(fill => 'x', side=> 'top');

  $WIDGET{'struct_notebook'} = $structDataFrame->NoteBook( -dynamicgeometry => 'false',
                                                        -bg => $BaseColor,
                                                        -font => $Font{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, fill => 'both');
   &configure_struct_notebook($WIDGET{'struct_notebook'});


  $WIDGET{'array_attrib_edit_label'} = $arrayAttribEditFrame->Label( text => $ArrayAttributeTitle . ":[]",
                                                      bg => $BaseColor, fg => $Black,
                                                      bd => 2,
                                                      font => $Font{$DISPLAY_SIZE},
                                                    )->pack(fill => 'both', side=> 'top' );

  &make_widget_highlight_on_mouseover($WIDGET{'array_attrib_edit_label'});

  $WIDGET{'array_attrib_edit_label'}->bind('<Double-1>' => 
                                                   sub { &edit_array_attribs($arrayHeaderFrame); });

  $WIDGET{'array_edit_label'} = $arrayDataFrame->Label ( -text => 'Array View/Edit Functions', 
                                                      -font => $Font{$DISPLAY_SIZE},
                                               )->pack(fill => 'x', side=> 'top');

   $WIDGET{'array_notebook'} = $arrayDataFrame->NoteBook( -dynamicgeometry => 'false',
                                                        -bg => $BaseColor,
                                                        -font => $Font{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, fill => 'both');
   &configure_array_notebook($WIDGET{'array_notebook'});

}

sub configure_array_notebook {
   my ($widget) = @_;

   $widget->add( 'Data', -label => 'Data',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_dataview_gui(@_); },
               );

   $widget->add( 'DFmt', -label => 'DataFormat',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_array_dataformat_gui(@_); },
               );

   $widget->add( 'Note', -label => 'Notes',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_notelist_gui('Array', @_);},
               );

   $widget->add( 'Out', -label => 'XMLDataIOStyle',
                  -raisecmd => sub { },
                  -createcmd => sub { &init_array_outputstyle_gui(@_); },
               );

   $widget->add( 'Param', -label => 'Parameters',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_parameterlist_gui('Array', @_);},
               );

   $widget->add( 'Unit', -label => 'Units',
                  -raisecmd => sub { },
                  -createcmd => sub { &init_unitlist_gui('Array', @_);},
               );

}

sub configure_xmlNode_notebook {
   my ($widget) = @_;

   $widget->add( 'Attributes', -label => 'Attributes',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_xmlNodeAttrib_gui('xmlNode', @_);},
               );

   $widget->add( 'CDATA', -label => 'CDATA',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_xmlNodeCDATA_gui('xmlNode', @_);},
               );

}

sub configure_struct_notebook {
   my ($widget) = @_;

   $widget->add( 'Note', -label => 'Notes',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_notelist_gui('Struct', @_);},
               );

   $widget->add( 'Param', -label => 'Parameters',
                 -raisecmd => sub { },
                 -createcmd => sub { &init_parameterlist_gui('Struct', @_);},
               );

}

sub unshow_edit_frames {

   $FRAME{'xmlNodeHeader'}->packForget;
   $FRAME{'structHeader'}->packForget;
   $FRAME{'structData'}->packForget;
   $FRAME{'arrayHeader'}->packForget;
   $FRAME{'arrayData'}->packForget;

}

sub show_xmlnode_frames {
   my ($path) = @_;

   &unshow_edit_frames();

   $FRAME{'xmlNodeHeader'}->pack(side => 'top', fill => 'both'); 
   &edit_XMLNode_attribs ($path);

}

sub edit_XMLNode_attribs {
  my ( $path) = @_;

  &clear_xmlNode_attrib_edit();

   # tag name 
   my $subFrame = $FRAME{'xmlNodeHeader'}->Frame->pack(side => 'top', fill => 'both', expand => 0);
   my $labelname = 'xmlElementTag_label';
   my $entryname = 'xmlElementTag_val_label';
   my $getMethodRef = sub { $CURRENT_ITEM->getTagName; };
   my $setMethodRef = sub {
                              $CURRENT_ITEM->setTagName(@_);
                              $WIDGET{'xml_hlist'}->entryconfigure($path, -text => $_[0] );
                          };
   &make_label_click_widget( 'TAGNAME', $subFrame, $labelname, $entryname, $getMethodRef, $setMethodRef);
   push @XMLNODE_EDITFRAMES, $subFrame;

   my $masterFrame = $FRAME{'xmlNode_attribs'};#->Scrolled ( 'Frame', -scrollbars => 'se')->pack( side => 'top', expand => 1, fill => 'both');
#   push @XMLNODE_EDITFRAMES, $masterFrame;

   #populate attib tab
   my $attrib_numb = 0;
   my $getMethodRef2;
   my $setMethodRef2;
   foreach my $attrObj ($CURRENT_ITEM->getAttributes->getValues) {
      $subFrame = $masterFrame->Frame->pack(side => 'top', fill => 'both', expand => 0);
      push @XMLNODE_EDITFRAMES, $subFrame;
      $labelname = 'xmlElementAttr' . $attrib_numb . "_label";
      $entryname = 'xmlElementAttr' . $attrib_numb . "_val_label";
      $getMethodRef = sub { $attrObj->getName; };
      $setMethodRef = sub {  my ($name) = @_;
                             my $oldname = $attrObj->getName(); 
                             my $value = $attrObj->getValue(); 
                             $CURRENT_ITEM->removeAttribute($oldname);
                             $CURRENT_ITEM->setAttribute($name, $value);
       #                      &show_xmlnode_frames($path);
                          };
      $getMethodRef2 = sub { $attrObj->getValue; };
      $setMethodRef2 = sub { $attrObj->setValue(@_); };

      my $buttonName = 'xmlElementAttr' . $attrib_numb . "_button";
      $WIDGET{$buttonName} = $subFrame->Button( -text => 'Delete Attrib',
                                                -bg => $Red, -fg => $Black,
                                                -font => $Font{$DISPLAY_SIZE},
                                                -command => sub { &null_cmd; },
                                              )->pack(side => 'left');
  #    &make_label_click_widget( $attrObj->getName, $subFrame, $labelname, $entryname, $getMethodRef, $setMethodRef);
   #my ($text, $frame, $labelname, $entryname, $getRef, $setRef) = @_;

      &make_clickable_entrylabel($subFrame, $labelname, $getMethodRef, $setMethodRef);
      &make_clickable_entrylabel($subFrame, $entryname, $getMethodRef2, $setMethodRef2);
      $attrib_numb++;
   }

   # populate CDATA tab
   if (defined $FRAME{'xmlNode_CDATA'}) {
      &show_XMLNode_CDATA();
   }

}

sub show_XMLNode_CDATA {

   my $elementCDataFrame = $FRAME{'xmlNode_CDATA'}->Frame->pack(side => 'top', fill => 'both', expand => 0);
   push @XMLNODE_EDITFRAMES, $elementCDataFrame;
   my $setname = "xmlElementCdata_set_button";
   my $clearname = "xmlElementCdata_clear_button";
   my $entryname = "xmlElementCdata_val_label";
   my $getMethodRef = sub { &getTextData($CURRENT_ITEM); };
   my $setMethodRef = sub { &setTextData($CURRENT_ITEM, @_); };

   &make_textArea_click_widget( 'CDATA', $elementCDataFrame, $setname, $clearname, $entryname, $getMethodRef, $setMethodRef);

}

sub add_Structure_toCurrentItem_cmd {

   return unless $CURRENT_ITEM;

   my $newNode;
   if (ref($CURRENT_ITEM) =~ m/XDF::/) {

      $newNode = $CURRENT_ITEM->addStructure(new XDF::Structure());

   } elsif (ref($CURRENT_ITEM) =~ m/XML::/) {

      my $newXDF = new XDF::XDF();
      $newNode = $XDF_DOM->createXDFElement($newXDF);
      $CURRENT_ITEM->appendChild($newNode);

   }

   if (defined $newNode) { 
      &update_hlist_from_xdf($WIDGET{'xml_hlist'});
   }

}          

# not ready for prime time. What kind of array do we add? what 
# are its dimensions?? we should at least have a popup array 
# dialog to as for axis info, etc. 
sub add_Array_toCurrentItem_cmd {

   return unless $CURRENT_ITEM;

   my $newArray;
   if (ref($CURRENT_ITEM) =~ m/XDF::/) {

      $newArray= $CURRENT_ITEM->addArray(new XDF::Array());

      # OTHER config steps..
      # set output style to tagged
      $newArray->setXMLDataIOStyle(new XDF::TaggedXMLDataIOStyle());
        
      # add two generic axes
      $newArray->addAxis(new XDF::Axis({'axisId' => 'axis1'}));
      $newArray->addAxis(new XDF::Axis({'axisId' => 'axis2'}));

   }

   if (defined $newArray) { 
      &update_hlist_from_xdf($WIDGET{'xml_hlist'});
   }

}

sub add_childXMLNode_toCurrentItem_cmd {

   return unless defined $CURRENT_ITEM;

   my $newNode;
   if (ref($CURRENT_ITEM) =~ m/XDF::/) {
     # add an XDF internal node

      $newNode = new XDF::XMLElement('new_xml_node');
      $CURRENT_ITEM->addXMLElement($newNode);

   } elsif (ref($CURRENT_ITEM) =~ m/XML::/) {

      $newNode = $XDF_DOM->createElement('new_xml_node');
      $CURRENT_ITEM->appendChild($newNode);

   }

   if (defined $newNode) { 
      &update_hlist_from_xdf($WIDGET{'xml_hlist'});
   }
}

sub cut_SelectedItem_cmd {

   my $path = $WIDGET{'xml_hlist'}->selectionGet();
   return unless defined $path;

   my $item = $WIDGET{'xml_hlist'}->info('data', $path);
   my $parentPath = $WIDGET{'xml_hlist'}->info('parent', $path);
   my $parentItem = $WIDGET{'xml_hlist'}->info('data', $parentPath);

   return unless defined $item && defined $parentItem;
   $CURRENT_ITEM = $parentItem;

print STDERR "Delete item: $item Parent: $parentItem\n";

   if (ref($item) =~ m/XDF::/) {

   } elsif (ref($item) =~ m/XML::/) {

   }

   &update_view();
};

# some text nodes are just formating info,
# not terribly interesting for most of us.
# the default is to ignore formatting text
sub getTextData {
  my ($node, $ignore_format_text) = @_;

  $ignore_format_text = 0 unless defined $ignore_format_text;

  my $text = "";
  foreach my $child ($node->getChildNodes) {
    if ($child->getNodeTypeName eq 'TEXT_NODE') {
      my $child_text = $child->getNodeValue;
      $text .= $child->getNodeValue unless ($ignore_format_text && $child_text =~ m/^\s*$/);
    }
  }

  return $text;
}

sub setTextData {
  my ($node, $new_data) = @_;


  my $child = $node->getFirstChild();

  print STDERR "SET TEXT DATA ON NODE: $node (",$node->getNodeTypeName,") $child\n";

  # setting data by node type is not really needed, 
  # but we use our API this way and perhaps its cleaner implemntation (??).
  if (ref($node) eq 'XDF::XMLElement') { 
       $node->setCData($new_data);
  } else { 
     # its a regular XML::DOM Element or Text node
     if(defined $new_data) {
       if (ref($child) eq 'XML::DOM::Text') {
          $child->setData($new_data);
       } elsif (ref($child) eq 'XML::DOM::Element') {
          $child->addText($new_data);
       } else {
          print STDERR "ERROR: Program confused, and can't setTextData for node: ", ref($child), "\n";
       }
    }
  }
}

sub show_struct_frames {
   my ($pack) = @_;

   &unshow_edit_frames();
#   &show_xmlnode_frames();

   $FRAME{'structHeader'}->pack(expand => 1, side => 'top', fill => 'both'); 
   $FRAME{'structData'}->pack(expand => 1, fill => 'both', side => 'bottom');
   &edit_struct_attribs ($FRAME{'structHeader'});

}

sub show_array_frames {
   my ($pack) = @_;

 #  &show_struct_frames();
   &unshow_edit_frames();

   $FRAME{'arrayHeader'}->pack(side => 'top', fill => 'both'); 
   $FRAME{'arrayData'}->pack(expand => 1, fill => 'both', side => 'bottom'); 
}

sub delete_selected_structure {

   return unless $CURRENT_ITEM;
   # $CURRENT_ITEM->addStructure(new XDF::Structure());
}

sub make_widget_highlight_on_mouseover {
   my ($widget, $leaveColor) = @_;

   $leaveColor = $BaseColor unless defined $leaveColor;
  $widget->bind('<Enter>' => sub { $widget->configure(-bg => $EventMouseOverColor); });
  $widget->bind('<Leave>' => sub { $widget->configure(-bg => $leaveColor); });

}

sub make_widget_not_highlight_on_mouseover {
   my ($widget) = @_;

  $widget->bind('<Enter>' => sub { });
  $widget->bind('<Leave>' => sub { });
}

sub init_itemlist_gui {
   my ($what, $frame, $name, $addCodeRef) = @_;

   my $subFrame0 = $frame->Frame->pack(side => 'top');
   my $subFrame1 = $frame->Frame->pack(side => 'top', expand => 1, fill => 'both');
   my $subFrame2 = $frame->Frame->pack(side => 'top');

   my $labelname = $what . '_' . $name . 'list_label';
   $WIDGET{$labelname} = $subFrame0->Label( -text => "\n$what $name List\n",
                                            -font => $Font{$DISPLAY_SIZE},
                                           )->pack();

   my $listboxname = $what . '_' . $name . 'list_listbox';
   $WIDGET{$listboxname} = $subFrame1->Scrolled ( 'Listbox', -scrollbars => 'se', 
                                           )->pack( side => 'top', expand => 1, fill => 'both');
   $WIDGET{$listboxname}->configure ( -font => $Font{$DISPLAY_SIZE}, ); 
                                     #      )->pack( side => 'top', expand => 1, fill => 'both');

   my $addbuttonname = $what . '_add' . $name . '_button';
   $WIDGET{$addbuttonname} = $subFrame2->Button (
                                            -text => "Add $name",
                                            -font => $Font{$DISPLAY_SIZE},
                                            -command => sub { &$addCodeRef; },
                                            -bg => $AddButtonBgColor, -fg => $Black,
                                           )->pack( side => 'left');
}

sub init_unitlist_gui {
   my ($what, $frame) = @_;
   &init_itemlist_gui($what, $frame, 'Unit', \&null_cmd);
}

sub reset_array_unitlist_view {
   $WIDGET{'Array_Unitlist_listbox'}->delete(0,'end');
}

sub update_array_unitlist_view {

   return unless defined $WIDGET{'Array_Unitlist_listbox'};
   &reset_array_unitlist_view();

#   return unless ($CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/);

   my $listbox = $WIDGET{'Array_Unitlist_listbox'};

   foreach my $unitObj (@{$ARRAY->getUnits()->getUnitList()}) {
       my $name = 'Unit:';
       $name .= $unitObj->getValue() if defined $unitObj->getValue();
       $name .= ':';
       $name .= $unitObj->getPower() if defined $unitObj->getPower();
       $listbox->insert('end', $name);
   }

}

sub init_xmlNodeAttrib_gui {
   my ($what, $frame) = @_;

   my $name = 'XMLNode_Attribs';

   my $subFrame1 = $frame->Frame->pack(side => 'top', expand => 1, fill => 'both');
   my $subFrame2 = $frame->Frame->pack(side => 'top');

   $FRAME{'xmlNode_attribs'} = $subFrame1;

   my $addbuttonname = $what . '_add' . $name . '_button';
   $WIDGET{$addbuttonname} = $subFrame2->Button (
                                            -text => "Add Attribute",
                                            -font => $Font{$DISPLAY_SIZE},
                                            -command => sub { 
                                                               $CURRENT_ITEM->setAttribute("new", " "); 
                                                               &show_xmlnode_frames($WIDGET{'xml_hlist'}->selectionGet());
                                                            },
                                            -bg => $AddButtonBgColor, -fg => $Black,
                                           )->pack( side => 'left');

}

sub init_xmlNodeCDATA_gui {
   my ($what, $frame) = @_;

   my $name = 'XMLNode_CDATA';
   my $subFrame1 = $frame->Frame->pack(side => 'top', expand => 1, fill => 'both');

   $FRAME{'xmlNode_CDATA'} = $subFrame1;
   &show_XMLNode_CDATA(); # populate 
}

sub init_notelist_gui {
   my ($what, $frame) = @_;
   &init_itemlist_gui($what, $frame, 'Note', \&null_cmd);
}

sub reset_array_notelist_view {
   $WIDGET{'Array_Notelist_listbox'}->delete(0,'end');
}

sub update_array_notelist_view {

   return unless defined $WIDGET{'Array_Notelist_listbox'};
   &reset_array_notelist_view();
#   return unless ($CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/);

   my $listbox = $WIDGET{'Array_Notelist_listbox'};

   foreach my $noteObj (@{$ARRAY->getNoteList()}) {
       my $name = 'Note:';
       $name .= $noteObj->getNoteId() if defined $noteObj->getNoteId();
       $name .= ':';
       $name .= $noteObj->getValue() if defined $noteObj->getValue();
       $listbox->insert('end', $name);
   }

}

sub init_parameterlist_gui {
   my ($what, $frame) = @_;
   &init_itemlist_gui($what, $frame, 'Parameter', \&null_cmd);
}

sub reset_array_parameterlist_view {
   $WIDGET{'Array_Parameterlist_listbox'}->delete(0,'end');
}

sub update_array_parameterlist_view {

   return unless defined $WIDGET{'Array_Parameterlist_listbox'};
   &reset_array_parameterlist_view();
#   return unless ($CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/); 

   my $listbox = $WIDGET{'Array_Parameterlist_listbox'};

   foreach my $paramObj (@{$ARRAY->getParamList()}) {
       my $name = 'Parameter:';
       $name .= $paramObj->getName() if defined $paramObj->getName();
       $listbox->insert('end', $name);
   }

}

sub init_array_dataformat_gui {
   my ($frame) = @_;

   $frame->configure( -bg => $BaseColor );
   my $subFrame0 = $frame->Frame->pack(side => 'top'); 
   my $subFrame1 = $frame->Frame->pack(side => 'top'); 
   my $subFrame2 = $frame->Frame->pack(side => 'top'); 
   $FRAME{'dataformat_edit'} = $frame->Frame->pack(side => 'top');

   $WIDGET{'dataformat_filler1_label'} = $subFrame0->Label( -text => " ",
                                                        -font => $Font{$DISPLAY_SIZE},
                                                        -bg => $BaseColor,
                                                      )->pack();

   $WIDGET{'dataformat_label'} = $subFrame1->Label( -text => " Array DataFormat: ",
                                                -font => $Font{$DISPLAY_SIZE},
                                                -bg => $BaseColor,
                                             )->pack(side => 'left', expand => 0, fill => 'both');

   $WIDGET{'dataformat_browse_optionmenu'} = $subFrame1->Optionmenu (
                                                    -width => 12,
                                                    -font => $Font{$DISPLAY_SIZE},
                                                    -bg => $BaseColor,
                                                    -variable => \$ARRAY_DATAFORMAT,
                                                    -activebackground => $EventMouseOverColor,
                                                    -command => sub { &change_array_dataformat(); },
                                               )->pack(side=> 'left', expand => 0);
   my @options;
   while (my ($key, $value) = each (%DataFormatStyle) ) {
      push @options, $value;
   }
   $WIDGET{'dataformat_browse_optionmenu'}->addOptions(@options);

   $WIDGET{'dataformat_filler2_label'} = $subFrame2->Label( -text => " ",
                                                        -font => $Font{$DISPLAY_SIZE},
                                                        -bg => $BaseColor,
                                                      )->pack();

   &update_dataformat_view();


}

sub reset_dataformat_view {
   while ((my $frame = pop @DATAFORMAT_SUBFRAMES)) { $frame->destroy(); }
}

sub update_dataformat_view {

#   return unless defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/;
   return unless defined $FRAME{'dataformat_edit'};

   &reset_dataformat_view();

   my $attribEditFrame = $FRAME{'dataformat_edit'}->Frame->pack(side => 'top', fill => 'both');
   $attribEditFrame->configure( bg => $BaseColor);

   push @DATAFORMAT_SUBFRAMES, $attribEditFrame;

   my $titleFrame1 = $attribEditFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');
   my $subFrame1 = $attribEditFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');

   $WIDGET{'dataformat_attrib_label'} = $titleFrame1->Label (
                                                    -text => 'Attributes',
                                                    -font => $Font{$DISPLAY_SIZE},
                                                    -bg => $White,
                                                 )->pack(side => 'top', expand => 0, fill => 'both');

   #for (@{$ARRAY->getDataFormat->getXMLAttributes()}) {
   my $formatObj = $ARRAY->getDataFormat;
   for (@{$formatObj->getXMLAttributes()}) {
       my $subFrame = $subFrame1->Frame->pack(side => 'top', fill => 'both', expand => 0);
       my $labelname = 'dataformat' . $_ . "_label";
       my $entryname = 'dataformat' . $_ . "_val_label";
       my $methodname = 'get' . ucfirst ($_);
       my $getMethod = 'get' . ucfirst $_;
       my $setMethod = 'set' . ucfirst $_;
       #my $getMethodRef = sub { $ARRAY->getDataFormat->$getMethod; };
       #my $setMethodRef = sub { $ARRAY->getDataFormat->$setMethod(@_); };
       my $getMethodRef = sub { $formatObj->$getMethod; };
       my $setMethodRef = sub { $formatObj->$setMethod(@_); };
       &make_label_click_widget( $_, $subFrame, $labelname, $entryname, $getMethodRef, $setMethodRef );
   }

}

sub init_array_outputstyle_gui {
   my ($frame) = @_;

   $frame->configure( -bg => $BaseColor );
   my $subFrame0 = $frame->Frame->pack(side => 'top');
   my $subFrame1 = $frame->Frame->pack(side => 'top');
   my $subFrame2 = $frame->Frame->pack(side => 'top');
   $FRAME{'ostyle_edit'} = $frame->Frame->pack(side => 'top');

   $WIDGET{'ostyle_filler1_label'} = $subFrame0->Label( -text => " ", 
                                                        -font => $Font{$DISPLAY_SIZE},
                                                        -bg => $BaseColor,
                                                      )->pack(); 

   $WIDGET{'ostyle_label'} = $subFrame1->Label( -text => " Output Style: ", 
                                                -font => $Font{$DISPLAY_SIZE},
                                                -bg => $BaseColor,
                                             )->pack(side => 'left', expand => 0, fill => 'both'); 

   $WIDGET{'ostyle_browse_optionmenu'} = $subFrame1->Optionmenu (
                                                    -width => 12,
                                                    -font => $Font{$DISPLAY_SIZE},
                                                    -bg => $BaseColor,
                                                    -variable => \$ARRAY_OSTYLE,
                                                    -activebackground => $EventMouseOverColor, 
                                                    -command => sub { &change_ostyle(); },
                                               )->pack(side=> 'left', expand => 0);
   my @options;
   while (my ($key, $value) = each (%XMLDataIOStyle) ) {
      push @options, $value;
   }
   $WIDGET{'ostyle_browse_optionmenu'}->addOptions(@options);

   $WIDGET{'ostyle_filler2_label'} = $subFrame2->Label( -text => " ",
                                                        -font => $Font{$DISPLAY_SIZE},
                                                        -bg => $BaseColor,
                                                      )->pack(); 

   &update_ostyle_view();

}

sub reset_ostyle_view {
   while ((my $frame = pop @OSTYLE_SUBFRAMES)) { $frame->destroy(); }
}

sub update_ostyle_view {

   return unless defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/; 
   return unless defined $FRAME{'ostyle_edit'};

   &reset_ostyle_view();

   my $genericFrame = $FRAME{'ostyle_edit'}->Frame->pack(side => 'top', fill => 'both');
   my $fillerFrame = $FRAME{'ostyle_edit'}->Frame->pack(side => 'top', fill => 'both');
   my $specificFrame = $FRAME{'ostyle_edit'}->Frame->pack(side => 'top', fill => 'both');
   $genericFrame->configure( bg => $BaseColor);
   $specificFrame->configure( bg => $BaseColor);

   push @OSTYLE_SUBFRAMES, $specificFrame;
   push @OSTYLE_SUBFRAMES, $fillerFrame;
   push @OSTYLE_SUBFRAMES, $genericFrame;

   my $titleFrame1 = $genericFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');
   my $subFrame1 = $genericFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');

   $WIDGET{'generic_ostyle_attrib_label'} = $titleFrame1->Label (
                                                    -text => 'Generic Attributes', 
                                                    -font => $Font{$DISPLAY_SIZE},
                                                    -bg => $White,
                                                 )->pack(side => 'top', expand => 0, fill => 'both');

   #for (@{XDF::XMLDataIOStyle->getXMLAttributes()}) {
   my $readObj = $CURRENT_ITEM->getXMLDataIOStyle();
   for (@{$readObj->getXMLAttributes()}) {
       my $subFrame = $subFrame1->Frame->pack(side => 'top', fill => 'both', expand => 0);
       my $labelname = 'dataIOstyle' . $_ . "_label";
       my $entryname = 'dateIOstyle' . $_ . "_val_label";
       my $getMethod = 'get' . ucfirst $_;
       my $setMethod = 'set' . ucfirst $_;
       #my $getMethodRef = sub { $ARRAY->getXMLDataIOStyle->$getMethod; };
       #my $setMethodRef = sub { $ARRAY->getXMLDataIOStyle->$setMethod(@_); };
       my $getMethodRef = sub { $readObj->$getMethod; };
       my $setMethodRef = sub { $readObj->$setMethod(@_); };

       &make_label_click_widget( $_, $subFrame, $labelname, $entryname, $getMethodRef, $setMethodRef );
   }

   $WIDGET{'filler1_ostyle_attrib_label'} = $fillerFrame->Label (
                                                    -text => ' ', 
                                                    -font => $Font{$DISPLAY_SIZE},
                                                    -bg => $BaseColor,
                                                 )->pack(side => 'top', expand => 0, fill => 'both');

   if ($ARRAY_OSTYLE eq 'Tagged') {

      my $titleFrame = $specificFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');
      my $subFrame = $specificFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');
 
      # a label
      $WIDGET{'ostyle_tagged_spec_attrib_label'} =  $titleFrame->Label ( 
                          -text => 'Tagged Style Attributes', 
                          -bg => $White, 
                          -font => $Font{$DISPLAY_SIZE},
                        )->pack(side => 'top', expand => 0, fill => 'both');

      for (@{$ARRAY->getAxisList()}) 
      {
         my $thisFrame = $subFrame->Frame->pack(side => 'top');
         my $axisId = $_->getAxisId();
         my $labelname = 'dataIOstyle' . $axisId . "tag_label";
         my $entryname = 'dataIOstyle' . $axisId . "tag_val_label";
         my $label = "Axis Tag ($axisId):";
         my $getMethodRef = sub { $ARRAY->getXMLDataIOStyle->getAxisTag($axisId); };
         my $setMethodRef = sub { $ARRAY->getXMLDataIOStyle->setAxisTag($axisId, @_); };

         &make_label_click_widget( $label, $thisFrame, $labelname, $entryname, $getMethodRef, $setMethodRef);
      }

   } elsif ($ARRAY_OSTYLE eq 'Delimited') {

      my $titleFrame = $specificFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');
      my $subFrame = $specificFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');


      # a label
      $WIDGET{'ostyle_tagged_spec_attrib_label'} =  $titleFrame->Label (
                          -text => 'Delimited Style Attributes',
                          -bg => $White, 
                          -font => $Font{$DISPLAY_SIZE},
                        )->pack(side => 'top', expand => 0, fill => 'both');

      for (qw (Delimiter Repeatable RecordTerminator)) 
      {
         my $thisFrame = $subFrame->Frame->pack(side => 'top', fill => 'both', expand => 0);
         my $labelname = 'Delimited_dataIOstyle_' . $_ . "_label";
         my $entryname = 'Delimited_dataIOstyle' . $_. "_val_label";
         my $getMethod = 'get' . ucfirst $_;
         my $setMethod = 'set' . ucfirst $_;
         my $getMethodRef = sub { $ARRAY->getXMLDataIOStyle->$getMethod; };
         my $setMethodRef = sub { $ARRAY->getXMLDataIOStyle->$setMethod(@_); };

         &make_label_click_widget( $_, $thisFrame, $labelname, $entryname, $getMethodRef, $setMethodRef);
      }


   } elsif ($ARRAY_OSTYLE eq 'FixedWidth') {

      my $titleFrame = $specificFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');
      my $subFrame = $specificFrame->Frame(bd => 2, -bg => $Blue)->pack(side => 'top');

      # a label
      $WIDGET{'ostyle_tagged_spec_attrib_label'} =  $titleFrame->Label (
                          -text => 'Fixed Style Attributes',
                          -bg => $BaseColor, 
                          -font => $Font{$DISPLAY_SIZE},
                        )->pack(side => 'top', expand => 0, fill => 'both');

   }


}

sub make_textArea_click_widget {
   my ($text, $frame, $clearname, $setname, $entryname, $getRef, $setRef) = @_;

   my $topframe = $frame->Frame->pack(side => 'top', expand => 1, fill => 'x');
   my $textframe = $frame->Frame->pack(side => 'top', expand => 1, fill => 'both');

   my $val = "";
   if (defined $getRef) {
      $val = &{$getRef};
      $val = "" unless defined $val;
   }

   $WIDGET{$clearname} = $topframe->Button (
                                                    -text => "Clear CDATA",
                                                    -font => $Font{$DISPLAY_SIZE},
                                                    -command => sub {
                                                                       &setTextData($CURRENT_ITEM, "");
                                             #                          &update_view();
                                                                       $WIDGET{$entryname}->configure('-state' => 'normal');
                                                                       $WIDGET{$entryname}->delete('0.0', 'end'); # hope this exists!! 
                                                                       $WIDGET{$entryname}->configure('-state' => 'disabled');
                                                                       $WIDGET{$setname}->configure(-state => 'disabled');
                                                                    },
                                                    -bg => $ClearButtonBgColor, -fg => $Black,
                                                )->pack( side => 'left');
   
   $WIDGET{$setname} = $topframe->Button (
                                                    -text => "Set CDATA",
                                                    -font => $Font{$DISPLAY_SIZE},
                                                    -state => 'disabled',
                                                    -command => sub { 
                                                                       my $data = $WIDGET{$entryname}->get('0.0', 'end');
                                                                       &setTextData($CURRENT_ITEM, $data) if defined $data;
                                                                       $WIDGET{$entryname}->configure('-state' => 'disabled');
                                                                       $WIDGET{$setname}->configure(-state => 'disabled');
                                                                    },
                                                    -bg => $ClearButtonBgColor, -fg => $Black,
                                                )->pack( side => 'left');
   

   $WIDGET{$entryname} = $textframe->Text(
                            -bg => $BaseColor,
                            -fg => $Black,
                            -font => $Font{$DISPLAY_SIZE},
                          )->pack(fill => 'both', expand => 1, side => 'left');

   my $yscrollbar = $textframe->Scrollbar(-command => ['yview', $WIDGET{$entryname}])->pack(side => 'right', fill =>'y');
   $WIDGET{$entryname}->configure(-yscrollcommand => ['set', $yscrollbar]);
   $WIDGET{$entryname . 'y_scroll'} = $yscrollbar;

   $WIDGET{$entryname}->insert('end', $val);
   $WIDGET{$entryname}->configure('-state' => 'disabled');
   

   $WIDGET{$entryname}->bind('<Enter>' => sub {
                                              if ($WIDGET{$entryname}->cget('-state') eq 'disabled') {
                                                 $WIDGET{$entryname}->configure( -bg => $EventMouseOverColor);
                                              }
                                         });

   $WIDGET{$entryname}->bind('<Leave>' => sub {
                                             $WIDGET{$entryname}->configure( -bg => $BaseColor);
#                                             $WIDGET{$entryname}->configure('-state' => 'disabled');
                                         });

   $WIDGET{$entryname}->bind('<Double-1>' => sub {
                                             $WIDGET{$entryname}->configure( -bg => $BaseColor);
                                             $WIDGET{$entryname}->configure('-state' => 'normal');
                                             $WIDGET{$setname}->configure(-state => 'normal');
                                             $WIDGET{$entryname}->focus;
                                         });




}

sub make_label_click_widget {
   my ($text, $frame, $labelname, $entryname, $getRef, $setRef) = @_;

   $WIDGET{$labelname} = $frame->Label( -text => $text . ': ',
                            bg => $BaseColor, fg => $Black,
                            -justify => 'left',
                            -font => $Font{$DISPLAY_SIZE},
                          )->pack(fill => 'x', side=> 'left' );

   &make_clickable_entrylabel($frame, $entryname, $getRef, $setRef, $WIDGET{$labelname});
}

sub make_clickable_entrylabel {
   my ($frame, $name, $getRef, $setRef, $labelWidget) = @_;

   my $val = "";
   if (defined $getRef) {
      $val = &{$getRef};
      $val = "" unless defined $val;
   }

   $WIDGET{$name} = $frame->Label( -text => $val,
                            -bg => $BaseColor, 
                            -fg => $Black,
                            -justify => 'right',
                            -font => $Font{$DISPLAY_SIZE},
                          )->pack(fill => 'x', side=> 'left', expand => 1 );

   # init mouse bindings
   $WIDGET{$name}->bind('<Enter>' => sub { 
                                            $WIDGET{$name}->configure( -bg => $EventMouseOverColor); 
                                            $labelWidget->configure( -bg => $EventMouseOverColor) if defined $labelWidget; 
                                         });
   $labelWidget->bind('<Enter>' => sub { 
                                            $WIDGET{$name}->configure( -bg => $EventMouseOverColor); 
                                            $labelWidget->configure( -bg => $EventMouseOverColor);
                                         }) if defined $labelWidget;

   $WIDGET{$name}->bind('<Leave>' => sub { 
                                             $WIDGET{$name}->configure( -bg => $BaseColor); 
                                             $labelWidget->configure( -bg => $BaseColor) if defined $labelWidget; 
                                         });
   $labelWidget->bind('<Leave>' => sub { 
                                             $WIDGET{$name}->configure( -bg => $BaseColor); 
                                             $labelWidget->configure( -bg => $BaseColor);
                                         }) if defined $labelWidget;

   $WIDGET{$name}->bind('<Double-1>' => sub { $WIDGET{$name}->destroy();
                                              &make_entry_blank($frame, $name, $val, $getRef, $setRef, $labelWidget);
                                            });

}

sub make_entry_blank {
   my ($frame, $widgetname, $val, $getRef, $setRef, $labelWidget) = @_;

   $OPEN_ENTRY_WIDGET->destroy() if ($OPEN_ENTRY_WIDGET);

   $WIDGET{$widgetname} = $frame->Entry( -font => $Font{$DISPLAY_SIZE},
                                       )->pack(fill => 'both');
   $WIDGET{$widgetname}->insert('end', $val);
   $WIDGET{$widgetname}->bind ('<Enter>' => sub { $WIDGET{$widgetname}->focus(); });

   if (defined $setRef) {
      $WIDGET{$widgetname}->bind('<Return>' => sub { 
                                                        my $value = $WIDGET{$widgetname}->get();
                                                        &$setRef($value);
                                                        $WIDGET{$widgetname}->destroy();
                                                        &make_clickable_entrylabel($frame, $widgetname, $getRef, $setRef, $labelWidget);
                                                        $OPEN_ENTRY_WIDGET = undef;
                                                   } );
   }

   $OPEN_ENTRY_WIDGET = $WIDGET{$widgetname};
}

# set up the widgets to show the view of the data node attribs, data
# and axis information
sub init_dataview_gui {
  my ($mainFrame) = @_;

  # frames
  my $attribFrame = $mainFrame->Frame->pack(expand => 0, fill => 'both', side => 'top');
  my $lowerFrame = $mainFrame->Frame->pack(expand => 1, fill => 'both', side => 'top');

  my $dataLabelFrame = $lowerFrame->Frame->pack(expand => 0, fill => 'both' );
  my $dataFrame = $lowerFrame->Frame->pack(expand => 1, fill => 'both', side => 'bottom');

  my $leftFrame = $dataFrame->Frame->pack(expand => 0, fill => 'both', side => 'left');
  my $rightFrame = $dataFrame->Frame->pack(expand => 1, fill => 'both', side => 'left');

  my $horzAxisInfoFrame = $rightFrame->Frame->pack(expand => 0, fill => 'both', side => 'top');
  my $bottomFrame = $rightFrame->Frame->pack(expand => 1, fill => 'both', side => 'bottom');

  my $xscrollFrame   = $bottomFrame->Frame->pack(expand => 0, side => 'bottom', fill => 'x');

  my $leftTopFrame = $leftFrame->Frame->pack(expand => 0, fill => 'both', side => 'top');
  my $leftBottomFrame = $leftFrame->Frame->pack(expand => 1, fill => 'both', side => 'bottom');
  my $vertAxisInfoFrame = $leftBottomFrame->Frame->pack(expand => 0, fill => 'y', side => 'left');
  $FRAME{'row_listbox'} = $leftBottomFrame->Frame->pack(expand => 0, fill => 'both', side => 'left');
  my $rightBottomFrame = $bottomFrame->Frame->pack(expand => 1, fill => 'both', side => 'right');
  my $yscrollFrame = $rightBottomFrame->Frame->pack(expand => 0, side => 'right', fill => 'y');
  my $tableFrame  = $rightBottomFrame->Frame->pack(expand => 1, side => 'top', fill => 'both');

  # these must be recorded so we know what to destroy
  # when the view changes
 # push @SHARED_SUBFRAMES, $horzAxisInfoFrame;
 # push @SHARED_SUBFRAMES, $bottomFrame;

  # configure frames
  $leftTopFrame->configure ( bg => $BaseColor, bd => 2);
  $horzAxisInfoFrame->configure ( relief => 'flat', bd => 2, bg => 'white');
  $bottomFrame->configure ( relief => 'flat', bd => 2, bg => $Black);
  $vertAxisInfoFrame->configure ( relief => 'flat', bd => 2, bg => 'white');
  $attribFrame->configure ( relief => 'flat', bd => 2, bg => $DataColor );
  $lowerFrame->configure ( relief => 'flat', bd => 4, );

  # widgets

  $WIDGET{'data_attrib_edit_label'} = $attribFrame->Label( text => $DataAttributeTitle,
                                                          font => $Font{$DISPLAY_SIZE},
                                                          bg => $BaseColor,
                                                        )->pack( expand => 0, fill => 'x');

  $WIDGET{'datatable_view_label'} = $dataLabelFrame->Label( text => 'Table View',
                                                            font => $Font{$DISPLAY_SIZE},
                                                            bg => $BaseColor,
                                                           )->pack( expand => 0, fill => 'x',);

  &make_widget_highlight_on_mouseover($WIDGET{'data_attrib_edit_label'});

  $WIDGET{'data_attrib_edit_label'}->bind('<Double-Button-1>' =>
                                                   sub { &edit_data_attribs($attribFrame); });


  my $hAxisLabel = 'horz' . $AxisWidgetBaseName;
  $WIDGET{$hAxisLabel} = $horzAxisInfoFrame->Label( text => '', 
                                                -font => $BoldFont{$DISPLAY_SIZE},
                                                bg => $AxisBoxColor,
                                             )->pack( expand => 1, fill => 'x');


   $WIDGET{$hAxisLabel}->bind('<Enter>' => sub { $WIDGET{$hAxisLabel}->configure( -bg => $EventMouseOverColor); } );
   $WIDGET{$hAxisLabel}->bind('<Leave>' => 
                                    sub { my $c = &get_horzAxisColor(); $WIDGET{$hAxisLabel}->configure(bg => $c); } );
   $WIDGET{$hAxisLabel}->bind('<Double-1>' => sub { &edit_axis_attribs($horzAxisInfoFrame, 0, 'horz'); } );

  my $listBoxFrame = $tableFrame->Pane( -sticky => 'nsew'
                                      )->pack( expand => 1, side => 'top', fill => 'both');

  $listBoxFrame->configure (relief => 'flat', bd => 2, bg => $Lite_grey); 

  my $vAxisLabel = 'vert' . $AxisWidgetBaseName;
  $WIDGET{$vAxisLabel} = $vertAxisInfoFrame->Label( text => '',
                                                -width => 2,
                                                -font => $BoldFont{$DISPLAY_SIZE},
                                                bg => $AxisBoxColor,
                                                #-orient => 'horizontal',
                                             )->pack( expand => 1, side => 'left', fill => 'y');
   $WIDGET{$vAxisLabel}->bind('<Enter>' => sub { $WIDGET{$vAxisLabel}->configure( -bg => $EventMouseOverColor); } );
   $WIDGET{$vAxisLabel}->bind('<Leave>' => sub { my $c = &get_vertAxisColor(); $WIDGET{$vAxisLabel}->configure(bg => $c); } );
   $WIDGET{$vAxisLabel}->bind('<Double-1>' => sub { &edit_axis_attribs($vertAxisInfoFrame, 1, 'vert'); } );

  # the 'row' listbox
  $FRAME{'row_listbox'}->configure ( relief => 'flat', bd => 4, bg => 'white'); 

  # some filler for the top right frame
  $WIDGET{'filler1_boldlabel'} = $leftTopFrame->Label( -text => ' ', -font => $BoldFont{$DISPLAY_SIZE},
                        -bg => $BaseColor,
                      )->pack(expand => 'no', side => 'top', fill => 'both' );
  $WIDGET{'filler1_boldlabel'}->configure ( relief => 'flat', bd => 4, ); 

  $WIDGET{'filler2_boldlabel'} = $leftTopFrame->Label( -text => ' ', -font => $BoldFont{$DISPLAY_SIZE},
                        -bg => $BaseColor,
                      )->pack(expand => 'no', side => 'top', fill => 'both');

  $WIDGET{'filler3_boldlabel'} = $leftTopFrame->Label( -text => ' ', -font => $BoldFont{$DISPLAY_SIZE},
                        -bg => $BaseColor,
                      )->pack( expand => 'no', side => 'top', fill => 'both');

  $WIDGET{'row_listbox'} = $FRAME{'row_listbox'}->Listbox( -width => 4,
                                                         -height => $MaxDisplayListBoxHeight,
                                                         -bg => $DataFrameColor, 
                                                         -selectforeground => 'black',
                                                         -selectbackground => 'yellow',
                                                         -exportselection => 1,
                                                         -selectmode => $ListBoxSelectionStyle,
                                                         -font => $Font{$DISPLAY_SIZE},
                                                       )->pack( expand => 'yes',
                                                                side => 'bottom', fill => 'both');

  $WIDGET{'y_scroll'} = $yscrollFrame->Scrollbar()->pack(side => 'right');
  $WIDGET{'x_scroll'} = $xscrollFrame->Scrollbar(-orient => 'horizontal')->pack(side => 'bottom', expand => 1, fill => 'x');
  &add_horizontal_scrollbar_to_widget($WIDGET{'row_listbox'},$FRAME{'row_listbox'},'right',$WIDGET{'y_scroll'});
  &add_vertical_scrollbar_to_widget($listBoxFrame, $tableFrame,'bottom',$WIDGET{'x_scroll'});

  $WIDGET{'row_listbox'}->bind('<Button-1>' => sub {
                                                     &unselect_all_listBoxes();
                                                     &select_all_listBox_index($WIDGET{'row_listbox'}->curselection());
                                                  });
  $WIDGET{'row_listbox'}->bind('<Control-Button-1>' => sub {
                                                     &select_all_listBox_index($WIDGET{'row_listbox'}->curselection());
                                                  });

  # collect up frames we need to remember  
  $FRAME{'table'} = $tableFrame;
  $FRAME{'listBox'} = $listBoxFrame;

}

sub get_horzAxisColor {

   my $color = $AxisBoxColor;
   if (ref($CURRENT_HORZ_AXIS) eq 'XDF::FieldAxis') {
       $color = $FieldAxisBoxColor;
   }

   return $color;
}

sub get_vertAxisColor {
   my $color = $AxisBoxColor;
   # for now, we never allow field axis on the vertical.
   return $color;
}

sub show_Hlist_item_children {
   my ($path) = @_;

   return unless defined $path;

   my $item = $WIDGET{'xml_hlist'}->info('data', $path);
   my $parentItem = $WIDGET{'xml_hlist'}->info('parent', $path);

   $WIDGET{'xml_hlist'}->showEntry($path); 
#print STDERR "Hide status: ",$WIDGET{'xml_hlist'}->entrycget($path, -hide), "\n"; 

}

sub hide_Hlist_item_children {
   my ($path) = @_;

   return unless defined $path;

print STDERR "HIDE PATH: $path\n";
#print STDERR "Hide status: ",$WIDGET{'xml_hlist'}->entrycget($path, -hide), "\n"; 

   my @path = split '/', $path;
   return if $#path < 1;

   my $item = $WIDGET{'xml_hlist'}->info('data', $path); 
   my $parentItem = $WIDGET{'xml_hlist'}->info('parent', $path);

   $CURRENT_ITEM = $parentItem;

   $WIDGET{'xml_hlist'}->selectionSet($parentItem); 
   $WIDGET{'xml_hlist'}->hideEntry($path); 

}

sub select_Hlist_item { 
   my ($path) = @_;

   return unless defined $path;

   my $item = $WIDGET{'xml_hlist'}->info('data', $path);
   $CURRENT_ITEM = $item; # make this the new current item 

#   print STDERR "Single click path=$path, data=",$item,"\n";

   if (ref($item) eq 'XDF::Array') {
     # seek thru the path to get the parent structure
     my $parentItem = $WIDGET{'xml_hlist'}->info('parent', $path);
     show_array_frames();
     if (defined $parentItem) {
       $CURRENT_STRUCTURE = $WIDGET{'xml_hlist'}->info('data', $parentItem);
     } else {
        die "couldnt get parent structure for $item\n";
     }
   } elsif (ref($item) eq 'XDF::Structure' || ref($item) eq 'XDF::XDF' ) {
     $CURRENT_STRUCTURE = $item; # it is a structure 
     show_struct_frames();
   } else {
     show_xmlnode_frames($path); 
   }

   if ($CURRENT_ITEM =~ m/Array/) {
      $ARRAY_OSTYLE = $XMLDataIOStyle{ref($CURRENT_ITEM->getXMLDataIOStyle)};
      if (!defined $CURRENT_ITEM->getFieldAxis) {
         $ARRAY_DATAFORMAT = $DataFormatStyle{ref($CURRENT_ITEM->getDataFormat)};
      } else {
         $ARRAY_DATAFORMAT = undef;
      }
   } else {
      $ARRAY_OSTYLE = undef;
      $ARRAY_DATAFORMAT = undef;
   }

   &update_view();

} 

sub update_view {

   &debug("update view\n");

   &configure_gui_view($CURRENT_ITEM);
   &update_header_view();
   &update_array_unitlist_view();
   &update_array_notelist_view();
   &update_array_parameterlist_view();
   &update_table_view();
   &update_ostyle_view();
   &update_dataformat_view();

   if ($ARRAY_ATTRIB_EDIT_OPEN) {
      &update_array_edit_attrib_val();
   }

   if ($STRUCT_ATTRIB_EDIT_OPEN) {
      &update_struct_edit_attrib_val();
   }
}

# change various button, lever, etc. spaces based on 
# what is being viewed.
sub configure_gui_view {
   my ($type) = @_;

   &debug("configure_gui_view\n");

   my @showArrayWidgets =  (
                                $WIDGET{'list_addXMLNode_button'}, 
                               # $WIDGET{'list_deleteThis_button'}, 
                                $WIDGET{'list_copySelect_button'}, 
                                $WIDGET{'list_pasteSelect_button'}, 
                                $WIDGET{'list_cutSelect_button'}, 
                           ); 

   my @showStructWidgets = (
                                $WIDGET{'list_addStruct_button'}, 
                                $WIDGET{'list_addArray_button'}, 
                                $WIDGET{'list_addXMLNode_button'}, 
                              #  $WIDGET{'list_deleteThis_button'}, 
                                $WIDGET{'list_copySelect_button'}, 
                                $WIDGET{'list_pasteSelect_button'}, 
                                $WIDGET{'list_cutSelect_button'}, 
                           ); 

   my @showExteriorXMLWidgets = (
                                $WIDGET{'list_addStruct_button'},
                                $WIDGET{'list_addXMLNode_button'}, 
                              #  $WIDGET{'list_deleteThis_button'}, 
                                $WIDGET{'list_copySelect_button'}, 
                                $WIDGET{'list_pasteSelect_button'}, 
                                $WIDGET{'list_cutSelect_button'}, 
                           );

   my @showInteriorXMLWidgets = (
                                $WIDGET{'list_addXMLNode_button'}, 
                              #  $WIDGET{'list_deleteThis_button'}, 
                                $WIDGET{'list_copySelect_button'}, 
                                $WIDGET{'list_pasteSelect_button'}, 
                                $WIDGET{'list_cutSelect_button'}, 
                           ); 

   if (defined $type && ref($type)) {
      if (ref($type) eq 'XDF::XMLElement') {
         for(@showStructWidgets) { $_->configure(-state => 'disabled'); }
         for(@showArrayWidgets) { $_->configure(-state => 'disabled'); }
         for(@showExteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
         for(@showInteriorXMLWidgets) { $_->configure(-state => 'normal'); }
      } elsif (ref($type) eq 'XML::DOM::Element') {
         for(@showStructWidgets) { $_->configure(-state => 'disabled'); }
         for(@showArrayWidgets) { $_->configure(-state => 'disabled'); }
         for(@showInteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
         for(@showExteriorXMLWidgets) { $_->configure(-state => 'normal'); }
      } elsif (ref($type) eq 'XDF::Array') {
         for(@showStructWidgets) { $_->configure(-state => 'disabled'); }
         for(@showInteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
         for(@showExteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
         for(@showArrayWidgets) { $_->configure(-state => 'normal'); }
      } else { 
         # its a structure
         for(@showArrayWidgets) { $_->configure(-state => 'disabled'); }
         for(@showInteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
         for(@showExteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
         for(@showStructWidgets) { $_->configure(-state => 'normal'); }
      }
   } else { 
      # its all disabled
      for(@showArrayWidgets) { $_->configure(-state => 'disabled'); }
      for(@showStructWidgets) { $_->configure(-state => 'disabled'); }
      for(@showExteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
      for(@showInteriorXMLWidgets) { $_->configure(-state => 'disabled'); }
   }

}

sub update_hlist_from_xdf {
   my ($widget) = @_;

   # clear widget entries
   $widget->delete('all');
   &show_XDF_DOM_in_Hlist($widget, $XDF_DOM) if defined $XDF_DOM;

}

sub show_XDF_DOM_in_Hlist {
  my ($widget, $xdf_dom ) = @_;

   my $first_node = $xdf_dom->getDocumentElement(); # get root element

   show_XDF_node_in_Hlist($widget, $first_node, $first_node);
}

sub show_XDF_node_in_Hlist {
   my ($widget, $node, $path) = @_;

   return unless ($node->getNodeTypeName eq 'ELEMENT_NODE');

   my $tagName = $node->getTagName;

   if (ref($node) eq 'XDF::DOM::Element') { 

     my $xdfObj = $node->getXDFObject();
     show_structure_in_Hlist($widget, $xdfObj, $path, 'XDF::Structure') if defined $xdfObj;

   } else {

      # print only element nodes, not text nodes
      show_XMLElement_in_Hlist($widget, $node, $path, $tagName);

   }
   

}

sub show_XMLElement_in_Hlist {
  my ($widget, $node, $path, $text) = @_;

      # its an ordinary XML Element node
      $widget->add($path, -text => $text,
                          -image => $XML_ELEMENT_NODE_IMAGE,
                          -data => $node);

      # print out the children
      for ($node->getChildNodes) {
         show_XDF_node_in_Hlist($widget, $_, "$path/$_");
      }

}

sub show_structure_in_Hlist {
  my ($widget, $structObj, $path, $text) = @_;

  $widget->add($path, -text => $text, 
                      -image => $STRUCTURE_IMAGE,
                      -data => $structObj);

  foreach my $node (@{$structObj->getXMLElementList()}) {
     next unless defined $node;
     my $name = $node->getNodeName;
     &show_XMLElement_in_Hlist($widget, $node, "$path/$node", $name);
  }

  foreach my $sObj (@{$structObj->getStructList()}) {
     #my $name = 'Structure:' . $sObj->getName();
     my $name = $sObj->getName();
     $name = "" unless defined $name;
     &show_structure_in_Hlist($widget, $sObj, "$path/$sObj", $name);
  }

  foreach my $arrayObj (@{$structObj->getArrayList()}) {
     my $name = $arrayObj->getName();
     $name = '' unless defined $name;
     #$name = 'Array:' . $name;
     $name = '<' . $name . '>';
     if (defined $arrayObj->getFieldAxis()) {
        $widget->add("$path/$arrayObj", 
                     -text => $name, -image => $FIELD_ARRAY_IMAGE,
                     -data => $arrayObj);
     } else {
        $widget->add("$path/$arrayObj", 
                     -text => $name, -image => $PLAIN_ARRAY_IMAGE,
                     -data => $arrayObj);
     }

     foreach my $node (@{$arrayObj->getXMLElementList()}) {
        next unless defined $node;
        my $name = $node->getNodeName;
        &show_XMLElement_in_Hlist($widget, $node, "$path/$arrayObj/$node", $name);
     }

  }

}

sub change_array_dataformat {

   my $obj = eval "new $DataFormatClass{$ARRAY_DATAFORMAT}"; 
   $ARRAY->setDataFormat($obj);

print STDERR "new obj dataformat is : $obj\n";

   &update_dataformat_view();

}

sub change_ostyle {

   my $obj = eval "new $XMLDataIOStyleClass{$ARRAY_OSTYLE}"; 
   $ARRAY->setXMLDataIOStyle($obj);

print STDERR "new obj style is : $obj\n";

   &update_ostyle_view();

}

sub create_menu {
   my ($menu, $name, $side, $expand) = @_;

   $expand = '0' unless defined $expand;
   $side = 'left' unless defined $side;
   my $thisMenu;

   $thisMenu = $menu->Menubutton(text => $name,
                                font => $Font{$DISPLAY_SIZE},
                                activebackground => $EventMouseOverColor, 
                                bg => $BaseColor, 
                                menu => $thisMenu,
                              )->pack(fill => 'x', side => $side, expand => $expand);
   return $thisMenu;
}

sub create_menus {
  my ($menu) = @_;

  $WIDGET{'file_menu'} = &create_menu($menu, 'File', 'left');
#  $WIDGET{'edit_menu'} = &create_menu($menu, 'Edit', 'left');
  $WIDGET{'view_menu'} = &create_menu($menu, 'View', 'left');
  $WIDGET{'help_menu'} = &create_menu($menu, 'Help', 'right');

  &create_file_menu($WIDGET{'file_menu'});
  &create_view_menu($WIDGET{'view_menu'});
  &create_help_menu($WIDGET{'help_menu'});

}

sub create_file_menu {
   my ($menu) = @_;

   $WIDGET{'new_file_menu'} = $menu->command( -label => 'New',
                                              -font => $Font{$DISPLAY_SIZE},
                                              -state => 'disabled',
                                              -bg => $BaseColor,
                                                 command => sub {
                                                                }
                                               );

   $menu->separator(-bg => $BaseColor);

   $WIDGET{'load_file_menu'} = $menu->command( -label => 'Load',
                                               -underline => 0,
                                                 font => $Font{$DISPLAY_SIZE},
                                                 bg => $BaseColor,
                                                 command => sub {  
                                                                   &load_xml_file(&select_file("Load which file?","*.xml")); 
                                                                }
                                               );

   $WIDGET{'reload_file_menu'} = $menu->command( -label => 'Re-Load',
                                               -underline => 0,
                                                 font => $Font{$DISPLAY_SIZE},
                                                 bg => $BaseColor,
                                                 command => sub {
                                                                   &load_xml_file($XML_FILE);
                                                                }
                                               );

  $menu->separator(bg => $BaseColor);

   $WIDGET{'save_file_menu'} = $menu->command( -label => 'Save',
                                               -underline => 0,
                                                 font => $Font{$DISPLAY_SIZE},
                                                 bg => $BaseColor,
                                                 command => sub { &save_xdf_file($XML_FILE); }
                                               );

   $WIDGET{'save_as_file_menu'} = $menu->command( -label => 'Save As',
                                                  -underline => 1,
                                                    font => $Font{$DISPLAY_SIZE},
                                                    bg => $BaseColor,
                                                    command => sub { &save_xdf_file(&select_file("Save as file?","*.xml"));}
                                                  );


   $menu->separator(bg => $BaseColor);

  # output file options
   my $menu_file_output = 'File Output Options';
   $WIDGET{'output_file_menu'} =
           $menu->cascade(-label => $menu_file_output, bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm_output = $menu->cget(-menu);
   my $cc_file_output = $cm_output->Menu;
   $menu->entryconfigure($menu_file_output, -menu => $cc_file_output);


   # clobber existing output files w/o asking
   my $menu_file_output_clobber = 'Confirm overwriting existing files';
   $WIDGET{'clobber_output_file_menu'} =
           $WIDGET{'output_file_menu'}->cascade(-label => $menu_file_output_clobber,
                                                      -bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm_output_clobber = $WIDGET{'output_file_menu'}->cget(-menu);
   my $cc_file_output_clobber = $cm_output_clobber->Menu;

   $cc_file_output->entryconfigure($menu_file_output_clobber, -menu => $cc_file_output_clobber);

   $WIDGET{'file_clobber_output_true_menu'} = $cc_file_output_clobber->radiobutton(-label => ' True ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$CONFIRM_OUTPUT_CLOBBER,
                                                      -value => 1,
                                                                     );
    $WIDGET{'file_clobber_output_false_menu'} = $cc_file_output_clobber->radiobutton(-label => ' False ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$CONFIRM_OUTPUT_CLOBBER,
                                                      -value => 0,
                                                                     );

   # pretty File output
   my $menu_file_output_pretty = 'Pretty File Output';
   $WIDGET{'pretty_output_file_menu'} =
           $WIDGET{'output_file_menu'}->cascade(-label => $menu_file_output_pretty, 
                                                      -bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm_output_pretty = $WIDGET{'output_file_menu'}->cget(-menu);
   my $cc_file_output_pretty = $cm_output_pretty->Menu;

   $cc_file_output->entryconfigure($menu_file_output_pretty, -menu => $cc_file_output_pretty);

    $WIDGET{'file_pretty_output_false_menu'} = $cc_file_output_pretty->radiobutton(-label => ' False ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$PRETTY_XDF_OUTPUT,
                                                      -value => 0,
                                                     -command => sub {
                                                               my $spec = XDF::Specification->getInstance();                                        
                                                               $spec->setPrettyXDFOutput($PRETTY_XDF_OUTPUT);
                                                                      },
                                                                     );

   $WIDGET{'file_pretty_output_true_menu'} = $cc_file_output_pretty->radiobutton(-label => ' True ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$PRETTY_XDF_OUTPUT,
                                                      -value => 1,
                                                      -command => sub {
                                                               my $spec = XDF::Specification->getInstance();
                                                               $spec->setPrettyXDFOutput($PRETTY_XDF_OUTPUT);
                                                                      },
                                                                     );

   # input file options
   my $menu_file_input = 'File Input Options';
   $WIDGET{'parse_input_file_menu'} =
           $menu->cascade(-label => $menu_file_input, bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm_input = $menu->cget(-menu);
   my $cc_file_input = $cm_input->Menu;
   $menu->entryconfigure($menu_file_input, -menu => $cc_file_input);


   # expand entities option
   my $menu_file_input_parse_ent = 'Expand Entities';
   $WIDGET{'file_input_parse_entities_menu'} = $WIDGET{'parse_input_file_menu'}->cascade(
                                                         -label => $menu_file_input_parse_ent, 
                                                         -bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm_input_parse_ent = $WIDGET{'parse_input_file_menu'}->cget(-menu);
   my $cc_file_input_parse_ent = $cm_input_parse_ent->Menu;
   $cc_file_input->entryconfigure( $menu_file_input_parse_ent, 
                                   -menu => $cc_file_input_parse_ent);

    $WIDGET{'file_input_parse_ent_true_menu'} = $cc_file_input_parse_ent->radiobutton(-label => ' True ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$XDF_PARSER_NO_EXPAND,
                                                      -value => 0,
                                                                     );

    $WIDGET{'file_input_parse_ent_false_menu'} = $cc_file_input_parse_ent->radiobutton(-label => ' False ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$XDF_PARSER_NO_EXPAND,
                                                      -value => 1,
                                                                     );


   $WIDGET{'parse_input_file_menu'}->separator(bg => $BaseColor);

   # parse param entities option
   my $menu_file_input_parse_pent = 'Parse Parameter Entities';
   $WIDGET{'file_input_parse_param_ent_menu'} = $WIDGET{'parse_input_file_menu'}->cascade(
                                                         -label => $menu_file_input_parse_pent,
                                                         -bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm_input_parse_pent = $WIDGET{'parse_input_file_menu'}->cget(-menu);
   my $cc_file_input_parse_pent = $cm_input_parse_pent->Menu;
   $cc_file_input->entryconfigure( $menu_file_input_parse_pent,
                                   -menu => $cc_file_input_parse_pent);

    $WIDGET{'file_input_parse_pent_true_menu'} = $cc_file_input_parse_pent->radiobutton(-label => ' True ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$XDF_PARSER_PARSE_PARAM_ENT,
                                                      -value => 1,
                                                                     );

    $WIDGET{'file_input_parse_pent_false_menu'} = $cc_file_input_parse_pent->radiobutton(-label => ' False ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$XDF_PARSER_PARSE_PARAM_ENT,
                                                      -value => 0,
                                                                    );

   $WIDGET{'parse_input_file_menu'}->separator(bg => $BaseColor);

   # expand param entities option
   my $menu_file_input_expand_pent = 'Expand Parameter Entities';
   $WIDGET{'file_input_expand_param_ent_menu'} = $WIDGET{'parse_input_file_menu'}->cascade(
                                                         -label => $menu_file_input_expand_pent,
                                                         -bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm_input_expand_pent = $WIDGET{'parse_input_file_menu'}->cget(-menu);
   my $cc_file_input_expand_pent = $cm_input_expand_pent->Menu;
   $cc_file_input->entryconfigure( $menu_file_input_expand_pent,
                                   -menu => $cc_file_input_expand_pent);

    $WIDGET{'file_input_expand_pent_true_menu'} = $cc_file_input_expand_pent->radiobutton(-label => ' True ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -variable => \$XDF_PARSER_EXPAND_PARAM_ENT,
                                                     -value => 1, 
                                                                                         );

    $WIDGET{'file_input_expand_pent_false_menu'} = $cc_file_input_expand_pent->radiobutton(-label => ' False ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -variable => \$XDF_PARSER_EXPAND_PARAM_ENT,
                                                     -value => 0, 
                                                                                          );

   $WIDGET{'parse_input_file_menu'}->separator(bg => $BaseColor);

   $menu->separator(bg => $BaseColor);

   $WIDGET{'close_file_menu'} = $menu->command( -label => 'Close',
                                                -font => $Font{$DISPLAY_SIZE},
                                                -state => 'disabled',
                                                -bg => $BaseColor,
                                                 command => sub {
                                                                }
                                           );

   # the quit button
   $WIDGET{'quit_file_menu'} = $menu->command(-label => 'Quit',
                                             font => $Font{$DISPLAY_SIZE},
                                             -underline => 0,
                                             bg => $BaseColor,
                                            -command => sub { &my_exit; }
                                           );


}

sub create_view_menu {
  my ($menu) = @_;

   my $menu_font_view = 'Change Display Font';
   $WIDGET{'font_view_menu'} =
           $menu->cascade(-label => $menu_font_view, bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
    my $cm_font_view = $menu->cget(-menu);
    my $cc_font_view = $cm_font_view->Menu;
    $menu->entryconfigure($menu_font_view, -menu => $cc_font_view);

   $WIDGET{'view_font_fixed_menu'} = $cc_font_view->radiobutton(-label => ' Fixed ',
                                                      -font => $Font{$DISPLAY_SIZE},
                                                      -bg => $BaseColor,
                                                      -variable => \$FONT_STYLE,
                                                      -value => 'fixed', 
                                                      -command => sub {   
                                                                         %Font = %Fixed_Font;
                                                                         %BoldFont = %Fixed_BoldFont;
                                                                         %SmallFont = %Fixed_SmallFont;
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                       });

   $WIDGET{'view_font_helvetica_menu'} = $cc_font_view->radiobutton(-label => ' Helvetica ',
                                                      -font => $Font{$DISPLAY_SIZE},
                                                      -bg => $BaseColor,
                                                      -variable => \$FONT_STYLE,
                                                      -value => 'helvetica',    
                                                      -command => sub {    
                                                                         %Font = %Helvetica_Font;
                                                                         %BoldFont = %Helvetica_BoldFont;
                                                                         %SmallFont = %Helvetica_SmallFont;
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                       });

    $WIDGET{'view_font_times_menu'} = $cc_font_view->radiobutton(-label => ' Times ',
                                                      -font => $Font{$DISPLAY_SIZE},
                                                      -bg => $BaseColor,
                                                      -variable => \$FONT_STYLE,
                                                      -value => 'times',
                                                      -command => sub {
                                                                         %Font = %Times_Font;
                                                                         %BoldFont = %Times_BoldFont;
                                                                         %SmallFont = %Times_SmallFont;
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                       });




   my $menu_cb = 'Change Tool Display Size';
   $WIDGET{'size_cascade_options_menu'} =
           $menu->cascade(-label => $menu_cb, bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
    my $cm = $menu->cget(-menu);
    my $cc = $cm->Menu;
    $menu->entryconfigure($menu_cb, -menu => $cc);
    $WIDGET{'opt_size_cas_large_menu'} = $cc->radiobutton(-label => '  Large (1600x1200) ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$DISPLAY_SIZE,
                                                      -value => 'large',
                                                     -command => sub { 
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                     });

    $WIDGET{'opt_size_cas_normal_menu'} = $cc->radiobutton(-label => '  Normal (1240x1024) ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$DISPLAY_SIZE,
                                                      -value => 'normal',
                                                     -command => sub { 
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                     });
    $WIDGET{'opt_size_cas_small_menu'} = $cc->radiobutton(-label => '  Small (1024x768) ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      -variable => \$DISPLAY_SIZE,
                                                      -value => 'small',
                                                      bg => $BaseColor,
                                                     -command => sub { 
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                     });
    $WIDGET{'opt_size_cas_tiny_menu'} = $cc->radiobutton(-label => '   Tiny (800x600)  ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                      -variable => \$DISPLAY_SIZE,
                                                      -value => 'tiny',
                                                     -command => sub { 
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                     });
    $cc->invoke(2);

}

sub create_help_menu {
  my ($this) = @_;

   $WIDGET{'helpcmd_help_menu'} = $this->command(-label => 'Help',
                           -font => $Font{$DISPLAY_SIZE},
                           bg => $BaseColor,
                           -command => sub { popup_msg_window(&help_message());});

   $WIDGET{'bugcmd_help_menu'} = $this->command(-label => 'Known Bugs',
                           -font => $Font{$DISPLAY_SIZE},
                           bg => $BaseColor,
                           -command => sub { popup_msg_window(&bugs_message());});

   $WIDGET{'aboutcmd_help_menu'} = $this->command(-label => 'About',
                           -font => $Font{$DISPLAY_SIZE},
                           bg => $BaseColor,
                           -command => sub { popup_msg_window(&about_message());});


}


sub load_xml_file {
   my ($file) = @_;

   return unless defined $file && -e $file;

   &debug("loading $file\n");

   my $parser = new XDF::DOM::Parser(
                                       debug => $DEBUG,
                                       quiet => $QUIET,
                                       NoExpand => $XDF_PARSER_NO_EXPAND,
                                       ParseParamEnt => $XDF_PARSER_PARSE_PARAM_ENT,
                                       ExpandParamEnt => $XDF_PARSER_EXPAND_PARAM_ENT,
                                    );

   $XDF_DOM = $parser->parsefile($file);

   my @xdfNodes = @{$XDF_DOM->getXDFElements};

   # just pick off the first object for now
#   $XDF = $xdfNodes[0]->getXDFObject;

   # update the widgets
   $WIDGET{'file_label'}->configure(text => "File Name: $file");

   &update_hlist_from_xdf($WIDGET{'xml_hlist'});

   $CURRENT_STRUCTURE = undef;
   $CURRENT_ITEM = undef;
   # we default the view to the first array, should it exist 

   &update_view();

   # update global in case re-load command is used 
   $XML_FILE = $file;

}

sub save_xdf_file {
  my ($file) = @_;

  &debug("save $XML_FILE\n");

  return unless defined $file;

  return unless ( !-e $file || !$CONFIRM_OUTPUT_CLOBBER ||
                  &confirm_overwritting_file($file));

  # change the file we are working with to this new name
  $XML_FILE = $file;

  # update the widgets
  $WIDGET{'file_label'}->configure(text => "File Name: $file");

  open(FILE, ">$file");
  print FILE $XDF_DOM->toString;
  close FILE;

}

sub confirm_overwritting_file {
  my ($filename) = @_;

  my $title = 'Overwrite file';
  my $msg = "$filename exists, overwrite it?";
  return &popup_yes_no_dialog($title, $msg, $Font{$DISPLAY_SIZE});

}

sub popup_yes_no_dialog {
  my ($title, $msg, $font) = @_;

  if(!$title) { $title = "Yes/No Question"; }

  my @buttons;
  (@buttons) = (@buttons, "Yes");
  (@buttons) = (@buttons, "No");
  
  my $dialog = $WIDGET{'main'}->Dialog(-title => $title, -font => $font, -text => $msg, -buttons => [@buttons]);
  my $selection = $dialog->Show;

  return $selection eq "Yes" ? 1 : 0;
}

sub reset_header_view {

  my $structTitle = $StructAttributeTitle . ':[]';
  $WIDGET{'struct_attrib_edit_label'}->configure( -text => $structTitle);

  if (!$ARRAY_ATTRIB_EDIT_OPEN) {
     my $arrTitle = $ArrayAttributeTitle . ':[]';
     $WIDGET{'array_attrib_edit_label'}->configure( -text => $arrTitle );
  } else {
      if (!defined $CURRENT_ITEM || $CURRENT_ITEM !~ m/Array/) { 
         &close_array_attrib_edit();
         &close_axis_attrib_edit($CURRENT_HORZ_AXIS, 'horz', 'horz' . $AxisWidgetBaseName);
         &close_axis_attrib_edit($CURRENT_VERT_AXIS, 'vert', 'vert' . $AxisWidgetBaseName);
      }
  }

}

sub update_header_view {

  &debug("update_header_view()\n");

  &reset_header_view();

  my $structObj = $CURRENT_STRUCTURE;
  my $arrayObj = $CURRENT_ITEM;

  return unless defined $structObj;

  my $structTitle = $StructAttributeTitle;
  my $structname = $structObj->getName();
  $structname = "" unless defined $structname;
  $structTitle .= ":[$structname]";
  $WIDGET{'struct_attrib_edit_label'}->configure( -text => $structTitle);

  return if (!defined $arrayObj || $arrayObj !~ m/Array/);

  if (!$ARRAY_ATTRIB_EDIT_OPEN) {
     my $arrTitle = $ArrayAttributeTitle;
     my $arrname = $arrayObj->getName();
     $arrname = "" unless defined $arrname;
     $arrTitle .= ":[$arrname]";
     $WIDGET{'array_attrib_edit_label'}->configure( -text => $arrTitle);
  }

}

sub update_table_view {

  &debug("update_table_view()\n");

  my $structObj = $CURRENT_STRUCTURE;
  my $arrayObj = $CURRENT_ITEM;

  &reset_table_view();
  &reset_table_globals($arrayObj);

  return if (!defined $arrayObj || $arrayObj !~ m/Array/);

  if (defined $arrayObj->getFieldAxis()) 
  {
     &update_fieldtable_view($arrayObj);
  } else {
     &update_plaintable_view($arrayObj);
  }

}

sub update_plaintable_view {
  my ($arrayObj) = @_;

   &debug("update_plaintable_view()\n");

   my $column_color = $ListBoxBgColor{ref($arrayObj->getDataFormat())};
   my $dataFormat = $arrayObj->getDataFormat(); 
   my $width = defined $dataFormat ? $dataFormat->numOfBytes() : 1;

   # horz axis
   my $axisInfo = &get_axis_title($CURRENT_HORZ_AXIS, 'horz');
   my $axisLabel = 'horz' . $AxisWidgetBaseName;
   $WIDGET{$axisLabel}->configure( text => $axisInfo, bg => $AxisBoxColor,);

   # vert axis
   $axisLabel = 'vert' . $AxisWidgetBaseName;
   $axisInfo = &get_axis_title($CURRENT_VERT_AXIS, 'vert');
   $WIDGET{$axisLabel}->configure ( text => $axisInfo, bg => $AxisBoxColor, );

   # geometry of the widget: a 'row' listbox followed by fieldlistboxes
   # 

   # this next line will fail when more than 2 axes exist in the array.
   my @axisOrder = ($CURRENT_VERT_AXIS, $CURRENT_HORZ_AXIS); # will fail if array has more than 2 axes 
   #my @axisOrder = reverse @{$arrayObj->getAxisList()};
   $LOCATOR->setIterationOrder(\@axisOrder);
   foreach my $col (0 ... ($CURRENT_HORZ_AXIS->getLength()-1)) {

      # create new frame for the axis header + listbox
      # after the first ('row') header + listbox and preexisting header + listboxes 
      # frames
      my $boxFrame = $FRAME{'listBox'}->Frame()->pack(expand => 1,
                                                       side => 'left', anchor => 'n',
                                                       fill => 'both'); 

      my $headerFrame = $boxFrame->Frame()->pack(expand => 0, side => 'top', fill => 'both' ); 
      my $dataFrame = $boxFrame->Frame()->pack(expand => 1, side => 'top', fill => 'both' ); 
      $headerFrame ->configure( relief => 'flat', bd => 2, bg => 'white');
      $dataFrame->configure ( relief => 'raised', bd => 2, bg => $Black);

      push @DATA_FRAMES, $boxFrame;

      # use labels to store field header info
      # name is the column index 
      my $name = $col;
      my $axisLabelWidget = $headerFrame->Label(  text => $name, 
                                                bg => $DataFrameColor, 
                                                font => $Font{$DISPLAY_SIZE},
                                             )->pack( expand => 'no', side => 'top', fill => 'both');
      push @LABELS, $axisLabelWidget;

      # this label empty
      my $emptyLabelWidget = $headerFrame->Label( text => ' ', -bg => $DataFrameColor, 
                         -font => $Font{$DISPLAY_SIZE},
                        )->pack(expand => 'no', side => 'top', fill => 'both');
      push @LABELS, $emptyLabelWidget;

      # add new 'data' listbox holding that columns data
      my $listBox = $dataFrame->Listbox(-width => $width, 
                                        -exportselection => 0,
                                        -height => $MaxDisplayListBoxHeight,
                                        -selectmode => $ListBoxSelectionStyle,
                                        -font => $Font{$DISPLAY_SIZE},
                                        )->pack ( expand => 1,
                                                  side => 'bottom',
                                                  fill => 'both');
      push @LISTBOXES, $listBox;

      # set color bg of listbox 
      $listBox->configure(-bg => $column_color);

      # mouse/keybindings
      $boxFrame->bind('<Enter>' => sub { $CURRENT_LISTBOX = $listBox; });
      $boxFrame->bind('<Leave>' => sub { $CURRENT_LISTBOX = undef; });
      $axisLabelWidget->bind('<Enter>' => sub { 
                                                 $axisLabelWidget->configure(-bg => $EventMouseOverColor); 
                                                 $emptyLabelWidget->configure(-bg => $EventMouseOverColor); 
                                              });
      $emptyLabelWidget->bind('<Enter>' => sub { 
                                                 $axisLabelWidget->configure(-bg => $EventMouseOverColor); 
                                                 $emptyLabelWidget->configure(-bg => $EventMouseOverColor); 
                                              });

      $axisLabelWidget->bind('<Button-1>' => sub { 
                                                    $WIDGET{'row_listbox'}->selectionClear(0, 'end');
                                                    &unselect_all_listBoxes(); 
                                                    &select_all_listBox_items($CURRENT_LISTBOX); 
                                                 });

      $emptyLabelWidget->bind('<Button-1>' => sub { 
                                                    $WIDGET{'row_listbox'}->selectionClear(0, 'end');
                                                    &unselect_all_listBoxes(); 
                                                    &select_all_listBox_items($CURRENT_LISTBOX); 
                                                 });
      $axisLabelWidget->bind('<Leave>' => sub { 
                                                 $axisLabelWidget->configure(-bg => $DataFrameColor); 
                                                 $emptyLabelWidget->configure(-bg => $DataFrameColor); 
                                              });
      $emptyLabelWidget->bind('<Leave>' => sub { 
                                                 $axisLabelWidget->configure(-bg => $DataFrameColor); 
                                                 $emptyLabelWidget->configure(-bg => $DataFrameColor); 
                                              });

      $listBox->bind('<Button-1>' => sub { 
                                             &unhighlight_all_table_labels($axisLabelWidget, $DataFrameColor);
                                             &unselect_all_listBoxes($listBox);
                                             &highlight_widget($axisLabelWidget);
                                             &select_rowListBox_item($listBox); 
                                         });

      $listBox->bind('<Double-Button-1>' => sub { 
                                             &unhighlight_all_table_labels($axisLabelWidget, $DataFrameColor);
                                             &unselect_all_listBoxes($listBox);
                                             &highlight_widget($axisLabelWidget);
                                             &select_rowListBox_item($listBox);
                                             &edit_listBox_item($listBox, $col); 
                                         });


      # insert data into new listbox
      my $row = 0;
      while ($LOCATOR->hasNext() && $LOCATOR->getAxisIndex($CURRENT_HORZ_AXIS) == $col) {
         $listBox->insert('end', $arrayObj->getData($LOCATOR));
         $WIDGET{'row_listbox'}->insert('end', $row) if ($col == 0);
         $row++;
         $LOCATOR->next();
      }

   }

   # tie them all together
   $WIDGET{'row_listbox'}->tie('scroll', @LISTBOXES);

}

sub select_all_listBox_index {
   my ($index) = @_;

   for (@LISTBOXES) {
      $_->selectionSet($index);
   }
}

sub unhighlight_all_table_labels {
   my ($dontDoThis, $color) = @_;

   $color = $BaseColor unless defined $color; 
   for (@LABELS) {
      $_->configure(-bg => $color) unless defined $dontDoThis && $_ eq $dontDoThis;
   }
}

sub unselect_all_listBoxes {
   my ($dontUnselectThis) = @_;
   for (@LISTBOXES) {
      $_->selectionClear(0, 'end') unless defined $dontUnselectThis && $_ eq $dontUnselectThis;
   }
}

sub select_all_listBox_items {
  my ($listBox) = @_;

  if (defined $listBox) {
     $listBox->selectionSet(0, 'end'); 
  }
}

sub edit_struct_attribs {
   my ($frame) = @_;

   return unless defined $CURRENT_ITEM && ($CURRENT_ITEM =~ m/Structure/ || $CURRENT_ITEM =~ m/XDF::XDF/);

   if ($STRUCT_ATTRIB_EDIT_OPEN) {
      &close_struct_attrib_edit();
      return;
   }

   $STRUCT_ATTRIB_EDIT_OPEN = 1;

   $WIDGET{'struct_attrib_edit_label'}->configure( -text => '<<Click to Close Structure Attributes>>',
                                                  -fg => 'white', #$Bright_white,
                                                  -bg => $StructureColor,
                                                );

   &make_widget_not_highlight_on_mouseover($WIDGET{'struct_attrib_edit_label'});

   # create widgets
   #for (@{XDF::Structure->getXMLAttributes}) {
   for (@{$CURRENT_ITEM->getXMLAttributes}) {
       my $subFrame = $frame->Frame->pack(side => 'top', fill => 'both', expand => 0);
       push @STRUCTEDITFRAMES, $subFrame;
       my $labelname = 'struct' . $_ . "_label";
       my $entryname = 'struct' . $_ . "_val_label";
       my $getMethod = 'get' . ucfirst $_;
       my $setMethod = 'set' . ucfirst $_;
       my $getMethodRef = sub { $CURRENT_ITEM->$getMethod; };
       my $setMethodRef = sub { $CURRENT_ITEM->$setMethod(@_); };
       next if ref(&$getMethodRef);
       &make_label_click_widget( $_, $subFrame, $labelname, $entryname, $getMethodRef, $setMethodRef);
   }

   # update value of widgets
   &update_struct_edit_attrib_val();
}

sub edit_array_attribs {
   my ($frame) = @_;

   return unless defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/;

   if ($ARRAY_ATTRIB_EDIT_OPEN) {
      &close_array_attrib_edit();
      return;
   }

   $ARRAY_ATTRIB_EDIT_OPEN = 1;

   $WIDGET{'array_attrib_edit_label'}->configure( -text => '<<Click to Close Array Attributes>>',
                                                  -fg => 'white', #$Bright_white,
                                                  -bg => $ArrayColor,
                                                );
   &make_widget_not_highlight_on_mouseover($WIDGET{'array_attrib_edit_label'});

   # create widgets
   for (@ArrayAttribList) {
       my $subFrame = $frame->Frame->pack(side => 'top', fill => 'both', expand => 0);
       push @ARRAYEDITFRAMES, $subFrame;
       my $labelname = 'array' . $_ . "_label";
       my $entryname = 'array' . $_ . "_val_label";
       my $getMethod = 'get' . ucfirst $_; 
       my $setMethod = 'set' . ucfirst $_; 
       my $getMethodRef = sub { $ARRAY->$getMethod; }; 
       my $setMethodRef = sub { $ARRAY->$setMethod(@_); }; 
       &make_label_click_widget( $_, $subFrame, $labelname, $entryname, $getMethodRef, $setMethodRef); 
   }

   # update value of widgets
   &update_array_edit_attrib_val();
}

sub edit_data_attribs {
   my ($frame) = @_;

   return unless defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/;

   if ($DATA_ATTRIB_EDIT_OPEN) {
      &close_data_attrib_edit();
      return;
   }

   $DATA_ATTRIB_EDIT_OPEN = 1;

   $WIDGET{'data_attrib_edit_label'}->configure( -text => '<<Click to Close Data Attributes>>',
                                                  -fg => 'white', #$Bright_white,
                                                  -bg => $DataColor,
                                                );
   &make_widget_not_highlight_on_mouseover($WIDGET{'data_attrib_edit_label'});

   #for (@{XDF::DataCube->getXMLAttributes}) {
   my $dataCube = $CURRENT_ITEM->getDataCube();
   for (@{$dataCube->getXMLAttributes}) {
       my $subFrame = $frame->Frame->pack(side => 'top', fill => 'both', expand => 0);
       push @DATAEDITFRAMES, $subFrame;
       my $labelname = 'dataCube' . $_ . "_label";
       my $entryname = 'dataCube' . $_ . "_val_label";
       my $getMethod = 'get' . ucfirst $_;
       my $setMethod = 'set' . ucfirst $_;
       #my $getMethodRef = sub { $CURRENT_ITEM->getDataCube->$getMethod; };
       #my $setMethodRef = sub { $CURRENT_ITEM->getDataCube->$setMethod(@_); };
       my $getMethodRef = sub { $dataCube->$getMethod; };
       my $setMethodRef = sub { $dataCube->$setMethod(@_); };
       next if ref(&$getMethodRef);
       &make_label_click_widget( $_, $subFrame, $labelname, $entryname, $getMethodRef, $setMethodRef
);
   }

   # update value of widgets
   #&update_data_edit_attrib_val();
}


sub edit_axis_attribs {
  my ($frame, $axisNum, $which) = @_;

   # this could be bad, current item could now be structure?
   my $axisObj = $CURRENT_ITEM->getAxisList->[$axisNum];
   my $widgetname = $which . 'Axis_edit_boldlabel';

   if ($AXIS_ATTRIB_EDIT_OPEN{$which}) {
      &close_axis_attrib_edit($axisObj, $which, $widgetname);
      return;
   }

   $AXIS_ATTRIB_EDIT_OPEN{$which} = 1;

   my $title = '<<Click to Close>>';
   if ($which eq 'vert') { $title =~ s/(.)/$1\n/g; }

   $WIDGET{$widgetname}->configure( -text => $title,
                                    -font => $SmallFont{$DISPLAY_SIZE},
                                    -fg => $Black,
                                    -bg => $AxisBoxColor,
                                  );


   &make_widget_not_highlight_on_mouseover($WIDGET{$widgetname});

   for (@{$axisObj->getXMLAttributes()}) {
       my $getMethod = 'get' . ucfirst $_;
       my $setMethod = 'set' . ucfirst $_;
       next if ref($axisObj->$getMethod); # dont show objects 

       my $subFrame = $frame->Frame->pack(side => 'top', fill => 'both', expand => 0);
       push @{$AXISEDITFRAMES{$which}}, $subFrame;
       my $labelname = 'axis' . $axisNum . $_ . "_label";
       my $entryname = 'axis' . $axisNum . $_ . "_val_label";
       my $getMethodRef = sub { $axisObj->$getMethod; };
       my $setMethodRef = sub { $axisObj->$setMethod(@_); };
       &make_label_click_widget( $_, $subFrame, $labelname, $entryname, 
                                 $getMethodRef, $setMethodRef );
   }
}

sub clear_xmlNode_attrib_edit {

  while ((my $frame = pop @XMLNODE_EDITFRAMES)) {
      $frame->destroy();
  }

}

sub close_struct_attrib_edit {

  while ((my $frame = pop @STRUCTEDITFRAMES)) {
      $frame->destroy();
  }

  # update attribute title  
  my $name;
  if(defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Structure/) {
     $name = $CURRENT_ITEM->getName();
  }
  $name = "" unless defined $name;
  my $structTitle = $StructAttributeTitle . ":[$name]";

  $WIDGET{'struct_attrib_edit_label'}->configure( -text => $structTitle,
                                                  -fg => $Black,
                                                  -bg => $BaseColor,
                                               );

  &make_widget_highlight_on_mouseover($WIDGET{'struct_attrib_edit_label'});

  $STRUCT_ATTRIB_EDIT_OPEN = 0;
  return;

}

sub close_axis_attrib_edit {
  my ($axisObj, $which, $widgetname) = @_;

  while ((my $frame = pop @{$AXISEDITFRAMES{$which}})) {
      $frame->destroy();
  }
  
  # update attribute title  
  my $title = &get_axis_title($axisObj, $which);
  my $color = $AxisBoxColor;

  if ($which eq 'horz') {
    $color = &get_horzAxisColor();
  } else { 
    $color = &get_vertAxisColor();
  }

  $WIDGET{$widgetname}->configure( -text => $title,
                                   -font => $BoldFont{$DISPLAY_SIZE},
                                   -fg => $Black,
                                   -bg => $color,
                                 );

  &make_widget_highlight_on_mouseover($WIDGET{$widgetname}, $color);

  $AXIS_ATTRIB_EDIT_OPEN{$which} = 0;
  return;

}

sub close_array_attrib_edit {

  while ((my $frame = pop @ARRAYEDITFRAMES)) {
      $frame->destroy();
  }

  # update attribute title  
  my $arrname;
  if(defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/) {
     $arrname = $CURRENT_ITEM->getName();
  } 
  $arrname = "" unless defined $arrname;
  my $arrTitle = $ArrayAttributeTitle . ":[$arrname]";

  $WIDGET{'array_attrib_edit_label'}->configure( -text => $arrTitle,
                                                  -fg => $Black,
                                                  -bg => $BaseColor,
                                               );

  &make_widget_highlight_on_mouseover($WIDGET{'array_attrib_edit_label'});

  $ARRAY_ATTRIB_EDIT_OPEN = 0;
  return;

}

sub close_data_attrib_edit {

  while ((my $frame = pop @DATAEDITFRAMES)) {
      $frame->destroy();
  }    
       
  # update attribute title   
  $WIDGET{'data_attrib_edit_label'}->configure( -text => $DataAttributeTitle,
                                                  -fg => $Black,
                                                  -bg => $BaseColor,
                                               );

  &make_widget_highlight_on_mouseover($WIDGET{'data_attrib_edit_label'});

  $DATA_ATTRIB_EDIT_OPEN = 0;
  return;

}

sub update_struct_edit_attrib_val {

   return unless (defined $CURRENT_ITEM);

   if ($CURRENT_ITEM =~ m/Structure/ || $CURRENT_ITEM =~ m/XDF::XDF/) {

      #for (@{XDF::Structure->getXMLAttributes}) {
      for (@{$CURRENT_ITEM->getXMLAttributes}) {
         my $name = 'struct' . $_ . "_val_label";
         my $methodname = 'get' . ucfirst $_;
         my $val = $CURRENT_ITEM->$methodname;
         next if ref($val);
         $val = "" unless defined $val;
         $WIDGET{$name}->configure(-text => $val);
      }

   } else { # clear and close
      &close_struct_attrib_edit();
   }

}

sub update_array_edit_attrib_val {

   return unless (defined $CURRENT_ITEM);
    
   if ($CURRENT_ITEM =~ m/Array/) {

      for (@ArrayAttribList) {
         my $name = 'array' . $_ . "_val_label";
         my $methodname = 'get' . $_;
         my $val = $CURRENT_ITEM->$methodname;
         $val = "" unless defined $val;
         $WIDGET{$name}->configure(-text => $val);
      }

   } else { # clear and close
      &close_array_attrib_edit();
   }
}

sub edit_listBox_item {
  my ($listBox, $colIndex) = @_;

  my $index = $listBox->curselection();

  $LOCATOR->setAxisIndex($CURRENT_HORZ_AXIS, $index);
  $LOCATOR->setAxisIndex($CURRENT_VERT_AXIS, $colIndex);

  my $value = &popup_edit_window("Edit Data Value", $ARRAY->getData($LOCATOR));
  $ARRAY->setData($LOCATOR, $value);

  $listBox->delete($index);
  $listBox->insert($index, $value);
 
}

sub highlight_widget {
  my ($widget) = @_;
  $widget->configure(bg => $EventMouseOverColor);
}

sub select_rowListBox_item {
  my ($rowListBox) = @_;

  my $index = $rowListBox->curselection();

  if (defined $index) {
     $WIDGET{'row_listbox'}->selectionClear(0, 'end');
     $WIDGET{'row_listbox'}->selectionSet($index);
  }

}

sub reset_table_globals {
   my ($obj) = @_;

   &debug("reset_table_globals()\n");

   $CURRENT_HORZ_AXIS = undef; 
   $CURRENT_VERT_AXIS = undef;

   $ARRAY = defined $obj && $obj =~ m/Array/ ? $obj : undef;

   if (defined $ARRAY) {
     $CURRENT_VERT_AXIS = $ARRAY->getAxisList()->[1];
     $CURRENT_HORZ_AXIS = $ARRAY->getAxisList()->[0];
     $LOCATOR = $ARRAY->createLocator();
   } else { 
     $LOCATOR = undef;
   }

}

sub reset_table_view {

   &debug("reset_table_view()\n");

   #horz axis label
   my $wname = 'horz' . 'Axis_edit_boldlabel';
   $WIDGET{$wname}->configure( text => "Axis:", bg => $AxisBoxColor,) if defined $WIDGET{$wname}; 

   #vert axis label
   $wname = 'vert' . 'Axis_edit_boldlabel';
   $WIDGET{$wname}->configure ( text => "A\nx\ni\ns",
                                bg => $AxisBoxColor,
                              ) if defined $WIDGET{$wname};

   $WIDGET{'array_notebook'}->pageconfigure( 'DFmt', -state => 'normal');
   $WIDGET{'array_notebook'}->pageconfigure( 'Unit', -state => 'normal');

   while (my $widget = pop @LISTBOXES) {
      $widget->destroy();
   }

   while (my $widget = pop @LABELS) {
      $widget->destroy();
   }

   #@LABELS = ();

   for (@DATA_FRAMES) {
     $_->destroy();
   }
   @DATA_FRAMES = ();

   # clean out the row listbox
   $WIDGET{'row_listbox'}->delete(0, 'end') if defined $WIDGET{'row_listbox'};

}



sub update_fieldtable_view {
   my ($arrayObj) = @_;

   &debug("update_fieldtable_view()\n");

   # for field tables we must edit units, dataformat on field by field
   # basis. Therefore, disable these tabs and change the notebook view
   # if it is currently there.
   $WIDGET{'array_notebook'}->pageconfigure( 'DFmt', -state => 'disabled');
   $WIDGET{'array_notebook'}->pageconfigure( 'Unit', -state => 'disabled');
   if ( $WIDGET{'array_notebook'}->raised eq 'DFmt' ||
        $WIDGET{'array_notebook'}->raised eq 'Unit' ) 
   {
       $WIDGET{'array_notebook'}->raise('Data');
   }

   my $fieldAxis = $CURRENT_HORZ_AXIS; #$arrayObj->getFieldAxis();

   # horz axis
   my $axisInfo = &get_axis_title($CURRENT_HORZ_AXIS, 'horz');
   my $wname = 'horz' . 'Axis_edit_boldlabel';
   my $color = &get_horzAxisColor();
   $WIDGET{$wname}->configure( text => $axisInfo, bg => $color);

   # vert axis
   $wname = 'vert' . 'Axis_edit_boldlabel';
   $axisInfo = &get_axis_title($CURRENT_VERT_AXIS, 'vert');
   $color = &get_vertAxisColor();
   $WIDGET{$wname}->configure ( text => $axisInfo, bg => $color,);



   $FRAME{'listBox'}->configure(-height => 30, -width => 100);


   # we need to change the default iteration order
   my @axisOrder = ($CURRENT_VERT_AXIS, $CURRENT_HORZ_AXIS); # will fail if array has more than 2 axes 
   $LOCATOR->setIterationOrder(\@axisOrder);

   my $col = 0;
   # geometry of the widget: a 'row' listbox followed by fieldlistboxes
   foreach my $fieldObj ($fieldAxis->getFields()) 
   {
      
      # create new frame for the field header + listbox
      # after the first ('row') header + listbox and preexisting header + listboxes 
      # frames
      my $dataFrame = $FRAME{'listBox'}->Frame()->pack(expand => 'yes',
                                                       side => 'left',
                                                       fill => 'both'); 
      $dataFrame->configure ( relief => 'raised', bd => 3, bg => 'black');
      push @DATA_FRAMES, $dataFrame; 

      # use labels to store field header info
      # field name
      my $name = defined $fieldObj->getName() ? $fieldObj->getName() : "";
      my $labelWidget = $dataFrame->Label( text => $name, -bg => $DataFrameColor,
                        -font => $Font{$DISPLAY_SIZE},
                       )->pack(expand => 'no', 
                                              side => 'top', 
                                              fill => 'both'); 
      push @LABELS, $labelWidget;

      # field units
      my $units = defined $fieldObj->getUnits->getValue() ? 
                       $fieldObj->getUnits()->getValue() : "";
      my $unitLabelWidget = $dataFrame->Label( text => "(".$units.")", -bg => $DataFrameColor,
                                               font => $Font{$DISPLAY_SIZE},
                                             )->pack(expand => 'no', side => 'top', 
                                                     fill => 'both');
      push @LABELS, $unitLabelWidget;

      # add new 'field' listbox holding that columns data
      my $listBox = $dataFrame->Listbox(
                                        -exportselection => 0,
                                        -height => $MaxDisplayListBoxHeight,
                                        -selectmode => $ListBoxSelectionStyle,
                                        -font => $Font{$DISPLAY_SIZE},
                                       )->pack ( expand => 'yes', 
                                                  side => 'bottom', 
                                                  fill => 'both'); 
      
      push @LISTBOXES, $listBox;

      # color bg of listbox by dataformat
      my $color = $ListBoxBgColor{ref($fieldObj->getDataFormat())};
      $listBox->configure(-bg => $color); 

      # mouse/key bindings
      $dataFrame->bind('<Enter>' => sub { $CURRENT_LISTBOX = $listBox; });
      $unitLabelWidget->bind('<Enter>' => sub { $unitLabelWidget->configure(-bg => $EventMouseOverColor); });
      $unitLabelWidget->bind('<Leave>' => sub { $unitLabelWidget->configure(-bg => $DataFrameColor); });
      $labelWidget->bind('<Enter>' => sub { $labelWidget->configure(-bg => $EventMouseOverColor); });
      $labelWidget->bind('<Leave>' => sub { $labelWidget->configure(-bg => $DataFrameColor); });
      $labelWidget->bind('<Button-1>' => sub {
                                               $WIDGET{'row_listbox'}->selectionClear(0, 'end');
                                               &unselect_all_listBoxes();
                                               &select_all_listBox_items($CURRENT_LISTBOX);
                                             });
      $labelWidget->bind('<Double-Button-1>' => sub {
                                                  my $value = &popup_edit_window("Edit Field Name", $fieldObj->getName());
                                                  $fieldObj->setName($value);
                                                  $labelWidget->configure(-text => $value);
                                             });
     $labelWidget->bind('<Button-2>' => sub {
                                                print STDERR "options menu\n";
                                             });

      $listBox->bind('<Button-1>' => sub {
                                             &unhighlight_all_table_labels($labelWidget, $DataFrameColor);
                                             &unselect_all_listBoxes($listBox);
                                             &highlight_widget($labelWidget);
                                             &select_rowListBox_item($listBox); 
                                         });

      my $colIndex = $col; # kludge for Perl Bug?. Cant seem to beable to use just $col here. :P
      $listBox->bind('<Double-Button-1>' => sub {
                                             &unhighlight_all_table_labels($labelWidget, $DataFrameColor);
                                             &unselect_all_listBoxes($listBox);
                                             &highlight_widget($labelWidget);
                                             &select_rowListBox_item($listBox); 
                                             &edit_listBox_item($listBox, $colIndex);
                                         });

      $dataFrame->bind('<Leave>' => sub { $CURRENT_LISTBOX = undef; });


      # insert data into new listbox
      my $row = 0;
      while ($LOCATOR->hasNext() && $LOCATOR->getAxisIndex($fieldAxis) == $col) {
         $listBox->insert('end', $arrayObj->getData($LOCATOR));
         $WIDGET{'row_listbox'}->insert('end', $row) if $col == 0;
         $row++;
         $LOCATOR->next();
      }
      $col++;
   }

   # tie them all together
   $WIDGET{'row_listbox'}->tie('scroll', @LISTBOXES);

}

sub get_axis_title {
   my ($axisObj, $which) = @_;

   my $axisInfo = $axisObj->getName();
   $axisInfo = "" unless defined $axisInfo;
   $axisInfo .= " (" . $axisObj->getLength();

   if (ref($axisObj) eq 'XDF::FieldAxis') {
     $axisInfo = "Field Axis:" . $axisInfo;
     $axisInfo .= " fields)";
   } else { 
     $axisInfo = "Axis:$axisInfo)";
   }

   if ($which eq 'vert') { $axisInfo =~ s/(.)/$1\n/g; }

   return $axisInfo;
}

sub add_horizontal_scrollbar_to_widget {
  my ($widget,$frame,$barside,$yscroll) = @_;

  $barside = defined $barside ? $barside : "right";
 
  my $widget_side = $barside eq 'right' ? 'left' : 'right';

  $yscroll = $frame->Scrollbar unless $yscroll;
  $yscroll->configure(-command => ['yview', $widget]);
  $widget->configure (-yscrollcommand => ['set', $yscroll]); 
  $widget->pack(side => $widget_side, fill => 'both', expand => 'yes');
  $yscroll->pack(side => $barside, fill => 'y');

  return $yscroll;
}

sub add_vertical_scrollbar_to_widget {
  my ($widget,$frame,$barside,$xscroll) = @_;

  $barside = defined $barside ? $barside : "bottom";
  $xscroll = $frame->Scrollbar unless $xscroll;

  my $widget_side = $barside eq 'bottom' ? 'top' : 'bottom';

  $xscroll->configure(-command => ['xview', $widget]);
  $widget->configure (-xscrollcommand => ['set', $xscroll]); 
  $widget->pack(side => $widget_side, fill => 'both', expand => 'yes');
  $xscroll->pack(side => $barside, fill => 'x');

  return $xscroll;
}
 
sub change_display_size {
  my ($display_size) = @_;

  $WIDGET{'main'}->configure ( title => "$TOOLNAME v$VERSION")
    if $WIDGET{'main'};
    
  foreach my $widget (keys %WIDGET) {
    &debug("change_display($widget)\n");
    if ($widget =~ m/text/) {
       # $WIDGET{$widget}->configure(-height => $widget_dim{$widget}->{'height'}->{$display_size},
       #                             -width => $widget_dim{$widget}->{'width'}->{$display_size},
       #                             -font => $font{$display_size}
       #                            );
    }
    if ($widget =~ m/boldlabel/ or $widget =~ m/button/ ) {
        $WIDGET{$widget}->configure( -font => $BoldFont{$display_size});
    }
    if ($widget =~ m/listbox/ or $widget =~ m/hlist/ 
        or $widget =~ m/optionmenu/ or $widget =~ m/notebook/ 
        or $widget =~ m/menu/ or $widget =~ m/_label/) 
    {
        $WIDGET{$widget}->configure( -font => $Font{$display_size});
    }
  }

  # now for the more ephemeral list of widgets within the table
  for (@LISTBOXES) {
        $_->configure( -font => $Font{$display_size});
  }
  for (@LABELS) {
        $_->configure( -font => $Font{$display_size});
  }

}

sub popup_msg_window {
  my (@msg) = @_;
  my $popup_width = 100;

  chomp @msg;

  my $size = $#msg > 40 ? 42 : $#msg+3;
  my $top= $WIDGET{'main'}->Toplevel;
  $top->configure(title => "Popup Window");

  # frame
  my $popup = $top->Frame()->pack(side => 'top', expand => 1, fill => 'both');

  # widgets
  my $text = $popup->Text(height => $size-1, -font => $Font{$DISPLAY_SIZE} );
  my $exit = $top->Button(text => "OK", -font => $Font{$DISPLAY_SIZE}, command => sub {$top->destroy;});
  my $foo_height = $popup->Label();
  my $foo_width = $popup->Label();
  my $yscrollbar = $text->Scrollbar(-command => ['yview', $text]);

  #configure
  $text->configure(-yscrollcommand => ['set', $yscrollbar]);
  $text->configure(bg => 'black', fg => 'white');
  $exit->configure(bg => 'red', fg => 'black');
  $foo_height -> configure(height => $size);
  $foo_width -> configure(width => $popup_width);

  #pack it
  $foo_height->pack(side => 'left');
  $foo_width->pack(side => 'top');
  $text->pack(side => 'top', expand => 1, fill => 'both');
  $exit->pack(side => 'bottom');
  $yscrollbar->pack(-side=>'right', fill => 'y');

  for (@msg) {
    $text->insert('end', $_);
    $text->insert('end', "\n");
  }
}

sub popup_edit_window 
{
   my ($title, $default_value) = @_;
   # ("Edit Data Value", $ARRAY->getData($LOCATOR));

  my @buttons;
  (@buttons) = (@buttons, "Ok");
  (@buttons) = (@buttons, "Ignore");

                      #-font => $Font{$DISPLAY_SIZE},
  my $dialog = $WIDGET{'main'}->DialogBox (
                      -title => $title,
                      -buttons => [@buttons]
                 );
  my $label = $dialog->add('Label', -text => $title);
  my $entry = $dialog->add('Entry');
  $entry->insert(0.0,$default_value) if ($default_value);
  $label->pack;
  $entry->pack;

  my $selection = $dialog->Show;

  my $ret_val = $selection eq 'Ok' ? $entry->get : $default_value;
  return $ret_val;
}

sub select_file {
   my ($title, $filter, $dir) = @_;
   my $file;

   $filter = "*" if !$filter;
   $dir = "." if !$dir;
  
   my $popup = $WIDGET{'main'}->FileSelect(
                                   -filter => "$filter",
                                   -directory => $dir,
                                   -takefocus => 1,
                                   -font => $Font{$DISPLAY_SIZE} 
                                );

   # configuration
   $popup->configure(-title => $title) if $title;
   $popup->configure(-filelabel => 'filelabel');
   $popup->configure(-filelistlabel => 'file list');
   $popup->configure(-dirlabel => "file filter");
   $popup->configure(-dirlistlabel => 'directory list');

   my $selection = $popup->Show;
   return $selection;
}

sub my_exit { exit 0; }

sub null_cmd { }

sub warn {
  my ($msg) = @_;
  print STDERR $msg;
}

sub debug {
  my ($msg) = @_;
  print STDERR $msg if $DEBUG >= 1;
}

sub help_message {
  my @msg;
  push @msg, "";
  push @msg, "Help Message => no help available yet!!";
  push @msg, "";
  return @msg;
}

sub bugs_message {
  my @msg;
  push @msg, "";
  push @msg, "Known Bugs";
  push @msg, "";
  push @msg, "Lots! Dont use this tool for anything other than as a demo!";
  return @msg;
}

sub about_message {
  my @msg;
  push @msg, "";
  push @msg, "The $TOOLNAME is a simple program to demonstrate how a";
  push @msg, "GUI might be written to use the Perl XDF package.";
  push @msg, ""; 
  push @msg, ""; 
  push @msg, "Disclaimer:";
  push @msg, ""; 
  push @msg, "This program MAY be useful one day as a viewer/editor, but"; 
  push @msg, "unlike the rest of the Perl XDF package, this sub-program is";
  push @msg, "NOT beta quality software (yet!!). Much of the needed functionality ";
  push @msg, "missing/incomplete and many bugs remain (!).";  
  push @msg, "";
  push @msg, ""; 
  push @msg, "Author: Brian Thomas";
  push @msg, "";
  push @msg, ""; 
  push @msg, "Licence:";
  push @msg, ""; 
  push @msg, "  guiview.pl Copyright (C) 2000 Brian Thomas,";
  push @msg, "  ADC/GSFC-NASA, Code 631, Greenbelt MD, 20771"; 
  push @msg, ""; 
  push @msg, "  This program is free software; it is licensed under the same terms"; 
  push @msg, "  as Perl itself is. Please refer to the file LICENSE which is contained"; 
  push @msg, "  in the distribution that this file came in."; 
  push @msg, ""; 
  push @msg, "  This program is distributed in the hope that it will be useful,"; 
  push @msg, "  but WITHOUT ANY WARRANTY; without even the implied warranty of";
  push @msg, "  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. "; 
  push @msg, ""; 
  push @msg, ""; 

  return @msg;
}

sub field_array_image {
  return '/* XPM */
static char * fieldarray_xpm[] = {
"12 12 4 1",
"       s None  c None",
".      c #000000000000",
"X      c #00000000FFFF",
"o      c #0000FFFF0000",
"            ",
" .......... ",
" .XX.XX.XX. ",
" .XX.XX.XX. ",
" .......... ",
" .oo.oo.oo. ",
" .oo.oo.oo. ",
" .......... ",
" .oo.oo.oo. ",
" .oo.oo.oo. ",
" .......... ",
"            "};';
} 

sub array_image {
   my $msg = '/* XPM */
static char * array_xpm[] = {
"12 12 3 1",
"       s None  c None",
".      c #000000000000",
"X      c #0000FFFF0000",
"            ",
" .......... ",
" .XX.XX.XX. ",
" .XX.XX.XX. ",
" .......... ",
" .XX.XX.XX. ",
" .XX.XX.XX. ",
" .......... ",
" .XX.XX.XX. ",
" .XX.XX.XX. ",
" .......... ",
"            "};';
  return $msg;
}

sub structure_image {
  return '/* XPM */
static char * structure_xpm[] = {
"12 12 3 1",
"       s None  c None",
".      c #000000000000",
"X      c #FFFF00000000",
"            ",
" ....       ",
" .XXX...... ",
" .XXXXXXXX. ",
" .XXXXXXXX. ",
" .XXXXXXXX. ",
" .XXXXXXXX. ",
" .XXXXXXXX. ",
" .XXXXXXXX. ",
" .XXXXXXXX. ",
" .......... ",
"            "};';
}

sub open_xml_element_node_image {
   return '/* XPM */
static char * struct_xpm[] = {
"12 12 3 1",
"       s None  c None",
"b      c #999555FFF",
".      c #000000000",
"            ",
"            ",
"    ...     ",
"    .b.     ",
"    .b.     ",
" ....b....  ",
" .bbbbbbb.  ",
" ....b....  ",
"    .b.     ",
"    .b.     ",
"    ...     ",
"            "};';
}




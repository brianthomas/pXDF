#!/usr/bin/perl -w -I ..
#/XDF/Perl_Package

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
                     Tk::DialogBox
                     Tk::FileSelect
                     XDF::Reader
                   );
  for(@modlist) {
    die "Could'nt load $_ module, please correct Perl path or install.\n" unless (eval "require $_" );
  }

}

use vars qw/$FILEIMG $FOLDIMG/;

# pragmas
use strict;

# program defs
my $VERSION = "0.5";
my $TOOLNAME = "XDF Viewer Tool";

# GLOBAL Variables
my $XDF;    # reference to the XDF object of interest
my $XDF_FILE; 
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
my $ROWAXIS;
my $COLAXIS;
my $LOCATOR;
my $PRETTY_XDF_OUTPUT = 1;
my $ARRAY_OSTYLE = 'Tagged';
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

my $CURRENT_STRUCTURE;
my $CURRENT_ITEM; # could be an array or structure that is selected from Hlist
my $ARRAY_ATTRIB_EDIT_OPEN;
my @ARRAYEDITFRAMES;
#my @SHARED_SUBFRAMES;
my @OSTYLE_SUBFRAMES;
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
my ( $Red ,$Green, $Blue, $Lite_blue, $Yellow, $Dark_green, $Grey, $Dark_grey, $Medium_grey, $Lite_grey, $White, $Black) =
   ("#c24","#8e7","#5ac",   "#7df"  , "#eea",  "#181"    ,"#bbb","#555"    ,"#888",   "#bbb",   "#eee", "#000");

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
my $StructureColor = $Red;
my $ArrayColor = $Green;
my $EventMouseOverColor = 'yellow';
my $ButtonFgColor = $Black;
my $ButtonBgColor = $White;

my $StructAttributeTitle = 'Structure Attributes';
my $ArrayAttributeTitle = 'Array Attributes';

my %Font = ( 'tiny'   => '-adobe-fixed-medium-r-normal--12-*-*-*-*-*-*-*', 
             'small'  => '-adobe-fixed-medium-r-normal--14-*-*-*-*-*-*-*',
             'normal' => '-adobe-fixed-medium-r-normal--18-*-*-*-*-*-*-*',
             'large'  => '-adobe-fixed-medium-r-normal--24-*-*-*-*-*-*-*'
           );

my %BoldFont  = ( 'tiny'   => '-adobe-helvetica-bold-r-normal--12-*-*-*-*-*-*-*',
                  'small'  => '-adobe-helvetica-bold-r-normal--14-*-*-*-*-*-*-*',
                  'normal' => '-adobe-helvetica-bold-r-normal--18-*-*-*-*-*-*-*',
                  'large'  => '-adobe-helvetica-bold-r-normal--24-*-*-*-*-*-*-*'
                );



# B E G I N  P R O G R A M 

  &argv_loop();

  # init section
  &init_gui();
  &init_mouse_bindings();
  &init_key_bindings();

  &load_xdf_file($XDF_FILE);

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
    $WIDGET{'main'}->bind('<Alt-Key-q>' => sub { &my_exit();} );
}

sub argv_loop { 

  #&usage() unless ($#ARGV > -1);

  while ($_ = shift @ARGV) {
   #  print $_, "\n";
    if(/-h/) { &usage();
    } elsif(/-q/) { $QUIET = 1; 
    } elsif(/-v/) { $DEBUG = 1; 
    } else {
      $XDF_FILE = $_;
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

  my $infoFrame    = $rightFrame->Frame->pack(expand => 0 ,fill => 'both', side => 'top');
  my $headerFrame = $rightFrame->Frame->pack(expand => 0, fill => 'both', side => 'top');
  my $sharedFrame = $rightFrame->Frame->pack(expand => 1, fill => 'both', side => 'bottom');

  my $listFrame = $leftFrame->Frame->pack(expand => 1, fill => 'both', side => 'top');
  my $listButtonFrame = $leftFrame->Frame->pack(expand => 1, fill => 'both', side => 'bottom');

  my $toolLabelFrame  = $topFrame->Frame->pack(side=> 'top', fill => 'both');
  my $fileNameFrame  = $topFrame->Frame->pack(side => 'top', fill => 'both');

  my $structureHeaderFrame  = $infoFrame->Frame->pack(side => 'top', fill => 'both');
  my $structureAttribEditFrame  = $structureHeaderFrame->Frame->pack(side => 'top', fill => 'both');
  my $arrayHeaderFrame  = $infoFrame->Frame->pack(side => 'top', fill => 'both');
  my $arrayAttribEditFrame  = $arrayHeaderFrame->Frame->pack(side => 'top', fill => 'both');

  # configure frames
  $menubarFrame->configure( relief => 'raised', bd => 2, bg => $BaseColor);
  $topFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $infoFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $toolLabelFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $arrayHeaderFrame ->configure ( relief => 'flat', bd => 2, bg => $ArrayColor);
  $arrayAttribEditFrame->configure ( relief => 'flat', bd => 2, bg => $BaseColor);
  $structureHeaderFrame ->configure ( relief => 'flat', bd => 2, bg => $StructureColor);
  $fileNameFrame ->configure ( relief => 'flat', bd => 2, bg => $BaseColor );
  $sharedFrame->configure( relief => 'flat', bd => 2, bg => $Black);

  # Widgets
  # menuBar Frame Widgets
  &create_program_menu($menubarFrame);

  $WIDGET{'ylist_scroll'} = $listFrame->Scrollbar()->pack(side => 'left', expand => 0, fill => 'y');
  $WIDGET{'xlist_scroll'} = $listFrame->Scrollbar(-orient => 'horizontal')->pack(side => 'bottom', expand => 0, fill => 'x');

  $FILEIMG = $WIDGET{'main'}->Bitmap(-file => Tk->findINC('file.xbm'));
  $FOLDIMG = $WIDGET{'main'}->Bitmap(-file => Tk->findINC('folder.xbm'));

  $WIDGET{'xml_hlist'} = $listFrame->HList(
                                            -separator => '/', 
                                            -width => 22,
                                            -itemtype => 'imagetext', 
                                            -font => $Font{$DISPLAY_SIZE},
                                          )->pack(fill => 'both', side=> 'top', expand => 0);

  $WIDGET{'xml_hlist'}->configure( -command => sub { &select_Hlist_item($_[0]); });
  $WIDGET{'xml_hlist'}->bind('<Button-1>' => sub { &select_Hlist_item($WIDGET{'xml_hlist'}->selectionGet()); });

  &add_horizontal_scrollbar_to_widget($WIDGET{'xml_hlist'},$listFrame,'left',$WIDGET{'ylist_scroll'});
  &add_vertical_scrollbar_to_widget($WIDGET{'xml_hlist'},$listFrame,'bottom',$WIDGET{'xlist_scroll'});

  $WIDGET{'list_addStruct_button'} = $listButtonFrame->Button(
                                                         -text => 'Add Structure', 
                                                         -fg => $ButtonFgColor, -bg => $ButtonBgColor,
                                                         -state => 'disabled', 
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, fill => 'y');
  $WIDGET{'list_delStruct_button'} = $listButtonFrame->Button(
                                                         -text => 'Delete Structure', 
                                                         -fg => $ButtonFgColor, -bg => $ButtonBgColor,
                                                         -state => 'disabled', 
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, fill => 'y');
  $WIDGET{'list_addArray_button'} = $listButtonFrame->Button(
                                                         -text => 'Add Array', 
                                                         -fg => $ButtonFgColor, -bg => $ButtonBgColor,
                                                         -state => 'disabled', 
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, fill => 'y');
  $WIDGET{'list_delArray_button'} = $listButtonFrame->Button(
                                                         -text => 'Delete Array', 
                                                         -fg => $ButtonFgColor, -bg => $ButtonBgColor,
                                                         -state => 'disabled', 
                                                         -font => $BoldFont{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, fill => 'y');
  $WIDGET{'tool_boldlabel'} = $toolLabelFrame->Label( text => $TOOLNAME,
                                              bg => $BaseColor, fg => $Black,
                                              font => $BoldFont{$DISPLAY_SIZE},
                                             )->pack(fill => 'x', side=> 'top' );

  $WIDGET{'file_label'} = $fileNameFrame->Label( text => "File Name:",
                                                 bg => $BaseColor, fg => $Black,
                                                 font => $Font{$DISPLAY_SIZE},
                                               )->pack(fill => 'x', side=> 'left' );

  $WIDGET{'struct_attrib_edit_label'} = $structureAttribEditFrame->Label( 
                                                 text => $StructAttributeTitle . ":[]",
                                                   bg => $BaseColor, fg => $Black,
                                                   bd => 2,
                                                 font => $Font{$DISPLAY_SIZE},
                                                    )->pack(fill => 'both', side=> 'top' );

  $WIDGET{'array_attrib_edit_label'} = $arrayAttribEditFrame->Label( text => $ArrayAttributeTitle . ":[]",
                                                      bg => $BaseColor, fg => $Black,
                                                      bd => 2,
                                                      font => $Font{$DISPLAY_SIZE},
                                                    )->pack(fill => 'both', side=> 'top' );

  $WIDGET{'array_attrib_edit_label'}->bind('<Enter>' => sub { $WIDGET{'array_attrib_edit_label'}->configure(-bg => $EventMouseOverColor); });
  $WIDGET{'array_attrib_edit_label'}->bind('<Leave>' => sub { $WIDGET{'array_attrib_edit_label'}->configure(-bg => $BaseColor); });
  $WIDGET{'array_attrib_edit_label'}->bind('<Double-Button-1>' => sub { &edit_array_attribs($arrayHeaderFrame); });

  $WIDGET{'array_edit_label'} = $sharedFrame->Label ( -text => 'Array Edit Functions', 
                                                      -font => $Font{$DISPLAY_SIZE},
                                               )->pack(fill => 'x', side=> 'top');

   $WIDGET{'shared_notebook'} = $sharedFrame->NoteBook( -dynamicgeometry => 'false',
                                                        -bg => $BaseColor,
                                                        -font => $Font{$DISPLAY_SIZE},
                                                      )->pack(side => 'top', expand => 1, 
                                                              fill => 'both');
   $WIDGET{'shared_notebook'}->add( 'Data', -label => 'Data',
                                    -raisecmd => sub { },
                                    -createcmd => sub { &init_table_gui(@_); },
                                  );

   $WIDGET{'shared_notebook'}->add( 'DFmt', -label => 'DataFormat',
                                    -raisecmd => sub { },
                                    -createcmd => sub { },
                                  );

   $WIDGET{'shared_notebook'}->add( 'Note', -label => 'Notes',
                                    -raisecmd => sub { },
                                    -createcmd => sub { &init_notelist_gui('Array', @_);},
                                  );

   $WIDGET{'shared_notebook'}->add( 'Out', -label => 'XMLDataIOStyle',
                                    -raisecmd => sub { },
                                    -createcmd => sub { &init_array_outputstyle_gui(@_); },
                                  );

   $WIDGET{'shared_notebook'}->add( 'Param', -label => 'Parameters',
                                    -raisecmd => sub { },
                                    -createcmd => sub { &init_parameterlist_gui('Array', @_);},
                                  );

   $WIDGET{'shared_notebook'}->add( 'Unit', -label => 'Units',
                                    -raisecmd => sub { },
                                    -createcmd => sub { &init_unitlist_gui('Array', @_);},
                                  );

  $FRAME{'shared'} = $sharedFrame;
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
   $WIDGET{$listboxname} = $subFrame1->Listbox(
                                            -font => $Font{$DISPLAY_SIZE},
                                           )->pack( side => 'top', expand => 1, fill => 'both');

   my $addbuttonname = $what . '_add' . $name . '_button';
   $WIDGET{$addbuttonname} = $subFrame2->Button (
                                            -text => "Add $name",
                                            -font => $Font{$DISPLAY_SIZE},
                                            -command => sub { &$addCodeRef; },
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
   return unless ($CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/);

   my $listbox = $WIDGET{'Array_Unitlist_listbox'};

   foreach my $unitObj (@{$CURRENT_ITEM->getUnits()->getUnitList()}) {
       my $name = 'Unit:';
       $name .= $unitObj->getValue() if defined $unitObj->getValue();
       $name .= ':';
       $name .= $unitObj->getPower() if defined $unitObj->getPower();
       $listbox->insert('end', $name);
   }

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
   return unless ($CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/);

   my $listbox = $WIDGET{'Array_Notelist_listbox'};

   foreach my $noteObj (@{$CURRENT_ITEM->getNoteList()}) {
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
   return unless ($CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/); 

   my $listbox = $WIDGET{'Array_Parameterlist_listbox'};

   foreach my $paramObj (@{$CURRENT_ITEM->getParamList()}) {
       my $name = 'Parameter:';
       $name .= $paramObj->getName() if defined $paramObj->getName();
       $listbox->insert('end', $name);
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

   for (@{XDF::XMLDataIOStyle->getXMLAttributes()}) {
       my $subFrame = $subFrame1->Frame->pack(side => 'top', fill => 'both', expand => 0);
       my $labelname = 'dataIOstyle' . $_ . "_label";
       my $entryname = 'dateIOstyle' . $_ . "_val_label";
       my $methodname = 'get' . ucfirst ($_);
       my $val = $CURRENT_ITEM->getXMLDataIOStyle()->$methodname;
       &make_label_click_widgets( $_, $subFrame, $labelname, $entryname, $val);
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

      for (@{$CURRENT_ITEM->getAxisList()}) 
      {
         my $thisFrame = $subFrame->Frame->pack(side => 'top');
         my $axisId = $_->getAxisId();
         my $tagName = $CURRENT_ITEM->getXMLDataIOStyle()->getAxisTag($axisId);
         my $labelname = 'dataIOstyle' . $axisId . "tag_label";
         my $entryname = 'dataIOstyle' . $axisId . "tag_val_label";
         my $label = "Axis Tag ($axisId):";
         &make_label_click_widgets( $label, $thisFrame, $labelname, $entryname, $tagName);
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
         my $val = "";
         &make_label_click_widgets( $_, $thisFrame, $labelname, $entryname, $val);
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

sub make_label_click_widgets {
   my ($text, $frame, $labelname, $entryname, $entryVal ) = @_;

   $WIDGET{$labelname} = $frame->Label( text => $text,
                            bg => $BaseColor, fg => $Black,
                            font => $Font{$DISPLAY_SIZE},
                          )->pack(fill => 'x', side=> 'left' );

   $entryVal = "" unless defined $entryVal;
   $WIDGET{$entryname} = $frame->Label( text => $entryVal,
                            bg => $BaseColor, fg => $Black,
                            width => 25,
                            justify => 'left',
                            font => $Font{$DISPLAY_SIZE},
                          )->pack(fill => 'x', side=> 'left', expand => 1 );

   # init mouse bindings
   $WIDGET{$entryname}->bind('<Enter>' => sub { $WIDGET{$entryname}->configure( -bg => $EventMouseOverColor); });
   $WIDGET{$entryname}->bind('<Leave>' => sub { $WIDGET{$entryname}->configure( -bg => $BaseColor); });

}

sub init_table_gui {
  my ($mainFrame) = @_;

  &clear_shared_frame();

  # frames
  my $leftFrame = $mainFrame->Frame->pack(expand => 0, fill => 'both', side => 'left');
  my $rightFrame = $mainFrame->Frame->pack(expand => 1, fill => 'both', side => 'left');

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

  # widgets

  $WIDGET{'horzAxisInfo_boldlabel'} = $horzAxisInfoFrame->Label( text => '', 
                                                -font => $BoldFont{$DISPLAY_SIZE},
                                                bg => $AxisBoxColor,
                                             )->pack( expand => 1, fill => 'x');


   $WIDGET{'horzAxisInfo_boldlabel'}->bind('<Enter>' => sub { $WIDGET{'horzAxisInfo_boldlabel'}->configure( -bg => $EventMouseOverColor); } );
   $WIDGET{'horzAxisInfo_boldlabel'}->bind('<Leave>' => 
                                    sub { my $c = &get_horzAxisColor(); $WIDGET{'horzAxisInfo_boldlabel'}->configure(bg => $c); } );

  my $listBoxFrame = $tableFrame->Pane( -sticky => 'nsew'
                                      )->pack( expand => 1, side => 'top', fill => 'both');

  $listBoxFrame->configure (relief => 'flat', bd => 2, bg => $Lite_grey); 

  $WIDGET{'vertAxisInfo_boldlabel'} = $vertAxisInfoFrame->Label( text => '',
                                                -width => 2,
                                                -font => $BoldFont{$DISPLAY_SIZE},
                                                bg => $AxisBoxColor,
                                                #-orient => 'horizontal',
                                             )->pack( expand => 1, side => 'left', fill => 'y');
   $WIDGET{'vertAxisInfo_boldlabel'}->bind('<Enter>' => sub { $WIDGET{'vertAxisInfo_boldlabel'}->configure( -bg => $EventMouseOverColor); } );
   $WIDGET{'vertAxisInfo_boldlabel'}->bind('<Leave>' => sub { my $c = &get_vertAxisColor(); $WIDGET{'vertAxisInfo_boldlabel'}->configure(bg => $c); } );

  # the 'row' listbox
  $FRAME{'row_listbox'}->configure ( relief => 'flat', bd => 2, bg => 'white'); 

  # some filler for the top right frame
  $WIDGET{'filler1_boldlabel'} = $leftTopFrame->Label( -text => ' ', -font => $BoldFont{$DISPLAY_SIZE},
                        -bg => $BaseColor,
                      )->pack(expand => 'no', side => 'top', fill => 'both');

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
 
   # note this will cause problems if we ever allow display
   # of a field axis along the vertical
   if (defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/ 
       && defined $CURRENT_ITEM->getFieldAxis()) {
       $color = $FieldAxisBoxColor;
   }

   return $color;
}

sub get_vertAxisColor {
   my $color = $AxisBoxColor;

   # note this will cause problems if we ever allow display
   # of a field axis along the vertical
   return $color;
}

sub clear_shared_frame {

#  while ((my $item = pop @SHARED_SUBFRAMES)) { $item->destroy(); }

}

sub select_Hlist_item { 
   my ($path) = @_;

   return unless defined $path;

   # print STDERR "Double click path=$path, data=",$item,"\n";
   my $item = $WIDGET{'xml_hlist'}->info('data', $path);
   my $parentItem = $WIDGET{'xml_hlist'}->info('parent', $path);
   my $parentStruct = $XDF;
   $parentStruct = $WIDGET{'xml_hlist'}->info('data', $parentItem) if (defined $parentItem);
 
   $CURRENT_STRUCTURE = $parentStruct;
   $CURRENT_ITEM = $item;

   if ($CURRENT_ITEM =~ m/Array/) {
      $ARRAY_OSTYLE = $XMLDataIOStyle{ref($CURRENT_ITEM->getXMLDataIOStyle)};
   } else {
      $ARRAY_OSTYLE = undef;
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

   if ($ARRAY_ATTRIB_EDIT_OPEN) {
      &update_array_edit_attrib_val();
   }

}

# change various button, lever, etc. spaces based on 
# what is being viewed.
sub configure_gui_view {
   my ($type) = @_;

   &debug("configure_gui_view\n");

   my @showArrayWidgets =  (
                                $WIDGET{'list_delArray_button'},
                           ); 

   my @showStructWidgets = (
                                $WIDGET{'list_addStruct_button'}, 
                                $WIDGET{'list_delStruct_button'}, 
                                $WIDGET{'list_addArray_button'}, 
                           ); 

   if (defined $type) {
      if ($type =~ m/Array/) {
         for (@showArrayWidgets) { $_->configure(-state => 'normal'); }
         for(@showStructWidgets) { $_->configure(-state => 'disabled'); }
      } else { 
         for(@showStructWidgets) { $_->configure(-state => 'normal'); }
         for(@showArrayWidgets) { $_->configure(-state => 'disabled'); }
      }
   } else { 
      # its all disabled
      for(@showArrayWidgets) { $_->configure(-state => 'disabled'); }
      for(@showStructWidgets) { $_->configure(-state => 'disabled'); }
   }

}

sub update_hlist_from_xdf {
   my ($widget) = @_;

   # clear widget entries
   $widget->delete('all');
   &show_structure_in_Hlist($widget, $XDF, $XDF, 'Structure:XDF') if defined $XDF;
}

sub show_structure_in_Hlist {
  my ($widget, $structObj, $path, $text) = @_;

  $widget->add($path, -text => $text, 
                      -image => $FOLDIMG,
                      -data => $structObj);

  foreach my $sObj (@{$structObj->getStructList()}) {
     &show_structure_in_Hlist($widget, $sObj, "$path/$sObj", 'Structure:'.$sObj->getName());
  }

  foreach my $arrayObj (@{$XDF->getArrayList()}) {
     my $name = $arrayObj->getName();
     $name = 'Array:' . $name;
     $widget->add("$path/$arrayObj", 
                  -text => $name, -image => $FILEIMG, 
                  -data => $arrayObj);
  }

}

sub change_ostyle {

   my $obj = eval "new $XMLDataIOStyleClass{$ARRAY_OSTYLE}"; 
   $CURRENT_ITEM->setXMLDataIOStyle($obj);

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

sub create_program_menu {
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

   $WIDGET{'load_menu'} = $menu->command( -label => 'Load',
                                                 font => $Font{$DISPLAY_SIZE},
                                                 bg => $BaseColor,
                                                 command => sub {  
                                                                   &load_xdf_file(&select_file("Load which file?","*.xml")); 
                                                                }
                                               );

  $menu->separator(bg => $BaseColor);

   $WIDGET{'save_menu'} = $menu->command( -label => 'Save',
                                                 font => $Font{$DISPLAY_SIZE},
                                                 bg => $BaseColor,
                                                 command => sub { &my_exit; }
                                               );

   $WIDGET{'save_as_menu'} = $menu->command( -label => 'Save As',
                                                    font => $Font{$DISPLAY_SIZE},
                                                    bg => $BaseColor,
                                                    command => sub { &save_xdf_file(&select_file("Save as file?","*.xml"));}
                                                  );


   $menu->separator(bg => $BaseColor);

   my $menu_cb = 'Pretty File Output';
   $WIDGET{'pretty_file_output_menu'} =
           $menu->cascade(-label => $menu_cb, bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
   my $cm = $menu->cget(-menu);
   my $cc = $cm->Menu;
   $menu->entryconfigure($menu_cb, -menu => $cc);
   $WIDGET{'file_pretty_output_true_menu'} = $cc->command(-label => ' True ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -command => sub {
                                                                         $PRETTY_XDF_OUTPUT = 1;
                                                                     });
    $WIDGET{'file_pretty_output_false_menu'} = $cc->command(-label => ' False ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -command => sub {
                                                                         $PRETTY_XDF_OUTPUT = 0;
                                                                     });

   $menu->separator(bg => $BaseColor);

   # the quit button
   $WIDGET{'quit_menu'} = $menu->command(-label => 'Quit',
                                             font => $Font{$DISPLAY_SIZE},
                                             bg => $BaseColor,
                                            -command => sub { &my_exit; }
                                           );


}

sub create_view_menu {
  my ($menu) = @_;

  my $menu_cb = 'Change Tool Display Size';
  $WIDGET{'size_cascade_options_menu'} =
           $menu->cascade(-label => $menu_cb, bg => $BaseColor, -font => $Font{$DISPLAY_SIZE});
    my $cm = $menu->cget(-menu);
    my $cc = $cm->Menu;
    $menu->entryconfigure($menu_cb, -menu => $cc);
    $WIDGET{'opt_size_cas_large_menu'} = $cc->command(-label => '  Large (1600x1200) ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -command => sub { 
                                                                         $DISPLAY_SIZE = 'large';
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                     });
    $WIDGET{'opt_size_cas_normal_menu'} = $cc->command(-label => '  Normal (1240x1024) ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -command => sub { 
                                                                         $DISPLAY_SIZE = 'normal';
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                     });
    $WIDGET{'opt_size_cas_small_menu'} = $cc->command(-label => '  Small (1024x768) ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -command => sub { 
                                                                         $DISPLAY_SIZE = 'small';
                                                                         &change_display_size($DISPLAY_SIZE);
                                                                     });
    $WIDGET{'opt_size_cas_tiny_menu'} = $cc->command(-label => '   Tiny (800x600)  ',
                                                     -font => $Font{$DISPLAY_SIZE},
                                                      bg => $BaseColor,
                                                     -command => sub { 
                                                                         $DISPLAY_SIZE = 'tiny';
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


sub load_xdf_file {
   my ($file) = @_;

   return unless defined $file && -e $file;

   &debug("loading $file\n");

   my %options = ('quiet' => $QUIET, 'debug' => $DEBUG, );
   # set the new XDF object
   $XDF = &XDF::Reader::createXDFObjectFromFile($file, \%options);

   # update the widgets
   $WIDGET{'file_label'}->configure(text => "File Name: $file");

   &update_hlist_from_xdf($WIDGET{'xml_hlist'});

   $CURRENT_STRUCTURE = undef;
   $CURRENT_ITEM = undef;
   # we default the view to the first array, should it exist 

   &update_view();

}

sub save_xdf_file {
  my ($file) = @_;

  &debug("save $XDF_FILE\n");

  return unless defined $file;

#   &pop_warning_of_overwritting_file() if (-e $file);

  $XDF_FILE = $file;

  # update the widgets
  $WIDGET{'file_label'}->configure(text => "File Name: $file");

  open(FILE, ">$file");
  $XDF->Pretty_XDF_Output($PRETTY_XDF_OUTPUT);  # whether to use pretty print 
 # $XDF->Pretty_XDF_Output_Indentation($PRETTY_XDF_INDENTATION);  # use 3 spaces for indentation
  $XDF->toXMLFileHandle(\*FILE);
  close FILE;

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
   my $width = $arrayObj->getDataFormat()->numOfBytes();

   my $first_axis = $arrayObj->getAxisList()->[0];
   my $axisInfo = $first_axis->getName();
   $axisInfo = "" unless defined $axisInfo;
   $axisInfo .= " (" . $first_axis->getLength() . ")";
   $WIDGET{'horzAxisInfo_boldlabel'}->configure( text => "Axis:$axisInfo", 
                                                  bg => $AxisBoxColor,
                                               );

   my $second_axis = $arrayObj->getAxisList()->[1];
   $axisInfo = $second_axis->getName();
   $axisInfo = "" unless defined $axisInfo;
   $axisInfo = "Axis $axisInfo (" . $second_axis->getLength() . ")";
   $axisInfo =~ s/(.)/$1\n/g;
   $WIDGET{'vertAxisInfo_boldlabel'}->configure ( text => $axisInfo, 
                                               bg => $AxisBoxColor,
                                             );

   # geometry of the widget: a 'row' listbox followed by fieldlistboxes
   my @axisOrder = reverse @{$arrayObj->getAxisList()};
   $LOCATOR->setIterationOrder(\@axisOrder);
   foreach my $col (0 ... ($first_axis->getLength()-1)) {

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
      while ($LOCATOR->hasNext() && $LOCATOR->getAxisIndex($first_axis) == $col) {
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

sub edit_array_attribs {
   my ($frame) = @_;

   return unless defined $CURRENT_ITEM && $CURRENT_ITEM =~ m/Array/;

   if ($ARRAY_ATTRIB_EDIT_OPEN) {
      &close_array_attrib_edit();
      return;
   }

   $ARRAY_ATTRIB_EDIT_OPEN = 1;

   $WIDGET{'array_attrib_edit_label'}->configure( -text => '<<Click to Close Array Attributes>>');

   # create widgets
   for (@ArrayAttribList) {
       my $subFrame = $frame->Frame->pack(side => 'top', fill => 'both', expand => 0);
       push @ARRAYEDITFRAMES, $subFrame;
       my $labelname = 'array' . $_ . "_label";
       my $entryname = 'array' . $_ . "_val_label";
       &make_label_click_widgets( $_, $subFrame, $labelname, $entryname); 
   }

   # update value of widgets
   &update_array_edit_attrib_val();
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

  $WIDGET{'array_attrib_edit_label'}->configure( -text => $arrTitle);

  $ARRAY_ATTRIB_EDIT_OPEN = 0;
  return;

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

  $LOCATOR->setAxisIndex($ROWAXIS, $index);
  $LOCATOR->setAxisIndex($COLAXIS, $colIndex);

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

   $ARRAY = defined $obj && $obj =~ m/Array/ ? $obj : undef;

   if (defined $ARRAY) {
     $LOCATOR = $ARRAY->createLocator();
     $COLAXIS = $ARRAY->getAxisList()->[0];
     $ROWAXIS = $ARRAY->getAxisList()->[1];
   } else { 
     $LOCATOR = undef;
     $COLAXIS = undef;
     $ROWAXIS = undef;
   }

}

sub reset_table_view {

   &debug("reset_table_view()\n");

   $WIDGET{'horzAxisInfo_boldlabel'}->configure( text => "Axis:", 
                                                  bg => $AxisBoxColor,
                                               ) if defined $WIDGET{'horzAxisInfo_boldlabel'}; 

   $WIDGET{'vertAxisInfo_boldlabel'}->configure ( text => "A\nx\ni\ns",
                                                  bg => $AxisBoxColor,
                                               ) if defined $WIDGET{'vertAxisInfo_boldlabel'};

   $WIDGET{'shared_notebook'}->pageconfigure( 'DFmt', -state => 'normal');
   $WIDGET{'shared_notebook'}->pageconfigure( 'Unit', -state => 'normal');

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
   $WIDGET{'shared_notebook'}->pageconfigure( 'DFmt', -state => 'disabled');
   $WIDGET{'shared_notebook'}->pageconfigure( 'Unit', -state => 'disabled');
   if ( $WIDGET{'shared_notebook'}->raised eq 'DFmt' ||
        $WIDGET{'shared_notebook'}->raised eq 'Unit' ) 
   {
       $WIDGET{'shared_notebook'}->raise('Data');
   }

   my $fieldAxis = $arrayObj->getFieldAxis();
   $COLAXIS = $fieldAxis;
   $ROWAXIS = $arrayObj->getAxisList()->[1];

   my $axisInfo = $fieldAxis->getName();
   $axisInfo = "" unless defined $axisInfo;
   $axisInfo .= " (" . $fieldAxis->getLength() . " fields)";
   $WIDGET{'horzAxisInfo_boldlabel'}->configure( text => "Field Axis:$axisInfo", 
                                                 bg => $FieldAxisBoxColor);

   my $second_axis = $arrayObj->getAxisList()->[1];
   $axisInfo = $second_axis->getName();
   $axisInfo = "" unless defined $axisInfo;
   $axisInfo = "Axis $axisInfo (" . $second_axis->getLength() . ")";
   $axisInfo =~ s/(.)/$1\n/g;
   $WIDGET{'vertAxisInfo_boldlabel'}->configure ( text => $axisInfo,
                                               bg => $AxisBoxColor,
                                             );



   $FRAME{'listBox'}->configure(-height => 30, -width => 100);


   # we need to change the default iteration order
   my @axisOrder = ($second_axis, $fieldAxis);
   $LOCATOR->setIterationOrder(\@axisOrder);

   my $col = 0;
   # geometry of the widget: a 'row' listbox followed by fieldlistboxes
   foreach my $fieldObj (@{$fieldAxis->getFields()}) 
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
  return @msg;
}

sub about_message {
  my @msg;
  push @msg, "";
  push @msg, "The $TOOLNAME is a simple program to demonstrate how a";
  push @msg, "GUI might be written to use the Perl XDF package.";
  push @msg, "";
  push @msg, "Author: Brian Thomas";
  return @msg;
}


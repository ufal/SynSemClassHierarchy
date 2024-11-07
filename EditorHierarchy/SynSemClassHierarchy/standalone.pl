#!/usr/bin/perl -I.. -I../..
use Getopt::Std;

getopts('pc:hMDP');

if ($opt_h) {
  print "Usage: $0 [options] <path_to_vallexes>\n";
  print "   -p          profiling run (do not enter Mainloop)\n";
  print "   -c <count>  number of time to re-run initialization (use with -p)\n";
  print "   -h          this help\n";
  print "   -D          reviewer may delete existing records (brutal force)\n";
  print "   -M          reviewer may modify existing records (brutal force)\n";
  print "   -P          display lists of problems for classes\n";
  exit 0;
}

use FindBin;
my $binDir=$FindBin::RealBin;
my $tkLibDir = "../";

push @INC,$tkLibDir; 

use Tk;
use Tk::Wm;
require Tk::BindMouseWheel;

require locale;
use POSIX qw(locale_h);
setlocale(LC_COLLATE,"cs_CZ");
setlocale(LC_NUMERIC,"us_EN");
#setlocale(LANG,"czech");

#setlocale(LC_ALL, 'cs_CZ');

package Tk::Wm;
# overwriting the original Tk::Wm::Post:
sub Post
{
 my ($w,$X,$Y)= @_;
 $X= int($X);
 $Y= int($Y);
 $w->positionfrom('user');
 $w->MoveToplevelWindow($X,$Y);
 $w->deiconify;
}

package main;

require strict;
require Tk::Adjuster;
require SynSemClassHierarchy::Data;

$XMLData_main ="SynSemClassHierarchy::LibXMLData_main";
$XMLData_cms ="SynSemClassHierarchy::LibXMLData_cms";
$XMLData_hierarchy ="SynSemClassHierarchy::LibXMLData_hierarchy";
$Data_multi="SynSemClassHierarchy::Data_multi";
require SynSemClassHierarchy::LibXMLData_main;
require SynSemClassHierarchy::LibXMLData_cms;
require SynSemClassHierarchy::LibXMLData_hierarchy;

require SynSemClassHierarchy::Widgets;
require SynSemClassHierarchy::Editor;
require SynSemClassHierarchy::Hierarchy;
require SynSemClassHierarchy::InOut;
require SynSemClassHierarchy::Config;
require SynSemClassHierarchy::Data_multi;


use POSIX qw(locale_h);
setlocale(LC_NUMERIC,"C");
setlocale(LC_COLLATE, "cs_CZ.utf8");
setlocale(LANG, "cs_CZ.utf8");

SynSemClassHierarchy::Config->loadConfig();
SynSemClassHierarchy::Config->loadCodeTable();

my @langs= SynSemClassHierarchy::Config->getLanguages();

my %data_files=();
my $data_multi=$Data_multi->new();

$data_multi->set_languages(@langs);
	
$data_files{main} = (defined $ARGV[0] ? $ARGV[0] . "/synsemclass_main.xml" : SynSemClassHierarchy::Config->getFromResources("synsemclass_main.xml"));
die ("Can not read file synsemclass_main.xml") unless (-e $data_files{main});
$data_multi->set_main($XMLData_main->new($data_files{main},1));
$data_multi->main->set_languages(@langs);

$data_files{hierarchy} = (defined $ARGV[0] ? $ARGV[0] . "/synsemclass_hierarchy.xml" : SynSemClassHierarchy::Config->getFromResources("synsemclass_hierarchy.xml"));
die ("Can not read file synsemclass_hierarchy.xml") unless (-e $data_files{hierarchy});
$data_multi->set_hierarchy($XMLData_hierarchy->new($data_files{hierarchy},1));
$data_multi->hierarchy->set_user($data_multi->main->user);

foreach my $lang (@langs){
	my $file = "synsemclass_" . $lang . "_cms.xml";
	$data_files{$lang} = (defined $ARGV[0] ? $ARGV[0] . "/" . $file : SynSemClassHierarchy::Config->getFromResources($file));
	die ("Can not read file $file") unless (-e $data_files{$lang});
	$data_multi->set_lang_cms($lang, $XMLData_cms->new($data_files{$lang},1));
	$data_multi->lang_cms($lang)->set_user($data_multi->main->user);
	$data_multi->lang_cms($lang)->set_languages($lang);

	my $p = "SynSemClassHierarchy::" . uc($lang) . "::Resources";
	eval "require $p";
	if ($@) {
		die $@;
	}
	$p->read_resources();
}


$opt_c = 1 unless defined($opt_c);

$SynSemClassHierarchy::Editor::reviewer_can_delete = $opt_D || 1;
$SynSemClassHierarchy::Editor::reviewer_can_modify = $opt_M || 1;
$SynSemClassHierarchy::Editor::display_problems = $opt_P;

while ($opt_c--) {
  my $top;
  do {
    my $font = "-adobe-helvetica-medium-r-*-*-12-*-*-*-*-*-iso8859-2";
    my $small_font = "-adobe-helvetica-medium-r-*-*-12-*-*-*-*-*-iso8859-2";
    my $fc=[-font => $font];
    my $fe_conf={ elements => $fc,
		  problem => $fc,
		};
    my $vallex_conf = {
		       classlist => { classlist => $fc, search => $fc},
		       classproblem => $fc,
		       infoline => { label => $fc }
		      };
    $top=Tk::MainWindow->new();
	$top->geometry(SynSemClassHierarchy::Config->getGeometry());
    $top->option('add',"\*Button.font", $small_font);
    $top->option('add',"\*Button.highlightbackground", 'red');
    $top->option('add',"\*Checkbutton.font", $small_font);
    $top->useinputmethods(1);

    my $top_frame = $top->Frame()->pack(qw/-expand yes -fill both -side top/);


    my $vallex= SynSemClassHierarchy::Editor->new_multi($data_multi, undef,$top_frame,0,
					  $fc, # classlist items
					  $fc, # classmemberlist items
					  $fe_conf);
    $vallex->subwidget_configure($vallex_conf);
    $vallex->pack(qw/-expand yes -fill both -side left/);
    $top->title("SynEd: ".$data_multi->lang_cms($data_multi->get_priority_lang)->getUserName($data_multi->main->user()));

    my $bottom_frame = $top->Frame()->pack(qw/-expand no -fill x -side bottom/);

    my $save_button=$bottom_frame->Button(-text => "Save",
					  -command => sub {
					    $vallex->save_data($top);
					  })->pack(qw/-side right -pady 10 -padx 10/);

    my $reload_button=
      $bottom_frame->Button(-text => "Reload",
			    -command => sub {
					$vallex->reload_data($top);
				})->pack(qw/-side right -pady 10 -padx 10/);

	my $export_button=$bottom_frame->Button(-text => "Export data",
												-command => [sub {my ($self)=@_;
														SynSemClassHierarchy::InOut::exportData($self);
													}, $vallex])
								->pack(qw/-side right -pady 10 -padx 10/);

   if ($data_multi->main->user() eq "SYS"){					
	   my $import_button=$bottom_frame->Button(-text => "Import",
											   -command =>[sub { my ($self)=@_;
													   SynSemClassHierarchy::InOut::importData($self);
												   }, $vallex])
											   
											   #[\&import_buttddon_pressed,$self])
								->pack(qw/-side right -pady 10 -padx 10/);

	   require SynSemClassHierarchy::Check;
	   my $check_button=$bottom_frame->Button(-text => "Check",
											   -command =>[sub { my ($self)=@_;
													   SynSemClassHierarchy::Check::check($self);
												   }, $vallex])
								->pack(qw/-side right -pady 10 -padx 10/);
	}

    my $quit_button=$bottom_frame->Button(-text => "Quit",
                                          -command =>
                                          [sub { my ($self,$top)=@_;
			                         $self->ask_save_data($top)
			                           if ($self->data()->changed());
									 SynSemClassHierarchy::Config->saveConfig($top);
			                         $top->destroy();
			                         undef $top;
			                        },$vallex,$top]
                     )->pack(qw/-side left -pady 10 -padx 10/);

    $top->protocol('WM_DELETE_WINDOW'=> 
		   [sub { my ($self,$top)=@_;
			  $self->ask_save_data($top)
			    if ($self->data()->changed());
			  SynSemClassHierarchy::Config->saveConfig($top);
			  $top->destroy();
			  undef $top;
			},$vallex,$top]);
    print "starting editor\n";

    if ($opt_p) {
      $top->Popup();
      $top->destroy() if ref($top);
    } else {
      eval {
	MainLoop;
      };
      print "$@\n";
      die $@ if $@;
      exit;
    }
  };
}



1;



#!/usr/bin/perl

#####################################
# Packages
#####################################
	use strict "refs";
	use English;
	use Time::localtime;
	use Getopt::Long;
	use Cwd ;
	use File::Basename;
	use Term::ANSIColor qw(:constants);
	use Switch;
	use Getopt::Mixed;
	use FindBin;                # where was script installed?
	use lib $FindBin::Bin;      # use that dir for libs, too
	use Data::Dumper;
#####################################
# Global
#####################################
	my $SCR = $ENV{'scripts'};
	require $SCR.'/common.pl';

	# print RED. "Stop!\n". RESET;
	# print GREEN. "Go!\n". RESET;

   



#{ <--<> Main
   # signature();   
   # GetTimeAndPrint();

    call_history(); 
	get_command_line_options();
	
	initialize();

	setup_libraries();
	clean_libraries();
	setup_directories();
	compilation ();
	set_waveform();
	optimization( $TB_TOP );
	simulation  ( $TB_TOP );

	view_waveform();

	# PrintErrMsg(__LINE__, 2, "sss", "ddd");

	# End(0);   
#} >--<> Main
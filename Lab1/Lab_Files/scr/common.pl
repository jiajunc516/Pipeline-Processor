#! /usr/bin/perl -w

#{ <--<> Packages
use strict "refs";
use English;
use Time::localtime;
use Getopt::Long;
use Cwd ;
use File::Basename;
use Term::ANSIColor qw(:constants);
use Switch;
# use Getopt::Mixed;
use FindBin;                # where was script installed?
use lib $FindBin::Bin;      # use that dir for libs, too
use Data::Dumper;
#use Util;
#} >--<> Packages

#{ <--<> Constants & Global Variables
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$SimStart);
    my $LINESTART         = " "x2;
    my $LOC               =  `pwd`;
       $LOC               =~ s/[\r\n]//g;
    my $USER              = `whoami`;   
    my $sim               = $ENV{'run'};
    my $test_loc          = $ENV{'verif'}."/test";
    my $test_loc          = $ENV{'verif'}."/test/bin";
    my $base_cfg_filename = "$sim/cfg/default.cfg";
    my $FN_RUN_HISTORY    = ".run_history";
    my $LOGDIR            = "logs";
    my $GCCCOMPCMD        = "gcc";
    my $VLOGCOMPCMD       = "vlog";
    my $VHDLCOMPCMD       = "vcom";
    my $OPTCMD            = "vopt";
    my $SIMCMD            = "vsim";
    my $WLFVIEWER         = "vsim";
    my $VISVIEWER         = "visualizer";
    my $VISVIEWERABBR     = "vis";
    my $WAVEVIEWER        = $WLFVIEWER;
    my $VIS_DESIGN_DB     = "design.db";
    my $WLF_NAME          = "waveform.wlf";
    my $VWAVE_PREFIX      = "qwave";
    my $VWAVE_ARGS        = "+signal+class+uvm_schematic+assertion+memory";

	my $lib_loc           = "questa";
	my @libraries         = ();
	# push( @libraries, work                       ); # Default library
	push( @libraries, mem_cells                  );
	
    our $DUT_TOP;
    our $TB_TOP;

    my @rtl_cfg_arg  = ();  
    my  @tb_cfg_arg  = ();  
    my @mod_cfg_arg  = ();  
    my @opt_cfg_arg  = ();  
    my @sim_cfg_arg  = ();  
    
    my @rtl_test_arg = ();  
    my  @tb_test_arg = ();  
    my @mod_test_arg = ();  
    my @opt_test_arg = ();  
    my @sim_test_arg = ();  
    
    my @rtl_user_arg = ();  
    my  @tb_user_arg = ();  
    my @mod_user_arg = ();  
    my @opt_user_arg = ();  
    my @sim_user_arg = ();  
    
    
    %options = ();
    $options{'comp_lib'}   = 0;
    $options{'comp_rtl'}   = 0;
    $options{'comp_tb'}    = 0; 
    $options{'opt'}        = 0;
    $options{'setlib'}     = 0;
    $options{'testname'}   = "default";
    $options{'visualizer'} = 0;
	
	
    my @vhdl_library_path = (
                        );        
	
    my @vhdl_library_name = qw( 
							);
	
    my @cell_library_path = ( $ENV{'sim_top'}."/../cell_sources.list"  );        
	
    my @cell_library_name = qw(  mem_cells );	
#} >--<> 

#{ <--<> Subroutines
### Features to come:
#*      File-lister
#*      check if the test dir exists
#*      WLF vs Visualizer 
#*      Comp logs --> ??


# sub get_command_line_options{

   # Getopt::Mixed::init( 'h L:s S:s C=s O T=s 1=i 2=s 3=s 4=s 5=s V W:s sim_args>5 wave>W visualizer>V tb_args>3 rtl_args>4 comp_args>2 seed>1 test>T sim>S setlib>L comp>C opt>O help>h');
   # printf("\n");
   # while( my( $option, $value, $pretty ) = Getopt::Mixed::nextOption() ) {
      # OPTION: {
         # $option eq 'h' and do {
            # print_help();
            # exit;
            # last OPTION;
         # };
         # $option eq 'C' and do {
            # if($value){
                # my @line = split(":", $value);
                # foreach(@line){
                    # if( $_ eq "lib" ){
                        # $options{'comp_lib'} = 1;
                    # }elsif( $_ eq "rtl" ){
                        # $options{'comp_rtl'} = 1;
                    # }elsif( $_ eq "tb" ){
                        # $options{'comp_tb'}  = 1;
                    # }elsif( $_ eq "mod" ){
                        # $options{'comp_model'}  = 1;
                    # }
                # }
            # } else{
                # $options{'comp_lib'}    = 1;
                # $options{'comp_rtl'}    = 1;
                # $options{'comp_tb'}     = 1;
                # $options{'comp_model'}  = 1;
            # }
            # last OPTION;
         # };
         # $option eq 'O' and do {
            # $options{'opt'} = 1;            
            # last OPTION;
         # };
         # $option eq 'L' and do {
            # $options{'setlib'} = 1;         
            # last OPTION;
         # };
         # $option eq 'S' and do {
            # $options{'sim'} = 1;            
            # last OPTION;
         # };
         # $option eq '5' and do {
            # push( @sim_user_arg, $value );            
            # last OPTION;
         # };
         # $option eq 'T' and do {
            # $options{'testname'} = $value if($value);
            # my $test_full_path = $test_loc.'/'.$options{'testname'}.'/'.$options{'testname'}.".txt";
            # if ( -f $test_full_path ){
                # push( @sim_user_arg, "+TEST=".$test_loc.'/'.$options{'testname'}.'/'.$options{'testname'}.".txt" );
                # push( @sim_user_arg, "+TESTNAME=".$options{'testname'} );
            # } else {
                # my $cmd = "ls -ltr ".$test_loc." | awk '{print \$9}' ";
                # system($cmd);
                # PrintErrMsg(__LINE__, 2, "ERROR", "Test " . $test_full_path . " doesn't exist.");
            # }
            # last OPTION;
         # };
         # $option eq '1' and do {
            # if($value){
                # $options{'seed'} = $value ; 
            # }else{
                # $options{'seed'} = gen_seed();
            # }   
            # push( @sim_user_arg, "-sv_seed ".$options{'seed'} );
            # last OPTION;
         # };
         # $option eq '2' and do {
            # push( @rtl_user_arg, $value );
            # push( @tb_user_arg , $value );
            # last OPTION;
         # };
         # $option eq '3' and do {
            # push( @tb_user_arg , $value );
            # last OPTION;
         # };
         # $option eq '4' and do {
            # push( @rtl_user_arg, $value );
            # last OPTION;
         # };
         # $option eq 'V' and do {
            # $options{'visualizer'} = 1;
            # $options{'opt'}        = 1;
            # last OPTION;
         # };
         # $option eq 'W' and do {
            # $options{'waveform'} = 1;
            
            # if( $value eq $VISVIEWERABBR){
                # $WAVEVIEWER = $VISVIEWER;
            # }elsif( $value eq $WLFVIEWER){ 
                # $WAVEVIEWER = $WLFVIEWER;
            # }   
            # last OPTION;
         # };
      # };
   # }
   # Getopt::Mixed::cleanup();
   # # die "No project specified via -j.\n" unless $Project;
# }

sub get_command_line_options {

  if(@ARGV == 0) {
     print_help();
     exit;
  } else {
     @all_argv = @ARGV;

     $return_val = GetOptions(
         'help|h'         => sub { print_help(); exit;},
         'comp|C:s'       => sub {   if($_[1]){
                                        my @line = split(":", $_[1]);
                                        foreach(@line){
                                            if( $_ eq "lib" ){
                                                $options{'comp_lib'}    = 1;
                                            }elsif( $_ eq "rtl" ){
                                                $options{'comp_rtl'}    = 1;
                                            }elsif( $_ eq "tb" ){
                                                $options{'comp_tb'}     = 1;
                                            }elsif( $_ eq "mod" ){
                                                $options{'comp_model'}  = 1;
                                            }
                                        }
                                    } else{
                                        $options{'comp_lib'}    = 1;
                                        $options{'comp_rtl'}    = 1;
                                        $options{'comp_tb'}     = 1;
                                        $options{'comp_model'}  = 1;
                                    } }        ,
         'opt|O!'         => \$options{'opt'} ,      
         'sim|S!'         => \$options{'sim'} ,      
         'setlib|L!'      => \$options{'setlib'} ,      
         'sim_args=s'     => sub { push( @sim_user_arg, $_[1] ); } ,      
         'test|T=s'       => sub { $options{'testname'} = $_[1]; 
                                    my $test_full_path = $test_loc.'/'.$options{'testname'};
                                    if ( -f $test_full_path ){
                                        push( @sim_user_arg, "+TEST=".$test_loc.'/'.$options{'testname'} );
                                        push( @sim_user_arg, "+TESTNAME=".$options{'testname'} );
                                    } else {
                                        my $cmd = "ls -ltr ".$test_loc." | awk '{print \$9}' ";
                                        system($cmd);
                                        PrintErrMsg(__LINE__, 2, "ERROR", "Test " . $test_full_path . " doesn't exist.");
                                    }
                                 } ,      
         'seed=i'         => sub {  if( $_[1] ){
										$options{'seed'} = $_[1] ; 
									}else{
										$options{'seed'} = gen_seed();
									}   
									push( @sim_user_arg, "-sv_seed ".$options{'seed'} );
								},
         'comp_args=s'    => sub {  push( @rtl_user_arg, $_[1] );
                                    push( @tb_user_arg , $_[1] ); 
								} , 
         'tb_args=s'      => sub {  push( @tb_user_arg, $_[1] );
								} , 
         'rtl_args=s'     => sub {  push( @rtl_user_arg, $_[1] );
								} , 
         'visualizer|V!' => sub { $options{'visualizer'} = 1;
                                   $options{'opt'}        = 1;
								} , 
         'wave|W!'       => sub {   $options{'waveform'} = 1;
            
									if( $value eq $VISVIEWERABBR){
										$WAVEVIEWER = $VISVIEWER;
									}elsif( $value eq $WLFVIEWER){ 
										$WAVEVIEWER = $WLFVIEWER;
									}   
								} , 
								
         'redundancy|R!'  => \$options{'opt'},       
         'clean=s'        => \$options{'clean_lib'}       

     );

     if ($return_val ne 1) {
        printf ("Error processing command line options $return_val\n");
         print_help();
         exit;
     }

     # illegal_opt_check();
  }
}

sub log_script{
  if ( $options{'debug'} ) {
     open (STDOUT, "| tee $0.log");
     print "#######################################################################\n";
     print "Start log $0 script: ";
     system ("date");
     print "$0 @ARGV\n";
     print "#######################################################################\n\n";
  }
} 

sub setup_libraries{
    my $cmd;
    if( $options{'setlib'}==1  ){
        # $cmd = sprintf("./pre_compile.sh");

		$cmd  = sprintf(" rm -rf modelsim.ini ;");
		$cmd .= sprintf(" rm -rf %s ; ", $lib_loc );
		$cmd .= sprintf(" vlib   %s ; ", $lib_loc );
		$cmd .= sprintf(" vlib   %s/work ; ", $lib_loc );
		$cmd .= sprintf(" vmap -c mtiUvm %s/work ;", $lib_loc );
		
		foreach( @libraries ){
			$cmd .= sprintf(" vlib %s/%s ; ", $lib_loc, $_ );
			$cmd .= sprintf(" vmap %s %s/%s ; ", $_, $lib_loc, $_ );
		}
		
        printf( $cmd."\n" );
        system( $cmd );		
		
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Setting Libraries failed.");
        }else{
            ReportMsg("Setting Libraries was successfull.");
        }
    }
}

sub clean_libraries{
    my $cmd;
    if( $options{'clean_lib'} ){

		$cmd  = sprintf(" rm -rf %s/%s ; ", $lib_loc, $options{'clean_lib'} );
		$cmd .= sprintf(" vlib   %s/%s ; ", $lib_loc, $options{'clean_lib'} );
		$cmd .= sprintf(" vmap %s %s/%s ; ", $options{'clean_lib'}, $lib_loc, $options{'clean_lib'} );
		# if( $options{'clean_lib'} eq "work" ){
			# $cmd .= sprintf(" vmap -c mtiUvm %s/work ;", $lib_loc );
		# }	
		
        printf( $cmd."\n" );
        system( $cmd );		
		
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Cleaning Library %s failed.", $options{'clean_lib'});
        }else{
            ReportMsg("Cleaning Library %s was successfull.", $options{'clean_lib'});
        }
    }
}

sub compilation{
    my $cmd;
    if( $options{'comp_lib'}==1  ){
        $cmd = sprintf("./comp_vhdl.pl");
        system( $cmd );
		compile_vhdl();
		
		#compile_cell();
		
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Compiling Libraries (VHDL|Mems) failed.");
        }else{
            ReportMsg("Compiling Libraries (VHDL|Mems) was successfull.");
        }       
    }
    if( $options{'comp_rtl'}==1  ){
        get_comp_rtl_args();
        $cmd = comp_rtl_vlog( \@rtl_cfg_arg, \@rtl_test_arg, \@rtl_user_arg);
        printf( $cmd."\n" );
        system( $cmd );
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Compiling SV RTL failed.");
        }else{
            ReportMsg("Compiling SV RTL was successfull.");
        }       
    }
    if( $options{'comp_tb'} ==1  ){
        get_comp_tb_args();
        $cmd = comp_tb_vlog( \@tb_cfg_arg, \@tb_test_arg, \@tb_user_arg);
        printf( $cmd."\n" );
        system( $cmd );
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Compiling TB failed.");
        }else{
            ReportMsg("Compiling TB was successfull.");
        }       
    }
    if( $options{'comp_model'} ==1  ){
        # $cmd = sprintf("./comp_model.sh");
        get_comp_model_args();
        $cmd  = "cd \$sim ; rm -rf so_libs; mkdir  so_libs; ";
        $cmd .= comp_model( \@mod_cfg_arg, \@mod_test_arg, \@mod_user_arg);
        printf( $cmd."\n" );
        system( $cmd );
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Compiling C Models failed.");
        }else{
            ReportMsg("Compiling C Models was successfull.");
        }       
    }

}

sub optimization{
    my $top = $_[0];
    my $cmd;
    if( $options{'opt'}==1  ){
        get_opt_args();
        $cmd = optimize( $top, \@opt_cfg_arg, \@opt_test_arg, \@opt_user_arg);
        printf( $cmd."\n" );
        system( $cmd );
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Optimization failed.");
        }else{
            ReportMsg("Optimization was successfull.");
        }       
    }
}

sub simulation{
    my $cmd;
    my $top        = $_[0];
    if( $options{'sim'}==1  ){
        get_sim_args();
        $cmd = simulate( $top, \@sim_cfg_arg, \@sim_test_arg, \@sim_user_arg);
        printf( $cmd."\n" );
        system( $cmd );
    }
}

sub read_config{
    my $config_hash = $_[0];
    my $target_opt  = $_[1];
    my $options_q   = $_[2];
    foreach $keys (sort(keys(%{$config_hash}))) {
        if ( $keys eq $target_opt ){
            while ( my ($key,$value) = each %{${$config_hash}{$keys}} ) {
                if ( not($key =~ m/\-top/g) ) {
                    push @{$options_q}, "$key";
                }
                if ($value ne "" && not($value =~ m/\-top/g)) {
                    push @{$options_q}, "$value";
                }
            }
        }
    }
}

sub comp_rtl_vlog{
    my $cmd_str;
    my $base_opt_q = $_[0];
    my $test_opt_q = $_[1];
    my $user_opt_q = $_[2];
    
    $cmd_str =  sprintf(" %s %s %s %s", $VLOGCOMPCMD, sprint_q(\@{$user_opt_q}), sprint_q(\@{$test_opt_q}), sprint_q(\@{$base_opt_q}) );
    
    return $cmd_str;
}

sub comp_tb_vlog{
    my $cmd_str;
    my $base_opt_q = $_[0];
    my $test_opt_q = $_[1];
    my $user_opt_q = $_[2];
    
    $cmd_str =  sprintf(" %s %s %s %s", $VLOGCOMPCMD, sprint_q(\@{$user_opt_q}), sprint_q(\@{$test_opt_q}), sprint_q(\@{$base_opt_q}) );
    
    return $cmd_str;
}

sub comp_model{
    my $cmd_str;
    my $base_opt_q = $_[0];
    my $test_opt_q = $_[1];
    my $user_opt_q = $_[2];
    
    $cmd_str =  sprintf(" %s %s %s %s", $GCCCOMPCMD, sprint_q(\@{$user_opt_q}), sprint_q(\@{$test_opt_q}), sprint_q(\@{$base_opt_q}) );
    
    return $cmd_str;
}

sub optimize{
    my $cmd_str;
    my $top        = $_[0];
    my $base_opt_q = $_[1];
    my $test_opt_q = $_[2];
    my $user_opt_q = $_[3];
    
    $cmd_str =  sprintf(" %s %s -o %s %s %s %s", $OPTCMD, $top, $top."_opt", sprint_q(\@{$user_opt_q}), sprint_q(\@{$test_opt_q}), sprint_q(\@{$base_opt_q}) );
    #$cmd_str .= sprintf(" ; echo \$?");
    return $cmd_str;
}

sub simulate{
    my $cmd_str;
    my $top        = $_[0];
    my $base_sim_q = $_[1];
    my $test_sim_q = $_[2];
    my $user_sim_q = $_[3];
    
    my $log_path = sprintf("%s/%s/%s", $LOGDIR, $options{'testname'} );
    my $sim_log  = sprintf("%s/%s", $log_path, "simulation.log" );
    # my $wave_log = sprintf("%s/%s", $log_path, "waveform.wlf" );
    
    $cmd_str =  sprintf(" %s -c %s -l %s %s %s %s", $SIMCMD, $top."_opt", $sim_log, sprint_q(\@{$user_sim_q}), sprint_q(\@{$test_sim_q}), sprint_q(\@{$base_sim_q}) );
    
    return $cmd_str;
}

sub set_waveform{
    my $str;
    my $log_path = sprintf("%s/%s/%s", $LOGDIR, $options{'testname'} );
    if ( $options{'visualizer'} ){
      push( @opt_user_arg, "-designfile ". $log_path.'/'.$VIS_DESIGN_DB ) ;
      push( @sim_user_arg, sprintf("-%sdb=%s+wavefile=%s/qwave.db", $VWAVE_PREFIX, $VWAVE_ARGS, $log_path ) );
    }else {
        push( @sim_user_arg, "-wlf ".$log_path.'/'.$WLF_NAME );
    }       
    return $str;
}

sub view_waveform{
    my $cmd;
    my $log_path = sprintf("%s/%s/%s", $LOGDIR, $options{'testname'} );
    my $designfile = $log_path.'/'.$VIS_DESIGN_DB;
    my $qwavefile  = $log_path.'/'.'qwave.db';
    my $wlffile    = $log_path.'/'.$WLF_NAME ;
    # printf("%s %s\n", $options{'waveform'}, $WAVEVIEWER );
    if ( $options{'waveform'} == 1 ){
    
        if ( $WAVEVIEWER eq $VISVIEWER ){
            if( -f $designfile && -f $qwavefile ){
                $cmd = sprintf( "%s +designfile=%s +wavefile=%s &", $WAVEVIEWER, $designfile, $qwavefile );
                printf( $cmd."\n" );
                system( $cmd );
            }else{
                ReportErrMsg( sprintf("The design file or wave file could not be found\n  %s\n  %s", $designfile, $qwavefile ) );
            }
        }elsif ( $WAVEVIEWER eq $WLFVIEWER ){
            if( -f $wlffile ){
                $cmd = sprintf( "%s -64 -gui -view %s &", $WAVEVIEWER, $wlffile );
                printf( $cmd."\n" );
                system( $cmd );             
            }else{
                ReportErrMsg( sprintf("The WLF file could not be found.\n  %s\n  %s", $wlffile ) );
            }
        }
    }else{
        # PrintInfoMsg(1, 1, "Waveform viewer is not set.\n");
    }   
}

sub get_dut_top{
    require $base_cfg_filename;
    my @design_cfg_arg;
    read_config( \%sim_cfg, "design", \@design_cfg_arg );
    return $design_cfg_arg[0];
}

sub get_tb_top{
    require $base_cfg_filename;
    my @tb_cfg_arg;
    read_config( \%sim_cfg, "testbench", \@tb_cfg_arg );
    return $tb_cfg_arg[0];
}

sub get_comp_rtl_args{
    require $base_cfg_filename;
    read_config( \%sim_cfg, "compile_rtl", \@rtl_cfg_arg );
    if( $options{'testname'} ne "default" ){
        my $test_cfg_filename =  $test_loc.'/'.$options{'testname'}.'/test.cfg';
        require $test_cfg_filename;
        read_config( \%test_cfg, "compile_rtl", \@rtl_test_arg );
    }
    # print_q(\@rtl_cfg_arg);
}

sub get_comp_tb_args{
    require $base_cfg_filename;
    read_config( \%sim_cfg, "compile_tb", \@tb_cfg_arg );
    if( $options{'testname'} ne "default" ){
        my $test_cfg_filename =  $test_loc.'/'.$options{'testname'}.'/test.cfg';
        require $test_cfg_filename;
        read_config( \%test_cfg, "compile_tb", \@tb_test_arg );
    }
    # print_q(\@rtl_cfg_arg);
}

sub get_comp_model_args{
    require $base_cfg_filename;
    read_config( \%sim_cfg, "compile_model", \@mod_cfg_arg );
    if( $options{'testname'} ne "default" ){
        my $test_cfg_filename =  $test_loc.'/'.$options{'testname'}.'/test.cfg';
        require $test_cfg_filename;
        read_config( \%test_cfg, "compile_model", \@mod_test_arg );
    }
    # print_q(\@mod_cfg_arg);
}

sub get_opt_args{
    require $base_cfg_filename;
    read_config( \%sim_cfg, "optimizition", \@opt_cfg_arg );
    if( $options{'testname'} ne "default" ){
        my $test_cfg_filename =  $test_loc.'/'.$options{'testname'}.'/test.cfg';
        require $test_cfg_filename;
        read_config( \%test_cfg, "optimizition", \@opt_test_arg );
    }
    # print_q(\@rtl_cfg_arg);
}

sub get_sim_args{
    require $base_cfg_filename;
    read_config( \%sim_cfg, "simulation", \@sim_cfg_arg );
    if( $options{'testname'} ne "default" ){
        my $test_cfg_filename =  $test_loc.'/'.$options{'testname'}.'/test.cfg';
        require $test_cfg_filename;
        read_config( \%test_cfg, "simulation", \@sim_test_arg );
    }
    # print_q(\@rtl_cfg_arg);
}

sub gen_seed{
    # Seed generation
    srand( $random_seed = int(rand(0xffff)) );
    return $random_seed;
}

sub sprint_q{
    my $ref_q = $_[0];
    my $str;
    foreach( @{$ref_q} ){
        $str .= sprintf( "%s ", $_ );
    }
    return $str;
}

sub print_q{
    my $ref_q = $_[0];
    foreach( @{$ref_q} ){
        printf( "%s \n", $_ );
    }
}

sub print_hash{
    my $ref_hash = $_[0];
    while ( my ($k,$v)=each %${ref_hash} ){print "$k $v\n"}
}

sub print_help{
    PrintInfoMsg( 1, 1, "\n");
    PrintInfoMsg( 1, 1, "########################### help #########################\n");
    PrintInfoMsg( 1, 1, "\n");
    PrintInfoMsg( 1, 1, "#  Usage:\n");
    PrintInfoMsg( 1, 1, "#    $0 <options> \n");
    PrintInfoMsg( 1, 1, "\n");
    PrintInfoMsg( 1, 1, "#    Valid options: \n");
    PrintInfoMsg( 1, 1, "\n");   
    PrintInfoMsg( 1, 1, "#    --help          [ -h]   : Prints help\n");
    PrintInfoMsg( 1, 1, "#    --setlib        [ -L]   : Setup compilation libraries\n");
    PrintInfoMsg( 1, 1, "#    --comp          [ -C]   : Compile <rtl:tb:lib:mod>\n");
    PrintInfoMsg( 1, 1, "#    --opt           [ -O]   : optimize\n");
    PrintInfoMsg( 1, 1, "#    --sim           [ -S]   : simulation\n");
    PrintInfoMsg( 1, 1, "#    --test          [ -T]   : Testname\n");
    PrintInfoMsg( 1, 1, "#    --seed                  : seed = <number>; default or 0 is random\n");
    PrintInfoMsg( 1, 1, "#    --comp_args             : RTL and TB Compilation arguments\n");
    PrintInfoMsg( 1, 1, "#    --rtl_args              : RTL Compilation arguments\n");
    PrintInfoMsg( 1, 1, "#    --tb_args               : TB  Compilation arguments\n");
    PrintInfoMsg( 1, 1, "#    --visualizer    [ -V]   : Visualizer waveform dump\n");
    PrintInfoMsg( 1, 1, "#    --wave          [ -W]   : Opens the waveform. [wlf] or [vis]\n");
    PrintInfoMsg( 1, 1, "#    --clean                 : Cleans a library and re-creates it.\n");
    PrintInfoMsg( 1, 1, "#   ------\n");
    PrintInfoMsg( 1, 1, "#   Example          \n");
    PrintInfoMsg( 1, 1, "\n"); 
    PrintInfoMsg( 1, 1, "#    $0 -L -C lib:rtl:tb:mod -O -S -T app_test\n");
    PrintInfoMsg( 1, 1, "#    $0 -L -C lib:rtl:tb:mod -O -S -T disp_test\n");
    PrintInfoMsg( 1, 1, "#    $0 -S -T disp_test -V\n");
    PrintInfoMsg( 1, 1, "#    $0 -W -T disp_test\n");
    PrintInfoMsg( 1, 1, "#    $0 --clean=work \n");
    PrintInfoMsg( 1, 1, "##########################################################\n");
}


sub compile_cell{
    for( my $i=0; $i <= $#cell_library_path; $i++ )
    {
        my $cell_file_name = $LOGDIR."/".$cell_library_name[$i]."_comp.list";
		my $log_file_name    = $LOGDIR."/compile_".$cell_library_name[$i].".log";
		
        parse_flist( $cell_library_path[$i], $cell_file_name, 0 );
  		
		my $cmd = sprintf("vlog -quiet -64 -f %s -work %s -l %s +define+ST_NO_MSG_MODE +define+ST_MSG_CONTROL_TIME=1000000;", $cell_file_name, $cell_library_name[$i], $log_file_name );
		printf( "  %s\n", $cmd);
		# system( $cmd );
		
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Compiling CELLs into $cell_library_path[$i] library failed.");
        }else{
            ReportMsg("Cleaning CELLs into $cell_library_path[$i] library was successfull.");
        }    
    }
}

sub compile_vhdl{
    for( my $i=0; $i <= $#vhdl_library_path; $i++ )
    {
        my $output_file_name = $LOGDIR."/".$vhdl_library_name[$i]."_comp.list";
		my $log_file_name    = $LOGDIR."/compile_".$vhdl_library_name[$i].".log";
		
        make_flist( $vhdl_library_path[$i], $vhdl_library_name[$i], $output_file_name, 0 );
  		
		my $cmd = sprintf("vcom  -64 -F %30s -work %s -l %s", $output_file_name, $vhdl_library_name[$i], $log_file_name );
		printf( "  %s\n", $cmd);
		system( $cmd );
		
        if( check_shell_retval() != 0 ){
            ReportErrMsg("Compiling VHDL RTL into %s library failed.", $vhdl_library_name[$i]);
        }else{
            ReportMsg("Compiling  VHDL RTL into %s library was successfull.", $vhdl_library_name[$i]);
        }    
    }
}


# There is a problem with liblist, or -F
sub parse_flist
{
    my $library_path      = $_[0];
    my $output_file_name  = $_[1];
    my $verify            = $_[2];
    
    my $path_name      =  dirname( $library_path );
    my $list_file_name = sprintf("%s", $library_path);
        
    if( -e $list_file_name )
    {
        my $line_no = 0;
        
        system( "rm -rf $output_file_name" );
        open( FILE, $list_file_name ) or die $!;
        open( FILEOUT, '>'. $output_file_name ) or die $!;
        while( <FILE> )
        {   chomp;
            $line_no++;
            my $rtl_file_name ;
            if($verify){
                $rtl_file_name = sprintf("%s", $_);
                $rtl_file_name =~ s/\.\.\/common_src/$common_src/;
                #$rtl_file_name =~ s/\$CATSON_LIBRARY/$CATSON_LIBRARY/;
                #$rtl_file_name =~ s/\$NOTECH_LIBRARY/$NOTECH_LIBRARY/;
            }else{
                $rtl_file_name = sprintf("%s/%s", $path_name, $_);
            }
			
			$rtl_file_name = trim( $rtl_file_name );
			
            if( $_ !~ /^\/\// && $_ !~ /^#/  && $_ !~ /incdir/ && $_ ne "" )
            {
                # if( defined( $rtl_file_name ) && -e $rtl_file_name )
				if( $_ =~ /-F/ ) {
				
					parse_flist( $rtl_file_name, $cell_file_name, 0 );
				
                } elsif( defined( $rtl_file_name ) && $rtl_file_name =~ /$\.v/   ){
					if(  -f $rtl_file_name   )
					{

						printf("%s %s %s\n", ctime( $last_compile_time ), ctime( $timestamp ), $rtl_file_name);
						printf( FILEOUT "%s\n", $rtl_file_name );
	   
					}
					else
					{
						printf("Error::%s doesn't exist. File %s, Line %d\n", $rtl_file_name, $list_file_name, $line_no );
						#exit;
					}
                }
            }
        }
        close( FILEOUT );
        close( FILE );
    }
    else
    {
        printf("Error:: %s doesn't exist. \n", $list_file_name );
    }
}    

sub make_flist
{
    my $library_path      = $_[0];
    my $library_name      = $_[1];
    my $output_file_name  = $_[2];
    my $bypass            = $_[3];
    
    my $path_name      =  dirname( $library_path );
    my $list_file_name = sprintf("%s", $library_path);
        
    if( -e $list_file_name )
    {
        my $line_no = 0;
        
        system( "rm -rf $output_file_name" );
        open( FILE, $list_file_name ) or die $!;
        open( FILEOUT, '>'. $output_file_name ) or die $!;
        while( <FILE> )
        {   chomp;
            $line_no++;
            my $rtl_file_name ;
            if($bypass){
                $rtl_file_name = sprintf("%s", $_);
                $rtl_file_name =~ s/\$common_src/$common_src/;
                $rtl_file_name =~ s/\$CATSON_LIBRARY/$CATSON_LIBRARY/;
                $rtl_file_name =~ s/\$NOTECH_LIBRARY/$NOTECH_LIBRARY/;
            }else{
                $rtl_file_name = sprintf("%s/%s", $path_name, $_);
            }
            if( $_ !~ /^\/\// && $_ !~ /^#/  && $_ !~ /incdir/ )
            {
                # if( defined( $rtl_file_name ) && -e $rtl_file_name )
                if( defined( $rtl_file_name ) )
                {

					# printf("%s %s %s\n", ctime( $last_compile_time ), ctime( $timestamp ), $rtl_file_name);
					printf( FILEOUT "%s\n", $rtl_file_name );
   
                }
                else
                {
                    printf("Error::%s doesn't exist. File %s, Line %d\n", $rtl_file_name, $list_file_name, $line_no );
                    #exit;
                }
            }
        }
        close( FILEOUT );
        close( FILE );
    }
    else
    {
        printf("Error:: %s doesn't exist. \n", $list_file_name );
    }
}    
 

################################################################
# Name                  : PrintErrMsg()
# Description           : print error message
#                       :
# Input parameters      : Current line number, number of lines
#                         (1 or 2), and strings
#                       : (1 or 2) respectively
# Return Values         :
################################################################
sub PrintErrMsg {
   my($curr_line)     = $_[0];
   my($num_of_lines)  = $_[1];
   my($input_string1) = $_[2];
   my($input_string2) = $_[3];
   print STDOUT "\n",$LINESTART,"#"x70,"";

   print STDOUT "\n$LINESTART## ", RED, "FATAL_ERROR:: $input_string1", RESET;
   printf(" at %s LINE(%d) ", __FILE__, $curr_line);
   if ($num_of_lines eq 2){
      print STDOUT "\n$LINESTART## $input_string2 ";
   }
   print STDOUT "\n",$LINESTART,"#"x70,"\n";
   End(1); 
}

sub ReportErrMsg {
   my($input_string1) = $_[0];
   print STDOUT "\n$LINESTART## ", RED,"#"x70, RESET;
   print STDOUT "\n$LINESTART## ", RED, "FATAL_ERROR:: $input_string1", RESET;
   print STDOUT "\n$LINESTART## ", RED,"#"x70, RESET,"\n";
   End(1); 
}

sub ReportMsg {
   my($input_string1) = $_[0];
   print STDOUT "\n$LINESTART## ", GREEN,"#"x70, RESET;
   print STDOUT "\n$LINESTART## ", GREEN, "INFO:: $input_string1", RESET;
   print STDOUT "\n$LINESTART## ", GREEN,"#"x70,"\n", RESET;
}

################################################################
# Name                  : GetTimeAndPrint()
# Description           : get time and print it to screen
#                       :
# Input parameters      :
# Return Values         :
################################################################
sub GetTimeAndPrint {
    get_time();
    PrintInfoMsg(1, 1,"Date: $mday $month $year");
    $start_time = $time ;
    PrintInfoMsg(1, 1,"Start Time: $start_time");
}

################################################################
# Name                  : PrintInfoMsg()
# Description           : print information message
#                       :
# Input parameters      : number of lines (1 or 2) and strings
#                       : (1 or 2) respectively
# Return Values         :
################################################################
sub PrintInfoMsg {
   my($plain)         = $_[0];
   my($num_of_lines)  = $_[1];
   my($input_string1) = $_[2];
   my($input_string2) = $_[3];
   if(!$plain) {print STDOUT $LINESTART, "\n","#"x70,"";}
   print STDOUT "$LINESTART $input_string1 ";
   if ($num_of_lines eq 2){
      print STDOUT "$LINESTART $input_string2 ";
   }
   if(!$plain) {print STDOUT $LINESTART, "\n","#"x70,"\n"};
}

sub replace_tab($)
{
   my $line = shift;
   $line =~ s/\t/   /g;
   return ($line);
}

sub trim_leading_space($)
{
   my $line = shift;
   $line =~ s/^ +//g;
   return ($line);
}

sub trim_trailing_space($)
{
   my $line = shift;
   $line =~ s/ +$//g;
   return ($line);
}

sub trim($)
{
   my $string = shift;
   $string =~ s/^\s+//;
   $string =~ s/\s+$//;
   return $string;
}

sub sec2human {
   my $secs = shift;
   if    ($secs >= 365*24*60*60) { return sprintf '%.1fy', $secs/(365*24*60*60) }
   elsif ($secs >=     24*60*60) { return sprintf '%.1fd', $secs/(    24*60*60) }
   elsif ($secs >=        60*60) { return sprintf '%.1fh', $secs/(       60*60) }
   elsif ($secs >=           60) { return sprintf '%.1fm', $secs/(          60) }
   else                          { return sprintf '%.1fs', $secs                }
}

sub get_time {
    # List of weekdays and months
    my @a_days_list       = ( "Sun", "Mon", "Tues", "Wednes", "Thurs", "Fri", "Satur");
    my @a_months_list     = ( "January", "February", "March", 
                              "April"  , "May"     , "June",
                              "July"   , "August"  , "September",
                              "October", "November", "December" );
    my @a_num_months_list = ( "01", "02", "03", "04", "05", "06", 
                              "07", "08", "09", "10", "11", "12" );

    # get the current date and time
    $date_time = localtime;
    
    $wday      = $a_days_list[$date_time->wday]."day";
    $mday      = ($date_time->mday);
    $month     = $a_months_list[$date_time->mon];
    $num_month = $a_num_months_list[$date_time->mon];
    $year      = ($date_time->year)+1900;
    $time      = sprintf ("%02d:%02d:%02d",$date_time->hour, $date_time->min, $date_time->sec);
    $cpu_time  = $date_time->sec + ($date_time->min*60) + ($date_time->hour*3600);
    return $time;
}

sub signature {
   $SimStart = time();
   system("clear");
print <<End_of_signature;
\n  ########################################################
  ##                \@2017 Master Script V0.1            ##
  ########################################################
End_of_signature
}

sub End {
print <<End_of_signature;
\n  ########################################################
  ##          End of Script                             ##
  ########################################################\n
End_of_signature
   # How long did it take for this script to run.
   my $End  = time();
   my $Diff = $End - $SimStart;
   printf   sec2human($Diff)."\n";
   exit($_[0]);
}

#} >--<> Subroutines

#{ >--<> Subroutines2

    sub run_cmd{
        my $cmd        = $_[0];   
        my $show_cmd   = $_[1];
        my $debug_only = $_[2];
        my $return     = $_[3];
        my $ret;
        
        if( $debug_only == 1 || $show_cmd == 1 ){ # Show and run
            PrintInfoMsg( $cmd );       
        }
        
        if( $debug_only == 0 ) {
            if( $return == 1 ){
                $ret = `$cmd`;
                return $ret
            }else{
                system( $cmd );
            }
        }
        
    }

   sub initialize {
        # while (my ($k,$v)=each %options){print "$k $v\n"}
        $DUT_TOP = get_dut_top();
        $TB_TOP  = get_tb_top();
        printf( "DUT_TOP = %s\n", $DUT_TOP );
        printf( "TB_TOP  = %s\n", $TB_TOP  );   

        #exit(0);
   }
  
   sub setup_directories{
        my $cmd = sprintf("mkdir -p %s", sprintf("%s/%s/%s", $LOGDIR, $options{'testname'} ));
        print ( $cmd."\n" );
        system( $cmd );   
   }

   sub check_shell_retval{
        #my $cmd = sprintf("echo \$?");
        
        #my $retval = `$cmd`;
        # print ( $?."\n" );        
        return $?;
   }
  
   sub call_history {
      if (@ARGV) {
         $datestring = localtime();
         open (FILE,">> $FN_RUN_HISTORY");
         print FILE "$datestring $0 @ARGV\n";
         close FILE;
      }
   }

#} >--<> Subroutines2


1;

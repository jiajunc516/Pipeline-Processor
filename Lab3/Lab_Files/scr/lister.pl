#!/usr/bin/perl -w

######################################################################### 
#  Name        : fileLister.pl
#
#  Description : This script parses a given rtl.cfg and generates a list
#                of rtl files and include directories contained within.
#                The script is recursive in terms of any #include 
#                directories that include rtl.cfg.
#
#  Version     : 1.0 
#
#  Authors     : Pooria Yaghni 
#                
#  Usage       : See % ./filelister --help
#            
#  Limitations : 1) RTL.cfg must specify dir #include 
#                   dir w.r.t $RTL_ROOT/units
# 
#                2) RTL.cfg must specify local include dir using +incdir+
#
#                3) ifdefs are not supported in RTL.cfg
#########################################################################


#------------------------------------------------------------------------
# Global 
#------------------------------------------------------------------------

use Getopt::Long;
use File::Basename;
use Data::Dumper;


#------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------

my $top_rtl_cfg        = "0";
my $sim_file_list_path = "sim_files.list";
my $incdir_list_path   = "incdir.list";
my $RTL_ROOT           = "";
my $TB_ROOT            = "";
my $ROOT               = "";
my $help               = 0;
my @file_list          = ();
my @incdir_list        = ();
my %file_list_hash     = ();
my %incdir_hash        = ();
my %hinclude_hash      = ();
my %cfg_error_hash     = ();
my $error_count        = 0;
my $warning_count      = 0;
my $info_count         = 0;
my $MAXDEPTH           = 2;
my @root_ar            = ();
my $stop_on_err_cnt    = -1;
my $debug              = 0;
my $tb                 = 0;
my $version            = 0;
my $cfg_file           = "sources.list";
my $file_hierarchy     = "design/rtl";


#------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------

  print_welcome     ();

  get_argv          ();

  check_env_var     ();

  check_top_rtl_cfg ($top_rtl_cfg);

  parse_cfg_file    ($top_rtl_cfg);

  print_file_list   ();

  print_incdir_list ();

  print_status      ();


#------------------------------------------------------------------------
# Subroutine to get user inputs
#------------------------------------------------------------------------

sub check_env_var 
  {  
     if($tb ne 0)
       {
         if($ENV{'TB_ROOT'})
           {
             print_info("Using TB_ROOT = $ENV{'TB_ROOT'}");
             $TB_ROOT = $ENV{'TB_ROOT'};
             $ROOT = $TB_ROOT;
           } 
         else 
           {
             print_error("TB_ROOT not set. Exiting...");
             exit(-1);
           }
       }
     else  
       {
         if($ENV{'design'})
           {
             print_info("Using RTL_ROOT = $ENV{'design'}");
             $RTL_ROOT = $ENV{'design'};
             $ROOT = $RTL_ROOT;
           } 
         else 
           {
             print_error("RTL_ROOT not set. Exiting...");
             exit(-1);
           }
       }
  }


#------------------------------------------------------------------------
# Subroutine to get user inputs
#------------------------------------------------------------------------

sub get_argv
  {
    if(@ARGV == 0) 
      {
        help_info();
        exit (-1);
      }
    else 
      {
        $return_val = GetOptions('top_rtl_cfg=s'     => \$top_rtl_cfg,
                                 'sim_file_list=s'   => \$sim_file_list_path,
                                 'incdir_list=s'     => \$incdir_list_path,
                                 'help!'             => \$help,
                                 'debug'             => \$debug,
                                 'tb'                => \$tb,
                                 'version'           => \$version,
                                 'stop_on_err_cnt=s' => \$stop_on_err_cnt);

        if($version ne 0)
          {
            print_version();
            exit(-1);
          }

        if($tb ne 0)
          {
            $file_hierarchy = "verif/src";
            $cfg_file = "sources.list";
            print_info("CFG File type is tb.cfg \n");
          }
        else
          {
            $file_hierarchy = "design/rtl";
            $cfg_file = "sources.list";
            print_info("CFG File type is rtl.cfg \n");
          }

        if($debug ne 0)
          {
            print_info("Verbose/Debug mode ON \n");
          }
        else
          {
            print_info("Quite Mode ON \n");
          }

        if ($help ne 0)
          {
            help_info();
            exit(-1);
          }

        if($top_rtl_cfg eq "0")
          {
            print_error("Top $cfg_file file not specified.");
            exit_with_status();
          }
    
        if ($return_val ne 1)
          {
            print_error ("Error processing command line options $return_val");
            help_info();
            exit_with_status();
          }
      }
  }


#------------------------------------------------------------------------
# Subroutine to print and save file list 
#------------------------------------------------------------------------

sub print_file_list 
  {
    if(@file_list ne "")
      {
        open (FILE, ">$sim_file_list_path") or die $!;
        for (@file_list)
          {
            print_info("Design File = $_");
            printf FILE "$_\n";
          }
      }
  }


#------------------------------------------------------------------------
# Subroutine to print and save incdir list 
#------------------------------------------------------------------------

sub print_incdir_list 
  {
    if(@incdir_list ne "")
      {
        open (FILE, ">$incdir_list_path") or die $!;
        for (@incdir_list)
          {
            print_info("Include dir = $_");
            printf FILE "+incdir+$_\n";
          }
      }
  }


#------------------------------------------------------------------------
# Subroutine to check RTL config file 
#------------------------------------------------------------------------

sub check_top_rtl_cfg
  {
    my ($f) = @_;
    my ($mf)= "";
    my (@a);
    $f =~ s/\s//g; 
    @a = split (/\//, $f);
    if ($#a eq 0)
      {
      } 
    elsif ($a[0] eq "") 
      { 
        print_info("Top CFG File = $top_rtl_cfg");
      }
    else 
      { 
        $top_rtl_cfg = $ROOT . "/" . $f;
        $top_rtl_cfg =~ s/\/\//\//g;
        if(-e $top_rtl_cfg)
          {
            print_info("Top CFG File = $top_rtl_cfg");
          }
        else
          {
            print_error("Top cfg file does not exists. Check path ($top_rtl_cfg)");
            exit_with_status();
          }
      }

  }


#------------------------------------------------------------------------
# Subroutine for processing cfg files
#------------------------------------------------------------------------

sub parse_cfg_file 
  {
    my $filehandle = shift;
    my ($FH);
    my ($ln);
    my ($curr_dir) = dirname($filehandle);
    my ($new_cfg);
    my @found;
    my $inc_name;
    my $incdir_return = "";
    open ($FH, "<", $filehandle) || die "Can't open $filehandle: $!\n";
    while ($ln = <$FH>)
      {
        $ln =~ s/\s//g;
        if ($ln ne "")
          {
            if ($ln =~ /^\+incdir/)
              {
                @ar = split (/\+incdir\+/i, $ln);
	        if($#ar ne 0) 
                  {
	            $inc_name = $ar[1];
	            if ($inc_name eq ".") 
                      {
                        if($incdir_hash{$curr_dir})
                          {
                            print_info("$curr_dir already included before");
                          }
                        else
                          {
	                    $incdir_hash {$curr_dir} = 1;
                            push (@incdir_list, $curr_dir);
                          }
	              } 
	            elsif ($inc_name eq "..") 
                      {
                        if($incdir_hash{dirname($curr_dir)})
                          {
                            print_info("../$curr_dir already included before");
                          }
                        else
                          {
	                    $incdir_hash {dirname($curr_dir)} = 1;
                            push (@incdir_list, dirname($curr_dir));
                          }
	              }
                    else 
                      {
                        if(-e $curr_dir."/".$inc_name)
                          {
                             $incdir_return = $curr_dir."/".$inc_name;
                          }
                        else
                          {
                            $incdir_return = find_path($inc_name, "");
                          }
                        if($incdir_return eq "")
                          {
                            print_error("IncDir ($inc_name) specified in $filehandle not found");
                          }
                        elsif($incdir_hash{$incdir_return})
                          {
                            print_info("IncDir ($incdir_return) specified in $filehandle already included before");
                          }
                        else
                          {
                            print_info("Found an incdir = $incdir_return");
	                    $incdir_hash {$incdir_return} = 1;
                            push (@incdir_list, $incdir_return);
                          }
	              }
	          }
              }
            elsif ($ln =~ /^\#include/)
              {
                @ar = split (/\#include/i, $ln);
	        if($#ar ne 0) 
                {
                    $inc_name = $ar[1];
	            if ($inc_name eq ".") 
                      {
                        print_error("Included current dir "." with #include. Use +incdir+.");
	              } 
	            elsif ($inc_name eq "..") 
                      {
                        print_error("Included previous dir ".." with #include. Use +incdir+..");
	              }
                    else 
                      {
                         print_info ("Searching #include dir in order of priorities - $inc_name");
                         print_info ("Searching for $curr_dir..$inc_name");
                                                                       
                         if(-e $curr_dir."/".$inc_name)
                           {
                      	     $new_cfg = $curr_dir."/".$inc_name;
                             print_info ("Resolved (priority 1) #include dir ($inc_name) to curr_dir/inc_dir/$file_hierarchy/$cfg_file ($new_cfg)");
                           }
                         elsif(-e $curr_dir."/".$inc_name."/". $cfg_file)
                           {
                      	     $new_cfg =  $curr_dir."/".$inc_name."/". $cfg_file;
                             print_info ("Resolved (priority 2) #include dir ($inc_name) to curr_dir/inc_dir/$cfg_file ($new_cfg)");
                           }
                         else
                           {
                      	     $new_cfg =  find_path($inc_name, $cfg_file);
                           }

                        if (-e $new_cfg) 
                          { 
                            if($hinclude_hash{$inc_name})
                              {
                                print_info("$inc_name already included before");
                              }
                            else
                              {
	                        $hinclude_hash{$inc_name} = 1;
                                parse_cfg_file($new_cfg);
                              }
                          }
                        else
                          {
                            if($cfg_error_hash{$inc_name})
                              {
                                print_info("DUPLICATE_ERROR: $curr_dir/$cfg_file contains a #include dir that does not have an $cfg_file or the path ($inc_name) is incorrect or exists in more than one place in RTL_ROOT");
                              }
                            else
                              {
	                        $cfg_error_hash{$inc_name} = 1;
                                print_error("$curr_dir/$cfg_file contains a #include dir that does not have an $cfg_file or the path ($inc_name) is incorrect or exists in more than one place in RTL_ROOT");
                              }
                          }
	              }
                }
              }
            else
              {
                if ($ln =~ /^\#ifdef/)
                {
                  print_info("Skipping #ifdef line in $cfg_file - $ln");
                }
                elsif ($ln =~ /^\#endif/)
                {
                  print_info("Skipping #endif line in $cfg_file - $ln");
                }
                elsif ($ln =~ /^\#else/)
                {
                  print_info("Skipping #else line in $cfg_file - $ln");
                }
                elsif ($ln =~ /^\#end/)
                {
                  print_info("Skipping #end line in $cfg_file - $ln");
                }
                elsif (substr($ln, 0, 2) eq "//")
                {
                  print_info("Skipping comment in $cfg_file - $ln");
                }
                else
                {
                  if($ln =~ m/[^a-zA-Z0-9_.\/]/)
                   {
                     print_info("File name contains alphanumberic characters (file name - $ln)");
                   }
                  $ln = $curr_dir . "/" . $ln;
                  $ln =~ s/\/\//\//g; 
                  if(-e $ln)
                    {
                      if($file_list_hash{$ln})
                        {
                          print_info("File - $ln already included before");
                        }
                      else
                        {
	                  $file_list_hash{$ln} = 1;
                          push (@file_list, $ln);
                        }
                    }
                  else
                    {
                      print_error("File not found or corrupt name (file name - $ln)");
                    }
                }
              }
          }
      }
    close($FH);
  }


#------------------------------------------------------------------------
# Subroutine for displaying help information.
#------------------------------------------------------------------------

sub print_status 
  {
    print("\n Filelister done. Printing status: \n");
    print "\n Error(s) = $error_count \n";
    print "\n Warning(s) = $warning_count \n\n";
    if($error_count == 0)
      {
        print " *SUCCESS* \n\n"
      }
    else
      {
        print " *FAILED*. Fix Errors and retry. To see help, use -h(elp) \n\n"
      }
  }


#------------------------------------------------------------------------
# Subroutine to find the file in any given path
#------------------------------------------------------------------------

sub find_path
  {
    my $dir   = $_[0];
    my $file   = $_[1];        
    my $path_to_find  = $dir.'/'.$file;        
    my $filename = "";

    # 1) Check whether the path directly exists
    if(-e $ROOT.'/'.$path_to_find)
      {
         $filename = $ROOT.'/'.$path_to_find;
         print_info("Found $cfg_file for #include dir $dir directly from ROOT($filename)");
      }
    elsif(-e $ROOT.'/units/'. $dir . '/$file_hierarchy/'.$file)
      {
         $filename = $ROOT.'/units/'. $dir . "/$file_hierarchy/".$file;
         print_info("Found $cfg_file for #include dir $dir from ROOT/units/$dir/$file_hierarchy");
      }
    # 1) Check whether the path is in units dir
    elsif(-e $ROOT.'/units/'.$path_to_find)
      {
         $filename = $ROOT.'/units/'.$path_to_find;
         print_info("Found $cfg_file in #include dir $dir ($filename) in units dir");
      }
    else
      {        
         # 2) Try to find based on previous known root path
         foreach my $KnownRoot (@root_ar)
           {
              if(-e $KnownRoot.'/'.$path_to_find)
                {
                   $filename = $KnownRoot.'/'.$path_to_find;
                   last;
                }        
           }

           # 3) Try to find it through Linux find command        
           if($filename eq "")
             {
                my $RootStr     = $dir =~ "/" ? substr($dir, 0, index($dir,"/")) : $dir;
                my $RootLeftStr = $dir =~ "/" ? substr($dir,index($dir,"/")+1)   : "";
                # print "  Root str - $RootStr \n";
                # print "  Root left str - $RootLeftStr \n";
                my $cmd = sprintf("find %s/ -maxdepth %d  -name %s\n", $ROOT, $MAXDEPTH, $RootStr);
                print_info("Trying to find $RootStr in ROOT with max depth $MAXDEPTH ");
                my @result_q = `$cmd`;
                if(@result_q == 1)
                  {
                     my $result = $result_q[0];
                     chomp($result);        
                     if( -e $result.'/'.$RootLeftStr)
                       {
                          push (@root_ar, substr($result, 0, index($result,$RootStr)-1));
                          $filename = $result.'/'.$RootLeftStr.'/'.$file;
                       }
                  }
                elsif(@result_q == 0)
                  {
                    print_error("No files with name - $RootStr not found in ROOT");
                  }
                else
                  {
                    print_error("More than one file detected in ROOT with name - $RootStr :");
                    for (@result_q)
                      {
                        print_info("File = $_");
                      }
                  }
             }
      }        

    # if($filename eq "")
    #   { 
    #     print_error("Could not find rtl.cfg in any $dir in RTL_ROOT");
    #   }

    return $filename;
}


#------------------------------------------------------------------------
# Subroutine for displaying Info 
#------------------------------------------------------------------------

sub print_info
  {
    my $str = shift;
    if($debug ne 0)
      {
        printf(" INFO: %s \n", $str);
        $info_count++;
      }
  }


#------------------------------------------------------------------------
# Subroutine for displaying Warniings
#------------------------------------------------------------------------

sub print_warning
  {
    my $str = shift;
    printf(" WARNING: %s \n", $str);
    $warning_count++;
  }


#------------------------------------------------------------------------
# Subroutine for displaying Errors
#------------------------------------------------------------------------

sub print_error
  {
    my $str = shift;
    printf(" ERROR: %s \n", $str);
    $error_count++;
    if($error_count == $stop_on_err_cnt)
      {
        print_info("STOP ON ERROR COUNT ($stop_on_err_cnt) reached. Exiting.");
        exit_with_status;
      }
  }


#------------------------------------------------------------------------
# Subroutine for exit with error
#------------------------------------------------------------------------

sub exit_with_status
  {
    print_status();
    exit(-1);
  }

#------------------------------------------------------------------------
# Subroutine for displaying welcome message 
#------------------------------------------------------------------------

sub print_welcome
  {
    printf("\n");
    printf("Starting.. \n");
    printf("\n");
  }

#------------------------------------------------------------------------
# Subroutine for displaying version information.
#------------------------------------------------------------------------

sub print_version
  {
    printf("\n");
    printf("File Lister Version - 1.0 \n");
    printf("\n");
  }


#------------------------------------------------------------------------
# Subroutine for displaying help information.
#------------------------------------------------------------------------

sub help_info {
  printf("\n");
  printf("Help Information: \n");
  printf("\n");
  printf("  Usage:");
  printf("    $0 <options> \n");
  printf("\n");
  printf("  Valid options: \n");
  printf("\n");
  printf("    -top_rtl_cfg <top rtl.cfg file>   : Specify Top rtl.cfg path \n");
  printf("                                        Path can be full path or be absolute w.r.t to design top dir \n");
  printf("                                        Eg: galaxy/design/rtl/rtl.cfg \n\n");
  printf("    -sim_file_list                    : Specify simulation file list (optional)\n\n");
  printf("    -incdir_list                      : Specify include dir file list (optional)\n\n");
  printf("    -stop_on_err_cnt                  : Stop on error count \n\n");
  printf("    -v(ersion)                        : Version Information \n\n");
  printf("    -h(elp)                           : Help on options\n\n");
  printf("    -d(ebug)                          : Display all INFO messages, else only WARNING(s) and ERROR(s)\n\n");
}


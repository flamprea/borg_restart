#!perl

# Script Name: HTTP Interface for ColdFusion Restarts
# Version: 1.0
# Date: October 14, 2004
# Author: Francis J. Lamprea
# Wildcard Systems, Inc.

# Description:
# Performs an HTTP call to a ColdFusion Based Webserver. Evalutes results for
# Success / Failure.
# Success = background-color: green
# Failure = background-color: red (or any other color besides green)
# 

# History:
# Date               Initials       Description
# -----------------------------------------------------------------------
# 10-14-2004         FJL            Creation
# 01-04-2005         FJL            Added writeflash options
# 02-25-2005         FJL            Fixed Timeout issue with Restart Module
# 08-02-2005         FJL            Added nosubwids options
#
#
#

# Notes:
# Currently only supports BORG based sites.

# BEGIN SCRIPT

# END SCRIPT
use LWP;
use Getopt::Long;

# --server = server (Mandatory String)
# --wid = WID (Optional String)
# --password = Password (Mandatory String)
# --cache = Cache On/Off (1/0) (Optional Boolean)
# --flush = Flush On/Off (1/0) (Optional Boolean)
# --widsonly = Write only modified wid flash files (Optional Boolean)
# --skipgpiac = Write all flash files except gpiac (Optional Boolean)
# --nosubwids = Do Not Restart Subwids (Optional Boolean)
# --verbose = verbose (Optional Boolean)
# --dump = dump output (Optional Boolean)

# Define Variables
my $server = '';
my $wid = '';
my $password = '';
my $a2acache = '';
my $flush = '';
my $widsonly = '';
my $skipgpiac = '';
my $nosubwids = '';
my $verbose = '';
my $dump = '';

my $url = '';

GetOptions ('server=s' => \$server, 'wid:s' => \$wid, 'password=s' => \$password, 'cache' => \$a2acache, 
            'flush' => \$flush, 'widsonly' => \$widsonly, 'skipgpiac' => \$skipgpiac, 'nosubwids' => \$nosubwids, 
            'verbose' => \$verbose, 'dump' => \$dump) or die "Unable to Parse Options\n";

# If A2ACache is off the value should be set to 0
   if (!($a2acache)) {
      $a2acache = 0;
   }
   else {
      $a2acache = 1;
   }

if ( (!($server)) || (!($password))  ){
   &errorexit;
}

###################################################################################################
#
###################################################################################################
# Run this loop first if Flush is ON
if ($flush) {
   $url = "http://$server/borg/index.cfm?flushtc=1&pwd=$password";

   if ($verbose) {
      print "URL: $url\n";
   }

   &flushurl();
}
###################################################################################################
#
###################################################################################################
# Restart the Site if a WID is selected
if ($wid) {
   $url = "http://$server/borg/index.cfm?restart=$wid&pwd=$password&RequestTimeout=15000&debug=131&usea2acache=$a2acache";

   if ($widsonly) {
      $url = $url . "&writeflash=widsonly";
   }

   if ($skipgpiac) {
      $url = $url . "&writeflash=skipgpiac";
   }

   if ($nosubwids) {
      $url = $url . "&nosubwids=1";
   }

   if ($verbose) {
      print "URL: $url\n";
   }

   &restarturl();
}


# If we are here everything is OK
if ($verbose) {
   print "OK\n";
}
exit 0;
###################################################################################################
#
###################################################################################################

###################################################################################################
#
###################################################################################################
#BEGIN SUB ############################################################
sub flushurl {

      my $browser = LWP::UserAgent->new;
      $browser->agent('Bladelogic');
      $browser->timeout( 900 );
      my $response = $browser->get($url);
      
         die "Error at $url\n ", $response->status_line, "\n Aborting" unless $response->is_success;

         if ($dump) {
            print "DUMP: ", $response->content, "\n";
         }
      
         if ($response->content =~ m/Trusted\s+Cache\s+Flushed/i) {
            if ($verbose) {
               print "Matched\n"
            }
         }
         else {
            if ($verbose) {
               print "No Match\n";
            }
            exit 1;
         }
      
      if ($verbose) {
         print "OK\n";
      }

      if ($dump) {
         print "DUMP: ", $response->content_type, " document\n";
      }

}
#END SUB ##############################################################

###################################################################################################
#
###################################################################################################

#BEGIN SUB ############################################################
sub restarturl {

      my $browser = LWP::UserAgent->new;
      $browser->agent('Bladelogic');
      $browser->timeout( 900 );
      my $response = $browser->get($url);

      die "Error at $url\n ", $response->status_line, "\n Aborting" unless $response->is_success;
      
         if ($dump) {
            print "DUMP: ", $response->content, "\n";
         }
      
         if ($response->content =~ m/background-color:\s+green/i) {
            if ($verbose) {
               print "Matched\n"
            }
         }
         else {
            if ($verbose) {
               print "No Match\n";
            }
            exit 1;
         }
      
      if ($verbose) {
         print "OK\n";
      }

      if ($dump) {
         print "DUMP: ", $response->content_type, " document\n";
      }

}
#END SUB ##############################################################

sub errorexit() {

   print "Options: \n";
   print "
   --server = server (Mandatory String)
   --wid = WID (Optional String)
   --password = Password (Mandatory String)
   --cache = Cache On/Off (1/0) (Optional Boolean)
   --flush = Flush On/Off (1/0) (Optional Boolean)
   --widsonly = Write only modified wid flash files (Optional Boolean)
   --skipgpiac = Write all flash files except gpiac (Optional Boolean)
   --nosubwids = Do Not Restart Subwids (Optional Boolean)
   --verbose = verbose (Optional Boolean)
   --dump = dump output (Optional Boolean)
   \n";
   exit 1;

}

###################################################################################################
#
###################################################################################################




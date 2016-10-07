#!/usr/bin/perl -w
#
# $Id: check_rrd,v 1.6 2005/03/10 10:00:40 gvs Exp $
#
# this is nagios plugin for getting
# data from RRD databases which is designed
# to replace check_mrtg
#
use strict;
use RRDs;
use lib "/usr/local/libexec/nagios";
use utils qw($TIMEOUT %ERRORS &print_revision &support);
 
$0      =~ /^.*\/([^\/.]+)\.*[^\/]*$/o;
my $me  = $1;
my $int = 0;    # output in integer, default is float
 
my $usage_short = "Usage:
 $me -F log_file -a <AVERAGE | MAX> -v variable -w warning -c critical
             [-l label] [-u units] [-e expire_minutes] [-i]
  $me (-h | --help) for detailed help
  $me (-V | --version) for version information";
 
 unless ($#ARGV > -1) {
        print $usage_short, "\n";
        exit $ERRORS{'CRITICAL'};
 }
 
my ($verbose, $debug, $logfile, $variable, $warn, $crit, $aggr, $label, $unit,
        $expire, $timeout) = (0, 0, '', 0, 0, 0, 'AVERAGE', '', '', 10, 0);
 
my $detailed_help = <<eof;
 This plugin will check either the average or maximum value of one of the
 variables recorded in an RRD database.
 
 Usage:
  $me -F file -a <AVG | MAX> -v variable -w warning -c critical
             [-l label] [-u units] [-e expire_minutes] [-t timeout] [-i]
  $me (-h | --help) for detailed help
  $me (-V | --version) for version information
 
 Options:
  -F, --logfile=FILE
    The RRD database file containing the data you want to monitor
  -e, --expires=MINUTES
    Minutes before RRD data is considered to be too old
  -a, --aggregation=AVG|MAX
    Should we check average or maximum values?
  -v, --variable=STRING|INTEGER
    Which variable should we inspect (field name or number in RRD database)
  -w, --warning=INTEGER
    Threshold value for data to result in WARNING status
  -c, --critical=INTEGER
    Threshold value for data to result in CRITICAL status
  -l, --label=STRING
    Type label for data (Examples: Conns, "Processor Load", In, Out)
  -u, --units=STRING
    Option units label for data (Example: Packets/Sec, Errors/Sec,
    "Bytes Per Second", "% Utilization")
  -i, --integer
    Output integer part of result only
  -h, --help
    Print detailed help screen
  -V, --version
    Print version information
 
 If the value exceeds the <vwl> threshold, a WARNING status is returned.  If
 the value exceeds the <vcl> threshold, a CRITICAL status is returned.  Note,
 if <vcl> threshold is lower than <vwl>, the order is reversed.
 
 If the data in the log file is older than <expire_minutes> old, an UNKNOWN
 status is returned and a warning message is printed.
 
 Notes:
 - This plugin only monitors one of the variables stored in the RRD database.
   If you want to monitor more values you will have to define appropriate
   commands with different values for the <variable> argument.  Of course,
   you can always hack the code to make this plugin work for you...
 - RRD stands for the Round-Robin Database.  It can be downloaded from
   http://ee-staff.ethz.ch/~oetiker/webtools/rrdtool/
 - This software is publicly distributed under Yandex Public License, you may
   copy, modify and use it for free keeping credits to Yandex.
 
 Copyright (C) Yandex 2005
eof
 
 while ($_ = shift) {
        last if /^--$/o;
 
        /^-?-d(ebug)?/o         && ($debug      = 1, next);
        /^-(x|-verbose)/o       && ($verbose    = 1, next);
 
        if (/^-(V|-version)/o) {
                print_revision( $me, q$Revision: 1.6 $ );
                exit;
        }
 
        if (/^-(F|-logfile=?)(.*)$/o) {
                $logfile        = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-a(ggregation=?)?(.*)$/o) {
                $aggr           = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-v(ariable=?)?(.*)$/o) {
                $variable       = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-w(arning=?)?(.*)$/o) {
                $warn   = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-c(ritical=?)?(.*)$/o) {
                $crit   = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-l(abel=?)?(.*)$/o) {
                $label  = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-u(nit=?)?(.*)$/o) {
                $unit   = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-e(xpire=?)?(.*)$/o) {
                $expire = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-t(imeout=?)?(.*)$/o) {
                $timeout        = ($2 ne '') ? $2 : shift;
                next;
        }
 
        if (/^-?-i(nteger)?/o) {
                $int    = 1;
                next;
        }
 
        if (/^-?-h(elp)?/o) {
                print $detailed_help, "\n";
                exit $ERRORS{'OK'};
        }
 
        printf "Unknown argument: $_\n";
        print $usage_short, "\n";
        exit $ERRORS{'UNKNOWN'};
 }
 
 ############################################################
 
 unless (-f $logfile or -l $logfile) {
        print "Can't stat $logfile: no file found\n";
        exit $ERRORS{'UNKNOWN'};
 }
 
 my $last_updated = RRDs::last($logfile);
 my $s = $expire * 60;
 my $now = time();
 
 if ($now - $last_updated > $s) {
        printf "$logfile last updated at %s (stalled)\n",
                                        scalar localtime($last_updated);
        exit $ERRORS{'UNKNOWN'};
 }
 
 my ($start, $step, $names, $data) = RRDs::fetch($logfile, $aggr,
                                                "--start", -$s);
 
 my $ERR = RRDs::error;
 if ($ERR) {
        printf "ERROR reading $logfile: $ERR\n";
        exit $ERRORS{'UNKNOWN'};
 }
 
 my $t = $start;
 
 if ($verbose) {
        print "Start:       ", scalar localtime($start), " ($start)\n";
        print "Step size:   $step seconds\n";
        print "DS names:    ", join (", ", @$names)."\n";
        print "Data points: ", $#$data + 1, "\n";
        print "Data:\n";
 
        foreach my $line (@$data) {
                print "  ", scalar localtime($t), " ($t) ";
                $t += $step;
                foreach my $val (@$line) {
                        if (defined $val) {
                                printf "%12.2f ", $val;
                        } else {
                                print "         NaN ";
                        }
                }
                print "\n";
        }
 }
 
 # find variable
 my $col;
 my $row = $#$data;
 
 if ($variable =~ /\D/o) {
        for ($col = 0; $col <= $#$names; $col++) {
                last if ($names->[$col] eq $variable); 
        }
 
        if ($col > $#$names) {
                print "Field $variable not found in $logfile\n";
                exit $ERRORS{'UNKNOWN'};
        }
 } else {
        $col = $variable - 1;
        $variable = $names->[$col];
 }
 
# now catch latest result
 for ($t = $start + $step * $row; $row > -1; $row--, $t -= $step) {
        last if (defined $data->[$row]->[$col]);
 }
 
 # perform validity checks:
 if ($now  - $t > $expire * 60) {
        printf "Variable $variable last updated at %s (stalled)\n",
                                                scalar localtime($t);
        exit $ERRORS{'UNKNOWN'};
 }
 
 my $value = $data->[$row]->[$col];
 my $result;
 
 # TODO: thresholds
 if ($crit < $warn) {   # critical condition occurs when lowering value
        $result = ($value < $crit) ? 'CRITICAL' :
                        ($value < $warn) ? 'WARNING' : 'OK';
 } else {
        $result = ($value > $crit) ? 'CRITICAL' :
                        ($value > $warn) ? 'WARNING' : 'OK';
 }
 
 my $mask       = ($int or int($value) == $value) ? '%d' : '%.3f';
 
 printf "$result \%s \%s = $mask \%s\n", ucfirst(lc($aggr)), $variable, $value, $unit;
 exit $ERRORS{$result};
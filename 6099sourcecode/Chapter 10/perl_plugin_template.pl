#!/usr/bin/perl -w

use strict;
use Getopt::Long;

use lib "/usr/local/nagios/libexec";
use utils qw($TIMEOUT %ERRORS &print_revision &support &usage);
use vars qw($PROGNAME);
use vars qw($opt_V $opt_h $verbose $opt_H $opt_w $opt_c);

$PROGNAME = "perl_plugin_template";

sub print_help ();
sub print_usage ();

$ENV{'PATH'}='';
$ENV{'BASH_ENV'}='';
$ENV{'ENV'}='';

Getopt::Long::Configure('bundling');
GetOptions
        ("V"   => \$opt_V, "version"    => \$opt_V,
         "h"   => \$opt_h, "help"       => \$opt_h,
         "v" => \$verbose, "verbose"  => \$verbose,
         "H=s" => \$opt_H, "hostname=s" => \$opt_H,
         "w=s" => \$opt_w, "warning=s"  => \$opt_w,
         "c=s" => \$opt_c, "critical=s" => \$opt_c);

if ($opt_V) {
        print_revision($PROGNAME,'$Revision: 1.4 $'); #'
        exit $ERRORS{'OK'};
}

if ($opt_h) {
        print_help();
        exit $ERRORS{'OK'};
}

($opt_H) || ($opt_H = shift) || usage("Host name not specified\n");
my $host = $1 if ($opt_H =~ m/^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[a-zA-Z][-a-zA-Z0]+(\.[a-zA-Z][-a-zA-Z0]+)*)$/);

($opt_w) || ($opt_w = shift) || usage("You must specify a warning value.\n");
my $warning = $1 if ($opt_w =~ /([0-9]+)/);

($opt_c) || ($opt_c = shift) || usage("You must specify a critical value.\n");
my $critical = $1 if ($opt_c =~ /([0-9]+)/);

# Insert plug-in logic here

sub print_usage () {
        print "This section tells you what the plug-in does.\n";
}

sub print_help () {
        print_revision($PROGNAME,'$Revision: 1.4 $');
        print "Copyright (c) 2006 James Turnbull\n";
        print "\n";
        print_usage();
        print "\n";
        print "<warn> = The warning threshold should be...\n";
        print "<crit> = The critical threshold should be...\n\n";
        support();
}

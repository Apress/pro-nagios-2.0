#!/usr/bin/perl -w

use strict;
use DBI;

my $timet = $ARGV[0];
my $hostname = $ARGV[1];
my $servicedesc = $ARGV[2];
my $servicestateid = $ARGV[3];
my $servicestate = $ARGV[4];
my $serviceoutput = $ARGV[5];
my $serviceperfdata = $ARGV[6];

my $dsn = 'DBI:mysql:nagios_db:localhost';
my $db_user_name = 'nagios';
my $db_password = 'password';

my $dbh = DBI->connect($dsn, $db_user_name, $db_password)
        or die "Couldn't connect to database: " . DBI->errstr;

my $sth = $dbh->prepare( q{
                    insert into service_data
                    (timet, host_name, service_description, service_state_id, service_state, service_output, service_perf_data)
                    values
                    (?, ?, ?, ?, ?, ?, ?)
            });

$sth->execute($timet, $hostname, $servicedesc, $servicestateid, $servicestate, $serviceoutput, $serviceperfdata);

$dbh->disconnect;

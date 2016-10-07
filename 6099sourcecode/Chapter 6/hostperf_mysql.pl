#!/usr/bin/perl -w

use strict;
use DBI;

my $timet = $ARGV[0];
my $hostname = $ARGV[1];
my $hostalias = $ARGV[2];
my $hoststateid = $ARGV[3];
my $hoststate = $ARGV[4];
my $hostoutput = $ARGV[5];
my $hostperfdata = $ARGV[6];

my $dsn = 'DBI:mysql:nagios_db:localhost';
my $db_user_name = 'nagios';
my $db_password = 'password';

my $dbh = DBI->connect($dsn, $db_user_name, $db_password)
        or die "Couldn't connect to database: " . DBI->errstr;

my $sth = $dbh->prepare( q{
                    insert into host_data
                    (timet, host_name, host_alias, host_state_id, host_state, host_output, host_perf_data)
                    values
                    (?, ?, ?, ?, ?, ?, ?)
            });

$sth->execute($timet, $hostname, $host_alias, $hoststateid, $hoststate, $hostoutput, $hostperfdata);

$dbh->disconnect;


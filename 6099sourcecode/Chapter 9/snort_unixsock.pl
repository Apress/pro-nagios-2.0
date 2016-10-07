#!/usr/bin/perl -w
use strict;
use IO::Socket;

# Confirm socket is not connected

unlink "/var/log/snort/snort_alert";

# Connect to socket

my $client = IO::Socket::UNIX->new(Type => SOCK_DGRAM,
                   Local => "/var/log/snort/snort_alert")
  or die "Socket: $@";

print STDOUT "Socket Open ... \n";

# Loop receiving data from the socket, pulling out the
# alert name and printing it.

my $data;

# Adjust this template to extract further data from the socket
my $template = "A256 A*";
my $alert_type;
use constant true => 1; 

while ( true ) {
    recv($client,$data,1024,0);
    ($alert_type) = unpack($template, $data);
    
# Output alert type to STDOUT - you can modify this to perform other functions
    print "$alert_type \n";
}

# Close socket

END {unlink "/var/log/snort/snort_alert";}
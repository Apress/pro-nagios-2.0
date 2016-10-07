#!/usr/bin/perl -w
#
# Accepts a fully formed email address on stdin.  If the message doesn't
# get throttled, send it.  Otherwise, send a "too many pages" message,
# and throw away the message.
#
# Mark Ferlatte <ferlatte@cryptio.net>

use strict;
use Fcntl qw(:flock);
use Getopt::Long;
use IO::File;
use Mail::Address;
use Mail::Internet;

sub throttle($$$);
sub send_throttle_note($);

my ($help, $msg, $msghead, $rate, $statedir, $to, $throttlemsgfile, @tolist);

$statedir = '/var/tmp/state.db';

# Default to 2 million emails/second.
$rate = '2000000:1';

GetOptions( 'r|rate=s' => \$rate,
						's|state=s' => \$statedir,
						'm|message=s' => \$throttlemsgfile,
						'h|help' => \$help,
					) or die;

if ($help)
{
	print("mail-throttle [OPTIONS]\n");
	print("Accepts an RFC822 message on stdin, and either email that message\n");
	print("or throttle it (not send it, but send a note once.");
	print("--rate=MSGS:SECONDS					Allow MSGS per SECONDS\n");
	print("--state=/path/to/dir					Where to store state.\n");
	print("--message=/path/to/throttlemsgs Where the throttle email is.\n");
	print("--help                       Prints this help.\n");
	exit(0);
}

mkdir($statedir, 0755) or die "$!" unless -d $statedir;

$msg = Mail::Internet->new(*STDIN) or die "$!";
$msghead = $msg->head() or die "$!";
@tolist = Mail::Address->parse($msghead->get('To'));

for $to (@tolist)
{
	my ($nummsgs, $seconds) = split(/:/, $rate);
	if (throttle($to->address(), $nummsgs, $seconds))
	{
		send_throttle_note($to->address());
	}
	else 
	{
		$msg->send();
	}
}

exit(0);

# Input: 1 email address as a string, 1 number of messages as int,
# 1 number of seconds as int.
# Return: true if throttling should occur, false if okay to send.
# Side effect: Updates the state db.
#
# If number of message per number of seconds is exceeded, throttle.
sub throttle($$$)
{
	my ($addr, $nummsgs, $numsecs) = @_;
	my ($fh, @timestamps, $retval);
	my $now = time();
	my $dbfile = "$statedir/$addr";
	my $throttlefile = "$statedir/$addr.throttled";
	if (-e $dbfile) {
		$fh = IO::File->new($dbfile, "r+") or 
			die "Unable to open state db: $! $dbfile";
	} 
	else 
	{
		$fh = IO::File->new($dbfile, "w+") or
			die "Unable to open state db: $! $dbfile";
	}
	flock($fh, LOCK_EX);
	foreach my $line ($fh->getlines())
	{
		next unless defined $line;
		chomp($line);
		if (($now - $line) <= $numsecs)
		{
			push(@timestamps, $line);
			$nummsgs -= 1;
		}
	}
	push(@timestamps, $now);
	$fh->seek(0, 0);
	$fh->truncate(0);
	foreach my $line (@timestamps)
	{
		$fh->print($line . "\n");
	}
	flock($fh, LOCK_UN);
	$fh->close();
	if ($nummsgs <= 0)
	{
		$retval = 1;
	} 
	else
	{
		$retval = 0;
		if (-e $throttlefile)
		{
			unlink($throttlefile);
		}
	}
	return $retval;
}

# Input: email address that was throttled
# Side effect: xmits email to that address stating that they are throttled.
# Only send once per throttling incident.
# How?  Create a lock file: throttle will remove it.
sub send_throttle_note($)
{
	my ($addr) = @_;
	my $throttlefile = "$statedir/$addr.throttled";
	my $throttlemsg;
	if (-e $throttlefile)
	{
		return;
	}
	my $fh = IO::File->new($throttlefile, "w+") or die "$!";
	$fh->close();
	# Send too many pages message
	$fh = IO::File->new($throttlemsgfile) or die "$!";
	if (defined $fh)
	{
		$throttlemsg = Mail::Internet->new($fh);
		$throttlemsg->head()->replace('To', $addr);
		$throttlemsg->send();
		$fh->close();
	}
}


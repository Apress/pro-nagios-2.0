#!/bin/sh

# Arguments:
# $1 = Hostname of the host (using the $HOSTNAME$ macro)
# $2 = Host Status ID of the host (using the $HOSTSTATUSID$ macro)
# $3 = Output of the host check (using the $HOSTOUTPUT$ macro)

/bin/echo "$1","$2","$3" | /usr/local/nagios/bin/send_nsca -H ip_address -c /usr/local/nagios/etc/send_nsca.cfg -d ","
#!/bin/sh

# Arguments:
# $1 = Hostname of the host (using the $HOSTNAME$ macro)
# $2 = Service Description of the service (using the $SERVICEDESC$ macro)
# $3 = Service Status ID of the service (using the $SERVICESTATUSID$ macro)
# $4 = Output of the service check (using the $SERVICEOUTPUT$ macro)

/bin/echo "$1","$2","$3","$4" | /usr/local/nagios/bin/send_nsca -H ip_address -c /usr/local/nagios/etc/send_nsca.cfg -d ","

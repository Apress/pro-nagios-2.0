#!/bin/bash
while read line
  do
    /bin/echo "$line" | /usr/local/nagios/bin/send_nsca -H 10.0.0.31 -c /usr/local/nagios/etc/send_nsca.cfg -d ","
  done < /var/run/nagios.pipe

exit 0
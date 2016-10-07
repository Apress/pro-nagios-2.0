#!/bin/sh

cmd_file=/usr/local/nagios/var/rw/nagios.cmd

/usr/local/nagios/libexec/check_nrpe -H 10.0.0.1 -c check_nagios
return_code=$?

case "$return_code" in
            '0')
             TIME=`date +%s`
             echo "[$TIME] STOP_EXECUTING_SVC_CHECKS" >> $cmd_file
             echo "[$TIME] STOP_EXECUTING_HOST_CHECKS" >> $cmd_file
             echo "[$TIME] DISABLE_NOTIFICATIONS" >> $cmd_file
             ;;
            '2')
             TIME=`date +%s`
             echo "[$TIME] START_EXECUTING_SVC_CHECKS" >> $cmd_file
             echo "[$TIME] START_EXECUTING_HOST_CHECKS" >> $cmd_file
             echo "[$TIME] ENABLE_NOTIFICATIONS" >> $cmd_file
             ;;
esac
exit 0

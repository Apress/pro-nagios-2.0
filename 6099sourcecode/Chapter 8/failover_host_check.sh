#!/bin/sh

cmd_file=/usr/local/nagios/var/rw/nagios.cmd

case "$1" in
HARD)
        case "$2" in
        0)
             TIME=`date +%s`
             echo "[$TIME] STOP_EXECUTING_SVC_CHECKS" >> $cmd_file
             echo "[$TIME] STOP_EXECUTING_HOST_CHECKS" >> $cmd_file
             echo "[$TIME] DISABLE_NOTIFICATIONS" >> $cmd_file
             ;;
         1)
             TIME=`date +%s`
             echo "[$TIME] START_EXECUTING_SVC_CHECKS" >> $cmd_file
             echo "[$TIME] START_EXECUTING_HOST_CHECKS" >> $cmd_file
             echo "[$TIME] ENABLE_NOTIFICATIONS" >> $cmd_file
             ;;
        esac
        ;;
esac
exit 0

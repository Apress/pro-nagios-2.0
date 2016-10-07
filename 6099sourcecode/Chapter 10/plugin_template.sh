#!/bin/sh
PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`

. $PROGPATH/utils.sh

print_usage() {
        echo "Usage: $PROGNAME"
}

print_help() {
        print_revision $PROGNAME $REVISION
        echo ""
        print_usage
        echo ""
        echo "This plugin is a plug-in template written in shell script."
        echo ""
        support
        exit 0
}

case "$1" in
        --help)
                print_help
                exit 0
                ;;
        -h)
                print_help
                exit 0
                ;;
        --version)
                print_revision $PROGNAME $REVISION
                exit 0
                ;;
        -V)
                print_revision $PROGNAME $REVISION
                exit 0
                ;;
        *)
                testdata=`test -e t1`
                status=$?
                if test "$1" = "-v" -o "$1" = "--verbose"; then
                        echo ${testdata}
                fi

                  if test ${status} -eq 1; then
                        echo "UNKNOWN: The plug-in has failed to function"
                        exit 3

                      elif echo ${testdata} | egrep WARNING > /dev/null; then
                           echo "WARNING: The plug-in returned $status"
                           exit 1
             
                      elif echo ${testdata} | egrep CRITICAL > /dev/null; then
                           echo "CRITICAL: The plug-in returned $status"
                           exit 2
              
                      else test ${status} -eq 0 ; 
                           echo "OK: The plug-in returned $status"
                           exit 0
                  fi
                  ;;
esac

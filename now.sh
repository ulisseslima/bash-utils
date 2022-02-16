#!/bin/bash
format="$1"

case "$format" in
        WEEKDAY|-w|--weekday)
                df="%u"
        ;;
        MONTH|-m|--month)
                df="%m"
        ;;
        YEAR|-y|--year)
                df="%Y"
        ;;
        DATE|-d|--date)
                df="%Y-%m-%d"
        ;;
        DT|DATET|DATETIME|DATE_TIME|-dt|--datetime|--date-time)
                df="%Y-%m-%d %H:%M:%S"
        ;;
        -f|--file)
                df="%Y-%m-%d_%Hh%M"
        ;;
        T|TIME|-t|--time)
                df="%H:%M:%S"
        ;;
        H|HOUR|-h|--hour)
                df="%H"
        ;;
        M|--min|--minute)
                df="%M"
        ;;
        D|DAY|--day)
                df="%d"
        ;;
        *)
		echo $(($(date +%s%N)/1000000))
		exit 0
	;;
esac

date +"$df"

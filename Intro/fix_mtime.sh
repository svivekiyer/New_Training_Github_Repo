#!/bin/bash

#Script to reset timestamp of Store Candidate and report.
#Ver 1 : Edited reporting and added email to send reporting.
#Will be running this script every 4 hour's.


rm /tmp/storecan_mtime.csv $2>1
for class in `mysql -sNe "select classndx from tmdb.classdef;"`
do
# Remove previous storecand--files file
  if [ -e /tmp/storecand${class}files ]
  then
    rm -f /tmp/storecand${class}files
  fi
# Determine correct file system
  devkey=`mysql -sNe "select device_key from tmdb.classdir where classndx=${class};" | uniq`
  if [ -z $devkey ]; then
    continue
  elif [ $devkey -eq "1" ]; then
    fs="archive"
  fi
# Create list of files in the storecand table
  for fhino in `mysql -sNe "select fhino from tmdb.storecand${class};"`
  do
    echo "rpl ${fhino}" | cvfsdb $fs 2>&1 | grep \/ 1>>/tmp/storecand${class}files
  done
# Fix line to show full path
    if [ -e /tmp/storecand${class}files ]
    then
        sed -i "s/^\//\/stornext\/$fs\//g" /tmp/storecand${class}files
        # Touch file to fix bad mtime
        while read line
        do
                if [ `date +%s` -lt `dm_info "$line" | grep mtime | awk '{print $3}'` ]
                then
                        before_update=`dm_info "$line" | grep -i mtime | awk '{$1=$2=$3=$4=""; print $0}'`
                        curdate=`date +%s`
                        fino=`dm_info "${line}" | grep "ino:" | awk '{print $2}'`
                        touch "${line}"
                        mysql -e "update tmdb.storecand${class} set mtime = $curdate where fhino=$fino;"
                        after_update=`dm_info "$line" | grep -i mtime | awk '{$1=$2=$3=$4=""; print $0}'`
                        echo $line , $before_update , $after_update >> /tmp/storecan_mtime.csv
                fi
        done < /tmp/storecand${class}files
    fi
done

#send email
/bin/mail -S smtp='smtp://mail-gw.corp.linkedin.com' -s 'Show_MTime_Of_Files' -a /tmp/storecan_mtime.csv -r viiyer@linkedin.com viiyer@linkedin.com  < /tmp/storecan_mtime.csv
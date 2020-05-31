#!/usr/bin/env bash
# Created by:   Vivek
# Purpose:      Show the utilization of tapes slot's Carp Library
#Script # /usr/adic/HAM/shared/cte_scripts/mtx_utilization/mtx_utilization.sh
#Ver1: 26th Mar 2019

host1=`hostname`
source /usr/adic/.profile
chk_primary=`snhamgr -m status | awk 'BEGIN { FS = ":" }; {print $3}'`

if [ "$chk_primary" = "primary" ]
then
	{
		echo ""
		echo "We are in Primary MDC. Proceeding with Script."
		echo ""
		echo ===========================================

        date1=`date +%Y%m%d_%H%M%S`;
        /usr/sbin/mtx -f `fs_scsi -p | grep changer | awk '{print $NF}'` status > /tmp/mtx_status_$date1

        total_slots=`cat /tmp/mtx_status_$date1 | egrep -v 'Export|EXPORT|Transfer' | wc -l`
        full_slots=`cat /tmp/mtx_status_$date1 | egrep -v 'Data|EXPORT' | grep Full | wc -l`
        empty_slot=`cat /tmp/mtx_status_$date1 | egrep -v 'Data|EXPORT' | grep -v Full | grep -v Changer | wc -l`
        echo Total Slots : $total_slots | tee -a /tmp/mtx_output_$date1
        used_percent=$((100*$full_slots/$total_slots))
        empty_percent=$((100*$empty_slot/$total_slots))

        echo Used Slots : $full_slots " & Used Percentage :" $used_percent | tee -a /tmp/mtx_output_$date1
        echo Empty Slots : $empty_slot "& Empty Percentage :" $empty_percent | tee -a /tmp/mtx_output_$date1

        #Send Email
        from='carmdc@linkedin.com'
        subject="Tape_Utilization_"$date1
        attachment1="/tmp/mtx_output_$date1"
        to='viiyer@linkedin.com'

        /bin/mail -S smtp='smtp://relay.lynda.com' -s $subject -r $from -a $attachment1 $to < $attachment1

        #Remove file after operation
        #rm -f /tmp/mtx_output_$date1
        #rm -f /tmp/mtx_status_$date1
    }
fi

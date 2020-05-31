#!/bin/sh

echo "#################################################################################"
echo "##### This Script is for alerting if TSM is not performing copy to tapes    #####"
echo "#################################################################################"

#This edit is for script from carmdc2 server
#Ver01--- Jan 10 2019

#Cleanup old file
rm /usr/local/bin/check_tsm/output.log &>/dev/null

host1=`hostname`
date1=`date +%Y%m%d_%H%M%S`;

source /usr/adic/.profile
chk_primary=`snhamgr -m status | awk 'BEGIN { FS = ":" }; {print $3}'`

if [ "$chk_primary" = "primary" ]
then
	{
		echo ""
		echo "We are in Primary MDC. Proceeding with Script."
		echo ""
		echo ===========================================

		#Check if Store Candidates are present.
		store_candidate=`showc /stornext/archive | grep -i entries | awk '{print $2}'`

		if [ "$store_candidate" -gt "1" ]
		then
		{
				trace_time=`cat /usr/adic/TSM/logs/trace/trace_01 | tail -1 | cut -c 1-15`
				trace_epoch=$(date -d "${trace_time}" +"%s")
				timenow_epoch=`date +%s`
				Delta_Time=`expr $timenow_epoch - $trace_epoch`
				Tapes_avail=`fsmedlist -glb | grep -i "Total # of media in class 'genscratch'" | awk '{print $9}'`
				Delta_Time_Minutes=`expr $Delta_Time / 60 `
				Delta_Time_Hour=`expr $Delta_Time_Minutes / 60 `

				if [ "$Delta_Time" -gt "900" ]
				then
					{
						echo $host1 >> /usr/local/bin/check_tsm/output.log
						echo =========================================== >> /usr/local/bin/check_tsm/output.log
						showc_count=`showc /stornext/archive | grep found | awk '{print $2}'`
                        echo No of Store Candidates :  $showc_count >> /usr/local/bin/check_tsm/output.log
						echo Tapes available in Library: $Tapes_avail >> /usr/local/bin/check_tsm/output.log
                        echo =========================================== >> /usr/local/bin/check_tsm/output.log
						echo "Last Data copy to tape happened before : "$Delta_Time_Minutes" minutes ( "$Delta_Time_Hour" Hours) which is more than 15 Minutes checkpoint." >> /usr/local/bin/check_tsm/output.log
						echo =========================================== >> /usr/local/bin/check_tsm/output.log
						echo "Files are not transferring to tape. Please check TSM". >> /usr/local/bin/check_tsm/output.log
						echo =========================================== >> /usr/local/bin/check_tsm/output.log

						cat /usr/local/bin/check_tsm/output.log
						echo "Sending email with above information"
                        

						#Send Email
						from='carmdc@linkedin.com'
						subject="IMP_TSM_Issue_"$host1"_"$date1
						attachment1="/usr/local/bin/check_tsm/output.log"
						to='viiyer@linkedin.com'

						/bin/mail -S smtp='smtp://mail-gw.corp.linkedin.com' -s $subject -r $from -a $attachment1 $to < $attachment1

                        if [ "$Tapes_avail" -gt "1" ]
                        then   
                            echo "Running the snsm_fix_time script to correct the timing of Store candidates."
                            sh /usr/adic/HAM/shared/cte_scripts/reset_storecand/snsm_fix_mtime.sh
                        fi
					}
				else
					{
						echo "" >> /usr/local/bin/check_tsm/output.log
						echo "Last Data copy to tape happened before : "$Delta_Time_Minutes" minutes which is less than 15 Minutes checkpoint" >> /usr/local/bin/check_tsm/output.log
						echo No Action required currently as TSM is performing as expected. >> /usr/local/bin/check_tsm/output.log
						echo "" >> /usr/local/bin/check_tsm/output.log
						echo "********Script Ending **********" >> /usr/local/bin/check_tsm/output.log
						echo "" >> /usr/local/bin/check_tsm/output.log
						cat /usr/local/bin/check_tsm/output.log
					}
				fi
		}
		else
		{
			echo There are no store candidates. So all good. >> /usr/local/bin/check_tsm/output.log
			cat /usr/local/bin/check_tsm/output.log
		}
		fi

	}
else
	{
		echo "This script must be run on the PRIMARY MDC." >> /usr/local/bin/check_tsm/output.log
		cat /usr/local/bin/check_tsm/output.log
	}
fi
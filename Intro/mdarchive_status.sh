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


						#Send Email
						from='carmdc@linkedin.com'
						subject="IMP_TSM_Issue_"$host1"_"$date1
						attachment1="/usr/local/bin/check_tsm/output.log"
						to='viiyer@linkedin.com'

						/bin/mail -S smtp='smtp://relay.lynda.com' -s $subject -r $from -a $attachment1 $to < $attachment1

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
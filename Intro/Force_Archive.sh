#!/bin/bash
# Created by:   Vivek
# Purpose:      Keep the Archive Utilization aroung 80%.
#script:/usr/adic/HAM/shared/cte_scripts/truncation/archive_ldcsan_truncation.sh
#Ver1: 26th Mar 2019
#run every 15 mins and only from Primary MDC

rm /tmp/truncation_output.001 $2>1

host1=`hostname`
source /usr/adic/.profile
chk_primary=`snhamgr -m status | awk 'BEGIN { FS = ":" }; {print $3}'`

if [ "$chk_primary" = "primary" ]
then
        {
                touch /usr/adic/HAM/shared/cte_scripts/truncation/truncation_lock.001
                file="/usr/adic/HAM/shared/cte_scripts/truncation/truncation_lock.001"
                if [ -f "$file" ]
                then
                    echo "" | tee -a /tmp/truncation_output.001
                    echo "We are in Primary MDC. Proceeding with Script." | tee -a /tmp/truncation_output.001
                    echo "" | tee -a /tmp/truncation_output.001
                    echo =========================================== | tee -a /tmp/truncation_output.001
                    for fs_name in archive LDCSAN01 ; do

                            before_utilization=`df -h | grep -i $fs_name | awk '{print $5}' | sed 's/%//g'`
                            #Changing the benchmark to 89%, to keep the filesystem utilization below 90.
                            benchmark=89

                            if [ "$before_utilization" -ge "$benchmark" ] ; then

                                echo "*******************************************" | tee -a /tmp/truncation_output.001
                                echo "Running forceful truncation on " $fs_name "Filesytem" | tee -a /tmp/truncation_output.001
                                echo =========================================== | tee -a /tmp/truncation_output.001
                                value1=`df -h | grep -i $fs_name`
                                echo "Before Truncation : " $value1 | tee -a /tmp/truncation_output.001
                                echo =========================================== | tee -a /tmp/truncation_output.001
                                fs_path=`df -h | grep -i $fs_name | awk '{print $6}'`
                                fspolicy -t -y $fs_path -e -o $benchmark | tee -a /tmp/truncation_output.001
                                value1=`df -h | grep -i $fs_name`
                                echo =========================================== | tee -a /tmp/truncation_output.001
                                echo "After Truncation : " $value1 | tee -a /tmp/truncation_output.001
                               
                            else
                                echo "No truncation required for "$fs_name " filesystem." | tee -a /tmp/truncation_output.001
                            fi 
                            rm -f /usr/adic/HAM/shared/cte_scripts/truncation/truncation_lock.001
                    done

                fi
        }
fi


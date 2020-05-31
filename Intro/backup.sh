echo -n "Enter the Source folder which you want to retrieve (Under Double quotes) :- " ; read source_path
echo " "



echo -n "Enter the Destination Folder where you want files to be copied.(Under Double quotes) :- " ; read destination_path
echo " "


echo "==================================================="
echo "Verify Source Folder :-" $source_path
echo " "
echo "Verify Destination Folder :-" $destination_path
echo " "

echo -n "Do you want to proceed (Y/N)? " ; read choice

if [ "$choice" = "Y" ]
then
        {
                echo ""
                echo "==================================================="
                echo ""
                echo "Moving Files to Stornext to perform operation"
                echo "fsretrieve -a -p -R $source_path" > /home/encoding/retrive.sh
                echo "/usr/cvfs/bin/cvcp -Aud -t20 $source_path $destination_path" > /home/encoding/migration.sh
                echo ""
                scp /home/encoding/retrive.sh root@10.35.1.17:/usr/adic/HAM/shared/cte_scripts/encoding_retrieve/
                #scp /home/encoding/migration.sh root@10.35.1.17:/usr/adic/HAM/shared/cte_scripts/encoding_retrieve/
                echo "==================================================="
                
                echo "find $source_path -type f | wc -l" > /home/encoding/source_file_count.sh
                source_file_count=`sh /home/encoding/source_file_count.sh`
                
                echo "du -s --apparent-size "$source_path > /home/encoding/source_dir_size.sh
                source_dir_size=`sh /home/encoding/source_dir_size.sh | awk '{print $1}'`
                source_dir_size_mb=`expr $source_dir_size / 1024 `
                source_dir_size_gb=`expr $source_dir_size_mb / 1024 `

                echo "du -s "$source_path > /home/encoding/source_dir_size_in_disk.sh
                source_dir_size_in_disk=`sh /home/encoding/source_dir_size_in_disk.sh | awk '{print $1}'`
                source_dir_size_in_disk_mb=`expr $source_dir_size_in_disk / 1024 `
                source_dir_size_in_disk_gb=`expr $source_dir_size_in_disk_mb / 1024 `

                tape_restore_size_kb=`expr $source_dir_size - $source_dir_size_in_disk`
                tape_restore_size_mb=`expr $tape_restore_size_kb / 1024 `
                tape_restore_size_gb=`expr $tape_restore_size_mb / 1024 `
                
                echo "File Count in Source Folder : " $source_file_count
                echo "Total data/size of Source Folder = " $source_dir_size_mb"(MB) /"$source_dir_size_gb"(GB)"
                echo "Current data/size of Source Folder = " $source_dir_size_in_disk_mb"(MB) /"$source_dir_size_in_disk_gb"(GB)"
                echo "Data/Size to retrieve from Tape = " $tape_restore_size_mb"(MB) /"$tape_restore_size_gb"(GB)"
                echo " "
                echo "Note: Time required to retrieve data is directly dependent on size how much to retrieve from tape."
                echo "--------------------------------------------------"
                echo "Retrieve Starting....."
                echo " "
                ssh root@10.35.1.17 /usr/adic/HAM/shared/cte_scripts/encoding_retrieve/retrive.sh
                echo "==================================================="
                echo "Fetrieve has finished."
                echo "==================================================="
                echo "Now proceeding with Migration of Data from Source to Destination."
                echo " "
                sh /home/encoding/migration.sh
                echo "==================================================="
                echo "Data Migration has finished."
                echo "==================================================="
                echo " "
                #post verification of Files and Size to compare. 
                echo "find $destination_path -type f | wc -l" > /home/encoding/destination_file_count.sh
                echo "du -sh --apparent-size "$destination_path > /home/encoding/destination_dir_size.sh
                destination_file_count=`sh /home/encoding/destination_file_count.sh`
                destination_dir_size=`sh /home/encoding/destination_dir_size.sh | awk '{print $1}'`

                echo "Verifing the File Count and Size on Source and Destination Folder"
                echo " "
                echo "Source Directory/File Size (GB): " $source_dir_size_gb " & Source File Count : " $source_file_count
                echo "Destination Directory/File Size(GB) : " $destination_dir_size " & Source File Count : " $destination_file_count
                echo "==================================================="

        }
else
        {
                echo " "
                echo "Please re-run the script with correct path."
        }
fi

echo ""
#removing temp files:--
rm /home/encoding/retrive.sh
rm /home/encoding/migration.sh
rm /home/encoding/destination_dir_size.sh
rm /home/encoding/source_dir_size.sh
rm /home/encoding/destination_file_count.sh
rm /home/encoding/source_file_count.sh
rm /home/encoding/source_dir_size_in_disk.sh

echo "Script has completed."
echo "****************************************"
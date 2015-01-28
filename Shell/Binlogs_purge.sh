#!/bin/bash
# Author: Gaurav Tomar
user=purge_rep
passwd='redhat'
master_ip=`mysql -u$user -p$passwd -e "Show slave status\G" |grep -i "Master_Host:" |gawk '{print $2}'`
Relay_master_log_file=`mysql -u$user -p$passwd -h$master_ip -e "Show slave status\G" |grep -i "Relay_Master_Log_File:" |gawk '{print $2}'`
Seconds_Behind_Master=`mysql -u$user -p$passwd -h$master_ip -e "Show slave status\G" |grep -i "Seconds_Behind_Master:"|gawk '{print $2}'`
Slave_IO_Running=`mysql -u$user -p$passwd -h$master_ip -e "Show slave status\G" |grep -i "Slave_IO_Running:"|gawk '{print $2}'`
Slave_SQL_Running=`mysql -u$user -p$passwd -h$master_ip -e "Show slave status\G" |grep -i "Slave_SQL_Running:"|gawk '{print $2}'`
master_count=`mysql -u$user -p$passwd -N -e "select count(*) from wave2.call_policy_data cpd, wave2.call_policy cp where cp.id = cpd.call_policy_id and         (cpd.daily_count >= cp.daily_limit OR cpd.weekly_count >= cp.weekly_limit OR  cpd.fortnightly_count >= cp.fortnightly_limit OR cpd.monthly_count >= cp.monthly_limit OR cpd.vas_count >= cp.vas_monthly_limit OR cpd.non_vas_count >= cp.non_vas_monthly_limit);"`
mirror_count=`mysql -u$user -p$passwd -h$master_ip -N -e "select count(*) from wave2.call_policy_data cpd, wave2.call_policy cp where  cp.id = cpd.call_policy_id and  (cpd.daily_count >= cp.daily_limit OR cpd.weekly_count >= cp.weekly_limit OR  cpd.fortnightly_count >= cp.fortnightly_limit OR cpd.monthly_count >= cp.monthly_limit OR cpd.vas_count >= cp.vas_monthly_limit OR cpd.non_vas_count >= cp.non_vas_monthly_limit);"`


if [ "$Slave_IO_Running" = "Yes" ] && [ "$Slave_SQL_Running" = "Yes" ] && [ $Seconds_Behind_Master = 0 ];then
        if [ $master_count -eq $mirror_count ]; then
file="$( cut -d '.' -f 1 <<< "$Relay_master_log_file" )";
number="$( cut -d '.' -f 2- <<< "$Relay_master_log_file" )";
count=${#number}
number1=`expr $number - 1`
number2=`printf "%0$count"d $number1`
mysql -u$user -p$passwd -e "Purge binary logs to '$file.$number2';"
echo "`date`: Purged binary logs till '$file.$number2'" >>/usr/local/bin/purge_binlogs/track.txt
else
echo -e "`date`: Master-Mirror count mismatch\nmaster_count: $master_count\nmirror_count: $mirror_count">>/usr/local/bin/purge_binlogs/track.txt
fi
else
echo -e "`date`: Servers Not in Sync\nmaster_ip: $master_ip\nRelay_master_log_file: $Relay_master_log_file\nSeconds_Behind_Master: $Seconds_Behind_Master\nSlave_IO_Running: $Slave_IO_Running\nSlave_SQL_Running: $Slave_SQL_Running" >>/usr/local/bin/purge_binlogs/track.txt
fi

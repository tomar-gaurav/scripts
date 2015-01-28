#!/bin/bash

date=`date '+%Y%m%d'`
file_path=/tmp/tbl_tertiary_bckup
table_name=ussd_deal_details
db_name=dba
duration_type=month
duration=3
user=admin
passwd='asdwe#IBDds34asdf34'

table1=0
table2=0
table1=`mysql -u$user -p$passwd -N -e "select count(1) from information_schema.TABLES where TABLE_NAME='${table_name}' and TABLE_SCHEMA='${db_name}';"`
table2=`mysql -u$user -p$passwd -N -e "select count(1) from information_schema.TABLES where TABLE_NAME='${table_name}_${date}' and TABLE_SCHEMA='${db_name}';"`

if [[ "$table1" -eq 1 ]];
then
	if [[ "$table2" -eq 0 ]];
	then

mysql -u$user -p$passwd  -e " use $db_name;rename table $table_name to ${table_name}_${date}; create table $table_name like ${table_name}_${date}; INSERT INTO $table_name SELECT * FROM ${table_name}_${date}  where DATE(time) >= '`date --date="${duration} ${duration_type} ago" +%Y-%m-%d`';" ;
mysqldump -u$user -p$passwd $db_name ${table_name}_$date |gzip > ${file_path}/${table_name}_${date}.sql.gz
result=`mysql -u$user -p$passwd -N -e "use $db_name;select concat(max(time),' and ',min(time)) from ${table_name}_${date};"`
result1=`mysql -u$user -p$passwd -N -e "use $db_name;select concat(max(time),' and ',min(time)) from ${table_name};"`

if test -e "${file_path}/${table_name}_${date}.sql.gz";
then
    chmod 777 ${file_path}/${table_name}_${date}.sql.gz
	status=`zcat ${file_path}/${table_name}_$date.sql.gz|tail -1`
	if [[ "$status" == *"Dump completed"* ]];
	then
		#mysql -uroot -e "use $db_name;drop table $table_name_${date};";
		echo -e "`date`: Dropped and Dumped successfully at path ${file_path}/${table_name}_${date}.sql.gz\nwith Max and Min date as $result\nMax and Min date in ${db_name}.${table_name} is ${result1}"
	else	
	
		echo "`date`: Dump was not completed at path ${file_path}/${table_name}_${date}.sql.gz"
	fi
else
	echo "`date`: File does not exists at path ${file_path}/${table_name}_${date}.sql.gz"
fi

else
	echo "`date`: Table ${table_name}_${date} already present in database ${db_name}"
	fi
else
echo "`date`: Table ${table_name} is not present in database ${db_name}"
fi

while :
do
mysql -uadmin -pabc -e "SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;start slave; "

# sleep 1
done

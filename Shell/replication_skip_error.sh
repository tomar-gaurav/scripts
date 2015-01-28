while :
do
mysql -uadmin -pasdwe#IBDds34asdf34 -e "SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;start slave; "

# sleep 1
done
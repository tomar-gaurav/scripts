
file="./master.info"
x=0
while read line
do
	if [ "$x" == "3" ];
	then
	MASTER_HOST=$line
	fi
	if [ "$x" == "4" ];
	then
	MASTER_USER=$line
	fi
	if [ "$x" == "5" ];
	then 
	MASTER_PASSWORD=$line
	fi
		x=`expr $x + 1`	
done <"$file"


file1="./relay-log.info"
y=0
while read line
do
	if [ "$y" == "2" ];
	then 
	MASTER_LOG_FILE=$line
	fi
	if [ "$y" == "3" ];
	then 
	MASTER_LOG_POS=$line
	fi
		y=`expr $y + 1`	
done <"$file1"

echo "CHANGE MASTER TO 
MASTER_HOST=$MASTER_HOST,
MASTER_USER=$MASTER_USER,
MASTER_PASSWORD=$MASTER_PASSWORD,
MASTER_LOG_FILE=$MASTER_LOG_FILE,
MASTER_LOG_POS=$MASTER_LOG_POS;"

/*
Navicat MySQL Data Transfer

Source Server         : 104
Source Server Version : 50132
Source Host           : localhost:3306
Source Database       : divesh_test

Target Server Type    : MYSQL
Target Server Version : 50132
File Encoding         : 65001

Date: 2015-02-17 13:54:14
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Procedure structure for `single_colomn_to_rows`
-- ----------------------------
DROP PROCEDURE IF EXISTS `single_colomn_to_rows`;
DELIMITER ;;
CREATE DEFINER=`admin`@`127.0.0.1` PROCEDURE `single_colomn_to_rows`()
BEGIN


DECLARE number bigint(12);
DECLARE alt bigint(12);
DECLARE ses datetime;
DECLARE script text;
DECLARE finished int(2);
declare len BIGINT(12);


DECLARE cur CURSOR for SELECT
	msisdn,
	alt_userid,
	session_starttime,
	REPLACE(REPLACE(GROUP_CONCAT(event_script),'\n','~'),'~~','~')
FROM
	db_ussd.eventlog_20150206
WHERE
	app_name = 'UPEast-121'
AND campaign_id = 12
AND ussd_mode = 1
GROUP BY trans_id;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

OPEN cur;

deltab: LOOP

FETCH cur into number,alt,ses,script;

IF finished=1 THEN
LEAVE deltab;
END IF;



sec: LOOP
set len=LENGTH(script);
IF len<1 THEN
LEAVE sec;
END IF;

set @col= SUBSTRING_INDEX(script,'~',1);
set @col= REPLACE(@col,'Press 0 for more,','');
set @quer1= concat("insert into test (msisdn,alt_userid,session_starttime,offers) values (",number,",",alt,",'",ses,"','",@col,"')");
select @quer1;
PREPARE stmt from @quer1;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

#set script=SUBSTR(script,1,LENGTH(SUBSTRING_INDEX(script,'~',-1))+1);
select LOCATE('~',script) into @loc;
if @loc > 0 THEN 
set script=SUBSTRING_INDEX(script,concat(@col,'~'),-1);
ELSE
set script=SUBSTRING_INDEX(script,@col,-1);
END IF;
select script;
END LOOP sec;

END LOOP deltab;

CLOSE cur;


update 5thto9th set offer1=SUBSTRING_INDEX(offers,'~',1),
offer2=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',1))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',1))+1)),'~',1),
offer3=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',2))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',2))+1)),'~',1),
offer4=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',3))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',3))+1)),'~',1),
offer5=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',4))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',4))+1)),'~',1),
offer6=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',5))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',5))+1)),'~',1),
offer7=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',6))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',6))+1)),'~',1),
offer8=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',7))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',7))+1)),'~',1),
offer9=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',8))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',8))+1)),'~',1),
offer10=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',9))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',9))+1)),'~',1),
offer11=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',10))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',10))+1)),'~',1),
offer12=SUBSTRING_INDEX(SUBSTR(offers FROM (LENGTH(SUBSTRING_INDEX(offers,'~',11))+2) FOR LENGTH(offers)-(LENGTH(SUBSTRING_INDEX(offers,'~',11))+1)),'~',1);

END
;;
DELIMITER ;

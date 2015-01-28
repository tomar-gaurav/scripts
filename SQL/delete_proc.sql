/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50534
Source Host           : localhost:3306
Source Database       : db_ussd

Target Server Type    : MYSQL
Target Server Version : 50534
File Encoding         : 65001

Date: 2014-11-05 18:00:50
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Procedure structure for del
-- ----------------------------
DROP PROCEDURE IF EXISTS `del`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `del`(IN `db_name` VARCHAR(255),IN `table_name` VARCHAR(255),IN `start_date` date,IN `end_date` date)
BEGIN

set @st=DATE_FORMAT(start_date, '%Y%m%d');

set @en=DATE_FORMAT(end_date, '%Y%m%d'); 

set @ty=table_name;

set @db=db_name;

del :LOOP

IF @en < @st THEN
	LEAVE del;
END
IF;


SET @tab = CONCAT('DROP TABLE IF EXISTS ',concat(@db,'.'),concat(@ty,'_'),@st,';');

PREPARE stmt
FROM
	@tab;

EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @st = DATE_FORMAT(
	DATE_ADD(
		DATE_FORMAT(@st, '%Y-%m-%d'),
		INTERVAL 1 DAY
	),
	'%Y%m%d'
);


END LOOP del;

END
;;
DELIMITER ;

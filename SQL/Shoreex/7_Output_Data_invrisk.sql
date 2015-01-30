/*
 Navicat Premium Data Transfer

 Source Server         : shoreex_be
 Source Server Type    : MySQL
 Source Server Version : 50154
 Source Host           : localhost
 Source Database       : db82494_confirmations

 Target Server Type    : MySQL
 Target Server Version : 50154
 File Encoding         : utf-8

 Date: 01/03/2015 20:57:35 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `7_Output_Data_invrisk`
-- ----------------------------
DROP PROCEDURE IF EXISTS `7_Output_Data_invrisk`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `7_Output_Data_invrisk`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

DECLARE done boolean DEFAULT 0;
DECLARE p_orderDetailID int(11);
DECLARE p_vendorCost decimal(10,4);


DECLARE cur_invrisk CURSOR FOR
SELECT orderDetailID,vendorCost from shoreex_staging.inv_risk GROUP BY orderDetailID;



DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
SET sql_mode := 'IGNORE_SPACE';


OPEN cur_invrisk;
REPEAT

FETCH cur_invrisk INTO
									p_orderDetailID,
									p_vendorCost;


IF (p_orderDetailID IS NOT NULL AND p_orderDetailID<>'') THEN

UPDATE order_information_details SET vendorCost=p_vendorCost WHERE orderDetailID=p_orderDetailID;

END IF;

 UNTIL done=1
END REPEAT;

CLOSE cur_invrisk;

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

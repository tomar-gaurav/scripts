/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50534
Source Host           : localhost:3306
Source Database       : db_utilities

Target Server Type    : MYSQL
Target Server Version : 50534
File Encoding         : 65001

Date: 2015-01-21 20:28:18
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `delete_log`
-- ----------------------------
DROP TABLE IF EXISTS `delete_log`;
CREATE TABLE `delete_log` (
`db_name`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
`deleted_table`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
`log_date`  datetime NOT NULL 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci

;


-- ----------------------------
-- Table structure for `table_list`
-- ----------------------------
DROP TABLE IF EXISTS `table_list`;
CREATE TABLE `table_list` (
`db_name`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
`table_name`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
UNIQUE INDEX `idx_db_table_name` (`db_name`, `table_name`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci

;


-- ----------------------------
-- Procedure structure for `del`
-- ----------------------------
DROP PROCEDURE IF EXISTS `del`;
DELIMITER ;;
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `del`()
BEGIN

DECLARE db VARCHAR(255);
DECLARE tab VARCHAR(255);
DECLARE finished int(2);

DECLARE del CURSOR for select db_name,table_name from table_list;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

OPEN del;

deltab: LOOP

FETCH del into db,tab;

IF finished=1 THEN
LEAVE deltab;
END IF;

set @quer=concat(' Drop table  ',db,'.',tab,';');

PREPARE stmt from @quer;

EXECUTE stmt;

INSERT INTO delete_log (db_name,deleted_table,log_date) values (db,tab,NOW());

DEALLOCATE PREPARE stmt;

END LOOP deltab;

CLOSE del;

Truncate table table_list;

END
;;
DELIMITER ;

/*
 Navicat Premium Data Transfer

 Source Server         : shoreex_be
 Source Server Type    : MySQL
 Source Server Version : 50154
 Source Host           : localhost
 Source Database       : shoreex_staging

 Target Server Type    : MySQL
 Target Server Version : 50154
 File Encoding         : utf-8

 Date: 01/03/2015 20:54:54 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Function structure for `IsNumeric`
-- ----------------------------
DROP FUNCTION IF EXISTS `IsNumeric`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` FUNCTION `IsNumeric`(sIn varchar(1024))
RETURNS tinyint(4)
LANGUAGE SQL
DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
RETURN sIn REGEXP '^(-|\\+){0,1}([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+|[0-9]+)$'
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

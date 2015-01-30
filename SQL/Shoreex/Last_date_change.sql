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

 Date: 01/03/2015 20:55:36 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Function structure for `Last_date_change`
-- ----------------------------
DROP FUNCTION IF EXISTS `Last_date_change`;
delimiter ;;
CREATE DEFINER = `nrathi`@`%` FUNCTION `Last_date_change`(`tourdate` datetime,`tourtime` varchar(255))
RETURNS datetime
LANGUAGE SQL
DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
SET `tourdate`=DATE(`tourdate`);
set @tourday=0;
set @tourdatetime=0;

IF tourtime like 'Monday%' THEN
SET @tourday=DAYNAME(tourdate);
CASE @tourday
WHEN 'Monday' THEN set @tourdatetime=CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 7 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Monday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Monday', 2-1)) + 1),'Monday', '')), '%h:%i %p'));
WHEN 'Tuesday' THEN set @tourdatetime=CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 1 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Monday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Monday', 2-1)) + 1),'Monday', '')), '%h:%i %p'));
WHEN 'Wednesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 2 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Monday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Monday', 2-1)) + 1),'Monday', '')), '%h:%i %p'));
WHEN 'Thursday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 3 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Monday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Monday', 2-1)) + 1),'Monday', '')), '%h:%i %p'));
WHEN 'Friday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 4 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Monday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Monday', 2-1)) + 1),'Monday', '')), '%h:%i %p'));
WHEN 'Saturday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 5 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Monday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Monday', 2-1)) + 1),'Monday', '')), '%h:%i %p'));
WHEN 'Sunday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 6 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Monday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Monday', 2-1)) + 1),'Monday', '')), '%h:%i %p'));
ELSE INSERT INTO shoreex_staging.date_change_log(created_at,tour_date,tour_time,tour_day,tour_datetime) VALUES(NOW(),tourdate,tourtime,@tourday,@tourdatetime);
END CASE;
END IF;



IF tourtime like 'Tuesday%' THEN
SET @tourday=DAYNAME(tourdate);
CASE @tourday
WHEN 'Tuesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 7 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Tuesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Tuesday', 2-1)) + 1),'Tuesday', '')), '%h:%i %p'));
WHEN 'Wednesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 1 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Tuesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Tuesday', 2-1)) + 1),'Tuesday', '')), '%h:%i %p'));
WHEN 'Thursday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 2 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Tuesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Tuesday', 2-1)) + 1),'Tuesday', '')), '%h:%i %p'));
WHEN 'Friday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 3 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Tuesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Tuesday', 2-1)) + 1),'Tuesday', '')), '%h:%i %p'));
WHEN 'Saturday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 4 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Tuesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Tuesday', 2-1)) + 1),'Tuesday', '')), '%h:%i %p'));
WHEN 'Sunday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 5 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Tuesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Tuesday', 2-1)) + 1),'Tuesday', '')), '%h:%i %p'));
WHEN 'Monday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 6 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Tuesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Tuesday', 2-1)) + 1),'Tuesday', '')), '%h:%i %p'));
ELSE INSERT INTO shoreex_staging.date_change_log(created_at,tour_date,tour_time,tour_day,tour_datetime) VALUES(NOW(),tourdate,tourtime,@tourday,@tourdatetime);
END CASE;
END IF;



IF tourtime like 'Wednesday%' THEN
SET @tourday=DAYNAME(tourdate);
CASE @tourday

WHEN 'Wednesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 7 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Wednesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Wednesday', 2-1)) + 1),'Wednesday', '')), '%h:%i %p'));
WHEN 'Thursday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 1 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Wednesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Wednesday', 2-1)) + 1),'Wednesday', '')), '%h:%i %p'));
WHEN 'Friday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 2 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Wednesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Wednesday', 2-1)) + 1),'Wednesday', '')), '%h:%i %p'));
WHEN 'Saturday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 3 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Wednesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Wednesday', 2-1)) + 1),'Wednesday', '')), '%h:%i %p'));
WHEN 'Sunday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 4 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Wednesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Wednesday', 2-1)) + 1),'Wednesday', '')), '%h:%i %p'));
WHEN 'Monday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 5 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Wednesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Wednesday', 2-1)) + 1),'Wednesday', '')), '%h:%i %p'));
WHEN 'Tuesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 6 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Wednesday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Wednesday', 2-1)) + 1),'Wednesday', '')), '%h:%i %p'));
ELSE INSERT INTO shoreex_staging.date_change_log(created_at,tour_date,tour_time,tour_day,tour_datetime) VALUES(NOW(),tourdate,tourtime,@tourday,@tourdatetime);
END CASE;
END IF;



IF tourtime like 'Thursday%' THEN
SET @tourday=DAYNAME(tourdate);
CASE @tourday
WHEN 'Thursday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 7 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Thursday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Thursday', 2-1)) + 1),'Thursday', '')), '%h:%i %p'));
WHEN 'Friday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 1 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Thursday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Thursday', 2-1)) + 1),'Thursday', '')), '%h:%i %p'));
WHEN 'Saturday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 2 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Thursday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Thursday', 2-1)) + 1),'Thursday', '')), '%h:%i %p'));
WHEN 'Sunday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 3 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Thursday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Thursday', 2-1)) + 1),'Thursday', '')), '%h:%i %p'));
WHEN 'Monday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 4 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Thursday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Thursday', 2-1)) + 1),'Thursday', '')), '%h:%i %p'));
WHEN 'Tuesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 5 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Thursday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Thursday', 2-1)) + 1),'Thursday', '')), '%h:%i %p'));
WHEN 'Wednesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 6 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Thursday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Thursday', 2-1)) + 1),'Thursday', '')), '%h:%i %p'));
ELSE INSERT INTO shoreex_staging.date_change_log(created_at,tour_date,tour_time,tour_day,tour_datetime) VALUES(NOW(),tourdate,tourtime,@tourday,@tourdatetime);
END CASE;
END IF;



IF tourtime like 'Friday%' THEN
SET @tourday=DAYNAME(tourdate);
CASE @tourday

WHEN 'Friday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 7 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Friday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Friday', 2-1)) + 1),'Friday', '')), '%h:%i %p'));
WHEN 'Saturday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 1 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Friday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Friday', 2-1)) + 1),'Friday', '')), '%h:%i %p'));
WHEN 'Sunday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 2 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Friday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Friday', 2-1)) + 1),'Friday', '')), '%h:%i %p'));
WHEN 'Monday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 3 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Friday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Friday', 2-1)) + 1),'Friday', '')), '%h:%i %p'));
WHEN 'Tuesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 4 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Friday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Friday', 2-1)) + 1),'Friday', '')), '%h:%i %p'));
WHEN 'Wednesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 5 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Friday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Friday', 2-1)) + 1),'Friday', '')), '%h:%i %p'));
WHEN 'Thursday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 6 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Friday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Friday', 2-1)) + 1),'Friday', '')), '%h:%i %p'));
else set @tourdatetime=0;
END CASE;
END IF;



IF tourtime like 'Saturday%' THEN
SET @tourday=DAYNAME(tourdate);
CASE @tourday
WHEN 'Saturday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 7 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Saturday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Saturday', 2-1)) + 1),'Saturday', '')), '%h:%i %p'));
WHEN 'Sunday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 1 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Saturday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Saturday', 2-1)) + 1),'Saturday', '')), '%h:%i %p'));
WHEN 'Monday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 2 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Saturday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Saturday', 2-1)) + 1),'Saturday', '')), '%h:%i %p'));
WHEN 'Tuesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 3 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Saturday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Saturday', 2-1)) + 1),'Saturday', '')), '%h:%i %p'));
WHEN 'Wednesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 4 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Saturday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Saturday', 2-1)) + 1),'Saturday', '')), '%h:%i %p'));
WHEN 'Thursday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 5 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Saturday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Saturday', 2-1)) + 1),'Saturday', '')), '%h:%i %p'));
WHEN 'Friday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 6 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Saturday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Saturday', 2-1)) + 1),'Saturday', '')), '%h:%i %p'));
ELSE INSERT INTO shoreex_staging.date_change_log(created_at,tour_date,tour_time,tour_day,tour_datetime) VALUES(NOW(),tourdate,tourtime,@tourday,@tourdatetime);
END CASE;
END IF;



IF tourtime like 'Sunday%' THEN
SET @tourday=DAYNAME(tourdate);
CASE @tourday
WHEN 'Sunday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 7 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Sunday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Sunday', 2-1)) + 1),'Sunday', '')), '%h:%i %p'));
WHEN 'Monday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 1 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Sunday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Sunday', 2-1)) + 1),'Sunday', '')), '%h:%i %p'));
WHEN 'Tuesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 2 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Sunday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Sunday', 2-1)) + 1),'Sunday', '')), '%h:%i %p'));
WHEN 'Wednesday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 3 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Sunday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Sunday', 2-1)) + 1),'Sunday', '')), '%h:%i %p'));
WHEN 'Thursday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 4 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Sunday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Sunday', 2-1)) + 1),'Sunday', '')), '%h:%i %p'));
WHEN 'Friday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 5 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Sunday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Sunday', 2-1)) + 1),'Sunday', '')), '%h:%i %p'));
WHEN 'Saturday' THEN set @tourdatetime= CONCAT(DATE(DATE_SUB(tourdate, INTERVAL 6 DAY)),' ',STR_TO_DATE(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(tourtime, 'Sunday', 2),LENGTH(SUBSTRING_INDEX(tourtime, 'Sunday', 2-1)) + 1),'Sunday', '')), '%h:%i %p'));
ELSE INSERT INTO shoreex_staging.date_change_log(created_at,tour_date,tour_time,tour_day,tour_datetime) VALUES(NOW(),tourdate,tourtime,@tourday,@tourdatetime);
END CASE;
END IF;



RETURN @tourdatetime;


END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

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

 Date: 01/03/2015 20:50:42 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `3_Load_itineary_data`
-- ----------------------------
DROP PROCEDURE IF EXISTS `3_Load_itineary_data`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `3_Load_itineary_data`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

/*
@todo: DO A TRAINING SESSION - white box, code review
@todo:
 10. Do NOT answer the questions,
 20. Instead write it in code as comments
 30. Ask if this comment answers their question
@todo: the below pseudo code is just copy paste and redundant
*/ /* This is the 3rd file in the procedure
This function loads the cruise information.It basically sets the tourdate, tourtime, itinaryworks portarrival, portdeparture and port name
*/ /*
10. Update cruiseLine and cruiseShip for all
20. Set package id as null where package product code is null and do the following
  21.  Set getItineraryTime to minutes whereever applicable according to tourTime
  22.  Set getItineraryTime for rest according to value of time_value from time_equivalency table
  23.  Set value of tourDateTime according to value of getItineraryTime
30.  Set values of below columns where package product code is not null
  31.  Set the package id from packages table where cruiseDuration is numeric and not numeric
  32.  Set the value of tourDateTime according to the value of packageId computed above by comparing the productCode and packageId
  33.  Set the tourDate and tourTime using tourDateTime computed above
40.  Set the value of itineraryWorks
  41. Set the value of return column to 1 wherever the value of itineraryWorks is being set
  42. Set the value of return column to 1 where cruise data is missing
50. Set value of tourDate and tourTime where getItineraryTime is false and itineraryWorks is not set i.e. return is 0
60. Set the value of cruiseLine and cruiseShip from cruisecal tables where return is 0
70. Again set the value of getItineraryTime according to tourTime computed at 50 where return is 0
80. Create table temp_port containg information from cruisecal_data table
  81. Set value of pc prefix
  82. Set values of Port,portArrival,portDeparture,localize_port_arrival,localize_port_departure joining with temp_port where return is 0
90. Set the value of tourTimeSec according to value of getItineraryTime where return is 0
  91. Set the value of isInvalidPortArrival and isInvalidPortdeparture according to value of tourTimeSec
  92. Set the value of ItineraryWorks according to value of isInvalidPortArrival and isInvalidPortdeparture
*/ /* This function loads the cruise information.It basically sets the tourdate, tourtime, itinaryworks portarrival, portdeparture and port name*/ /*Update cruiseLine and cruiseShip to cruiseLineId and cruiseShipId*/
UPDATE order_information_details_test
SET cruiseLine=cruiseLineID,
    cruiseShip=cruiseShipID;
COMMIT;

/*Update packageId as null where package_product_code is null*/
UPDATE order_information_details_test
SET packageID=NULL
WHERE package_product_code IS NULL;

/*Update the getItinaryTime from string to number of minutes for a tour that is not package and has tourDate and tourTime */
UPDATE order_information_details_test t1
INNER JOIN order_information_details_test t2 ON t1.orderDetailID = t2.orderDetailID
SET t1.getItinaryTime = IF(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1-1)) + 1),'Minutes After Ship', ''))=t1.tourtime,IF(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1-1)) + 1),'Minutes After Ship Arrival', ''))=t1.tourTime,null,TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1-1)) + 1),'Minutes After Ship Arrival', ''))),TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1-1)) + 1),'Minutes After Ship', '')))
WHERE t1.tourTime LIKE '%Minutes After Ship%'
  AND t1.package_product_code IS NULL
  AND t1.tourDate IS NOT NULL
  AND t1.tourTime IS NOT NULL;


/*Update the getItinaryTime from number of hours to minutes for tours that are not package and have tourDate and tourTime */
UPDATE order_information_details_test t1
INNER JOIN order_information_details_test t2 ON t1.orderDetailID = t2.orderDetailID
SET t1.getItinaryTime = CASE
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'ONE' THEN 60
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'TWO' THEN 120
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'THREE' THEN 180
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'FOUR' THEN 240
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'FIVE' THEN 300
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'SIX' THEN 360
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'SEVEN' THEN 420
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'EIGHT' THEN 480
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'NINE' THEN 540
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'TEN' THEN 600
                            WHEN IsNumeric(REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', ''))='1' THEN TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '')*60)
                        END
WHERE t1.tourTime LIKE '%Hour After Ship%'
  AND t1.package_product_code IS NULL
  AND t1.tourDate IS NOT NULL
  AND t1.tourTime IS NOT NULL;

/*Update getItinaryTime for other rows by taking the value from time_value or setting them true/false for tours that are not package and have tourDate and tourTime*/
UPDATE order_information_details_test
LEFT JOIN db82494_confirmations.time_equivalency ON (order_information_details_test.tourtime=time_equivalency.name)
SET getItinaryTime= CASE
                        WHEN time_equivalency.time_value='00:00:00' THEN 'True'
                        WHEN time_equivalency.time_value IS NULL
                             AND time_equivalency.`name` IS NULL THEN 'False'
                        ELSE time_equivalency.time_value
                    END
WHERE order_information_details_test.getItinaryTime IS NULL
  AND order_information_details_test.package_product_code IS NULL
  AND order_information_details_test.tourDate IS NOT NULL
  AND order_information_details_test.tourTime IS NOT NULL;

 /*Update tourDateTime on the basis of getItinarytime column value like
if false then combine the tourDate and tourTime
if true then set as tourDate
if numeric then set as tourTime*/
UPDATE order_information_details_test
SET tourDateTime= UNIX_TIMESTAMP(tourDate)               
WHERE order_information_details_test.package_product_code IS NULL
  AND order_information_details_test.tourDate IS NOT NULL
  AND order_information_details_test.tourTime IS NOT NULL and order_information_details_test.getItinaryTime='True';

UPDATE order_information_details_test
SET tourDateTime= UNIX_TIMESTAMP(tourDate)               
WHERE order_information_details_test.package_product_code IS NULL
  AND order_information_details_test.tourDate IS NOT NULL
  AND order_information_details_test.tourTime IS NOT NULL and IsNumeric(order_information_details_test.getItinaryTime)='1';


UPDATE order_information_details_test
SET tourDateTime= IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',IF(UNIX_TIMESTAMP(date_change(tourDate,tourTime))<>'0',UNIX_TIMESTAMP(date_change(tourDate,tourTime)),IF(UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p')))<>'0',UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p'))),IF(UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))=UNIX_TIMESTAMP(date(tourdate)),0,UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))))),0)               
WHERE order_information_details_test.package_product_code IS NULL
  AND order_information_details_test.tourDate IS NOT NULL
  AND order_information_details_test.tourTime IS NOT NULL and order_information_details_test.getItinaryTime='False';

UPDATE order_information_details_test
SET tourDateTime=UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',getItinaryTime))
where IsNumeric(getItinaryTime)=0
and getItinaryTime<>'True'
and getItinaryTime<>'False';

/*Update values when package product code is not null*/ /*Update the package id from package table by comparing the package_product_code and where cruiseDuration is numeric and greater than 0*/
UPDATE order_information_details_test
SET order_information_details_test.packageID=
  (SELECT packages.packageId
   FROM db82494_confirmations.packages
   WHERE packages.productCode=order_information_details_test.package_product_code
     AND packages.cruisecal_shipId=order_information_details_test.cruiseShipID
     AND packages.arrival_date >=DATE(cruiseStartDate)
     AND packages.departure_date <= ADDDATE(DATE(cruiseStartDate),INTERVAL cruiseDuration DAY)
     AND IsNumeric(cruiseDuration)='1'
     AND cruiseDuration>0
     AND package_product_code IS NOT NULL
   GROUP BY orderDetailID
   ORDER BY packages.arrival_date ASC)
WHERE IsNumeric(cruiseDuration)='1'
  AND cruiseDuration>0
  AND package_product_code IS NOT NULL;

/*Update the package id where cruiseDuration is not numeric*/
UPDATE order_information_details_test
SET order_information_details_test.packageID=
  (SELECT packages.packageId
   FROM db82494_confirmations.packages
   WHERE packages.productCode=order_information_details_test.package_product_code
     AND packages.cruisecal_shipId=order_information_details_test.cruiseShipID
     AND packages.arrival_date >=DATE(cruiseStartDate)
     AND IsNumeric(cruiseDuration)='0'
     AND package_product_code IS NOT NULL
   GROUP BY orderDetailID
   ORDER BY packages.arrival_date ASC)
WHERE IsNumeric(cruiseDuration)='0'
  AND package_product_code IS NOT NULL;

/*Update the tourDateTime according to tour_begin date provided by the package ids computed above by comparing the productCode and packageId*/
UPDATE order_information_details_test
SET tourDateTime= UNIX_TIMESTAMP(
                                   (SELECT package_ports.tour_begin
                                    FROM db82494_confirmations.ports, db82494_confirmations.package_ports, db82494_confirmations.products
                                    WHERE ports.product_code_prefix = LEFT(package_ports.port_productCode, 4)
                                      AND package_ports.port_productCode = order_information_details_test.productCode
                                      AND products.productCode = package_ports.port_productCode
                                      AND package_ports.packageId =order_information_details_test.packageID
                                      AND order_information_details_test.packageID IS NOT NULL))
WHERE order_information_details_test.packageID IS NOT NULL
  AND package_product_code IS NOT NULL;

/*UpdateSets the tourDate and tourTime using tourDateTime computed above when package_product_code is not null*/
UPDATE order_information_details_test
SET tourDate=DATE(FROM_UNIXTIME(tourDateTime)),
             tourTime=TIME_FORMAT(FROM_UNIXTIME(tourDateTime),'%l:%i %p')
WHERE order_information_details_test.packageID IS NOT NULL
  AND package_product_code IS NOT NULL
  AND tourDateTime IS NOT NULL
  AND tourDateTime<>'';

/*Update value of variables according to value of cruiseline id*/
UPDATE order_information_details_test
SET cruiseShip='None',
    cruiseLine='Hotel',
    itineraryWorks='Yes',
    `return`='1'
WHERE cruiseLineID='-1';

 COMMIT;

 /*Update the value of variables according to value of cruiseline id*/
UPDATE order_information_details_test
SET cruiseShip='None',
    cruiseLine='Other',
    itineraryWorks='Other, itinerary unknown.',
    `return`='1'
WHERE cruiseLineID='-2'
  AND cruiseLineID<>'-1';

 COMMIT;

/*Update value of itineraryWorks to 'Pre-Cruise' where cruiseStartDate is after tourDate*/
/*UPDATE order_information_details_test
SET itineraryWorks='Pre-Cruise',
    `return`='1'
WHERE IFNULL(UNIX_TIMESTAMP(cruiseStartDate),UNIX_TIMESTAMP('1970-01-02 00:00:00')) > IFNULL(UNIX_TIMESTAMP(tourDate),0)
  AND itineraryWorks IS NULL;

 COMMIT;*/

/*Update value of itineraryWorks to 'Post-Cruise' where tourdate is after the tour ends(cruiseStartDate+Duration)*/
/*UPDATE order_information_details_test
SET itineraryWorks='Post-Cruise',
    `return`='1'
WHERE (IFNULL(UNIX_TIMESTAMP(ADDDATE(DATE(cruiseStartDate),INTERVAL cruiseDuration DAY)),'') IS NOT NULL
       OR IFNULL(UNIX_TIMESTAMP(ADDDATE(DATE(cruiseStartDate),INTERVAL cruiseDuration DAY)),'') <>'')
  AND UNIX_TIMESTAMP(tourDate)>=IFNULL(UNIX_TIMESTAMP(ADDDATE(DATE(cruiseStartDate),INTERVAL cruiseDuration DAY)),'')
  AND (cruiseDuration IS NOT NULL
       OR cruiseDuration<>'')
  AND itineraryWorks IS NULL;

 COMMIT;*/

/*Update value of return to 1 where where cruise data is missing*/
UPDATE order_information_details_test
SET `return`='1'
WHERE (cruiseLineID IS NULL
       OR cruiseShipID IS NULL
       OR cruiseDuration IS NULL
       OR cruiseStartDate IS NULL);

 COMMIT;


UPDATE order_information_details_test
SET `return`='1'
WHERE (IsNumeric(cruiseLineID)<>'1'
       OR IsNumeric(cruiseShipID)<>'1'
       OR IsNumeric(cruiseDuration)<>'1');

 COMMIT;


UPDATE order_information_details_test
SET `return`='1'
WHERE UNIX_TIMESTAMP(cruiseStartDate)='0';

 COMMIT;

/*Update tourDateTime for false getItinaryTime where itineraryWorks is not set*/
UPDATE order_information_details_test
SET tourDateTime= IF(SUBSTR(tourTime,-2)='AM'
                     OR SUBSTR(tourTime,-2)='PM',UNIX_TIMESTAMP(last_date_change(tourDate,tourTime)),0)
WHERE getItinaryTime='False'
  AND IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',UNIX_TIMESTAMP(last_date_change(tourDate,tourTime)),0)<>0
  AND DATE_FORMAT(FROM_UNIXTIME(tourDateTime),'%c/%d/%Y') > DATE_FORMAT(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(DATE(FROM_UNIXTIME((UNIX_TIMESTAMP(cruiseStartDate)+cruiseDuration*86400))),' 11:59:59 PM'))),'%c/%d/%Y')
  AND DATE_FORMAT(FROM_UNIXTIME(IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',UNIX_TIMESTAMP(last_date_change(tourDate,tourTime)),0)),'%c/%d/%Y') > DATE_FORMAT(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(cruiseStartDate))),' 12:00:00 PM'))),'%c/%d/%Y')
  AND DATE_FORMAT(FROM_UNIXTIME(IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',UNIX_TIMESTAMP(last_date_change(tourDate,tourTime)),0)),'%c/%d/%Y') < DATE_FORMAT(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(DATE(FROM_UNIXTIME((UNIX_TIMESTAMP(cruiseStartDate)+cruiseDuration*86400))),' 11:59:59 PM'))),'%c/%d/%Y')
  AND `return`='0';

/*Update tourDate and tourTime from tourDateTime computed above for false getItinaryTime where itineraryWorks is not set*/
UPDATE order_information_details_test
SET tourDate=DATE(FROM_UNIXTIME(tourDateTime)),
             tourTime=TIME_FORMAT(FROM_UNIXTIME(tourDateTime),'%l:%i %p')
WHERE getItinaryTime='False'
  AND `return`='0';

/*Update the cruiseLine from cruisecal tables where itineraryWorks is not set*/
UPDATE order_information_details_test
SET cruiseLine=
  (SELECT ifnull(`lines`.name, cruisecal_lines.lineName)
   FROM db82494_confirmations.cruisecal_ships,
        db82494_confirmations.cruisecal_lines
   LEFT OUTER JOIN db82494_confirmations.`lines` ON (`lines`.cruisecal_lineId = cruisecal_lines.lineId)
   WHERE cruisecal_ships.lineId = cruisecal_lines.lineId
     AND cruisecal_lines.lineId = order_information_details_test.cruiseLineID
     AND cruisecal_ships.shipId = order_information_details_test.cruiseShipID)
WHERE `return`='0';
COMMIT;

/*Update the cruiseShip from cruisecal tables where itineraryWorks is not set*/
UPDATE order_information_details_test
SET cruiseShip=
  (SELECT cruisecal_ships.shipName
   FROM db82494_confirmations.cruisecal_ships,
        db82494_confirmations.cruisecal_lines
   LEFT OUTER JOIN db82494_confirmations.`lines` ON (`lines`.cruisecal_lineId = cruisecal_lines.lineId)
   WHERE cruisecal_ships.lineId = cruisecal_lines.lineId
     AND cruisecal_lines.lineId = order_information_details_test.cruiseLineID
     AND cruisecal_ships.shipId = order_information_details_test.cruiseShipID)
WHERE `return`='0';
COMMIT;

UPDATE order_information_details_test SET cruiseShip=cruiseShipID,cruiseLine=cruiseLineID WHERE cruiseShip is null and cruiseLine is null;

/*once again pdate the getItinaryTime from string to minutes from tourTime where itineraryWorks is not set*/
UPDATE order_information_details_test t1
INNER JOIN order_information_details_test t2 ON t1.orderDetailID = t2.orderDetailID
SET t1.getItinaryTime = IF(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1-1)) + 1),'Minutes After Ship', ''))=t1.tourtime,IF(TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1-1)) + 1),'Minutes After Ship Arrival', ''))=t1.tourTime,null,TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship Arrival', 1-1)) + 1),'Minutes After Ship Arrival', ''))),TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1),LENGTH(SUBSTRING_INDEX(t1.tourtime, 'Minutes After Ship', 1-1)) + 1),'Minutes After Ship', '')))

WHERE t1.tourTime LIKE '%Minutes After Ship%'
  AND t1.tourDate IS NOT NULL
  AND t1.tourTime IS NOT NULL
  AND t1.`return`='0';

/*Update getItinaryTime from hours to minutes from tourTime where itineraryWorks is not set*/
UPDATE order_information_details_test t1
INNER JOIN order_information_details_test t2 ON t1.orderDetailID = t2.orderDetailID
SET t1.getItinaryTime = CASE
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'ONE' THEN 60
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'TWO' THEN 120
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'THREE' THEN 180
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'FOUR' THEN 240
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'FIVE' THEN 300
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'SIX' THEN 360
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'SEVEN' THEN 420
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'EIGHT' THEN 480
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'NINE' THEN 540
                            WHEN REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '') = 'TEN' THEN 600
                            WHEN IsNumeric(REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', ''))='1' THEN TRIM(REPLACE(SUBSTRING(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1),LENGTH(SUBSTRING_INDEX(t2.tourTime, 'Hour After Ship', 1-1)) + 1),'Hour After Ship', '')*60)
                        END
WHERE t1.tourTime LIKE '%Hour After Ship%'
  AND t1.tourDate IS NOT NULL
  AND t1.tourTime IS NOT NULL
  AND t1.`return`='0';

/*Update getItinaryTime for other rows by taking the value from time_value or setting them true/false for tours that are not package and have tourDate and tourTime where itineraryWorks is not set*/
UPDATE order_information_details_test
LEFT JOIN db82494_confirmations.time_equivalency ON (order_information_details_test.tourtime=time_equivalency.name)
SET getItinaryTime= CASE
                        WHEN time_equivalency.time_value='00:00:00' THEN 'True'
                        WHEN time_equivalency.time_value IS NULL
                             AND time_equivalency.`name` IS NULL THEN 'False'
                        ELSE time_equivalency.time_value
                    END
WHERE order_information_details_test.getItinaryTime IS NULL
  AND order_information_details_test.tourDate IS NOT NULL
  AND order_information_details_test.tourTime IS NOT NULL
  AND `return`='0';

/*Create temporary table containg information from cruisecal_data table*/
DROP TABLE IF EXISTS temp_port;


CREATE TABLE `temp_port` (`id` int(30) NOT NULL AUTO_INCREMENT, `orderID` int(11) NOT NULL, `orderDetailID` int(11) NOT NULL, `portDate` date DEFAULT NULL, `arriveTime` time DEFAULT NULL, `departTime` time DEFAULT NULL, `localize_port_arrival` datetime DEFAULT NULL, `localize_port_departure` datetime DEFAULT NULL, `portname` varchar(255) DEFAULT NULL, `product_code_prefix` varchar(4), PRIMARY KEY (`id`), KEY `idx_orderid` (`orderID`) USING BTREE) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Insert data into this table*/
INSERT INTO `temp_port`
SELECT '',
       order_information_details_test.orderID,
       order_information_details_test.orderDetailID,
       cruisecal_data.portDate,
       cruisecal_data.arriveTime,
       cruisecal_data.departTime,
       cruisecal_data.localize_port_arrival,
       cruisecal_data.localize_port_departure,
       ifnull(ports.name, cruisecal_data.port),
       ports.product_code_prefix
FROM order_information_details_test,
     db82494_confirmations.cruisecal_data
LEFT OUTER JOIN db82494_confirmations.ports ON ports.cruisecal_port = cruisecal_data.port
WHERE cruisecal_data.masterLineId = order_information_details_test.cruiseLineID
  AND cruisecal_data.masterShipId = order_information_details_test.cruiseShipID
  AND DATEDIFF(cruisecal_data.portDate,IFNULL(DATE(FROM_UNIXTIME(order_information_details_test.tourDateTime)),DATE(tourDate)))='0';

 /*Update pcprefix with first 4 characters of the productCode*/
UPDATE order_information_details_test
SET pcprefix=TRIM(SUBSTR(order_information_details_test.productCode
                         FROM 1
                         FOR 4));

 COMMIT;

/*Update Port,portArrival,portDeparture,localize_port_arrival,localize_port_departure where first 4 characters of the product code are same*/
UPDATE order_information_details_test
INNER JOIN temp_port ON (order_information_details_test.orderID=temp_port.orderID
                         AND order_information_details_test.orderDetailID=temp_port.orderDetailID)
SET order_information_details_test.`port`=temp_port.portname,
    order_information_details_test.portArrival=IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(temp_port.portDate,' ',temp_port.arriveTime))),CONCAT(temp_port.portDate,' ','00:00:00')),
                                               order_information_details_test.portDeparture=IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(temp_port.portDate,' ',temp_port.departTime))),CONCAT(temp_port.portDate,' ','23:59:59')),
                                                                                            order_information_details_test.localize_port_arrival=IF(temp_port.localize_port_arrival IS NULL
                                                                                                                                                    OR temp_port.localize_port_arrival='',
                                                                                                                                                       IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(temp_port.portDate,' ',temp_port.arriveTime))),CONCAT(temp_port.portDate,' ','00:00:00')),
                                                                                                                                                       temp_port.localize_port_arrival), order_information_details_test.localize_port_departure= IF(temp_port.localize_port_departure IS NULL
OR temp_port.localize_port_departure='',
   IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(temp_port.portDate,' ',temp_port.departTime))),CONCAT(temp_port.portDate,' ','23:59:59')),
   temp_port.localize_port_departure)
WHERE temp_port.product_code_prefix=order_information_details_test.pcprefix
AND order_information_details_test.`return`='0';

 COMMIT;

/*Update Port,portArrival,portDeparture,localize_port_arrival,localize_port_departure and itineraryWorks where first 4 characters of the product code are different by selecting the value from the maximum order detail id of the order id */
UPDATE order_information_details_test
INNER JOIN temp_port t1 ON (order_information_details_test.orderdetailid=t1.orderdetailid
                            AND t1.orderID=order_information_details_test.orderID)
INNER JOIN
(SELECT MAX(id) id
 FROM temp_port,
      order_information_details_test
 WHERE order_information_details_test.orderDetailID=temp_port.orderDetailID
   AND order_information_details_test.orderID=temp_port.orderID
   AND (order_information_details_test.pcprefix<>temp_port.product_code_prefix
        OR (order_information_details_test.pcprefix IS NOT NULL
            AND temp_port.product_code_prefix IS NULL))
 GROUP BY temp_port.orderDetailID) t2 ON (t2.id=t1.id)
SET order_information_details_test.`port`=t1.portname,
    order_information_details_test.portArrival=IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(t1.portDate,' ',t1.arriveTime))),CONCAT(t1.portDate,' ','00:00:00')),
                                               order_information_details_test.portDeparture=IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(t1.portDate,' ',t1.departTime))),CONCAT(t1.portDate,' ','23:59:59')),
                                                                                            order_information_details_test.localize_port_arrival=IF(t1.localize_port_arrival IS NULL
                                                                                                                                                    OR t1.localize_port_arrival='',
                                                                                                                                                       IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(t1.portDate,' ',t1.arriveTime))),CONCAT(t1.portDate,' ','00:00:00')),
                                                                                                                                                       t1.localize_port_arrival), order_information_details_test.localize_port_departure= IF(t1.localize_port_departure IS NULL
OR t1.localize_port_departure='',
   IFNULL(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(t1.portDate,' ',t1.departTime))),CONCAT(t1.portDate,' ','23:59:59')),
   t1.localize_port_departure), order_information_details_test.itineraryWorks='The ship is not in this port. ',
                                order_information_details_test.`return`='1'
WHERE order_information_details_test.`port` IS NULL
AND order_information_details_test.portArrival IS NULL
AND order_information_details_test.portDeparture IS NULL
AND order_information_details_test.localize_port_arrival IS NULL
AND order_information_details_test.localize_port_departure IS NULL
AND order_information_details_test.`return`='0';

 COMMIT;

/*Update the value of tourTimeSec according to value of getItineraryTime */
/*UPDATE order_information_details_test
SET tourTimeSec= CASE
                     WHEN getItinaryTime='True' THEN 'True'
                     WHEN getItinaryTime='False' THEN IF(UNIX_TIMESTAMP(date_change(tourDate,tourTime))<>'0',
                                                                                                         UNIX_TIMESTAMP(date_change(tourDate,tourTime)),
                                                                                                         IF(UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p')))<>'0',
                                                                                                                                                                                         UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p'))),
                                                                                                                                                                                         UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))))
                     WHEN IsNumeric(getItinaryTime)='1' THEN (UNIX_TIMESTAMP(localize_port_arrival)+getItinaryTime*60)
                     ELSE (UNIX_TIMESTAMP(CONCAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(tourDate))),' ',getItinaryTime)))
                 END
WHERE `return`='0';

 COMMIT;*/

UPDATE order_information_details_test SET tourTimeSec='True' WHERE getItinaryTime='True' AND `return`='0';
COMMIT;


UPDATE order_information_details_test SET tourTimeSec= IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',IF(UNIX_TIMESTAMP(date_change(tourDate,tourTime))<>'0',UNIX_TIMESTAMP(date_change(tourDate,tourTime)),IF(UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p')))<>'0',UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p'))),IF(UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))=UNIX_TIMESTAMP(date(tourdate)),0,UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))))),0) WHERE getItinaryTime='False' AND `return`='0';
COMMIT;


UPDATE order_information_details_test SET tourTimeSec=(UNIX_TIMESTAMP(localize_port_arrival)+getItinaryTime*60) WHERE IsNumeric(getItinaryTime)='1' AND `return`='0';
COMMIT;


UPDATE order_information_details_test SET tourTimeSec=(UNIX_TIMESTAMP(CONCAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(tourDate))),' ',getItinaryTime)))
WHERE IsNumeric(getItinaryTime)<>1 AND getItinaryTime<>'True' AND getItinaryTime<>'False' AND `return`='0';
COMMIT;

/*Update value of itineraryWorks where port data is not available*/
UPDATE order_information_details_test t1
LEFT JOIN temp_port t2 ON (t1.orderID=t2.orderID
                           AND t1.orderDetailID=t2.orderDetailID)
SET itineraryWorks='No port data available.',
    `return`='1'
WHERE t2.arriveTime IS NULL
AND t2.departTime IS NULL
AND t2.localize_port_arrival IS NULL
AND t2.localize_port_departure IS NULL
AND t2.portDate IS NULL
AND t2.portname IS NULL
AND t2.product_code_prefix IS NULL
AND t1.`return`='0';

 COMMIT;

/*Update the value of itineraryWorks when tourTimeSec is false and itineraryWorks is not set*/
UPDATE order_information_details_test
SET `return`='1',
    isInvalidPortArrival='1',
    isInvalidPortDeparture='1',
    itineraryWorks='The tour time was unparseble for comparison.'
WHERE (FROM_UNIXTIME(tourTimeSec)='1970-01-01 05:30:00'
       AND tourTimeSec<>'True')
AND `return`='0';

 COMMIT;

/*Update the value of isInvalidPortArrival and isInvalidPortDeparture where tourTimeSec is true and itineraryWorks is not set*/
UPDATE order_information_details_test
SET isInvalidPortArrival='0',
    isInvalidPortDeparture='0'
WHERE tourTimeSec='True'
AND `return`='0';

 COMMIT;

/*For all other values of tourTimeSec set the value of isInvalidPortArrival and isInvalidPortDeparture as below where itineraryWorks is not set */ 

START TRANSACTION;


UPDATE order_information_details_test
SET isInvalidPortArrival=IF(UNIX_TIMESTAMP(localize_port_arrival)>(tourTimeSec-(bufferTime*3600)),'1',
                                                                                                  '0'),isInvalidPortDeparture=IF((tourTimeSec+(IFNULL(tourDuration,0)*3600)+(bufferTime*3600))>UNIX_TIMESTAMP(localize_port_departure),
                                                                                                                                                                                     '1',
                                                                                                                                                                                     '0')
WHERE (FROM_UNIXTIME(tourTimeSec)<>'1970-01-01 05:30:00'
       AND tourTimeSec<>'True')
AND `return`='0';

 COMMIT;

/*Update the value of ItineraryWorks according to value of isInvalidPortArrival and isInvalidPortdeparture*/
UPDATE order_information_details_test
SET itineraryWorks='The tour date / time is not within the trip duration. ',
    `return`='1'
WHERE isInvalidPortArrival='1'
AND isInvalidPortDeparture='1'
AND `return`='0';

 COMMIT;


UPDATE order_information_details_test
SET itineraryWorks='The tour begins whilst the ship is not in port. ',
    `return`='1'
WHERE isInvalidPortArrival='1'
AND `return`='0';

 COMMIT;


UPDATE order_information_details_test
SET itineraryWorks='The tour ends whilst the ship is not in port. ',
    `return`='1'
WHERE isInvalidPortDeparture='1'
AND `return`='0';

COMMIT;


UPDATE order_information_details_test
SET itineraryWorks='Yes'
WHERE `return`='0';

 COMMIT;

/*LoadItinarydata function Ends*/

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

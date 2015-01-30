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

 Date: 01/03/2015 20:57:53 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `8_Output_Data_OI`
-- ----------------------------
DROP PROCEDURE IF EXISTS `8_Output_Data_OI`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `8_Output_Data_OI`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

DECLARE   done boolean DEFAULT 0;
DECLARE  `p_orderInformationID` int(11);
DECLARE  `p_lastUpdated` timestamp;
DECLARE  `p_orderID` int(11);
DECLARE  `p_orderDate` datetime;
DECLARE  `p_orderNotes` text;
DECLARE  `p_orderStatus` varchar(255) DEFAULT NULL;
DECLARE  `p_paymentRecieved` tinyint(1) DEFAULT '0';
DECLARE  `p_customerID` int(11);
DECLARE  `p_customerPhoneNumber` varchar(30) DEFAULT NULL;
DECLARE  `p_customerEmailAddress` varchar(75) DEFAULT NULL;
DECLARE  `p_firstName` varchar(30) DEFAULT NULL ;
DECLARE  `p_lastName` varchar(40) DEFAULT NULL;
DECLARE  `p_notesToVendor` varchar(255) DEFAULT NULL;
DECLARE  `p_affiliateID` int(11) DEFAULT NULL;
DECLARE  `p_affiliateGroupID` int(11) DEFAULT NULL;
DECLARE  `p_affiliateEmailAddress` varchar(75) DEFAULT NULL;
DECLARE  `p_affiliateName` varchar(255) DEFAULT NULL;
DECLARE  `p_affiliateBranding` tinyint(1) DEFAULT '0';
DECLARE  `p_affiliateBrandingID` int(11) DEFAULT NULL;
DECLARE  `p_affiliateBCC` tinyint(1) DEFAULT '0';
DECLARE  `p_affiliateData` varchar(255) DEFAULT NULL;
DECLARE  `p_cruiseLineID` varchar(50) DEFAULT NULL;
DECLARE  `p_cruiseShipID` varchar(50) DEFAULT NULL;
DECLARE  `p_cruiseLine` varchar(255) DEFAULT NULL;
DECLARE  `p_cruiseShip` varchar(255) DEFAULT NULL;
DECLARE  `p_cruiseStartDate` datetime DEFAULT NULL;
DECLARE  `p_cruiseDuration` varchar(50) DEFAULT NULL;
DECLARE  `p_customerEmailConfirmed` varchar(50) DEFAULT NULL;
DECLARE  `p_customerNotes` text;
DECLARE  `p_holdEmailsForOrder` tinyint(1) DEFAULT '0';
DECLARE  `p_reviewEmailAuthorized` tinyint(1) DEFAULT '0';
DECLARE  `p_date` datetime DEFAULT NOW();




DECLARE cur_OID CURSOR FOR
SELECT    orderID,
          orderDate,
          orderNotes,
          orderStatus,
          paymentRecieved,
          customerID,
          customerPhoneNumber,
          customerEmailAddress,
          firstName,
          lastName,
          notesToVendor,
          affiliateID,
          affiliateGroupID,
          affiliateEmailAddress,
          affiliateName,
          affiliateBranding,
          affiliateBrandingID,
          affiliateBCC,
          affiliateData,
          cruiseLineID,
          cruiseShipID,
          cruiseLine,
          cruiseShip,
          cruiseStartDate,
          cruiseDuration,
          customerEmailConfirmed,
          customerNotes,
          holdEmailsForOrder,
          reviewEmailAuthorized
   FROM shoreex_staging.order_information_details_test
   INNER JOIN
     (SELECT MIN(order_information_details_test.orderDetailID) MIN
      FROM shoreex_staging.order_information_details_test
      WHERE orderDetailID NOT LIKE '-%'
      GROUP BY orderid) t2 ON (order_information_details_test.orderDetailID=t2.MIN) ORDER BY orderID asc,orderDetailID asc;


DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
SET sql_mode := 'IGNORE_SPACE';



OPEN cur_OID;
REPEAT

FETCH cur_OID INTO
          p_orderID,
          p_orderDate,
          p_orderNotes,
          p_orderStatus,
          p_paymentRecieved,
          p_customerID,
          p_customerPhoneNumber,
          p_customerEmailAddress,
          p_firstName,
          p_lastName,
          p_notesToVendor,
          p_affiliateID,
          p_affiliateGroupID,
          p_affiliateEmailAddress,
          p_affiliateName,
          p_affiliateBranding,
          p_affiliateBrandingID,
          p_affiliateBCC,
          p_affiliateData,
          p_cruiseLineID,
          p_cruiseShipID,
          p_cruiseLine,
          p_cruiseShip,
          p_cruiseStartDate,
          p_cruiseDuration,
          p_customerEmailConfirmed,
          p_customerNotes,
          p_holdEmailsForOrder,
          p_reviewEmailAuthorized;


SET p_orderInformationID=NULL;
SET p_lastUpdated=NULL;
SET p_date=NOW();


IF (p_orderID IS NOT NULL AND p_orderID<>'') THEN


delete from orders_information where orderid=p_orderID;
DELETE FROM order_information_details where orderid=p_orderID; 


REPLACE INTO orders_information(orders_information.orderInformationID, orders_information.lastUpdated, orders_information.orderID, orders_information.orderDate, orders_information.orderNotes, orders_information.orderStatus, orders_information.paymentRecieved, orders_information.customerID, orders_information.customerPhoneNumber, orders_information.customerEmailAddress, orders_information.firstName, orders_information.lastName, orders_information.notesToVendor, orders_information.affiliateID, orders_information.affiliateGroupID, orders_information.affiliateEmailAddress, orders_information.affiliateName, orders_information.affiliateBranding, orders_information.affiliateBrandingID, orders_information.affiliateBCC, orders_information.affiliateData, orders_information.cruiseLineID, orders_information.cruiseShipID, orders_information.cruiseLine, orders_information.cruiseShip, orders_information.cruiseStartDate, orders_information.cruiseDuration, orders_information.customerEmailConfirmed, orders_information.customerNotes, orders_information.holdEmailsForOrder, orders_information.reviewEmailAuthorized) 
VALUES   (p_orderInformationID,
          p_lastUpdated,
          p_orderID,
          p_orderDate,
          p_orderNotes,
          p_orderStatus,
          p_paymentRecieved,
          p_customerID,
          p_customerPhoneNumber,
          p_customerEmailAddress,
          p_firstName,
          p_lastName,
          p_notesToVendor,
          p_affiliateID,
          p_affiliateGroupID,
          p_affiliateEmailAddress,
          p_affiliateName,
          p_affiliateBranding,
          p_affiliateBrandingID,
          p_affiliateBCC,
          p_affiliateData,
          p_cruiseLineID,
          p_cruiseShipID,
          p_cruiseLine,
          p_cruiseShip,
          p_cruiseStartDate,
          p_cruiseDuration,
          p_customerEmailConfirmed,
          p_customerNotes,
          p_holdEmailsForOrder,
          p_reviewEmailAuthorized);



END IF;


 UNTIL done=1
END REPEAT;

CLOSE cur_OID;


END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

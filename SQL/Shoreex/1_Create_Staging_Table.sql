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

 Date: 01/03/2015 20:45:33 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `1_Create_Staging_Table`
-- ----------------------------
DROP PROCEDURE IF EXISTS `1_Create_Staging_Table`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `1_Create_Staging_Table`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
/*
The aim of this Job is to update the records in all the tables whenever any change is made to the order id in system
This file creates the staging table-order_information_details_test.

Further this whole procedure is divided into 7 parts
*/ /*
10. insert into staging table(order_information_details_test) select from orders and order_details.
  11. match the exact columns names with the selected column values
  12. avoid using upper, lower case functions
20 convert corelated subqueries to temporary table
	21. left join main table with this and more temporary table(s)
30. put all unions as separate insert into main table statement
	31. remove the already selected redundant coloumns
	32. move the union sub queries as temporary tables
	33. select from these temporary tables
40. combine similar cases into one
50. avoid sub queries
*/ /*
@TO-DO - Use informative names for temporary tables
@todo: explain the overall procedure, which files is it split in
*/ /*
Create the Staging table (order_information_details_test) where all the updations will be performed
*/
SET SESSION sql_mode='ALLOW_INVALID_DATES';

DROP TABLE IF EXISTS `order_information_details_test`;


CREATE TABLE `order_information_details_test` (
  `Pid` int(11) NOT NULL AUTO_INCREMENT,
  `lastUpdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `orderDetailID` int(11) NOT NULL,
  `orderID` int(11) NOT NULL,
  `productCode` varchar(30) NOT NULL,
  `productName` varchar(255) DEFAULT NULL,
  `productOptionsList` text,
  `number_of_adults` int(11) DEFAULT '0',
  `number_of_children` int(11) DEFAULT '0',
  `quantity` int(11) DEFAULT NULL,
  `totalPrice` decimal(10,4) NOT NULL COMMENT 'order_details.totalPrice',
  `checkStub` varchar(100) DEFAULT NULL,
  `notes` text,
  `packageID` int(11) DEFAULT NULL,
  `vendorID` int(11) DEFAULT NULL,
  `vendorTitle` varchar(50) DEFAULT NULL,
  `vendorAddress` varchar(255) DEFAULT NULL,
  `vendorEmailAddress` varchar(75) DEFAULT NULL,
  `vendorPONotes` varchar(255) DEFAULT NULL,
  `vendorContacts` text,
  `vendorCost` decimal(10,4) NOT NULL DEFAULT '0',
  `dateVendorPaid` varchar(255) DEFAULT NULL,
  `howVendorPaid` varchar(255) DEFAULT NULL,
  `vendorNotes` text,
  `affiliatePayment` decimal(10,4) NOT NULL DEFAULT '0',
  `dateTravelAgentPaid` varchar(255) DEFAULT NULL,
  `tourDate` datetime DEFAULT NULL,
  `tourTime` varchar(100) DEFAULT NULL,
  `tourDuration` varchar(100) DEFAULT NULL,
  `port` varchar(255) DEFAULT NULL,
  `portArrival` datetime DEFAULT NULL,
  `portDeparture` datetime DEFAULT NULL,
  `itineraryWorks` varchar(255) DEFAULT NULL COMMENT 'Yes, and if not, should mention what caused invalidation',
  `lastResponseDirection` enum('V','M','C')  COMMENT 'V = vendor, M = Merchant, C = customer',
  `lastResponse` enum('A','R','S','P')  COMMENT 'A = accept, R = refuse, S = suggest, P = refuse within penalty',
  `lastResponseSuggestion` varchar(255) DEFAULT NULL,
  `lastResponseNotes` text,
  `customerEmailSent` tinyint(1) NOT NULL DEFAULT '0',
  `holdEmailsForTour` tinyint(1) NOT NULL DEFAULT '0',
  `discountRow` tinyint(1) NOT NULL DEFAULT '0',
  `statusColor` enum('G','R','Y','O','B') NOT NULL DEFAULT 'Y' COMMENT 'G = green, R = red, Y = yellow, O = orange, B = blue',
  `localize_port_arrival` datetime DEFAULT NULL,
  `localize_port_departure` datetime DEFAULT NULL,
  `autoprocess` text,
  `overRide` tinyint(4) DEFAULT NULL,
  `lastResponseSuggestionDate` datetime DEFAULT NULL,
  `lastResponseSuggestionLocation` varchar(400) DEFAULT NULL,
  `meeting_location` varchar(500) DEFAULT NULL,
  `auto_confirm` varchar(10) DEFAULT NULL,
  /*`orderInformationID` int(11) NOT NULL AUTO_INCREMENT,*/
  `orderDate` datetime NOT NULL,
  `orderNotes` text,
  `orderStatus` varchar(255) DEFAULT NULL,
  `paymentRecieved` tinyint(1) NOT NULL DEFAULT '0',
  `customerID` int(11) NOT NULL,
  `customerPhoneNumber` varchar(30) DEFAULT NULL,
  `customerEmailAddress` varchar(75) DEFAULT NULL,
  `firstName` varchar(30) DEFAULT NULL COMMENT 'orders.billingFirstName',
  `lastName` varchar(40) DEFAULT NULL COMMENT 'orders.billingLastName',
  `notesToVendor` varchar(255) DEFAULT NULL COMMENT 'Custom_Field_Custom5',
  `affiliateID` int(11) DEFAULT NULL COMMENT 'Custom_Field_Custom4 or affiliateCustomerID',
  `affiliateGroupID` int(11) DEFAULT NULL,
  `affiliateEmailAddress` varchar(75) DEFAULT NULL,
  `affiliateName` varchar(255) DEFAULT NULL,
  `affiliateBranding` tinyint(1) DEFAULT '0',
  `affiliateBrandingID` int(11) DEFAULT NULL,
  `affiliateBCC` tinyint(1) NOT NULL DEFAULT '0',
  `affiliateData` varchar(255) DEFAULT NULL COMMENT 'Custom_Field_Custom7',
  `cruiseLineID` varchar(50) DEFAULT NULL COMMENT 'Custom_Field_Custom1',
  `cruiseShipID` varchar(50) DEFAULT NULL COMMENT 'Custom_Field_Custom2',
  `cruiseLine` varchar(255) DEFAULT NULL,
  `cruiseShip` varchar(255) DEFAULT NULL,
  `cruiseStartDate` datetime DEFAULT NULL COMMENT 'orders.Custom_Field_Custom3',
  `cruiseDuration` varchar(50) DEFAULT NULL COMMENT 'orders.Custom_Field_Custom6',
  `customerEmailConfirmed` varchar(50) DEFAULT NULL,
  `customerNotes` text COMMENT 'orders.order_Comments',
  `holdEmailsForOrder` tinyint(1) NOT NULL DEFAULT '0',
  `reviewEmailAuthorized` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Affiliate Custom_Field_Custom2',
  `bufferTime` varchar(50) DEFAULT NULL,
  `getItinaryTime` varchar(50) DEFAULT NULL,
  `package_product_code` varchar(30) DEFAULT NULL,
  `tourDateTime` varchar(50) DEFAULT NULL,
  `tourTimeSec` varchar(50) DEFAULT NULL,
  `isInvalidPortArrival` varchar(50) DEFAULT NULL,
  `isInvalidPortDeparture` varchar(50) DEFAULT NULL,
  `loadLastResponse` int(11) NOT NULL DEFAULT '0',
  `doesEmailExist` int(11) DEFAULT NULL,
  `inventoryriskproducts` int(11) DEFAULT NULL,
  `dscdate` datetime DEFAULT NULL,
  `dsctime` VARCHAR(255) DEFAULT NULL,
  `pcprefix` VARCHAR(255) DEFAULT NULL,
  `return` tinyint(5) NOT NULL DEFAULT '0',
  `mailentry` tinyint(2) NOT NULL DEFAULT '0',
  /*UNIQUE KEY `orderInformationID_UNIQUE` (`orderInformationID`) USING BTREE,*/
  PRIMARY KEY (`Pid`),
  KEY `orderDetailID` (`orderDetailID`) USING BTREE,
  KEY `statusColor` (`statusColor`) USING BTREE,
  KEY `productCode` (`productCode`) USING BTREE,
  KEY `orderID` (`orderID`) USING BTREE,
  KEY `tourDate` (`tourDate`) USING BTREE,
  KEY `port` (`port`) USING BTREE,
  KEY `vendorTitle` (`vendorTitle`) USING BTREE,
  KEY `vendorID` (`vendorID`) USING BTREE,
  KEY `lastUpdated` (`lastUpdated`) USING BTREE,
  KEY `orderDate` (`orderDate`) USING BTREE,
  KEY `cruiseStartDate` (`cruiseStartDate`) USING BTREE,
  KEY `cruiseLine` (`cruiseLine`) USING BTREE,
  KEY `cruiseShip` (`cruiseShip`) USING BTREE,
  KEY `affiliateName` (`affiliateName`) USING BTREE,
  KEY `customerID` (`customerID`) USING BTREE,
  KEY `affiliateGroupID` (`affiliateGroupID`) USING BTREE,
  KEY `lastresponsesggdat_idx` (`lastResponseSuggestionDate`) USING BTREE,
  KEY `bffertime_idx` (`bufferTime`) USING BTREE,
  KEY `id_packgid` (`packageID`) USING BTREE,
  KEY `idx_pckprdctcode` (`package_product_code`) USING BTREE,
  KEY `idx_getitinaery` (`getItinaryTime`) USING BTREE,
KEY `idx_itinaryworks` (`itineraryWorks`) USING BTREE
) ENGINE=InnoDB /*AUTO_INCREMENT=9470*/ DEFAULT CHARSET=utf8;
 /*
Create a temporary table to be joined with order_information_details_test table for data insertion
Contain the orderids to be processed
*/
DROP TABLE IF EXISTS `order_information_changes_queue_TEMP`;

CREATE TEMPORARY TABLE `order_information_changes_queue_TEMP` 
SELECT DISTINCT orderid
FROM db82494_confirmations.order_information_changes_queue
WHERE updated IS NULL
ORDER BY orderid;

 /* Start inserting data in staging table*/
INSERT INTO order_information_details_test (order_information_details_test.orderID,order_information_details_test.orderDetailID,order_information_details_test.customerPhoneNumber,order_information_details_test.orderDate,order_information_details_test.customerID,order_information_details_test.firstName,order_information_details_test.lastName,order_information_details_test.orderNotes,order_information_details_test.productName,order_information_details_test.productCode,order_information_details_test.vendorID,order_information_details_test.vendorTitle,order_information_details_test.vendorContacts,order_information_details_test.vendorEmailAddress,order_information_details_test.vendorPONotes,order_information_details_test.vendorAddress,order_information_details_test.totalPrice,order_information_details_test.paymentRecieved,order_information_details_test.dateVendorPaid,order_information_details_test.howVendorPaid,order_information_details_test.dateTravelAgentPaid,order_information_details_test.notes,order_information_details_test.notesToVendor,order_information_details_test.affiliateID,order_information_details_test.affiliateData,order_information_details_test.orderStatus,order_information_details_test.quantity,order_information_details_test.customerNotes,order_information_details_test.cruiseLineID,order_information_details_test.cruiseShipID,order_information_details_test.cruiseStartDate,order_information_details_test.cruiseDuration,order_information_details_test.tourDuration,order_information_details_test.bufferTime,order_information_details_test.auto_confirm,order_information_details_test.package_product_code)
SELECT orders.orderID,
       order_details.orderDetailID,
       orders.shipPhoneNumber,
       orders.orderDate,
       orders.customerID,
       orders.billingFirstName AS firstName,
       orders.billingLastName AS lastName,
       orders.orderNotes,
       order_details.productName,
       order_details.productCode,
       order_details.vendorID,
       vendors.vendor_Title AS vendorTitle,
       vendors.vendor_Contacts AS vendorContacts,
       vendors.vendor_EmailAddress AS vendorEmailAddress,
       vendors.vendor_PO_Notes vendorPONotes,
       vendors.vendor_Address vendorAddress,
       order_details.totalPrice,
       (orders.paymentAmount = orders.total_Payment_Received) AS paymentRecieved,
       order_details_notes.date_vendor_paid AS dateVendorPaid,
       order_details_notes.how_vendor_paid AS howVendorPaid,
       order_details_notes.date_travel_agent_paid AS dateTravelAgentPaid,
       order_details_notes.notes,
       orders.custom_Field_Custom5 AS notesToVendor,
       IFNULL(orders.custom_Field_Custom4, orders.affiliateCustomerID),
       orders.custom_Field_Custom7 AS affiliateData,
       orders.orderStatus,
       order_details.quantity,
       orders.order_Comments AS customerNotes,
       orders.custom_Field_Custom1 AS cruiseLineID,
       orders.custom_Field_Custom2 AS cruiseShipID,
       IF(IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d,%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d,%m,%Y'), IFNULL(IF(STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y') LIKE '0000-%',REPLACE(STR_TO_DATE(custom_Field_Custom3, '%m/%d'),'0000-','2013-'),STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y')), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %M %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%m-%d-%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d.%c.%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %b. %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%b %D %Y'),'1970-01-01'))))))))) LIKE '0000-%',REPLACE(IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d,%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d,%m,%Y'), IFNULL(IF(STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y') LIKE '0000-%',REPLACE(STR_TO_DATE(custom_Field_Custom3, '%m/%d'),'0000-','2013-'),STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y')), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %M %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%m-%d-%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d.%c.%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %b. %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%b %D %Y'),'1970-01-01'))))))))),'0000-','2013-'),IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d,%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d,%m,%Y'), IFNULL(IF(STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y') LIKE '0000-%',REPLACE(STR_TO_DATE(custom_Field_Custom3, '%m/%d'),'0000-','2013-'),STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y')), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %M %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%m-%d-%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d.%c.%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %b. %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%b %D %Y'),'1970-01-01')))))))))) AS cruiseStartDate,
       orders.custom_Field_Custom6 AS cruiseDuration,
       products.productCondition AS tourDuration,
       products.customField2 AS bufferTime,
       products.customField3 AS auto_confirm,
       NULL AS package_product_code
FROM db82494_confirmations.orders
INNER JOIN order_information_changes_queue_TEMP ON (orders.orderID = order_information_changes_queue_TEMP.orderID)
INNER JOIN db82494_confirmations.order_details ON (orders.orderID = order_details.orderID)
LEFT OUTER JOIN db82494_confirmations.vendors ON (order_details.vendorID = vendors.vendorId)
LEFT OUTER JOIN db82494_confirmations.order_details_notes ON (order_details.orderDetailID = order_details_notes.orderDetailID)
LEFT OUTER JOIN db82494_confirmations.products ON order_details.productCode = products.productCode
WHERE NOT EXISTS
    (SELECT NULL
     FROM db82494_confirmations.order_details AS parent_order_details
     LEFT OUTER JOIN db82494_confirmations.order_details AS child_order_details ON (parent_order_details.orderID = child_order_details.orderID
                                                              AND parent_order_details.isKitID = child_order_details.kitID)
     WHERE parent_order_details.orderID = order_information_changes_queue_TEMP.orderID
       AND child_order_details.orderID = order_information_changes_queue_TEMP.orderID
       AND parent_order_details.productCode LIKE 'PCKG%'
       AND (parent_order_details.orderDetailID = order_details.orderDetailID
            OR child_order_details.orderDetailID = order_details.orderDetailID));

 /*Create another temporary table to fetch data from order_details table*/
DROP TABLE IF EXISTS `Vendor_Temp`;


CREATE
TEMPORARY TABLE `Vendor_Temp`
  (SELECT parent_order_details.productCode AS parent_productCode, parent_order_details.orderID AS parent_orderID, parent_order_details.orderDetailID AS parent_orderDetailID, parent_order_details.totalPrice AS parent_totalPrice, child_order_details.productCode AS child_productCode, child_order_details.orderID AS child_orderID, child_order_details.orderDetailID AS child_orderDetailID, child_order_details.productName AS child_productName, child_order_details.quantity AS child_quantity, child_order_details.vendorID AS child_vendorID, products.productCondition AS child_productCondition
   FROM db82494_confirmations.order_details AS parent_order_details, db82494_confirmations.order_details AS child_order_details
   INNER JOIN db82494_confirmations.products ON child_order_details.productCode = products.productCode
   WHERE parent_order_details.productCode LIKE 'PCKG%'
     AND parent_order_details.orderID = child_order_details.orderID
     AND parent_order_details.isKitID = child_order_details.kitID);

 /* Insert data in staging table*/
INSERT INTO order_information_details_test (order_information_details_test.orderID, order_information_details_test.orderDetailID, order_information_details_test.customerPhoneNumber, order_information_details_test.orderDate, order_information_details_test.customerID, order_information_details_test.firstName, order_information_details_test.lastName, order_information_details_test.orderNotes, order_information_details_test.productName, order_information_details_test.productCode, order_information_details_test.vendorID, order_information_details_test.vendorTitle, order_information_details_test.vendorContacts, order_information_details_test.vendorEmailAddress, order_information_details_test.vendorPONotes, order_information_details_test.vendorAddress, order_information_details_test.totalPrice, order_information_details_test.paymentRecieved, order_information_details_test.dateVendorPaid, order_information_details_test.howVendorPaid, order_information_details_test.dateTravelAgentPaid, order_information_details_test.notes, order_information_details_test.notesToVendor, order_information_details_test.affiliateID, order_information_details_test.affiliateData, order_information_details_test.orderStatus, order_information_details_test.quantity, order_information_details_test.customerNotes, order_information_details_test.cruiseLineID, order_information_details_test.cruiseShipID, order_information_details_test.cruiseStartDate, order_information_details_test.cruiseDuration, order_information_details_test.tourDuration, order_information_details_test.bufferTime, order_information_details_test.auto_confirm, order_information_details_test.package_product_code)
SELECT orders.orderID,
       Vendor_Temp.child_orderDetailID AS orderDetailID,
       orders.shipPhoneNumber,
       orders.orderDate,
       orders.customerID,
       orders.billingFirstName AS firstName,
       orders.billingLastName AS lastName,
       orders.orderNotes,
       concat(Vendor_Temp.child_productName, ' (', Vendor_Temp.parent_productCode, ')') AS productName,
       Vendor_Temp.child_productCode AS productCode,
       Vendor_Temp.child_vendorID AS vendorID,
       vendors.vendor_Title AS vendorTitle,
       vendors.vendor_Contacts AS vendorContacts,
       vendors.vendor_EmailAddress AS vendorEmailAddress,
       vendors.vendor_PO_Notes AS vendorPONotes,
       vendors.vendor_Address AS vendorAddress,
       Vendor_Temp.parent_totalPrice AS totalPrice,
       (orders.paymentAmount = orders.total_Payment_Received) AS paymentReceived,
       order_details_notes.date_vendor_paid AS dateVendorPaid,
       order_details_notes.how_vendor_paid AS howVendorPaid,
       order_details_notes.date_travel_agent_paid AS dateTravelAgentPaid,
       order_details_notes.notes,
       orders.custom_Field_Custom5 AS notesToVendor,
       ifnull(orders.custom_Field_Custom4, orders.affiliateCustomerID),
       orders.custom_Field_Custom7 AS affiliateData,
       orders.orderStatus,
       Vendor_Temp.child_quantity AS quantity,
       orders.order_Comments AS customerNotes,
       orders.custom_Field_Custom1 AS cruiseLineID,
       orders.custom_Field_Custom2 AS cruiseShipID,
       IF(IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d,%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d,%m,%Y'), IFNULL(IF(STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y') LIKE '0000-%',REPLACE(STR_TO_DATE(custom_Field_Custom3, '%m/%d'),'0000-','2013-'),STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y')), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %M %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%m-%d-%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d.%c.%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %b. %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%b %D %Y'),'1970-01-01'))))))))) LIKE '0000-%',REPLACE(IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d,%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d,%m,%Y'), IFNULL(IF(STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y') LIKE '0000-%',REPLACE(STR_TO_DATE(custom_Field_Custom3, '%m/%d'),'0000-','2013-'),STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y')), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %M %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%m-%d-%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d.%c.%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %b. %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%b %D %Y'),'1970-01-01'))))))))),'0000-','2013-'),IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d,%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d,%m,%Y'), IFNULL(IF(STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y') LIKE '0000-%',REPLACE(STR_TO_DATE(custom_Field_Custom3, '%m/%d'),'0000-','2013-'),STR_TO_DATE(custom_Field_Custom3, '%m/%d/%Y')), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %M %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%m-%d-%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%M %d %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d.%c.%Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%d %b. %Y'), IFNULL(STR_TO_DATE(custom_Field_Custom3, '%b %D %Y'),'1970-01-01')))))))))) AS cruiseStartDate,
       orders.custom_Field_Custom6 AS cruiseDuration,
       Vendor_Temp.child_productCondition AS tourDuration,
       "" AS bufferTime,
       NULL AS auto_confirm,
               Vendor_Temp.parent_productCode AS package_product_code
FROM db82494_confirmations.orders
LEFT JOIN Vendor_Temp ON (orders.orderID = Vendor_Temp.parent_orderID
                          AND orders.orderID = Vendor_Temp.child_orderID)
INNER JOIN order_information_changes_queue_TEMP ON (order_information_changes_queue_TEMP.orderID = Vendor_Temp.parent_orderID)
LEFT OUTER JOIN db82494_confirmations.vendors ON (Vendor_Temp.child_vendorID = vendors.vendorId)
LEFT OUTER JOIN db82494_confirmations.order_details_notes ON (Vendor_Temp.child_orderDetailID = order_details_notes.orderDetailID);

 /*Create another temporary table to fetch vendor data*/
DROP TABLE IF EXISTS `Discount_Temp`;

CREATE TEMPORARY TABLE `Discount_Temp` 
(SELECT orders.orderID, sum(order_details.totalPrice) AS totalPriceLineItems
   FROM db82494_confirmations.orders, db82494_confirmations.order_details
   WHERE orders.orderID = order_details.orderID
   GROUP BY order_details.orderID, orders.paymentAmount HAVING orders.paymentAmount != totalPriceLineItems);

 /* Start inserting data in staging table*/
INSERT INTO order_information_details_test (order_information_details_test.orderID, order_information_details_test.orderDetailID, order_information_details_test.customerPhoneNumber, order_information_details_test.orderDate, order_information_details_test.customerID, order_information_details_test.firstName, order_information_details_test.lastName, order_information_details_test.orderNotes, order_information_details_test.productName, order_information_details_test.productCode, order_information_details_test.vendorID, order_information_details_test.vendorTitle, order_information_details_test.vendorContacts, order_information_details_test.vendorEmailAddress, order_information_details_test.vendorPONotes, order_information_details_test.vendorAddress, order_information_details_test.totalPrice, order_information_details_test.paymentRecieved, order_information_details_test.dateVendorPaid, order_information_details_test.howVendorPaid, order_information_details_test.dateTravelAgentPaid, order_information_details_test.notes, order_information_details_test.notesToVendor, order_information_details_test.affiliateID, order_information_details_test.affiliateData, order_information_details_test.orderStatus, order_information_details_test.quantity, order_information_details_test.customerNotes, order_information_details_test.cruiseLineID, order_information_details_test.cruiseShipID, order_information_details_test.cruiseStartDate, order_information_details_test.cruiseDuration, order_information_details_test.tourDuration, order_information_details_test.bufferTime, order_information_details_test.auto_confirm, order_information_details_test.package_product_code)
SELECT orders.orderID,
       '2147483647' AS orderDetailID,
       orders.shipPhoneNumber,
       orders.orderDate,
       orders.customerID,
       orders.billingFirstName AS firstName,
       orders.billingLastName AS lastName,
       orders.orderNotes,
       'Discounts and Other' AS productName,
       'DSC' AS productCode,
       NULL AS vendorID,
               NULL AS vendorTitle,
                       NULL AS vendorContacts,
                               NULL AS vendorEmailAddress,
                                       NULL AS vendorPONotes,
                                               NULL AS vendorAddress,
                                                       (orders.paymentAmount - Discount_Temp.totalPriceLineItems) AS totalPrice,
                                                       (orders.paymentAmount = orders.total_Payment_Received) AS paymentRecieved,
                                                       NULL AS dateVendorPaid,
                                                               NULL AS howVendorPaid,
                                                                       NULL AS dateTravelAgentPaid,
                                                                               NULL AS notes,
                                                                                       orders.custom_Field_Custom5 AS notesToVendor,
                                                                                       ifnull(orders.custom_Field_Custom4, orders.affiliateCustomerID),
                                                                                       orders.custom_Field_Custom7 AS affiliateData,
                                                                                       orders.orderStatus,
                                                                                       1 AS quantity,
                                                                                       NULL AS order_Comments,
                                                                                               NULL AS cruiseLineID,
                                                                                                       NULL AS cruiseShipID,
                                                                                                               NULL AS cruiseStartDate,
                                                                                                                       NULL AS cruiseDuration,
                                                                                                                               NULL AS tourDuration,
                                                                                                                                       "" AS bufferTime,
                                                                                                                                       NULL AS auto_confirm,
                                                                                                                                               NULL AS package_product_code
FROM Discount_Temp
INNER JOIN db82494_confirmations.orders ON (orders.orderID = Discount_Temp.orderid)
INNER JOIN order_information_changes_queue_TEMP ON (order_information_changes_queue_TEMP.orderID = orders.orderID);

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

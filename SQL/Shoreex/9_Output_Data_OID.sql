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

 Date: 01/03/2015 20:58:08 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `9_Output_Data_OID`
-- ----------------------------
DROP PROCEDURE IF EXISTS `9_Output_Data_OID`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `9_Output_Data_OID`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

DECLARE done boolean DEFAULT 0;
DECLARE p_orderInformationDetailID int(11);
DECLARE p_lastUpdated timestamp;
DECLARE p_orderDetailID int(11) ;
DECLARE p_orderID int(11);
DECLARE p_productCode varchar(30);
DECLARE p_productName varchar(255) DEFAULT NULL;
DECLARE p_productOptionsList text;
DECLARE p_number_of_adults int(11) DEFAULT '0';
DECLARE p_number_of_children int(11) DEFAULT '0';
DECLARE p_quantity int(11) DEFAULT NULL;
DECLARE p_totalPrice decimal(10,4);
DECLARE p_checkStub varchar(100) DEFAULT NULL;
DECLARE p_notes text;
DECLARE p_packageID int(11) DEFAULT NULL;
DECLARE p_vendorID int(11) DEFAULT NULL;
DECLARE p_vendorTitle varchar(50) DEFAULT NULL;
DECLARE p_vendorAddress varchar(255) DEFAULT NULL;
DECLARE p_vendorEmailAddress varchar(75) DEFAULT NULL;
DECLARE p_vendorPONotes varchar(255) DEFAULT NULL;
DECLARE p_vendorContacts text;
DECLARE p_vendorCost decimal(10,4) DEFAULT NULL;
DECLARE p_dateVendorPaid varchar(255) DEFAULT NULL;
DECLARE p_howVendorPaid varchar(255) DEFAULT NULL;
DECLARE p_vendorNotes text;
DECLARE p_affiliatePayment decimal(10,4) DEFAULT NULL;
DECLARE p_dateTravelAgentPaid varchar(255) DEFAULT NULL;
DECLARE p_tourDate datetime DEFAULT NULL;
DECLARE p_tourTime varchar(100) DEFAULT NULL;
DECLARE p_tourDuration varchar(100) DEFAULT NULL;
DECLARE p_port varchar(255) DEFAULT NULL;
DECLARE p_portArrival datetime DEFAULT NULL;
DECLARE p_portDeparture datetime DEFAULT NULL;
DECLARE p_itineraryWorks varchar(255) DEFAULT NULL ;
DECLARE p_lastResponseDirection enum('V','M','C') DEFAULT 'V';
DECLARE p_lastResponse enum('A','R','S','P') DEFAULT 'A';
DECLARE p_lastResponseSuggestion varchar(255) DEFAULT NULL;
DECLARE p_lastResponseNotes text;
DECLARE p_customerEmailSent tinyint(1) DEFAULT '0';
DECLARE p_holdEmailsForTour tinyint(1) DEFAULT '0';
DECLARE p_discountRow tinyint(1) DEFAULT '0';
DECLARE p_statusColor enum('G','R','Y','O','B') DEFAULT 'Y' ;
DECLARE p_localize_port_arrival datetime DEFAULT NULL;
DECLARE p_localize_port_departure datetime DEFAULT NULL;
DECLARE p_autoprocess varchar(100) DEFAULT NULL;
DECLARE p_overRide tinyint(4) DEFAULT NULL;
DECLARE p_lastResponseSuggestionDate datetime DEFAULT NULL;
DECLARE p_auto_confirm varchar(10) DEFAULT NULL;
DECLARE  `p_lastResponseSuggestionLocation` varchar(400) DEFAULT NULL;
DECLARE  `p_meeting_location` varchar(500) DEFAULT NULL;
DECLARE p_mailentry TINYINT(2) DEFAULT '0';
DECLARE p_date datetime DEFAULT NOW();

DECLARE cur_OID CURSOR FOR
SELECT    orderDetailID,
          productCode,
          orderID,
          productName,
          productOptionsList,
          number_of_adults,
          number_of_children,
          quantity,
          totalPrice,
          checkStub,
          notes,
          packageID,
          vendorID,
          vendorTitle,
          vendorAddress,
          vendorEmailAddress,
          vendorPONotes,
          vendorContacts,
          vendorCost,
          dateVendorPaid,
          howVendorPaid,
          vendorNotes,
          affiliatePayment,
          dateTravelAgentPaid,
          tourDate,
          tourTime,
          tourDuration,
          `port`,
          portArrival,
          portDeparture,
          itineraryWorks,
          lastResponseDirection,
          lastResponse,
          lastResponseSuggestion,
          lastResponseNotes,
          customerEmailSent,
          holdEmailsForTour,
          discountRow,
          statusColor,
          localize_port_arrival,
          localize_port_departure,
          autoprocess,
          overRide,
          lastResponseSuggestionDate,
          auto_confirm,
					lastResponseSuggestionLocation,
          meeting_location,
          mailentry
   FROM shoreex_staging.order_information_details_test t1 INNER JOIN (select MAX(order_information_details_test.Pid) Pid from shoreex_staging.order_information_details_test  GROUP BY order_information_details_test.orderDetailID) t2 on (t1.Pid=t2.Pid);


DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
SET sql_mode := 'IGNORE_SPACE';




OPEN cur_OID;
REPEAT

FETCH cur_OID INTO
          p_orderDetailID,
          p_productCode,
          p_orderID,
          p_productName,
          p_productOptionsList,
          p_number_of_adults,
          p_number_of_children,
          p_quantity,
          p_totalPrice,
          p_checkStub,
          p_notes,
          p_packageID,
          p_vendorID,
          p_vendorTitle,
          p_vendorAddress,
          p_vendorEmailAddress,
          p_vendorPONotes,
          p_vendorContacts,
          p_vendorCost,
          p_dateVendorPaid,
          p_howVendorPaid,
          p_vendorNotes,
          p_affiliatePayment,
          p_dateTravelAgentPaid,
          p_tourDate,
          p_tourTime,
          p_tourDuration,
          p_port,
          p_portArrival,
          p_portDeparture,
          p_itineraryWorks,
          p_lastResponseDirection,
          p_lastResponse,
          p_lastResponseSuggestion,
          p_lastResponseNotes,
          p_customerEmailSent,
          p_holdEmailsForTour,
          p_discountRow,
          p_statusColor,
          p_localize_port_arrival,
          p_localize_port_departure,
          p_autoprocess,
          p_overRide,
          p_lastResponseSuggestionDate,
          p_auto_confirm,
					p_lastResponseSuggestionLocation,
          p_meeting_location,
          p_mailentry;


SET p_orderInformationDetailID=NULL;
SET p_lastUpdated=NULL;
SET p_date=NOW();


IF (p_orderDetailID IS NOT NULL AND p_orderDetailID<>'') THEN


IF (p_mailentry is not null and p_mailentry<>'' and p_mailentry=1) THEN
REPLACE INTO order_details_responses (order_details_responses.orderDetailID,order_details_responses.direction,order_details_responses.response,order_details_responses.received) VALUES (p_orderDetailID,'M','A',now());

REPLACE INTO approval_emails_log (approval_emails_log.email_id,approval_emails_log.orderDetailID,approval_emails_log.orderID,approval_emails_log.direction,approval_emails_log.email_type,approval_emails_log.queued) VALUES ('',p_orderDetailID,p_orderID,'V','R',NULL);

END IF;



/*DELETE FROM order_information_details where orderDetailID=p_orderDetailID; */
/*delete from order_information_details where orderID=p_orderID AND productCode = 'DSC' ; */

REPLACE INTO order_information_details (orderInformationDetailID, orderDetailID, productCode, lastUpdated, orderID, productName, productOptionsList, number_of_adults, number_of_children, quantity, totalPrice, checkStub, notes, packageID, vendorID, vendorTitle, vendorAddress, vendorEmailAddress, vendorPONotes, vendorContacts, vendorCost, dateVendorPaid, howVendorPaid, vendorNotes, affiliatePayment, dateTravelAgentPaid, tourDate, tourTime, tourDuration, `port`, portArrival, portDeparture, itineraryWorks, lastResponseDirection, lastResponse, lastResponseSuggestion, lastResponseNotes, customerEmailSent, holdEmailsForTour, discountRow, statusColor, localize_port_arrival, localize_port_departure, autoprocess, overRide, lastResponseSuggestionDate, auto_confirm,lastResponseSuggestionLocation,meeting_location) 
VALUES   (p_orderInformationDetailID,
          p_orderDetailID,
          p_productCode,
          p_lastUpdated,
          p_orderID,
          p_productName,
          p_productOptionsList,
          p_number_of_adults,
          p_number_of_children,
          p_quantity,
          p_totalPrice,
          p_checkStub,
          p_notes,
          p_packageID,
          p_vendorID,
          p_vendorTitle,
          p_vendorAddress,
          p_vendorEmailAddress,
          p_vendorPONotes,
          p_vendorContacts,
          p_vendorCost,
          p_dateVendorPaid,
          p_howVendorPaid,
          p_vendorNotes,
          p_affiliatePayment,
          p_dateTravelAgentPaid,
          p_tourDate,
          p_tourTime,
          p_tourDuration,
          p_port,
          p_portArrival,
          p_portDeparture,
          p_itineraryWorks,
          p_lastResponseDirection,
          p_lastResponse,
          p_lastResponseSuggestion,
          p_lastResponseNotes,
          p_customerEmailSent,
          p_holdEmailsForTour,
          p_discountRow,
          p_statusColor,
          p_localize_port_arrival,
          p_localize_port_departure,
          p_autoprocess,
          p_overRide,
          p_lastResponseSuggestionDate,
          p_auto_confirm,
          p_lastResponseSuggestionLocation,
          p_meeting_location);



UPDATE order_information_changes_queue SET updated=now() WHERE orderID=p_orderid AND updated IS NULL;
END IF;



 UNTIL done=1
END REPEAT;

CLOSE cur_OID;

UPDATE order_information_details
SET `port` = null,
portArrival = null,
portDeparture = null,
localize_port_arrival = null,
localize_port_departure = null,
vendorID = '1',
vendorTitle = 'Shore Excursions Group',
vendorEmailAddress = 'confirm@shoreex.com',
itineraryWorks='Yes',
overRide=1,
lastResponse='A',
lastResponseDirection='M',
statusColor='G'
WHERE productCode LIKE 'DSC-%' and statusColor = 'Y';

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

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

 Date: 01/03/2015 20:51:42 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `4_Update_statusColor`
-- ----------------------------
DROP PROCEDURE IF EXISTS `4_Update_statusColor`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `4_Update_statusColor`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

/*
This file updates fileds for EXPEDITE and EXCURSIONPROTPLAN products and updates status color for all the records
*/ /*
10. Update columns for EXPEDITE and EXCURSIONPROTPLAN products
     11. update the tourdate
     12. update the overide column
     13. update the itineraryWorks
20. insert entries into order_details_responses and approval_email_logs table
30. Update statusColor to R,G,B,Y,O following appropriate conditions
40. Update values for holdEmailsForOrder for all records
50. Update the statuscolor for blackout dates to Orange
60. Update the value of doesEmailExist
*/ /*Update the tourDate for EXPEDITE and EXCURSIONPROTPLAN products*/
UPDATE order_information_details_test
SET tourDate=IFNULL(CONCAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(cruiseStartDate))),' 00:00:00'),NULL)
WHERE (tourDate IS NULL
       OR tourDate='')
  AND productCode IN ('EXPEDITE',
                      'EXCURSIONPROTPLAN');

 /*Update the overide=1 and itineraryWorks=yes for EXPEDITE and EXCURSIONPROTPLAN products*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.order_information_details ON (order_information_details_test.orderdetailid=order_information_details.orderdetailid)
SET order_information_details_test.overRide='1',
    order_information_details_test.itineraryWorks='Yes'
WHERE order_information_details.overRide='1';

UPDATE order_information_details_test
SET order_information_details_test.overRide='1',
    order_information_details_test.itineraryWorks='Yes'
WHERE order_information_details_test.productCode IN ('EXPEDITE',
                                                     'EXCURSIONPROTPLAN');

 /*Update the itineraryWorks=Yes when auto confirm is set for EXPEDITE and EXCURSIONPROTPLAN products*/
UPDATE order_information_details_test
SET itineraryWorks='Yes'
WHERE auto_confirm ='Y'
  AND orderStatus<>'CANCELLED'
  AND orderStatus<>'PAYMENT DECLINED'
  /*AND productCode IN ('EXPEDITE',
                      'EXCURSIONPROTPLAN')*/;

 /*Insert the data in order_details_responses for auto-confirm orders with default direction as 'M' and response as 'A'*/
 /*Insert the data in approval_emails_log for auto-confirm orders with default direction as 'V' and email type 'R'*/


UPDATE  order_information_details_test 
   LEFT JOIN db82494_confirmations.order_details_responses ON (order_information_details_test.orderDetailID = order_details_responses.orderDetailID) 
SET order_information_details_test.mailentry=1
WHERE order_details_responses.order_details_response_id IS NULL
     AND order_information_details_test.orderDetailID NOT LIKE '-%'
     AND auto_confirm ='Y'
     AND orderStatus<>'CANCELLED'
     AND orderStatus<>'PAYMENT DECLINED';


 /*Update the lastResponse as 'A' and lastResponseDirection 'M' for which entries have been inserted into order_details_responses*/
UPDATE order_information_details_test
LEFT JOIN db82494_confirmations.order_details_responses ON (order_information_details_test.orderDetailID = order_details_responses.orderDetailID)
SET lastResponse='A' ,
    lastResponseDirection='M'
WHERE order_details_responses.order_details_response_id IS NULL
  AND order_information_details_test.orderDetailID NOT LIKE '-%'
  AND order_information_details_test.auto_confirm ='Y'
  AND order_information_details_test.orderStatus<>'CANCELLED'
  AND order_information_details_test.orderStatus<>'PAYMENT DECLINED';

 /*Status Color*/ /*if the orderstatus is cancelled then color red*/
UPDATE order_information_details_test
SET statusColor='R'
WHERE lastResponse='R'
  OR orderStatus='CANCELLED';

 COMMIT;

 /*if the order is accepted,customerEmail is sent and payment is recieved then update color to green*/
UPDATE order_information_details_test
SET statusColor='G'
WHERE statusColor<>'R'
  AND lastResponse='A'
  AND customerEmailSent='1'
  AND paymentRecieved='1';

 COMMIT;

 /*when order is refused with penalty then update color to blue*/
UPDATE order_information_details_test
SET statusColor='B'
WHERE statusColor NOT IN ('R',
                          'G')
  AND lastResponse='P';

 COMMIT;

 /*Update rest of the orders to yellow*/
UPDATE order_information_details_test
SET statusColor='Y'
WHERE statusColor NOT IN ('R',
                          'G',
                          'B');

 COMMIT;

 /*Update the value of holdEmailsForOrder='1' for yellow orders and where lastResponse is null or if it is not null, it should not be Accepted or rejected */
UPDATE order_information_details_test
SET holdEmailsForOrder='1'
WHERE (statusColor='Y'
       AND productCode<>'DSC'
       AND (holdEmailsForOrder='0'
            AND ((loadLastResponse='1')
                 OR (loadLastResponse<>'1'
                     AND lastResponse<>'A'
                     AND lastResponse<>'R'))));

 COMMIT;

 /*if the itinerary works is null or not yes,precruise,postcruise then update all the tours except red to yellow*/
UPDATE order_information_details_test
SET statusColor='Y'
WHERE (statusColor<>'R'
       AND ((itineraryWorks IS NULL)
            OR (itineraryWorks<>'yes'
                /*AND itineraryWorks<>'pre-cruise'
                AND itineraryWorks<>'post-cruise'*/)));

 COMMIT;

 /*Update the value of holdEmailsForOrder='1' for yellow orders and where lastResponse is null or if it is not null, it should not be Accepted or rejected */
UPDATE order_information_details_test
SET holdEmailsForOrder='1'
WHERE (statusColor='Y'
       AND productCode<>'DSC'
       AND (holdEmailsForOrder='0'
            AND ((loadLastResponse='1')
                 OR (loadLastResponse<>'1'
                     AND lastResponse<>'A'
                     AND lastResponse<>'R'))));

 COMMIT;

 /*when emails are held for a tour then update color to orange*/
UPDATE order_information_details_test
SET statusColor='O',
    holdEmailsForTour='1'
WHERE (statusColor<>'R'
       AND (((itineraryWorks IS NULL)
             OR (itineraryWorks<>'yes'
                 /*AND itineraryWorks<>'pre-cruise'
                 AND itineraryWorks<>'post-cruise'*/))
            OR (cruiseStartDate IS NOT NULL
                AND orderDate IS NOT NULL
                AND UNIX_TIMESTAMP(orderDate) > UNIX_TIMESTAMP(CONCAT(DATE_SUB(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(cruiseStartDate))),INTERVAL 1 DAY),' ',STR_TO_DATE('5:01 pm','%h:%i %p')))))
       AND (customerEmailSent<>'1'
            AND lastResponse IS NULL));

 /*Update status color to Orange for tours that have been booked on blackout dates*/
UPDATE order_information_details_test
SET statusColor='O',
    holdEmailsForTour='1',
    autoprocess='Blackout'
WHERE EXISTS
    (SELECT *
     FROM db82494_confirmations.blackout_dates t2
     WHERE order_information_details_test.productCode=t2.productCode
       AND t2.blackout_date=DATE(order_information_details_test.tourDate))
  AND lastResponse<>'A'
  AND lastResponse<>'R'
  AND orderStatus<>'CANCELLED'
  AND UNIX_TIMESTAMP(NOW()) <= UNIX_TIMESTAMP(tourDate);

 /*Check if order id exists in the approval_emails_log table and update the value of doesEmailExist*/
UPDATE order_information_details_test
SET doesEmailExist=1
WHERE EXISTS
    (SELECT *
     FROM db82494_confirmations.approval_emails_log
     WHERE order_information_details_test.orderID=approval_emails_log.orderID
       AND direction='V');

 /*Update the status color to yellow for hotel cruiseLine*/
UPDATE order_information_details_test
SET statusColor='Y',
    holdEmailsForTour='0'
WHERE statusColor='O'
  AND cruiseLine='hotel';

 /*if lastSuggestions exist or the mail has gone out then update status Color to yellow*/
UPDATE order_information_details_test
SET statusColor='Y',
    holdEmailsForTour='0'
WHERE (statusColor='O'
       AND (doesEmailExist='1'
            OR lastResponseSuggestion IS NOT NULL
            OR lastResponseSuggestionDate IS NOT NULL));

 /*All the orange tour emails are to be held back*/
UPDATE order_information_details_test
SET statusColor='O',
    holdEmailsForTour='1'
WHERE statusColor<>'R'
  AND INSTR(orderStatus,'Awaiting Payment')<>0 ;

 /*Update the tourDate for DSC product code by taking the tourDate of the maximum order details id of the order id*/
UPDATE order_information_details_test
INNER JOIN
  (SELECT orderID,
          orderDetailID,
          dscdate,
          dsctime
   FROM order_information_details_test t1
   WHERE orderDetailID=
       (SELECT MAX(orderDetailID)
        FROM order_information_details_test
        WHERE order_information_details_test.orderID=t1.orderID
          AND dscdate IS NOT NULL
          AND productCode<>'DSC')) AS t2 ON (order_information_details_test.orderID=t2.orderid)
SET tourDate= DATE(FROM_UNIXTIME(IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',IF(UNIX_TIMESTAMP(date_change(tourDate,tourTime))<>'0',UNIX_TIMESTAMP(date_change(tourDate,tourTime)),IF(UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p')))<>'0',UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p'))),IF(UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))=UNIX_TIMESTAMP(date(tourdate)),0,UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))))),0)))
/*WHERE tourTime IS NOT NULL
  AND DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(tourDate))),' ','00:00:00')))) < DATE(FROM_UNIXTIME(IF(UNIX_TIMESTAMP(date_change(tourDate,tourTime))<>'0000-00-00 00:00:00',UNIX_TIMESTAMP(date_change(tourDate,tourTime)),IF(UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p')))<>'0000-00-00 00:00:00',UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p'))),UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))))))
  AND order_information_details_test.productCode='DSC';*/
WHERE IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',UNIX_TIMESTAMP(date_change(tourDate,tourTime))<>0 OR HOUR(tourTime)<>0,0)
    AND DATE_FORMAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(tourDate))),' ','00:00:00')))),'%c/%d/%Y') < DATE_FORMAT(DATE(FROM_UNIXTIME(IF(SUBSTR(tourTime,-2)='AM' OR SUBSTR(tourTime,-2)='PM',IF(UNIX_TIMESTAMP(date_change(tourDate,tourTime))<>'0',UNIX_TIMESTAMP(date_change(tourDate,tourTime)),IF(UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p')))<>'0',UNIX_TIMESTAMP(CONCAT(DATE(tourDate),' ',STR_TO_DATE(tourTime,'%h:%i %p'))),IF(UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))=UNIX_TIMESTAMP(date(tourdate)),0,UNIX_TIMESTAMP(CONCAT(date(tourdate),' ',tourtime))))),0))),'%c/%d/%Y');

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

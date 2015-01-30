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

 Date: 01/03/2015 20:47:42 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `2_Update_tourinfo`
-- ----------------------------
DROP PROCEDURE IF EXISTS `2_Update_tourinfo`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `2_Update_tourinfo`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

/*
@todo: Comments need to be formatted with white space
@todo: missing pseudo code ---done
@todo: missing business logic explanation (comments are not adding any value) --- done
@todo: comments have to be written for the WHY and not the WHO, WHAT, WHEN, WHERE ---- done
*/
/*
10. Update the tour informations correctly
20. Make the date/ time format consistent with each other
	21. the date format M D Y should be consistent throughout
	22. The time format should be same throughout
30. Take all the tour related responses of vendor/adminn from order_detail_responses table
40. Take all the tourDate/tourTime and number of individuals information from options table
50. Take care of the value columns where lastSuggestions/responses do not exist
*/ 
/*
This is the second file of the procedure.
This file will update the tourinformation like tourdate,tourTime, suggested dates and times, the last response(Accepted,rejected or suggestion) etc for all the order ids(discount and non-discount)*/ 

/*
update the latest lastResponse(A,R,S,P), lastResponseDirection(V,C,M), lastResponsenotes for the given orderdetailid from order_details_responses table where the last response from frontend is stored

Why max recieved
because we need to get the latest response data from vendor/merchant 
*/
SET SESSION sql_mode='ALLOW_INVALID_DATES';

UPDATE order_information_details_test SET cruiseStartDate=DATE_ADD(cruiseStartDate,INTERVAL 0 DAY);

UPDATE order_information_details_test
SET lastResponse =
  ( SELECT response
   FROM db82494_confirmations.order_details_responses
   WHERE order_details_responses.orderDetailID = order_information_details_test.orderDetailID
     AND received =
       ( SELECT max(received)
        FROM db82494_confirmations.order_details_responses
        WHERE order_details_responses.orderDetailID = order_information_details_test.orderDetailID )), lastResponseDirection =
  ( SELECT direction
   FROM db82494_confirmations.order_details_responses
   WHERE order_details_responses.orderDetailID = order_information_details_test.orderDetailID
     AND received =
       ( SELECT max(received)
        FROM db82494_confirmations.order_details_responses
        WHERE order_details_responses.orderDetailID = order_information_details_test.orderDetailID )), lastResponseNotes =
  ( SELECT notes
   FROM db82494_confirmations.order_details_responses
   WHERE order_details_responses.orderDetailID = order_information_details_test.orderDetailID
     AND received =
       ( SELECT max(received)
        FROM db82494_confirmations.order_details_responses
        WHERE order_details_responses.orderDetailID = order_information_details_test.orderDetailID ));

/*update the most recent lastResponseSuggestion and lastResponseSuggestionDate and lastResponseSuggestionLocation for the tour as suggested by the merchant*/

UPDATE order_information_details_test
SET lastResponseSuggestion =(

	SELECT  suggestion

	FROM    db82494_confirmations.order_details_responses

	WHERE   order_details_responses.orderDetailID = order_information_details_test.orderDetailID

	AND     suggestion IS NOT NULL

	AND received =(

		SELECT	max(received)

		FROM	db82494_confirmations.order_details_responses

		WHERE	order_details_responses.orderDetailID = order_information_details_test.orderDetailID

		AND(	order_details_responses.suggestion_date IS NOT NULL

			OR order_details_responses.suggestion IS NOT NULL

			OR order_details_responses.suggestion_location IS NOT NULL

		)

	)

),

 lastResponseSuggestionDate =(

	SELECT	suggestion_date

	FROM	db82494_confirmations.order_details_responses

	WHERE	order_details_responses.orderDetailID = order_information_details_test.orderDetailID

	AND suggestion_date IS NOT NULL

	AND received =(

		SELECT	max(received)

		FROM	db82494_confirmations.order_details_responses

		WHERE	order_details_responses.orderDetailID = order_information_details_test.orderDetailID

		AND(	order_details_responses.suggestion_date IS NOT NULL

			OR order_details_responses.suggestion IS NOT NULL

			OR order_details_responses.suggestion_location IS NOT NULL

		)

	)

),

 lastResponseSuggestionLocation =(

	SELECT	suggestion_location

	FROM	db82494_confirmations.order_details_responses

	WHERE	order_details_responses.orderDetailID = order_information_details_test.orderDetailID

	AND suggestion_date IS NOT NULL

	AND received =(

		SELECT	max(received)

		FROM	db82494_confirmations.order_details_responses

		WHERE	order_details_responses.orderDetailID = order_information_details_test.orderDetailID

		AND(	order_details_responses.suggestion_date IS NOT NULL

			OR order_details_responses.suggestion IS NOT NULL

			OR order_details_responses.suggestion_location IS NOT NULL

		)

	)

);
/*
what doe sthe -% comparison stand for?
discount rows after processinhg have orderDetailId of the form -OrderID.
For a particular non discount order id if there is no value in order_detail_response table then update loadLastResponse=1*/
UPDATE order_information_details_test
LEFT JOIN db82494_confirmations.order_details_responses ON ( order_information_details_test.orderDetailID = order_details_responses.orderDetailID)
SET order_information_details_test.loadLastResponse = '1'
WHERE order_details_responses.order_details_response_id IS NULL
  AND order_information_details_test.orderDetailID NOT LIKE '-%';

/*update all the vendorNotes in a concat format given by the vendor for the orderdetailid, starting with the most recent one*/
UPDATE order_information_details_test
SET order_information_details_test.vendorNotes =
  ( SELECT GROUP_CONCAT( concat( order_details_responses.notes ) SEPARATOR ' ' ) AS notes
   FROM db82494_confirmations.order_details_responses
   WHERE order_details_responses.direction = 'V'
     AND notes IS NOT NULL
     AND order_details_responses.orderDetailID = order_information_details_test.orderDetailID
   GROUP BY order_details_responses.orderDetailID
   ORDER BY received DESC, order_details_response_id DESC);

/*
why approval_email_log
because all the mails that go out of the system are saved in this table
Update the customerEmailSent value=1 if the mail has gone to the customer and hence is not queued in approval_email_log table*/
UPDATE order_information_details_test
SET customerEmailSent =
  ( SELECT 1
   FROM db82494_confirmations.approval_emails_log t1
   WHERE t1.orderID = order_information_details_test.orderID
     AND t1.direction = 'C'
     AND t1.queued IS NOT NULL
   GROUP BY t1.orderID);

/*Update the customerEmailConfirmed value=1 if the order was confirmed. If confirmed, the orderid will be present in the order_confirmations_log*/
UPDATE order_information_details_test
LEFT JOIN db82494_confirmations.order_confirmations_log ON ( order_confirmations_log.orderID = order_information_details_test.orderID)
SET customerEmailConfirmed = 1
WHERE order_confirmations_log.ID IS NOT NULL;

/*update the customer email adress from customers table*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON ( order_information_details_test.customerID = customers.customerId)
SET order_information_details_test.customerEmailAddress = customers.emailAddress;

/*Update the tourDate to the last Suggested Date suggested by the merchant for the order detail ids where lastResponseSuggestionDate is not null*/
UPDATE order_information_details_test
SET order_information_details_test.tourDate = order_information_details_test.lastResponseSuggestionDate
WHERE order_information_details_test.lastResponseSuggestionDate IS NOT NULL;


/*this will allow invalid dates to be saved in database*/
SET SESSION sql_mode='ALLOW_INVALID_DATES';
/*For all order ids a dscdate is set from options table using the ordertail id as discount tours do not have tourDate and this needs to be used for the order ids having a discount row */ /*17-day 16-month 145-year*/
UPDATE order_information_details_test
SET dscdate =
  ( SELECT DATE_ADD(STR_TO_DATE( GROUP_CONCAT( ifnull( order_details_options.text, optionsDesc ) SEPARATOR ' ' ), '%M %d %Y' ),INTERVAL 0 DAY)
   FROM db82494_confirmations.order_details_options_parsed
   LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID ), db82494_confirmations.option_categories,
                                                                                                                                db82494_confirmations.`options`
   WHERE `options` .optionCatID = option_categories.iD
     AND order_details_options_parsed.orderDetailID = order_information_details_test.orderDetailID
     AND order_details_options_parsed.optionID = `options` .iD
     AND option_categories.iD IN (17,
                                  16,
                                  145)
   GROUP BY order_information_details_test.orderDetailID);

/*
16,17,145 significance?
if lastResponseSuggestionDate is null then load the date entered by customer from the front end into tourDatethat is stored in options table 17-day 16-month 145-year
-updated below query on 11 sept 2014 to replace the 'Click here' option to '' so that tourdate can be calculated properly as after group concating result was like 'October 23 Click Here 2014' but we 
needs it ina format like 'October 23 2014' to be saved into tourdate column
*/
UPDATE order_information_details_test
SET tourDate =
  ( SELECT DATE_ADD(STR_TO_DATE(if (GROUP_CONCAT(ifnull(order_details_options.text,optionsDesc)SEPARATOR ' ') like '%Click Here%',replace(GROUP_CONCAT(ifnull(order_details_options.text,optionsDesc)SEPARATOR ' '),'Click Here ',''),
        GROUP_CONCAT(
                      ifnull(
						order_details_options.text,
						optionsDesc
					)SEPARATOR ' '
				)),
				'%M %d %Y'
			),
			INTERVAL 0 DAY
		)
   FROM db82494_confirmations.order_details_options_parsed
   LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID ), db82494_confirmations.option_categories,
                                                                                                                                db82494_confirmations.`options`
   WHERE `options` .optionCatID = option_categories.iD
     AND order_details_options_parsed.orderDetailID = order_information_details_test.orderDetailID
     AND order_details_options_parsed.optionID = `options` .iD
     AND option_categories.iD IN (17,
                                  16,
                                  145)
   GROUP BY order_information_details_test.orderDetailID)
WHERE order_information_details_test.lastResponseSuggestionDate IS NULL
  AND tourDate IS NULL;

/*Set the dscdate calculated before to tourDate for discount rows by selecting the tourDate of the latest order detail id because discount rows do not have a tourDate/Time*/
UPDATE order_information_details_test t1
INNER JOIN
  ( SELECT orderID,
           orderDetailID,
           dscdate,
           dsctime
   FROM order_information_details_test t1
   WHERE orderDetailID =
       ( SELECT MAX(orderDetailID)
        FROM order_information_details_test
        WHERE order_information_details_test.orderID = t1.orderID
          AND productCode <> 'DSC' )) AS t2 ON (t1.orderID = t2.orderid)
SET t1.tourDate = t2.dscdate,
    t1.dscdate = t2.dscdate
WHERE t1.productCode = 'DSC';

/*Update the tourTime to the last Suggested Time suggested by the merchant for the order detail ids where lastResponseSuggestionTimee is not null*/
UPDATE order_information_details_test
SET tourTime = lastResponseSuggestion
WHERE lastResponseSuggestion IS NOT NULL;

/*For all order ids a dsctime is set from options table using the ordertail id as discount tours do not have tourTime and this needs to be used for the order ids having a discount row */ /*22-Tour Departure Time */
UPDATE order_information_details_test
SET dsctime =
  ( SELECT ifnull( order_details_options.text, optionsDesc )
   FROM db82494_confirmations.order_details_options_parsed
   LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID ), db82494_confirmations.option_categories,
                                                                                                                                db82494_confirmations.`options`
   WHERE `options` .optionCatID = option_categories.iD
     AND order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID
     AND order_details_options_parsed.optionID = `options` .iD
     AND option_categories.iD = '22'
   GROUP BY order_information_details_test.orderDetailID);

/*if lastResponseSuggestion is null then load the time entered by customer from the front end into tourTime that is stored in options table
22-Tour Departure Time */
UPDATE order_information_details_test
SET tourTime =
  ( SELECT ifnull( order_details_options.text, optionsDesc )
   FROM db82494_confirmations.order_details_options_parsed
   LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID ), db82494_confirmations.option_categories,
                                                                                                                                db82494_confirmations.`options`
   WHERE `options` .optionCatID = option_categories.iD
     AND order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID
     AND order_details_options_parsed.optionID = `options` .iD
     AND option_categories.iD = '22'
   GROUP BY order_information_details_test.orderDetailID)
WHERE order_information_details_test.lastResponseSuggestion IS NULL
  AND tourTime IS NULL;

/*set the dsctime calculated before to tourTime for discount rows by selecting the tourTime of the latest order detail id */
UPDATE order_information_details_test t1
INNER JOIN
  ( SELECT orderID,
           orderDetailID,
           dscdate,
           dsctime
   FROM order_information_details_test t1
   WHERE orderDetailID =
       ( SELECT MAX(orderDetailID)
        FROM order_information_details_test
        WHERE order_information_details_test.orderID = t1.orderID
          AND productCode <> 'DSC' )) AS t2 ON (t1.orderID = t2.orderid)
SET t1.tourTime = t2.dsctime,
    t1.dsctime = t2.dsctime
WHERE t1.productCode = 'DSC';

/*Update the productOptionList with all the options except from tourDate and tourTime*/
UPDATE order_information_details_test
SET order_information_details_test.productOptionsList =
  ( SELECT GROUP_CONCAT( CONCAT( optionCategoriesDesc, ': ', ifnull( order_details_options.text, optionsDesc ) ) SEPARATOR '\n' )
   FROM db82494_confirmations.order_details_options_parsed
   LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID ), db82494_confirmations.option_categories,
                                                                                                                                db82494_confirmations.`options`
   WHERE `options` .optionCatID = option_categories.iD
     AND order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID
     AND order_details_options_parsed.optionID = `options` .iD
     AND option_categories.iD NOT IN (16,
                                      17,
                                      22,
                                      145)
   GROUP BY order_information_details_test.orderDetailID);

/*Update Number Of Adults entered on front end and that are saved in options table where optionCategoriesDesc is Number of Individuals/Number of Adults*/
/*UPDATE order_information_details_test
INNER JOIN order_details_options_parsed ON ( order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID)
LEFT OUTER JOIN order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID), option_categories,
                                                                                                                            `options`
SET order_information_details_test.number_of_adults = SUM(ifnull( order_details_options.text, IFNULL(optionsDesc, '0')))
WHERE `options` .optionCatID = option_categories.iD
  AND order_details_options_parsed.optionID = `options` .iD
  AND optionCategoriesDesc IN ( 'Number of Individuals',
                                'Number of Adults');*/
UPDATE order_information_details_test SET number_of_adults= (SELECT SUM(ifnull( order_details_options.text, IFNULL(optionsDesc, '0')))
from db82494_confirmations.order_details_options_parsed LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID), db82494_confirmations.option_categories,
                                                                                                                            db82494_confirmations.`options`

WHERE `options` .optionCatID = option_categories.iD AND order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID
  AND order_details_options_parsed.optionID = `options` .iD
  AND optionCategoriesDesc IN ( 'Number of Individuals',
                                'Number of Adults') GROUP BY order_information_details_test.orderDetailID);
COMMIT;

UPDATE order_information_details_test SET number_of_adults=0 WHERE number_of_adults is null;
COMMIT;

/*Update Number Of Children entered in front end and that are saved in options table where optionCategoriesDesc is Number of Children*/
/*UPDATE order_information_details_test
INNER JOIN order_details_options_parsed ON ( order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID)
LEFT OUTER JOIN order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID), option_categories,
                                                                                                                            `options`
SET order_information_details_test.number_of_children = SUM(ifnull( order_details_options.text, IFNULL(optionsDesc, '0')))
WHERE `options` .optionCatID = option_categories.iD
  AND order_details_options_parsed.optionID = `options` .iD
  AND optionCategoriesDesc IN ('Number of Children');*/

UPDATE order_information_details_test SET number_of_children= (SELECT SUM(ifnull( order_details_options.text, IFNULL(optionsDesc, '0')))
from db82494_confirmations.order_details_options_parsed LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID), db82494_confirmations.option_categories,
                                                                                                                            db82494_confirmations.`options`

WHERE `options` .optionCatID = option_categories.iD AND order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID
  AND order_details_options_parsed.optionID = `options` .iD
  AND optionCategoriesDesc IN ('Number of Children') GROUP BY order_information_details_test.orderDetailID);
COMMIT;

UPDATE order_information_details_test SET number_of_children=0 WHERE number_of_children is NULL;
COMMIT;

/*Update meeting location from the options value*/

UPDATE order_information_details_test SET meeting_location = (SELECT ifnull(order_details_options.text, IFNULL(optionsDesc, NULL)) 

from db82494_confirmations.order_details_options_parsed LEFT OUTER JOIN db82494_confirmations.order_details_options ON ( order_details_options_parsed.textOptionID = order_details_options.textOptionID), db82494_confirmations.option_categories,

                                                                                                                            db82494_confirmations.`options`



WHERE `options` .optionCatID = option_categories.iD AND order_information_details_test.orderDetailID = order_details_options_parsed.orderDetailID

  AND order_details_options_parsed.optionID = `options` .iD

  AND optionCategoriesDesc IN ('Tour Pickup Location') GROUP BY order_information_details_test.orderDetailID);

/** Update tourdate for dsc product -- Sandeep 09 Nov*/
UPDATE order_information_details_test t1
INNER JOIN order_information_details_test t2 ON(t1.orderID=t2.orderID)
SET t1.tourDate = (SELECT MIN(t2.tourDate))
WHERE t1.productCode LIKE 'DSC-%';

COMMIT;


/*
why 0.5 this is the default time
Upate buffer time for time difference between the different timezones */
UPDATE order_information_details_test
SET bufferTime = '0.5'
WHERE bufferTime = ''
  OR bufferTime IS NULL
  OR bufferTime = 0;

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

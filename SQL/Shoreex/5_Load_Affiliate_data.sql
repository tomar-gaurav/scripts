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

 Date: 01/03/2015 20:52:45 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `5_Load_Affiliate_data`
-- ----------------------------
DROP PROCEDURE IF EXISTS `5_Load_Affiliate_data`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `5_Load_Affiliate_data`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

/*Load Afiiliate Function*/ /*
This is the 5th file in the procedure
This file updates all the affiliate related column values*/ /*
10. Proper inner and left jon of staging table with customer table on customer id and customer group id
20. Update values of affiliateGroupID,affiliateBCC, affiliateEmailAddress, affiliateName, affiliatePayment
30. Update values of affiliateBrandingID and reviewEmailAuthorized according to the values of customerId column in customers table
40. Update values of affiliateBranding according to value of affiliateBrandingID
*/ /*customer table has customerId and customerGroupId.
Affiliate id from staging table is matched with customer id of customer table and customer id is matched with customer group id
of customer table.
affiliateGroupId is updated in order_information_details_test*/
UPDATE order_information_details_test t1
INNER JOIN db82494_confirmations.customers t2 ON (t1.affiliateID=t2.customerId)
LEFT JOIN db82494_confirmations.customers t3 ON (t2.iD_Customers_Groups=t3.customerId)
SET t1.affiliateGroupID=t3.customerid
WHERE t2.iD_Customers_Groups IS NOT NULL;

 /*Update affiliateBCC='1' if the affiliate should be bcc'd on e-tickets where customers accessKey is P*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
SET order_information_details_test.affiliateBCC='1'
WHERE customers.accessKey='P'
  AND customers.custom_Field_Custom4='Y';

 /*Check if the affiliate is branded customer(custom_Field_Custom5) then update value of affiliateBrandingID where customerId is null*/ /*inner joining with customers table on customerid to get the rows wrt main table then
left joining with customers table again to get the values present in left side table
*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
LEFT JOIN db82494_confirmations.customers t1 ON (t1.customerId=customers.iD_Customers_Groups)
SET order_information_details_test.affiliateBrandingID=customers.customerId
WHERE t1.customerId IS NULL
  AND customers.accessKey='P'
  AND customers.custom_Field_Custom5='Y';

 /*If this affiliate belongs to an agency, check if the agency is branded then update value of affiliateBrandingID where customerId is not null*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
LEFT JOIN db82494_confirmations.customers t1 ON (t1.customerId=customers.iD_Customers_Groups)
SET order_information_details_test.affiliateBrandingID=t1.customerId
WHERE customers.iD_Customers_Groups IS NOT NULL
  AND t1.customerId IS NOT NULL
  AND t1.accessKey='P'
  AND t1.custom_Field_Custom5='Y';

 /*Check if the affiliate allows review emails then update reviewEmailAuthorized as per conditions*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
LEFT JOIN db82494_confirmations.customers t1 ON (t1.customerId=customers.iD_Customers_Groups)
SET order_information_details_test.reviewEmailAuthorized= CASE
                                                              WHEN customers.custom_Field_Custom2='Y' THEN '1'
                                                              WHEN customers.custom_Field_Custom2<>'Y' THEN '0'
                                                          END
WHERE t1.customerId IS NULL
  AND customers.accessKey='P';

 /*same as above*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
LEFT JOIN db82494_confirmations.customers t1 ON (t1.customerId=customers.iD_Customers_Groups)
SET order_information_details_test.reviewEmailAuthorized= CASE
                                                              WHEN t1.custom_Field_Custom2='Y' THEN '1'
                                                              WHEN t1.custom_Field_Custom2<>'Y' THEN '0'
                                                          END
WHERE t1.customerId IS NOT NULL
  AND customers.accessKey='P';

 /*Update the email adress from customer table if available other wise using affilaite data as email address*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
SET order_information_details_test.affiliateEmailAddress= CASE
                                                              WHEN (customers.emailAddress IS NOT NULL
                                                                    OR customers.emailAddress<>'') THEN customers.emailAddress
                                                              WHEN (order_information_details_test.affiliateData IS NOT NULL
                                                                    AND (TRIM(order_information_details_test.affiliateData) REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\.[a-zA-Z]{2,4}$')=1) THEN order_information_details_test.affiliateData
                                                              ELSE NULL
                                                          END;

 /*Update the affilaite name as either company name or full name*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
SET order_information_details_test.affiliateName= CASE
                                                      WHEN customers.companyName IS NULL THEN CONCAT(customers.firstName,' ',customers.lastName)
                                                      ELSE customers.companyName
                                                  END;

 /*Calculate the affiliate payment based on the value of custom_Field_Custom1*/
UPDATE order_information_details_test
INNER JOIN db82494_confirmations.customers ON (order_information_details_test.affiliateID=customers.customerId)
SET order_information_details_test.affiliatePayment= CASE
                                                         WHEN IsNumeric(customers.custom_Field_Custom1)='1' THEN (customers.custom_Field_Custom1*order_information_details_test.totalPrice)
                                                         ELSE 0
                                                     END;

 /*if branding id is present then update to 1 else 0*/
UPDATE order_information_details_test
SET affiliateBranding= CASE
                           WHEN affiliateBrandingID IS NOT NULL THEN '1'
                           ELSE 0
                       END;

 /*Load Affiliate Function Ends*/

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

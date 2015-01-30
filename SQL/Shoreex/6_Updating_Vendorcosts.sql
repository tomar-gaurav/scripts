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

 Date: 01/03/2015 20:53:19 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Procedure structure for `6_Updating_Vendorcosts`
-- ----------------------------
DROP PROCEDURE IF EXISTS `6_Updating_Vendorcosts`;
delimiter ;;
CREATE DEFINER = `kettle`@`localhost` PROCEDURE `6_Updating_Vendorcosts`()
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

/*
This is the 6th file in the procedure
This file computed the the vendor cost for each of the booked tours*/ /*
10. Convert sub queries into temporary table and use with select queries to get vendor cost
20. Compute vendor cost again if the product is in inventory risk products
30. Update vendorCost for already booked tours present in orer_information_details
40. Update total price and affiliate payment
*/ /*Vendor cost when package id is not null*/ /*Below queries computes the vendor costs since there were two corelated subqueries, they were saved into two temporary tables
and were joined with the main query to provided the required result*/ /*Get package_port_id from package_ports*/
DROP TABLE IF EXISTS `innertemp` ;


CREATE
TEMPORARY TABLE `innertemp`
SELECT order_information_details_test.orderDetailID AS innodid,
       order_information_details_test.packageID,
       package_ports.package_port_id
FROM db82494_confirmations.order_details AS child_order_details,
     db82494_confirmations.order_details AS parent_order_details,
     db82494_confirmations.packages,
     db82494_confirmations.package_ports ,
     order_information_details_test
WHERE child_order_details.orderDetailID = order_information_details_test.orderDetailID
  AND parent_order_details.productCode LIKE 'PCKG%'
  AND parent_order_details.orderID = child_order_details.orderID
  AND parent_order_details.isKitID = child_order_details.kitID
  AND packages.productCode = parent_order_details.productCode
  AND packages.packageID = package_ports.packageID
  AND package_ports.port_productCode = child_order_details.productCode
  AND package_ports.packageId = order_information_details_test.packageID
  AND order_information_details_test.packageID IS NOT NULL;

 /*Create another subquery*/ /*outertemp temporary table has a corelated subquery whoes data was saved in innertemp temporary table*/
DROP TABLE IF EXISTS `outertemp`;


CREATE
TEMPORARY TABLE `outertemp`
SELECT package_port_to_calculate.innodid outodid,
       package_ports.package_port_id,
       package_ports.individuals_per_unit,
       sum(child_order_details.quantity) AS total_quantity,
       ceil(sum(child_order_details.quantity) / package_ports.individuals_per_unit) AS total_units,
       ceil(sum(child_order_details.quantity) / ceil(sum(child_order_details.quantity) / package_ports.individuals_per_unit)) AS quantity_for_cost
FROM db82494_confirmations.order_details AS child_order_details,
     db82494_confirmations.order_details AS parent_order_details,
     db82494_confirmations.packages,
     db82494_confirmations.package_ports,
     innertemp AS package_port_to_calculate
WHERE parent_order_details.productCode LIKE 'PCKG%'
  AND parent_order_details.orderID = child_order_details.orderID
  AND parent_order_details.isKitID = child_order_details.kitID
  AND packages.productCode = parent_order_details.productCode
  AND packages.packageID = package_ports.packageID
  AND packages.packageId = package_port_to_calculate.packageID
  AND package_ports.port_productCode = child_order_details.productCode
  AND package_ports.package_port_id = package_port_to_calculate.package_port_id
GROUP BY package_port_to_calculate.innodid,
         package_ports.package_port_id,
         package_ports.individuals_per_unit;

 /*Update the vendor cost by joining with temporary tables for records where package id is not null*/
UPDATE order_information_details_test
SET order_information_details_test.vendorCost=
  (SELECT package_costs.cost AS vendor_Price
   FROM outertemp AS ordered_packages,
        db82494_confirmations.package_costs,
        db82494_confirmations.orders,
        db82494_confirmations.order_details
   WHERE package_costs.package_port_id = ordered_packages.package_port_id
     AND orders.orderID = order_details.orderID
     AND orders.orderStatus != 'Cancelled'
     AND orders.orderStatus != 'Payment Declined'
     AND order_details.orderDetailID = order_information_details_test.orderDetailID
     AND ordered_packages.quantity_for_cost >= ifnull(package_costs.quantity_lower, ordered_packages.quantity_for_cost)
     AND ordered_packages.quantity_for_cost <= ifnull(package_costs.quantity_upper, ordered_packages.quantity_for_cost)
     AND ordered_packages.outodid=order_information_details_test.orderDetailID
     AND order_information_details_test.packageID IS NOT NULL
   GROUP BY ordered_packages.outodid);

 /*Update Vendor costs when package id is null*/
UPDATE order_information_details_test
SET vendorCost =
  (SELECT sum(ifnull(vendor_Price, 0.0)) + sum(ifnull(`options`.vendorPriceDiff, 0.0)) AS vendor_Price
   FROM db82494_confirmations.order_details,
        db82494_confirmations.order_details_options_parsed,
        db82494_confirmations.`options`
   WHERE order_details.orderDetailID = order_details_options_parsed.orderDetailID
     AND order_details_options_parsed.optionID = `options`.iD
     AND order_details.orderDetailID = order_information_details_test.orderDetailID
     AND order_information_details_test.packageID IS NULL
   GROUP BY order_details.orderDetailID)
WHERE order_information_details_test.packageID IS NULL;

 /*if response is penalty then update the vendor cost to 0*/
UPDATE order_information_details_test
SET vendorCost= CASE
                    WHEN (loadLastResponse<>'1'
                          AND lastResponse='P') THEN 0
                    ELSE vendorCost*quantity
                END;

 /*Update discount row and check stub on the basis of whether the productcode is discount or not*/ /*no checkstub for discount row*/
UPDATE order_information_details_test
SET discountRow= CASE
                     WHEN productCode='dsc' THEN 1
                     ELSE 0
                 END,
                 checkStub= CASE
                                WHEN productCode='dsc' THEN NULL
                                ELSE CASE
                                         WHEN tourDate IS NULL THEN ''
                                         ELSE CONCAT(lastName,' - ',DATE_FORMAT(DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(tourDate))),'%c/%d/%Y'))
                                     END
                            END;

UPDATE order_information_details_test SET orderDetailID=CONCAT('-', orderID) WHERE order_information_details_test.productCode='DSC';

 /*Find and update inventoryRiskProducts=1 if the product exists in product_tours_mapping table so that we can use this flag to separate tours from the ones that do not exist in product_tours_mapping*/
UPDATE order_information_details_test
SET order_information_details_test.inventoryRiskProducts=
  (SELECT 1
   FROM db82494_confirmations.product_tour_mappings
   WHERE order_information_details_test.productCode=product_tour_mappings.productCode
   GROUP BY order_information_details_test.orderDetailID);

 /*If product is in risk inventory, update vendor costs*/ /*A table is created for storing details of the booking of the same tours as the the one is inventory risk*/ /*this table will consist the tours on the same date/time and same ship from the current orders and that are pre-computed*/
DROP TABLE IF EXISTS inv_risk;


CREATE TABLE `inv_risk` (
  `od` int(11) NOT NULL,
  `orderDetailID` int(11) NOT NULL,
  `number_of_adults` int(11) DEFAULT '0',
  `number_of_children` int(11) DEFAULT '0',
  `vendorCost` decimal(10,4) DEFAULT NULL,
  `productCode` varchar(30) NOT NULL,
  `number_of_individual` int(11) DEFAULT NULL,
  `maxperdeparture` int(11) DEFAULT NULL,
  `unitvendorcost` decimal(50,4) DEFAULT NULL,
  UNIQUE KEY `idx_orderdetailcomb` (`od`,`orderDetailID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



 /*Insert details for previous tours from precomputed order_information_details_test*/
INSERT INTO inv_risk
SELECT order_information_details_test.orderDetailID AS od,
       order_information_details.orderDetailID,
       order_information_details.number_of_adults,
       order_information_details.number_of_children,
       order_information_details.vendorCost,
       order_information_details.productCode,
       NULL,
       NULL,
       NULL
FROM db82494_confirmations.order_information_details,
     order_information_details_test
WHERE order_information_details.productCode IN
    (SELECT p2.productCode
     FROM db82494_confirmations.product_tour_mappings p1
     INNER JOIN db82494_confirmations.product_tour_mappings p2 ON (p1.masterTourID=p2.masterTourID)
     WHERE p1.productCode = order_information_details_test.productCode)
  AND order_information_details.tourDate =FROM_UNIXTIME(UNIX_TIMESTAMP(order_information_details_test.tourDate))
  AND order_information_details.tourTime = order_information_details_test.tourTime
  AND order_information_details.orderDetailID != order_information_details_test.orderDetailID
  AND order_information_details.statusColor ='G'  and NOT EXISTS (SELECT 1 from order_information_details_test WHERE order_information_details.orderDetailID=order_information_details_test.orderDetailID)
GROUP BY order_information_details_test.orderDetailID,
         order_information_details.orderDetailID
ORDER BY order_information_details_test.orderDetailID;
COMMIT;


INSERT INTO inv_risk
SELECT t2.orderDetailID AS od,
       t1.orderDetailID,
       t1.number_of_adults,
       t1.number_of_children,
       t1.vendorCost,
       t1.productCode,
       NULL,
       NULL,
       NULL
FROM order_information_details_test t1,
     order_information_details_test t2
WHERE t1.productCode IN
    (SELECT p2.productCode
     FROM db82494_confirmations.product_tour_mappings p1
     INNER JOIN db82494_confirmations.product_tour_mappings p2 ON (p1.masterTourID=p2.masterTourID)
     WHERE p1.productCode = t2.productCode)
  AND t1.tourDate =FROM_UNIXTIME(UNIX_TIMESTAMP(t2.tourDate))
  AND t1.tourTime = t2.tourTime
  AND t1.orderDetailID != t2.orderDetailID
  AND t1.statusColor ='G'
GROUP BY t2.orderDetailID,
         t1.orderDetailID
ORDER BY t2.orderDetailID;

 /*Insert details for tours from the current orders in case the current statusColor of order is green*/
INSERT INTO inv_risk
SELECT DISTINCT order_information_details_test.orderDetailID,
                order_information_details_test.orderDetailID,
                order_information_details_test.number_of_adults,
                order_information_details_test.number_of_children,
                order_information_details_test.vendorCost,
                order_information_details_test.productCode,
                NULL,
                NULL,
                NULL
FROM order_information_details_test INNER JOIN db82494_confirmations.product_tour_mappings on (order_information_details_test.productCode=product_tour_mappings.productCode)
WHERE order_information_details_test.statusColor='G' ;


 /*Update the max number of persons allowed on ship*/
UPDATE inv_risk
SET maxperdeparture=
  (SELECT inventory_tours.maxPerDeparture
   FROM db82494_confirmations.inventory_tours
   INNER JOIN db82494_confirmations.product_tour_mappings ON (inventory_tours.id = product_tour_mappings.masterTourID)
   WHERE (product_tour_mappings.productCode=inv_risk.productCode)
   GROUP BY od);

 /*Update total No. of individual per orderdetailid*/
UPDATE inv_risk a
INNER JOIN
  (SELECT od,
          SUM(number_of_adults)+SUM(number_of_children) totalStock
   FROM inv_risk
   GROUP BY od) b ON a.od = b.od
SET number_of_individual=totalstock;

 /*Calculate and update vendor cost per person for total no of individual more than no of persons allowed on ship*/
UPDATE inv_risk
SET unitvendorcost=
  (SELECT SUM(vendor_costs.costPerIndividual)/COUNT(*)
   FROM db82494_confirmations.inventory_tours
   INNER JOIN db82494_confirmations.vendor_costs ON (inventory_tours.id = vendor_costs.masterTourID)
   INNER JOIN db82494_confirmations.product_tour_mappings ON (inventory_tours.id = product_tour_mappings.masterTourID)
   WHERE product_tour_mappings.productCode= inv_risk.productCode
     AND vendor_costs.totalBooked IN (CEIL(inv_risk.number_of_individual/CEIL(inv_risk.number_of_individual/inv_risk.maxPerDeparture)),
                                      FLOOR(inv_risk.number_of_individual/CEIL(inv_risk.number_of_individual/inv_risk.maxPerDeparture)))
   GROUP BY inv_risk.od,
            inv_risk.productCode)
WHERE inv_risk.number_of_individual>inv_risk.maxperdeparture;

 /*Calculate and update vendor cost per person for total no of individual less or equal to no of persons allowed on ship*/
UPDATE inv_risk
SET unitvendorcost=
  (SELECT vendor_costs.costPerIndividual
   FROM db82494_confirmations.inventory_tours
   INNER JOIN db82494_confirmations.vendor_costs ON (inventory_tours.id = vendor_costs.masterTourID)
   INNER JOIN db82494_confirmations.product_tour_mappings ON (inventory_tours.id = product_tour_mappings.masterTourID)
   WHERE product_tour_mappings.productCode= inv_risk.productCode
     AND vendor_costs.totalBooked = inv_risk.number_of_individual
   GROUP BY inv_risk.od)
WHERE inv_risk.number_of_individual <= inv_risk.maxperdeparture;

 /*Calculate and update vendor cost by multiplying unitvendorcost and total no of individual*/
/*UPDATE inv_risk t1
INNER JOIN inv_risk t2 ON (t1.orderDetailID=t2.orderDetailID
                           AND t1.od=t2.od)
SET t1.vendorCost= ((t1.number_of_adults+t1.number_of_children)*t1.unitvendorcost)
WHERE t1.od!=t2.orderDetailID;*/

 /*Calculate and update vendor costby multiplying unitvendorcost and total no of individual*/
/*UPDATE inv_risk t1
INNER JOIN inv_risk t2 ON (t1.orderDetailID=t2.orderDetailID
                           AND t1.od=t2.od)
SET t1.vendorCost= ((t1.number_of_adults+t1.number_of_children)*t1.unitvendorcost)
WHERE t1.od=t2.orderDetailID;*/
UPDATE inv_risk SET vendorCost=((number_of_adults+number_of_children)*unitvendorcost);

 /*Update vendor cost for present tours that are in staging table*/
UPDATE order_information_details_test
INNER JOIN inv_risk ON (order_information_details_test.orderDetailID=inv_risk.od)
SET order_information_details_test.vendorCost=inv_risk.vendorCost
WHERE inv_risk.od=inv_risk.orderDetailID;

 /*Update vendor cost for already booked tours present in orer_information_details*/
/*UPDATE db82494_confirmations.order_information_details
INNER JOIN inv_risk ON (order_information_details.orderDetailID=inv_risk.orderDetailID)
SET order_information_details.vendorCost=inv_risk.vendorCost;*/

 /*Update total price and affiliate payment*/
UPDATE order_information_details_test t2
INNER JOIN
  (SELECT orderID,
          vendorCost,
          packageID,
          sum(vendorCost) sam
                          /*orderInformationID*/
   FROM order_information_details_test
   WHERE packageID IS NOT NULL
   GROUP BY orderID) AS t1 ON (t2.orderID=t1.orderID)
SET affiliatePayment=ROUND(t2.affiliatePayment*(t2.vendorCost/sam),2),
                     totalPrice=ROUND(t2.totalPrice*(t2.vendorCost/sam),2)
WHERE t2.packageID IS NOT NULL;



UPDATE order_information_details_test t1
LEFT JOIN order_information_details_test t2 ON (t1.orderID=t2.orderID)
SET t1.statusColor='G'
WHERE t1.productCode='DSC'
  AND t2.productCode<>'DSC'
  AND t2.statusColor IN ('G',
                         'Y',
                         'O',
                         'B');

 COMMIT;


UPDATE order_information_details_test
SET statusColor='R'
WHERE statusColor<>'G'
  AND discountRow='1';

 COMMIT;


UPDATE order_information_details_test
SET vendorCost='0'
WHERE productCode='DSC'
  AND vendorCost IS NULL;

 COMMIT;


UPDATE order_information_details_test t1
INNER JOIN
  (SELECT order_information_details_test.orderID,
          SUM(order_information_details_test.holdEmailsForOrder) HOLD
   FROM order_information_details_test
   GROUP BY orderID HAVING HOLD > 0) t2 ON (t1.orderID=t2.orderID)
SET t1.holdEmailsForOrder='1';

COMMIT;

UPDATE order_information_details_test SET tourTime='1:00 AM' WHERE tourDate='1970-01-01 00:00:00' and tourTime='5:30 AM';
COMMIT;

UPDATE order_information_details_test SET checkStub=null WHERE checkStub='';
COMMIT;

END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

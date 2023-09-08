--TRIM WHITESPACE FROM PRODUCTS
CREATE VIEW products_cln as
SELECT p.sku,
       TRIM(BOTH FROM p.name) AS name_cln,
       p.orderedquantity,
       p.stocklevel,
       p.restockingleadtime,
       p.sentimentscore,
       p.sentimentmagnitude
FROM products p;


-- VIEW for PRODUCTS_CATEGORIES
-- -- 1. trim name
-----2. split path into categories.
drop view if exists products_categories;
CREATE view products_categories as
SELECT
        p.sku,
        trim(both FROM name) as name_cln,
       orderedquantity,
       stocklevel,
       restockingleadtime,
       sentimentscore,
       c.Cat_level1 as CategoryL1,
       c.Cat_level2 as CategoryL2,
       c.Cat_level3 as CategoryL3
    FROM
        products P
JOIN productcategories_cln C
ON  p.sku=c.productsku;
SELECT * FROM products_categories;
--------


-- PRODUCT CATEGORIES - split into ARRAY and then create new columns
DROP VIEW IF EXISTS productcategories_cln2;
CREATE VIEW productcategories_cln2 as
SELECT  productsku,
        v2productcategory,
        CASE
                WHEN v2productcategory='${escCatTitle}' then NULL
                WHEN v2productcategory='(not set)' then null
                else v2productcategory
                END AS productCategory_fix,
       length(v2productcategory) - length(replace(v2productcategory,'/','')) as CatDepth,
       categoriesarray[1] as Cat_level1,
       categoriesarray[2] as Cat_level2,
       categoriesarray[3] as Cat_level3,
       categoriesarray[4] as Cat_level4
FROM (
    SELECT  DISTINCT productsku,
            v2productcategory,
            string_to_array(v2productcategory,'/') as categoriesarray
    FROM all_sessions
     ) as CategoryArray;

-----TEST THE CATEGORY VIEW
SELECT   productsku,
       v2productcategory,
       CatDepth,
       Cat_level1,
       Cat_level2,
       Cat_level3
FROM productcategories_cln2;


-- SUMMARY VIEW FROM ANALYTICS
drop view if exists analytics_summary2;
CREATE VIEW  analytics_summary2 as
SELECT a.visitid,
       to_char(avg(unit_price),'FM999,999,999') as AVG_VisitPrice,
       to_char(max(unit_price),'FM999,999,999') as MAX_visitprice,
       to_char(min(unit_price),'FM999,999,999') as MIN_visitprice
FROM analytics as A
GROUP BY a.visitid;
SELECT * FROM analytics_summary2;


--ANALYTICS_CLN
--change data type fo units sold (even though view not used for analysis)
DROP VIEW IF EXISTS analytics_cln;
CREATE VIEW  analytics_cln as
SELECT *,
   to_number(units_sold,'9999') as units_sold_num
FROM analytics as A
WHERE units_sold is not null and revenue is not null;
SELECT * FROM analytics_cln;

--SALES_REPORT_CLN
CREATE OR REPLACE VIEW sales_report_cln as
SELECT productsku,
       total_ordered,
       trim (both FROM name),
       stocklevel,
       restockingleadtime,
       sentimentscore,
       sentimentmagnitude,
       ratio
FROM sales_report;

-- VIEW for SALES_BY_SKU_CLN
CREATE OR REPLACE VIEW sales_by_sku_cln as
SELECT *
FROM sales_by_sku;

-- VIEW for ALL_SESSIONS_CLN
-- Create a primary key and select only distinct records.
DROP VIEW IF EXISTS all_session_cln;
CREATE OR REPLACE VIEW all_session_cln as
SELECT DISTINCT (concat(visitid,'-',date,'-',time)) as primarykey,
        visitid,
       time,
       channelgrouping,
       country,
       -- City name - remove junk
       CASE
            when city = '(not set)' then 'N/A'
            When city = 'not available in demo dataset' then 'N/A'
            else city
        end as city_fix,
       transactions,
       v2productcategory,
       timeonsite,
       pageviews,
       sessionqualitydim,
       date,
       type,
       productrefundamount,
       productquantity,
       productprice,
       productrevenue,
       productsku,
       productvariant,
       currencycode,
       itemquantity,
       itemrevenue,
       --- Convert Transaction revenue from string to number
       to_number(totaltransactionrevenue,'FM999,999,999') as tot_Txn_Revenue,
       transactionid,
       pagetitle,
       searchkeyword,
       pagepathlevel1,
       ecommerceaction_type,
       ecommerceaction_step,
       "eCommerceAction_option"
FROM all_sessions;
SELECT * FROM all_session_cln;

---- VIEW of SESSIONS where Item Qty >=1
-- dropped V2category as it will be joined to [product_categories]
-- dropped [product refund amount]
-- dropped [product variant]
-- dropped [search keyword]
DROP VIEW IF EXISTS all_session_transactions;
CREATE OR REPLACE VIEW all_session_transactions as
SELECT DISTINCT (concat(visitid,'-',date,'-',time)) as primarykey,
        visitid,
       time,
       channelgrouping,
       country,
       -- City name - remove junk
       CASE
            when city = '(not set)' then 'N/A'
            When city = 'not available in demo dataset' then 'N/A'
            else city
        end as city_fix,
       transactions,
       timeonsite,
       pageviews,
       date,
       type,
       --- Convert Product Quantity from string to number
       CAST(productquantity as numeric) as productquantity,
       productprice,
       productrevenue,
       productsku,
       --- Convert item Quantity from string to number
        to_number(itemquantity,'FM999,999,999') as item_quantity,
       --- Convert item REvenue from string to number
        to_number(itemrevenue,'FM999,999,999') as item_revenue,
       --- Convert Transaction revenue from string to number
       to_number(totaltransactionrevenue,'FM999,999,999') as tot_Txn_Revenue,
       transactionid,
       pagetitle,
       pagepathlevel1,
       ecommerceaction_type,
       ecommerceaction_step,
       "eCommerceAction_option"
FROM all_session_clean
WHERE productquantity is not null;
SELECT * FROM all_session_transactions;




------ JOIN ALL_SESSIONS AND ANALYTICS
-- Not much purpose in doing this given Analytics table has limited value.
SELECT A.visitid_cln as A_visitID,
       S.primarykey as S_PrimaryKey,
       a.visitnumber,
       visitstarttime,
       A.date,
       fullvisitorid,
       userid,
       A.channelgrouping,
       socialengagementtype,
       units_sold,
       A.pageviews,
       A.timeonsite,
       bounces,
       revenue,
       unit_price,
       s.visitid,
       time,
       S.channelgrouping,
       country,
       city_fix,
       totaltransactionrevenue,
       transactions,
       S.timeonsite,
       S.pageviews,
       sessionqualitydim,
       S.date,
       type,
       productrefundamount,
       productquantity,
       productprice,
       productrevenue,
       S.productsku,
       productvariant,
       currencycode,
       itemquantity,
       itemrevenue,
       transactionrevenue,
       transactionid,
       pagetitle,
       searchkeyword,
       pagepathlevel1,
       ecommerceaction_type,
       ecommerceaction_step,
       "eCommerceAction_option"
FROM analytics_cln A
join all_session_cln S
on A.visitid_cln=S.visitid


------------
SELECT productsku,
       v2productname,
       count(productsku) count_transactions
FROM orphaned_products
GROUP BY  productsku, v2productname
order by count(productsku) desc

-- 13,101 record on inner join

-- ---- compare product names to verify correctness
-- JOIN PRODUCTS::ALL_SESSIONS
DROP VIEW IF EXISTS  product_name_compare;
CREATE VIEW product_name_compare as
SELECT m.product_sku as MasterSKU,
       a.productsku as AllsessionSKU,
       p.sku as ProductSKU,
       p.name_cln as Product_Name,
       a.v2productname as Session_Name
FROM master_sku M
join all_session_clean A
on m.product_sku=a.productsku
join products_cln P
on m.product_sku=p.sku;
SELECT * FROM product_name_compare


-- -- JOIN PRODUCTS AND SALES_REPORT
SELECT p.sku,
       p.name_cln
FROM products_cln P
join sales_report_cln S
on p.sku = s.productsku

-- -- JOIN ALL_SESSIONS AND SALES_REPORT
SELECT p.sku,
       p.name_cln
FROM products_cln P
join all_session_cln S
on p.sku = s.productsku

--
------ JOIN for SALES REPORTS
SELECT productsku,
       R.total_ordered as Sales_report_TOTAL,
       S.total_ordered as Sales_by_Sku_total,

       stocklevel,
       restockingleadtime,
       sentimentscore,
       sentimentmagnitude,
       ratio,
       product_sku

FROM sales_report_cln R
join sales_by_sku_cln S
on R.productsku = S.product_sku
WHERE r.total_ordered!=s.total_ordered

---- MASTER LIST OF ALL SKU: UNION of SaleReport and SalesbySKU
DROP VIEW IF EXISTS master_sku;
CREATE OR REPLACE VIEW master_sku as
SELECT product_sku
FROM sales_by_sku
    union
SELECT productsku
FROM sales_report_cln
--     union
-- SELECT sku
-- FROM products;








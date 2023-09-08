------------------------------------------
---PRIMARY KEYS -----

--PRODUCTS TABLE
SELECT sku,count(sku)
FROM products
GROUP BY name,sku;

--ALL_SESSIONS TABLE
--- visitID is NOT a primary key
-- what is composition of this 'key'
SELECT visitid,count(visitid) as visitidcount
FROM all_sessions
GROUP BY visitid
HAVING count(visitid) >1
order by visitidcount desc

---ANALYTICS TABLE:
-- Evaluate total records and which are likely Primary keys using 'id' columns.
-- Evaluate which columns can be dropped given immaterial contribution.
-- Insight: No primary key and all of fields have minimal contribution to value.
-- units sold has no direct relation to product/sku
-- Outcome: Do not include the table in further analysis.
SELECT DISTINCT count(*) as Total_Count,
                count (distinct visitid) as distinct_visitid,
                count(distinct fullvisitorid) as distinct_fullvisitid,
                count(distinct socialengagementtype) as distinct_socialtype,
                count(userid) as UserID_count,
                count(units_sold) as unit_sold,
                count(revenue) as txn_w_revenue
FROM analytics
ORDER BY Total_Count desc;

------------------------------------------
--- ORPHANED RECORDS: ---------

--IDENTIFY THE SKU that are not included on the SALES by SKU REPORT
-- but ARE listed in the SALES_REPORT
DROP VIEW IF EXISTS sku_missing_frm_salesbyskurpt
CREATE VIEW sku_missing_frm_salesbyskurpt as
SELECT M.product_sku as MASTER_LIST,
       S.product_sku as Sales_by_SKU,
       R.productsku as Sales_Report
FROM master_sku M
LEFT JOIN sales_by_sku S
on M.product_sku=s.product_sku
LEFT JOIN sales_report_cln R
on M.product_sku = R.productsku
WHERE r.productsku is null;
SELECT * FROM sku_missing_frm_salesbyskurpt;

--  ORPHANED PRODUCTS- JOIN PRODUCTS AND ALL_SESSIONS
-- 2,033 txn on [all_sessions] that do not have a corresponding [product]
CREATE VIEW orphaned_products as
    SELECT a.date,
       a.visitid,
       a.productsku,
       a.v2productname,
       p.sku,
       p.name_cln
FROM all_sessions A
FULL JOIN products_cln P
On a.productsku = P.sku
WHERE name_cln is null;
SELECT *
FROM orphaned_products;

 -- ORPHANED ANALYTICS
-- [analytics] that do not appear on [all sessions_cln] using visitID,WHERE there IS a sale.
DROP VIEW IF EXISTS orphaned_analytics;
create view orphaned_analytics as
SELECT s.visitid all_session_id,
       a.visitid,
       a.units_sold,
       a.unit_price,
           a.channelgrouping,
           a.socialengagementtype,
           a.date,
           a.timeonsite,
           a.pageviews
FROM all_session_clean AS s
full join analytics_cln a
on s.visitid = a.visitid
WHERE s.visitid is null and units_sold is not null;

SELECT * FROM orphaned_analytics

------------------------------------------
-- VERIFY AN DUPLICATION IN SKU FOR THE TWO REPORTS:
--SALES by SKU
SELECT product_sku,count(product_sku) as countSKU
FROM sales_by_sku
GROUP BY product_sku
HAVING count(product_sku) >1
order by countSKU desc;

--SALES REPORT
SELECT productsku,count(productsku) as countSKU
FROM sales_report
GROUP BY productsku
HAVING count(productsku) >1
order by countSKU desc;

-- VERIFY NAME TRIM ON PRODUCTS_CLN VIEW
SELECT
       PC.name_cln,
       length(name) as no_trim,
       length(trim(both FROM name)) as trim
FROM
    products P
JOIN products_cln PC ON PC.sku=P.sku
WHERE  length(name) != length(trim(both FROM name));
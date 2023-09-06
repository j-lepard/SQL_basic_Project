select *
from sales_report
where "productSKU" = 'GGOEGAAX0081'

select *
from sales_by_sku
where "productSKU" = 'GGOEGAAX0081'

select *
from products P
join sales_by_sku S on P.sku=S."productSKU"
where p.sku='GGOEGAAX0081'

SELECT table_name, column_name
FROM information_schema.columns
WHERE table_name = 'your_table_name'
AND column_name <> LOWER(column_name);

---CHANGE THE COLUMN/Field Names
ALTER TABLE your_table_name
RENAME COLUMN "productSKU" TO productsku;

---Check count of primary key items
--PRODUCTS TABLE
select sku,count(sku)
from products
group by name,sku

--ALL_SESSIONS TABLE
select visitid,count(visitid) as visitidcount
from all_sessions
group by visitid
having count(visitid) >1
order by visitidcount desc

--Analytics
select visitid,count(visitid) as visitidcount
from analytics
group by visitid
having count(visitid) >1
order by visitidcount desc

--SALES by SKU
select product_sku,count(product_sku) as countSKU
from sales_by_sku
group by product_sku
having count(product_sku) >1
order by countSKU desc;

--SALES REPORT
select productsku,count(productsku) as countSKU
from sales_report
group by productsku
having count(productsku) >1
order by countSKU desc

--TRIM WHITESPACE from PRODUCTS
select name,
       trim(both from name),
       length(name) as no_trim,
       length(trim(both from name)) as trim
    from
        products;

-- VIEW for PRODUCTS_CLN
-- -- Add additional components to this View as required
drop view if exists products_cln cascade;
create or replace view products_cln as
select
        p.sku,
        trim(both from name) as name_cln,
       orderedquantity,
       stocklevel,
       restockingleadtime,
       sentimentscore,
       sentimentmagnitude,
       c.Cat_level1 as CategoryL1,
       c.Cat_level2 as CategoryL2,
       c.Cat_level3 as CategoryL3
    from
        products P
join productcategories_cln C
on p.sku=c.sku;
select * from products_cln
--------

select sku,
       name_cln,
       orderedquantity,
       stocklevel,
       restockingleadtime,
       sentimentscore,
       sentimentmagnitude,
       ProductCategory --Todo: product categories needs to be broken down.
from products_cln

-- VIEW PRODUCT CATEGORIES - split into ARRAY and then create new columns
drop view if exists productcategories_cln;
create view productcategories_cln as
SELECT  sku,
        name_cln,
        CASE
                WHEN ProductCategory='${escCatTitle}' then NULL
                WHEN ProductCategory='(not set)' then null
                else ProductCategory
                END AS productCategory_fix,
       length(ProductCategory) - length(replace(productcategory,'/','')) as CatDepth,
       categoriesarray[1] as Cat_level1,
       categoriesarray[2] as Cat_level2,
       categoriesarray[3] as Cat_level3,
       categoriesarray[4] as Cat_level4
from (
    select  sku,
            name_cln,
            productcategory,
            string_to_array(productcategory,'/') as categoriesarray
    from products_cln
     ) as CategoryArray;

-- VIEW for ANALYTICS_CLN
-- Select Distinct VisitID to remove duplicates
drop table if exists unique_visits;
create temp table unique_visits as
select distinct visitid
from analytics
select * from unique_visits;

-- CREATE SUMMARY VIEW FROM ANALYTICS
drop view if exists analytics_summary2;
create view  analytics_summary2 as
SELECT a.visitid,
       to_char(avg(unit_price),'FM999,999,999') as AVG_VisitPrice,
       to_char(max(unit_price),'FM999,999,999') as MAX_visitprice,
       to_char(min(unit_price),'FM999,999,999') as MIN_visitprice
FROM analytics as A
group by a.visitid;
select * from analytics_summary2;

--VIEW FOR ANALYTICS_CLN
    --change data type fo units sold
    -- REMOVE any record where the units sold is Null AND the Revenue is NULL.

drop view if exists analytics_cln;
create view  analytics_cln as
SELECT *,
   to_number(units_sold,'9999') as units_sold_num
FROM analytics as A
where units_sold is not null and revenue is not null
select * from analytics_cln;

-- VIEW for SALES_REPORT_CLN
create or replace view sales_report_cln as
select productsku,
       total_ordered,
       trim (both from name),
       stocklevel,
       restockingleadtime,
       sentimentscore,
       sentimentmagnitude,
       ratio
from sales_report;

-- VIEW for SALES_BY_SKU_CLN
create or replace view sales_by_sku_cln as
select *
from sales_by_sku;

-- VIEW for ALL_SESSIONS_CLN
drop view if exists all_session_cln
create or replace view all_session_cln as
select distinct (concat(visitid,'-',date,'-',time)) as primarykey,
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
       to_number(totaltransactionrevenue,'FM999,999,999') as tot_Txn_Revenue,
       transactionid,
       pagetitle,
       searchkeyword,
       pagepathlevel1,
       ecommerceaction_type,
       ecommerceaction_step,
       "eCommerceAction_option"
from all_sessions;
select * from all_session_cln;

------ JOIN ALL_SESSIONS AND ANALYTICS
select A.visitid_cln as A_visitID,
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
from analytics_cln A
join all_session_cln S
on A.visitid_cln=S.visitid


 -- ORPHANED ANALYTICS
-- [analytics] that do not appear on [all sessions_cln] using visitID,where there IS a sale.
drop view if exists orphaned_analytics
create view orphaned_analytics as
select s.visitid all_session_id,
       a.visitid_cln,
       a.units_sold,
       a.unit_price,
           a.channelgrouping,
           a.socialengagementtype,
           a.date,
           a.timeonsite,
           a.pageviews
from all_session_cln AS s
full join analytics_cln a
on s.visitid = a.visitid_cln
where s.visitid is null and units_sold is not null;

select * from orphaned_analytics
---------


-- JOIN PRODUCTS AND ALL_SESSIONS [ORPHANED PRODUCTS]
-- 2,033 txn on [all_sessions] that do not have a corresponding [product]
create view orphaned_products as
    select a.date,
       a.visitid,
       a.productsku,
       a.v2productname,
       p.sku,
       p.name_cln
from all_sessions A
full join products_cln P
On a.productsku = P.sku
where name_cln is null;

select productsku,
       v2productname,
       count(productsku) count_transactions
from orphaned_products
group by  productsku, v2productname
order by count(productsku) desc

-- 13,101 record on inner join

-- ---- JOIN PRODUCTS:ALL_SESSIONS to compare product names
-- -- Query no longer works because the V2name was dropped from All_sessions.
-- drop view if exists  product_name_compare
-- create view product_name_compare as
-- select product_sku as MasterSKU,
--        productsku as AllsessionSKU,
--        v2productname as v2name_from_allsession,
--        p.name_cln as name_from_products
-- from master_sku M
-- join all_session_cln A
-- on m.product_sku=a.productsku
-- join products_cln P
-- on m.product_sku=p.sku;
-- select * from product_name_compare


-- -- JOIN PRODUCTS AND SALES_REPORT
Select p.sku,
       p.name_cln
from products_cln P
join sales_report_cln S
on p.sku = s.productsku

-- -- JOIN ALL_SESSIONS AND SALES_REPORT
Select p.sku,
       p.name_cln
from products_cln P
join all_session_cln S
on p.sku = s.productsku

--
------ JOIN for SALES REPORTS
select productsku,
       R.total_ordered as Sales_report_TOTAL,
       S.total_ordered as Sales_by_Sku_total,

       stocklevel,
       restockingleadtime,
       sentimentscore,
       sentimentmagnitude,
       ratio,
       product_sku

from sales_report_cln R
join sales_by_sku_cln S
on R.productsku = S.product_sku
where r.total_ordered!=s.total_ordered

---- MASTER LIST OF ALL SKU: UNION of SaleReport and SalesbySKU
DROP VIEW IF EXISTS master_sku;
create or replace view master_sku as
select product_sku
from sales_by_sku
    union
select productsku
from sales_report_cln
--     union
-- select sku
-- from products;

--IDENTIFY THE SKU that are not included on the SALES by SKU REPORT
-- but ARE listed in the SALES_REPORT
drop view if exists sku_missing_frm_salesbyskurpt
create view sku_missing_frm_salesbyskurpt as
select M.product_sku as MASTER_LIST,
       S.product_sku as Sales_by_SKU,
       R.productsku as Sales_Report
from master_sku M
left join sales_by_sku S
on M.product_sku=s.product_sku
left join sales_report_cln R
on M.product_sku = R.productsku
where r.productsku is null;
select * from sku_missing_frm_salesbyskurpt


--- CREATE CATEGORY TABLE:
-- create table product_category
-- (id int,
-- parent int,
-- description varchar(15))

-- How many duplicate visitid are on All_session
select visitid,count(visitid)
from all_session_cln
group by visitid
having count(visitid) >1


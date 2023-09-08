-- Question 1

SELECT channelgrouping,
       COUNT(productquantity) as transaction_count,
       SUM(productquantity) as product_qty_total

FROM all_session_transactions
GROUP BY channelgrouping
ORDER BY transaction_count DESC


-- Question 2 -- What is the relative distribution of these categories?
WITH product_quantity_summary as
(SELECT DISTINCT channelgrouping,
                sum(productquantity) OVER (PARTITION BY channelgrouping) as quantity_by_channel,
                sum(productquantity) OVER () total_product_quantity
FROM all_session_transactions
ORDER BY quantity_by_channel DESC)
SELECT channelgrouping,
       quantity_by_channel,
       total_product_quantity,
       to_char((quantity_by_channel / total_product_quantity) *100, '999d99') as relative_percentage_of_total
FROM product_quantity_summary


-- Question 3 -- Breakdown Channel grouping by Country.

SELECT
    channelgrouping,
    SUM(CASE WHEN country = 'Argentina' THEN productquantity ELSE 0 END) AS Argentina,
    SUM(CASE WHEN country = 'Canada' THEN productquantity ELSE 0 END) AS Canada,
    SUM(CASE WHEN country = 'Colombia' THEN productquantity ELSE 0 END) AS Colombia,
    SUM(CASE WHEN country = 'Finland' THEN productquantity ELSE 0 END) AS Finland,
    SUM(CASE WHEN country = 'France' THEN productquantity ELSE 0 END) AS France,
    SUM(CASE WHEN country = 'India' THEN productquantity ELSE 0 END) AS India,
    SUM(CASE WHEN country = 'Ireland' THEN productquantity ELSE 0 END) AS Ireland,
    SUM(CASE WHEN country = 'Mexico' THEN productquantity ELSE 0 END) AS Mexico,
    SUM(CASE WHEN country = 'Spain' THEN productquantity ELSE 0 END) AS Spain,
    SUM(CASE WHEN country = 'United States' THEN productquantity ELSE 0 END) AS Trumpistan
FROM all_session_transactions S
group by channelgrouping
order by channelgrouping

--Question 4 -- Stocking Level measures for product Categories.

SELECT C.cat_level2 as Category,
       max(R.stocklevel) as Max_stock_lvl,
       avg(R.stocklevel) as AVG_stock_lvl,
        min(R.stocklevel) as min_stock_lvl,
        stddev(r.stocklevel) as stdev_stock_levl,
        count(C.productsku) as product_in_cat
FROM sales_report_cln R
JOIN productcategories_cln2 C
ON R.productsku = C.productsku
GROUP BY Category
ORDER BY Category

SELECT distinct R.productsku
FROM sales_report_cln R
JOIN    productcategories_cln2 C
ON R.productsku=C.productsku
WHERE cat_level2 = 'Apparel'


--- Question 5 - Dates visited------
WITH session_dates as (
SELECT TO_DATE(date::text, 'YYYYMMDD') as Date_corrected
FROM all_session_clean )
--- BY MONTH ---
SELECT DISTINCT (EXTRACT(MONTH from Date_corrected)) as MonthVisit,
         count(Date_corrected) OVER (PARTITION BY EXTRACT(MONTH from Date_corrected)) as visit_count
FROM session_dates
ORDER BY MonthVisit

--- BY DAY OF MONTH
SELECT DISTINCT (EXTRACT(DAY from Date_corrected)) as Day_of_Month_visit,
         count(Date_corrected) OVER (PARTITION BY EXTRACT(DAY from Date_corrected)) as visit_count
FROM session_dates
ORDER BY Day_of_Month_visit
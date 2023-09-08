--Question 1: Which cities and countries have the highest level of transaction revenues
-- ON the site?**

DROP TABLE IF EXISTS total_txn_revenue;
create temp table total_txn_revenue as
SELECT country, city_fix,
        sum(tot_txn_revenue) as Total_txn_revenue
FROM all_session_cln
WHERE all_session_cln.tot_txn_revenue is not null
GROUP BY country, city_fix
ORDER BY Total_txn_revenue desc;
SELECT * FROM total_txn_revenue


--COUNTRY
SELECT country,
        sum(tot_txn_revenue) as Total_txn_revenue
FROM all_session_cln
WHERE all_session_cln.tot_txn_revenue is not null
GROUP BY country
ORDER BY Total_txn_revenue desc;

--CITY
SELECT city_fix,
        sum(tot_txn_revenue) as Total_txn_revenue
FROM all_session_cln
WHERE all_session_cln.tot_txn_revenue is not null
GROUP BY city_fix
ORDER BY Total_txn_revenue desc;

-------------------------
--Question 2: What is the average number of products ordered FROM visitors in each city and country?**
-- COUNTRY
SELECT
       s.country,
       to_char(avg(a.units_sold_num),'9999d9') as AVG
FROM analytics_cln A
JOIN all_session_cln S
ON A.visitid=S.visitid
GROUP BY s.country
ORDER BY AVG DEsc

-- BY CITY
SELECT
       s.city_fix,
       to_char(avg(a.units_sold_num),'9999d9') as AVG
FROM analytics_cln A
JOIN all_session_cln S
ON A.visitid=S.visitid
GROUP BY s.city_fix
ORDER BY AVG DESC

-- Question 3: Pattern to product Category with respect to city/country?

SELECT
    cat_level1,
    cat_level2,
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
JOIN productcategories_cln PC
ON S.productsku = PC.productsku
group by cat_level1, cat_level2
order by cat_level1, cat_level2


-- **Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**
WITH SKU_RANK as(
SELECT t.country,
       t.productsku,
       SUM(t.productquantity) OVER(PARTITION BY t.productsku) as sku_count,
       SUM(t.productquantity) OVER(PARTITION BY t.country) as country_tot_count,
       RANK() OVER (PARTITION BY t.country ORDER BY t.productquantity DESC) as rank_in_country
FROM all_session_transactions t
ORDER BY t.country, t.productquantity DESC)

SELECT *
FROM sku_rank
WHERE rank_in_country =1

--**Question 5: Can we summarize the impact of revenue generated from each city/country?**

WITH SKU_RANK as
    (SELECT t.country,
            city_fix,
            sum(productquantity * productprice) as Revenue
    FROM all_session_transactions t
    GROUP BY country, city_fix
    ORDER BY Revenue ASC)

SELECT country,
       city_fix,
       revenue,
       rank() OVER (PARTITION BY country ORDER BY revenue DESC) as City_rank_in_Country
FROM sku_rank
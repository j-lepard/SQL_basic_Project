--Question 1: Which cities and countries have the highest level of transaction revenues
-- on the site?**

drop table if exists total_txn_revenue;
create temp table total_txn_revenue as
select country, city_fix,
        sum(tot_txn_revenue) as Total_txn_revenue
from all_session_cln
where all_session_cln.tot_txn_revenue is not null
group by country, city_fix
order by Total_txn_revenue desc;
select * from total_txn_revenue


--COUNTRY
select country,
        sum(tot_txn_revenue) as Total_txn_revenue
from all_session_cln
where all_session_cln.tot_txn_revenue is not null
group by country
order by Total_txn_revenue desc;

--CITY
select city_fix,
        sum(tot_txn_revenue) as Total_txn_revenue
from all_session_cln
where all_session_cln.tot_txn_revenue is not null
group by city_fix
order by Total_txn_revenue desc;

-------------------------
--Question 2: What is the average number of products ordered from visitors in each city and country?**
-- COUNTRY



-- BY CITY
select
       s.city_fix,
       to_char(avg(a.units_sold_num),'9999d9') as AVG
from analytics_cln A
join all_session_cln S
on A.visitid=S.visitid
group by s.city_fix
order by AVG DEsc
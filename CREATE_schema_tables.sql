----CREATE TABLE
create table sessions (
fullVisitorId bigint,
channelGrouping text,
time time,
country varchar(15),
city varchar(15),
totalTransactionRevenue float4,
transactions varchar(15),
timeOnSite int,
pageviews int,
sessionQualityDim varchar(15),
date int,
visitId int,
type varchar(10),
productRefundAmount float4,
productQuantity int,
productPrice float4,
productRevenue float4,
productSKU varchar(15),
v2ProductName varchar(25),
v2ProductCategory varchar(25),
productVariant varchar(10),
currencyCode varchar(10),
itemQuantity int,
itemRevenue float4,
transactionRevenue float4,
transactionId int,
pageTitle text,
searchKeyword text,
pagePathLevel1 varchar(15),
eCommerceAction_type int,
eCommerceAction_step int,
eCommerceAction_option int
)

---- IMPORT TABLE from csv file
COPY sessions (fullVisitorId,channelGrouping,time,country,city,totalTransactionRevenue,transactions,timeOnSite,pageviews,sessionQualityDim,date,visitId,type,productRefundAmount,productQuantity,productPrice,productRevenue,productSKU,v2ProductName,v2ProductCategory,productVariant,currencyCode,itemQuantity,itemRevenue,transactionRevenue,transactionId,pageTitle,searchKeyword,pagePathLevel1,eCommerceAction_type,eCommerceAction_step,eCommerceAction_option)
FROM '/Users/jamielepard/Library/CloudStorage/OneDrive-Lepard&Lepard/Data Science/LighthouseLabs/LHL-SQL_Project/sql final project data_updated/all_sessions.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');
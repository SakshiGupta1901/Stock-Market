DROP DATABASE AIMA;
CREATE DATABASE AIMA;
USE AIMA;
DESCRIBE STOCKMARKET;
SELECT * FROM STOCKMARKET;
# ******************************************** #
SELECT COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Aima'
  AND TABLE_NAME = 'STOCKMARKET';
SELECT COUNT(*) FROM STOCKMARKET;
SELECT * FROM STOCKMARKET;
######################  Data Cleaning   ########################
####### ************* RENAMING THE COLUMNS *************** #######
ALTER TABLE STOCKMARKET
	RENAME COLUMN `Name` TO `Company_Name`;
ALTER TABLE STOCKMARKET
	RENAME COLUMN `Sub-Sector` TO `Sub_Sector`;
ALTER TABLE STOCKMARKET
	RENAME COLUMN `Market Cap` TO `Market_Cap`;
ALTER TABLE STOCKMARKET
	RENAME COLUMN `1Y Forward Revenue Growth` TO `1Y_Forward_Revenue_Growth`;
ALTER TABLE STOCKMARKET
	RENAME COLUMN `Close Price` TO `Close_Price`;
ALTER TABLE STOCKMARKET
	RENAME COLUMN `PE Ratio` TO `PE_Ratio`;
ALTER TABLE STOCKMARKET
	RENAME COLUMN `Percentage Buy Recoâ€™s` TO `Percentage_Buy_Records`;
ALTER TABLE STOCKMARKET
	RENAME COLUMN `5Y Historical Revenue Growth` TO `5Y_Historical_Revenue_Growth`,
    RENAME COLUMN `Total Revenue` TO `Total_Revenue`,
    RENAME COLUMN `Taxes & Other Items` TO `Taxes_And_Other_Items`,
    RENAME COLUMN `DII Holding ChangeÂ â€“Â 3M` TO `DII_Holding_Change_3M`,
    RENAME COLUMN `FII Holding ChangeÂ â€“Â 3M` TO `FII_Holding_Change_3M` ,
    RENAME COLUMN `MF Holding ChangeÂ â€“Â 3M` TO `MF_Holding_Change_3M`,
    RENAME COLUMN `Promoter Holding ChangeÂ â€“Â 3M` TO `Promoter_Holding_Change_3M`,
    RENAME COLUMN `No. of analysts with buy reco` TO `No_Of_Analysts_With_Buy_Reco`;
    SELECT * FROM STOCKMARKET;

    ####### ************* LETS TAKE COUNT OF NULL VALUES *************** #######
SELECT
    SUM(CASE WHEN Company_Name IS NULL THEN 1 ELSE 0 END) AS Company_Name_null_count,
    SUM(CASE WHEN Ticker IS NULL THEN 1 ELSE 0 END) AS Ticker_null_count,
	SUM(CASE WHEN Sub_Sector IS NULL THEN 1 ELSE 0 END) AS Sub_Sector_null_count,
    SUM(CASE WHEN Market_Cap IS NULL THEN 1 ELSE 0 END) AS Market_Cap_null_count,
    SUM(CASE WHEN Close_Price IS NULL THEN 1 ELSE 0 END) AS Close_Price_null_count,
    SUM(CASE WHEN PE_Ratio IS NULL THEN 1 ELSE 0 END) AS PE_Ratio_null_count,
    SUM(CASE WHEN 5Y_Historical_Revenue_Growth IS NULL THEN 1 ELSE 0 END) AS `5Y_Historical_Revenue_Growth_null_count`,
    SUM(CASE WHEN `1Y_Forward_Revenue_Growth` IS NULL THEN 1 ELSE 0 END) AS `1Y Forward Revenue Growth_null_count`,
    SUM(CASE WHEN Total_Revenue IS NULL THEN 1 ELSE 0 END) AS Total_Revenue_null_count,
    SUM(CASE WHEN PBT IS NULL THEN 1 ELSE 0 END) AS PBT_null_count,
    SUM(CASE WHEN Taxes_And_Other_Items IS NULL THEN 1 ELSE 0 END) AS Taxes_And_Other_Items_null_count,
    SUM(CASE WHEN DII_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS DII_Holding_Change_3M_null_count,
    SUM(CASE WHEN FII_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS FII_Holding_Change_3M_null_count,
    SUM(CASE WHEN MF_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS MF_Holding_Change_3M_null_count,
    SUM(CASE WHEN Promoter_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS Promoter_Holding_Change_3M_null_count,
    SUM(CASE WHEN Percentage_Buy_Records IS NULL THEN 1 ELSE 0 END) AS Percentage_Buy_Records_null_count,
    SUM(CASE WHEN No_Of_Analysts_With_Buy_Reco IS NULL THEN 1 ELSE 0 END) AS No_Of_Analysts_With_Buy_Reco_null_count,
    SUM(CASE WHEN `Percentage Upside` IS NULL THEN 1 ELSE 0 END) AS `Percentage Upside_null_count`
FROM STOCKMARKET;
## Market Cap Null Value is 129 (total)
SELECT COUNT(Market_Cap) AS total_null_Market_Cap
FROM STOCKMARKET
WHERE `Sub_Sector` LIKE 'Industrial Machinery' AND Market_Cap IS NULL;
## Since the count of null value of Market Cap of `Sub_Sector` = 'Industrial Machinery' is 0 lets treat other null values
SELECT * FROM STOCKMARKET;
####### ************* LETS TREAT NULL VALUES *************** #######
### MARKET_CAP Mean = 6572.563931 and Median = 107.6594081 

SELECT
    AVG(`Market_Cap`) AS average_value_Market_Cap,
    (SELECT `Market_Cap`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `Market_Cap`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `Market_Cap` IS NOT NULL
        ORDER BY `Market_Cap`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `Market_Cap` IS NOT NULL
     )
    ) AS median_value_Market_Cap
FROM STOCKMARKET;

### Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. 
#### To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
### Since we dont have variable with primary key So lets disable safe update mode
# ******************************************** #
## Disable safe update mode 
SET SQL_SAFE_UPDATES = 0;
-### Calculating the median value
SELECT `Market_Cap`
INTO @median
FROM (
    SELECT `Market_Cap`, @rownum := @rownum + 1 AS rownum
    FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
    WHERE `Market_Cap` IS NOT NULL
    ORDER BY `Market_Cap`
) AS ranked
WHERE rownum = (
    SELECT COUNT(*) / 2 + 1
    FROM STOCKMARKET
    WHERE `Market_Cap` IS NOT NULL
);
### Updating null values with the calculated median
UPDATE STOCKMARKET
SET `Market_Cap` = IFNULL(`Market_Cap`, @median);

### After completing the deletion, it's recommended to re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(Market_Cap) AS total_null_Market_Cap
FROM STOCKMARKET
WHERE Market_Cap IS NULL;
# ******************************************** #
### Close_Price count of null value is 79 
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SET SQL_SAFE_UPDATES = 0;

UPDATE STOCKMARKET
SET `Close_Price` = 0
WHERE `Close_Price` IS NULL;

SELECT COUNT(Close_Price) AS total_null_Close_Price
FROM STOCKMARKET
WHERE Close_Price IS NULL;
## *****************************************
### PE_Ratio count of null value is 188 
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
UPDATE STOCKMARKET
SET `PE_Ratio` = 0
WHERE `PE_Ratio` IS NULL;

SELECT COUNT(PE_Ratio) AS total_null_PE_Ratio
FROM STOCKMARKET
WHERE PE_Ratio IS NULL;

### 5Y_Historical_Revenue_Growth count of null value is 576
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
UPDATE STOCKMARKET
SET `5Y_Historical_Revenue_Growth` = 0
WHERE `5Y_Historical_Revenue_Growth` IS NULL;

SELECT COUNT(`5Y_Historical_Revenue_Growth`) AS total_null_5Y_Historical_Revenue_Growth
FROM STOCKMARKET
WHERE `5Y_Historical_Revenue_Growth` IS NULL;

### 1Y_Forward_Revenue_Growth count of null value is 3851
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
UPDATE STOCKMARKET
SET `1Y_Forward_Revenue_Growth` = 0
WHERE `1Y_Forward_Revenue_Growth` IS NULL;

SELECT COUNT(`1Y_Forward_Revenue_Growth`) AS total_null_1Y_Forward_Revenue_Growth
FROM STOCKMARKET
WHERE `1Y_Forward_Revenue_Growth` IS NULL;

### Total_Revenue count of null value is 185
## Median = 99.7, Mean= 3258.580460617225
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SELECT
    AVG(`Total_Revenue`) AS average_value_Total_Revenue,
    (SELECT `Total_Revenue`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `Total_Revenue`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `Total_Revenue` IS NOT NULL
        ORDER BY `Total_Revenue`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `Total_Revenue` IS NOT NULL
     )
    ) AS median_value_Total_Revenue
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `Total_Revenue` = 0
WHERE `Total_Revenue` IS NULL;

SELECT COUNT(`Total_Revenue`) AS total_null_Total_Revenue
FROM STOCKMARKET
WHERE `Total_Revenue` IS NULL;

### PBT of null value is 178
## Mean= 317.2151203887795
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SELECT
    AVG(`PBT`) AS average_value_PBT,
    (SELECT `PBT`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `PBT`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `PBT` IS NOT NULL
        ORDER BY `PBT`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `PBT` IS NOT NULL
     )
    ) AS median_value_Total_Revenue
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `PBT` = 0
WHERE `PBT` IS NULL;

SELECT COUNT(`PBT`) AS total_null_Total_Revenue
FROM STOCKMARKET
WHERE `PBT` IS NULL;

### Taxes_And_Other_Items of null value is 178
## Mean= 97.76544033111092
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SELECT
    AVG(`Taxes_And_Other_Items`) AS average_value_Taxes_And_Other_Items,
    (SELECT `Taxes_And_Other_Items`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `Taxes_And_Other_Items`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `Taxes_And_Other_Items` IS NOT NULL
        ORDER BY `Taxes_And_Other_Items`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `Taxes_And_Other_Items` IS NOT NULL
     )
    ) AS median_value_Taxes_And_Other_Items
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `Taxes_And_Other_Items` = 0
WHERE `Taxes_And_Other_Items` IS NULL;

SELECT COUNT(`Taxes_And_Other_Items`) AS total_null_Taxes_And_Other_Items
FROM STOCKMARKET
WHERE `Taxes_And_Other_Items` IS NULL;

### DII_Holding_Change_3M of null value is 536
## Mean= 0.007831795397296388
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SELECT
    AVG(`DII_Holding_Change_3M`) AS average_value_DII_Holding_Change_3M,
    (SELECT `DII_Holding_Change_3M`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `DII_Holding_Change_3M`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `DII_Holding_Change_3M` IS NOT NULL
        ORDER BY `DII_Holding_Change_3M`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `DII_Holding_Change_3M` IS NOT NULL
     )
    ) AS median_value_DII_Holding_Change_3M
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `DII_Holding_Change_3M` = 0
WHERE `DII_Holding_Change_3M` IS NULL;

SELECT COUNT(`DII_Holding_Change_3M`) AS total_null_DII_Holding_Change_3M
FROM STOCKMARKET
WHERE `DII_Holding_Change_3M` IS NULL;

### FII_Holding_Change_3M of null value is 536
## Mean= 0.08576215258907524
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SELECT
    AVG(`FII_Holding_Change_3M`) AS average_value_FII_Holding_Change_3M,
    (SELECT `FII_Holding_Change_3M`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `FII_Holding_Change_3M`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `FII_Holding_Change_3M` IS NOT NULL
        ORDER BY `FII_Holding_Change_3M`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `FII_Holding_Change_3M` IS NOT NULL
     )
    ) AS median_value_FII_Holding_Change_3M
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `FII_Holding_Change_3M` = 0
WHERE `FII_Holding_Change_3M` IS NULL;

SELECT COUNT(`FII_Holding_Change_3M`) AS total_null_FII_Holding_Change_3M
FROM STOCKMARKET
WHERE `FII_Holding_Change_3M` IS NULL;

### MF_Holding_Change_3M of null value is 536
## Mean= 0.0193463581284866
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SELECT
    AVG(`MF_Holding_Change_3M`) AS average_value_MF_Holding_Change_3M,
    (SELECT `MF_Holding_Change_3M`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `MF_Holding_Change_3M`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `MF_Holding_Change_3M` IS NOT NULL
        ORDER BY `MF_Holding_Change_3M`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `MF_Holding_Change_3M` IS NOT NULL
     )
    ) AS median_value_MF_Holding_Change_3M
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `MF_Holding_Change_3M` = 0
WHERE `MF_Holding_Change_3M` IS NULL;

SELECT COUNT(`MF_Holding_Change_3M`) AS total_null_MF_Holding_Change_3M
FROM STOCKMARKET
WHERE `MF_Holding_Change_3M` IS NULL;

### Promoter_Holding_Change_3M of null value is 536
## Mean= -0.3770983374848735
## we cannot fill null values with mean or median values as it belong to a specific company so lets replace it with 0
SELECT
    AVG(`Promoter_Holding_Change_3M`) AS average_value_Promoter_Holding_Change_3M,
    (SELECT `Promoter_Holding_Change_3M`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `Promoter_Holding_Change_3M`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `Promoter_Holding_Change_3M` IS NOT NULL
        ORDER BY `Promoter_Holding_Change_3M`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `Promoter_Holding_Change_3M` IS NOT NULL
     )
    ) AS median_value_Promoter_Holding_Change_3M
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `Promoter_Holding_Change_3M` = 0
WHERE `Promoter_Holding_Change_3M` IS NULL;

SELECT COUNT(`Promoter_Holding_Change_3M`) AS total_null_Promoter_Holding_Change_3M
FROM STOCKMARKET
WHERE `Promoter_Holding_Change_3M` IS NULL;


### Percentage_Buy_Records of null value is 3791 
## Mean= 73.88344743369703, Median = 81.25
## we cannot fill null values with mean or median values as there are two many null values
## so either to drop them or replace them  with 0 but not allowed to drop so lets replace it with 0
SELECT
    AVG(`Percentage_Buy_Records`) AS average_value_Percentage_Buy_Records,
    (SELECT `Percentage_Buy_Records`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `Percentage_Buy_Records`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `Percentage_Buy_Records` IS NOT NULL
        ORDER BY `Percentage_Buy_Records`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `Percentage_Buy_Records` IS NOT NULL
     )
    ) AS median_value_Percentage_Buy_Records
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `Percentage_Buy_Records` = 0
WHERE `Percentage_Buy_Records` IS NULL;
SELECT COUNT(`Percentage_Buy_Records`) AS total_null_Percentage_Buy_Records
FROM STOCKMARKET
WHERE `Percentage_Buy_Records` IS NULL;

### No_Of_Analysts_With_Buy_Reco of null value is 52
## Mean= 1.1267
## we cannot fill null values with mean or median values as it categorical data
SELECT
    AVG(`No_Of_Analysts_With_Buy_Reco`) AS average_value_No_Of_Analysts_With_Buy_Reco,
    (SELECT `No_Of_Analysts_With_Buy_Reco`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `No_Of_Analysts_With_Buy_Reco`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `No_Of_Analysts_With_Buy_Reco` IS NOT NULL
        ORDER BY `No_Of_Analysts_With_Buy_Reco`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `No_Of_Analysts_With_Buy_Reco` IS NOT NULL
     )
    ) AS median_value_No_Of_Analysts_With_Buy_Reco
FROM STOCKMARKET;
##  Calculate Mode (mode value = 0, frequency = 3779
SELECT No_Of_Analysts_With_Buy_Reco AS mode_value, COUNT(*) AS frequency
FROM STOCKMARKET
GROUP BY No_Of_Analysts_With_Buy_Reco
ORDER BY COUNT(*) DESC
LIMIT 1;

UPDATE STOCKMARKET
SET `No_Of_Analysts_With_Buy_Reco` = 0
WHERE `No_Of_Analysts_With_Buy_Reco` IS NULL;

SELECT COUNT(`No_Of_Analysts_With_Buy_Reco`) AS total_null_Percentage_Buy_Records
FROM STOCKMARKET
WHERE `No_Of_Analysts_With_Buy_Reco` IS NULL;

### Percentage Upside of null value is 3789
## Mean= 20.228940825066207, Median = 16.44671177
## we cannot fill null values with mean or median values as there are two many null values
## so either to drop them or replace them  with 0 but not allowed to drop so lets replace it with 0
SELECT
    AVG(`Percentage Upside`) AS `average_value_Percentage Upside`,
    (SELECT `Percentage Upside`
     FROM (
        SELECT @rownum := @rownum + 1 AS rownum, `Percentage Upside`
        FROM STOCKMARKET, (SELECT @rownum := 0) AS dummy
        WHERE `Percentage Upside` IS NOT NULL
        ORDER BY `Percentage Upside`
     ) ranked
     WHERE rownum = (
        SELECT COUNT(*) / 2 + 1
        FROM STOCKMARKET
        WHERE `Percentage Upside` IS NOT NULL
     )
    ) AS `median_value_Percentage Upside`
FROM STOCKMARKET;

UPDATE STOCKMARKET
SET `Percentage Upside` = 0
WHERE `Percentage Upside` IS NULL;

SELECT COUNT(`Percentage Upside`) AS total_null_Percentage_Buy_Records
FROM STOCKMARKET
WHERE `Percentage Upside` IS NULL;

SELECT * FROM STOCKMARKET;
SET SQL_SAFE_UPDATES = 1;

## Lets start treating duplicated rows
SHOW COLUMNS FROM STOCKMARKET;
SELECT *
FROM STOCKMARKET
GROUP BY `Name`,`Ticker`, `Sub_Sector`, `Market_Cap`,`Close_Price`, `PE_Ratio`,
 `5Y_Historical_Revenue_Growth`,`1Y_Forward_Revenue_Growth`, `Total_Revenue`,
`PBT`, `Taxes_And_Other_Items`, `DII_Holding_Change_3M`, `FII_Holding_Change_3M`,
`MF_Holding_Change_3M`, `Promoter_Holding_Change_3M`,`Percentage_Buy_Records`,
 `No_Of_Analysts_With_Buy_Reco`, `Percentage Upside`,`Net_Profit`,`Profit_Margin`,
 `PS_Ratio`,`Revenue_Growth`,`Total_Institutional_Holding_Change`
HAVING COUNT(*) > 1;
#################         Its Good That we don't have duplicated value

## Here we are done with Data Cleaning
## Sub_Sector_null_count = 591 lets not treat it as we are not allowed to drop them lets ignore them
################################## Here we are done with Data Cleaning lets export our cleaned dataset in csv format
 ################## by using the MySQL Workbench GUI

###		Right-click on the table that you want to export.
###		"Export Data".
###		In the "Export Data" dialog box, select "CSV" as the file format.
###		Specify the file path and filename for the exported file.
###		field separator is the comma (,)
###		Click "Export".

USE AIMA;
DESCRIBE STOCKMARKETFINAL;
SELECT * FROM STOCKMARKETFINAL;
### Lets Check Count of Null Values
SELECT
    SUM(CASE WHEN Company_Name IS NULL THEN 1 ELSE 0 END) AS Company_Name_null_count,
    SUM(CASE WHEN Ticker IS NULL THEN 1 ELSE 0 END) AS Ticker_null_count,
	SUM(CASE WHEN Sub_Sector IS NULL THEN 1 ELSE 0 END) AS Sub_Sector_null_count,
    SUM(CASE WHEN Market_Cap IS NULL THEN 1 ELSE 0 END) AS Market_Cap_null_count,
    SUM(CASE WHEN Close_Price IS NULL THEN 1 ELSE 0 END) AS Close_Price_null_count,
    SUM(CASE WHEN PE_Ratio IS NULL THEN 1 ELSE 0 END) AS PE_Ratio_null_count,
    SUM(CASE WHEN 5Y_Historical_Revenue_Growth IS NULL THEN 1 ELSE 0 END) AS `5Y_Historical_Revenue_Growth_null_count`,
    SUM(CASE WHEN `1Y_Forward_Revenue_Growth` IS NULL THEN 1 ELSE 0 END) AS `1Y Forward Revenue Growth_null_count`,
    SUM(CASE WHEN Total_Revenue IS NULL THEN 1 ELSE 0 END) AS Total_Revenue_null_count,
    SUM(CASE WHEN PBT IS NULL THEN 1 ELSE 0 END) AS PBT_null_count,
    SUM(CASE WHEN Taxes_And_Other_Items IS NULL THEN 1 ELSE 0 END) AS Taxes_And_Other_Items_null_count,
    SUM(CASE WHEN DII_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS DII_Holding_Change_3M_null_count,
    SUM(CASE WHEN FII_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS FII_Holding_Change_3M_null_count,
    SUM(CASE WHEN MF_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS MF_Holding_Change_3M_null_count,
    SUM(CASE WHEN Promoter_Holding_Change_3M IS NULL THEN 1 ELSE 0 END) AS Promoter_Holding_Change_3M_null_count,
    SUM(CASE WHEN Percentage_Buy_Records IS NULL THEN 1 ELSE 0 END) AS Percentage_Buy_Records_null_count,
    SUM(CASE WHEN No_Of_Analysts_With_Buy_Reco IS NULL THEN 1 ELSE 0 END) AS No_Of_Analysts_With_Buy_Reco_null_count,
    SUM(CASE WHEN `Percentage Upside` IS NULL THEN 1 ELSE 0 END) AS `Percentage Upside_null_count`,
    SUM(CASE WHEN `Net_Profit` IS NULL THEN 1 ELSE 0 END) AS `Net_Profit_null_count`,
    SUM(CASE WHEN `Profit_Margin` IS NULL THEN 1 ELSE 0 END) AS `Profit_Margin_null_count`,
    SUM(CASE WHEN `PS_Ratio` IS NULL THEN 1 ELSE 0 END) AS `PS_Ratio_null_count`,
    SUM(CASE WHEN `Earnings_Yield` IS NULL THEN 1 ELSE 0 END) AS `Earnings_Yield_null_count`,
    SUM(CASE WHEN `Revenue_Growth` IS NULL THEN 1 ELSE 0 END) AS `Revenue_Growth_null_count`,
    SUM(CASE WHEN `Total_Institutional_Holding_Change` IS NULL THEN 1 ELSE 0 END) AS `Total_Institutional_Holding_Change_null_count`,
    SUM(CASE WHEN `Change_Retail_Holding` IS NULL THEN 1 ELSE 0 END) AS `Change_Retail_Holding_null_count`,
    SUM(CASE WHEN `Composite_Score` IS NULL THEN 1 ELSE 0 END) AS `Composite_Score_null_count`
FROM STOCKMARKETFINAL;
## LETS TREAT NULL VALUES ###############################################################
SET SQL_SAFE_UPDATES = 0;

## Profit_Margin NULL VALUE COUNT 274
UPDATE STOCKMARKETFINAL
SET `Profit_Margin` = 0
WHERE `Profit_Margin` IS NULL;

SELECT COUNT(`Profit_Margin`) AS total_null_Profit_Margin
FROM STOCKMARKETFINAL
WHERE `Profit_Margin` IS NULL;

## PS_Ratio NULL VALUE COUNT 274
UPDATE STOCKMARKETFINAL
SET `PS_Ratio` = 0
WHERE `PS_Ratio` IS NULL;

SELECT COUNT(`PS_Ratio`) AS total_null_PS_Ratio
FROM STOCKMARKETFINAL
WHERE `PS_Ratio` IS NULL;

## Earnings_Yield NULL VALUE COUNT 30
UPDATE STOCKMARKETFINAL
SET `Earnings_Yield` = 0
WHERE `Earnings_Yield` IS NULL;

SELECT COUNT(`Earnings_Yield`) AS total_null_Earnings_Yield
FROM STOCKMARKETFINAL
WHERE `Earnings_Yield` IS NULL;

## Revenue_Growth NULL VALUE COUNT 275
UPDATE STOCKMARKETFINAL
SET `Revenue_Growth` = 0
WHERE `Revenue_Growth` IS NULL;

SELECT COUNT(`Revenue_Growth`) AS total_null_Revenue_Growth
FROM STOCKMARKETFINAL
WHERE `Revenue_Growth` IS NULL;

## Composite_Score NULL VALUE COUNT 501
UPDATE STOCKMARKETFINAL
SET `Composite_Score` = 0
WHERE `Composite_Score` IS NULL;

SELECT COUNT(`Composite_Score`) AS total_null_Composite_Score
FROM STOCKMARKETFINAL
WHERE `Composite_Score` IS NULL;


    
SET SQL_SAFE_UPDATES = 1;

## Here we are done with FINAL Data Cleaning
## Sub_Sector_null_count = 591 lets not treat it as we are not allowed to drop them lets ignore them
################################## Here we are done with Data Cleaning lets export our cleaned dataset in csv format
 ################## by using the MySQL Workbench GUI

###		Right-click on the table that you want to export.
###		"Export Data".
###		In the "Export Data" dialog box, select "CSV" as the file format.
###		Specify the file path and filename for the exported file.
###		field separator is the comma (,)
###		Click "Export".
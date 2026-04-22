create database bankdb;
use bankdb;

select * from credit_debit_bank;
describe credit_debit_bank;
select count(*) from credit_debit_bank;

describe credit_debit_bank;

ALTER TABLE credit_debit_bank
MODIFY Customer_ID          CHAR(50),
MODIFY Customer_Name        VARCHAR(100),
MODIFY Account_Number       BIGINT,
MODIFY Transaction_Date     DATE,
MODIFY Transaction_Type     ENUM('Credit','Debit'),
MODIFY Amount               DECIMAL(10,2),
MODIFY Balance              DECIMAL(12,2),
MODIFY Description          VARCHAR(255),
MODIFY Branch               VARCHAR(100),
MODIFY Transaction_Method   VARCHAR(50),
MODIFY Currency             CHAR(10),
MODIFY Bank_Name            VARCHAR(100);

describe credit_debit_bank;

#Q1 - Total Credit Amount
select concat(round(sum(Amount)/1000000,2),"M") as Total_Credit_Amount from credit_debit_bank where Transaction_Type="Credit";

#Q2 - Total Debit Amount
select concat(round(sum(Amount)/1000000,2),"M") as Total_Debit_Amount from credit_debit_bank where Transaction_Type="Debit";

#Q3 - Credit to Debit Ratio
select round(sum(case when Transaction_Type="Credit" then Amount end) / 
       sum(case when Transaction_Type="Debit" then Amount end),2)
       as Credit_Debit_Ratio
from credit_debit_bank;

#Q4 - Net Transaction Amount
SELECT 
    CONCAT(
        ROUND(
            (
                SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) -
                SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)
            ) / 1000000, 
        2),
        'M'
    ) AS Net_Transaction_Amount
FROM credit_debit_bank;

#Q5 - Account Activity Ratio
select count(*) / sum(Balance) as Overall_Account_Activity_Ratio
from credit_debit_bank;

#Q6 - Transactions per Day/Week/Month
#6.1 Transactions per Day
select Transaction_Date,
       count(*) as Transactions_Per_Day
from credit_debit_bank
group by Transaction_Date
order by Transaction_Date;

#6.2 Transactions per Week
select year(Transaction_Date) as Year,
       week(Transaction_Date) as Week_Number,
       count(*) as Transactions_Per_Week
from credit_debit_bank
group by year(Transaction_Date), Week(Transaction_Date)
order by Year, Week_Number;

#6.3 Transactions per Month
select date_format(Transaction_Date,"%Y-%m") as Month,
       count(*) as Transactions_Per_Month
from credit_debit_bank
group by date_format(Transaction_Date,"%Y-%m")
order by Month;

#Q7 - Total Transaction Amount By Branch
select Branch,
       concat(round(sum(Amount)/1000000,2),"M") as Total_Transactions
from credit_debit_bank
group by Branch
order by Total_Transactions desc;

#Q8 - Transaction Volume By Bank
select Bank_Name,
       concat(round(sum(Amount)/1000000,2),"M") as Total_Transactions
from credit_debit_bank
group by Bank_Name
order by Total_Transactions desc;

#Q9 - Transaction Method Distribution
select Transaction_Method,
       concat(round(count(*)/1000,2),"K") as Total_Transactions
from credit_debit_bank
group by Transaction_Method
order by Total_Transactions desc;

#Q10 - Branch Transaction Growth %
WITH MonthlyTotals AS (
    SELECT 
        Branch,
        DATE_FORMAT(Transaction_Date, '%Y-%m') AS Month,
        SUM(Amount) AS Total_Amount
    FROM credit_debit_bank
    GROUP BY Branch, DATE_FORMAT(Transaction_Date, '%Y-%m')
)

SELECT 
    Branch,
    Month,
    Total_Amount,
    
    LAG(Total_Amount) OVER (PARTITION BY Branch ORDER BY Month) AS Previous_Month_Amount,

    CONCAT(
        ROUND(
            ((Total_Amount - LAG(Total_Amount) OVER (PARTITION BY Branch ORDER BY Month)) 
             / LAG(Total_Amount) OVER (PARTITION BY Branch ORDER BY Month)) * 100
        , 2),
        '%'
    ) AS Growth_Percentage

FROM MonthlyTotals
ORDER BY Branch, Month;

#Q11 - High-Risk Transaction Flag
SELECT 
    *,
    CASE 
        WHEN Amount > 4500 THEN 'High-Risk'
        ELSE 'Normal'
    END AS Risk_Flag
FROM credit_debit_bank;

#Q12 - Suspicious Transaction Frequency
SELECT 
    concat(round(COUNT(*)/1000,2),"K") AS Suspicious_Transaction_Count
FROM credit_debit_bank
WHERE Amount > 4500;

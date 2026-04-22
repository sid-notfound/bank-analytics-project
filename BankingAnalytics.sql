create database	bankAs;

use bankAs;

describe final_fact_cleaned;

select * from final_fact_cleaned;

select count(*) from final_fact_cleaned;

ALTER TABLE final_fact_cleaned
MODIFY COLUMN Account_ID VARCHAR(20),
MODIFY COLUMN `Client _id` INT,
MODIFY COLUMN Branch_Name_x VARCHAR(100),
MODIFY COLUMN Product_Id VARCHAR(50),
MODIFY COLUMN Loan_Amount INT,
MODIFY COLUMN Funded_Amount INT,
MODIFY COLUMN Funded_Amount_Inv INT,
MODIFY COLUMN Disbursement_Date DATE,
MODIFY COLUMN Loan_Status VARCHAR(50),
MODIFY COLUMN Repayment_Type VARCHAR(50),
MODIFY COLUMN Center_Id_x INT,
MODIFY COLUMN BranchID VARCHAR(50),
MODIFY COLUMN Client_Name VARCHAR(100),
MODIFY COLUMN Gender_ID VARCHAR(10),
MODIFY COLUMN Age VARCHAR(10),              -- because values look like 26-35
MODIFY COLUMN Age_T INT,
MODIFY COLUMN Date_of_Birth DATE,
MODIFY COLUMN Caste VARCHAR(20),
MODIFY COLUMN Religion VARCHAR(20),
MODIFY COLUMN Home_Ownership VARCHAR(50),
MODIFY COLUMN Client_Income_Range VARCHAR(50),
MODIFY COLUMN Employment_Type VARCHAR(50),
MODIFY COLUMN Credit_Score INT,
MODIFY COLUMN Product_Code VARCHAR(20),
MODIFY COLUMN Purpose_Category VARCHAR(50),
MODIFY COLUMN Term VARCHAR(20),             -- because value is "36 months"
MODIFY COLUMN Int_Rate DECIMAL(10,4),
MODIFY COLUMN Grade VARCHAR(5),
MODIFY COLUMN Sub_Grade VARCHAR(5),
MODIFY COLUMN Branch_Name_y VARCHAR(100),
MODIFY COLUMN Bank_Name VARCHAR(100),
MODIFY COLUMN Region_Name VARCHAR(100),
MODIFY COLUMN State_Abbr VARCHAR(10),
MODIFY COLUMN `State_Abbr.1` VARCHAR(10),
MODIFY COLUMN State_Name VARCHAR(50),
MODIFY COLUMN City VARCHAR(100),
MODIFY COLUMN Center_Id_y INT,
MODIFY COLUMN BH_Name VARCHAR(100),
MODIFY COLUMN Branch_Performance_Category VARCHAR(50),
MODIFY COLUMN Total_Pymnt DECIMAL(12,2),
MODIFY COLUMN Total_Pymnt_inv DECIMAL(12,2),
MODIFY COLUMN Total_Rec_Prncp DECIMAL(12,2),
MODIFY COLUMN Total_Fees DECIMAL(12,2),
MODIFY COLUMN Total_Rrec_Int DECIMAL(12,2),
MODIFY COLUMN Is_Delinquent_Loan ENUM('Y','N'),
MODIFY COLUMN Is_Default_Loan ENUM('Y','N'),
MODIFY COLUMN Delinq_2_Yrs INT,
MODIFY COLUMN Repayment_Behavior VARCHAR(50);

select * from final_fact_cleaned;

#Q1 - Total Clients
select count(`client _id`) as Total_Clients from final_fact_cleaned;


#Q2 - Active Clients
select count(distinct `client _id`) as Active_Clients from final_fact_cleaned where Loan_Status="Active";


#Q3 - New Clients
SET @StartDate = '2015-01-01';   
SET @EndDate   = '2023-12-31';  

SELECT COUNT(*) AS New_Clients 
FROM (
      SELECT `Client _id`
      FROM final_fact_cleaned
      GROUP BY `Client _id`
      HAVING MIN(Disbursement_Date) BETWEEN @StartDate AND @EndDate
) AS t;


#Q4 - Client Retention Rate
SET @PrevStart = '2020-01-01';
SET @PrevEnd   = '2020-12-31';

SET @CurrStart = '2021-01-01';
SET @CurrEnd   = '2021-12-31';

SELECT 
    COUNT(DISTINCT curr.`Client _id`) * 1.0 
    / COUNT(DISTINCT prev.`Client _id`) AS Retention_Rate
FROM final_fact_cleaned curr
JOIN final_fact_cleaned prev 
  ON curr.`Client _id` = prev.`Client _id`
WHERE curr.Disbursement_Date BETWEEN @CurrStart AND @CurrEnd
  AND prev.Disbursement_Date BETWEEN @PrevStart AND @PrevEnd;


#Q5 - Total Loan Amount Disbursed
select concat(round(sum(Loan_Amount)/1000000,2),"M") as Total_Loan_Amount from final_fact_cleaned;


#Q6 - Total Funded Amount 
SELECT 
    CONCAT(ROUND(SUM(Funded_Amount) / 1000000, 2),
            'M') AS Total_Funded_Amount
FROM
    final_fact_cleaned;


#Q7 - Average Loan Size
SELECT 
    CONCAT(ROUND(AVG(Loan_Amount) / 1000, 2), 'K') AS Average_Loan_Size
FROM
    final_fact_cleaned;


#Q8 - Loan Growth %
SELECT 
    CONCAT(
        ROUND(
            ((Curr.TotalLoan - Prev.TotalLoan) / Prev.TotalLoan) * 100,
            2
        ),
        '%'
    ) AS Loan_Growth_Percent
FROM 
    (SELECT SUM(Loan_Amount) AS TotalLoan
     FROM final_fact_cleaned
     WHERE Disbursement_Date BETWEEN @PrevStart AND @PrevEnd) AS Prev,

    (SELECT SUM(Loan_Amount) AS TotalLoan
     FROM final_fact_cleaned
     WHERE Disbursement_Date BETWEEN @CurrStart AND @CurrEnd) AS Curr;


#Q9 - Total Repayments Collected
SELECT 
    CONCAT(ROUND(SUM(Total_Pymnt) / 1000000, 2),
            'M') AS Total_Repayments
FROM
    final_fact_cleaned;


#10 - Principal Recovery Rate
SELECT 
    CONCAT(ROUND((SUM(Total_Rec_Prncp) * 1.0 / SUM(Loan_Amount)) * 100,
                    2),
            '%') AS Principal_Recovery_Rate
FROM
    final_fact_cleaned;


#11 - Interest Income
select concat(round(sum(Total_Rrec_int)/1000000,2),"M") as Interest_Income from final_fact_cleaned;


#12 - Default Rate
SELECT 
    CONCAT(
        ROUND(
            (SUM(CASE WHEN Is_Default_Loan = 'Y' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100,
            2
        ),
        '%'
    ) AS Default_Rate
FROM final_fact_cleaned;


#13 - Delinquency Rate
SELECT 
    CONCAT(
        ROUND(
            (SUM(CASE WHEN Is_Delinquent_Loan = 'Y' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100,
            2
        ),
        '%'
    ) AS Delinquency_Rate
FROM final_fact_cleaned;


#14 - On-Time Repayments %
SELECT 
    CONCAT(
        ROUND(
            (SUM(CASE WHEN Repayment_Behavior = 'On-Time' THEN 1 ELSE 0 END) * 1.0 
            / COUNT(*)) * 100,
        2),
        '%'
    ) AS On_Time_Repayment_Percent
FROM final_fact_cleaned;


#15 - Loan Distribution By Branch
SELECT 
    Branch_Name_x,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), 'M') AS Loan_Distribution
FROM final_fact_cleaned
GROUP BY Branch_Name_x
ORDER BY SUM(Loan_Amount) DESC;


#16 - Branch Performance Category Split
SELECT 
    Branch_Performance_Category,
    COUNT(*) AS Loan_Count,
    CONCAT(
        ROUND(
            (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 
            2
        ), 
        '%'
    ) AS Percentage
FROM final_fact_cleaned
GROUP BY Branch_Performance_Category;


#17 - Product-Wise Loan Volume
SELECT 
    Product_Id,
    CONCAT(ROUND(SUM(Loan_Amount) / 1000000, 2), 'M') AS Total_Loan_Amount
FROM final_fact_cleaned
GROUP BY Product_Id
ORDER BY SUM(Loan_Amount) DESC;


#18 - Product Profitability
SELECT 
    Product_Id,
    CONCAT(ROUND(SUM(Total_Rrec_Int) / 1000000, 2), 'M') AS Interest_Income
FROM final_fact_cleaned
GROUP BY Product_Id
ORDER BY SUM(Total_Rrec_Int) DESC;


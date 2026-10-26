-- Coding done by Justine Berger, Oct 2026

-- Analytics -- 

---------------------------------------------------------------------
--- Top Customers --- 
-- Customer Ranking --
-- Business Question: Who are the top 10 customers? --

WITH customer_balances AS (
	SELECT
		CustomerID,
		SUM(Balance) AS TotalBalance
	FROM accounts
	GROUP BY CustomerID
)

SELECT 
	CustomerID,
	TotalBalance,
	RANK() OVER (
			ORDER BY TotalBalance DESC
		) AS BalanceRank
FROM customer_balances
ORDER BY TotalBalance DESC
LIMIT 10;

---------------------------------------------------------------------
-- Transaction Volume by Type
-- Business Question: What type of transactions are occuring the most?

SELECT 
	tt.TypeName,
	COUNT(*) AS Transaction_Count,
	TO_CHAR(SUM(t.Amount), '$999,999,999,990.00') AS Total_Amount,
	TO_CHAR(AVG(t.Amount), '$999,999,999,990.00') AS Average_Amount
FROM Transactions t
JOIN Transaction_Types tt
	ON t.TransactionTypeID = tt.TransactionTypeID
GROUP BY tt.TypeName
ORDER BY Total_Amount DESC;

---------------------------------------------------------------------
--- Top Account Activity --- 
-- Business Question: What are the top 10 accounts with the most activity?

WITH Activity AS(
	SELECT
		AccountOriginID AS AccountID
	FROM Transactions
	UNION ALL
	SELECT AccountDestinationID
	FROM Transactions
)

SELECT 
	AccountID,
	COUNT(*) AS Transaction_Count
FROM Activity
GROUP BY AccountID
ORDER BY Transaction_Count DESC
LIMIT 10;

--------------------------------------------------------------------
--- Interest Revenue --- 
-- Due to the limitation on information provided in the data set used, the below is not accurate for a real business case.
-- This is assuming that no payments were made on the loans. 
-- In a real world scenario, we would take into account the payments made to help calculate interest revenue.
-- This is an example of how we could start building out a schedule to estimate interest revenue over the loan's life.

WITH Imputed_Dates AS (
	SELECT
		*,
		(EstimatedEndDate - StartDate) AS Est_Days_Outstanding
	FROM loans
),

Average_Days AS (
	SELECT 
		AVG(Est_Days_Outstanding) AS Avg_Days
	FROM Imputed_Dates
),

Loan_Dates AS (
	SELECT 
		i.LoanID,
		i.PrincipalAmount,
		i.InterestRate,
		
		CASE 
			WHEN i.StartDate IS NULL 
				THEN (i.EstimatedEndDate - CAST(a.Avg_Days AS INTEGER))
			ELSE i.StartDate
		END AS Imputed_StartDate,
		
		CASE 
			WHEN EstimatedEndDate IS NULL 
				THEN (i.StartDate + CAST(a.Avg_days AS INTEGER))
			ELSE EstimatedEndDate
		END AS Imputed_EstimatedEndDate
		
	FROM Imputed_Dates i
	CROSS JOIN Average_Days a
)
	
SELECT
	LoanId,
	PrincipalAmount,
	InterestRate,
	Imputed_StartDate,
	Imputed_EstimatedEndDate,
	CAST(Imputed_EstimatedEndDate - Imputed_Startdate AS DECIMAL)
		AS Imputed_Days_Outstanding,
	ROUND(CAST(Imputed_EstimatedEndDate - Imputed_StartDate AS DECIMAL)/365.0, 2) 
		AS Years_Outstanding,
	ROUND(CAST (PrincipalAmount * InterestRate AS DECIMAL), 2) 
		AS Annual_Interest,
	ROUND(CAST(Imputed_EstimatedEndDate - Imputed_StartDate AS DECIMAL)/365.0 * (PrincipalAmount * InterestRate), 2) 
		AS Estimated_Interest_Revenue

FROM Loan_Dates
ORDER BY Estimated_Interest_Revenue DESC
;

-----------------------------------------
--- Transactions vs Balance -----
-- Business Question: Do the transactions reconcile to the account balances provided?
-- Transaction activity does not fully explain balances. This indicates that the balances provided are possibly a point in time
-- and/or independently generated from the transaction history.
-- Reviewing the site the data was generated from (https://testdatabox.com/?utm_source=kaggle) this does appear to be true.

WITH Disbursements AS (
	SELECT
		t.AccountOriginId,
		SUM(t.Amount) AS Total_Disbursements
	FROM Transactions t
	GROUP BY t.AccountOriginId
),

Deposits AS (
	SELECT
		t.AccountDestinationId,
		SUM(t.Amount) AS Total_Deposits
	FROM Transactions t
	GROUP BY t.AccountDestinationId
)

SELECT
	a.AccountId,
	COALESCE(d.Total_Deposits,0) AS Deposits,
	COALESCE(dis.Total_Disbursements,0) AS Disbursements,
	COALESCE(d.Total_Deposits,0) - COALESCE(dis.Total_Disbursements,0) AS Transaction_Derived_Balance,
	a.balance AS Actual_Balance,
	(COALESCE(d.Total_Deposits,0) - COALESCE(dis.Total_Disbursements,0)) - a.Balance AS Balance_Variance,
	ABS((COALESCE(d.Total_Deposits,0) - COALESCE(dis.Total_Disbursements,0)) - a.Balance) AS ABS_Balance_Variance
	
FROM Accounts a

LEFT JOIN Deposits d
	ON a.AccountID = d.AccountDestinationID
	
LEFT JOIN Disbursements dis
	ON a.AccountID = dis.AccountOriginID
	
ORDER BY ABS_Balance_Variance DESC;

---------------------------------------------------------


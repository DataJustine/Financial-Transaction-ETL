-- Coding done by Justine Berger, Oct 2026 --
-- Store Queries to be reused as needed -- 
-- Order Bys were removed from original queries created for analytics to create the views,
-- as when using the view one would then order as needed

-----------View 1-----------------
--Customer Balances---
CREATE VIEW vw_customer_balances AS
SELECT
    CustomerID,
    SUM(Balance) AS TotalBalance
FROM accounts
GROUP BY CustomerID;


-----------View 2-----------------
---Transaction Volume by Type---
CREATE VIEW vw_transaction_summary AS

SELECT 
	tt.TypeName,
	COUNT(*) AS Transaction_Count,
	SUM(t.Amount) AS Total_Amount, -- Removed formatting for currency to allow Aggregations as needed.
	AVG(t.Amount)AS Average_Amount -- Removed formatting for currency to allow Aggregations as needed.
FROM Transactions t
JOIN Transaction_Types tt
	ON t.TransactionTypeID = tt.TransactionTypeID
GROUP BY tt.TypeName;

---------View 3------------------
--- Account Activity ---
CREATE VIEW vw_account_activity AS

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
GROUP BY AccountID;

---------View 4-------------------
---------Interest Revenue---------
-- Due to the limitation on information provided in the data set used, the below is not accurate for a real business case.
-- This is assuming that no payments were made on the loans. 
-- In a real world scenario, we would take into account the payments made to help calculate interest revenue.
-- This is an example of how we could start building out a schedule to estimate interest revenue over the loan's life and 
-- save it as a view for future use as applicable.

CREATE VIEW vw_loan_revenue_estimates AS

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

FROM Loan_Dates;


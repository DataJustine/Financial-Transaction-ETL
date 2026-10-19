-- Code by Justine Berger 10-2026 for Financial Transaction ETL LOAD --
-- Created using pgAdmin 4

--------------------------------------------------------------------------------------------------------------------------------
-- Create database to house data
-- CREATE DATABASE financial_transaction_etl;

-- Connect to the database before continuing
--------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE account_statuses(
	AccountStatusID integer PRIMARY KEY,
	StatusName varchar(100) NOT NULL
);

-- Import data
COPY account_statuses
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\account_statuses_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Check data
SELECT * FROM account_statuses;

-- Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE account_types(
	AccountTypeID integer PRIMARY KEY,
	TypeName varchar(100) NOT NULL
);

-- Import data
COPY account_types
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\account_types_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Check data
SELECT * FROM account_types;

-- Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE addresses(
	AddressID integer PRIMARY KEY,
	Street varchar(100),
	City varchar(100),
	Country varchar(100)
);

-- Noted while in data exploration there are NULLs present in the address fields. 
-- To preserve source data NOT NULL constraint will not be used.
-- Recommended that after business rules fully defined, add constraints to production environment. 
-- This logic will be applied to subsequent tables.

-- Import data
COPY addresses
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\addresses_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Check data
SELECT * FROM addresses;

-- Check data 
SELECT COUNT (*)
FROM addresses;
-- Expected 1,210 records. No exceptions noted.

-- Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
-- Needs to be created after addresses due to keys

CREATE TABLE branches(
	BranchID integer PRIMARY KEY,
	BranchName varchar(100) NOT NULL,
	AddressID integer NOT NULL
		REFERENCES addresses (AddressID)
);

-- Import data
COPY branches
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\branches_cleaned.csv'
WITH (FORMAT CSV, HEADER);


-- Check data
SELECT * FROM branches;
-- Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE customer_types(
	CustomerTypeID integer PRIMARY KEY,
	TypeName varchar(100) NOT NULL
);

-- Import data
COPY customer_types
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\customer_types_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Check data
SELECT * FROM customer_types;

--Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE customers(
	CustomerID integer PRIMARY KEY,
	FirstName varchar(100),
	LastName varchar(100),
	DateOfBirth date,
	AddressID integer NOT NULL
		REFERENCES addresses (AddressID),
	CustomerTypeID integer NOT NULL
		REFERENCES customer_types (CustomerTypeID)
);


-- Import data

COPY customers
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\customers_cleaned.csv'
WITH (FORMAT CSV, HEADER); 

-- Check data
SELECT * FROM customers;

-- Check data 
SELECT COUNT (*)
FROM customers;
-- Expected 1,100 records. No exceptions noted.

--Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Due to keys, this needed to be created after customers, account_types, and account_statuses tables.
-- Create table
CREATE TABLE accounts(
	AccountID integer PRIMARY KEY,
	CustomerID integer NOT NULL
		REFERENCES customers (CustomerID),
	AccountTypeID integer NOT NULL
		REFERENCES account_types (AccountTypeID),
	AccountStatusID integer NOT NULL
		REFERENCES account_statuses (AccountStatusID),
	Balance numeric(10,2) NOT NULL,
	OpeningDate date
);

-- Import data
COPY accounts
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\accounts_cleaned.csv'
WITH (FORMAT CSV, HEADER);


-- Check data
SELECT * FROM accounts;

-- Check data 
SELECT COUNT (*)
FROM accounts;
-- Expected 1,651 records. Noting no exception noted.

--Imported without issue


--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE loan_statuses(
	LoanStatusID integer PRIMARY KEY,
	StatusName varchar(100) NOT NULL
);

-- Import data
COPY loan_statuses
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\loan_statuses_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Check data
SELECT * FROM loan_statuses;

--Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table

CREATE TABLE loans(
	LoanID integer PRIMARY KEY,
	AccountID integer NOT NULL
		REFERENCES accounts (AccountID),
	LoanStatusID integer NOT NULL
		REFERENCES loan_statuses (LoanStatusID),
	PrincipalAmount numeric(10,2) NOT NULL -- Allows loans up to 10M, loans in the data set don't exceed 100k. This allows growth. 
		CHECK (PrincipalAmount >= 0),
	InterestRate numeric(7,5) NOT NULL -- Interest rates should not reach 3 digits before the decimal. This allows growth, however, keeps reasonable limits on input.
		CHECK (InterestRate >= 0),
	StartDate date,
	EstimatedEndDate date
);

-- During data exploration, records were identified where StartDate occurred after EstimatedEndDate.
-- To resolve this a CHECK constraint could be implemented as follows: EstimatedEndDate >= StartDate.
-- However, the source data also contains NULL values. Because the objective is to preserve validated source data,
-- it will not be implemented at this stage. This should be considered when business requirements are being finalized 
-- and implemented to the production environment, as applicable.

-- Import data
COPY loans
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\loans_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Check data
SELECT * FROM loans;

-- Check data 
SELECT COUNT (*)
FROM loans;
-- Expected 330 records. No exceptions noted.

--Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE transaction_types(
	TransactionTypeID integer PRIMARY KEY,
	TypeName varchar(100) NOT NULL
);

COPY transaction_types
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\transaction_types_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Check data
SELECT * FROM transaction_types;

--Imported without issue

--------------------------------------------------------------------------------------------------------------------------------------
-- Create table
CREATE TABLE transactions(
	TransactionID integer PRIMARY KEY,
	AccountOriginID integer NOT NULL
		REFERENCES accounts (AccountID),
	AccountDestinationID integer NOT NULL
		REFERENCES accounts (AccountID),
	TransactionTypeID integer NOT NULL 
		REFERENCES transaction_types (TransactionTypeID),
	Amount numeric(10,2) NOT NULL 
		CHECK (Amount >= 0),
	TransactionDate date,
	BranchID integer NOT NULL 
		REFERENCES branches (BranchID),
	Description text
);

-- Import Data
COPY transactions
FROM 'C:\Users\mavor\Data Science\Financial Transactions ETL\Data\Raw\transactions_cleaned.csv'
WITH (FORMAT CSV, HEADER);

-- Imported without issue

-- Check data
SELECT * 
FROM transactions
LIMIT 1000;

-- Check data 
SELECT COUNT (*)
FROM transactions;
-- Expected 49,500 records. No exceptions noted.

----------------------------------------------------------------------------------------------------------------------------------
-- VALIDATE
--------------------------------

-- Because foreign key constraints are enforced at load time, 
-- the orphan-record validation queries serve primarily as a 
-- demonstration of referential integrity testing rather than a 
-- necessary control. The expectation is that no records return.

---------------------------------
-- Orphan customer records

SELECT * 
FROM customers c
LEFT JOIN addresses a
	ON c.AddressID = a.AddressID
WHERE a.AddressID IS NULL;

-- None found
---------------------------------
-- Orphan loan records

SELECT *
FROM loans l
LEFT JOIN accounts a
	ON l.AccountID = a.AccountID
WHERE a.AccountID IS NULL;

-- None found
---------------------------------
-- Orphan transactions

SELECT *
FROM transactions t
LEFT JOIN accounts a
	ON t.AccountOriginID = a.AccountID
WHERE a.AccountID IS NULL;

-- None noted

SELECT *
FROM transactions t
LEFT JOIN accounts a
	ON t.AccountDestinationID = a.AccountID
WHERE a.AccountID IS NULL;

-- None noted

---------------------------------
-- Account balance statistics

SELECT
	MIN(Balance),
	MAX(Balance),
	AVG(Balance)
FROM accounts

-- This is consistent with balances reviewed in Python Data Exploration MIN = -486.68, MAX = 99828.98, MEAN = 49072.473935. 
-- The variance between Python mean and SQL avg caused most likely due to rounding differences in the programs. 
-- This appears appropriate.

----------------------------------
-- PrincipalAmount balance statistics

SELECT
	MIN(PrincipalAmount),
	MAX(PrincipalAmount),
	AVG(PrincipalAmount)
FROM loans

-- This is consistent with balances reviewed in Python Data Exploration MIN = 1128.49, MAX = 99830.33, MEAN = 51780.517447. 
-- The variance between Pthyon mean and SQL avg caused most likely due to rounding differences in the programs. 
-- This appears appropriate.

---------------------------------
-- Review critical data and largest table

SELECT COUNT(*)
FROM transactions
WHERE AccountOriginID IS NULL 
	OR AccountDestinationID IS NULL 
	OR AMOUNT IS NULL; 
	
-- No values missing from crucial fields.
-----------------------------------


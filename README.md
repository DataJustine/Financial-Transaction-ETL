# Financial Transactions ETL Pipeline (In Progress)

## Project Objective
This project demonstrates an end-to-end data analytics workflow using Python, PostgreSQL, and Power BI.

The project began with a collection of raw financial datasets containing customer, account, transaction, loan, and branch information. The data was profiled, cleaned, transformed, loaded into a PostgreSQL database, analyzed using SQL, and ultimately visualized through interactive Power BI dashboards.

The objective was to simulate a realistic analytics workflow while demonstrating data engineering, SQL development, data modeling, and business intelligence skills.

## Business Objectives

The project was designed to answer the following business questions:

### Customer Analysis

- Who are the highest-value customers?
- How are customer balances distributed?
- Which customer segments hold the most assets?

### Transaction Analysis

- What types of transactions occur most frequently?
- What transaction types generate the largest dollar volume?
- Which accounts demonstrate the highest activity?
- How has transaction activity changed over time?

### Loan Portfolio Analysis

- What is the total value of the loan portfolio?
- Which loans generate the highest estimated interest revenue?
- How are interest rates distributed?
- What relationship exists between principal amounts and estimated revenue?

## Technology Stack

- Python (Pandas, NumPy and Pathlib)
- Database (PostgreSQL and pgAdmin 4)
- Business Intelligence (Power BI)
- Development Environment (Jupyter Notebook and Visual Studio Code)

## Project Workflow

## ETL Process
### Extract
### Transform
### Load

## Database Design

## SQL Analytics
### Views Created

## Power BI Dashboards

### Customer Dashboard

## Transaction Dashboard

## Loan Portfolio Dashboard

## Key Findings
### Customer Insights

- Customer balances total approximately $81M.
- Large Enterprise, Small Business, and Individual customers each contribute significant portfolio value.
- Customer balances exhibit a right-skewed distribution with relatively few high-balance customers.

### Transaction Insights

- Total transaction volume exceeds $124M.
- Deposits, Transfers, and Withdrawals occur at similar levels of activity.
- Transaction activity declines significantly after 2023 due to source data limitations and missing transaction dates.

### Loan Portfolio Insights

- Total loan principal exceeds $17M.
- Estimated interest revenue exceeds $4.7M.
- Most loans remain active.
- Interest rates are concentrated between approximately 6% and 10%.

# Code by Justine Berger, Oct 2026

# Load libraries
import pandas as pd
import numpy as np

# Create individual functions for each table to be cleaned

#-----------------------------------
# accounts
#-----------------------------------

def clean_accounts(df): 

    # Remove duplicates    
    df = df.drop_duplicates().copy()

    # Reformat dates
    df['OpeningDate'] = (
        pd.to_datetime(
            df['OpeningDate'],
            errors='coerce'
        ).dt.date
    )

    return df

#-----------------------------------
# addresses
#-----------------------------------

def clean_addresses(df):

    # Remove duplicates
    df = df.drop_duplicates().copy()

    # Update Country inconsistencies
    df.loc[
        ~df.Country.isin(['United States']),
          'Country'
          ] = 'United States'

    return df

#-----------------------------------
# customers
#-----------------------------------

def clean_customers(df):

    # Remove duplicates
    df = df.drop_duplicates().copy()

    # Update invalid dates
    df['DateOfBirth'] = (
        df['DateOfBirth']
        .replace({
            '1960-08-27T00:00:00' : '1960-08-27 00:00:00.000000',
            'NaT' : np.nan,
            '07.04.1981' : '1981-07-04 00:00:00.000000',
            '1985/07/09' : '1985-07-09 00:00:00.000000',
            '02/11/1970' : '1970-02-11 00:00:00.000000',
            '09/12/1982' : '1982-09-12 00:00:00.000000',
            '1989/03/17' : '1989-03-17 00:00:00.000000',
            '1962-15-01' : '1962-01-15 00:00:00.000000',
            '1974-31-01' : '1974-01-31 00:00:00.000000',
            '01.18.1960' : '1960-01-18 00:00:00.000000',
            '1969/08/28' : '1969-08-28 00:00:00.000000'
        })
    )

    # Format dates
    df['DateOfBirth'] = (
        pd.to_datetime(
            df['DateOfBirth'],
             errors='coerce'
            ).dt.date
    )

    return df

#-----------------------------------
# loans
#-----------------------------------

def clean_loans(df):

    # Remove duplicates
    df = df.drop_duplicates().copy()

    # Format dates
    for col in ['StartDate', 'EstimatedEndDate']:
        df[col] = (
            pd.to_datetime(
                df[col], 
                errors='coerce'
            ).dt.date
        )

    # Impute and update values for invalid EstimatedEndDate 
 
    ## Create a dataset with only valid loan periods

    valid_periods = df[
        df['StartDate'] <= df['EstimatedEndDate']
    ]

    ## Calculate individual row differences and then get the overall average

    avg_days = (
        pd.to_datetime(valid_periods['EstimatedEndDate']) 
        - 
        pd.to_datetime(valid_periods['StartDate'])
    ).dt.days.mean()

    ## Update invalid dates

    df['EstimatedEndDate'] = np.where(
        pd.to_datetime(df['StartDate']) 
        > 
        pd.to_datetime(df['EstimatedEndDate']),
        
        pd.to_datetime(df['StartDate']) 
        + 
        pd.to_timedelta(avg_days, unit='D'),

        pd.to_datetime(df['EstimatedEndDate'])
    )

    return df

#-----------------------------------
# transactions
#-----------------------------------

def clean_transactions(df): 

    # Remove duplicates    
    df = df.drop_duplicates().copy()

    # Reformat dates
    df['TransactionDate'] = (
        pd.to_datetime(
            df['TransactionDate'],
            errors='coerce'
        ).dt.date
    )

    return df


# Create a master function to run all functions created above

def transform_data(tables):

    tables['accounts'] = clean_accounts(
        tables['accounts']
    )
    
    tables['addresses'] = clean_addresses(
        tables['addresses']
    )

    tables['customers'] = clean_customers(
        tables['customers']
    )

    tables['loans'] = clean_loans(
        tables['loans']
    )

    tables['transactions'] = clean_transactions(
        tables['transactions']
    )

    return tables


# Load libraries
from pathlib import Path
import pandas as pd

# Set directory
DATA_DIR = Path(__file__).parent.parent / 'Data' / 'Raw'

# Create function with dictionary to load data sets
def extract_data():
    """
    Extract raw CSV files into pandas dataframes.
    Returns:
        dict: Dictionary containing all source tables.
    """
    tables = {
        'account_statuses' : pd.read_csv(DATA_DIR / 'account_statuses.csv'),
        'account_types' : pd.read_csv(DATA_DIR / 'account_types.csv'),
        'accounts' : pd.read_csv(DATA_DIR / 'accounts.csv'),
        'addresses' : pd.read_csv(DATA_DIR / 'addresses.csv'),
        'branches' : pd.read_csv(DATA_DIR / 'branches.csv'),
        'customer_types' : pd.read_csv(DATA_DIR / 'customer_types.csv'),
        'customers' : pd.read_csv(DATA_DIR / 'customers.csv'),
        'loan_statuses' : pd.read_csv(DATA_DIR / 'loan_statuses.csv'),
        'loans' : pd.read_csv(DATA_DIR / 'loans.csv'),
        'transaction_types' : pd.read_csv(DATA_DIR / 'transaction_types.csv'),
        'transactions' : pd.read_csv(DATA_DIR / 'transactions.csv')
    }

    return tables

# Validation checks
if __name__ == "__main__":

    tables =  extract_data()

    print(f"Loaded {len(tables)} tables.") # Expect 11

    for name, df in tables.items():
        print(f"{name}: {df.shape}")
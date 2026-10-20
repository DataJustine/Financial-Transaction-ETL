# Load libraries
from pathlib import Path

# Set directory
CLEAN_DIR = Path(__file__).parent.parent / 'Data' / 'Cleaned'

# Create function to export cleaned datasets
def export_data(tables):
    """
    Export cleaned DataFrames to CSV files.
    Args:
        tables(dict):
            Dictionary containing cleaned DataFrames.
    """

    for table_name, df in tables.items():

        df.to_csv(
            CLEAN_DIR / f"{table_name}_cleaned.csv",
            index=False
            )
        
        print(
            f"Exported {table_name}: "
            f"{df.shape}"
        )

# Validation check
if __name__ == "__main__":

    print(
        "This script is intended to export a "
        "dictionary of cleaned Dataframes."
    )
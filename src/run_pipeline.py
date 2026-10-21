# Create a pipeline to run all scripts

from extract import extract_data
from transform import transform_data
from export_cleaned_data import export_data

def run_pipeline():
    # Extract

    tables = extract_data()

    print('Extraction complete.')
    
    # Transform

    tables = transform_data(tables)
    
    print('Transformation complete.')
    
    # Export
    export_data(tables)
    
    print('Export complete.')

if __name__ == "__main__":

    run_pipeline()
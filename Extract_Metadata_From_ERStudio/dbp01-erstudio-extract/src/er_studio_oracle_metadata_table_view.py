"""
Extracts and formats table and view comments from ER/Studio metadata for physical models,
cleaning any RTF/HTML formatting, and generates combined SQL comment files for each model.
"""

import os
import pandas as pd
import re
from bs4 import BeautifulSoup
import logging
from db_connection import get_db_connection

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Define the list of physical models
physical_models = ['APT2', 'ADAM (FOR)', 'BEC', 'CBR', 'CLIENT', 'CNS', 'CSP', 'CONSEP', 'ECAS', 
                   'ERA', 'ESF', 'FNIRS', 'FSP', 'FTA', 'FTC', 'GAS2', 'GBMS', 'HBS', 'IAPP', 
                   'ILCR', 'ISP', 'LEXIS', 'LTRACK', 'MSD', 'NSA2', 'REPT', 'RESULTS', 
                   'SCS', 'SPAR', 'TSADMRPT']

# Fix paths to look in correct directories
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)  # Go up one level from src
SQL_DIR = os.path.join(PROJECT_ROOT, 'sql')
OUTPUT_ROOT = os.path.join(PROJECT_ROOT, 'output')

# Define a more comprehensive regex pattern
REGEX_PATTERN = r'{\\rtf1.*?(?:\\lang\d+\\f\d+\\fs\d+\s*|\\viewkind\d\\uc1\\pard\\cf\d\\lang\d+\\f\d+\\fs\d+\s*)'

# Step 1: Read SQL query from a file
def read_sql_file(file_path):
    full_path = os.path.join(SQL_DIR, file_path)
    with open(full_path, 'r') as file:
        sql_query = file.read()
    return os.path.basename(file_path), sql_query

# Step 2: Modify SQL query to include physical models
def insert_models_into_sql(sql_query, models):
    models_with_postfix = [f"'{model}_Physical'" for model in models]
    models_placeholder = ", ".join(models_with_postfix)
    return sql_query.format(models=models_placeholder)

# Step 3: Fetch metadata from ER/Studio
def fetch_metadata_from_er_studio(conn, sql_query):
    try:
        cursor = conn.cursor()
        cursor.execute(sql_query)
        results = cursor.fetchall()
        columns = [column[0] for column in cursor.description]
        cursor.close()
        return results, columns
    except Exception as e:
        logging.error(f"Error fetching metadata: {e}")
        raise

# Step 4: Use Beautiful Soup to clean up SQL results
def clean_metadata(metadata):
    cleaned_data = []
    cleaning_performed = False
    for row in metadata:
        cleaned_row = []
        for index, data in enumerate(row):
            if isinstance(data, (str, bytes)):
                try:
                    original_data = data
                    soup = BeautifulSoup(data, 'html.parser')
                    cleaned_text = soup.get_text()

                    # Use regex to remove RTF formatting
                    cleaned_text = re.sub(REGEX_PATTERN, '', cleaned_text, flags=re.DOTALL)

                    # Remove any occurrences of '\par' or '\par }'
                    cleaned_text = re.sub(r'\\par\s*}', '', cleaned_text)
                    cleaned_text = re.sub(r'\\par', '', cleaned_text)

                    # Remove any remaining RTF control words and their content
                    cleaned_text = re.sub(r'\\[a-z]+\d*', '', cleaned_text)
                    cleaned_text = re.sub(r'\{[^}]*\}', '', cleaned_text)

                    # Remove any remaining backslashes and extra spaces
                    cleaned_text = cleaned_text.replace('\\', '')
                    cleaned_text = ' '.join(cleaned_text.split())

                    if cleaned_text != original_data:
                        cleaning_performed = True

                    logging.info(f"Cleaned metadata (column {index}): {cleaned_text}")
                    cleaned_row.append(cleaned_text) 
                except Exception as e:
                    logging.error(f"An error occurred while parsing HTML in column {index}: {e}")
                    cleaned_row.append(data)
            else:
                logging.info(f"Skipping data in column {index} as it is not a string or bytes.")
                cleaned_row.append(data)
        cleaned_data.append(tuple(cleaned_row))
    return cleaned_data, cleaning_performed

# Modified function to write all comments to a single file in the specified folder
def write_all_comments(model, table_comments, view_comments):
    output_folder = os.path.join(OUTPUT_ROOT, "Get_Table_View_Comment_Statements_output")
    os.makedirs(output_folder, exist_ok=True)

    filename = f"{model}_all_comments.sql"
    file_path = os.path.join(output_folder, filename)

    def format_comment(comment):
        match = re.match(r"(COMMENT ON (?:TABLE|VIEW) .+? IS )'(.+)';", comment)
        if match:
            prefix = match.group(1)
            comment_text = match.group(2)
            # Remove any surrounding quotes and strip whitespace
            comment_text = comment_text.strip("'\"").strip()
            # Replace single quotes with double quotes for internal quotes
            comment_text = comment_text.replace("'", '"')
            # Wrap the entire comment in single quotes
            return f"{prefix}'{comment_text}';"
        return comment  # Return original if no match

    if table_comments or view_comments:
        with open(file_path, 'w', encoding='utf-8') as file:
            # Add SET DEFINE OFF at the top
            file.write("SET DEFINE OFF;\n\n")

            file.write(f"-- Table and View Comments for {model}\n\n")
            if table_comments:
                file.write("-- Table Comments\n")
                for comment in table_comments:
                    formatted_comment = format_comment(comment[0])
                    file.write(f"{formatted_comment}\n")
            if view_comments:
                file.write("\n-- View Comments\n")
                for comment in view_comments:
                    formatted_comment = format_comment(comment[0])
                    file.write(f"{formatted_comment}\n")

            # Add a newline for separation
            file.write("\n")
            
            # Add SET DEFINE ON at the bottom
            file.write("SET DEFINE ON;\n")

        logging.info(f"All comments for {model} written to {file_path}")
    else:
        logging.info(f"No comments found for {model}. Skipping file creation.")

# List of SQL files
sql_files = [
    'Get_Table_Comment_Statements_v2.sql',
    'Get_View_Comment_Statements_v2.sql'
]

# Main execution
def main():
    try:
        # Get database connection
        conn = get_db_connection()

        for model in physical_models:
            try:
                table_comments = []
                view_comments = []

                for sql_file in sql_files:
                    # Read SQL query from file
                    file_name, er_studio_sql_query = read_sql_file(sql_file)

                    # Insert model into SQL query
                    er_studio_sql_query_with_model = insert_models_into_sql(er_studio_sql_query, [model])

                    # Fetch metadata from ER/Studio
                    er_studio_metadata, columns = fetch_metadata_from_er_studio(conn, er_studio_sql_query_with_model)
                    
                    if er_studio_metadata:
                        cleaned_metadata, cleaning_performed = clean_metadata(er_studio_metadata)
                        if cleaning_performed:
                            logging.info(f"Cleaning was performed for {model} in {file_name}.")
                        else:
                            logging.info(f"No cleaning was necessary for {model} in {file_name}.")

                        # Append to appropriate list based on the SQL file
                        if 'Table' in file_name:
                            table_comments.extend(cleaned_metadata)
                        elif 'View' in file_name:
                            view_comments.extend(cleaned_metadata)

                # Write all comments to a single file
                write_all_comments(model, table_comments, view_comments)

            except Exception as e:
                logging.error(f"An error occurred for model {model}: {e}")

        conn.close()
        logging.info("Script execution completed successfully.")
    except Exception as e:
        logging.error(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
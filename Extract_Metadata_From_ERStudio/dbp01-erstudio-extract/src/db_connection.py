import pyodbc
import os
from dotenv import load_dotenv, dotenv_values
import logging

def get_db_connection():
    # Set up logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

    # Clear any existing Oracle-related environment variables
    oracle_env_vars = ['ORACLE_HOME', 'LD_LIBRARY_PATH', 'TNS_ADMIN', 'TWO_TASK', 'ORACLE_SID']
    for var in oracle_env_vars:
        if var in os.environ:
            del os.environ[var]
            logging.info(f"Cleared environment variable: {var}")

    # Load environment variables
    load_dotenv()
    env_vars = dotenv_values()

    # Mask password for logging
    def mask_password(password):
        return '*' * len(password) if password else None

    # Mask connection string for logging
    def mask_connection_string(conn_str):
        parts = conn_str.split(';')
        masked_parts = [part if not part.startswith('PWD=') else 'PWD=*****' for part in parts]
        return ';'.join(masked_parts)

    # Log environment variables (except password)
    logging.info(f"ORACLE_DRIVER: {env_vars.get('ORACLE_DRIVER')}")
    logging.info(f"ORACLE_DSN: {env_vars.get('ORACLE_DSN')}")
    logging.info(f"ORACLE_USER: {env_vars.get('ORACLE_USER')}")
    logging.info(f"ORACLE_PASSWORD: {mask_password(env_vars.get('ORACLE_PASSWORD'))}")
    logging.info(f"TNS_ADMIN: {env_vars.get('TNS_ADMIN')}")

    # Set TNS_ADMIN environment variable
    os.environ['TNS_ADMIN'] = env_vars.get('TNS_ADMIN')

    # Construct connection string
    connection_string = (
        f"DRIVER={{{env_vars.get('ORACLE_DRIVER')}}};"
        f"DBQ={env_vars.get('ORACLE_DSN')};"
        f"UID={env_vars.get('ORACLE_USER')};"
        f"PWD={env_vars.get('ORACLE_PASSWORD')}"
    )

    logging.info(f"Attempting to connect with: {mask_connection_string(connection_string)}")

    try:
        conn = pyodbc.connect(connection_string)
        logging.info("Connection successful!")
        verify_connection(conn)
        return conn
    except pyodbc.Error as e:
        logging.error(f"Connection failed: {str(e)}")
        raise

def verify_connection(conn):
    cursor = conn.cursor()
    
    # Get database name
    cursor.execute("SELECT SYS_CONTEXT('USERENV', 'DB_NAME') FROM DUAL")
    db_name = cursor.fetchone()[0]
    logging.info(f"Connected to database: {db_name}")

    # Get current user
    cursor.execute("SELECT USER FROM DUAL")
    current_user = cursor.fetchone()[0]
    logging.info(f"Connected as user: {current_user}")

    # Get instance name
    cursor.execute("SELECT SYS_CONTEXT('USERENV', 'INSTANCE_NAME') FROM DUAL")
    instance_name = cursor.fetchone()[0]
    logging.info(f"Connected to instance: {instance_name}")

    # Get service name
    cursor.execute("SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') FROM DUAL")
    service_name = cursor.fetchone()[0]
    logging.info(f"Connected to service: {service_name}")

    # Get server host
    cursor.execute("SELECT SYS_CONTEXT('USERENV', 'SERVER_HOST') FROM DUAL")
    server_host = cursor.fetchone()[0]
    logging.info(f"Connected to server host: {server_host}")

    cursor.close()

if __name__ == "__main__":
    try:
        connection = get_db_connection()
        # Add any test code here if needed
        connection.close()
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
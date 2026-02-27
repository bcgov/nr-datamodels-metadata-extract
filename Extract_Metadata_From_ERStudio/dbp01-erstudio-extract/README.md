# DBP01 ERStudio Metadata Extract scripts

These scripts were created to pull any column, view or table comments from ER Studio database to be inserted
into DBP01 operational database. The work was carried out with the help of DBA's. These scripts could be used
in future metadata extraction from ER Studio database to insert into operational databases.

## Folder Structure
```
    dbp01-erstudio-extract/
    ├── output/
    │   ├── Get_Column_Comment_Statements_output/
    │   │   └── {model}_column_comments.sql
    │   └── Get_Table_View_Comment_Statements_output/
    │       └── {model}_all_comments.sql
    ├── sql/
    │   ├── Get_Column_Comment_Statements_v2.sql
    │   ├── Get_Table_Comment_Statements_v2.sql
    │   └── Get_View_Comment_Statements_v2.sql
    ├── src/
    │   ├── __init__.py
    │   ├── db_connection.py
    │   ├── er_studio_oracle_metadata_column.py
    │   └── er_studio_oracle_metadata_table_view.py
    ├── .env_sample
    ├── .gitignore
    ├── Pipfile
    ├── Pipfile.lock
    ├── README.md
    └── requirements.txt
```

- `output/`: Contains generated SQL files for column, table, and view comments
- `sql/`: Contains the source SQL query files used to extract metadata
- `src/`: Contains the Python source code

## Prerequisites

- Python 3.11
- Required Python packages (refer to a requirements.txt or pipfile)
- Necessary permissions and credentials for Oracle database

## Installation

### Steps to set up the project outside of a development environment:

1. Clone the repository
   ```
   git clone https://github.com/bcgov/nr-datamodels-metadata-extract.git
   cd Extract_Metadata_From_ERStudio/Metadata-Extract
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt`
   ```

3. Set up configuration file:
    - `.env` (see .env.example) contains Oracle credentials. This file belongs in the route of the folder.

### Steps to set up the project using PIPENV:

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/openmetadata-tagging-project.git
   cd Extract_Metadata_From_ERStudio/Metadata-Extract
   ```

2. Ensure you have pipenv installed:
   ```
   pip install pipenv
   ```

3. Install dependencies using pipenv:
   ```
   pipenv install
   ```

4. Activate the pipenv shell:
   ```
   pipenv shell
   ```

5. Set up configuration file:
    - `.env` (see .env.example) contains Oracle credentials. This file belongs in the route of the folder.

## Usage

Running the python scripts will access the SQL scripts and the output will be generated as seperate folders in the ouput folder. Sub-folders
will be generated automatically if they do not exist.

After activating the pipenv shell run the following:

  ```
  python src/er_studio_oracle_metadata_columns.py
  ```
  And

  ```
  python src/er_studio_oracle_metadata_table_view.py
  ```

## Configuration

- Database connection details can be obtained via a service request to the DBA's if no username/password is known.

## License

      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.


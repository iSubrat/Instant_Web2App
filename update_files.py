import mysql.connector
import sys
import os

def replace_text_in_file(file_path, find_text, new_text):
    try:
        # Open the file in read mode
        with open(file_path, 'r') as file:
            lines = file.readlines()

        # Replace the line containing the find_text with the new_text
        updated_lines = [new_text if find_text in line else line for line in lines]

        # Open the file in write mode and write the updated data
        with open(file_path, 'w') as file:
            file.writelines(updated_lines)
        
        print(f"Text replaced successfully in {file_path}.")

    except FileNotFoundError:
        print(f"File {file_path} not found.")
    except Exception as e:
        print(f"An error occurred while replacing text in {file_path}: {e}")

def execute_query(db_host, db_username, db_password, db_database, query):
    global id, app_name, web_url, username, email_address
    try:
        # Connect to the MySQL server
        connection = mysql.connector.connect(
            host=db_host,
            user=db_username,
            password=db_password,
            database=db_database
        )

        if connection.is_connected():
            print("Connected to MySQL database")

        # Create a cursor object
        cursor = connection.cursor()

        # Execute the query
        cursor.execute(query)

        # Fetch all the rows
        row = cursor.fetchone()

        # Print the rows
        if row:
            id = row[0]
            app_name = row[1]
            web_url = row[2]
            username = row[3]
            email_address = row[5]
            print(id, app_name, web_url, username, email_address)
            
            # Update the status column to "Updated"
            update_query = "UPDATE app_data SET status = 'building' WHERE id = %s"
            cursor.execute(update_query, (id,))
            connection.commit()
            print("Status column updated to 'Updated'")

        # Close the cursor and connection
        cursor.close()
        connection.close()

    except mysql.connector.Error as e:
        print("Error executing query:", e)

if __name__ == "__main__":
    # MySQL database credentials temp
    host = os.environ['DB_HOST']
    username = os.environ['DB_USERNAME']
    password = os.environ['DB_PASSWORD']
    database = os.environ['DB_NAME']

    # Example query
    query = "SELECT * FROM app_data WHERE status IS NULL"

    # Execute the query
    execute_query(host, username, password, database, query)

    # Replace text in files
    file_path = ["android/app/src/main/AndroidManifest.xml", "lib/my_home_page.dart"]  # Replace with the path to your text file
    find_text = ["android:label=", "url: Uri.parse("]      # Replace with the text to be replaced
    new_text = [f'        android:label="{app_name}"\n', f"                  url: Uri.parse('{web_url}'),\n"]      # Replace with the new text
    for fp, ft, nt in zip(file_path, find_text, new_text):
        replace_text_in_file(fp, ft, nt)

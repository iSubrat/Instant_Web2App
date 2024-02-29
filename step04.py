import os
import re
import sys
import smtplib
import mysql.connector
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email(sender_email, sender_password, recipient_email, subject, message):
    try:
        email_host = os.environ['EMAIL_HOST']
        email_port = os.environ['EMAIL_PORT']
        # Setup the email message
        email_message = MIMEMultipart()
        email_message['From'] = sender_email
        email_message['To'] = recipient_email
        email_message['Subject'] = subject

        # Attach the message body
        email_message.attach(MIMEText(message, 'plain'))

        # Create SMTP session for sending the mail
        with smtplib.SMTP_SSL(email_host, email_port) as session:
            session.login(sender_email, sender_password)
            session.sendmail(sender_email, recipient_email, email_message.as_string())

        print("Email sent successfully!")
    except Exception as e:
        print(f"Error: {e}")


def execute_query(db_host, db_username, db_password, db_database, query):
    global id, appname, username, recipient_email
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
          pattern = re.compile(r'[^a-zA-Z0-9_]')
          appname = str(id).zfill(4) + '_' + pattern.sub('', row[1]) + '.apk'
          username = row[3]
          recipient_email = row[5]
          while cursor.nextset():
            pass
          email_username = os.environ['EMAIL_USERNAME']
          email_password = os.environ['EMAIL_PASSWORD']
          sender_email = email_username
          sender_password = email_password
          subject = 'Your App is Ready to Download'
          message = f'Hi,\n Please download your app by clicking link: https://appcollection.in/InstantWeb2App/downloads/{appname}'
        
          send_email(sender_email, sender_password, recipient_email, subject, message)

          # Update the status column to "Updated"
          update_query = "UPDATE app_data SET status = 'email sent' WHERE id = %s"
          cursor.execute(update_query, (id,))
          connection.commit()
          print("Status column updated to 'email sent'")
        else:
          raise RuntimeError("There is no app for build.")

        # Close the cursor and connection
        cursor.close()
        connection.close()

    except mysql.connector.Error as e:
        print("Error executing query:", e)

if __name__ == "__main__":
  try:
    # MySQL database credentials temp
    host = os.environ['DB_HOST']
    username = os.environ['DB_USERNAME']
    password = os.environ['DB_PASSWORD']
    database = os.environ['DB_NAME']

    # Example query
    query = "SELECT * FROM app_data WHERE status = 'built'"

    # Execute the query
    execute_query(host, username, password, database, query)
  except Exception as e:
    raise RuntimeError("Process Aborted.")

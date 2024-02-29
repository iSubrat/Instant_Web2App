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
        
        print("Text replaced successfully.")

    except FileNotFoundError:
        print("File not found.")
    except Exception as e:
        print("An error occurred:", e)

if __name__ == "__main__":
    app_name = "AppName0157"
    file_path = "android/app/src/main/AndroidManifest.xml"  # Replace with the path to your text file
    find_text = "android:label="      # Replace with the text to be replaced
    new_text = f'        android:label="{app_name}"\n'      # Replace with the new text
    replace_text_in_file(file_path, find_text, new_text)

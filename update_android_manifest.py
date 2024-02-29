import xml.etree.ElementTree as ET

def update_android_manifest(manifest_path):
    # Define the namespace
    ns_android = {"android": "http://schemas.android.com/apk/res/android"}

    # Parse the XML file
    tree = ET.parse(manifest_path)
    root = tree.getroot()

    # Find the application element
    application_element = root.find(".//application")

    # Update the android:label attribute
    application_element.set("{http://schemas.android.com/apk/res/android}label", "Subrat")

    # Write the changes back to the file
    tree.write(manifest_path, xml_declaration=True, encoding='utf-8')

if __name__ == "__main__":
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    update_android_manifest(manifest_path)

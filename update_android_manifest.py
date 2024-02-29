import xml.etree.ElementTree as ET

def update_android_manifest(manifest_path):
    # Parse the XML file
    tree = ET.parse(manifest_path)
    root = tree.getroot()

    # Find the application element
    application_element = root.find(".//application")

    # Update the android:label attribute
    application_element.set("android:label", "Subrat")

    # Write the changes back to the file
    tree.write(manifest_path)

if __name__ == "__main__":
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    update_android_manifest(manifest_path)

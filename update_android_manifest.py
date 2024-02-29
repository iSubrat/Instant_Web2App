import xml.etree.ElementTree as ET

# Path to AndroidManifest.xml
manifest_path = "android/app/src/main/AndroidManifest.xml"

def update_manifest():
    tree = ET.parse(manifest_path)
    root = tree.getroot()

    # Make changes to the XML tree as needed
    # For example, change the package name
    package_name = "com.example.newpackage"
    root.attrib["package"] = package_name

    # Write the changes back to the file
    tree.write(manifest_path)

if __name__ == "__main__":
    update_manifest()

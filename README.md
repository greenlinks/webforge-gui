# WebForge GUI

WebForge GUI is a PowerShell-based tool to generate personalized HTML pages with map details from Halo Waypoint. This tool allows you to fetch map details, input additional details, and generate a custom HTML page.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Next Steps](#next-steps)

## Features
- Fetches map details from Halo Waypoint links
- Allows input of additional details for each map
- Generates a custom HTML page with the provided details
- Customizable page title, background color, and personal link

## Prerequisites
- Windows operating system
- PowerShell 5.1 or later

## Installation
1. Download the repository files to your local machine.
2. Ensure all files are in the same directory.

## Usage
1. **Launch the Program**: Double-click the `Start_WebForge.bat` file to launch the WebForge GUI.

2. **Input Halo Waypoint Links**: 
    - Click the `Add Halo Waypoint Links` button.
    - In the new window, input the Halo Waypoint links, one per line.
    - Click `Fetch` to load the map details into the main window.

3. **Customize Map Details**:
    - In the main window, input additional details for each map in the respective columns (Detail 1, Detail 2, Detail 3).

4. **Set Page Customizations**:
    - Input the desired page title in the `Page Title` field.
    - Select a background color from the `Background Color` dropdown.
    - Input your personal link and link text in the respective fields.

5. **Generate HTML**:
    - Click the `Generate HTML` button to create the custom HTML page.
    - The generated `index.html` file will be saved in the same directory.
    - A `details.csv` file will also be created to store the map details. This CSV file is useful for subsequent HTML generations, so you don't have to re-enter all the details again.

## File Structure
- `MapDetailsGUI.ps1`: The main PowerShell script for the GUI.
- `MapDetailsGUI.xaml`: The XAML file defining the GUI layout.
- `Start_WebForge.bat`: A batch file to run the PowerShell script.
- `index.html`: The generated HTML file containing the custom map details.
- `details.csv`: A CSV file that stores map details, created when the HTML file is generated. This file helps in retaining the map details for future HTML generations, reducing the need to re-enter the information.

## Next Steps
1. **View the Generated HTML**:
    - Open the `index.html` file in your web browser to see your custom HTML page with the map details and your personal customizations.

2. **Share the HTML File**:
    - You can share the `index.html` file with others by sending it via email, sharing it through a cloud storage service, or uploading it to a web server.

3. **Host the HTML File**:
    - If you have a website or a web server, you can host the `index.html` file there to make it accessible online.
    - Upload the `index.html` file to your web server using FTP or your web hosting provider's file manager.
    - Ensure that the file is placed in the appropriate directory and accessible through a URL.

4. **Regenerate HTML with Updated Details**:
    - If you need to update the map details or customize the page further, you can re-run the WebForge GUI.
    - The `details.csv` file will help retain previously entered details, so you only need to update the necessary fields.
    - Click `Generate HTML` again to create an updated version of your `index.html` file.

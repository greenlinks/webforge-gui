Add-Type -AssemblyName PresentationFramework

[xml]$xaml = Get-Content -Path "MapDetailsGUI.xaml"

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Assign controls to variables
$showInputButton = $window.FindName("ShowInputButton")
$mapDetailsDataGrid = $window.FindName("MapDetailsDataGrid")
$generateHtmlButton = $window.FindName("GenerateHtmlButton")
$pageTitleTextBox = $window.FindName("PageTitleTextBox")
$personalLinkTextBox = $window.FindName("PersonalLinkTextBox")
$linkTextTextBox = $window.FindName("LinkTextTextBox")
$backgroundColorComboBox = $window.FindName("BackgroundColorComboBox")

# Data structure to hold map details
$mapDetails = New-Object System.Collections.ObjectModel.ObservableCollection[pscustomobject]

# Function to fetch map details
function Get-MapDetails {
    param ([string]$url)
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $html = $response.Content

        # Extract map name
        $mapName = if ($html -match '<title>(.*?)</title>') { $matches[1] -replace ' - Halo Infinite| - UGC', '' } else { "Unknown Map" }

        # Extract hero image URL
        $imgUrlMatch = [regex]::Match($html, '(https:\/\/blobs-infiniteugc\.svc\.halowaypoint\.com\/ugcstorage\/map\/.*?\/images\/thumbnail\.jpg)')
        $imgUrl = if ($imgUrlMatch.Success) { $imgUrlMatch.Value -replace 'thumbnail.jpg', 'hero.jpg' } else { "https://via.placeholder.com/200x200?text=No+Image" }

        return @{
            Name = $mapName
            ImgUrl = $imgUrl
            URL = $url
            Detail1 = ""
            Detail2 = ""
            Detail3 = ""
        }
    }
    catch {
        [System.Windows.MessageBox]::Show("Failed to get details for $url")
        return $null
    }
}

# Function to load existing details from details.csv
function LoadExistingDetails {
    param ([string]$filePath)
    if (-not (Test-Path $filePath)) {
        return @{}
    }

    $details = @{}
    Import-Csv -Path $filePath | ForEach-Object {
        $details[$_.Name] = @{
            Detail1 = $_.Detail1
            Detail2 = $_.Detail2
            Detail3 = $_.Detail3
        }
    }
    return $details
}

# Function to show input dialog for URLs
function ShowInputDialog {
    Add-Type -AssemblyName PresentationFramework

    $inputWindow = New-Object Windows.Window
    $inputWindow.Title = "Input HaloWaypoint Links"
    $inputWindow.Width = 800
    $inputWindow.Height = 600
    $inputWindow.WindowStartupLocation = "CenterScreen"
    $inputWindow.WindowStyle = "ToolWindow"

    $stackPanel = New-Object Windows.Controls.StackPanel
    $stackPanel.Margin = 10

    $textBox = New-Object Windows.Controls.TextBox
    $textBox.AcceptsReturn = $true
    $textBox.VerticalScrollBarVisibility = "Auto"
    $textBox.TextWrapping = "Wrap"
    $textBox.Height = 500
    $stackPanel.Children.Add($textBox)

    $button = New-Object Windows.Controls.Button
    $button.Content = "Fetch"
    $button.Margin = "0,10,0,0"
    $button.HorizontalAlignment = "Center"
    $stackPanel.Children.Add($button)

    $button.Add_Click({
        $urls = $textBox.Text -split "`r`n"
        $existingDetails = LoadExistingDetails -filePath "details.csv"
        foreach ($url in $urls) {
            $mapInfo = Get-MapDetails -url $url
            if ($mapInfo) {
                if ($existingDetails.ContainsKey($mapInfo.Name)) {
                    $mapInfo.Detail1 = $existingDetails[$mapInfo.Name].Detail1
                    $mapInfo.Detail2 = $existingDetails[$mapInfo.Name].Detail2
                    $mapInfo.Detail3 = $existingDetails[$mapInfo.Name].Detail3
                }
                $mapDetails.Add([pscustomobject]@{
                    Name = $mapInfo.Name
                    ImgUrl = $mapInfo.ImgUrl
                    URL = $url
                    Detail1 = $mapInfo.Detail1
                    Detail2 = $mapInfo.Detail2
                    Detail3 = $mapInfo.Detail3
                })
            }
        }

        $mapDetailsDataGrid.Items.Refresh()
        $inputWindow.Close()
    })

    $inputWindow.Content = $stackPanel
    $inputWindow.ShowDialog()
}

# Event handler for Show Input Button
$showInputButton.Add_Click({
    ShowInputDialog
})

# Event handler for Generate HTML button
$generateHtmlButton.Add_Click({
    $pageTitle = $pageTitleTextBox.Text
    $personalLink = $personalLinkTextBox.Text
    $linkText = $linkTextTextBox.Text
    $backgroundColor = $backgroundColorComboBox.SelectedItem.Background.ToString()
    $backgroundColor = $backgroundColor -replace "System.Windows.Media.Color ", ""

    # Remove the "FF" prefix if present
    if ($backgroundColor -match '^#FF') {
        $backgroundColor = $backgroundColor -replace '^#FF', '#'
    }

    # Default background color if none selected
    if (-not $backgroundColor) {
        $backgroundColor = "#0F0F0F"
    }

    # Ensure personal link starts with http:// or https://
    if ($personalLink -notmatch '^https?://') {
        $personalLink = "http://$personalLink"
    }

    # Save details to CSV file
    $csvContent = @()
    foreach ($map in $mapDetails) {
        $csvContent += [pscustomobject]@{
            Name = $map.Name
            Detail1 = $map.Detail1
            Detail2 = $map.Detail2
            Detail3 = $map.Detail3
        }
    }
    $csvContent | Export-Csv -Path "details.csv" -NoTypeInformation

    # Generate HTML content
    $htmlContent = @"
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <link href='https://fonts.googleapis.com/css?family=Rajdhani' rel='stylesheet'>
    <title>$pageTitle</title>
    <style>
        body {
            font-family: 'Rajdhani', sans-serif;
            font-weight: bold;
            background-color: $backgroundColor;
            color: #E0E0E0;
            margin: 0;
            padding: 20px;
        } 
        h1 {
            text-align: center;
            color: #FFFFFF;
            margin-bottom: 20px;
        }
        footer {
            text-align: center;
            width: 100%;
            padding: 10px 0; 
        }
        .container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        .tile {
            background-color: #1A1A1A;
            border: 1px solid #FFFFFF;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            position: relative;
            cursor: pointer;
        }
        .tile::before {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            border: 4px solid transparent;
            transition: border-color 0.3s;
            z-index: 5;
        }
        .tile:hover::before {
            border-color: #FFFFFF;
        }
        .tile:hover {
            transform: translateY(-5px);
            box-shadow: 0 0 30px rgba(255, 255, 255, 0.3);
        }
        .tile .content {
            padding: 10px;
            font-size: 20px;
            background-color: rgba(0, 0, 0, 0.75);
            position: absolute;
            bottom: 0;
            width: 100%;
            text-align: left;
            transition: background-color 0.3s, color 0.3s;
            z-index: 6;
        }
        .tile:hover .content {
            background-color: #FFFFFF;
            color: #0F0F0F;
        }
        .tile img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            display: block;
        }
        .tile .hover-text {
            position: absolute;
            top: 10px;
            left: 10px;
            color: white;
            font-size: 14px;
            background-color: rgba(0, 0, 0, 0.3);
            padding: 10px;
            opacity: 0;
            transition: opacity 0.3s;
            z-index: 7;
        }
        .tile:hover .hover-text {
            opacity: 1;
        }
        .hover-text ul {
            list-style-type: disc;
            padding-left: 15px;
            margin: 0;
        }
    </style>
    <script>
        function isTouchDevice() {
            return 'ontouchstart' in window || navigator.maxTouchPoints;
        }

        function toggleOverlay(event) {
            var tile = event.currentTarget;
            var link = tile.querySelector('a');
            if (isTouchDevice()) {
                var isActive = tile.classList.contains('active');
                var tiles = document.querySelectorAll('.tile');
                tiles.forEach(function(t) {
                    t.classList.remove('active');
                });
                if (!isActive) {
                    tile.classList.add('active');
                    event.preventDefault();
                } else {
                    window.location = link.href;
                }
            } else {
                window.location = link.href;
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            var tiles = document.querySelectorAll('.tile');
            tiles.forEach(function(tile) {
                tile.addEventListener('click', toggleOverlay);
            });
        });
    </script>
</head>
<body>

    <h1>$pageTitle</h1>
    <div class="container">
"@

    foreach ($map in $mapDetails) {
        $htmlContent += @"
        <div class='tile'>
            <img src='$($map.ImgUrl)' alt='$($map.Name)'>
            <div class='content'>$($map.Name)</div>
            <div class='hover-text'>
                <ul>
"@
        if ($map.Detail1) { $htmlContent += "<li>$($map.Detail1)</li>" }
        if ($map.Detail2) { $htmlContent += "<li>$($map.Detail2)</li>" }
        if ($map.Detail3) { $htmlContent += "<li>$($map.Detail3)</li>" }
        $htmlContent += @"
                </ul>
            </div>
            <a href='$($map.URL)'></a>
        </div>
"@
    }

    $htmlContent += @"
    </div>
    <footer>
        <p>&copy; 2024 <a href='$personalLink' target='_blank' style='color: white; text-decoration: none;'>$linkText</a></p>
    </footer>
</body>
</html>
"@

    Set-Content -Path "index.html" -Value $htmlContent
    [System.Windows.MessageBox]::Show("HTML file generated successfully.")
})

# Set the data context for data binding
$mapDetailsDataGrid.ItemsSource = $mapDetails

# Show the window
$window.ShowDialog()

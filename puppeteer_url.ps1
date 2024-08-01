# Import Excel COM object
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

# Replace 'your_excel_file.xlsx' with your actual file path
$workbook = $excel.Workbooks.Open("F:\test\siteurls.xlsx")
$worksheet = $workbook.Worksheets.Item(1) # Assuming data is in the first sheet

# Get all URLs from the first column, skipping null or empty values
$urls = @()
for ($row = 2; $row -le $worksheet.UsedRange.Rows.Count; $row++) {
    $url = $worksheet.Cells.Item($row, 1).Value2
    if ($url -and $url.Trim() -ne "") {
        $urls += $url
    }
}

# Create JS files for each URL
$counter = 0
foreach ($url in $urls) {
    $uri = [uri]$url
    $baseUrl = $uri.Scheme + "://" + $uri.Host
    $firstSegment = $uri.AbsolutePath.Split('/')[1]
    $filePath = $firstSegment +"_" + "$counter.js"
    $counter +=1

    $content = @"
module.exports = {
    url: '$url',
    actions: []
};
"@

    [IO.File]::WriteAllText($filePath, $content)
}

# Close Excel
$workbook.Close($false)
$excel.Quit()
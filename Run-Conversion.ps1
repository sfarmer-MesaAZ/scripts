# Import the main script
. "C:\Scripts\Convert-TerminationReport.ps1"

# Set your paths
$excelPath = "F:\OneDrive - City of Mesa\Documents\Novemeber.xlsx"
$csvPath = "F:\Temp\Output.csv"

# Run the conversion
$result = Start-ExcelConversion -InputPath $excelPath -OutputPath $csvPath

# Show the result
if ($result) {
    Write-Host "Conversion completed successfully" -ForegroundColor Green
} else {
    Write-Host "Conversion failed" -ForegroundColor Red
}
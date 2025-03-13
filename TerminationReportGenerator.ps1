#  Generates a csv file from source Excel files supplied by Mary Cash's termination reports. 
#  The subsequent csv can then be uploaded to HubEngage to process terminations
#  USAGE: .\TerminationReportGenerator.ps1 -InputPath "F:\TEMP\HubEngage\Sep 2024.xlsx"  
#
#
#
#
param (
    [Parameter(Mandatory = $true)]
    [string]$InputPath
)

# Check if ImportExcel module is installed
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "Installing ImportExcel module..." -ForegroundColor Yellow
    try {
        Install-Module -Name ImportExcel -Scope CurrentUser -Force
    }
    catch {
        Write-Error "Failed to install ImportExcel module. Please install it manually using: Install-Module -Name ImportExcel -Scope CurrentUser"
        exit 1
    }
}

try {
    # Validate input file
    if (-not (Test-Path $InputPath)) {
        Write-Error "Input file does not exist: $InputPath"
        exit 1
    }
    
    $extension = [System.IO.Path]::GetExtension($InputPath)
    if ($extension -notin @('.xlsx', '.xls')) {
        Write-Error "Input file is not an Excel file: $InputPath"
        exit 1
    }
    
    # Generate output path (same location and name as input, but with .csv extension)
    $OutputPath = [System.IO.Path]::ChangeExtension($InputPath, ".csv")
    
    # Import Excel file and validate required columns
    $excelData = Import-Excel -Path $InputPath
    $requiredColumns = @('User Name', 'Emp ID')
    $missingColumns = $requiredColumns | Where-Object { $excelData[0].PSObject.Properties.Name -notcontains $_ }
    
    if ($missingColumns) {
        Write-Error "Missing required columns: $($missingColumns -join ', ')"
        exit 1
    }
    
    # Create an array to store the transformed data
    $transformedData = @()
    $rowCount = 0
    $skippedCount = 0
    
    # Process each row
    foreach ($row in $excelData) {
        # Check if row has content
        if ([string]::IsNullOrWhiteSpace($row.'User Name') -or 
            [string]::IsNullOrWhiteSpace($row.'Emp ID')) {
            $skippedCount++
            continue
        }
        
        # Split User Name into first and last name
        $nameParts = $row.'User Name'.Trim() -split '\s+', 2
        $firstName = $nameParts[0]
        $lastName = if ($nameParts.Count -gt 1) { $nameParts[1] } else { '' }
        
        # Clean and validate employee ID
        $employeeId = $row.'Emp ID'.ToString().Trim()
        
        $transformedRow = [PSCustomObject]@{
            'first_name'  = $firstName
            'last_name'   = $lastName
            'employee_id' = $employeeId
            'status'      = 'terminated'
        }
        $transformedData += $transformedRow
        $rowCount++
    }
    
    # Export to CSV if we have data
    if ($rowCount -gt 0) {
        $transformedData | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        Write-Host "Successfully converted Excel file to CSV" -ForegroundColor Green
        Write-Host "Input:  $InputPath" -ForegroundColor Cyan
        Write-Host "Output: $OutputPath" -ForegroundColor Cyan
        Write-Host "Processed $rowCount rows" -ForegroundColor Green
        if ($skippedCount -gt 0) {
            Write-Host "Skipped $skippedCount empty rows" -ForegroundColor Yellow
        }
    }
    else {
        Write-Warning "No valid data rows found in the Excel file. CSV file was not created."
        exit 1
    }
    
    exit 0
}
catch {
    Write-Error "Error during conversion: $_"
    exit 1
}
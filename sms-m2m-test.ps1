
# ==========================================================  READ ME ================================================= 
#Run the Script:
# To use the default values: ./api_request.ps1
# To specify custom values: ./api_request.ps1 -IntervalSeconds 30 -DurationMinutes 5 -LogFilePath "my_log.txt"
# Any combination of the parameters can be used.
# Check the Log File: The log file (either api_requests.log or the file you specified) will contain a record of the API requests and any errors that occurred.



# Parameters
param (
    [int]$IntervalSeconds = 60,  # Default interval: 60 seconds
    [int]$DurationMinutes = 10,  # Default duration: 10 minutes
    [string]$LogFilePath = "api_requests.log" #Default log file name
)


# Configuration
$apiUrl = 'https://prod-readyalertapi.azurewebsites.net/api/v1/SMS/send-m2m-sms?email=steven.farmer@mesaaz.gov&message=Test From PowerShell Script&apikey={{x-apikey}}'
$apiKey = '3ea3b13c-759a-4c4d-8627-129d0fcac000' # Replace with your API key
# $intervalSeconds = 60 # Interval between requests in seconds
# $durationMinutes = 10 # Total duration in minutes

# Calculate end time
$endTime = (Get-Date).AddMinutes($durationMinutes)

# Headers
$headers = @{
    'accept' = 'text/plain'
    'Cookie' = 'ARRAffinity=d273fa9c81fcefc26424831206db7c9a53438f63ff81522c252c356dd5edc78f; ARRAffinitySameSite=d273fa9c81fcefc26424831206db7c9a53438f63ff81522c252c356dd5edc78f'
}

# Replace placeholder in API URL
$apiUrl = $apiUrl.Replace('{{x-apikey}}', $apiKey)

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    Add-Content -Path $LogFilePath -Value $LogEntry
    Write-Host $LogEntry
}


# Loop until end time
while ((Get-Date) -lt $endTime) {
    try {
        # Invoke the REST API
        Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -ErrorAction Stop
        Log-Message "API request successful."
        Write-Host "$(Get-Date) - API request successful."
    }
    catch {
        Log-Message "API request failed: $($_.Exception.Message)"
        Write-Error "$(Get-Date) - API request failed: $($_.Exception.Message)"
    }

    # Wait for the specified interval
    Start-Sleep -Seconds $intervalSeconds
}

Log-Message "Script execution completed."
Write-Host "Script execution completed."
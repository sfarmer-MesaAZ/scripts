







## LISTDIR ##

.\script.ps1 -path "C:\Users\YourUserName\Documents" -recursive


This will create a file named "directory_list_YYYYMMDD.txt" in the "C:\Users\YourUserName\Documents" directory, containing a list of all subdirectories recursively.

To scan only the first level of directories:

PowerShell
.\script.ps1 -path "C:\Users\YourUserName\Documents"
Use code with caution.

This will create a file containing only the immediate subdirectories of "C:\Users\YourUserName\Documents".

Note: Replace .\script.ps1 with the actual path to your script.

Additional considerations:

For large directories, recursive scanning might take a long time.

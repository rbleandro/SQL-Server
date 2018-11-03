# This powershell script runs query converts results to Excel spreadsheet
# Copy contents of this script / download this script and save it to c:\Scripts, 
# use sqlps.exe to run this script
# sqlps.exe c:\scripts\QueryResultsToExcel.ps1
$query = "select SERVERPROPERTY('ServerName') As ServerName, Name, crdate from sysdatabases"

$csvFilePath = "c:\queryresults.csv"
$excelFilePath = "c:\queryresults.xls"

# Run Query against multiple servers, combine results
# Replace ".", with names of your SQL Server instances Example  machineName\instance1
$instanceName = "10.128.65.167,2103"
$DB = "tfs_nova.com"
#$results = Invoke-Sqlcmd -ServerInstance $instanceName -InputFile "c:\RelCodeReview.sql" -Database $DB
$results = Invoke-Sqlcmd -ServerInstance $instanceName -Query $query -Database $DB

# Output to CSV
write-host "Saving Query Results in CSV format..." 
$results | export-csv  $csvFilePath   -NoTypeInformation

# Convert CSV file to Excel
# Reference : http://gallery.technet.microsoft.com/scriptcenter/da4c725e-3487-42ff-862f-c022cf09c8fa
write-host "Converting CSV output to Excel..." 

$excel = New-Object -ComObject excel.application 
$excel.visible = $False 
$excel.displayalerts=$False 
$workbook = $excel.Workbooks.Open($csvFilePath) 
$workSheet = $workbook.worksheets.Item(1) 
$resize = $workSheet.UsedRange 
$resize.EntireColumn.AutoFit() | Out-Null 
$xlExcel8 = 56
$workbook.SaveAs($excelFilePath,$xlExcel8) 
$workbook.Close()
$excel.quit() 
$excel = $null

write-host "Results are saved in Excel file: " $excelFilePath


# This posting is provided "AS IS" with no warranties, and confers no rights. 


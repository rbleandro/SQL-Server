@echo off

"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd" -S "10.128.65.167,2103" -d "tfs_nova.com" -E -s, -W -i "c:\RelCodeReview.sql" | findstr /V /C:"-" /B > "c:\ExcelTest.csv"

DECLARE @ExportSQL nvarchar(max);
SET @ExportSQL = 'EXEC ..xp_cmdshell ''bcp "exec master..generateSecAuditReport " queryout "C:\SecAudit\secAuditDetailed.csv" -T -c -t, -S '+CONVERT(sysname, SERVERPROPERTY('servername'))+''''
--PRINT @ExportSQL
Exec(@ExportSQL)
GO
/*
DECLARE @ExportSQL nvarchar(max);
SET @ExportSQL = 'EXEC ..xp_cmdshell ''C:\progra~1\Micros~1\110\Tools\Binn\bcp "exec master..generateSecAuditReport" queryout "C:\SecAudit\secAuditDetailed.csv" -T -c -t, -S '+CONVERT(sysname, SERVERPROPERTY('servername'))+''''
--PRINT @ExportSQL
Exec(@ExportSQL)
GO
*/
--DECLARE @ExportSQL nvarchar(max);
--SET @ExportSQL = 'EXEC ..xp_cmdshell ''compact /c C:\SecAudit\secAuditDetailed.csv'''
--Exec(@ExportSQL)
--GO


--SELECT * FROM master..sysservers

--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].AdministradorAltera') AND type IN (N'P', N'PC'))
--BEGIN
--EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].AdministradorAltera AS' 
--END
--GO

--SELECT CONVERT(sysname, SERVERPROPERTY('servername')) --returns full instance name

--EXEC msdb.dbo.sp_start_job @job_name = 'Adela_User_List'
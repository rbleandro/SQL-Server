--DECLARE @Profile VARCHAR(100);
--SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile);

--EXEC msdb.dbo.sp_send_dbmail
--    @recipients='Adela.Magopat@loomis-express.com;Servicedesk@loomis-express.com;CANPARDatabaseAdministratorsStaffList@canpar.com', 
--    @subject='SQL USER LIST', 
--    @profile_name=@Profile,
--    @body='Hi Adela, Attach is the Sql user list. Thanks',
--    @query ='SELECT name FROM sys.server_principals WHERE TYPE = "S" and name not like "%##%"',
--    @attach_query_result_as_file = 1,
--    @query_attachment_filename = 'Sql_User_list.csv',
--    @query_result_separator = ',',
--    @query_result_header = 1

------------------ BELOW IS THE NEW LOGIC WHICH RETURNS MORE USERS' PERMISSIONS DETAIL
-- Generating info about users' permissions per database

DECLARE @ExportSQL nvarchar(max);
SET @ExportSQL = 'EXEC ..xp_cmdshell ''bcp "exec master..generateSecAuditReport " queryout "C:\SecAudit\secAuditDetailed.csv" -T -c -t, -S HQVNOCSQL1\SQL'''
Exec(@ExportSQL)
GO

-- Sending the email
DECLARE @Profile VARCHAR(100),@bod VARCHAR(2000)
SET @bod='Hi Adela, attached is the Sql users list and their permissions on each database. Also attached is a list of all sysadmin users on this instance (' + @@servername + ') . Thanks';
SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile);

EXEC msdb.dbo.sp_send_dbmail
    @recipients='Adela.Magopat@loomis-express.com;Servicedesk@loomis-express.com;CANPARDatabaseAdministratorsStaffList@canpar.com', 
    --@recipients='rleandro@canpar.com',
    @subject='SQL USER LIST', 
    @profile_name=@Profile,
    @body=@bod,
    @query ='SELECT sp.name FROM sys.server_role_members rm ,sys.server_principals sp WHERE rm.role_principal_id = SUSER_ID(''Sysadmin'') AND rm.member_principal_id = sp.principal_id ORDER BY sp.name',
    @attach_query_result_as_file = 1,
    @query_attachment_filename = 'Sql_Admin_User_list.csv',
    @file_attachments='C:\SecAudit\secAuditDetailed.csv'


--SELECT 'Name' = sp.NAME,sp.is_disabled AS [Is_disabled] FROM sys.server_role_members rm ,sys.server_principals sp WHERE rm.role_principal_id = SUSER_ID('Sysadmin') AND rm.member_principal_id = sp.principal_id ORDER BY sp.name
--GO

--DECLARE @ExportSQL nvarchar(max);
--SET @ExportSQL = 'SELECT sp.name,sp.is_disabled FROM sys.server_role_members rm ,sys.server_principals sp WHERE rm.role_principal_id = SUSER_ID(''Sysadmin'') AND rm.member_principal_id = sp.principal_id ORDER BY sp.name'
--Exec(@ExportSQL)

--EXEC sys.sp_executesql N'EXEC ..xp_cmdshell ''bcp "exec master..uspGetPermissionsOfAllLogins_DBsOnColumns " queryout "C:\SecAudit\secAuditSummary.csv" -T -c -t, -S HQVNOCSQL1\SQL'''


--EXEC sys.sp_configure 'show adv',0
--RECONFIGURE
--EXEC sys.sp_configure 'xp_cmdshell'

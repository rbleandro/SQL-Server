USE [msdb]
GO

/****** Object:  Job [Adela_User_List]    Script Date: 3/8/2019 4:00:32 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/8/2019 4:00:32 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Adela_User_List', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Generates a list of all users and their permissions accross all databases for auditing purposes.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA Group', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute_Statement]    Script Date: 3/8/2019 4:00:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute_Statement', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--DECLARE @Profile VARCHAR(100);
--SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile);

--EXEC msdb.dbo.sp_send_dbmail
--    @recipients=''Adela.Magopat@loomis-express.com;Servicedesk@loomis-express.com;CANPARDatabaseAdministratorsStaffList@canpar.com'', 
--    @subject=''SQL USER LIST'', 
--    @profile_name=@Profile,
--    @body=''Hi Adela, Attach is the Sql user list. Thanks'',
--    @query =''SELECT name FROM sys.server_principals WHERE TYPE = "S" and name not like "%##%"'',
--    @attach_query_result_as_file = 1,
--    @query_attachment_filename = ''Sql_User_list.csv'',
--    @query_result_separator = '','',
--    @query_result_header = 1

------------------ BELOW IS THE NEW LOGIC WHICH RETURNS MORE USERS'' PERMISSIONS DETAIL
-- Generating info about users'' permissions per database

DECLARE @ExportSQL nvarchar(max);
SET @ExportSQL = ''EXEC ..xp_cmdshell ''''bcp "exec master..generateSecAuditReport " queryout "C:\SecAudit\secAuditDetailed.csv" -T -c -t, -S HQVNOCSQL1\SQL''''''
Exec(@ExportSQL)
GO

-- Sending the email
DECLARE @Profile VARCHAR(100),@bod VARCHAR(2000)
SET @bod=''Hi Adela, attached is the Sql users list and their permissions on each database. Also attached is a list of all sysadmin users on this instance ('' + @@servername + '') . Thanks'';
SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile);

EXEC msdb.dbo.sp_send_dbmail
    @recipients=''Adela.Magopat@loomis-express.com;Servicedesk@loomis-express.com;CANPARDatabaseAdministratorsStaffList@canpar.com'', 
    --@recipients=''rleandro@canpar.com'',
    @subject=''SQL USER LIST'', 
    @profile_name=@Profile,
    @body=@bod,
    @query =''SELECT sp.name FROM sys.server_role_members rm ,sys.server_principals sp WHERE rm.role_principal_id = SUSER_ID(''''Sysadmin'''') AND rm.member_principal_id = sp.principal_id ORDER BY sp.name'',
    @attach_query_result_as_file = 1,
    @query_attachment_filename = ''Sql_Admin_User_list.csv'',
    @file_attachments=''C:\SecAudit\secAuditDetailed.csv''
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 90 Days', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=9, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=1, 
		@freq_recurrence_factor=3, 
		@active_start_date=20160615, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=235959, 
		@schedule_uid=N'615927da-72c5-46fc-8b20-0cda2aca81b8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO



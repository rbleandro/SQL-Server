SELECT * FROM MSDB.dbo.sysmail_profile
SELECT * FROM MSDB.dbo.sysmail_profileaccount
SELECT TOP 10 * FROM msdb.dbo.sysmail_account
SELECT TOP 10 * FROM msdb.dbo.sysmail_server 
SELECT @@SERVERNAME

IF NOT EXISTS(SELECT * FROM msdb.dbo.sysoperators WHERE name='DBA Group')
EXEC msdb.dbo.sp_add_operator @name=N'DBA Group', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'CANPARDatabaseAdministratorsStaffList@canpar.com', 
		@category_name=N'[Uncategorized]'
GO

IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE name='SMTP')
	EXECUTE msdb.dbo.sysmail_add_profile_sp @profile_name = 'SMTP',@description = '' --CREATING DATABASE MAIL PROFILE

declare @server varchar(100),@emailadd VARCHAR(500)
set @server = replace(@@servername,'\','-')
set @emailadd = @server+'@canpar.com'

IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE name='SMTP')
	EXECUTE msdb.dbo.sysmail_add_account_sp 
		@account_name = 'SMTP',
		@description = 'DEFAULT MAIL ACCOUNT',
		@email_address = @emailadd
		,@mailserver_type = 'SMTP',
		@replyto_address = '',
		@display_name = @server,
		@mailserver_name = 'smtp.canpar.com' ; --CREATING DATABASE MAIL ACCOUNT

IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profileaccount)
	EXEC msdb.dbo.sysmail_add_profileaccount_sp @profile_name = 'SMTP', @account_name = 'SMTP', @sequence_number = '1' -- associating accounts to profiles

IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_principalprofile)
	EXECUTE msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SMTP',@principal_name = 'public',@is_default = 1 ; -- associating principals to profile

EXEC sys.sp_configure @configname = 'show adv',@configvalue=1
RECONFIGURE
EXEC sys.sp_configure @configname = 'Database Mail XPs', @configvalue = 1
RECONFIGURE

USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N'DBA Group', @notificationmethod=1
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, @databasemail_profile=N'SMTP', @use_databasemail=1
GO

EXEC sys.sp_configure @configname = 'show adv',@configvalue=0
RECONFIGURE

--send test email
DECLARE @Destinatarios VARCHAR(500)='rleandro@canpar.com';    
DECLARE @Assunto VARCHAR(500)='test';    
DECLARE @Profile VARCHAR(100);    
SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile); 
EXEC msdb.dbo.sp_send_dbmail    
		@profile_name = @Profile    
		,@body = 'testing'
		,@recipients = @Destinatarios    
		,@subject = @Assunto    


--changing properties of the mail account
EXEC msdb.dbo.sysmail_update_account_sp @account_id = 1,                 -- int
                                        --@account_name = NULL,            -- sysname
                                        --@email_address = N'',            -- nvarchar(128)
                                        --@display_name = N'',             -- nvarchar(128)
                                        --@replyto_address = N'',          -- nvarchar(128)
                                        --@description = N'',              -- nvarchar(256)
                                        @mailserver_name = 'smtp.canpar.com',         -- sysname
                                        @mailserver_type = 'SMTP'         -- sysname
                                        --,@port = 25,                       -- int
                                        --@username = NULL,                -- sysname
                                        --@password = NULL,                -- sysname
                                        --@use_default_credentials = NULL, -- bit
                                        --@enable_ssl = NULL,              -- bit
                                        --@timeout = 0,                    -- int
                                        --@no_credential_change = NULL     -- bit

										


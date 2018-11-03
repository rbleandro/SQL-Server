SELECT * FROM MSDB.dbo.sysmail_profile
SELECT * FROM MSDB.dbo.sysmail_profileaccount
SELECT TOP 10 * FROM msdb.dbo.sysmail_account
SELECT TOP 10 * FROM msdb.dbo.sysmail_server 

EXECUTE msdb.dbo.sysmail_add_profile_sp @profile_name = 'SMTP',@description = '' --CREATING DATABASE MAIL PROFILE

EXECUTE msdb.dbo.sysmail_add_account_sp 
    @account_name = 'SMTP',
    @description = 'DEFAULT MAIL ACCOUNT',
    @email_address = 'CPRHQVCRMSQL01@canpar.com',@mailserver_type = 'SMTP',
    @replyto_address = '',
    @display_name = 'CPRHQVCRMSQL01',
    @mailserver_name = 'smtp.canpar.com' ; --CREATING DATABASE MAIL ACCOUNT


EXEC msdb.dbo.sysmail_add_profileaccount_sp @profile_name = 'SMTP', @account_name = 'SMTP', @sequence_number = '1' -- associating accounts to profiles
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SMTP',@principal_name = 'public',@is_default = 1 ; -- associating principals to profile

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

										


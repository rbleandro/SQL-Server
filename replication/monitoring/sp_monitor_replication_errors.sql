USE Distribution
go
SET NOCOUNT ON;
GO
IF OBJECT_ID('repl_alert_control') IS NULL
	CREATE TABLE repl_alert_control (repl VARCHAR(50) NOT NULL	CONSTRAINT pk_repl_alert_control PRIMARY KEY (repl), last_error DATETIME2,id BIGINT);
GO
	
IF NOT EXISTS(SELECT TOP 10 * FROM dbo.repl_alert_control WHERE repl='SQL-Replication')
INSERT dbo.repl_alert_control
(
    repl,
    last_error,
    id
)
VALUES
(   'SQL-Replication',            -- repl - varchar(10)
    sysdatetime(), -- last_error - datetime2
    0              -- id - bigint
    );

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].sp_monitor_replication_errors') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].sp_monitor_replication_errors AS' 
END
GO
ALTER PROCEDURE dbo.sp_monitor_replication_errors
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @extraction DATETIME2, @new_extraction DATETIME2=SYSDATETIME(); SET @extraction = (SELECT last_error FROM repl_alert_control WHERE repl = 'SQL-Replication');
	DECLARE @Destinatarios VARCHAR(500);
	DECLARE @Assunto       VARCHAR(500);
	DECLARE @Profile       VARCHAR(100);
	DECLARE @MsgBody NVARCHAR(MAX)

	SET @Profile = 'SMTP';
	SET @Destinatarios = 'CANPARDatabaseAdministratorsStaffList@canpar.com'
	--SET @Destinatarios = 'rleandro@canpar.com'
	SET @Assunto = 'Replication errors';

	SELECT [time],error_code, error_text,command_id,xact_seqno 
	INTO #repl_errors
	FROM Distribution.dbo.MSrepl_errors 
	WHERE time > @extraction 
	AND error_code NOT IN ('20525','2627') 
	AND error_text NOT LIKE '%NOC_LMCDB_Pub%'
	AND error_text NOT LIKE '%The process could not execute%'
	AND error_text NOT LIKE 'TCP Provider:%'
	AND error_text NOT LIKE 'Communication link failure'
	AND NOT (error_code IN (10054,22037,20015) 
	AND DATEPART(WEEKDAY,GETDATE()) IN (1,7))

	IF EXISTS(SELECT * FROM #repl_errors)
	BEGIN
		SET @MsgBody = N'<html><head><title>Data files report</title></head><body><table border= "1"><tr><td>DataHora</td><td>error code</td><td>error text</td><td>command_id</td><td>xact_seqno</td></tr>' 
		+
		CAST ((
				SELECT 
				td = tab1.[time],''
				,td = tab1.error_code,''
				,td = tab1.error_text,''
				,td = ISNULL(tab1.command_id,0),''
				,td = CONVERT(VARCHAR(1000),ISNULL(tab1.xact_seqno,0x0),2)
				FROM (SELECT * FROM #repl_errors) tab1
				FOR XML PATH('tr'),TYPE
		
			) AS NVARCHAR(MAX) )  +
			N'</table></body></html>' ;

		--PRINT @MsgBody
		EXEC msdb.dbo.sp_send_dbmail @profile_name = @Profile,@body = @MsgBody,@body_format = 'HTML',@recipients = @Destinatarios,@subject = @Assunto,@query_result_no_padding = 1,@query_result_header = 0

		UPDATE dbo.repl_alert_control SET last_error = @new_extraction WHERE repl = 'SQL-Replication';

	END
	ELSE
	BEGIN
		UPDATE dbo.repl_alert_control SET last_error = @new_extraction WHERE repl = 'SQL-Replication';
	END
END

GO


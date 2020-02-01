-- Use this script to automatically loop through the publications present on the server, verifyng the number of pending commands. If it is higher than the configured threshold, fire an email

USE distribution
GO

/*
begin tran
DELETE FROM distribution.dbo.MSsubscriptions WHERE publisher_db <> 'SmartSort_Canpar_SCS'
rollback
commit
*/
/*
EXEC sp_check_replication_contention -1,'rleandro@canpar.com'
*/

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].sp_check_replication_contention') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].sp_check_replication_contention AS' 
END
GO
ALTER PROCEDURE sp_check_replication_contention (@threshold INT, @maildest VARCHAR(100)='CANPARDatabaseAdministratorsStaffList@canpar.com')
AS
DECLARE @corpo VARCHAR(500)
DECLARE @publisher_db VARCHAR(50), @publication varchar(50), @subscriber_db varchar(50), @type tinyint, @publisher VARCHAR(50), @subscriber VARCHAR(50)
DECLARE @retornoOut INT, @subject VARCHAR(4000),@profile_name VARCHAR(100)

DECLARE assinatura CURSOR  for
SELECT DISTINCT 
ss.name
,p.publisher_db
,p.publication,s.subscriber_db,s.subscription_type
,ss2.name
FROM distribution.dbo.MSpublications p 
INNER JOIN distribution.dbo.MSsubscriptions s ON p.publication_id = s.publication_id
INNER JOIN sys.servers ss ON ss.server_id = p.publisher_id
INNER JOIN sys.servers ss2 ON ss2.server_id = s.subscriber_id
WHERE subscriber_db !='virtual'

OPEN assinatura
FETCH NEXT FROM assinatura INTO @publisher,@publisher_db,@publication,@subscriber_db,@type,@subscriber

WHILE @@FETCH_STATUS <> -1
BEGIN
	EXEC distribution.dbo.sp_replmonitorsubscriptionpendingcmds_output @publisher = @publisher,
	@publisher_db = @publisher_db, 
	@publication = @publication,
	@subscriber = @subscriber, 
	@subscriber_db = @subscriber_db, 
	@subscription_type = @type,
	@retorno = @retornoOut OUTPUT
	
	--SELECT @retornoOut
	SET @subject='SQL Server replication contention alert - ' + @subscriber_db

	--SELECT @retornoOut;

	IF @retornoOut > @threshold
	BEGIN
		--EXEC sp_configure 'show advanced options',1
		--RECONFIGURE
		--EXEC sp_configure 'Database Mail Xps',1
		--RECONFIGURE  

		SELECT @profile_name=name FROM msdb.dbo.sysmail_profile;
		SET @corpo = 'Number of pending commands to replicate: ' + CONVERT(VARCHAR(10),@retornoOut) + '
		
Check if there are any locks or long running transactions at server ' + @subscriber + ' , database ' + @subscriber_db + '.
		
Procedure name: distribution.dbo.sp_check_replication_contention. Current threshold: ' + CONVERT(VARCHAR(10),@threshold);

		EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile_name, @recipients = @maildest,@body = @corpo, @subject = @subject;

		--EXEC sp_configure 'Database Mail Xps',0
		--RECONFIGURE
		--EXEC sp_configure 'show advanced options',0
		--RECONFIGURE
	END
FETCH NEXT FROM assinatura INTO @publisher,@publisher_db,@publication,@subscriber_db,@type,@subscriber
END
CLOSE assinatura
DEALLOCATE assinatura
GO




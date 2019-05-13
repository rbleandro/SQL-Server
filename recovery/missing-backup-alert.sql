IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].sp_check_BackupCompliance') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].sp_check_BackupCompliance AS'; 
END;
GO
ALTER PROCEDURE sp_check_BackupCompliance
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Destinatarios VARCHAR(500);    
	DECLARE @Assunto VARCHAR(500);    
	DECLARE @Profile VARCHAR(100);    
	
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp;
	   
	SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile);    
	SET @Destinatarios = 'CANPARDatabaseAdministratorsStaffList@canpar.com'    
	--SET @Destinatarios = 'rleandro@canpar.com';    
	SET @Assunto = 'Databases pending proper backup (check situation below) ' + @@SERVERNAME + '\' + @@SERVICENAME;

	SELECT * 
	INTO #temp
	FROM 
	(
		SELECT 
			CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
			database_name, 
			'NO LOG BACKUP IN THE LAST 48 HOURS' AS SitRep
			--,MAX(backup_finish_date) AS last_db_backup_date
		FROM    msdb.dbo.backupset b INNER JOIN sys.databases d ON b.database_name = d.name
		WHERE    1=1
		AND d.recovery_model_desc <> 'SIMPLE'
		AND d.state_desc NOT IN ('OFFLINE')
		AND type = 'L'  
		AND d.name NOT LIKE 'ReportServer%'
		AND database_name NOT IN ('model','master','tempdb','distribution','DBAMonitor','SORT01_TEST','Canpar-Hitachi-IDPM','Loomis-Hitachi-IDPM','CallBackRouting')
		AND SERVERPROPERTY('Servername') NOT IN ('CPRDC1VDEVSQL01')
		AND is_read_only=0
		AND b.database_name NOT IN
		(
			SELECT DB_NAME(database_id) FROM sys.database_mirroring dm
			WHERE mirroring_role_desc = 'MIRROR'	
		)
		AND NOT (SERVERPROPERTY('Servername') = 'CPRDC1VOPSSQL2' AND d.[name] LIKE 'SmartSort_Canpar_SCS%')
		GROUP BY database_name 
		HAVING      (MAX(ISNULL(backup_finish_date,'1900-01-01')) < CONVERT(DATE,DATEADD(DAY,-2,GETDATE())))

		UNION  

		SELECT      
			CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,  
			s.name AS database_name,  
			'NO DATABASE BACKUP RECORD IN THE LAST 7 DAYS' AS SitRep
			
		FROM msdb.dbo.backupmediafamily   b
		INNER JOIN msdb.dbo.backupset  ba ON b.media_set_id = ba.media_set_id  
		INNER JOIN master.sys.databases s ON s.name  = ba.database_name 
		WHERE 1=1
		AND s.state_desc NOT IN ('OFFLINE')
		AND s.name NOT IN ('model','tempdb','distribution','DBAMonitor','SORT01_TEST','Canpar-Hitachi-IDPM','Loomis-Hitachi-IDPM','CallBackRouting')
		AND s.name NOT LIKE 'ReportServer%'
		AND SERVERPROPERTY('Servername') NOT IN ('CPRDC1VDEVSQL01')
		AND type = 'D'  
		AND is_read_only=0
		AND ba.database_name NOT IN
		(
			SELECT DB_NAME(database_id) FROM sys.database_mirroring dm
			WHERE mirroring_role_desc = 'MIRROR'	
		)
		AND NOT (SERVERPROPERTY('Servername') = 'CPRDC1VOPSSQL2' AND s.[name] LIKE 'SmartSort_Canpar_SCS%')
		GROUP BY s.name 
		HAVING (MAX(ISNULL(backup_finish_date,'1900-01-01')) < CONVERT(DATE,DATEADD(DAY,-7,GETDATE())))

		UNION

		SELECT      
			CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,  
			d.name AS database_name,  
			'NO DATABASE BACKUP RECORD SINCE DATABASE CREATION' AS SitRep 
			--,dm.mirroring_role_desc
		FROM master.sys.databases d LEFT JOIN msdb.dbo.backupset B ON d.name  = B.database_name 
		LEFT JOIN sys.database_mirroring dm ON dm.database_id = d.database_id
		WHERE B.[database_name] IS NULL 
		AND d.[name] NOT IN ('model','tempdb','distribution','DBAMonitor','SORT01_TEST','Canpar-Hitachi-IDPM','Loomis-Hitachi-IDPM','CallBackRouting')
		AND d.[name] NOT LIKE 'ReportServer%'
		AND d.state_desc NOT IN ('OFFLINE')
		AND SERVERPROPERTY('Servername') NOT IN ('CPRDC1VDEVSQL01')
		AND is_read_only=0
		AND (dm.mirroring_role_desc != 'MIRROR' OR dm.mirroring_role_desc IS NULL)
		AND NOT (SERVERPROPERTY('Servername') = 'CPRDC1VOPSSQL2' AND d.name LIKE 'SmartSort_Canpar_SCS%')

		--AND B.[type] = 'D'  
		
	) AS a
	ORDER BY database_name; 

	IF EXISTS(SELECT * FROM #temp)
	BEGIN
		DECLARE @MsgBody NVARCHAR(MAX);  
		SET @MsgBody = '<html>  
		<head>  
		<title>Data files report</title>  
		</head>  
		<body>  
		<table border= "1">  
		<tr>  
		<td>Server</td>  
		<td>Database</td>  
		<td>SitRep</td>  
		</tr>' +  
		CAST ((  
		SELECT  DISTINCT 
		td=Server,''  
		,td=database_name,''  
		,td=SitRep
		
		FROM #temp  
  
		FOR XML PATH('tr')  
		) AS NVARCHAR(MAX) ) +  
		N'</table>';  


		EXEC msdb.dbo.sp_send_dbmail    
		@profile_name = @Profile    
		,@body = @MsgBody    
		,@body_format = 'HTML'    
		,@recipients = @Destinatarios    
		,@subject = @Assunto    
		,@query_result_no_padding = 1    
		,@query_result_header = 0;    
	
		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp;	

	END;
END;
GO



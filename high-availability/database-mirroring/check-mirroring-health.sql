IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].CheckMirroringHealth') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].CheckMirroringHealth AS'; 
END;
GO
ALTER PROCEDURE dbo.CheckMirroringHealth
AS
BEGIN
	SET CONCAT_NULL_YIELDS_NULL ON;
	SET NOCOUNT ON;

	DECLARE @Destinatarios VARCHAR(500);    
	DECLARE @Assunto VARCHAR(500);    
	DECLARE @Profile VARCHAR(100);    
	DECLARE @idSkuServicoTipo INT;    
	DECLARE @Loja VARCHAR(100);    

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp;
	   
	SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile);    
	SET @Destinatarios = 'CANPARDatabaseAdministratorsStaffList@canpar.com';    
	--SET @Destinatarios = 'rleandro@canpar.com'    
	SET @Assunto = 'High Database mirroring queue size on server ' + @@SERVERNAME  + '! .'; 

	SELECT [counter_name] AS CounterName,[cntr_value]/1024 AS CounterValueMB,instance_name,d.mirroring_state_desc AS MirrState
	INTO #temp
	FROM sys.dm_os_performance_counters pc
	LEFT JOIN sys.database_mirroring d ON pc.instance_name = DB_NAME(d.database_id)
	WHERE [object_name] LIKE ('%Database Mirroring%') 
	AND [counter_name] IN ('Log Send Queue KB','Redo Queue KB') 
	AND [cntr_value] > 4000
	AND pc.instance_name <> '_Total '
	ORDER BY instance_name;

	
	IF EXISTS(SELECT * FROM #temp)
	BEGIN

		IF EXISTS(SELECT * FROM #temp WHERE MirrState='SUSPENDED' )
		BEGIN 
			DECLARE @cmd VARCHAR(max);
			SELECT @cmd = replace (
			(		
				SELECT 'alter database ['+ DB_NAME(database_id) + '] set partner RESUME' + ' | ' FROM sys.database_mirroring WHERE mirroring_state_desc='SUSPENDED'
				FOR XML PATH('')
			),'|',';');

			EXEC (@cmd);
		END;


		DECLARE @MsgBody NVARCHAR(MAX);  
		SET @MsgBody = '<html>  
		<head>  
		<title>Data files report</title>  
		</head>  
		<body>  
		<table border= "1">  
		<tr>  
		<td colspan="4">Suspended sessions were automatically resumed.</td> 
		</tr>
		<tr>  
		<td>CounterName</td>  
		<td>CounterValueMB</td>  
		<td>instance_name</td>  
		<td>MirrState</td> 
		</tr>' +  
		CAST ((  
		SELECT   
		td=CounterName,''  
		,td=CounterValueMB,''  
		,td=instance_name,''
		,td=MirrState
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
  
	END;

END;
GO

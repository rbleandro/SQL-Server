USE master
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].LockedSessionsReport') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].LockedSessionsReport AS' 
END
GO
ALTER PROCEDURE dbo.LockedSessionsReport    
AS    

SET NOCOUNT ON;
DECLARE @Destinatarios VARCHAR(500);    
DECLARE @Assunto VARCHAR(500);    
DECLARE @Profile VARCHAR(100);    
DECLARE @idSkuServicoTipo INT;    
DECLARE @Loja VARCHAR(100);    
    
SET CONCAT_NULL_YIELDS_NULL OFF;    
    
SET @Profile = (SELECT name FROM msdb.dbo.sysmail_profile); 
--SET @Destinatarios = 'CANPARDatabaseAdministratorsStaffList@canpar.com'    
SET @Destinatarios = 'rleandro@canpar.com';    
SET @Assunto = 'Blocking found on '+ @@SERVERNAME +'!'; 
    
IF OBJECT_ID('tempdb..#ProcessoLongo') IS NOT NULL  
DROP TABLE #ProcessoLongo;  

  
SELECT  DISTINCT 
DB_NAME(er.database_id) AS Banco
,er.session_id  
,CASE WHEN sp.program_name LIKE '%SQLAgent%' THEN 'YES' ELSE 'NO' END AS FlagJob  
,CASE WHEN sb.program_name LIKE '%SQLAgent%' THEN 'YES' ELSE 'NO' END AS BFlagJob  
,er.start_time  
,er.status  
,COALESCE(er.blocking_session_id,0) AS blocking_session_id  
,COALESCE(rb.blocking_session_id,0) AS BBlocking_session_id  
,COALESCE(er.wait_type,'NONE') AS wait_type  
,COALESCE(rb.wait_type,'NONE') AS BWait_type  
,er.wait_time
,er.total_elapsed_time  
,er.plan_handle  
,sp.program_name
,sb.program_name AS BProgram
,sp.host_name
,sp.login_name
,(CASE COALESCE(OBJECT_NAME(qt.objectid,qt.dbid),'1') WHEN '1' THEN qt.[text] ELSE OBJECT_NAME(qt.objectid,qt.dbid) END) AS texto  
,SUBSTRING(qt.text, (er.statement_start_offset/2)+1 
,((CASE er.statement_end_offset
    WHEN -1 THEN DATALENGTH(qt.text)
    ELSE er.statement_end_offset
    END - er.statement_start_offset)/2) + 1) AS statement_text
,CASE COALESCE(OBJECT_NAME(st1.objectid,rb.database_id),'1') WHEN '1' THEN st1.[text] ELSE OBJECT_NAME(st1.objectid,rb.database_id) END AS QBlock
,SUBSTRING(st1.text, (rb.statement_start_offset/2)+1 
,((CASE rb.statement_end_offset
    WHEN -1 THEN DATALENGTH(st1.text)
    ELSE rb.statement_end_offset
    END - rb.statement_start_offset)/2) + 1) AS BStatement
,sb.login_name AS UserVilain
,sb.host_name AS HostVilain
INTO #ProcessoLongo  
FROM sys.dm_exec_requests er 
INNER JOIN sys.dm_exec_sessions sp  ON er.session_id=sp.session_id  
LEFT JOIN sys.dm_exec_requests rb ON er.blocking_session_id=rb.session_id
LEFT JOIN sys.dm_exec_sessions sb ON sb.session_id=rb.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt  
OUTER APPLY sys.dm_exec_sql_text(rb.sql_handle) AS st1
WHERE 1=1
--and er.session_id>50  
AND er.wait_time > 10000
AND er.wait_type LIKE 'LCK%'
--AND er.session_id<>@@spid;  
    
DECLARE @MsgBody NVARCHAR(MAX);  
SET @MsgBody = '<html>  
<head>  
<title>Data files report</title>  
</head>  
<body>  
<table border= "1">  
<tr>  
<td>Database</td>  
<td>session_id</td>  
<td>JOB?</td>
<td>Query</td> 
<td>Statement</td> 
<td>start_time</td>  
<td>status</td>  
<td>wait_type</td>  
<td>waittime(s)</td>  
<td>ExecTime(s)</td>  
<td>plan</td>  
<td>program</td>  
<td>host</td>  
<td>user</td>  
<td>BSID</td>
<td>BBlkSID</td>
<td>BJOB?</td>  
<td>BWait</td>
<td>BQuery</td>  
<td>BStatement</td> 
<td>BHost</td>  
<td>BUser</td>  
<td>BProgram</td>  
</tr>' +  
CAST ((  
SELECT   
td=Banco,''  
,td=session_id,''  
,td=FlagJob,''  
,td=CONVERT(VARCHAR(MAX),ISNULL(texto,'N/A'),1),''  
,td=CONVERT(VARCHAR(MAX),ISNULL(statement_text,'N/A'),1),''  
,td=start_time,'',  
td=status,''  
,td=COALESCE(wait_type,'NONE'),''  
--,td=CAST(CAST (DATEDIFF(s,wait_time,GETDATE()) AS INT)/86400 AS VARCHAR(50))+':'+ CONVERT(VARCHAR, DATEADD(S, CAST (DATEDIFF(s,wait_time,GETDATE()) AS INT), 0), 108) ,''
--,td=CAST(CAST (DATEDIFF(s,start_time,GETDATE()) AS INT)/86400 AS VARCHAR(50))+':'+ CONVERT(VARCHAR, DATEADD(S, CAST (DATEDIFF(s,start_time,GETDATE()) AS INT), 0), 108) ,'',  
,td=wait_time/1000,''  
,td=DATEDIFF(s,start_time,GETDATE()),''  
,td=ISNULL(CONVERT(VARCHAR(MAX),plan_handle,1),'N/A'),''  
,td=ISNULL([program_name],'N/A'),''
,td=ISNULL(host_name,'N/A'),''
,td=ISNULL(login_name,'N/A'),''
,td=COALESCE(blocking_session_id,0),'' 
,td=BBlocking_session_id,''  
,td=BFlagJob,''  
,td=BWait_type,''  
,td=CONVERT(VARCHAR(MAX),ISNULL(QBlock,'N/A'),1),''   
,td=CONVERT(VARCHAR(MAX),ISNULL(BStatement,'N/A'),1),'' 
,td=ISNULL(HostVilain,'N/A'),''
,td=ISNULL(UserVilain,'N/A'),''
,td=ISNULL(BProgram,'N/A')

  
FROM #ProcessoLongo  
  
FOR XML PATH('tr')  
) AS NVARCHAR(MAX) ) +  
N'</table>';  

  
IF EXISTS(SELECT TOP 10 * FROM #ProcessoLongo)
BEGIN  
  
 EXEC msdb.dbo.sp_send_dbmail    
 @profile_name = @Profile    
 ,@body = @MsgBody    
 ,@body_format = 'HTML'    
 ,@recipients = @Destinatarios    
 ,@subject = @Assunto    
 ,@query_result_no_padding = 1    
 ,@query_result_header = 0;    
  
END;  
    
GO

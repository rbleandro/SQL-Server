SELECT DISTINCT r.session_id ,DB_NAME(r.database_id) AS 'Database'
,CASE COALESCE(OBJECT_NAME(st.objectid,r.database_id),'1') WHEN '1' THEN 'check statement' ELSE OBJECT_NAME(st.objectid,r.database_id) END AS Query 
,SUBSTRING(st.text, (r.statement_start_offset/2)+1 
,((CASE r.statement_end_offset
    WHEN -1 THEN DATALENGTH(st.text)
    ELSE r.statement_end_offset
    END - r.statement_start_offset)/2) + 1) AS statement_text
,qs1.tempo_medioP1 AS TM
,CONVERT(TIME,DATEADD (ms, r.total_elapsed_time, 0)) AS TempoTotal,
r.wait_time ,
r.last_wait_type AS waittype
,r.blocking_session_id AS blksid
,r.start_time 
,DATEADD(SECOND, r.estimated_completion_time / 1000, GETDATE()) AS estimated_completion_time
,CASE r.transaction_isolation_level WHEN 1 THEN 'ReadUncomitted' WHEN 2 THEN 'ReadCommitted' WHEN 3 THEN 'Repeatable' WHEN 4 THEN 'serializable' WHEN 5 THEN 'Snapshot' ELSE 'UNKNOWN' END  AS IsolamentoVit
,PLANOVITIMA=r.plan_handle 
,CASE rb.transaction_isolation_level WHEN 1 THEN 'ReadUncomitted' WHEN 2 THEN 'ReadCommitted' WHEN 3 THEN 'Repeatable' WHEN 4 THEN 'serializable' WHEN 5 THEN 'Snapshot' ELSE 'UNKNOWN' END AS IsolamentoVilao
,PLANOVILAO=rb.plan_handle 
,CASE COALESCE(OBJECT_NAME(st1.objectid,rb.database_id),'1') WHEN '1' THEN st1.[text] ELSE OBJECT_NAME(st1.objectid,rb.database_id) END AS QBlock
,sb.login_name AS UserVilain
,sb.host_name AS HostVilain
,sp.login_name AS UserVictim
,sp.host_name AS HostVictim
,qs1.total_physical_reads
,(SELECT CAST(t.scheduler_id AS VARCHAR(10)) + ',' AS [data()] FROM sys.dm_os_tasks t WHERE t.session_id = r.session_id FOR XML PATH('')) AS threads
FROM sys.dm_exec_requests r 
INNER JOIN sys.dm_exec_sessions sp ON sp.session_id=r.session_id
LEFT JOIN sys.dm_exec_requests rb ON r.blocking_session_id=rb.session_id
LEFT JOIN sys.dm_exec_sessions sb ON sb.session_id=rb.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
OUTER APPLY sys.dm_exec_sql_text(rb.sql_handle) AS st1
OUTER APPLY (SELECT TOP 1 tempo_medioP1 = (total_elapsed_time/1000 / execution_count),total_physical_reads FROM sys.dm_exec_query_stats qs WHERE qs.plan_handle = r.plan_handle ORDER BY qs.last_execution_time DESC) AS qs1
WHERE 1=1
--AND r.session_id&gt;50
--AND r.database_id=DB_ID()
AND r.session_id<>@@spid
AND r.last_wait_type NOT IN ('BROKER_RECEIVE_WAITFOR')
ORDER BY r.session_id
OPTION(RECOMPILE)
GO
USE [vSphere5-UM]
GO

SELECT * FROM 
(
	SELECT DB_NAME() AS Banco
	,[File Name]
	,[Physical Name]
	,[Total Size in MB]
	,[Available Space In MB]
	,[file_id]
	,[Filegroup Name]
	,a.[Total Size in MB] - a.[Available Space In MB] AS EspacoUsado
	,CASE type_desc WHEN 'ROWS' THEN 'DBCC SHRINKFILE (N'''+[a].[File Name]+''' , '+ CAST(CAST((a.[Total Size in MB] - a.[Available Space In MB] + 1000) AS INT) AS VARCHAR(1000)) + ')' 
	WHEN 'LOG' THEN	'DBCC SHRINKFILE (N'''+[a].[File Name]+''' , 0, TRUNCATEONLY)' 
	END AS [Shrink]
	,a.type_desc
	FROM 
	(
		SELECT f.name AS [File Name] , f.physical_name AS [Physical Name], 
		CAST((f.size/128.0) AS DECIMAL(15,2)) AS [Total Size in MB],
		CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS INT)/128.0 AS DECIMAL(15,2)) AS [Available Space In MB]
		, [file_id]
		, fg.name AS [Filegroup Name]
		,f.type_desc
		FROM sys.database_files AS f WITH (NOLOCK) 
		LEFT OUTER JOIN sys.data_spaces AS fg WITH (NOLOCK) 
		ON f.data_space_id = fg.data_space_id 
	) AS a
	--WHERE a.[Available Space In MB] >= 1000
) AS b
ORDER BY b.type_desc desc
OPTION (RECOMPILE);


--database file size report
SELECT TOP 1000 CAST((af.size/128.0) AS DECIMAL(15,2)) AS 'Size in MB',
                af.name,
                CASE af.status WHEN 1048642 THEN af.growth ELSE CAST((af.growth/128.0) AS DECIMAL(15,2)) END AS 'Growth in MB/%',
                af.filename,
                d.name,d.recovery_model_desc
				,'use ['+d.name+'];DBCC SHRINKFILE (N'''+af.name+''' , 0, TRUNCATEONLY)' 
				--,af.status
FROM sys.sysaltfiles af
INNER JOIN sys.databases d ON af.dbid=d.database_id
WHERE 1=1
--AND af.groupid=0
--AND CAST((af.size/128.0) AS DECIMAL(15,2)) > 100
AND af.name LIKE '%2017%'
ORDER BY d.name,CAST((af.size/128.0) AS DECIMAL(15,2)) DESC


--most recent backups taken
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   database_name,  
   MAX(backup_finish_date) AS last_db_backup_date,type
FROM   msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON backupmediafamily.media_set_id = backupset.media_set_id  
WHERE  1=1
--and msdb..backupset.type = 'D' 
GROUP BY 
   database_name  ,type
ORDER BY  
   database_name 
GO

SELECT TOP 10 log_reuse_wait_desc FROM sys.databases WHERE name = DB_NAME()

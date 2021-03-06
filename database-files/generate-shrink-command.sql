/*

Remarks:

1. Use this script to generate shrink command for all files within a database

*/

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

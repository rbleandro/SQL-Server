USE msdb
GO

--------------------------------------------------------------------------------- 
--Database Backups for all databases For Previous Week 
--------------------------------------------------------------------------------- 
SELECT DISTINCT
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
database_name, 
backup_start_date, 
backup_finish_date, 
CONVERT(VARCHAR(50),DATEDIFF(DAY,backup_start_date,backup_finish_date)) + ':' + CONVERT(VARCHAR(8),CONVERT(TIME(0),DATEADD (ms, DATEDIFF(ms,backup_start_date,backup_finish_date), 0))) TimeTaken,
expiration_date, 
CASE type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
END AS backup_type, 
backup_size, 
logical_device_name, 
--physical_device_name, 
name AS backupset_name, 
description 
FROM msdb.dbo.backupmediafamily b
INNER JOIN msdb.dbo.backupset bs ON b.media_set_id = bs.media_set_id 
WHERE backup_start_date >= DATEADD(DAY,-30,GETDATE())
--AND name IS NOT NULL
--AND database_name= 'arch_'
--AND bs.backup_finish_date > '2019-09-09'
AND database_name='arch_db'
ORDER BY 
database_name, 
backup_finish_date desc

GO

--SELECT * FROM sys.sysprocesses WHERE spid=15


------------------------------------------------------------------------------------------- 
--Most Recent Database Backup for Each Database 
------------------------------------------------------------------------------------------- 
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   database_name,  
   MAX(backup_finish_date) AS last_db_backup_date,type
FROM   msdb.dbo.backupmediafamily   b
   INNER JOIN msdb.dbo.backupset  ba ON b.media_set_id = ba.media_set_id  
WHERE  1=1
--and msdb..backupset.type = 'D' 
AND database_name = 'EdiEgap'
GROUP BY 
   database_name  ,type
ORDER BY  
   database_name ,last_db_backup_date desc
GO

------------------------------------------------------------------------------------------- 
--Most Recent Database Backup for Each Database - Detailed 
------------------------------------------------------------------------------------------- 
SELECT  
   A.Server,  
   A.last_db_backup_date,  
   B.backup_start_date,  
   B.expiration_date, 
   B.backup_size,  
   B.logical_device_name,  
   B.physical_device_name,   
   B.backupset_name, 
   B.description 
FROM 
   ( 
	   SELECT   
		   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
		   database_name,  
		   MAX(backup_finish_date) AS last_db_backup_date 
	   FROM    msdb.dbo.backupmediafamily  b
		   INNER JOIN msdb.dbo.backupset bs ON b.media_set_id = bs.media_set_id  
	   WHERE   1=1
	   --and msdb..backupset.type = 'D' 
	   GROUP BY 
       database_name  
   ) AS A 
    
   LEFT JOIN  

   ( 
	   SELECT   
	   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
	   database_name,  
	   backup_start_date,  
	   backup_finish_date, 
	   expiration_date, 
	   backup_size,  
	   logical_device_name,  
	   physical_device_name,   
	   name AS backupset_name, 
	   description 
		FROM   msdb.dbo.backupmediafamily  b
		   INNER JOIN msdb.dbo.backupset bs ON b.media_set_id = bs.media_set_id  
		WHERE  1=1
		--and msdb..backupset.type = 'D' 
   ) AS B 
   ON A.Server = B.Server AND A.database_name = B.database_name AND A.last_db_backup_date = B.backup_finish_date 
WHERE 1=1
AND A.database_name = 'EdiEgap'
ORDER BY  A.database_name 
GO


------------------------------------------------------------------------------------------- 
--Databases Missing a Data (aka Full) Back-Up Within Past 24 Hours 
------------------------------------------------------------------------------------------- 
--Databases with data backup over 24 hours old 
SELECT 
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   database_name, 
   MAX(backup_finish_date) AS last_db_backup_date, 
   DATEDIFF(hh, MAX(backup_finish_date), GETDATE()) AS [Backup Age (Hours)] 
FROM    msdb.dbo.backupset 
WHERE     type = 'D'  
GROUP BY database_name 
HAVING      (MAX(backup_finish_date) < DATEADD(DAY, - 1, GETDATE()))  

UNION  

--Databases without any backup history 
SELECT      
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,  
   d.name AS database_name,  
   NULL AS [Last Data Backup Date],  
   9999 AS [Backup Age (Hours)]  
FROM 
   master.sys.databases d LEFT JOIN msdb.dbo.backupset 
       ON d.name  = database_name 
WHERE database_name IS NULL AND d.name not in ('tempdb','distribution')
and d.name not like 'ReportServer%'
ORDER BY  
   database_name 
GO

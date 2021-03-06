use master
go
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].generateSecAuditReport') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].generateSecAuditReport AS' 
END
GO
ALTER PROCEDURE generateSecAuditReport
AS
BEGIN

IF OBJECT_ID('master.dbo.SecAuditDetailed') IS NOT NULL 
	TRUNCATE TABLE master.dbo.SecAuditDetailed;
else
	CREATE TABLE master.dbo.SecAuditDetailed ([Database] varchar(250),DatabaseUserName VARCHAR(500),UserType VARCHAR(500), [Role] VARCHAR(500), PermissionType VARCHAR(500), PermissionState VARCHAR(500), ObjectType VARCHAR(500), ObjectName VARCHAR(500), ColumnName VARCHAR(500));


DECLARE @dbname VARCHAR(250),@cmd VARCHAR(4000);
DECLARE cur CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4 AND is_read_only=0 and state_desc not in ('OFFLINE') AND name NOT LIKE 'ReportServer%' AND name NOT LIKE 'tempdb%'
OPEN cur
FETCH NEXT FROM cur INTO @dbname
WHILE @@FETCH_STATUS <> -1
BEGIN
	SET @cmd = 'INSERT INTO master.dbo.SecAuditDetailed( [Database],DatabaseUserName,UserType ,Role ,PermissionType ,PermissionState ,ObjectType ,ObjectName ,ColumnName) exec '+QUOTENAME(@dbname)+'.dbo.SecAuditPermissions';
	EXEC(@cmd); 

FETCH NEXT FROM cur INTO @dbname
end
CLOSE cur
DEALLOCATE cur

SELECT [Database] ,
       DatabaseUserName ,
       UserType ,
       Role ,
       PermissionType ,
       PermissionState ,
       ObjectType ,
       ObjectName ,
       ColumnName
FROM (	    
SELECT 'Database' AS [Database],'DatabaseUserName' AS DatabaseUserName,'UserType' AS UserType, 'Role' AS Role, 'PermissionType' AS PermissionType
, 'PermissionState' AS PermissionState,'ObjectType' AS ObjectType,'ObjectName' AS ObjectName, 'ColumnName' AS ColumnName, 1 AS ord
UNION 
SELECT [Database] ,
       DatabaseUserName ,
       UserType ,
       Role ,
       PermissionType ,
       PermissionState ,
       ObjectType ,
       ObjectName ,
       ColumnName, 2 AS ord
FROM master.dbo.SecAuditDetailed 
WHERE DatabaseUserName NOT IN ('guest','sys','dbo','INFORMATION_SCHEMA')
) AS a
ORDER BY ord ASC


END
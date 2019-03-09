IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].generateSecAuditReport') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].generateSecAuditReport AS' 
END
GO
ALTER PROCEDURE generateSecAuditReport
AS
BEGIN
IF OBJECT_ID('SecAuditDetailed') IS NOT NULL 
	TRUNCATE TABLE SecAuditDetailed;
else
	CREATE TABLE SecAuditDetailed ([Database] varchar(250),DatabaseUserName VARCHAR(500),UserType VARCHAR(500), [Role] VARCHAR(500), PermissionType VARCHAR(500), PermissionState VARCHAR(500), ObjectType VARCHAR(500), ObjectName VARCHAR(500), ColumnName VARCHAR(500));

/*
INSERT INTO ##temp( DatabaseUserName,UserType ,Role ,PermissionType ,PermissionState ,ObjectType ,ObjectName ,ColumnName)
EXEC [_dev_intranet].dbo.SecAuditPermissions
*/

DECLARE @dbname VARCHAR(250),@cmd VARCHAR(4000);
DECLARE cur CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4 
OPEN cur
FETCH NEXT FROM cur INTO @dbname
WHILE @@FETCH_STATUS <> -1
BEGIN
	SET @cmd = 'INSERT INTO SecAuditDetailed( [Database],DatabaseUserName,UserType ,Role ,PermissionType ,PermissionState ,ObjectType ,ObjectName ,ColumnName) exec '+QUOTENAME(@dbname)+'.dbo.SecAuditPermissions';
	EXEC(@cmd); 

FETCH NEXT FROM cur INTO @dbname
end
CLOSE cur
DEALLOCATE cur

SELECT 'Database' AS [Database],'DatabaseUserName' AS DatabaseUserName,'UserType' AS UserType, 'Role' AS Role, 'PermissionType' AS PermissionType
, 'PermissionState' AS PermissionState,'ObjectType' AS ObjectType,'ObjectName' AS ObjectName, 'ColumnName' AS ColumnName
UNION all
SELECT [Database] ,
       DatabaseUserName ,
       UserType ,
       Role ,
       PermissionType ,
       PermissionState ,
       ObjectType ,
       ObjectName ,
       ColumnName
FROM SecAuditDetailed 
WHERE DatabaseUserName NOT IN ('guest','sys','dbo','INFORMATION_SCHEMA')
ORDER BY [Database] ASC

--IF OBJECT_ID('tempdb..##temp') IS NOT NULL DROP TABLE ##temp

END
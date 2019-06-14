exec sp_configure 'show adv',1
reconfigure
exec sp_configure 'xp_cmdshell',1
reconfigure
go
exec xp_cmdshell 'mkdir c:\SecAudit'
go
exec sp_configure 'show adv',0
reconfigure
go

exec msdb.dbo.sysmail_configure_sp 'MaxFileSize','50000000'
GO

IF OBJECT_ID('master.dbo.SecAuditDetailed') IS NOT NULL 
	TRUNCATE TABLE master.dbo.SecAuditDetailed;
else
	CREATE TABLE master.dbo.SecAuditDetailed ([Database] varchar(250),DatabaseUserName VARCHAR(500),UserType VARCHAR(500), [Role] VARCHAR(500), PermissionType VARCHAR(500), PermissionState VARCHAR(500), ObjectType VARCHAR(500), ObjectName VARCHAR(500), ColumnName VARCHAR(500));

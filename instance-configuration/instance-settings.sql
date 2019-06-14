
declare @MasterPath nvarchar(512)
declare @LogPath nvarchar(512)
declare @ErrorLog nvarchar(512)
declare @ErrorLogPath nvarchar(512)

select @MasterPath=substring(physical_name, 1, len(physical_name) - charindex('\', reverse(physical_name))) from master.sys.database_files where name=N'master'
select @LogPath=substring(physical_name, 1, len(physical_name) - charindex('\', reverse(physical_name))) from master.sys.database_files where name=N'mastlog'
select @ErrorLog=cast(SERVERPROPERTY(N'errorlogfilename') as nvarchar(512))
select @ErrorLogPath=substring(@ErrorLog, 1, len(@ErrorLog) - charindex('\', reverse(@ErrorLog)))
      


declare @SmoRoot nvarchar(512)
exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @SmoRoot OUTPUT
      


SELECT
CAST(case when 'a' <> 'A' then 1 else 0 end AS bit) AS [IsCaseSensitive],
@@MAX_PRECISION AS [MaxPrecision],
@ErrorLogPath AS [ErrorLogPath],
@SmoRoot AS [RootDirectory],
N'Windows' AS [HostPlatform],
N'\' AS [PathSeparator],
CAST(FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS bit) AS [IsFullTextInstalled],
@LogPath AS [MasterDBLogPath],
@MasterPath AS [MasterDBPath],
SERVERPROPERTY(N'ProductVersion') AS [VersionString],
CAST(SERVERPROPERTY(N'Edition') AS sysname) AS [Edition],
CAST(SERVERPROPERTY(N'ProductLevel') AS sysname) AS [ProductLevel],
CAST(SERVERPROPERTY('IsSingleUser') AS bit) AS [IsSingleUser],
CAST(SERVERPROPERTY('EngineEdition') AS int) AS [EngineEdition],
convert(sysname, serverproperty(N'collation')) AS [Collation],
CAST(SERVERPROPERTY(N'MachineName') AS sysname) AS [NetName],
CAST(SERVERPROPERTY('IsClustered') AS bit) AS [IsClustered],
SERVERPROPERTY(N'ResourceVersion') AS [ResourceVersionString],
SERVERPROPERTY(N'ResourceLastUpdateDateTime') AS [ResourceLastUpdateDateTime],
SERVERPROPERTY(N'CollationID') AS [CollationID],
SERVERPROPERTY(N'ComparisonStyle') AS [ComparisonStyle],
SERVERPROPERTY(N'SqlCharSet') AS [SqlCharSet],
SERVERPROPERTY(N'SqlCharSetName') AS [SqlCharSetName],
SERVERPROPERTY(N'SqlSortOrder') AS [SqlSortOrder],
SERVERPROPERTY(N'SqlSortOrderName') AS [SqlSortOrderName],
SERVERPROPERTY(N'BuildClrVersion') AS [BuildClrVersionString],
SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS]


SELECT CONVERT(sysname, SERVERPROPERTY('servername')) --returns full instance name
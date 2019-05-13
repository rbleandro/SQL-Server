-- reporting orphan users per database
declare @bd varchar(100)
declare banco cursor for select name from sys.databases where 1=1 and database_id > 4
open banco
fetch next from banco into @bd
while @@fetch_status <> -1
begin
	print @bd
	exec ('use '+@bd+'; exec sp_change_users_login ''REPORT'' ')
	fetch next from banco into @bd
end
close banco
deallocate banco

--dinamically generating the commands to map users to its respective login for SQL Server 2000 and 2005
SELECT 'exec sp_change_users_login ''update_one'','''+su.name+''','''+su.name+'''',su.[name],su.name,su.sid
FROM sys.sysusers su inner JOIN sys.syslogins sl ON sl.sid = su.sid
WHERE 1=1
AND su.issqluser=1 and   (su.sid is not null and su.sid <> 0x0) 
AND su.name NOT IN('dbo') 

----dinamically generating the commands to map users to its respective login for SQL Server 2008 and beyond
SELECT 'exec sp_change_users_login ''update_one'','''+su.name+''','''+su.name+'''',su.[name],su.name,su.sid
,su.*
FROM sys.database_principals su
 left JOIN sys.server_principals sl ON sl.sid = su.sid
WHERE 1=1
AND su.type='S' AND su.is_fixed_role=0
--AND su.issqluser=1 and   (su.sid is not null and su.sid <> 0x0) 
AND su.name NOT IN('dbo','guest','sys','INFORMATION_SCHEMA') 
AND sl.sid IS NULL


exec sp_change_users_login 'update_one','twsqlmonitor','twsqlmonitor'
exec sp_change_users_login 'update_one','crmuser','crmuser'

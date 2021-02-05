--THE FIRST THING YOU NEED TO DO WHEN SETTING UP DATABASE MIRRORING IS PERFORM A FULL BACKUP FOLLOWED BY A TRANSACTION LOG BACKUP ON THE PRINCIPAL SERVER. 

--Create auxiliary table with db sizes (run on principal server)
SELECT CAST((af.size/128.0) AS DECIMAL(15,2)) AS 'Size in MB',
                af.name,
                CASE af.status WHEN 1048642 THEN af.growth ELSE CAST((af.growth/128.0) AS DECIMAL(15,2)) END AS 'Growth in MB/%',
                af.filename,
                d.name as dbname,d.recovery_model_desc
				--,af.status
into DBAMonitor.dbo.DBSize
FROM sys.sysaltfiles af
INNER JOIN sys.databases d ON af.dbid=d.database_id
WHERE af.groupid=1
--AND CAST((af.size/128.0) AS DECIMAL(15,2)) > 100
ORDER BY CAST((af.size/128.0) AS DECIMAL(15,2))

--to generante the backup statements (point to principal server)
select d.name,'if @@servername = ''CPRDC1VOPSSQL1'' 
begin 
backup database '+d.name+' to disk=''S:\Mirroring\'+d.name+'.bak'' with stats=10,compression'+'
backup log '+d.name+' to disk=''S:\Mirroring\'+d.name+'.trn'' with stats=10,compression
end
else raiserror(''wrong server'',16,1)

' as cmd,db.[Size in MB],1 as ord
from sys.databases d 
inner join DBAMonitor.dbo.DBSize db on d.name=db.dbname
where d.database_id>4
and d.name not like 'reportserver%'
and d.name not in ('distribution')

union

select d.name,'ALTER DATABASE '+d.name+' SET PARTNER = N''TCP://CPRDC1VOPSSQL2.canpar.com:5022''' as cmd,db.[Size in MB],2 as ord

from sys.databases d 
inner join DBAMonitor.dbo.DBSize db on d.name=db.dbname
where d.database_id>4
and d.name not like 'reportserver%'
and d.name not in ('distribution')
order by ord,db.[Size in MB]

--YOU THEN MUST RESTORE THESE TO THE MIRROR SERVER USING THE WITH NORECOVERY OPTION OF THE RESTORE COMMAND.'

--to generante the restore statements (point to mirror server)
select d.name,'if @@servername = ''CPRDC1VOPSSQL2'' 
begin 
restore database '+d.name+' from disk=''E:\DB_Backups\'+d.name+'.bak'' with stats=10, replace, norecovery'+'
restore log '+d.name+' from disk=''E:\DB_Backups\'+d.name+'.trn'' with stats=10, replace, norecovery 
ALTER DATABASE '+d.name+' SET PARTNER = N''TCP://CPRDC1VOPSSQL1.canpar.com:5022''
end
else raiserror(''wrong server'',16,1)

'
from sys.databases d 
inner join [CPRDC1VOPSSQL1].DBAMonitor.dbo.DBSize db on d.name=db.dbname
where d.database_id>4
and d.name not like 'reportserver%'
order by db.[Size in MB]

--'

/*Create endpoints on both servers*/
CREATE ENDPOINT Mirroring
STATE=STARTED AS TCP(LISTENER_PORT = PortNumber, LISTENER_IP = ALL)
FOR DATA_MIRRORING(ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = REQUIRED ALGORITHM RC4)

USE master;  
GO  
CREATE LOGIN [Adomain\Otheruser] FROM WINDOWS;  
GO  
GRANT CONNECT on ENDPOINT::Mirroring TO [Adomain\Otheruser];  
GO  

/*Set partner and setup job on mirror server*/
ALTER DATABASE DatabaseName SET PARTNER = N'TCP://CPRDC1VOPSSQL1.canpar.com:5022' --you can grab this from the dinamyc command generator above
EXEC sys.sp_dbmmonitoraddmonitoring -- default is 1 minute

/*Set partner, set synchronous mode, and setup job on principal server*/
ALTER DATABASE DatabaseName SET PARTNER = N'TCP://CPRDC1VOPSSQL2.canpar.com:5022' --you can grab this from the dinamyc command generator above
--ALTER DATABASE DatabaseName SET WITNESS OFF
ALTER DATABASE DatabaseName SET SAFETY OFF
EXEC sys.sp_dbmmonitoraddmonitoring -- default is 1 minute

/*FAILOVER */
ALTER DATABASE <database_name> SET PARTNER FAILOVER
ALTER DATABASE <database_name> SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS
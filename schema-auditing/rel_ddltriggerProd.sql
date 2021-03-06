USE dba;
GO

SELECT [DatabaseLogID]
     ,[DatabaseName]
     ,[LoginName]
     ,[PostTime]
     ,[DatabaseUser]
     ,[Event]
     ,[Schema]
     ,[Object]
     ,[TSQL]
 FROM [dba].[dbo].[AuditDDLOperations]
WHERE 1=1
and posttime > '2010-07-14 12:00:00'
--AND ComputerName = 'RJO00096'
--AND tsql LIKE '%SkuSaldoRefresh%'
AND LOGINNAME NOT IN ('corp\luciano.marques', 'corp\srv_psql02','rafael.bahia','sa','REALMADRID02\Administrator','luciano.marques')


SELECT * FROM dba.dbo.AuditDDLOperations
where 1=1
and (Event in ('ALTER_INDEX','UPDATE_STATISTICS','GRANT_DATABASE','DENY_DATABASE')) 
--AND (CONVERT(CHAR(8),PostTime,8) between '00:00:00.000' and '02:45:00.000')
--AND tsql LIKE '%catalog%'
GO

SELECT * FROM dba.dbo.AuditDDLOperations
where 1=1
and tsql like 'create%'
and loginname = 'CORP\rafael.bahia'

SELECT * FROM dba.dbo.AuditDDLOperations
where 1=1
and tsql like 'create%'
and loginname = 'sa'

DELETE FROM dba.dbo.AuditDDLOperations
where 1=1
and tsql like 'create%'
and loginname = 'sa'


SELECT * FROM dba.dbo.AuditDDLOperations
where 1=1
and (tsql like 'drop user%' or tsql like 'drop role%')
and loginname = 'sa'


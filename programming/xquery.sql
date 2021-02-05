DECLARE @cmd VARCHAR(max),@bdid VARCHAR(100)
SET @bdid= (SELECT database_id FROM sys.databases WHERE name = DB_NAME())
SELECT @cmd = replace (
	(
	SELECT 'kill ' + CAST(spid AS VARCHAR(10)) + ' | ' FROM sys.sysprocesses WHERE dbid = @bdid AND spid <> @@SPID
	FOR XML PATH('')
	)
,'|',';')

EXEC (@cmd)
--SELECT @cmd




declare @objname sysname
declare @objid int 
set @objname = 'TipoAgendamentoXML'
set @objid = (select object_id(@objname))
DECLARE @cmd VARCHAR(max)

if exists (select * from sys.foreign_keys where referenced_object_id = @objid)  
begin
	SELECT @cmd = replace ( 
	( 
		select 'alter table ' +  db_name() + '.' + rtrim(schema_name(ObjectProperty(parent_object_id,'schemaid')))  
		+ '.' + object_name(parent_object_id) + ' drop constraint ' + object_name(object_id)  + '|'
		from sys.foreign_keys 
		where referenced_object_id = @objid 
		FOR XML PATH('')
	)
	,'|',';')

	exec (@cmd)
end
GO
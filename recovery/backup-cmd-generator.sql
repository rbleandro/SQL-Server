/*
DECLARE @hora VARCHAR(8)=(SELECT REPLACE(CONVERT(VARCHAR(8),convert(time,GETDATE())),':',''))
DECLARE @data VARCHAR(10)=(SELECT REPLACE(CONVERT(VARCHAR(10),convert(date,GETDATE())),'-',''))
DECLARE @db VARCHAR(1000)='CCMStatisticalData'
DECLARE @path VARCHAR(4000)='S:\DB_Backups\'+@db+'_'+@data+'_'+@hora

BACKUP DATABASE @db TO DISK = @path WITH COMPRESSION,STATS=10
GO

DECLARE @hora VARCHAR(8)=(SELECT REPLACE(CONVERT(VARCHAR(8),convert(time,GETDATE())),':',''))
DECLARE @data VARCHAR(10)=(SELECT REPLACE(CONVERT(VARCHAR(10),convert(date,GETDATE())),'-',''))
DECLARE @db VARCHAR(1000)='CCMData'
DECLARE @path VARCHAR(4000)='S:\DB_Backups\'+@db+'_'+@data+'_'+@hora

BACKUP DATABASE @db TO DISK = @path WITH COMPRESSION,STATS=10
GO
*/

DECLARE @hora VARCHAR(8)=(SELECT REPLACE(CONVERT(VARCHAR(8),convert(time,GETDATE())),':',''));
DECLARE @data VARCHAR(10)=(SELECT REPLACE(CONVERT(VARCHAR(10),convert(date,GETDATE())),'-',''));
DECLARE @path VARCHAR(4000)='C:\db_backups\',@bkdbcmd VARCHAR(4000),@bklogcmd VARCHAR(4000),@shrinkcmd VARCHAR(4000),@bkpandshrink VARCHAR(MAX),@option VARCHAR(1000) = 'bkp full only';
DECLARE @dname sysname='master',@copy_only BIT = 0,@compression BIT=1, @truncateLog BIT = 0;
DECLARE c CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT d.name 
FROM sys.databases d
WHERE d.name not like 'tempdb%';
OPEN c;
FETCH NEXT FROM c INTO @dname;
WHILE @@FETCH_STATUS <> -1
BEGIN
	SET @bkdbcmd = 'use ' + @dname + ' BACKUP DATABASE '+@dname+' TO DISK = '''+@path+@dname+'_'+@data+'_'+@hora+'.bak'' WITH STATS=10' + CASE @copy_only WHEN 1 THEN + ',COPY_ONLY' ELSE '' END + CASE @compression WHEN 1 THEN + ',COMPRESSION' ELSE '' END;
	SET @bklogcmd = 'use ' + @dname + '; BACKUP LOG '+@dname+' TO DISK = '''+@path+@dname+'_'+@data+'_'+@hora+'.trn'' WITH NOUNLOAD' + CASE @compression WHEN 1 THEN + ',COMPRESSION' ELSE '' END + ';' /*+ CASE @truncateLog WHEN 1 THEN + '; DBCC SHRINKFILE (N''SmartSort_Canpar_SCS_Log'' , 0, TRUNCATEONLY);' ELSE '' END*/;
	SET @shrinkcmd = (SELECT 'use '+ @dname +'; DBCC SHRINKFILE('''+af.name+''', 0, TRUNCATEONLY)' + ';' AS [data()] FROM sys.master_files af WHERE af.database_id = DB_ID(@dname) AND af.type=1 FOR XML PATH(''))
	
	--PRINT @bkdbcmd;
	--PRINT @bklogcmd;
	--PRINT @shrinkcmd;
	
	SET @bkpandshrink = @bklogcmd + @shrinkcmd;
	
	IF @option = 'bkp log and truncate'
		print (@bkpandshrink);
	ELSE IF @option = 'bkp log only'
		EXEC (@bklogcmd);
	ELSE IF @option = 'bkp full only'
		EXEC (@bkdbcmd);

	FETCH NEXT FROM c INTO @dname;
END;
CLOSE c;
DEALLOCATE c;
GO



IF NOT EXISTS(SELECT * FROM [10.90.182.75].master.sys.procedures WHERE name ='restoredblog')
BEGIN
	RAISERROR('The restoredblog procedure does not exist in the target database or the target server is unreachable at the moment.',16,2);
END
ELSE
BEGIN
	DECLARE @hora VARCHAR(8)=(SELECT REPLACE(CONVERT(VARCHAR(8),CONVERT(TIME,GETDATE())),':',''));
	DECLARE @data VARCHAR(10)=(SELECT REPLACE(CONVERT(VARCHAR(10),CONVERT(DATE,GETDATE())),'-',''));
	DECLARE @path VARCHAR(4000)='E:\DB_Backups\',@bkdbcmd VARCHAR(4000),@bklogcmd VARCHAR(4000),@recogcmd VARCHAR(4000),@shrinkcmd VARCHAR(4000),@bkpandshrink VARCHAR(MAX),@option VARCHAR(1000) = 'bkp log only';
	DECLARE @dname sysname='master',@copy_only BIT = 0,@compression BIT=1, @truncateLog BIT = 1,@copyCmd VARCHAR(2000), @OpResult INT;
	DECLARE @DeleteDate DATETIME = DATEADD(DAY,-2,GETDATE()),@fullfilepath VARCHAR(1000);

	DECLARE c CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT d.name FROM sys.databases d
	WHERE d.name IN ('bbsort');
	
	OPEN c;
	FETCH NEXT FROM c INTO @dname;
	
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		SET @bkdbcmd = 'use ' + @dname + ' BACKUP DATABASE '+@dname+' TO DISK = '''+@path+@dname+'\'+@dname+'_'+@data+'_'+@hora+'.bak'' WITH STATS=10' + CASE @copy_only WHEN 1 THEN + ',COPY_ONLY' ELSE '' END + CASE @compression WHEN 1 THEN + ',COMPRESSION' ELSE '' END;
		SET @bklogcmd = 'use ' + @dname + '; BACKUP LOG '+@dname+' TO DISK = '''+@path+@dname+'\'+@dname+'_'+@data+'_'+@hora+'.trn'' WITH NOUNLOAD' + CASE @compression WHEN 1 THEN + ',COMPRESSION' ELSE '' END + ';' /*+ CASE @truncateLog WHEN 1 THEN + '; DBCC SHRINKFILE (N''SmartSort_Canpar_SCS_Log'' , 0, TRUNCATEONLY);' ELSE '' END*/;
		SET @shrinkcmd = (SELECT 'use '+ @dname +'; DBCC SHRINKFILE('''+af.name+''', 0, TRUNCATEONLY)' + ';' AS [data()] FROM sys.sysaltfiles af WHERE af.dbid = DB_ID(@dname) AND af.groupid=0 FOR XML PATH(''))
		SET @recogcmd = 'restore LOG '+@dname+' from DISK = '''+@path+@dname+'\'+@dname+'_'+@data+'_'+@hora+'.trn'' WITH FILE = 1,  NOUNLOAD,  STATS = 5,norecovery' + ';'

		--PRINT @bkdbcmd;
		PRINT @bklogcmd;
		PRINT @recogcmd;
		--PRINT @shrinkcmd;
	
		SET @bkpandshrink = @bklogcmd + @shrinkcmd;
	
		IF @option = 'bkp log and truncate'
			EXEC (@bkpandshrink);
		ELSE IF @option = 'bkp log only'
			EXEC (@bklogcmd);
		ELSE IF @option = 'bkp full only'
			EXEC (@bkdbcmd);
	
		--copies the backup to the ftp (we do not have CommVault running on this server so we need to store the file offsite to allow proper DR)
		SET @copyCmd = 'copy '+ @path+@dname+'\' + @dname + '_' + @data + '_' + @hora + '.trn \\10.90.182.75\db_backups\bbsort\ /Y /V';
		SET @fullfilepath=@path+@dname+'\' + @dname + '_' + @data + '_' + @hora + '.trn';

		EXEC @OpResult = master.sys.xp_cmdshell @copyCmd;
	
		IF (@OpResult = 0)  
			PRINT 'Success while copying backup file to the FTP server.'  
		ELSE  
			RAISERROR ( 'Failure while copying backup file to the FTP server. Copy command was: %s.',16,1,@copyCmd);  

		EXEC @OpResult=[10.90.182.75].master.dbo.restoredblog @dname,@fullfilepath --change the linked server to the secondary server here

		SELECT @OpResult;

		--deletes files older than 3 days from the ftp. Old files on the production server are deleted by the daily maintenance plan
		--EXEC @OpResult = master.sys.xp_delete_file 0,'\\CPRHQVFS4\Source\Backups\JCC-Backups\','trn',@DeleteDate,0;

		--IF (@OpResult = 0)  
		--	PRINT 'Success while deleting old backup files from the FTP.'  
		--ELSE  
		--	RAISERROR ('Failure while deleting old backup files from the FTP.',16,1);  

		FETCH NEXT FROM c INTO @dname;
	END;
	CLOSE c;
	DEALLOCATE c;
	END
GO



/************************ CREATE THIS PROC AT THE SECONDARY SERVER ON MASTER DATABASE ***********************/

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].restoredblog') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].restoredblog AS' 
END
GO
ALTER PROCEDURE restoredblog (@dbname VARCHAR(50),@fullfilepath VARCHAR(500))
as
BEGIN
	DECLARE @cmd VARCHAR(max)
	SET @cmd ='restore LOG BBSort from DISK = '''+@fullfilepath+''' WITH FILE = 1,  NOUNLOAD,  STATS = 5,norecovery';
	EXEC (@cmd);
END

/************************ *********************** *********************** *********************** ***********************/

--EXEC [10.90.182.75].master.dbo.restoredblog 'bbsort','E:\DB_Backups\BBSort\BBSort_20200917_205752.trn'
--SELECT COUNT(*) FROM OPENQUERY ([10.90.182.75], 'select top 1 * from master.sys.tables where 1=2; restore LOG BBSort from DISK = ''E:\DB_Backups\BBSort\BBSort_20200917_203329.trn'' WITH FILE = 1,  NOUNLOAD,  STATS = 5,norecovery;' );

--EXEC sp_configure 'show adv',1 RECONFIGURE
--EXEC sp_configure 'xp_cmdshell',1 RECONFIGURE



--DECLARE @copycmd VARCHAR(1000); SET @copyCmd = 'copy e:\db_backups\bbsort\BBSort_20200917_205114.trn \\10.90.182.75\db_backups\bbsort\ /Y /V'; EXEC master.sys.xp_cmdshell @copyCmd;

--deletes files older than 2 days from the ftp. Old files on the production server are deleted by the daily maintenance plan
--DECLARE @DeleteDate DATETIME = DATEADD(DAY,-2,GETDATE())
--EXEC  master.sys.xp_delete_file 0,'e:\db_backups\','trn',@DeleteDate,1;
--EXEC  master.sys.xp_delete_file 0,'e:\db_backups\','bak',@DeleteDate,1;
--EXEC  master.sys.xp_delete_file 0,'\\10.90.182.75\db_backups','trn',@DeleteDate,1;
--EXEC  master.sys.xp_delete_file 0,'\\10.90.182.75\db_backups','bak',@DeleteDate,1;

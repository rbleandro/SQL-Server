IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[s_ftp_PutFile]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[s_ftp_PutFile]
GO

CREATE PROCEDURE s_ftp_PutFile
@FTPServer	VARCHAR(128) ,
@FTPUser	VARCHAR(128) ,
@FTPPWD		VARCHAR(128) ,
@FTPPath	VARCHAR(128) ,
@FTPFileName	VARCHAR(128) ,
@SourcePath	VARCHAR(128) ,
@SourceFile	VARCHAR(128) ,
@workdir	VARCHAR(128)
AS

	DECLARE	@cmd VARCHAR(1000)
	DECLARE @workfilename VARCHAR(128)
	
	SET @workfilename = 'ftpcmd.txt'
	
	-- deal with special characters for echo commands
	SET @FTPServer = REPLACE(REPLACE(REPLACE(@FTPServer, '|', '^|'),'<','^<'),'>','^>')
	SET @FTPUser = REPLACE(REPLACE(REPLACE(@FTPUser, '|', '^|'),'<','^<'),'>','^>')
	SET @FTPPWD = REPLACE(REPLACE(REPLACE(@FTPPWD, '|', '^|'),'<','^<'),'>','^>')
	SET @FTPPath = REPLACE(REPLACE(REPLACE(@FTPPath, '|', '^|'),'<','^<'),'>','^>')
	
	SET	@cmd = 'echo '					+ 'open ' + @FTPServer
			+ ' > ' + @workdir + @workfilename
	EXEC master..xp_cmdshell @cmd, NO_OUTPUT
	--select @cmd
	
	SET	@cmd = 'echo '					+ @FTPUser
			+ '>> ' + @workdir + @workfilename
	EXEC master..xp_cmdshell @cmd, NO_OUTPUT
	--select @cmd
	
	SET	@cmd = 'echo '					+ @FTPPWD
			+ '>> ' + @workdir + @workfilename
	EXEC master..xp_cmdshell @cmd, NO_OUTPUT
	--select @cmd
	
	SET	@cmd = 'echo '					+ 'put ' + @SourcePath + @SourceFile + ' ' + @FTPPath + @FTPFileName
			+ ' >> ' + @workdir + @workfilename
	EXEC master..xp_cmdshell @cmd, NO_OUTPUT
	--select @cmd
	
	SET	@cmd = 'echo '					+ 'quit'
			+ ' >> ' + @workdir + @workfilename
	EXEC master..xp_cmdshell @cmd, NO_OUTPUT
	--select @cmd
	
	SET @cmd = 'ftp -s:' + @workdir + @workfilename
	--select @cmd
	
	CREATE TABLE #a (id INT IDENTITY(1,1), s VARCHAR(1000))
	INSERT #a
	EXEC master..xp_cmdshell @cmd

	SELECT id, ouputtmp = s FROM #a

	
GO

/*
exec s_ftp_PutFile 	
		@FTPServer = 'lmshqvopsftp01.loomisexpress.com' ,
		@FTPUser = 'MTRCUBING' ,
		@FTPPWD = 'Ftp123456' ,
		@FTPPath = '/MTRCUBING/' ,
		@FTPFileName = 'BATCH_UPLOAD_TEST.20191001134737' ,
		@SourcePath = 'E:\temp\' ,
		@SourceFile = 'BATCH_UPLOAD_TEST.20191001134737' ,
		@workdir = 'E:\temp\'
*/
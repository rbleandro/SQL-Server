-- Checking if the file with the optouts is actually there
DECLARE @Path varchar(128) ,
@FileName varchar(128)
SET @Path = @pasta + '\'
SET @FileName = @nometxt

DECLARE @objFSys int
DECLARE @i int
DECLARE @File varchar(1000)

SET @File = @Path + @FileName
EXEC sp_OACreate 'Scripting.FileSystemObject', @objFSys out
EXEC sp_OAMethod @objFSys, 'FileExists', @i out, @File
IF @i = 1
BEGIN
	-- Updating values
	UPDATE cliente set flagnews = 0 where EMAIL
	IN (select LTRIM(RTRIM(REPLACE(line,';',''))) COLLATE SQL_Latin1_General_CP1_CI_AS from [master].[dbo].[uftReadfileAsTable] (@pasta, @nometxt, 1000000)) AND flagnews = 1
END
ELSE
	exec msdb.dbo.sp_send_dbmail @subject = 'Erro na carga de OptOut', @recipients = 'rafael.bahia@corp.pontofrio.com', @body = 'Não foi possível gerar o arquivo com os emails a serem alterados. Para mais detalhes, verifique o log do script de geração do arquivo.'

EXEC sp_OADestroy @objFSys 
GO

CREATE FUNCTION [dbo].[uftReadfileAsTable]
(
	@Path VARCHAR(255),
	@Filename VARCHAR(100)
)
RETURNS 
@File TABLE
([LineNo] INT IDENTITY(1,1), 
line VARCHAR(8000)) 

AS
BEGIN

	DECLARE  @objFileSystem INT
		,@objTextStream INT,
		@objErrorObject INT,
		@strErrorMessage VARCHAR(1000),
		@Command VARCHAR(1000),
		@hr INT,
		@String VARCHAR(8000),
		@YesOrNo INT

	SELECT @strErrorMessage='opening the File System Object'
	EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT


	IF @hr=0 
		SELECT @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@Path+'\'+@Filename+'"',@Command=@Path+'\'+@Filename

	IF @hr=0 EXECUTE @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile'
	, @objTextStream OUT, @Command,1,false,0--for reading, FormatASCII

	WHILE @hr=0
	BEGIN
		IF @hr=0 SELECT @objErrorObject=@objTextStream, 
			@strErrorMessage='finding out if there is more to read in "'+@Filename+'"'
		IF @hr=0 EXECUTE @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT

		IF @YesOrNo<>0  
			BREAK
		IF @hr=0 SELECT @objErrorObject=@objTextStream, 
			@strErrorMessage='reading from the output file "'+@Filename+'"'
		IF @hr=0 EXECUTE @hr = sp_OAMethod  @objTextStream, 'Readline', @String OUTPUT
			INSERT INTO @File(line) SELECT @String
	END

	IF @hr=0 SELECT @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@Filename+'"'
	IF @hr=0 EXECUTE @hr = sp_OAMethod  @objTextStream, 'Close'


	IF @hr<>0
	BEGIN
		DECLARE @Source VARCHAR(255),@Description VARCHAR(255),@Helpfile VARCHAR(255),@HelpID INT

		EXECUTE sp_OAGetErrorInfo  @objErrorObject, @Source OUTPUT,@Description OUTPUT,@Helpfile OUTPUT,@HelpID OUTPUT
		
		SELECT @strErrorMessage='Error whilst '
				+COALESCE(@strErrorMessage,'doing something')
				+', '+COALESCE(@Description,'')
		INSERT INTO @File(line) SELECT @strErrorMessage
	
	END
	
	EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set

	RETURN 
END
-- use this script to export an image contained in a table (using the image or varbinary data type)
-- note that this script uses Ole automation procedures. This feature must be enabled on the instance for this to work

EXEC sp_configure 'Ole Automation Procedures',1
RECONFIGURE WITH OVERRIDE

DECLARE  @idarquivo INT,
         @Nome VARCHAR(128),
         @Caminho varchar(500),
         --@TIMESTAMP VARCHAR(1000),
         @binario varbinary(max),
         @ObjectToken INT
 
DECLARE crsImage CURSOR  FOR             
SELECT idarquivo,
       Nome,ArquivoBinario
FROM   Arquivo
WHERE  IdArquivo =1
 
OPEN crsImage
 
FETCH NEXT FROM crsImage
INTO @idarquivo,
     @Nome,@binario
 
WHILE (@@FETCH_STATUS = 0) 
  BEGIN

    SET @Caminho = 'd:\' + cast (@idarquivo as varchar(100)) + '_' + @Nome + '.bmp'
    --SET @TIMESTAMP = 'd:\' + replace(replace(replace(replace(convert(varchar,getdate(),121),'-',''),':',''),'.',''),' ','') + '.bmp'
    
    
    EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
	EXEC sp_OASetProperty @ObjectToken, 'Type', 1
	EXEC sp_OAMethod @ObjectToken, 'Open'
	EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @binario
	EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @Caminho, 2
	EXEC sp_OAMethod @ObjectToken, 'Close'
	EXEC sp_OADestroy @ObjectToken
    
    FETCH NEXT FROM crsImage
    INTO @idarquivo,
         @Nome,@binario
  END  -- cursor loop
 
CLOSE crsImage
DEALLOCATE crsImage

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


DECLARE @idarquivo INT,
        @Nome VARCHAR(128),
        @Caminho VARCHAR(500),
        --@TIMESTAMP VARCHAR(1000),
        @binario VARBINARY(MAX),
        @ObjectToken INT;

DECLARE crsImage CURSOR FOR
SELECT TOP 10
       idarquivo,
       Nome,
       ArquivoBinario
FROM Arquivo;
--WHERE  Nome != 'no_image_available_large.gif'

OPEN crsImage;

FETCH NEXT FROM crsImage
INTO @idarquivo,
     @Nome,
     @binario;

WHILE (@@FETCH_STATUS = 0)
BEGIN

    SET @Caminho = 'g:\Imagens_db_des_nike\' + CAST(@idarquivo AS VARCHAR(100)) + '_' + @Nome + '.bmp';
    --SET @TIMESTAMP = 'd:\' + replace(replace(replace(replace(convert(varchar,getdate(),121),'-',''),':',''),'.',''),' ','') + '.bmp'


    EXEC sys.sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT;
    EXEC sys.sp_OASetProperty @ObjectToken, 'Type', 1;
    EXEC sys.sp_OAMethod @ObjectToken, 'Open';
    EXEC sys.sp_OAMethod @ObjectToken, 'Write', NULL, @binario;
    EXEC sys.sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @Caminho, 2;
    EXEC sys.sp_OAMethod @ObjectToken, 'Close';
    EXEC sys.sp_OADestroy @ObjectToken;

    FETCH NEXT FROM crsImage
    INTO @idarquivo,
         @Nome,
         @binario;
END; -- cursor loop

CLOSE crsImage;
DEALLOCATE crsImage;
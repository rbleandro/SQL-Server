/*

Remarks:

• 	This script will generate the command you should run on command prompt to extract and load data between 2 SQL Server databases. 
	Just click on the link on the output. It will open a second tab containing the actual script.

•	This script is provided as is and the user is responsible for any misuse and/or loss of data that might occur.

•	The procedure will only work for user tables in the dbo schema by default. You can change the proc code to alter that.

•	You can make the proc to generate the bcp command for multiple tables. Just alter the cursor query accordingly.

•	The procedure authenticates to the SQL Servers using the integrated authentication mode. You can change the code to connect using a login/password if you want.
	For that, just provide values for parameters -U and -P of the BCP command.

•	The default delimiter is pipe "|". You can change it to anything you like.

•	If the delimiter parameter is NULL, BCP will export data in native mode instead of text mode.

*/

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].BCPGenerator') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].BCPGenerator AS' 
END
GO
ALTER PROCEDURE BCPGenerator
(
@tableToBCP NVARCHAR(128)   ='' 			-- the table you want to export/import
,@Top          VARCHAR(10)     = NULL 				-- Leave NULL to BCP all rows
,@Delimiter    VARCHAR(4)      = NULL
,@originserver NVARCHAR(100)='' 			--put the source server here (where you are going to read the data from)
,@destserver NVARCHAR(100)='' 			--put the destination server here (where you are going to write the data to)
,@origindb VARCHAR(100)=''					--put the origin database here
,@destdb NVARCHAR(100)='' 				--put the destination database here
,@Directory    VARCHAR(256)    = '' 	--where to put the files containing the actual data. This path must exist in the Origin Server.
,@qcomp varchar(MAX)=NULL 							--Leave NULL for nonfiltered export. If you wish to filter the data  being exported, just write your where filter here. E.g.: 'where id=1'
)
AS
SET CONCAT_NULL_YIELDS_NULL OFF	

--DECLARE @tableToBCP NVARCHAR(128)   ='ds_test' 			-- the table you want to export/import
--    , @Top          VARCHAR(10)     = 1000 				-- Leave NULL to BCP all rows
--    , @Delimiter    VARCHAR(4)      = '|'
--    ,@originserver NVARCHAR(100)='CPRDC1VDEVSQL01' 			--put the source server here (where you are going to read the data from)
--	,@destserver NVARCHAR(100)='CPRDC1VDEVSQL01' 			--put the destination server here (where you are going to write the data to)
--	,@origindb VARCHAR(100)='DBA_Test'					--put the origin database here
--	,@destdb NVARCHAR(100)='DBA_Test' 				--put the destination database here
--	, @Directory    VARCHAR(256)    = 'c:\temp\BCPS' 	--where to put the files containing the actual data. This path must exist in the Origin Server.
--	,@qcomp varchar(MAX)=NULL; 							--Leave NULL for nonfiltered export. If you wish to filter the data  being exported, just write your where filter here. E.g.: 'where id=1'

DECLARE @columnList VARCHAR(MAX)='';
DECLARE @bcpStatementIn NVARCHAR(MAX)='';
DECLARE @bcpStatementIn2 NVARCHAR(MAX)='';
DECLARE @bcpStatement2 NVARCHAR(MAX)='';
DECLARE @bcpStatement NVARCHAR(MAX) = '';

DECLARE c CURSOR LOCAL READ_ONLY FORWARD_ONLY FOR 
SELECT name 
FROM sys.tables 
WHERE 1=1
AND is_ms_shipped=0
AND [schema_id]=SCHEMA_ID('dbo')
AND name = @tableToBCP
ORDER BY name;

OPEN c;
FETCH NEXT FROM c INTO @tableToBCP;
WHILE @@FETCH_STATUS <> -1
BEGIN

SET @bcpStatement = CHAR(10) + CHAR(13) + @bcpStatement + 'BCP "SELECT ';
SET @bcpStatement2 = CHAR(10) + CHAR(13) + @bcpStatement2 + 'BCP ';

SELECT @columnList=REPLACE(a.v,',|','')
FROM 
(
	SELECT
	(
		SELECT name +',' AS [data()]
		FROM sys.columns 
		WHERE object_id = OBJECT_ID(@tableToBCP)
		FOR XML PATH('')
	) + '|' AS v
) AS a
 
IF @Top IS NOT NULL
    SET @bcpStatement = @bcpStatement + 'TOP (' + @Top + ') ';
 
 
SET @bcpStatement = @bcpStatement + @columnList + ' FROM ' + @origindb + '.dbo.' + @tableToBCP + ' ' + @qcomp + '" queryout '
    + @Directory + '\' + REPLACE(@tableToBCP, '.', '_') + '.dat -S' + @originserver
    + ' -T -t"' + @Delimiter + '" -c -CRAW -q' + CHAR(10) + CHAR(13);

SET @bcpStatement2 = @bcpStatement2 + ' ' + @origindb + '.dbo.' + @tableToBCP + ' out '
    + @Directory + REPLACE(@tableToBCP, '.', '_') + '.dat -S' + @originserver + ' -T -n -E -q'  + CHAR(10) + CHAR(13);

SET @bcpStatementIn = @bcpStatementIn + 'bcp  ' + @destdb + '.dbo.' + @tableToBCP + ' in ' 
	+ @Directory + '\' + REPLACE(@tableToBCP, '.', '_') + '.dat -S' + @destserver
    + ' -T -t"' + @Delimiter + '" -c -CRAW -q' + CHAR(10) + CHAR(13);

SET @bcpStatementIn2 = @bcpStatementIn2 + 'bcp  ' + @destdb + '.dbo.' + @tableToBCP + ' in ' 
	+ @Directory + REPLACE(@tableToBCP, '.', '_') + '.dat -S' + @destserver + ' -T -n -E -q' + CHAR(10) + CHAR(13);
 

FETCH NEXT FROM c INTO @tableToBCP;
END;
CLOSE c;
DEALLOCATE c;

DECLARE @VeryLongText NVARCHAR(MAX) = '';

SELECT @VeryLongText =  @VeryLongText + CASE WHEN @Delimiter IS NULL THEN @bcpStatement2 + @bcpStatementIn2 ELSE @bcpStatement + @bcpStatementIn end; 
SELECT @VeryLongText AS [processing-instruction(x)] FOR XML PATH('');
GO


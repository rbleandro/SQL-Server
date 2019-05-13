DECLARE @TabNome VARCHAR(256)
DECLARE @ColNome VARCHAR(256),@schema VARCHAR(100)
DECLARE @Resultado TABLE(TabNome VARCHAR(MAX), ColNome VARCHAR(MAX),[schema] VARCHAR(100))
DECLARE @retval INT,@sql NVARCHAR(max)
DECLARE Colunas CURSOR FOR

--Busca todas as colunas de todas as tabelas
SELECT DISTINCT COL.Name, TAB.Name,SCHEMA_NAME(TAB.schema_id)--,TYP.Name
FROM SYS.Columns COL
INNER JOIN SYS.Tables TAB ON TAB.Object_Id = COL.Object_Id
INNER JOIN SYS.Types TYP ON COL.System_Type_Id = TYP.System_Type_Id
WHERE TYP.Name IN ('varchar','nvarchar','text','sysname') -- Filtra o tipo de dado que você procura para evitar a procura de uma string em um inteiro
ORDER BY TAB.Name

OPEN Colunas
FETCH NEXT FROM Colunas INTO @ColNome, @TabNome,@schema
WHILE @@FETCH_STATUS = 0
BEGIN
	--PRINT @TabNome;
	SET @sql=N'select @retvalOUT=count(*) from (Select top 1 * From '+ @schema +'.' + @TabNome + ' Where ' + @ColNome + ' Like ''%spPresenteCompradoListaPorSku%'') as a'
	PRINT @sql
	EXEC sys.sp_executesql	@sql,N'@retvalOUT int OUTPUT',@retvalOUT=@retval OUTPUT

	IF (@retval > 0) -- Caso encontre, salva a tabela e a coluna
	BEGIN
		INSERT INTO @Resultado VALUES(@TabNome,@ColNome,@schema)
	END
FETCH NEXT FROM Colunas INTO @ColNome, @TabNome,@schema
END
CLOSE Colunas
DEALLOCATE Colunas


 SELECT * FROM @Resultado as Tabela -- Lista todas as tabelas e suas colunas que possuiam o valor desejado   

SELECT object_name(object_id),* FROM sys.columns WHERE name='sql_handle'
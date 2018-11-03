USE CLRUtilities;
GO

ALTER PROCEDURE ProjMunging
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp;
	IF OBJECT_ID('tempdb..#temp2') IS NOT NULL
		DROP TABLE #temp2;

	DECLARE @linha VARCHAR(8000),@ltratada VARCHAR(8000),@ltratada2 VARCHAR(8000);
	DECLARE @PosCB INT, @PosUnd INT;
	DECLARE @FindCB VARCHAR(1) = '\';
	DECLARE @Obj VARCHAR(500);

	CREATE TABLE #temp (s VARCHAR(8000),obj VARCHAR(500));
	CREATE TABLE #temp2 (s VARCHAR(8000),obj VARCHAR(500));

	DECLARE tabela CURSOR 
	FOR 
		SELECT 
		--TOP 5 
		REPLACE(REPLACE(REPLACE(REPLACE(linha,'None Include','Build Include'),'PostDeploy Include','Build Include'),CHAR(10),'' ),CHAR(13),'') AS linha
		FROM dbo.Strings;
		--WHERE linha LIKE '%build%' AND linha LIKE '%procs%'; ---remover
		--WHERE linha LIKE'%colecaoparametroprodutototal%'
	OPEN tabela;
	FETCH NEXT FROM tabela INTO @linha;
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @linha NOT LIKE '%.sql"%'
			INSERT INTO #temp ( s ) VALUES  ( @linha);
		ELSE
		BEGIN	
			SET @PosCB = (SELECT LEN(@linha) - CHARINDEX(@FindCB,REVERSE(@linha)));
		
			SET @ltratada = (SELECT REPLACE(@linha,SUBSTRING(@linha,1,@PosCB+1),''));
			SET @ltratada = (SELECT REPLACE(@ltratada,SUBSTRING(@ltratada,PATINDEX('%.%',@ltratada),CHARINDEX('>',@ltratada)),''));
			SET @ltratada2 = (SELECT REPLACE(@ltratada,SUBSTRING(@ltratada,PATINDEX('%[_][0-9]',@ltratada),1000),''));

			SET @Obj = (SELECT CASE WHEN @ltratada2='' OR @ltratada2 IS NULL THEN @ltratada ELSE @ltratada2 END);

			INSERT INTO #temp ( s,obj ) VALUES  ( @linha,@Obj);

		END;

	FETCH NEXT FROM tabela INTO @linha;
	END;
	CLOSE tabela;
	DEALLOCATE tabela;


	DECLARE tabela CURSOR 
	FOR 
		SELECT 
		s,obj
		FROM #temp;
	
	OPEN tabela;
	FETCH NEXT FROM tabela INTO @linha,@Obj;
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @Obj IS NULL
		BEGIN
			INSERT INTO #temp2 ( s,obj ) VALUES  ( @linha,@Obj);
			--PRINT @linha;
		END;
		ELSE
		BEGIN	
			SET @PosCB = (SELECT LEN(@linha) - CHARINDEX(@FindCB,REVERSE(@linha)));
		
			SET @ltratada = (SELECT REPLACE(@linha,SUBSTRING(@linha,1,@PosCB+1),''));
			SET @ltratada = (SELECT REPLACE(@ltratada,SUBSTRING(@ltratada,PATINDEX('%.%',@ltratada),CHARINDEX('>',@ltratada)),''));
			SET @ltratada2 = (SELECT REPLACE(@ltratada,SUBSTRING(@ltratada,PATINDEX('%[_][0-9]',@ltratada),1000),''));

			SET @Obj = (SELECT CASE WHEN @ltratada2='' OR @ltratada2 IS NULL THEN @ltratada ELSE @ltratada2 END);

			IF NOT EXISTS(SELECT 1 FROM #temp2 WHERE obj = @Obj )
			BEGIN
				INSERT INTO #temp2 ( s,obj ) VALUES  ( @linha,@Obj);
			--	SELECT @ltratada
			END;
			--ELSE	
			--	PRINT 'Skipping ' + @ltratada + ' --  linha: ' + @linha;
		END;

	FETCH NEXT FROM tabela INTO @linha,@Obj;
	END;
	CLOSE tabela;
	DEALLOCATE tabela;

	SELECT s FROM #temp2; 
END;
GO

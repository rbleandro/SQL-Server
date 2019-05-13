declare @i int;

 SELECT @i = MAX(IdFreteValor) FROM dbo.FreteValor;

 WITH tmp (gapId) AS (
   SELECT DISTINCT a.IdFreteValor + 1
   FROM dbo.FreteValor a WITH (NOLOCK)
   WHERE NOT EXISTS( SELECT * FROM dbo.FreteValor b WITH (NOLOCK)
        WHERE b.IdFreteValor  = a.IdFreteValor + 1)
   AND a.IdFreteValor < @i

   UNION ALL

   SELECT a.gapId + 1
   FROM tmp a
   WHERE NOT EXISTS( SELECT * FROM FreteValor b WITH (NOLOCK)
        WHERE b.IdFreteValor  = a.gapId + 1)
   AND a.gapId < @i
 )
 SELECT gapId
 FROM tmp
 ORDER BY gapId;



SELECT * FROM (
SELECT idfretevalor, ROW_NUMBER() OVER (ORDER BY idfretevalor DESC) AS rownum
FROM dbo.FreteValor
) b
WHERE rownum <= 600176
ORDER BY rownum desc


--SELECT COUNT(*) FROM fretevalor nolock WHERE IdFreteValor < 151619747
select top 10 * FROM fretevalor nolock WHERE IdFreteValor < 151619747 ORDER BY IdFreteValor DESC

--151619746
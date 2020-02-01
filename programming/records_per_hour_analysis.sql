DECLARE @divert_timeInicial DATETIME = '2019-09-02'
--@divert_timeInicial DATETIME = DATEADD(HOUR,-72,GETDATE())
, @divert_timeFinal DATETIME = DATEADD(HOUR,0,GETDATE());

;WITH cte AS
(
	SELECT DATEADD(HOUR, DATEDIFF(hour, 0, CONVERT(DATETIME,CONVERT(varchar(10),CONVERT(date,@divert_timeInicial)) + ' ' + CONVERT(varchar(10),DATEPART(hour,@divert_timeInicial)) + ':00:00')), 0) AS minuto,0 AS countc
	UNION ALL
	SELECT DATEADD(HOUR	,1,minuto),0 AS countc FROM cte
	WHERE minuto < @divert_timeFinal
)

--SELECT * FROM cte
--OPTION (MAXRECURSION 0,RECOMPILE)

SELECT cte.minuto AS minuto
,CASE WHEN c.minuto IS NOT NULL THEN c.Quantidade ELSE cte.countc END AS Quantidade
FROM cte 
LEFT JOIN
(
	SELECT DATEADD(HOUR, DATEDIFF(hour, 0, CONVERT(DATETIME,CONVERT(varchar(10),CONVERT(date,divert_time)) + ' ' + CONVERT(varchar(10),DATEPART(hour,divert_time)) + ':00:00')), 0) AS minuto, COUNT(*) AS Quantidade
	FROM databatch
	WHERE 1=1
	AND divert_time > @divert_timeInicial
	AND divert_time <= @divert_timeFinal
	GROUP BY DATEADD(HOUR, DATEDIFF(hour, 0, CONVERT(DATETIME,CONVERT(varchar(10),CONVERT(date,divert_time)) + ' ' + CONVERT(varchar(10),DATEPART(hour,divert_time)) + ':00:00')), 0)--,divert_time
) AS c ON cte.minuto = c.minuto

ORDER BY cte.minuto
OPTION (MAXRECURSION 0,RECOMPILE)
GO

IF OBJECT_ID('tempdb..#CRPend') IS NOT NULL 
	DROP TABLE #CRPend
IF OBJECT_ID('tempdb..#CRApp') IS NOT NULL 
	DROP	TABLE #CRApp

IF object_id('tempdb..#temp0') is not null
	drop TABLE #temp0

if object_id('tempdb..#temp1') is not null
	drop TABLE #temp1

DECLARE @p0 nvarchar(4000),@p1 nvarchar(4000);

CREATE TABLE #temp0
(
    ProjectId INT NOT NULL,
    WorkItemType NVARCHAR(256) COLLATE DATABASE_DEFAULT NOT NULL,

    UNIQUE CLUSTERED (ProjectId, WorkItemType)
)

INSERT #temp0
SELECT Category.ProjectId, WTypeName.String 
FROM dbo.WorkItemTypeCategories Category
JOIN dbo.WorkItemTypeCategoryMembers Member
    ON Member.PartitionId = Category.PartitionId 
    AND Member.WorkItemTypeCategoryID = Category.WorkItemTypeCategoryID
    AND Member.fDeleted = 0
JOIN dbo.WorkItemTypes WType
    ON WType.PartitionId = Member.PartitionId
    AND WType.WorkItemTypeID = Member.WorkItemTypeID
    AND WType.fDeleted = 0
JOIN dbo.Constants WTypeName
    ON WTypeName.PartitionId = WType.PartitionId
    AND WTypeName.ConstID = WType.NameConstantID
WHERE Category.PartitionId = 1
    AND Category.fDeleted = 0
    AND Category.ReferenceName = 'Microsoft.CodeReviewRequestCategory'
;

CREATE TABLE #temp1
(
    ProjectId INT NOT NULL,
    WorkItemType NVARCHAR(256) COLLATE DATABASE_DEFAULT NOT NULL,

    UNIQUE CLUSTERED (ProjectId, WorkItemType)
)

INSERT #temp1
SELECT Category.ProjectId, WTypeName.String 
FROM dbo.WorkItemTypeCategories Category
JOIN dbo.WorkItemTypeCategoryMembers Member
    ON Member.PartitionId = Category.PartitionId 
    AND Member.WorkItemTypeCategoryID = Category.WorkItemTypeCategoryID
    AND Member.fDeleted = 0
JOIN dbo.WorkItemTypes WType
    ON WType.PartitionId = Member.PartitionId
    AND WType.WorkItemTypeID = Member.WorkItemTypeID
    AND WType.fDeleted = 0
JOIN dbo.Constants WTypeName
    ON WTypeName.PartitionId = WType.PartitionId
    AND WTypeName.ConstID = WType.NameConstantID
WHERE Category.PartitionId = 1
    AND Category.fDeleted = 0
    AND Category.ReferenceName = 'Microsoft.CodeReviewResponseCategory'
;

--PEGANDO WIS REPROVADOS
SELECT a.WI,a.ChangeSet,a.CRRequest,a.CRResponse,a.[System.ChangedDate],a.Responsavel 
INTO #CRPend
FROM 
(
	SELECT TOP 2147483647 
	wics.WorkItemId AS WI
	,crrl.ChangesetId AS ChangeSet
	,lhs.Id AS CRRequest
	, links.TargetId AS CRResponse
	,DadosResponse.[System.ChangedDate]
	,ISNULL([lhs].[System.AssignedTo],lhs.[System.CreatedBy]) AS Responsavel
	,ROW_NUMBER() OVER(PARTITION BY wics.WorkItemId ORDER BY links.TargetId DESC) AS rn
	,DadosWI.[System.State] AS StatusWI
	FROM dbo.vw_denorm_WorkItemCoreLatest lhs
	LEFT JOIN dbo.ext_vwCodeReviewRequestLatest crrl ON lhs.Id=crrl.WorkItemId
	LEFT JOIN ext_vwWorkItemChangesetLinks wics ON wics.ChangesetId = crrl.ChangesetId
	JOIN 
	(
		SELECT links.SourceID AS SourceId, links.TargetID AS TargetId, links.[System.Links.LinkType] as LinkTypeId, links.Lock AS IsLocked
		FROM dbo.ForwardLinks links
		WHERE links.PartitionId = 1 AND (links.[System.Links.LinkType] = 2)
	) links
		ON links.SourceId = lhs.Id
	OUTER APPLY (SELECT [System.ChangedDate] FROM vw_denorm_WorkItemCoreLatest WHERE id=links.TargetId) DadosResponse
	OUTER APPLY (SELECT [System.State] FROM vw_denorm_WorkItemCoreLatest WHERE id=wics.WorkItemId) DadosWI
	JOIN 
	(
		SELECT rhs.Id AS Id, CONVERT(INT, SUBSTRING(rhs.AreaPath, DATALENGTH(rhs.AreaPath) - 3, 4)) AS LatestAreaId, rhs.[System.CreatedDate] AS F32, rhs.[System.Id] AS F_3
		FROM dbo.vw_denorm_WorkItemCoreLatest rhs
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10018
			ON rhs.PartitionId = rhsF10018.PartitionId AND rhs.Id = rhsF10018.Id AND rhsF10018.FieldId = 10018
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10019
			ON rhs.PartitionId = rhsF10019.PartitionId AND rhs.Id = rhsF10019.Id AND rhsF10019.FieldId = 10019
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10020
			ON rhs.PartitionId = rhsF10020.PartitionId AND rhs.Id = rhsF10020.Id AND rhsF10020.FieldId = 10020
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10023
			ON rhs.PartitionId = rhsF10023.PartitionId AND rhs.Id = rhsF10023.Id AND rhsF10023.FieldId = 10023


		WHERE rhs.IsDeleted = 0 AND rhs.PartitionId = 1 AND (( EXISTS(
			SELECT * 
			FROM #temp1 
			WHERE ProjectId = CONVERT(INT, SUBSTRING(rhs.AreaPath, 1, 4))
				AND WorkItemType = rhs.WorkItemType
		)) AND (rhsF10018.IntValue NOT IN (4, 5) OR rhsF10018.IntValue IS NULL) AND (rhsF10019.StringValue = N'Needs Work') AND (rhsF10020.IntValue = 2) AND (rhsF10023.StringValue = N'Rafael das Gracas Bahia <CORPNOVA\rafael.bahia>'))
	) rhs
		ON rhs.Id = links.TargetId
	WHERE lhs.IsDeleted = 0 AND lhs.PartitionId = 1 AND ((lhs.AreaPath  BETWEEN 0x00000003 AND 0x00000003FFFFFFFF) AND (lhs.[System.AssignedTo] NOT IN (N'Rafael das Gracas Bahia <CORPNOVA\rafael.bahia>', N'Rafael das Gracas Bahia') OR lhs.[System.AssignedTo] IS NULL) AND ( EXISTS(
    
		SELECT * 
		FROM #temp0 
		WHERE ProjectId = CONVERT(INT, SUBSTRING(lhs.AreaPath, 1, 4))
			AND WorkItemType = lhs.WorkItemType
	)))
	--ORDER BY lhs.[System.CreatedDate] DESC, lhs.[System.Id], rhs.F32 DESC, rhs.F_3
	--ORDER BY wics.WorkItemId
) AS a
WHERE rn=1
AND StatusWI!='Removed'
ORDER BY a.WI;


--PEGANDO WIS APROVADOS
SELECT a.WI,a.ChangeSet,a.CRRequest,a.CRResponse,a.[System.ChangedDate],a.Responsavel 
INTO #CRApp
FROM 
(
	SELECT TOP 2147483647 
	wics.WorkItemId AS WI
	,crrl.ChangesetId AS ChangeSet
	,lhs.Id AS CRRequest
	, links.TargetId AS CRResponse
	,DadosResponse.[System.ChangedDate]
	,ISNULL([lhs].[System.AssignedTo],lhs.[System.CreatedBy]) AS Responsavel
	,ROW_NUMBER() OVER(PARTITION BY wics.WorkItemId ORDER BY links.TargetId DESC) AS rn
	,DadosWI.[System.State] AS StatusWI
	FROM dbo.vw_denorm_WorkItemCoreLatest lhs
	LEFT JOIN dbo.ext_vwCodeReviewRequestLatest crrl ON lhs.Id=crrl.WorkItemId
	LEFT JOIN ext_vwWorkItemChangesetLinks wics ON wics.ChangesetId = crrl.ChangesetId
	JOIN 
	(
		SELECT links.SourceID AS SourceId, links.TargetID AS TargetId, links.[System.Links.LinkType] as LinkTypeId, links.Lock AS IsLocked
		FROM dbo.ForwardLinks links
		WHERE links.PartitionId = 1 AND (links.[System.Links.LinkType] = 2)
	) links
		ON links.SourceId = lhs.Id
	OUTER APPLY (SELECT [System.ChangedDate] FROM vw_denorm_WorkItemCoreLatest WHERE id=links.TargetId) DadosResponse
	OUTER APPLY (SELECT [System.State] FROM vw_denorm_WorkItemCoreLatest WHERE id=wics.WorkItemId) DadosWI
	JOIN
	(
		SELECT rhs.Id AS Id, CONVERT(INT, SUBSTRING(rhs.AreaPath, DATALENGTH(rhs.AreaPath) - 3, 4)) AS LatestAreaId, rhs.[System.CreatedDate] AS F32, rhs.[System.Id] AS F_3
		FROM dbo.vw_denorm_WorkItemCoreLatest rhs
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10018
			ON rhs.PartitionId = rhsF10018.PartitionId AND rhs.Id = rhsF10018.Id AND rhsF10018.FieldId = 10018
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10019
			ON rhs.PartitionId = rhsF10019.PartitionId AND rhs.Id = rhsF10019.Id AND rhsF10019.FieldId = 10019
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10020
			ON rhs.PartitionId = rhsF10020.PartitionId AND rhs.Id = rhsF10020.Id AND rhsF10020.FieldId = 10020
		LEFT JOIN dbo.tbl_WorkItemCustomLatest rhsF10023
			ON rhs.PartitionId = rhsF10023.PartitionId AND rhs.Id = rhsF10023.Id AND rhsF10023.FieldId = 10023


		WHERE rhs.IsDeleted = 0 AND rhs.PartitionId = 1 AND (( EXISTS(
			SELECT * 
			FROM #temp1 
			WHERE ProjectId = CONVERT(INT, SUBSTRING(rhs.AreaPath, 1, 4))
				AND WorkItemType = rhs.WorkItemType
		)) AND (rhsF10018.IntValue NOT IN (4, 5) OR rhsF10018.IntValue IS NULL) AND (rhsF10019.StringValue in (N'Looks Good','With Comments')) AND (rhsF10020.IntValue = 2) AND (rhsF10023.StringValue = N'Rafael das Gracas Bahia <CORPNOVA\rafael.bahia>'))
	) rhs
		ON rhs.Id = links.TargetId
	WHERE lhs.IsDeleted = 0 AND lhs.PartitionId = 1 AND ((lhs.AreaPath  BETWEEN 0x00000003 AND 0x00000003FFFFFFFF) AND (lhs.[System.AssignedTo] NOT IN (N'Rafael das Gracas Bahia <CORPNOVA\rafael.bahia>', N'Rafael das Gracas Bahia') OR lhs.[System.AssignedTo] IS NULL) AND ( EXISTS(
    
		SELECT * 
		FROM #temp0 
		WHERE ProjectId = CONVERT(INT, SUBSTRING(lhs.AreaPath, 1, 4))
			AND WorkItemType = lhs.WorkItemType
	)))
) AS a
WHERE rn=1
AND StatusWI!='Removed'
ORDER BY a.WI

--WIs AIND NÃO CORRIGIDAS
SELECT  WI,ChangeSet,CRRequest, CRResponse, Responsavel
FROM #CRPend p
WHERE NOT EXISTS
(
	SELECT * FROM #CRApp a WHERE a.wi=p.wi AND a.[System.ChangedDate]>p.[System.ChangedDate]
)
AND WI not in (57819,57818,17954,65400,40981,45898,68134,69930,70314,70740,70565,70721,70890,71779,37814,39949
,24098
,13381
,34338
,31290
)
order by Responsavel

/*
--PEGAR WIs QUE FORAM APROVADAS DEPOIS DE SEREM REPROVADAS PELO MENOS UMA VEZ
SELECT  *
FROM #CRPend p
WHERE EXISTS
(
	SELECT * FROM #CRApp a WHERE a.wi=p.wi AND a.[System.ChangedDate]>p.[System.ChangedDate]
)
AND WI not in (57819,57818,17954,65400,40981,45898,68134,69930,70314,70740,70721,70890,71779)
*/
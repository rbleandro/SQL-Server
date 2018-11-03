SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#InGroupSequenceTable1') IS NOT NULL 
	DROP	 TABLE #InGroupSequenceTable1
IF OBJECT_ID('tempdb..#InGroupSequenceTable2') IS NOT NULL 
	DROP	 TABLE #InGroupSequenceTable2
IF OBJECT_ID('tempdb..#CRPend') IS NOT NULL 
	DROP TABLE #CRPend
IF OBJECT_ID('tempdb..#CRApp') IS NOT NULL 
	DROP	TABLE #CRApp
IF OBJECT_ID('tempdb..#mapwics') IS NOT NULL 
	DROP	TABLE #mapwics
GO

DECLARE @PersonId AS INT
DECLARE @rebuildOK AS INT
DECLARE @PersonName AS NVARCHAR(256)
DECLARE @userSID AS NVARCHAR(256)
SET @userSID=N'S-1-5-21-3538927320-3857800942-4086916016-2999'


SELECT DISTINCT
SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000) AS Changeset
,I.ID,a.[system.id],a.[System.WorkItemType]
INTO #mapwics
FROM dbo.WorkItemFiles I JOIN dbo.FieldUsages U ON I.FldID = U.FldID
JOIN WorkItemsLatestUsed wi ON wi.[Microsoft.VSTS.CodeReview.Context]=SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000)
CROSS APPLY 
(
	SELECT DISTINCT ll2.sourceid AS [system.id]
	--,wi2.[System.WorkItemType]
	--,ll2.targetid AS [system.id]
	,wi3.[System.WorkItemType]
	FROM WorkItemsLatestUsed wi2, LinksLatest ll1
	,WorkItemsLatestUsed wi3
	,LinksLatest ll2
	--,WorkItemsLatestUsed wi4
	WHERE wi2.[System.WorkItemType] IN ('Germud')
	AND ll1.sourceid=wi2.[system.id]
	AND wi3.[system.id]=ll1.targetid
	AND wi2.[system.id]=65019 --NUMERO DO WI GERMUD
	AND ll2.sourceid=ll1.targetid
	--AND wi4.[system.id]=ll2.targetid
	AND ll2.targetid=I.id
) AS a
WHERE
I.PartitionId = 1
AND U.ObjectID = -100
AND U.fDeleted = 0
AND wi.[System.WorkItemType]='Code Review Request'
--AND I.id IN 
--(
--	select ll1.targetid--,wi2.*
--	FROM WorkItemsLatestUsed wi, LinksLatest ll1--,WorkItemsLatestUsed wi2
--	WHERE wi.[System.WorkItemType] IN ('Product Backlog Item','BUG')
--	AND wi.[system.id] IN (55097, 58452, 59206, 59898, 61049, 61404, 61473, 61552, 62573, 62578, 62580, 62710, 62712, 62740, 62798, 63004, 63793, 63935, 64160, 64434, 64569, 56553) 
--	AND ll1.sourceid=wi.[system.id]
--)


CREATE TABLE #InGroupSequenceTable1 (ProjectId INT NOT NULL, WitName NVARCHAR(256) COLLATE DATABASE_DEFAULT NOT NULL) IF SERVERPROPERTY('Edition') = 'Azure' CREATE CLUSTERED INDEX IX_InGroupTable1 ON #InGroupSequenceTable1 ([ProjectId])
INSERT #InGroupSequenceTable1
SELECT WITC.ProjectID, C.String
FROM dbo.WorkItemTypeCategories WITC
JOIN dbo.WorkItemTypeCategoryMembers WITCM
ON WITCM.[PartitionId] = 1 AND
    WITC.[WorkItemTypeCategoryID] = WITCM.[WorkItemTypeCategoryID]
    AND WITCM.[fDeleted] = 0
JOIN dbo.WorkItemTypes WIT
ON WIT.[PartitionId] = 1 AND
    WITCM.[WorkItemTypeID] = WIT.[WorkItemTypeID]
    AND WIT.[fDeleted] = 0
JOIN dbo.Constants C
ON C.[PartitionId] = 1 AND
    WIT.[NameConstantID] = C.[ConstID]
WHERE WITC.[PartitionId] = 1 AND
    WITC.[fDeleted] = 0
    AND (WITC.[ReferenceName] = N'Microsoft.CodeReviewRequestCategory' OR WITC.[ReferenceName] = N'Microsoft.TaskCategory')


CREATE TABLE #InGroupSequenceTable2 (ProjectId INT NOT NULL, WitName NVARCHAR(256) COLLATE DATABASE_DEFAULT NOT NULL) IF SERVERPROPERTY('Edition') = 'Azure' CREATE CLUSTERED INDEX IX_InGroupTable2 ON #InGroupSequenceTable2 ([ProjectId])
INSERT #InGroupSequenceTable2
SELECT WITC.ProjectID, C.String
FROM dbo.WorkItemTypeCategories WITC
JOIN dbo.WorkItemTypeCategoryMembers WITCM
ON WITCM.[PartitionId] = 1 AND
    WITC.[WorkItemTypeCategoryID] = WITCM.[WorkItemTypeCategoryID]
    AND WITCM.[fDeleted] = 0
JOIN dbo.WorkItemTypes WIT
ON WIT.[PartitionId] = 1 AND
    WITCM.[WorkItemTypeID] = WIT.[WorkItemTypeID]
    AND WIT.[fDeleted] = 0
JOIN dbo.Constants C
ON C.[PartitionId] = 1 AND
    WIT.[NameConstantID] = C.[ConstID]
WHERE WITC.[PartitionId] = 1 AND
    WITC.[fDeleted] = 0
    AND (WITC.[ReferenceName] = N'Microsoft.CodeReviewResponseCategory' OR WITC.[ReferenceName] = N'Microsoft.TaskCategory')


SELECT  links.[SourceID] CRRequest, links.[TargetID] CRResponse,links.[System.Links.LinkType]
,wi.[Microsoft.VSTS.CodeReview.Context] AS ChangeSet
,WID.Id
,wi2.[Microsoft.VSTS.CodeReview.ClosedStatus] StatusFinal
,wi2.[System.ChangedDate]
,wi2.[Microsoft.VSTS.Common.ReviewedBy]
,WID.[system.id]
,WID.[System.WorkItemType]
INTO #CRPend
FROM [dbo].[WorkItemsQueryLatestUsedConstIDs](1) AS lhs
JOIN dbo.ForwardLinks AS links ON links.[SourceID] = lhs.[System.ID] AND links.[PartitionId] = 1 AND (((links.[System.Links.LinkType] IN (1,2))))
JOIN [dbo].[WorkItemsQueryLatestUsedConstIDs](1) AS rhs ON links.[TargetID] = rhs.[System.ID]
JOIN WorkItemsLatestUsed wi ON wi.[System.Id]=links.SourceID
JOIN WorkItemsLatestUsed wi2 ON wi2.[System.Id]=links.TargetID

AND
(
	(
		(
			rhs.[System.WorkItemType] IS NOT NULL AND  EXISTS
			(
				SELECT *
				FROM #InGroupSequenceTable2 WITC_P5
				WHERE rhs.[System.WorkItemType] = WITC_P5.[WitName]
				AND rhs.[System.AreaID] IN (SELECT TreeID FROM dbo.SubTreeFromID(1, WITC_P5.[ProjectId]))
			)
		)
	)
	AND
	(
		(rhs.[Microsoft.VSTS.Common.ReviewedBy] IN (N'Rafael das Gracas Bahia'))
	)
	AND
	(
		(rhs.[Microsoft.VSTS.Common.StateCode]=2)
	)
	AND
	(
		(rhs.[Microsoft.VSTS.CodeReview.ClosedStatusCode]=3 OR rhs.[Microsoft.VSTS.CodeReview.ClosedStatusCode] IS NULL)
	)
)
CROSS APPLY (
				SELECT wi3.Id,wi3.[system.id],[System.WorkItemType]
				FROM #mapwics wi3
				WHERE wi3.Changeset= wi.[Microsoft.VSTS.CodeReview.Context]
			)  AS WID
WHERE 1=1
AND
(
	((lhs.[System.AreaId] IN (SELECT * FROM dbo.SubTreeFromID(1,3))))
	AND
	(
		(
			lhs.[System.WorkItemType] IS NOT NULL AND  EXISTS
			(
				SELECT *
				FROM #InGroupSequenceTable1 WITC_P2
				WHERE lhs.[System.WorkItemType] = WITC_P2.[WitName]
					AND lhs.[System.AreaID] IN (SELECT TreeID FROM dbo.SubTreeFromID(1, WITC_P2.[ProjectId]))
			)
		)
	)
);

SELECT  links.[SourceID] CRRequest, links.[TargetID] CRResponse,links.[System.Links.LinkType]
,wi.[Microsoft.VSTS.CodeReview.Context] AS ChangeSet
,WID.Id
,wi2.[Microsoft.VSTS.CodeReview.ClosedStatus] StatusFinal
,wi2.[System.ChangedDate]
,wi2.[Microsoft.VSTS.Common.ReviewedBy]
,WID.[system.id]
,WID.[System.WorkItemType]
INTO #CRApp
FROM [dbo].[WorkItemsQueryLatestUsedConstIDs](1) AS lhs
JOIN dbo.ForwardLinks AS links ON links.[SourceID] = lhs.[System.ID] AND links.[PartitionId] = 1 AND (((links.[System.Links.LinkType] IN (1,2))))
JOIN [dbo].[WorkItemsQueryLatestUsedConstIDs](1) AS rhs ON links.[TargetID] = rhs.[System.ID]
JOIN WorkItemsLatestUsed wi ON wi.[System.Id]=links.SourceID
JOIN WorkItemsLatestUsed wi2 ON wi2.[System.Id]=links.TargetID
AND
(
	(
		(
			rhs.[System.WorkItemType] IS NOT NULL AND  EXISTS
			(
				SELECT *
				FROM #InGroupSequenceTable2 WITC_P5
				WHERE rhs.[System.WorkItemType] = WITC_P5.[WitName]
				AND rhs.[System.AreaID] IN (SELECT TreeID FROM dbo.SubTreeFromID(1, WITC_P5.[ProjectId]))
			)
		)
	)
	AND
	(
		(rhs.[Microsoft.VSTS.Common.ReviewedBy] IN (N'Rafael das Gracas Bahia'/*,N'Fernando Louzada Paixao'*/))
	)
	AND
	(
		(rhs.[Microsoft.VSTS.Common.StateCode]=2)
	)
	AND
	(
		(rhs.[Microsoft.VSTS.CodeReview.ClosedStatusCode] IN (1,2) )
	)
)
CROSS APPLY (
				SELECT wi3.Id,[system.id],[System.WorkItemType]
				FROM #mapwics wi3
				WHERE wi3.Changeset= wi.[Microsoft.VSTS.CodeReview.Context]
			)  AS WID
WHERE 1=1
AND
(
	((lhs.[System.AreaId] IN (SELECT * FROM dbo.SubTreeFromID(1,3))))
	AND
	(
		(
			lhs.[System.WorkItemType] IS NOT NULL AND  EXISTS
			(
				SELECT *
				FROM #InGroupSequenceTable1 WITC_P2
				WHERE lhs.[System.WorkItemType] = WITC_P2.[WitName]
					AND lhs.[System.AreaID] IN (SELECT TreeID FROM dbo.SubTreeFromID(1, WITC_P2.[ProjectId]))
			)
		)
	)
);


IF OBJECT_ID('tempdb..#InGroupSequenceTable1') IS NOT NULL DROP	 TABLE #InGroupSequenceTable1;
IF OBJECT_ID('tempdb..#InGroupSequenceTable2') IS NOT NULL DROP	 TABLE #InGroupSequenceTable2;

WITH cte
AS
(
	SELECT  p.Id,p.ChangeSet
	,p.[Microsoft.VSTS.Common.ReviewedBy] AS Revisor
	,p.StatusFinal
	,[system.id],[System.WorkItemType]
	,ROW_NUMBER() OVER(PARTITION BY p.ID ORDER BY p.ChangeSet DESC) AS rn
	FROM #CRPend p
	WHERE NOT EXISTS
	(
		SELECT * FROM #CRApp a WHERE a.id=p.id AND a.[System.ChangedDate]>p.[System.ChangedDate]
	)
)
SELECT
cte.Id AS WorkItem
,ChangeSet
--,cte.[System.ChangedDate] 
,cte.Revisor 
,a.Dev
,a.[system.state] StatusWI
,b.sourceid AS Germud
,[system.id] AS WiPai
,[System.WorkItemType] AS TipoWIPai
FROM cte
OUTER APPLY (SELECT [system.state],COALESCE([System.AssignedTo],[system.createdby]) AS Dev FROM WorkItemsLatestUsed WHERE [System.WorkItemType]='task' AND cte.id=[system.id]) AS a
OUTER APPLY
(
	SELECT ll2.sourceid
	FROM LinksLatest ll1,LinksLatest ll2
	WHERE 1=1
	AND ll2.TARGETid=ll1.sourceid
	AND ll1.targetid=cte.id
	AND ll2.linktype=6
) AS b
WHERE 1=1
AND a.[system.state]!='Removed'
AND rn=1
ORDER BY cte.ID DESC;

SELECT * FROM #CRApp a

/*
	select ll1.targetid,wi2.*
	FROM WorkItemsLatestUsed wi, LinksLatest ll1,WorkItemsLatestUsed wi2
	WHERE wi.[System.WorkItemType] IN ('Product Backlog Item','BUG')
	AND wi.[system.id] IN (55097, 58452, 59206, 59898, 61049, 61404, 61473, 61552, 62573, 62578, 62580, 62710, 62712, 62740, 62798, 63004, 63793, 63935, 64160, 64434, 64569, 56553) 
	AND ll1.sourceid=wi.[system.id]
	--AND linktype=2
	AND wi2.[system.id]=ll1.targetid

*/
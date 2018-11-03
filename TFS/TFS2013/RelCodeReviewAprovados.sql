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

DECLARE @PersonId AS INT
DECLARE @rebuildOK AS INT
DECLARE @PersonName AS NVARCHAR(256)
DECLARE @userSID AS NVARCHAR(256)
SET @userSID=N'S-1-5-21-3538927320-3857800942-4086916016-2999'

SELECT
SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000) AS Changeset
,I.ID
--,wi.[System.AssignedTo]
INTO #mapwics
FROM dbo.WorkItemFiles I JOIN dbo.FieldUsages U ON I.FldID = U.FldID
AND U.ObjectID = -100
AND U.fDeleted = 0
JOIN WorkItemsLatestUsed wi ON wi.[Microsoft.VSTS.CodeReview.Context]=SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000)
AND wi.[System.WorkItemType]='Code Review Request'
WHERE
I.PartitionId = 1

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
    AND (WITC.[ReferenceName] = N'Microsoft.CodeReviewResponseCategory' OR WITC.[ReferenceName] = N'Microsoft.TaskCategory');

SELECT  links.[SourceID] CRRequest, links.[TargetID] CRResponse,links.[System.Links.LinkType]
,wi.[Microsoft.VSTS.CodeReview.Context] AS ChangeSet
,WID.Id
--,WID.[System.AssignedTo]
,wi2.[Microsoft.VSTS.CodeReview.ClosedStatus] StatusFinal
,wi2.[System.ChangedDate]
,wi2.[Microsoft.VSTS.Common.ReviewedBy]
--,wi2.[System.WorkItemType] tipo1
--,wi.[System.WorkItemType] tipo2
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
				SELECT wi3.Id
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

SELECT * FROM #CRApp a 


SET nocount on
declare @PersonId as int
declare @rebuildOK as int
declare @PersonName as nvarchar(256)
declare @userSID as nvarchar(256)
set @userSID=N'S-1-5-21-3538927320-3857800942-4086916016-2999'
--exec @rebuildOK=dbo.RebuildCallersViews @partitionId,@PersonId output,@P1
--if @rebuildOK<>0 return

--declare @P3_1 int
--select @P3_1 = ConstID from dbo.[Constants] where PartitionId = 1 and DisplayPart = N'Rodrigo da Silva Brito'

--if (@@rowcount > 1)
--begin
--    EXEC [dbo].[RaiseWITError] 600174, 16, 1
--    return
--end
--set @P3_1 = isnull(@P3_1,-2147483648);

IF OBJECT_ID('tempdb..#InGroupSequenceTable1') IS NOT NULL DROP	 TABLE #InGroupSequenceTable1;
IF OBJECT_ID('tempdb..#InGroupSequenceTable2') IS NOT NULL DROP	 TABLE #InGroupSequenceTable2;
IF OBJECT_ID('tempdb..#CRPend') IS NOT NULL DROP TABLE #CRPend;
IF OBJECT_ID('tempdb..#CRApp') IS NOT NULL DROP	TABLE #CRApp;
IF OBJECT_ID('tempdb..#mapwics') IS NOT NULL DROP	TABLE #mapwics;

SELECT
--I.FilePath
SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000) AS Changeset
,i.ID
--,U.ObjectID,I.FldID,U.DirectObjectID
into #mapwics
FROM dbo.WorkItemFiles I JOIN dbo.FieldUsages U ON I.FldID = U.FldID
AND U.ObjectID = -100
AND U.fDeleted = 0
JOIN WorkItemsLatestUsed wi ON wi.[Microsoft.VSTS.CodeReview.Context]=SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000)
AND wi.[System.WorkItemType]='Code Review Request'
WHERE
I.PartitionId = 1

CREATE TABLE #InGroupSequenceTable1 (ProjectId INT NOT NULL, WitName NVARCHAR(256) COLLATE DATABASE_DEFAULT NOT NULL) IF SERVERPROPERTY('Edition') = 'Azure' CREATE CLUSTERED INDEX IX_InGroupTable1 ON #InGroupSequenceTable1 ([ProjectId])
INSERT #InGroupSequenceTable1
select WITC.ProjectID, C.String
--,WITC.ReferenceName
from dbo.WorkItemTypeCategories WITC
join dbo.WorkItemTypeCategoryMembers WITCM
on WITCM.[PartitionId] = 1 and
    WITC.[WorkItemTypeCategoryID] = WITCM.[WorkItemTypeCategoryID]
    and WITCM.[fDeleted] = 0
join dbo.WorkItemTypes WIT
on WIT.[PartitionId] = 1 and
    WITCM.[WorkItemTypeID] = WIT.[WorkItemTypeID]
    and WIT.[fDeleted] = 0
join dbo.Constants C
on C.[PartitionId] = 1 and
    WIT.[NameConstantID] = C.[ConstID]
where WITC.[PartitionId] = 1 and
    WITC.[fDeleted] = 0
    and (WITC.[ReferenceName] = N'Microsoft.CodeReviewRequestCategory' OR WITC.[ReferenceName] = N'Microsoft.TaskCategory')
	--and WITC.[ReferenceName] = N'Microsoft.CodeReviewRequestCategory'


CREATE TABLE #InGroupSequenceTable2 (ProjectId INT NOT NULL, WitName NVARCHAR(256) COLLATE DATABASE_DEFAULT NOT NULL) IF SERVERPROPERTY('Edition') = 'Azure' CREATE CLUSTERED INDEX IX_InGroupTable2 ON #InGroupSequenceTable2 ([ProjectId])
INSERT #InGroupSequenceTable2
select WITC.ProjectID, C.String
from dbo.WorkItemTypeCategories WITC
join dbo.WorkItemTypeCategoryMembers WITCM
on WITCM.[PartitionId] = 1 and
    WITC.[WorkItemTypeCategoryID] = WITCM.[WorkItemTypeCategoryID]
    and WITCM.[fDeleted] = 0
join dbo.WorkItemTypes WIT
on WIT.[PartitionId] = 1 and
    WITCM.[WorkItemTypeID] = WIT.[WorkItemTypeID]
    and WIT.[fDeleted] = 0
join dbo.Constants C
on C.[PartitionId] = 1 and
    WIT.[NameConstantID] = C.[ConstID]
where WITC.[PartitionId] = 1 and
    WITC.[fDeleted] = 0
    and (WITC.[ReferenceName] = N'Microsoft.CodeReviewResponseCategory' OR WITC.[ReferenceName] = N'Microsoft.TaskCategory')
	--and WITC.[ReferenceName] = N'Microsoft.CodeReviewResponseCategory'

;WITH cte
AS
(
SELECT  links.[SourceID] CRRequest, links.[TargetID] CRResponse,links.[System.Links.LinkType]
,wi.[Microsoft.VSTS.CodeReview.Context] AS ChangeSet
,WID.Id
,wi.[System.AssignedTo]
,wi.[System.Title]
,wi2.[Microsoft.VSTS.CodeReview.ClosedStatus] StatusFinal
,wi2.[System.ChangedDate]
,wi2.[Microsoft.VSTS.Common.ReviewedBy]
,ROW_NUMBER() OVER (PARTITION BY wi.[Microsoft.VSTS.CodeReview.Context],WID.Id ORDER BY wi.[System.ChangedDate] desc) AS rn
,COUNT(links.[SourceID]) OVER (PARTITION BY wi.[Microsoft.VSTS.CodeReview.Context],WID.Id) AS QtdDup
--INTO #CRPend
from [dbo].[WorkItemsQueryLatestUsedConstIDs](1) as lhs
join dbo.ForwardLinks as links on links.[SourceID] = lhs.[System.ID] and links.[PartitionId] = 1 and (((links.[System.Links.LinkType] IN (1,2))))
join [dbo].[WorkItemsQueryLatestUsedConstIDs](1) as rhs on links.[TargetID] = rhs.[System.ID]
JOIN WorkItemsLatestUsed wi ON wi.[System.Id]=links.SourceID
JOIN WorkItemsLatestUsed wi2 ON wi2.[System.Id]=links.TargetID

AND
(
	(
		(
			rhs.[System.WorkItemType] is not null and  exists
			(
				select *
				from #InGroupSequenceTable2 WITC_P5
				WHERE rhs.[System.WorkItemType] = WITC_P5.[WitName]
				and rhs.[System.AreaID] in (select TreeID from dbo.SubTreeFromID(1, WITC_P5.[ProjectID]))
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
)
CROSS APPLY (
				SELECT /*TOP 1*/ wi3.Id
				FROM #mapwics wi3
				WHERE wi3.changeset= wi.[Microsoft.VSTS.CodeReview.Context]
			)  AS WID
WHERE 1=1
and
(
	((lhs.[System.AreaId] in (select * from dbo.SubTreeFromID(1,3))))
	AND
	(
		(
			lhs.[System.WorkItemType] is not null and  exists
			(
				select *
				from #InGroupSequenceTable1 WITC_P2
				where lhs.[System.WorkItemType] = WITC_P2.[WitName]
					and lhs.[System.AreaID] in (select TreeID from dbo.SubTreeFromID(1, WITC_P2.[ProjectID]))
			)
		)
	)
	--AND ((lhs.[System.AssignedTo]=@P3_1))
	--AND [lhs].[System.ChangedDate]>'2015-10-16'
	--AND wi.[Microsoft.VSTS.CodeReview.Context]='100659'
	--AND [lhs].[System.AssignedTo]='Silvia Mitsuko Terazaki'
)
)
SELECT * FROM cte 
WHERE 1=1
AND QtdDup>1
AND rn=1
ORDER BY CAST(cte.ChangeSet AS BIGINT) DESC	

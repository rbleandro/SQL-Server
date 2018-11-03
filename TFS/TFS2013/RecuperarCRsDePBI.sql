SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
/*
select top 1000 * FROM tbl_discussion 
WHERE 1=1
--and workitemid=65801
ORDER BY WorkItemId desc

select distinct c.content,d.workitemid,cast(replace(d.versionid,'C','') as int) as ChangeSet
from tbl_comment c inner join tbl_discussion d on c.discussionid=c.discussionid
where content like 'Crítica: Atenção! Realizar testes no ambiente de staging para ver se serão necessárias ações adicionais relacionadas a desempenho.'
and versionid='c189659'

select top 10 wi.[system.id] , ll1.sourceid, ll1.targetid, wi2.[System.WorkItemType], wi.[System.WorkItemType]
from WorkItemsLatestUsed wi , LinksLatest ll1 , WorkItemsLatestUsed wi2
WHERE 1=1
--and wi.[System.WorkItemType] IN ('Code Review Re')
and wi.[system.id]=189659
AND ll1.sourceid=wi.[system.id]
AND ll1.targetid=wi2.[system.id]

select top 10 * from LinksLatest where sourceid=65593 --TASK
select top 10 * from LinksLatest where sourceid=65594 --PBI
select top 10 * from LinksLatest where sourceid=65579 --BUG
select top 10 * from LinksLatest where sourceid=65956 --Test Case

select top 10 * from LinksLatest where sourceid=189659
select top 10 * from LinksLatest where sourceid=65681
select top 10 * from LinksLatest where targetid=65681

SELECT ll1.targetid,wi2.[System.WorkItemType]
FROM WorkItemsLatestUsed wi, LinksLatest ll1,WorkItemsLatestUsed wi2
WHERE wi.[System.WorkItemType] IN ('Product Backlog Item','BUG')
AND wi.[system.id] IN (63454) 
AND ll1.sourceid=wi.[system.id]
AND ll1.targetid=wi2.[system.id]


*/

SELECT DISTINCT
SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000) AS Changeset
,I.ID as WorkItem
,wi.[system.id] as IdRequestCR
--,a.[system.id]
--,a.[System.WorkItemType]
--INTO #mapwics
FROM dbo.WorkItemFiles I JOIN dbo.FieldUsages U ON I.FldID = U.FldID
JOIN WorkItemsLatestUsed wi ON wi.[Microsoft.VSTS.CodeReview.Context]=SUBSTRING(I.FilePath,CHARINDEX('changeset/',FilePath,1)+10,2000000000)
WHERE
I.PartitionId = 1
AND U.ObjectID = -100
AND U.fDeleted = 0
AND wi.[System.WorkItemType]='Code Review Request'
--select top 10 * FROM tbl_discussion WHERE workitemid=65801
and I.ID in 
(
SELECT ll1.targetid--,wi2.[System.WorkItemType]
FROM WorkItemsLatestUsed wi, LinksLatest ll1,WorkItemsLatestUsed wi2
WHERE wi.[System.WorkItemType] IN ('Product Backlog Item','BUG')
AND wi.[system.id] IN (63454) 
AND ll1.sourceid=wi.[system.id]
AND ll1.targetid=wi2.[system.id]
)

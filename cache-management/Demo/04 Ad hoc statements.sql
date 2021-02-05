-----------------------------------------------------------------
-- Course: SQL Server: Optimizing Ad Hoc Statement Performance
-- Module: Statement Caching
--   Demo: Ad Hoc Statements and the Plan Cache
-----------------------------------------------------------------

-- First, run the Sample Database Setup script for Credit
-- Script: CreditDemoDatabaseSetup.sql

USE [Credit];
GO

----------------------------------
-- Demo: Ad Hoc Statements and the Plan Cache
----------------------------------

-- Some quick setup for later searches
UPDATE [member]	
SET [lastname] = 'Tripp' 
WHERE [member_no] = 1234;
GO

CREATE INDEX [MemberLastName]
ON [dbo].[member] ([lastname]);
GO

-- Quick/general way to see index list
EXEC [sp_helpindex] N'dbo.member';
GO

-- Rewrite to give better index details/internals
-- Get here: http://bit.ly/1b3RcR0 
-- If you want help in setting this up, see
-- Course: SQL Server: Why Physical Database Design Matters
-- Module: Data Types and Index Size 
--   Demo: Setup sp_SQLskills_SQL2012_helpindex 

EXEC [sp_SQLskills_SQL2012_helpindex] N'dbo.member';
GO

-- And, if you want to dive into the size
-- of the plan in the cache:

CREATE PROCEDURE [QuickCheckOnCacheWSizeAndPlan]
(
    @StringToFind   NVARCHAR (4000)
)
AS
SET NOCOUNT ON;

SELECT [st].[text]
	, [qs].[execution_count]
	, [qs].[plan_handle]
	, [qs].[statement_start_offset]
	, [qp].[query_plan],qs.last_execution_time,qs.last_elapsed_time
	,'dbcc freeproccache('+CONVERT(VARCHAR(max),qs.sql_handle,1)+')' AS 'DBCCFreeProcChache'
FROM [sys].[dm_exec_query_stats] AS [qs] 
	CROSS APPLY [sys].[dm_exec_sql_text]
		 ([qs].[sql_handle]) AS [st]
	CROSS APPLY [sys].[dm_exec_query_plan]
		 ([qs].[plan_handle]) AS [qp]
WHERE [st].[text] LIKE @StringToFind 
	AND ([st].[text] NOT LIKE N'%syscacheobjects%' OR [st].[text] NOT LIKE N'%SELECT%cp.objecttype%')
	AND qs.last_elapsed_time > 10000
ORDER BY 1, [qs].[execution_count] DESC;
GO

-- Essentially the same thing, but add the query
-- plan to the output
CREATE PROCEDURE [QuickCheckOnCacheWSizeAndPlan]
(
    @StringToFind   NVARCHAR (4000)
)
AS
SET NOCOUNT ON;

SELECT [st].[text]
	, [qs].[execution_count]
	, [qs].[plan_handle]
	, [qs].[statement_start_offset]
	, [qp].[query_plan]
FROM [sys].[dm_exec_query_stats] AS [qs] 
	CROSS APPLY [sys].[dm_exec_sql_text]
		 ([qs].[sql_handle]) AS [st]
	CROSS APPLY [sys].[dm_exec_query_plan]
		 ([qs].[plan_handle]) AS [qp]
WHERE [st].[text] LIKE @StringToFind 
	AND ([st].[text] NOT LIKE N'%syscacheobjects%'
		OR [st].[text] NOT LIKE N'%SELECT%cp.objecttype%')
ORDER BY 1, [qs].[execution_count] DESC;
GO

----------------------------------
-- Ad hoc statements in the plan cache
----------------------------------

-- Make it a bit easier (more isolated) 
-- to review what's in cache and to clear
-- any plans that might have ended up there
-- that could influence the results of this
-- scripts:
DBCC FREEPROCCACHE;
GO

-- These are great for review:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Also, turn Actual Graphical Showplan ON
GO

-- Let's run a few statements but with different 
-- values (on an "unsafe" query)

SELECT [m_unsafe].* 
FROM [dbo].[member] AS [m_unsafe]
WHERE [m_unsafe].[lastname] = 'Tripp';
GO -- 1 rows

SELECT [m_unsafe].* 
FROM [dbo].[member] AS [m_unsafe]
WHERE [m_unsafe].[lastname] = 'Tripps';
GO -- 0 rows

SELECT [m_unsafe].* 
FROM [dbo].[member] AS [m_unsafe]
WHERE [m_unsafe].[lastname] = 'Tripper';
GO -- 0 rows

SELECT [m_unsafe].* 
FROM [dbo].[member] AS [m_unsafe]
WHERE [m_unsafe].[lastname] = 'Tripped';
GO -- 0 rows

SELECT [m_unsafe].* 
FROM [dbo].[member] AS [m_unsafe]
WHERE [m_unsafe].[lastname] = 'Falls';
GO -- 0 rows

EXEC [QuickCheckOnCacheWSize] N'%m_unsafe%';
EXEC [QuickCheckOnCacheWSizeAndPlan] N'%m_unsafe%';
GO

-- Let's execute with other values (and therefore 
-- [potentially] different plans)
SELECT [m_unsafe].* 
FROM [dbo].[member] AS [m_unsafe]
WHERE [m_unsafe].[lastname] = 'Anderson';
GO -- 385 rows

SELECT [m_unsafe].* 
FROM [dbo].[member] AS [m_unsafe]
WHERE [m_unsafe].[lastname] = 'Barr';
GO -- 385 rows

EXEC [QuickCheckOnCacheWSize] N'%m_unsafe%';
EXEC [QuickCheckOnCacheWSizeAndPlan] N'%m_unsafe%';
GO

-- All of these statements are in the plan cache
-- You'd expect this from an UNSAFE statement
-- What about a safe statement?

SELECT [m_safe].* 
FROM [dbo].[member] AS [m_safe]
WHERE [m_safe].[member_no] = 258;
GO

SELECT [m_safe].* 
FROM [dbo].[member] AS [m_safe]
WHERE [m_safe].[member_no] = 34567;
GO

SELECT [m_safe].* 
FROM [dbo].[member] AS [m_safe]
WHERE [m_safe].[member_no] = 33;
GO

EXEC [QuickCheckOnCacheWSize] N'%m_safe%';
EXEC [QuickCheckOnCacheWSizeAndPlan] N'%m_safe%';
GO

SELECT [m_safe].* 
FROM [dbo].[member] AS [m_safe]
WHERE [m_safe].[member_no] = 38;
GO

EXEC [QuickCheckOnCacheWSize] N'%m_safe%';
EXEC [QuickCheckOnCacheWSizeAndPlan] N'%m_safe%';
GO

--**************************************************************************************
-- Name: 	Jordan Sullivan 2013
-- Company: 	Brock Solutions
--**************************************************************************************
-- Description:	This Stored Procedure inserts a bulk file into 
--		the PACKAGE ALERTS table.
--**************************************************************************************
--Create Date:  09/25/2013
--
--	REVISION HISTORY
--	----------------------------------------------------
--	Item	Name		Date		Description
--	----------------------------------------------------
--	1.0		JPMS		Sep 25, 2013 Created Stored Procedure for bulk file insert for 
--									Package Alerts
--
--
--**************************************************************************************
ALTER PROCEDURE dbo.PACKAGE_ALERTS_BCP_INSERT_UPDATE
(
	@sFilePath   VARCHAR(128),
	@sFormatFilePath VARCHAR(128)
)
AS
BEGIN

	DECLARE @sSQL NVARCHAR(4000)

	-- INSERT INTO PACKAGES Table
	SET @sSQL = 'BULK INSERT SmartSort_Canpar_SCS.dbo.PACKAGE_ALERTS '
	SET @sSQL = @sSQL + 'FROM ''' + @sFilePath + ''''
	SET @sSQL = @sSQL + ' WITH ( FIRE_TRIGGERS, FIRSTROW = 2, FORMATFILE = ''' +@sFormatFilePath + ''', BATCHSIZE  = 2048 )'
	-- EXECUTE THE SQL STATEMENT BUILT
	EXEC sp_executesql @sSQL

END


GO


--**************************************************************************************
-- Name: 	Grace Bui 2005
-- Company: 	Brock Solutions
--**************************************************************************************
-- Description:	This Stored Procedure inserts a bulk file into 
--		the PACKAGE_TRANSACTIONS table.
--**************************************************************************************
--Create Date:  02/22/2006
--
--Revision:
--**************************************************************************************
--
--
--**************************************************************************************
ALTER PROCEDURE dbo.PACKAGE_TRANSACTIONS_BCP_INSERT_UPDATE
(
	@sFilePath   VARCHAR(128),
	@sFormatFilePath VARCHAR(128)
)
AS
BEGIN

	DECLARE @sSQL NVARCHAR(4000)

	SET @sSQL = 'BULK INSERT SmartSort_Canpar_SCS.dbo.PACKAGE_TRANSACTIONS '
	SET @sSQL = @sSQL + 'FROM ''' + @sFilePath + ''''
	SET @sSQL = @sSQL + ' WITH ( FIRSTROW = 2, FORMATFILE = ''' +@sFormatFilePath + ''', BATCHSIZE  = 2048 )'
	-- EXECUTE THE SQL STATEMENT BUILT
	EXEC sp_executesql @sSQL
END
GO


--**************************************************************************************
-- Name: 	Grace Bui 2005
-- Company: 	Brock Solutions
--**************************************************************************************
-- Description:	This Stored Procedure inserts a bulk file into 
--		the PACKAGES table.
--**************************************************************************************
--Create Date:  02/22/2006
--
--	REVISION HISTORY
--	----------------------------------------------------
--	Item	Name		Date		Description
--	----------------------------------------------------
--	2.0		DN		Nov 19, 2012	Added FIRE_TRIGGERS to PACKAGES Bulk Insert.  This 
--									will add the data to PACKAGES_HISTORY
--
--
--**************************************************************************************
ALTER PROCEDURE dbo.PACKAGES_BCP_INSERT_UPDATE
(
	@sFilePath   VARCHAR(128),
	@sFormatFilePath VARCHAR(128)
)
AS
BEGIN

	DECLARE @sSQL NVARCHAR(4000)

	-- INSERT INTO PACKAGES Table
	SET @sSQL = 'BULK INSERT SmartSort_Canpar_SCS.dbo.PACKAGES '
	SET @sSQL = @sSQL + 'FROM ''' + @sFilePath + ''''
	SET @sSQL = @sSQL + ' WITH ( FIRE_TRIGGERS, FIRSTROW = 2, FORMATFILE = ''' +@sFormatFilePath + ''', BATCHSIZE  = 2048 )'
	-- EXECUTE THE SQL STATEMENT BUILT
	EXEC sp_executesql @sSQL

END
GO

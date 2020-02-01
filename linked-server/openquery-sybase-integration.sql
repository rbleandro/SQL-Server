--Step 0. Requirements:
--A data source connection named CPDB1 must be created?
--Linked Server CPDB1 must be created and the login mappings configured
--OPENQUERY must be enabled in the SQL Server instance

--step 1. Create staging table on Sybase.
CREATE TABLE [dbo].[dhl_shpmt](
	[parcel_number] [VARCHAR](50) NOT NULL,
	[shipment_number] [VARCHAR](50) NULL,
	[account] [VARCHAR](9) NULL,
	[customer_name] [NVARCHAR](50) NULL,
	[ship_date] [SMALLDATETIME] NULL,
	[payment_type] [VARCHAR](3) NULL,
	[collect_account] [VARCHAR](9) NULL,
	[total_pieces] [INT] NULL,
	[void] [CHAR](1) NULL
) 
GO
CREATE NONCLUSTERED INDEX idx_parcelnumber ON dhl_shpmt(parcel_number) --this index speeds up the cleaning phase of the staging table
GO

--step 2. Cleaning the staging table
--The final delete in Sybase will use the parcel_number column in the where clause. This can take some time to finish depending on how big the table is.
--It might be way faster to just clean the table directly in Sybase (truncate table)
--DELETE FROM OPENQUERY ([CPDB1], 'SELECT parcel_number FROM lm_stage.dbo.dhl_shpmt')  
--Edited on July 10 2019: Do not use DELETE. You can use the workaround below to do a truncate which is much faster
DECLARE @count INT=1
SELECT @count=COUNT(*) FROM OPENQUERY (CPDB1, 'select top 1 * from lm_stage.dbo.dhl_shpmt where 1=2; TRUNCATE TABLE lm_stage.dbo.dhl_shpmt; select count(*) as qtd from lm_stage.dbo.dhl_shpmt' );
--SELECT @count;

IF @count>0 
	RAISERROR('The staging table in Sybase could not be cleaned. Check and correct previous errors.',16,1);
ELSE
BEGIN
	--step 3. Populating the Sybase staging table with the required information present at the SQL Server database
	INSERT OPENQUERY ([CPDB1], 'SELECT * FROM lm_stage.dbo.dhl_shpmt')  
	SELECT DISTINCT
	p.ParID 'parcel_number' ,
	p.ShptID 'shipment_number' ,
	s.S_AcctC 'account' ,
	s.S_CoName 'customer_name' ,
	s.Sh_ShptDate 'ship_date' ,
	s.Sh_PymtType 'payment_type' ,
	s.Sh_CollectAcct 'collect_account' ,
	s.Sh_TotalPcs 'total_pieces' ,
	s.mDeletedFlag 'void'
	--INTO dhl_shpmt
	FROM dbo.T_SHPMT s ,dbo.T_SHPAR p
	WHERE     s.Sh_ShptDate > '2019/06/24 00:00'
	AND s.Sh_ShptDate < '2019/06/25 00:00'
	AND p.ShptID = s.ShptID
	--AND 1=2

	--step 4. Performing the final select from SQL Server pulling data from Sybase tables (including the staging table created previously)
	SELECT 
	M.account AS 'Customer',
	M.customer_name AS 'Customer Name',
	M.ship_date AS 'Manifest Date',
	COUNT(*) AS 'Pieces',
	SUM(M.voids) AS 'Voids',
	SUM(M.manifested) AS 'Simon Manifest',
	SUM(M.billed) AS 'Billed'

	FROM (SELECT * FROM OPENQUERY([CPDB1],'
	SELECT  T.parcel_number ,
			T.shipment_number ,
			T.account ,
			T.customer_name ,
			T.ship_date ,
			T.payment_type ,
			T.collect_account ,
			T.total_pieces ,
			CASE WHEN T.void = ''1'' THEN 1 ELSE 0 END AS voids,
			CASE b.reference_num
			  WHEN NULL THEN 0
			  ELSE 1
			END AS manifested ,
			CASE x.reference_num
			  WHEN NULL THEN 0
			  ELSE 1
			END AS billed
	FROM    
	( 
		SELECT DISTINCT
		parcel_number ,
		shipment_number ,
		account ,
		customer_name ,
		ship_date ,
		payment_type ,
		collect_account ,
		total_pieces ,
		void
		FROM lm_stage.dbo.dhl_shpmt
	) T
	LEFT OUTER JOIN lmscan.dbo.tttl_ma_barcode b ON b.reference_num = T.parcel_number
	LEFT OUTER JOIN rev_hist_lm.dbo.bcxref x ON x.reference_num = T.parcel_number;
	')
	) AS M 
	GROUP BY account, customer_name, ship_date
END

EXEC rpt_dhl_manifest @begindate='2019/06/24 00:00', @enddate='2019/06/30 00:00'


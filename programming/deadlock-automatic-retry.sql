USE [SmartSort_Canpar_SCS_JCC]
GO

/****** Object:  StoredProcedure [dbo].[sp_MSins_dboPACKAGES]    Script Date: 5/9/2019 2:06:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_MSins_dboPACKAGES]
    @c1 uniqueidentifier,
    @c2 varchar(50),
    @c3 varchar(50),
    @c4 varchar(50),
    @c5 varchar(2),
    @c6 varchar(6),
    @c7 numeric(7,2),
    @c8 smallint,
    @c9 numeric(7,2),
    @c10 varchar(1),
    @c11 smallint,
    @c12 datetime,
    @c13 datetime,
    @c14 smallint,
    @c15 datetime,
    @c16 smallint,
    @c17 datetime,
    @c18 smallint,
    @c19 int,
    @c20 int,
    @c21 smallint,
    @c22 datetime,
    @c23 varchar(50),
    @c24 smallint,
    @c25 smallint,
    @c26 smallint,
    @c27 smallint,
    @c28 int,
    @c29 varchar(50),
    @c30 varchar(50),
    @c31 varchar(50),
    @c32 varchar(50),
    @c33 varchar(50),
    @c34 int,
    @c35 int,
    @c36 varchar(7),
    @c37 smallint,
    @c38 smallint,
    @c39 smallint,
    @c40 int,
    @c41 int,
    @c42 int,
    @c43 int,
    @c44 smallint,
    @c45 char(1),
    @c46 varchar(5),
    @c47 int,
    @c48 smallint,
    @c49 datetime,
    @c50 int
as
begin  
	DECLARE @RetryCount INT
	DECLARE @Success    BIT

	SELECT @RetryCount = 1, @Success = 0
	WHILE @RetryCount < =  3 AND @Success = 0
	BEGIN
		BEGIN TRY
		BEGIN TRANSACTION

		insert into [dbo].[PACKAGES](
			[GUID],
			[Package_ID],
			[Customer_ID],
			[Shipment_ID],
			[Service_Type],
			[Postal_Code],
			[Manifest_Weight],
			[Manifest_Weight_UOM],
			[Actual_Weight],
			[Actual_Weight_Status_Code],
			[Actual_Weight_UOM],
			[Manifest_Received_Time],
			[Upload_Time],
			[Tunnel_ID],
			[Scan_Tunnel_Time],
			[Virtual_Scanner_ID],
			[Divert_Time],
			[Door_ID],
			[Inbound_Trailer_ID],
			[Outbound_Trailer_ID],
			[Key_Station_ID],
			[Key_Station_Time],
			[Key_Station_Data],
			[Recirc_Count],
			[Reject_Count],
			[Virtual_Chute_ID],
			[Physical_Chute_ID],
			[Destination_ID],
			[Smart_Barcode],
			[Barcode_2],
			[Barcode_3],
			[Barcode_4],
			[Tote_ID],
			[Pallet_ID],
			[Container_ID],
			[Cart_ID],
			[Logical_Reject_Reason],
			[Last_Reject_Reason],
			[Sort_Method],
			[Actual_Length],
			[Actual_Width],
			[Actual_Height],
			[Actual_Volume],
			[Is_XC],
			[XC_Reason_ID],
			[Dimensioner_Status_Code],
			[Object_ID],
			[Creation_Type],
			[Creation_Time],
			[Company]
		) values (
		@c1,
		@c2,
		@c3,
		@c4,
		@c5,
		@c6,
		@c7,
		@c8,
		@c9,
		@c10,
		@c11,
		@c12,
		@c13,
		@c14,
		@c15,
		@c16,
		@c17,
		@c18,
		@c19,
		@c20,
		@c21,
		@c22,
		@c23,
		@c24,
		@c25,
		@c26,
		@c27,
		@c28,
		@c29,
		@c30,
		@c31,
		@c32,
		@c33,
		@c34,
		@c35,
		@c36,
		@c37,
		@c38,
		@c39,
		@c40,
		@c41,
		@c42,
		@c43,
		@c44,
		@c45,
		@c46,
		@c47,
		@c48,
		@c49,
		@c50	) 

		COMMIT TRANSACTION 
		
		SELECT @Success = 1 -- To exit the loop

	   END TRY
 
	   BEGIN CATCH
		  ROLLBACK TRANSACTION
 
		  SELECT  ERROR_NUMBER() AS [Error Number],
		  ERROR_MESSAGE() AS [ErrorMessage];     
  
		  IF ERROR_NUMBER() IN (  1204, -- SqlOutOfLocks
								  1205, -- SqlDeadlockVictim
								  1222 -- SqlLockRequestTimeout
								  )
		  BEGIN
				SET @RetryCount = @RetryCount + 1  
				-- This delay is to give the blocking 
				-- transaction time to finish.
				-- So you need to tune according to your 
				-- environment
				WAITFOR DELAY '00:00:10'  
		  END 
		  ELSE    
		  BEGIN
				DECLARE
				@ERROR_SEVERITY INT,
				@ERROR_STATE INT,
				@ERROR_NUMBER INT,
				@ERROR_LINE INT,
				@ERROR_MESSAGE VARCHAR(245)
				SELECT
				@ERROR_SEVERITY = ERROR_SEVERITY(),
				@ERROR_STATE = ERROR_STATE(),
				@ERROR_NUMBER = ERROR_NUMBER(),
				@ERROR_LINE = ERROR_LINE(),
				@ERROR_MESSAGE = ERROR_MESSAGE()
	
				RAISERROR(@ERROR_MESSAGE,@ERROR_SEVERITY, @ERROR_STATE);
		  END
	   END CATCH
	END
end  

GO


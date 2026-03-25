
----------------------STAGING----------------------
--[STAGING_CRM]
CREATE TABLE [dbo].[STAGING_CRM](
	[App_ID] [nvarchar](255) NOT NULL,
	[eKYC_ID] [nvarchar](255) NULL,
	[CRM_Source] [nvarchar](255) NULL,
	[CRM_Channel] [nvarchar](255) NULL,
	[Click_Ads_DT] [datetime] NULL,
	[Install_App_DT] [datetime] NULL)

--[STAGING_Digital_Account]
CREATE TABLE [dbo].[STAGING_Digital_Account](
	[Account_Created_DT] [datetime] NULL,
	[Account_Number] [nvarchar](255) NOT NULL,
	[Account_Category] [nvarchar](255) NULL,
	[Customer_ID] [nvarchar](255) NULL,
	[Account_Status] [nvarchar](255) NULL)

--[STAGING_Digital_Transaction]
CREATE TABLE [dbo].[STAGING_Digital_Transaction](
	[Transaction_ID] [nvarchar](255) NOT NULL,
	[Account_Number] [nvarchar](255) NULL,
	[Customer_ID] [nvarchar](255) NULL,
	[Transaction_Amount] [numeric](18, 0) NULL,
	[Transaction_Range] [nvarchar](255) NULL,
	[Transaction_DT] [datetime] NULL,
	[Transaction_Type] [nvarchar](255) NULL,
	[Transaction_Group] [nvarchar](255) NULL)

--[STAGING_eKYC_Information]
CREATE TABLE [dbo].[STAGING_eKYC_Information](
	[eKYC_ID] [nvarchar](255) NOT NULL,
	[eKYC_DT] [datetime] NULL,
	[OCR_Name] [nvarchar](255) NULL,
	[OCR_Dob] [nvarchar](255) NULL,
	[OCR_Gender] [nvarchar](255) NULL,
	[OCR_Address] [nvarchar](255) NULL,
	[OCR_Nationality] [nvarchar](255) NULL,
	[INPUT_Name] [nvarchar](255) NULL,
	[INPUT_Dob] [nvarchar](255) NULL,
	[INPUT_Gender] [nvarchar](255) NULL,
	[INPUT_Address] [nvarchar](255) NULL,
	[INPUT_Nationality] [nvarchar](255) NULL,
	[SCORE_Sanity] [decimal](3, 2) NULL,
	[SCORE_Tampering] [decimal](3, 2) NULL,
	[SCORE_Liveness] [decimal](3, 2) NULL,
	[SCORE_Matching] [decimal](3, 2) NULL,
	[Customer_ID] [nvarchar](255) NULL)

--[STAGING_Post_eKYC_Information]
CREATE TABLE [dbo].[STAGING_Post_eKYC_Information](
	[PosteKYC_created_DT] [datetime] NULL,
	[Customer_ID] [nvarchar](255) NOT NULL,
	[Fraud_Type] [nvarchar](255) NULL,
	[Is_KYC] [nvarchar](1) NULL,
	[KYC_DT] [datetime] NULL)


-----------------------------------------RECONCILIATION---------------------------------
--[DIM_TRANSACTION_TYPE]
CREATE TABLE [dbo].[DIM_TRANSACTION_TYPE](
	[Transaction_Type] [nvarchar](255) NOT NULL,
	[Transaction_Group] [nvarchar](255) NULL,
	[KYC_required] [nvarchar](1) NULL,
	[Limit_Trans_No] [numeric](18, 0) NULL,
	[Limit_Trans_Amount_Each] [numeric](18, 0) NULL,
	[Limit_Trans_Amount_Total] [numeric](18, 0) NULL)

--[DIM_ACCOUNTS]
	CREATE TABLE [dbo].[DIM_ACCOUNTS](
	[Account_Created_DT] [datetime] NULL,
	[Account_Number] [nvarchar](255) NOT NULL,
	[Account_Category] [nvarchar](255) NULL,
	[Customer_ID] [nvarchar](255) NULL,
	[Account_Status] [nvarchar](255) NULL)

--[DIM_CRM]
CREATE TABLE [dbo].[DIM_CRM](
	[App_ID] [nvarchar](255) NOT NULL,
	[eKYC_ID] [nvarchar](255) NULL,
	[CRM_Source] [nvarchar](255) NULL,
	[CRM_Channel] [nvarchar](255) NULL,
	[Click_Ads_DT] [datetime] NULL,
	[Install_App_DT] [datetime] NULL)

--[DIM_eKYC]
CREATE TABLE [dbo].[DIM_eKYC](
	[eKYC_ID] [nvarchar](255) NOT NULL,
	[eKYC_DT] [datetime] NULL,
	[OCR_Name] [nvarchar](255) NULL,
	[OCR_Dob] [nvarchar](255) NULL,
	[OCR_Gender] [nvarchar](255) NULL,
	[OCR_Nationality] [nvarchar](255) NULL,
	[INPUT_Name] [nvarchar](255) NULL,
	[INPUT_Dob] [nvarchar](255) NULL,
	[INPUT_Gender] [nvarchar](255) NULL,
	[INPUT_Nationality] [nvarchar](255) NULL,
	[SCORE_Sanity] [decimal](3, 2) NULL,
	[SCORE_Tampering] [decimal](3, 2) NULL,
	[SCORE_Liveness] [decimal](3, 2) NULL,
	[SCORE_Matching] [decimal](3, 2) NULL,
	[Customer_ID] [nvarchar](255) NULL,
	[OCR_Address] [nvarchar](255) NULL,
	[INPUT_Address] [nvarchar](255) NULL)

--[DIM_Post_eKYC]
CREATE TABLE [dbo].[DIM_Post_eKYC](
	[PosteKYC_created_DT] [datetime] NULL,
	[Customer_ID] [nvarchar](255) NOT NULL,
	[Fraud_Type] [nvarchar](255) NULL,
	[Is_KYC] [nvarchar](1) NULL,
	[KYC_DT] [datetime] NULL)

--[DIM_TRANSACTIONS]
CREATE TABLE [dbo].[DIM_TRANSACTIONS](
	[Transaction_ID] [nvarchar](255) NOT NULL,
	[Account_Number] [nvarchar](255) NULL,
	[Customer_ID] [nvarchar](255) NULL,
	[Transaction_Amount] [numeric](18, 0) NULL,
	[Transaction_Range] [nvarchar](255) NULL,
	[Transaction_DT] [datetime] NULL,
	[Transaction_Type] [nvarchar](255) NULL)

--FACT
CREATE TABLE [dbo].[FACT_DIGITAL_PROFILES](
	[eKYC_DT] [datetime] NULL,
	[CRM_Source] [nvarchar](255) NULL,
	[CRM_Channel] [nvarchar](255) NULL,
	[Customer_ID] [nvarchar](255) primary key,
	[Account_Created_DT] [datetime] NULL,
	[Account_Number] [nvarchar](255) NULL,
	[Account_Category] [nvarchar](255) NULL,
	[Account_Status] [nvarchar](255) NULL,
	[FIRST_TRANS] [datetime] NULL,
	[TRANS_CNT] [numeric](18, 0) NULL,
	[TRANS_AMT] [numeric](18, 0) NULL,
	[PosteKYC_created_DT] [datetime] NULL,
	[Fraud_Type] [nvarchar](255) NULL,
	[KYC_DT] [datetime] NULL)
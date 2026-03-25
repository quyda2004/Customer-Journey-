

-- [dbo].[STAGING_eKYC_Information]

SELECT count(*)
FROM [DWH].[dbo].[STAGING_eKYC_Information]

DELETE FROM [DWH].[dbo].[STAGING_eKYC_Information]

SELECT [eKYC_ID]
      ,[eKYC_DT]
      ,JSON_VALUE([OCR_INFO],'$.name') [OCR_Name]
	  ,JSON_VALUE([OCR_INFO],'$.dob') [OCR_Dob]
	  ,JSON_VALUE([OCR_INFO],'$.gender') [OCR_Gender]
	  ,JSON_VALUE([OCR_INFO],'$.nationality') [OCR_Nationality]
	  ,JSON_VALUE([OCR_INFO],'$.address') [OCR_Address]
	  ,JSON_VALUE([INPUT_INFO],'$.name') [INPUT_Name]
	  ,JSON_VALUE([INPUT_INFO],'$.dob') [INPUT_Dob]
	  ,JSON_VALUE([INPUT_INFO],'$.gender') [INPUT_Gender]
	  ,JSON_VALUE([INPUT_INFO],'$.address') [INPUT_Address]
	  ,JSON_VALUE([INPUT_INFO],'$.nationality') [INPUT_Nationality]
      ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Sanity]
	  ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Tampering]
	  ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Liveness]
	  ,CAST([SANITY_SCORE] AS decimal(3,2)) [SCORE_Matching]
      ,[CUSTOMER_ID]
FROM [ONBOARDING].[dbo].[ONBOARDING_Data]

-- STAGING -> RECONCILIATION: BULK LOAD
SELECT count(*)
FROM [DWH].[dbo].[DIM_EKYC]

DELETE FROM [DWH].[dbo].[DIM_EKYC]

  -- [dbo].[STAGING_CRM]

SELECT count(*)
FROM [DWH].[dbo].[STAGING_CRM]

DELETE FROM [DWH].[dbo].[STAGING_CRM]

-- STAGING -> RECONCILIATION: BULK LOAD
SELECT count(*)
FROM [DWH].[dbo].[DIM_CRM]

DELETE FROM [DWH].[dbo].[DIM_CRM]

  -- [dbo].[STAGING_Digital_Account]

  SELECT count(*)
FROM [DWH].[dbo].[STAGING_Digital_Account]

DELETE FROM [DWH].[dbo].[STAGING_Digital_Account]

SELECT  [CREATED_DT]
      ,[Transaction_Account]
      ,[Account_Category]
      ,[CUSTOMER_ID]
      ,[ACCOUNT_STATUS]
FROM [CORE_T24].[dbo].[T24_ACCOUNT]
WHERE Account_Category in ('1001','1002')

-- STAGING -> RECONCILIATION: BULK LOAD
SELECT count(*)
FROM [DWH].[dbo].[DIM_ACCOUNTS]

DELETE FROM [DWH].[dbo].[DIM_ACCOUNTS]

  -- [dbo].[DIM_TRANSACTION_TYPE]

  SELECT count(*)
FROM [DWH].[dbo].[DIM_TRANSACTION_TYPE]

DELETE FROM [DWH].[dbo].[STAGING_Digital_Transaction]

SELECT  [Transaction_Type]
      ,[Transaction_Group]
FROM [CORE_T24].[dbo].[T24_TRANSACTION]
GROUP BY  [Transaction_Type]
      ,[Transaction_Group]


DELETE FROM [DWH].[dbo].[DIM_TRANSACTION_TYPE]

  -- [dbo].[STAGING_Digital_Account]

  SELECT count(*)
FROM [DWH].[dbo].[STAGING_Digital_Transaction]

DELETE FROM [DWH].[dbo].[STAGING_Digital_Transaction]

--IF  [Transaction_Amount] < 10,000,000 => LOW
--IF  [Transaction_Amount] >= 10,000,000 & [Transaction_Amount] < 100,000,000  =>  MEDIUM LOW
--IF  [Transaction_Amount] >= 100,000,000 & [Transaction_Amount] < 1,000,000,000  => MEDIUM HIGH
--IF  [Transaction_Amount] > 1,000,000,000  => HIGH

SELECT [Transaction_ID]
      ,[Transaction_Account]
      ,[CUSTOMER_ID]
      --,[Channel]
	  ,[Transaction_Amount]
	  , IIF([Transaction_Amount] < 1000000, 'LOW'
			, IIF([Transaction_Amount] < 10000000, 'MEDIUM LOW'
				, IIF([Transaction_Amount] < 100000000, 'MEDIUM HIGH', 'HIGH')))   [Transaction_Range]
	  ,[Transaction_DT]
      ,[Transaction_Type]
      ,[Transaction_Group]
  FROM [CORE_T24].[dbo].[T24_TRANSACTION]
  WHERE [Channel] = 'APP'


-- STAGING -> RECONCILIATION: BULK LOAD
SELECT count(*)
FROM [DWH].[dbo].[DIM_TRANSACTIONS]

DELETE FROM [DWH].[dbo].[DIM_TRANSACTIONS]

 -- [dbo].[STAGING_Post_eKYC_Information]

  SELECT count(*)
FROM [DWH].[dbo].[STAGING_Post_eKYC_Information]

DELETE FROM [DWH].[dbo].[STAGING_Post_eKYC_Information]

-- STAGING -> RECONCILIATION: BULK LOAD
SELECT count(*)
FROM [DWH].[dbo].[DIM_POST_EKYC]

DELETE FROM [DWH].[dbo].[DIM_POST_EKYC]


-- FACT
SELECT e.[eKYC_DT], e.[Customer_ID]
			, c.[CRM_Source], c.[CRM_Channel]
			, a.[Account_Created_DT], a.[Account_Number], a.[Account_Category], a.[Account_Status]
			, t.FIRST_TRANS, t.TRANS_CNT, t.TRANS_AMT
			, p.[PosteKYC_created_DT]
			, p.[Fraud_Type] 
			, p.[KYC_DT] 
			--, 
	FROM [DWH].[dbo].[DIM_EKYC] e
	LEFT JOIN [DWH].[dbo].[DIM_CRM] c on e.[eKYC_ID] = c.[eKYC_ID]
	LEFT JOIN [DWH].[dbo].[DIM_ACCOUNTS] a on e.[Customer_ID] = a.[Customer_ID]
	LEFT JOIN (SELECT [Customer_ID],[Account_Number]
						, min([Transaction_DT]) FIRST_TRANS
						, count(distinct [Transaction_ID]) TRANS_CNT
						, sum([Transaction_Amount]) TRANS_AMT
				FROM [DWH].[dbo].[DIM_TRANSACTIONS]
				GROUP BY  [Customer_ID],[Account_Number]
					) t on e.[Customer_ID] = t.[Customer_ID] 
					AND a.[Account_Number] = t.[Account_Number]
	LEFT JOIN [DWH].[dbo].[DIM_POST_EKYC] p on   e.[Customer_ID] = p.[Customer_ID]
	WHERE e.[Customer_ID] IS NOT NULL


SELECT count(*)
FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]

DELETE FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]


-- CLEAN
--- STAGING
SELECT COUNT(*) --66967
FROM [DWH].[dbo].[STAGING_eKYC_Information]
SELECT COUNT(*) --108000
FROM [DWH].[dbo].[STAGING_CRM]
SELECT COUNT(*) --189320
FROM [DWH].[dbo].[STAGING_Digital_Account]
SELECT COUNT(*) --171088
FROM [DWH].[dbo].[STAGING_Digital_Transaction]
SELECT COUNT(*) --11336
FROM [DWH].[dbo].[STAGING_Post_eKYC_Information]

DELETE FROM [DWH].[dbo].[STAGING_eKYC_Information]
DELETE FROM [DWH].[dbo].[STAGING_CRM]
DELETE FROM [DWH].[dbo].[STAGING_Digital_Account]
DELETE FROM [DWH].[dbo].[STAGING_Digital_Transaction]
DELETE FROM [DWH].[dbo].[STAGING_Post_eKYC_Information]

--- RECONCILIATION
SELECT COUNT(*) --66967
FROM [DWH].[dbo].[DIM_EKYC]
SELECT COUNT(*) --108000
FROM [DWH].[dbo].[DIM_CRM]
SELECT COUNT(*) --189320
FROM [DWH].[dbo].[DIM_ACCOUNTS]
SELECT COUNT(*) --9
FROM [DWH].[dbo].[DIM_TRANSACTION_TYPE]
SELECT COUNT(*) --171088
FROM [DWH].[dbo].[DIM_TRANSACTIONS]
SELECT COUNT(*) --11336
FROM [DWH].[dbo].[DIM_POST_EKYC]

DELETE FROM [DWH].[dbo].[DIM_EKYC]
DELETE FROM [DWH].[dbo].[DIM_CRM]
DELETE FROM [DWH].[dbo].[DIM_ACCOUNTS]
DELETE FROM [DWH].[dbo].[DIM_TRANSACTION_TYPE]
DELETE FROM [DWH].[dbo].[DIM_TRANSACTIONS]
DELETE FROM [DWH].[dbo].[DIM_POST_EKYC]

--- FACT
SELECT count(*) -- 47116
FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]

SELECT TOP(1000) *
FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]

DELETE FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]
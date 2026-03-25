--SELECT TOP (1000) [eKYC_DT]
--      ,[CRM_Source]
--      ,[CRM_Channel]
--      ,[Customer_ID]
--      ,[Account_Created_DT]
--      ,[Account_Number]
--      ,[Account_Category]
--      ,[Account_Status]
--      ,[FIRST_TRANS]
--      ,[TRANS_CNT]
--      ,[TRANS_AMT]
--      ,[PosteKYC_created_DT]
--      ,[Fraud_Type]
--      ,[KYC_DT]
--  FROM [DWH].[dbo].[FACT_DIGITAL_PROFILES]

  SELECT F.[Customer_ID]
	  , IIF([Click_Ads_DT] > [Install_App_DT] OR [Click_Ads_DT] > F.[eKYC_DT] OR [Click_Ads_DT] > [Account_Created_DT] OR [Click_Ads_DT] > [FIRST_TRANS]
			OR [Install_App_DT] > F.[eKYC_DT] OR [Install_App_DT] > [Account_Created_DT]  OR [Install_App_DT] > [FIRST_TRANS]
			OR F.[eKYC_DT] > [Account_Created_DT] OR F.[eKYC_DT] > [FIRST_TRANS] 
			OR [Account_Created_DT] > [FIRST_TRANS], 1,0) IS_TIME_ALERT -- 1 - violate / 0 - comply
	  , IIF( E.[SCORE_Sanity] < 0.85 OR E.[SCORE_Tampering] < 0.85 OR E.[SCORE_Liveness] < 0.85 OR E.[SCORE_Matching] < 0.85,1,0) IS_SCORE_ALERT
	  , IIF(E.[OCR_Name] <> E.[INPUT_Name] 
			OR E.[OCR_Dob] <> E.[INPUT_Dob]
			OR  E.[OCR_Gender] <> E.[OCR_Gender] 
			OR  E.[OCR_Nationality] <> E.[INPUT_Nationality]
			OR E.[OCR_Address] <> E.[INPUT_Address],1,0) IS_INFO_ALERT
	  , IIF([Account_Category] not in ('1001','1002'),1,0) IS_CATEGORY_ALERT
	  , IIF(Fraud_Type IS NULL, 'NORMAL', Fraud_Type) Fraud_Type
  FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
  LEFT JOIN DIM_EKYC E  ON F.[Customer_ID] = E.[Customer_ID]
  LEFT JOIN DIM_CRM B ON E.[eKYC_ID] = B.eKYC_ID

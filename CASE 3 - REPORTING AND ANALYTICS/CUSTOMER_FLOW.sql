
--===================================== CUSTOMER ONBOARDING FLOW =======================================

------------------------------------- EASY ---------------------------------------

WITH N AS 
(
SELECT C.[CRM_Channel], C.[CRM_Source], C.[App_ID], C.[Click_Ads_DT], C.[Install_App_DT]
	   , E.[eKYC_DT], E.[Customer_ID], F.[Account_Created_DT], F.[FIRST_TRANS]
	   , T.[LAST_TRANS], F.[PosteKYC_created_DT], F.[KYC_DT]
	   , IIF(F.[FIRST_TRANS] IS NOT NULL, 'Make_First_Transaction'
			, IIF(F.[Account_Created_DT] IS NOT NULL, 'Created_Account'
				, IIF(E.[Customer_ID] IS NOT NULL, 'Created_CIF'
					, IIF(E.[eKYC_DT] IS NOT NULL, 'Register_eKYC'
						, IIF(C.[Install_App_DT] IS NOT NULL, 'Install_App', 'Click_to_Ads'))))) FINAL_STAGE
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E ON C.[eKYC_ID] = E.[eKYC_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F ON E.[Customer_ID] = F.[Customer_ID]
LEFT JOIN (SELECT T1.[Customer_ID], MAX([Transaction_DT]) LAST_TRANS
		   FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T1
		   GROUP BY T1.[Customer_ID]) T ON F.[Customer_ID] = T.[Customer_ID]
)
SELECT [App_ID]
		, FINAL_STAGE
		--, IIF([FIRST_TRANS] IS NOT NULL, 'Make_First_Transaction'
		--	, IIF([Account_Created_DT] IS NOT NULL, 'Created_Account'
		--		, IIF([Customer_ID] IS NOT NULL, 'Created_CIF'
		--			, IIF([eKYC_DT] IS NOT NULL, 'Register_eKYC'
		--				, IIF([Install_App_DT] IS NOT NULL, 'Install_App', 'Click_to_Ads'))))) FINAL_STAGE
		, M.[Stage_1] AS Click_to_Ads
			, M.[Stage_2] AS Install_App
				, M.[Stage_3] AS Register_eKYC
					, M.[Stage_4] AS Created_CIF
						, M.[Stage_5] AS Created_Account
							, M.[Stage_6] AS Make_First_Transaction
FROM N
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[MAPPING] M
ON FINAL_STAGE = M.[Key_]
WHERE [Type_] = 'STG';

------------------------------------------ INTERMEDIATE -------------------------------------

WITH N AS
(
SELECT C.[CRM_Channel], C.[CRM_Source], C.[App_ID], C.[Click_Ads_DT], C.[Install_App_DT]
	   , E.[eKYC_DT], E.[Customer_ID], F.[Account_Created_DT], F.[FIRST_TRANS]
	   , T.[LAST_TRANS], F.[PosteKYC_created_DT], F.[KYC_DT]
	   , IIF(F.[FIRST_TRANS] IS NOT NULL, 'Make_First_Transaction'
			, IIF(F.[Account_Created_DT] IS NOT NULL, 'Created_Account'
				, IIF(E.[Customer_ID] IS NOT NULL, 'Created_CIF'
					, IIF(E.[eKYC_DT] IS NOT NULL, 'Register_eKYC'
						, IIF(C.[Install_App_DT] IS NOT NULL, 'Install_App', 'Click_to_Ads'))))) FINAL_STAGE
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E ON C.[eKYC_ID] = E.[eKYC_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F ON E.[Customer_ID] = F.[Customer_ID]
LEFT JOIN (SELECT T1.[Customer_ID], MAX([Transaction_DT]) LAST_TRANS
		   FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T1
		   GROUP BY T1.[Customer_ID]) T ON F.[Customer_ID] = T.[Customer_ID]
)

SELECT CONVERT(VARCHAR(6), [Click_Ads_DT], 112) AS MONTHID
		, [App_ID]
		, FINAL_STAGE
		, M.[Stage_1] AS Click_to_Ads
			, M.[Stage_2] AS Install_App
				, M.[Stage_3] AS Register_eKYC
					, M.[Stage_4] AS Created_CIF
						, M.[Stage_5] AS Created_Account
							, M.[Stage_6] AS Make_First_Transaction
FROM N
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[MAPPING] M
ON FINAL_STAGE = M.[Key_]
WHERE [Type_] = 'STG';

-------------------------------------------- ADVANCE ----------------------------------------

WITH N AS
(
SELECT C.[CRM_Channel], C.[CRM_Source], C.[App_ID], C.[Click_Ads_DT], C.[Install_App_DT]
	   , E.[eKYC_DT], E.[Customer_ID], F.[Account_Created_DT], F.[FIRST_TRANS]
	   , T.[LAST_TRANS], F.[PosteKYC_created_DT], F.[KYC_DT]
	   , IIF(F.[FIRST_TRANS] IS NOT NULL, 'Make_First_Transaction'
			, IIF(F.[Account_Created_DT] IS NOT NULL, 'Created_Account'
				, IIF(E.[Customer_ID] IS NOT NULL, 'Created_CIF'
					, IIF(E.[eKYC_DT] IS NOT NULL, 'Register_eKYC'
						, IIF(C.[Install_App_DT] IS NOT NULL, 'Install_App', 'Click_to_Ads'))))) FINAL_STAGE
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E ON C.[eKYC_ID] = E.[eKYC_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F ON E.[Customer_ID] = F.[Customer_ID]
LEFT JOIN (SELECT T1.[Customer_ID], MAX([Transaction_DT]) LAST_TRANS
		   FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T1
		   GROUP BY T1.[Customer_ID]) T ON F.[Customer_ID] = T.[Customer_ID]
), 

DATE_TRNS AS
(
SELECT [App_ID], [CRM_Channel], [CRM_Source], [Click_Ads_DT], [Install_App_DT]
	   , [eKYC_DT], [Customer_ID], [Account_Created_DT], [FIRST_TRANS], FINAL_STAGE
		, IIF(DATEDIFF(DAY, [Click_Ads_DT], [Install_App_DT]) <=30, 'Within_30_days'
			, IIF(DATEDIFF(DAY, [Click_Ads_DT], [Install_App_DT]) > 30 AND DATEDIFF(DAY, [Click_Ads_DT], [Install_App_DT]) <= 60, 'Within_60_days'
				, IIF(DATEDIFF(DAY, [Click_Ads_DT], [Install_App_DT]) > 60 AND DATEDIFF(DAY, [Click_Ads_DT], [Install_App_DT]) <= 90, 'Within_90_days'
					, IIF(DATEDIFF(DAY, [Click_Ads_DT], [Install_App_DT]) > 90, 'More_than_90_days', NULL)))) Date_Ins

		, IIF(DATEDIFF(DAY, [Install_App_DT], [eKYC_DT]) <=30, 'Within_30_days'
			, IIF(DATEDIFF(DAY, [Install_App_DT], [eKYC_DT]) > 30 AND DATEDIFF(DAY, [Install_App_DT], [eKYC_DT]) <= 60, 'Within_60_days'
				, IIF(DATEDIFF(DAY, [Install_App_DT], [eKYC_DT]) > 60 AND DATEDIFF(DAY, [Install_App_DT], [eKYC_DT]) <= 90, 'Within_90_days'
					, IIF(DATEDIFF(DAY, [Install_App_DT], [eKYC_DT]) > 90, 'More_than_90_days', NULL)))) Date_eKYC

		, IIF(DATEDIFF(DAY, [eKYC_DT], [Account_Created_DT]) <=30, 'Within_30_days'
			, IIF(DATEDIFF(DAY, [eKYC_DT], [Account_Created_DT]) > 30 AND DATEDIFF(DAY, [eKYC_DT], [Account_Created_DT]) <= 60, 'Within_60_days'
				, IIF(DATEDIFF(DAY, [eKYC_DT], [Account_Created_DT]) > 60 AND DATEDIFF(DAY, [eKYC_DT], [Account_Created_DT]) <= 90, 'Within_90_days'
					, IIF(DATEDIFF(DAY, [eKYC_DT], [Account_Created_DT]) > 90, 'More_than_90_days', NULL)))) Date_Acc

		, IIF(DATEDIFF(DAY, [Account_Created_DT], [FIRST_TRANS]) <=30, 'Within_30_days'
			, IIF(DATEDIFF(DAY, [Account_Created_DT], [FIRST_TRANS]) > 30 AND DATEDIFF(DAY, [Account_Created_DT], [FIRST_TRANS]) <= 60, 'Within_60_days'
				, IIF(DATEDIFF(DAY, [Account_Created_DT], [FIRST_TRANS]) > 60 AND DATEDIFF(DAY, [Account_Created_DT], [FIRST_TRANS]) <= 90, 'Within_90_days'
					, IIF(DATEDIFF(DAY, [Account_Created_DT], [FIRST_TRANS]) > 90, 'More_than_90_days', NULL)))) Date_Trns

FROM N
)

SELECT CONVERT(VARCHAR(6), [Click_Ads_DT], 112) AS MONTHID
		, [App_ID], FINAL_STAGE
			, IIF([Click_Ads_DT] IS NOT NULL, 'Click_Ads' , NULL) Click_to_Ads
			, IIF([Install_App_DT] IS NOT NULL, 'Install_App', NULL) Install_App
			, IIF([Install_App_DT] IS NOT NULL, Date_Ins, NULL) Install_App
			, IIF([eKYC_DT] IS NOT NULL, 'Register_eKYC', NULL) Register_eKYC
			, IIF([eKYC_DT] IS NOT NULL, Date_eKYC, NULL) Register_eKYC
			, IIF([Account_Created_DT] IS NOT NULL, 'Created_Account', NULL) Created_Account
			, IIF([Account_Created_DT] IS NOT NULL, Date_Acc, NULL) Created_Account
			, IIF([FIRST_TRANS] IS NOT NULL, 'Make_First_Transaction', NULL) Make_First_Transaction
			, IIF([FIRST_TRANS] IS NOT NULL, Date_Trns, NULL) Make_First_Transaction
FROM DATE_TRNS







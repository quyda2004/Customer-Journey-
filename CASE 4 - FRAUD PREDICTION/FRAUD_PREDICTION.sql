WITH N AS
(
SELECT C.[Install_App_DT], F.[CRM_Source], F.[CRM_Channel],F.[Customer_ID], DATEDIFF(YEAR, E.[OCR_Dob], SYSDATETIME()) AGE,
		E.[eKYC_DT], E.[OCR_Dob], E.[OCR_Gender], E.[OCR_Address], E.[OCR_Nationality], 
		E.[INPUT_Dob], E.[INPUT_Gender], E.[INPUT_Address], E.[INPUT_Nationality], 
		E.[SCORE_Sanity], E.[SCORE_Tampering], E.[SCORE_Liveness], E.[SCORE_Matching],
		F.[Account_Created_DT], F.[FIRST_TRANS], F.[TRANS_CNT], F.[TRANS_AMT], F.[Fraud_Type]
FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E
ON F.[Customer_ID] = E.[Customer_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
ON E.[eKYC_ID] = C.[eKYC_ID]
)

SELECT [CRM_Channel], [Customer_ID], 
		IIF([OCR_Dob] <> [INPUT_Dob], 'YES', 'NO') Is_Diff_Dob,
		IIF([OCR_Gender] <> [INPUT_Gender], 'YES', 'NO') Is_Diff_Gender,
		IIF([OCR_Nationality] <> [INPUT_Nationality], 'YES', 'NO') Is_Diff_Nationality,
		IIF(AGE < 22, '21-',
			IIF(AGE < 26, '22-25', 
				IIF(AGE < 30, '26-29',
					IIF(AGE < 34, '30-33', '34+')))) AGE_Group,
		[OCR_Gender],
		IIF([OCR_Nationality] <> 'VIETNAMESE', 'OTHER', [OCR_Nationality]) Nationality,
		SCORE_Sanity, SCORE_Tampering, SCORE_Liveness, SCORE_Matching,
		ISNULL([TRANS_CNT], 0) Trans_Count,
		--PERCENTILE_CONT(0.3) WITHIN GROUP (ORDER BY [TRANS_AMT]) OVER () AS P30,
		--PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY [TRANS_AMT]) OVER () AS P60,
		--PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY [TRANS_AMT]) OVER () AS P90,
		 CASE
           WHEN [TRANS_AMT] <= 122074277 THEN 'LOW'
           WHEN [TRANS_AMT] <= 286487147.4 THEN 'MEDIUM LOW'
           WHEN [TRANS_AMT] <= 671883827.8 THEN 'MEDIUM HIGH'
           WHEN [TRANS_AMT] > 671883827.8 THEN 'HIGH'
		   ELSE 'NO TRANS'
       END AS Total_Amount_Group,
	   ISNULL(DATEDIFF(DAY, [Install_App_DT], [eKYC_DT]), 1000) DT_to_EKYC,
	   ISNULL(DATEDIFF(DAY, [eKYC_DT], [Account_Created_DT]), 1000) DT_to_Cre_Acc,
	   ISNULL(DATEDIFF(DAY, [Account_Created_DT], [FIRST_TRANS]), 1000) DT_to_Make_1stTrns,
	   IIF([Fraud_Type] <> 'CHECKED' OR [Fraud_Type] IS NULL, 'NORMAL', 'FRAUD') [LABEL]
FROM N

--=========================== Performance of operational verification ============================


------------------------ A.Performance of Predicting ------------------------

WITH N AS
(
 SELECT IIF(E.[OCR_Name] <> E.[INPUT_Name], 1, 0) IS_DIFF_NAME,
		IIF(E.[OCR_Dob] <> E.[INPUT_Dob], 1, 0) IS_DIFF_DOB,
		IIF(E.[OCR_Gender] <> E.[INPUT_Gender], 1, 0) IS_DIFF_GENDER,
		IIF(E.[OCR_Address] <> E.[INPUT_Address], 1, 0) IS_DIFF_ADDRESS,
		IIF(E.[SCORE_Sanity] < 0.85, 1, 0) IS_FAIL_SANITY,
		IIF(E.[SCORE_Tampering] < 0.85, 1, 0) IS_FAIL_TAMPERING,
		IIF(E.[SCORE_Liveness] < 0.85, 1, 0) IS_FAIL_LIVELINESS,
		IIF(E.[SCORE_Matching] < 0.85, 1, 0) IS_FAIL_MATCHING,
		IIF(F.[Fraud_Type] <> 'CHECKED', 1, 0) IS_FRAUD
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E
JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
ON E.[Customer_ID] = F.[Customer_ID]
)

SELECT IS_FRAUD,
		SUM(IIF(IS_DIFF_NAME = 0, 1, 0)) IS_DIFF_NAME_0,
		SUM(IIF(IS_DIFF_NAME = 1, 1, 0)) IS_DIFF_NAME_1,
		SUM(IIF(IS_DIFF_DOB = 0, 1, 0)) AS IS_DIFF_DOB_0,
		SUM(IIF(IS_DIFF_DOB = 1, 1, 0)) AS IS_DIFF_DOB_1,
		SUM(IIF(IS_DIFF_GENDER = 0, 1, 0)) AS IS_DIFF_GENDER_0,
		SUM(IIF(IS_DIFF_GENDER = 1, 1, 0)) AS IS_DIFF_GENDER_1,
		SUM(IIF(IS_DIFF_ADDRESS = 0, 1, 0)) AS IS_DIFF_ADDRESS_0,
		SUM(IIF(IS_DIFF_ADDRESS = 1, 1, 0)) AS IS_DIFF_ADDRESS_1,
		SUM(IIF(IS_FAIL_SANITY = 0, 1, 0)) AS IS_FAIL_SANITY_0,
		SUM(IIF(IS_FAIL_SANITY = 1, 1, 0)) AS IS_FAIL_SANITY_1,
		SUM(IIF(IS_FAIL_TAMPERING = 0, 1, 0)) AS IS_FAIL_TAMPERING_0,
		SUM(IIF(IS_FAIL_TAMPERING = 1, 1, 0)) AS IS_FAIL_TAMPERING_1,
		SUM(IIF(IS_FAIL_LIVELINESS = 0, 1, 0)) AS IS_FAIL_LIVELINESS_0,
		SUM(IIF(IS_FAIL_LIVELINESS = 1, 1, 0)) AS IS_FAIL_LIVELINESS_1, 
		SUM(IIF(IS_FAIL_MATCHING = 0, 1, 0)) AS IS_FAIL_MATCHING_0,
		SUM(IIF(IS_FAIL_MATCHING = 1, 1, 0)) AS IS_FAIL_MATCHING_1
FROM N
GROUP BY IS_FRAUD 

SELECT SUM(IIF(E.[OCR_Name] <> E.[INPUT_Name], 1, 0)) IS_DIFF_NAME
		FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E
JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
ON E.[Customer_ID] = F.[Customer_ID];


------------------------ B. Latency of Fraud Type Identification ------------------------

SELECT DATEDIFF(DAY, [Account_Created_DT], [PosteKYC_created_DT]) Number_of_Day, 
		COUNT(*) Total_Cusotmer
FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES]
WHERE [Fraud_Type] IS NOT NULL
GROUP BY DATEDIFF(DAY, [Account_Created_DT], [PosteKYC_created_DT])
ORDER BY DATEDIFF(DAY, [Account_Created_DT], [PosteKYC_created_DT]);


------------------------ C.Acutal Lost By FRAUD/RISK Customer ------------------------

SELECT  TT.[Transaction_Group], T.[Transaction_Type], COUNT(T.[Transaction_Type]) #_of_Transaction, SUM(F.[TRANS_AMT]) Total_Amount
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTION_TYPE] TT
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T
ON TT.[Transaction_Type] = T.[Transaction_Type]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
ON T.[Customer_ID] = F.[Customer_ID]
WHERE F.[Fraud_Type] <> 'CHECKED'
AND F.[Fraud_Type] IS NOT NULL
AND T.[Transaction_DT] <= F.[PosteKYC_created_DT]
GROUP BY TT.[Transaction_Group], T.[Transaction_Type]
ORDER BY TT.[Transaction_Group], T.[Transaction_Type];

--How many cases in each Transaction_Group
WITH Cases_each_Group AS (
SELECT TT.[Transaction_Group], T.[Transaction_Type],
    F.[Customer_ID],
    F.[TRANS_AMT],
	F.[FRAUD_TYPE],
    T.[Transaction_Range]
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTION_TYPE] TT
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T
ON TT.[Transaction_Type] = T.[Transaction_Type]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
ON F.[Customer_ID] = T.[Customer_ID]
WHERE F.[Fraud_Type] <> 'CHECKED' 
AND F.[Fraud_Type] IS NOT NULL
AND T.[Transaction_DT] <= F.[PosteKYC_created_DT]
)
SELECT [Transaction_Group], [Transaction_Range],
COUNT(DISTINCT [Customer_ID]) AS #_of_Cases, SUM([TRANS_AMT]) Total_Amount
FROM Cases_each_Group
GROUP BY [Transaction_Group], [Transaction_Range]
ORDER BY [Transaction_Group], [Transaction_Range];

--How many cases in each Source & Channel
WITH Cases_each_SC AS
(
SELECT F.[CRM_Channel],
	F.[CRM_Source],
    F.[Customer_ID],
    F.[TRANS_AMT],
	F.[FRAUD_TYPE],
    T.[Transaction_Range]
FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T
ON F.[Customer_ID] = T.[Customer_ID]
WHERE F.[Fraud_Type] <> 'CHECKED'
AND F.[Fraud_Type] IS NOT NULL
AND T.[Transaction_DT] <= F.[PosteKYC_created_DT]
)

SELECT [CRM_Channel], [CRM_Source], SUM([TRANS_AMT]) Total_Amount
		, COUNT(IIF([Transaction_Range] = 'LOW', 'LOW', NULL)) #_of_Low_Transaction
		, COUNT(IIF([Transaction_Range] = 'MEDIUM LOW', 'MEDIUM LOW', NULL)) #_of_Mid_Low_Transaction
		, COUNT(IIF([Transaction_Range] = 'MEDIUM HIGH', 'MEDIUM HIGH', NULL)) #_of_Mid_High_Transaction
		, COUNT(IIF([Transaction_Range] = 'HIGH', 'HIGH', NULL)) #_of_High_Transaction
FROM Cases_each_SC
GROUP BY [CRM_Channel], [CRM_Source]
ORDER BY [CRM_Channel], [CRM_Source];

------------------------ D.Rate of Recheck ------------------------

SELECT 
    CONVERT(VARCHAR(6), [PosteKYC_created_DT], 112) AS MonthID,
    IIF([Fraud_Type] = 'CHECKED', 'CHECKED', 'OTHER FRAUDS') Fraud_Type, COUNT(*) #_of_Customer
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_POST_EKYC]
GROUP BY CONVERT(VARCHAR(6), [PosteKYC_created_DT], 112)
		, IIF([Fraud_Type] = 'CHECKED', 'CHECKED', 'OTHER FRAUDS')
ORDER BY CONVERT(VARCHAR(6), [PosteKYC_created_DT], 112);


------------------------ E.Potential of Onboarding Proccess through month ------------------------

WITH N AS
(
SELECT 
        CONVERT(VARCHAR(6), [eKYC_DT], 112) AS MonthID,
        COUNT([eKYC_DT]) AS #_Onboarding
    FROM  [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC]
    GROUP BY CONVERT(VARCHAR(6), [eKYC_DT], 112)
)

SELECT MonthID, #_Onboarding,
		LAG(#_Onboarding,1,0) OVER (ORDER BY MonthID) AS Previous_Month_Onboarding,
    IIF(LAG(#_Onboarding,1,0) OVER (ORDER BY MonthID) = 0,0
		, #_Onboarding - LAG(#_Onboarding,1,0) OVER (ORDER BY MonthID)) #_of_Different
FROM N
GROUP BY MonthID, #_Onboarding
ORDER BY MonthID;
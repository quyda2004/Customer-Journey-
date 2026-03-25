 SELECT CONVERT(varchar(6),F.eKYC_DT,112) EKYC_MONTH
		, F.Customer_ID , IIF(F.[Fraud_Type] ='FRAUD' AND [Account_Status] <> 'CLOSED',1,0) FRAUD_NOT_CLOSED
						, IIF(F.[Fraud_Type] ='RISK' AND [Account_Status] <> 'SUSPENDED',1,0) RISK_NOT_SUSPENDED
						, IIF(F.[Fraud_Type] = 'CHECKED' AND [Account_Status] <> 'ACTIVE',1,0) CHECKED_NOT_ACTIVE
						, IIF(T1.[Account_Number] IS NOT NULL,1,0) FRAUD_TRANSACTION
						, FRAUD_TRANSACTION_ID 
						, IIF(T2.[Account_Number] IS NOT NULL,1,0) RISK_TRANSACTION
						, RISK_TRANSACTION_ID
  FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
  LEFT JOIN (SELECT T.Account_Number, min([Transaction_ID]) FRAUD_TRANSACTION_ID--, count(*) TRANS_NO
			 FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T 
			 LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_POST_EKYC] P ON P.Fraud_Type = 'FRAUD' AND T.[Customer_ID] = P.[Customer_ID]
			 WHERE T.Transaction_DT >= P.PosteKYC_created_DT
			 GROUP BY T.Account_Number
			 ) T1 ON T1.Account_Number = F.Account_Number
  
  LEFT JOIN (SELECT T.Account_Number, min([Transaction_ID]) RISK_TRANSACTION_ID--, count(*) TRANS_NO
			 FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T 
			 LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_POST_EKYC] P ON P.Fraud_Type = 'RISK' AND T.[Customer_ID] = P.[Customer_ID]
			 LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTION_TYPE] TT ON TT.[Transaction_Type] = T.[Transaction_Type]
			 WHERE T.Transaction_DT >= P.PosteKYC_created_DT
			 AND TT.[Transaction_Group] = 'DEPOSIT'
			 GROUP BY T.Account_Number
			 ) T2 ON T2.Account_Number = F.Account_Number
			


--FOR CUSTOMER WITH FRAUD_TYPE IS 'RISK'
SELECT  CONVERT(varchar(6),T.[Transaction_DT],112) TRANS_MONTH, TT.[Transaction_Group], T.[Transaction_Type], T.[Transaction_Range], count(*) TRANS_CNT, sum([Transaction_Amount]) TRANS_AMT
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T 
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_POST_EKYC] P ON P.Fraud_Type = 'RISK' AND T.[Customer_ID] = P.[Customer_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTION_TYPE] TT ON TT.[Transaction_Type] = T.[Transaction_Type]
WHERE T.Transaction_DT >= P.PosteKYC_created_DT -- AND TT.[Transaction_Group] = 'DEPOSIT' --IF CONSIDERING FOR SEARCHING CUSTOMER WITH 'RISK' TYPE AND 'DEPOSIT' TRANSACTON.
GROUP BY CONVERT(varchar(6),T.[Transaction_DT],112), TT.[Transaction_Group], T.[Transaction_Type], T.[Transaction_Range]

--FOR CUSTOMER WITH RRAUD_TYPE IS 'FRAUD'
SELECT  CONVERT(varchar(6),T.[Transaction_DT],112) TRANS_MONTH, TT.[Transaction_Group], T.[Transaction_Type], T.[Transaction_Range], count(*) TRANS_CNT, sum([Transaction_Amount]) TRANS_AMT
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T 
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_POST_EKYC] P ON P.Fraud_Type = 'FRAUD' AND T.[Customer_ID] = P.[Customer_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTION_TYPE] TT ON TT.[Transaction_Type] = T.[Transaction_Type]
WHERE T.Transaction_DT >= P.PosteKYC_created_DT 
GROUP BY CONVERT(varchar(6),T.[Transaction_DT],112), TT.[Transaction_Group], T.[Transaction_Type], T.[Transaction_Range]
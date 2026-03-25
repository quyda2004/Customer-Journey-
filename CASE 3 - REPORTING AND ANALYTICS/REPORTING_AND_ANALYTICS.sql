
-- ================================= A - The customer onboarding journey =================================

-- CONVERSION RATE

  WITH N AS
(
SELECT C.[CRM_Channel], C.[CRM_Source], C.[App_ID], C.[Click_Ads_DT], C.[Install_App_DT]
	   , E.[eKYC_DT], E.[Customer_ID], F.[Account_Created_DT], F.[FIRST_TRANS]
	   , T.[LAST_TRANS]
	   --, F.[PosteKYC_created_DT], F.[KYC_DT]
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E ON C.[eKYC_ID] = E.[eKYC_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F ON E.[Customer_ID] = F.[Customer_ID]
LEFT JOIN (SELECT T1.[Customer_ID], MAX([Transaction_DT]) LAST_TRANS
		   FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T1
		   GROUP BY T1.[Customer_ID]) T ON F.[Customer_ID] = T.[Customer_ID]
)

SELECT [CRM_Channel], [CRM_Source]
	   , SUM(IIF([Click_Ads_DT] IS NOT NULL, 1, 0)) Num_of_Clicks
	   , SUM(IIF([Install_App_DT] IS NOT NULL, 1, 0)) Num_of_Install
	   , SUM(IIF([eKYC_DT] IS NOT NULL, 1, 0)) Num_of_eKYC
	   , SUM(IIF([Customer_ID] IS NOT NULL, 1, 0)) Num_of_Customer
	   , SUM(IIF([Account_Created_DT] IS NOT NULL, 1, 0)) Num_of_Acc
	   , SUM(IIF([FIRST_TRANS] IS NOT NULL, 1, 0)) Num_of_FirstTrns
	   --, SUM(IIF([PosteKYC_created_DT] IS NOT NULL, 1, 0)) Num_of_PosteKYC
	   --, SUM(IIF([KYC_DT] IS NOT NULL, 1, 0)) Num_of_KYC
	   , SUM(IIF(DATEDIFF(MONTH,[LAST_TRANS],'20230125') <= 2 , 1, 0)) Num_of_CurrentActive -- ASSUME sysdatetime() = '20230125'
FROM N
GROUP BY [CRM_Source], [CRM_Channel];


-- Latency

WITH N AS
(
SELECT C.[CRM_Channel], C.[CRM_Source]
		, DATEDIFF(DAY, C.[Click_Ads_DT], C.[Install_App_DT]) AS ClickAds_to_Install
		, DATEDIFF(DAY, C.[Install_App_DT], E.[eKYC_DT]) AS Install_to_eKYC
		, DATEDIFF(DAY, E.[eKYC_DT], F.[Account_Created_DT]) AS eKYC_to_Acc
		, DATEDIFF(DAY, F.[Account_Created_DT], F.[FIRST_TRANS]) AS Acc_to_Trns
		-- Measure the time from initiation to value creation for the business
		, DATEDIFF(DAY, C.[Click_Ads_DT], F.[FIRST_TRANS]) AS FirstClick_to_Value
		---- Measure the time from account creation to the point when the customer is requested to visit the branch for KYC (to assess system performance)
		--, DATEDIFF(DAY, F.[Account_Created_DT], F.[PosteKYC_created_DT]) AS Acc_to_PosteKYC
		---- Measure the time from the PosteKYC notification to the actual branch visit for completing KYC
		--, DATEDIFF(DAY, F.[PosteKYC_created_DT], F.[KYC_DT]) AS PosteKYC_to_KYC
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
 LEFT JOIN [dbo].[DIM_EKYC] E 
  ON C.eKYC_ID = E.eKYC_ID
  LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
  ON E.Customer_ID = F.Customer_ID
)

SELECT [CRM_Source], [CRM_Channel]
	   , AVG(ClickAds_to_Install) AVG_LAT_of_Click_to_Install
	   , AVG(Install_to_eKYC) AVG_LAT_of_Install_to_eKYC
	   , AVG(eKYC_to_Acc) AVG_LAT_of_eKYC_to_Acc
	   , AVG(Acc_to_Trns) AVG_LAT_of_Account_to_Trans
	   , AVG(FirstClick_to_Value) AVG_LAT_of_Click_to_Value
	   --, AVG(Acc_to_PosteKYC) AVG_LAT_of_Acc_to_PosteKYC
	   --, AVG(PosteKYC_to_KYC) AVG_LAT_of_PosteKYC_to_KYC

FROM N

GROUP BY [CRM_Source], [CRM_Channel];

--SLAs

WITH N AS
(
SELECT C.[CRM_Channel], C.[CRM_Source]
		, DATEDIFF(DAY, '20220101', C.[Click_Ads_DT]) AS StartCampaign_to_ClickAds
		, DATEDIFF(DAY, '20220101', C.[Install_App_DT]) AS StartCampaign_to_Install
		, DATEDIFF(DAY, '20220101', E.[eKYC_DT]) AS StartCampaign_to_eKYC
		, DATEDIFF(DAY, '20220101', F.[Account_Created_DT]) AS StartCampaign_to_Acc
		, DATEDIFF(DAY, '20220101', F.[FIRST_TRANS]) AS StartCampaign_to_FirstTrns
		--, DATEDIFF(DAY, '20220101', F.[KYC_DT]) AS StartCampaign_to_KYC
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
LEFT JOIN [dbo].[DIM_EKYC] E 
ON C.eKYC_ID = E.eKYC_ID
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
ON E.Customer_ID = F.Customer_ID
)

SELECT [CRM_Source], [CRM_Channel]
	   , AVG(StartCampaign_to_ClickAds) AVG_StartCampaign_to_ClickAds
	   , AVG(StartCampaign_to_Install) AVG_StartCampaign_to_Install
	   , AVG(StartCampaign_to_eKYC) AVG_StartCampaign_to_eKYC
	   , AVG(StartCampaign_to_Acc) AVG_StartCampaign_to_Acc
	   , AVG(StartCampaign_to_FirstTrns) AVG_StartCampaign_to_FirstTrns
	   --, AVG(StartCampaign_to_KYC) AVG_StartCampaign_to_KYC

FROM N

GROUP BY [CRM_Source], [CRM_Channel];



--========================================== B - PROFIT AND LOSS =================================================


--PROFIT
WITH N AS
(
SELECT [CRM_Source]
      ,[CRM_Channel]
	  , ISNULL(T.[Transaction_Group],'NO TRANS') [Transaction_Group]
	  , IIF(T.[Transaction_Group] ='TRANSFER', 0.01
			,IIF(T.[Transaction_Group] ='PAYMENT', 0.05
				,IIF(T.[Transaction_Group] ='DEPOSIT', 0.12, 0))) NIM
			 
      , ISNULL(SUM(AMT),0) TOTAL_TRANS_AMT
	  , (IIF(T.[Transaction_Group] ='TRANSFER', 0.01
			,IIF(T.[Transaction_Group] ='PAYMENT', 0.05
				,IIF(T.[Transaction_Group] ='DEPOSIT', 0.12, 0))))  * ISNULL(SUM(AMT),0) TOTAL_PROFIT
	  
  FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
  LEFT JOIN (
			  SELECT [Customer_ID], T2.[Transaction_Group], COUNT(*) CNT, SUM([Transaction_Amount]) AMT
			  FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T1
			  LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTION_TYPE] T2 
						ON T1.[Transaction_Type] = T2.[Transaction_Type]
			  GROUP BY [Customer_ID], T2.[Transaction_Group]
			  ) T ON F.[Customer_ID] = T.[Customer_ID]
  GROUP BY [CRM_Source]
		   ,[CRM_Channel]
		   , T.[Transaction_Group]
)

SELECT [CRM_Source], [CRM_Channel], SUM(TOTAL_TRANS_AMT) Total_Transaction_AMT, SUM(TOTAL_PROFIT) Total_Profit
FROM N
GROUP BY [CRM_Source], [CRM_Channel];

--LOSS
WITH N AS
(
SELECT C.[CRM_Source], C.[CRM_Channel]
	   --, C.[App_ID], C.[Click_Ads_DT], C.[Install_App_DT]
	   --, E.[eKYC_DT], E.[Customer_ID], P.[Account_Created_DT], P.[FIRST_TRANS]
	   , IIF(P.[FIRST_TRANS] IS NOT NULL, 'TRANS'
			, IIF(P.[Account_Created_DT] IS NOT NULL, 'ACCOUNT'
				, IIF(E.[Customer_ID] IS NOT NULL, 'CUSTOMER'
					 , IIF(E.[eKYC_DT] IS NOT NULL, 'EKYC'
						   , IIF(C.[Install_App_DT] IS NOT NULL, 'INSTALL'
								, IIF( C.[Click_Ads_DT] IS NOT NULL, 'CLICK',NULL)))))) STAGE 
	   , SUM(IIF(P.[FIRST_TRANS] IS NOT NULL,  M.[Stage_6]
			, IIF(P.[Account_Created_DT] IS NOT NULL, M.[Stage_5]
				, IIF(E.[Customer_ID] IS NOT NULL, M.[Stage_4]
					 , IIF(E.[eKYC_DT] IS NOT NULL, M.[Stage_3]
						   , IIF(C.[Install_App_DT] IS NOT NULL, M.[Stage_2]
								, IIF( C.[Click_Ads_DT] IS NOT NULL, M.[Stage_1],0.000)))))) * 1000) ACQUISITION_COST 
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E ON C.[eKYC_ID] = E.[eKYC_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] P ON E.[Customer_ID] = P.[Customer_ID]
LEFT JOIN (
			 SELECT [Type_]
				  ,[Key_]
				  ,CAST([Stage_1] AS FLOAT) [Stage_1]
				  ,CAST([Stage_2] AS FLOAT) [Stage_2]
				  ,CAST([Stage_3] AS FLOAT) [Stage_3]
				  ,CAST([Stage_4] AS FLOAT) [Stage_4]
				  ,CAST([Stage_5] AS FLOAT) [Stage_5]
				  ,CAST([Stage_6] AS FLOAT) [Stage_6]
			  FROM [DATA_WAREHOUSE_Layer].[dbo].[MAPPING]
			  WHERE TYPE_ = 'COST'
		) M ON M.KEY_ =  C.[CRM_Channel]

GROUP BY C.[CRM_Source], C.[CRM_Channel]
		 , IIF(P.[FIRST_TRANS] IS NOT NULL, 'TRANS'
			, IIF(P.[Account_Created_DT] IS NOT NULL, 'ACCOUNT'
				, IIF(E.[Customer_ID] IS NOT NULL, 'CUSTOMER'
					 , IIF(E.[eKYC_DT] IS NOT NULL, 'EKYC'
						   , IIF(C.[Install_App_DT] IS NOT NULL, 'INSTALL'
								, IIF( C.[Click_Ads_DT] IS NOT NULL, 'CLICK',NULL)))))) 
)

SELECT [CRM_Source], [CRM_Channel]
		, 12 RUNNING_TIME
	    , IIF([CRM_Channel] ='Partnership', 80000000
			,IIF([CRM_Channel] ='Ecosystem', 100000000
				,IIF([CRM_Channel] ='Telesale', 50000000
					,IIF([CRM_Channel] ='Digital Direct Sale', 20000000
						,IIF([CRM_Channel] ='RB', 0, 0))))) BASE_PAYMENT
		
		, ISNULL(MAX(CASE WHEN [STAGE] = 'CLICK' THEN ACQUISITION_COST END),0) CLICK_COST
		, ISNULL(MAX(CASE WHEN [STAGE] = 'INSTALL' THEN ACQUISITION_COST END),0) INSTALL_COST
		, ISNULL(MAX(CASE WHEN [STAGE] = 'EKYC' THEN ACQUISITION_COST END),0) EKYC_COST
		, ISNULL(MAX(CASE WHEN [STAGE] = 'CUSTOMER' THEN ACQUISITION_COST END),0) CUSTOMER_COST
		, ISNULL(MAX(CASE WHEN [STAGE] = 'ACCOUNT' THEN ACQUISITION_COST END),0) ACCOUNT_COST
		, ISNULL(MAX(CASE WHEN [STAGE] = 'TRANS' THEN ACQUISITION_COST END),0) TRANS_COST

		--, CASE WHEN [STAGE] = 'CLICK' THEN SUM(ACQUISITION_COST) END CLICK_COST
		--, CASE WHEN [STAGE] = 'INSTALL' THEN SUM(ACQUISITION_COST) END INSTALL_COST
		--, CASE WHEN [STAGE] = 'EKYC' THEN SUM(ACQUISITION_COST) END EKYC_COST
		--, CASE WHEN [STAGE] = 'CUSTOMER' THEN SUM(ACQUISITION_COST) END CUSTOMER_COST
		--, CASE WHEN [STAGE] = 'ACCOUNT' THEN SUM(ACQUISITION_COST) END ACCOUNT_COST
		--, CASE WHEN [STAGE] = 'TRANS' THEN SUM(ACQUISITION_COST) END TRANS_COST
		, (SUM(ACQUISITION_COST) +  
			IIF([CRM_Channel] ='Partnership', 80000000
				,IIF([CRM_Channel] ='Ecosystem', 100000000
					,IIF([CRM_Channel] ='Telesale', 50000000
						,IIF([CRM_Channel] ='Digital Direct Sale', 20000000
							,IIF([CRM_Channel] ='RB', 0, 0)))))*12) TOTAL_COST
	   
FROM N
GROUP BY [CRM_Source], [CRM_Channel];




----------------------CALCULATE PROFIT AND LOSS-----------------------


--A.TOTAL_PROFIT

--Calculate Profit for each Transaction_Group 
WITH PROFIT AS
(
SELECT [CRM_Source]
      ,[CRM_Channel]
	  , ISNULL(T.[Transaction_Group],'NO TRANS') [Transaction_Group]
	  , IIF(T.[Transaction_Group] ='TRANSFER', 0.01
			,IIF(T.[Transaction_Group] ='PAYMENT', 0.05
				,IIF(T.[Transaction_Group] ='DEPOSIT', 0.12, 0))) NIM
			 
      , ISNULL(SUM(AMT),0) TOTAL_TRANS_AMT
	  , (IIF(T.[Transaction_Group] ='TRANSFER', 0.01
			,IIF(T.[Transaction_Group] ='PAYMENT', 0.05
				,IIF(T.[Transaction_Group] ='DEPOSIT', 0.12, 0))))  * ISNULL(SUM(AMT),0) TOTAL_PROFIT
	  
  FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
  LEFT JOIN (
			  SELECT [Customer_ID], T2.[Transaction_Group], COUNT(*) CNT, SUM([Transaction_Amount]) AMT
			  FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T1
			  LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTION_TYPE] T2 
						ON T1.[Transaction_Type] = T2.[Transaction_Type]
			  GROUP BY [Customer_ID], T2.[Transaction_Group]
			  ) T ON F.[Customer_ID] = T.[Customer_ID]
  GROUP BY [CRM_Source]
		   ,[CRM_Channel]
		   , T.[Transaction_Group]
)

--Calculate Total_Profit
, TOTAL_PROFIT AS
(
SELECT [CRM_Source], [CRM_Channel], SUM(TOTAL_TRANS_AMT) Total_Transaction_AMT, SUM(TOTAL_PROFIT) Total_Profit
FROM PROFIT
GROUP BY [CRM_Source], [CRM_Channel]
)


--B.TOTAL_COST

--Calculate ACQUISITION_COST
, ACQUISITION_COST AS
(
SELECT C.[CRM_Source], C.[CRM_Channel]
	   --, C.[App_ID], C.[Click_Ads_DT], C.[Install_App_DT]
	   --, E.[eKYC_DT], E.[Customer_ID], P.[Account_Created_DT], P.[FIRST_TRANS]
	   , IIF(P.[FIRST_TRANS] IS NOT NULL, 'TRANS'
			, IIF(P.[Account_Created_DT] IS NOT NULL, 'ACCOUNT'
				, IIF(E.[Customer_ID] IS NOT NULL, 'CUSTOMER'
					 , IIF(E.[eKYC_DT] IS NOT NULL, 'EKYC'
						   , IIF(C.[Install_App_DT] IS NOT NULL, 'INSTALL'
								, IIF( C.[Click_Ads_DT] IS NOT NULL, 'CLICK',NULL)))))) STAGE 
	   , SUM(IIF(P.[FIRST_TRANS] IS NOT NULL,  M.[Stage_6]
			, IIF(P.[Account_Created_DT] IS NOT NULL, M.[Stage_5]
				, IIF(E.[Customer_ID] IS NOT NULL, M.[Stage_4]
					 , IIF(E.[eKYC_DT] IS NOT NULL, M.[Stage_3]
						   , IIF(C.[Install_App_DT] IS NOT NULL, M.[Stage_2]
								, IIF( C.[Click_Ads_DT] IS NOT NULL, M.[Stage_1],0.000)))))) * 1000) Acquisition_Cost 
FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_CRM] C
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[DIM_EKYC] E ON C.[eKYC_ID] = E.[eKYC_ID]
LEFT JOIN [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] P ON E.[Customer_ID] = P.[Customer_ID]
LEFT JOIN (
			 SELECT [Type_]
				  ,[Key_]
				  ,CAST([Stage_1] AS FLOAT) [Stage_1]
				  ,CAST([Stage_2] AS FLOAT) [Stage_2]
				  ,CAST([Stage_3] AS FLOAT) [Stage_3]
				  ,CAST([Stage_4] AS FLOAT) [Stage_4]
				  ,CAST([Stage_5] AS FLOAT) [Stage_5]
				  ,CAST([Stage_6] AS FLOAT) [Stage_6]
			  FROM [DATA_WAREHOUSE_Layer].[dbo].[MAPPING]
			  WHERE TYPE_ = 'COST'
		) M ON M.KEY_ =  C.[CRM_Channel]

GROUP BY C.[CRM_Source], C.[CRM_Channel]
		 , IIF(P.[FIRST_TRANS] IS NOT NULL, 'TRANS'
			, IIF(P.[Account_Created_DT] IS NOT NULL, 'ACCOUNT'
				, IIF(E.[Customer_ID] IS NOT NULL, 'CUSTOMER'
					 , IIF(E.[eKYC_DT] IS NOT NULL, 'EKYC'
						   , IIF(C.[Install_App_DT] IS NOT NULL, 'INSTALL'
								, IIF( C.[Click_Ads_DT] IS NOT NULL, 'CLICK',NULL)))))) 
)

--Aggregate ACQUISITION_COST for each Source and Channel
, AGGREGATED_COST AS 
(
SELECT [CRM_Source], [CRM_Channel], SUM(Acquisition_Cost) AS Acquisition_Cost_Total
FROM ACQUISITION_COST
GROUP BY [CRM_Source], [CRM_Channel]
)

--BASE_PAYMENT
, BASE_PAYMENT AS 
(
SELECT 
        [CRM_Source], 
        [CRM_Channel],
        IIF([CRM_Channel] = 'Partnership', 80000000,
            IIF([CRM_Channel] = 'Ecosystem', 100000000,
                IIF([CRM_Channel] = 'Telesale', 50000000,
                    IIF([CRM_Channel] = 'Digital Direct Sale', 20000000,
                        IIF([CRM_Channel] = 'RB', 0, 0)
                    )
                )
            )
        ) AS Base_Payment,
		Acquisition_Cost_Total
FROM AGGREGATED_COST
)

--Calculate Total_Cost
, TOTAL_COST AS
(
SELECT  [CRM_Source], [CRM_Channel]
		, Base_Payment * 12 + Acquisition_Cost_Total AS Total_Cost
FROM BASE_PAYMENT
)


--C.CUSTOMER_ACTIVE
, CUSTOMER_ACTIVE AS 
(
SELECT [CRM_Source], [CRM_Channel], COUNT([Customer_ID]) AS Active_Customers
FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES]
WHERE [FIRST_TRANS] IS NOT NULL
GROUP BY [CRM_Source], [CRM_Channel]
)


--PROFIT AND LOSS
SELECT TP.[CRM_Source], TP.[CRM_Channel], TP.Total_Transaction_AMT, TP.Total_Profit, TC.Total_Cost
		, (TP.Total_Profit - TC.Total_Cost) Net_Profit,
		CASE 
			WHEN TC.Total_Cost = 0 THEN NULL
			ELSE ROUND((TP.Total_Profit - TC.Total_Cost) * 1.0 / TC.Total_Cost / 100, 5)
		END AS ROI_Percent
		, CA.Active_Customers
FROM TOTAL_PROFIT TP
FULL JOIN TOTAL_COST TC
ON TP.[CRM_Source] = TC.[CRM_Source]
AND TP.[CRM_Channel] = TC.[CRM_Channel]
FULL JOIN CUSTOMER_ACTIVE CA
ON TP.[CRM_Source] = CA.[CRM_Source]
AND TP.[CRM_Channel] = CA.[CRM_Channel];




--=======================================Customer Lifetime Value===============================================

DROP TABLE TMP_CUSTOMER_LIFETIME_DASHBOARD;

--- [Channel] - [Source] - [Customer_ID] - [Total Transaction No] - [Total Transaction Amt] - [LIFE_SPAN] - [Gross Profit Margin] 
SELECT [CRM_Channel] [Channel], [CRM_Source] [Source], F.[Customer_ID]
		, ISNULL([TRANS_CNT],0) [Total Transaction No], ISNULL([TRANS_AMT],0) [Total Transaction Amt]
		, ISNULL(T.[LIFE_SPAN]+1,0) [LIFE_SPAN]
		, M.[Stage_2] [Gross Profit Margin]
INTO TMP_CUSTOMER_LIFETIME_DASHBOARD		
FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
LEFT JOIN (SELECT Customer_ID, DATEDIFF(DAY, MIN([Transaction_DT]), MAX([Transaction_DT])) LIFE_SPAN
		   FROM  [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] 
		   GROUP BY Customer_ID
		   ) T ON F.[Customer_ID] = T.[Customer_ID]
LEFT JOIN MAPPING M ON M.[Key_] = F.[CRM_Source] 
					AND M.[Stage_1] = F.[CRM_Channel]
					AND M.[Type_] = 'GMP'


-- APV = Total Transaction Amt/ Total Transaction No for each customer
--ALTER TABLE TMP_CUSTOMER_LIFETIME_DASHBOARD
--ADD APV float; ----Create First

UPDATE TMP_CUSTOMER_LIFETIME_DASHBOARD
SET APV = (CAST([Total Transaction Amt] AS FLOAT)/IIF([Total Transaction No]=0,1,[Total Transaction No]));


-- APFR = Total # of Transaction / Total # Customer No = 0.296374904491043
DECLARE @APFR FLOAT;

SET @APFR = (
			  SELECT CAST(SUM([Total Transaction No]) AS FLOAT)/COUNT(DISTINCT [Customer_ID])
			  FROM TMP_CUSTOMER_LIFETIME_DASHBOARD);


--CV = APV * APFR
--ALTER TABLE TMP_CUSTOMER_LIFETIME_DASHBOARD
--ADD CV float; ------Create First

UPDATE TMP_CUSTOMER_LIFETIME_DASHBOARD
SET CV = APV * @APFR


-- Churn Rate = 1 – (Total # of Customers with >= 2 / Total # of customers) = 0.965998811444095
DECLARE @CR FLOAT;

SET @CR= (
			SELECT 1 - CAST(SUM(CASE WHEN [TRANS_CNT] >= 2 THEN 1 END) AS FLOAT)/COUNT(DISTINCT [CUSTOMER_ID])
			FROM [FACT_DIGITAL_PROFILES]);

-- CLV = CV * GM / CR
--ALTER TABLE TMP_CUSTOMER_LIFETIME_DASHBOARD
--ADD CLV float; ------Create First

UPDATE TMP_CUSTOMER_LIFETIME_DASHBOARD
SET [CLV] =  (CAST([CV] * [Gross Profit Margin] AS FLOAT)/@CR) 


-- Channel - Source - AVG of CLV - Customer ID - CLV (Descending Sort) - Diff to AVG - Rank
SELECT [Channel], [Source], avg(CLV) over(partition by [Channel], [Source]) [AVG of CLV], [Customer_ID], [CLV]
		, ([CLV] - avg(CLV) over(partition by [Channel], [Source])) [Diff to AVG] -- Calculate the difference between each customer's CLV and the average CLV within the same Channel-Source group.
		, RANK() OVER (PARTITION BY [Channel], [Source] ORDER BY [CLV] DESC) RANK_BY_CHANNEL_SOURCE
FROM TMP_CUSTOMER_LIFETIME_DASHBOARD
ORDER BY [Channel], [Source], CLV DESC



-- ================================= D - TURN OVER  =================================

DROP TABLE TMP_TURN_OVER;

WITH N AS
(
	SELECT [Customer_ID], [TRANSACTION_DT]
			, ROW_NUMBER() OVER (PARTITION BY [Customer_ID] ORDER BY [TRANSACTION_DT]) ROW_
			, MAX([TRANSACTION_DT]) OVER (PARTITION BY [Customer_ID]) [LAST_TRANS]
	FROM [DATA_WAREHOUSE_Layer].[dbo].[DIM_TRANSACTIONS] T
)

SELECT [CRM_Channel], [CRM_Source], F.[Customer_ID]
		, DATEDIFF(MONTH,[Account_Created_DT],[FIRST_TRANS]) MONTHS_TO_FT
		, DATEDIFF(MONTH,[FIRST_TRANS],[TRANSACTION_DT]) MONTHS_TO_ST
		, DATEDIFF(MONTH,[FIRST_TRANS],[LAST_TRANS]) LIFE_SPAN
		, [LAST_TRANS]
INTO TMP_TURN_OVER	
FROM [DATA_WAREHOUSE_Layer].[dbo].[FACT_DIGITAL_PROFILES] F
LEFT JOIN N N1 ON N1.ROW_ = 2 -- Choose the second transaction of customer to calculate MONTH_TO_ST
			   AND F.[Customer_ID] = N1.[Customer_ID] 
WHERE [FIRST_TRANS] IS NOT NULL;


SELECT [CRM_Channel], [CRM_Source]
	   , COUNT(DISTINCT [Customer_ID]) [NO_OF_CUSTOMERS]
	   , AVG(LIFE_SPAN) [AVG_LIFE_SPAN]
	   , SUM(IIF(MONTHS_TO_FT<3,1,0)) [# trans in first 3 months]
	   , SUM(IIF(MONTHS_TO_ST<1,1,0)) [# trans in 1 month after first]
	   , SUM(IIF(LIFE_SPAN >= 6,1,0)) [# trans in 6 month after first]
FROM TMP_TURN_OVER
GROUP BY [CRM_Channel], [CRM_Source];
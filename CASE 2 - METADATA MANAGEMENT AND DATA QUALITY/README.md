## 1. Introduction

In the second part, I delve deeper into the customer onboarding process — from the initial engagement with the program to the post-onboarding evaluation phase — to ensure that all relevant data attributes are clearly identified for building a scalable and flexible data model. Additionally, it is essential that the collected data meets four key criteria: accuracy, validity, consistency, and timeliness.

## 2. Create Schema and Filter Data

Before proceeding with this step, please refer to the Business Analyst's documentation ([Source_Target_Mapping](https://github.com/quachquoccuong2904/Customer-Journey/blob/main/CASE%202%20-%20METADATA%20MANAGEMENT%20AND%20DATA%20QUALITY/Source-Target_Mapping.xlsx)) to gain a clear understanding of the data creation and filtering process.

### 2.1. Create Schema for Staging Zone

<img width="1117" height="644" alt="Image" src="https://github.com/user-attachments/assets/09d3061d-9f86-4686-acbb-0a1ab650e85f" />

Data flow from the Source Layer into the Staging Zone, with the purpose of standardizing the data into a consistent state, making it easier for users to track the data flow.

### 2.2. Create Schema for Reconciliaton Zone

<img width="1069" height="749" alt="Image" src="https://github.com/user-attachments/assets/c63ebfb4-b47a-47c7-a15e-176880259314" />

At this layer, all data has been standardized and is ready for analytical use. To effectively support the customer journey, I need to design a suitable Data Warehouse layer that ensures scalability, fast data access, and accurate decision-making support:

| Tables | Description |
| --- | --- |
| [dbo].[DIM_CRM] | Customer information in CRM System |
| [dbo].[DIM_EKYC] | Customer eKYC process information |
| [dbo].[DIM_ACCOUNTS] | Customer account information |
| [dbo].[DIM_TRANSACTIONS] | Customer transaction information |
| [dbo].[DIM_TRANSACTION_TYPE] | Defined transaction types |
| [dbo].[DIM_POST_EKYC] | Customer post-eKYC process information |
| [dbo].[FACT_DIGITAL_PROFILES] | Customer Profile information |

### 2.3. Filter Data for each Zone

In addition to tables with direct mappings (1-1 mapping), several other tables must be processed and filtered based on business needs and logic based on Source_Target_Mapping:

- [dbo].[STAGING_Digital_Account]
- [dbo].[STAGING_Digital_Transaction]
- [dbo].[STAGING_eKYC_Information]
- [dbo].[DIM_TRANSACTION_TYPE]
- [dbo].[FACT_DIGITAL_PROFILES]

## 3. Intergrate data by using ETL Tools:

To perform this step, I used an ETL tool - SQL Server Integration Services (SSIS) - within the Visual Studio environment.

<img width="776" height="304" alt="Image" src="https://github.com/user-attachments/assets/d4a001f1-6c78-4d77-825d-1c42b7afe447" />

Several issues were encountered during the process:

**STAGING_Post_eKYC:**
The `IS_KYC` column is currently in Unicode String format (DT_WSTR), whereas the destination requires it in String format (DT_STR). Therefore, a conversion step is necessary, using Code Page 1252 (ANSI - Latin I).

<img width="303" height="280" alt="Image" src="https://github.com/user-attachments/assets/755c73c1-3508-4461-8c3f-729976d1ad7c" />

**STAGING_Transactions:**
The `Transaction_Range` column is currently in String format (DT_STR) at the Source, whereas the Destination requires it in Unicode String format (DT_WSTR). Therefore, a conversion step is necessary to ensure compatibility with the destination schema.

<img width="317" height="253" alt="Image" src="https://github.com/user-attachments/assets/66b5df72-12fd-474f-b68a-acf8d680f4c7" />

## 4. Data Quality

To ensure the data is suitable for analysis, reporting, and prediction tasks, I need to perform data quality control after the ETL process.

### 4.1. Completeness and Validity:

- I need to clarify the following questions:
    - What is the number of columns and rows in all tables?
    - Do the data types match what is defined in the documentation?
    - Are there any data entries that violate predefined limit ranges?
- To perform this validation, I use two main actions:
    - **Create and query the `INFORMATION_SCHEMA`**: A set of system views that allow us to retrieve information about the database structure (e.g., number of columns, data types, etc.).
    - **Use SQL Server `CURSOR`**: Enables iteration through each row of data to check for validity or completeness based on custom logic.

[Link to code](https://github.com/quachquoccuong2904/Customer-Journey/blob/main/CASE%202%20-%20METADATA%20MANAGEMENT%20AND%20DATA%20QUALITY/Data%20Quality/Completeness%20and%20Validity.sql)

<img width="1591" height="466" alt="Image" src="https://github.com/user-attachments/assets/e905dc3a-ca18-4874-a712-5fab820a3fdd" />

### 4.2. Accuracy:

- A common issue during the customer eKYC process is the discrepancy between the information filled in by the OCR system (OCR_Information) and the data manually entered by the customer (INPUT_Information), as well as insufficient scoring indicators (Scoring).
- These issues may stem from the following reasons:
    - Customers may intentionally or unintentionally enter incorrect information.
    - The eKYC process of the system might have technical problems, resulting in some customers with invalid eKYC data still being approved.
- To address these issues, I need to examine the following indicators:
    - IS_TIME_ALERT: If the process timestamps do not follow the correct order —
        
        `[Click_ads_DT] < [Install_App_DT] < [eKYC_DT] < [Account_Created_DT] < [FIRST_TRANS]` — then mark as 1 (violation); otherwise, mark as 0 (compliant).
        
    - IS_SCORE_ALERT: All scoring values must be greater than 0.85 (`Scoring > 0.85`).
    - IS_INFO_ALERT: Compare `OCR_Information` and `INPUT_Information` to detect any inconsistencies.
    - IS_CATEGORY_ALERT: Check whether any account category falls outside of the accepted values ‘1001’ and ‘1002’.

[Link to code](https://github.com/quachquoccuong2904/Customer-Journey/blob/main/CASE%202%20-%20METADATA%20MANAGEMENT%20AND%20DATA%20QUALITY/Data%20Quality/Accuracy.sql)

<img width="1402" height="390" alt="Image" src="https://github.com/user-attachments/assets/596b5a75-5af4-4f5f-b8d8-538e86739a1d" />

**Remarks:** 

- We can conclude that there are no violations in IS_INFO_ALERT and IS_CATEGORY_ALERT, indicating that the information captured by the OCR system and the data entered by users show no discrepancies. In addition, all customers have valid account types ('1001' and '1002').
- However, there are 848 cases of IS_TIME_ALERT and 2,346 cases of IS_SCORE_ALERT.
- Although the OCR system appears to be functioning properly in terms of capturing basic information (as there are no IS_INFO_ALERT or IS_CATEGORY_ALERT flags), the relatively high proportion of IS_SCORE_ALERT (4–5%) suggests that a review of input factors affecting the scoring mechanism is necessary. This includes the possibility that OCR may not be extracting sufficient or accurate data for proper scoring — especially in cases involving unclear, incomplete, or improperly formatted documents.

### 4.3. Consistency:

- A potential risk during the period between account creation and the system's classification of `Fraud_Type` is that customers labeled as FRAUD or RISK may still have time to perform unauthorized or malicious activities, potentially causing losses to the business. To assess the impact of this inconsistency, I need to carry out the following steps:
    - Identify the types of alerts and evaluate system effectiveness:
        - FRAUD_NOT_CLOSED: Fraud cases that have not been properly resolved.
        - RISK_NOT_SUSPENDED: Risk accounts that have not been suspended.
        - CHECKED_NOT_ACTIVE: Customers who have been reviewed but not yet deactivated.
    - Determine the total number of fraudulent and risky transactions carried out during this gap period.
    - Measure the monetary value (or impact) of those risky and fraudulent transactions.

[Link to code](https://github.com/quachquoccuong2904/Customer-Journey/blob/main/CASE%202%20-%20METADATA%20MANAGEMENT%20AND%20DATA%20QUALITY/Data%20Quality/Consistency.sql)

For the data obtained from the query above and using an Excel Pivot Table, we have the following report:

<img width="690" height="228" alt="Image" src="https://github.com/user-attachments/assets/275808e3-9ea8-4b03-ae8d-19718dab8649" />

<img width="1298" height="991" alt="Image" src="https://github.com/user-attachments/assets/20f445f7-e73f-4f60-aa94-6e8d0e551b30" />

<img width="1652" height="988" alt="Image" src="https://github.com/user-attachments/assets/54d40b8f-a545-415c-9f38-85ccbc416156" />

**Remarks:**

Overall, the post-eKYC system does not overlook any violations; however, it fails to immediately block accounts or reactivate them only after thorough verification.

Regarding the impact in terms of violation counts and transaction value:

- A total of 1,334 fraudulent transactions were detected, of which 1,202 (approximately 90%) occurred on the first attempt. This indicates that most fraudulent transactions are executed immediately upon account creation.

- Additionally, there were 85 “DEPOSIT” transactions associated with RISK-level fraud cases, with 83 of them (~98%) taking place during the first attempt. This suggests that nearly all violations in these cases occur right from the first transaction.

## 1. Introduction

After completing the eKYC process, tracking customers’ transaction behaviors plays a crucial role in minimizing potential losses and risks for the bank. In addition, I evaluate the performance of the verification system to identify weaknesses in the fraud detection process and address critical vulnerabilities. Finally, I propose building a classification model to detect potentially fraudulent behaviors—this provides a proactive solution to identify suspicious patterns early and implement effective preventive measures.

## 2. Performance of Vertification

## 2.1. Evaluate Old Prediction Algorithm

In traditional algorithms, fraud prediction is typically based on the principle of flagging a violation if there is any discrepancy in the information and the score falls below **0.85**. After analyzing the system’s prediction capability, the following results were obtained:

<img width="1543" height="69" alt="Image" src="https://github.com/user-attachments/assets/f7caaaf0-c600-463b-8e3a-d0a7d87c93f3" />

<img width="1541" height="68" alt="Image" src="https://github.com/user-attachments/assets/476ba270-d75c-40b4-9157-520f249bd2e9" />

- Specifically, for the thresholds representing discrepancies in information, both **Precision** and **Recall** are 0% in the groups with a value of `1`. In contrast, in the groups with a value of `0`, Precision consistently reaches **83.48%** and Recall is **100%**.
- This indicates that fraud prediction based on information consistency works well for non-fraudulent customers when the information matches. However, the model fails to identify fraudulent cases when discrepancies in information are present.
- Furthermore, for the groups with a value of `1`, Precision is only around **16.7–17.4%** and Recall is approximately **4.2–4.4%**, showing that the model is very weak in detecting fraud in cases involving eKYC errors.

## 2.2. Actual Lost

- This reflects the actual amount of money transacted by fraudulent actors that cannot be recovered. While it does not cause any direct financial loss to the bank’s asset value, it serves as a warning of the potential risks and weaknesses in the bank’s fraud control mechanisms. This amount is calculated for the period between the creation of the account and the point at which the system identifies and labels it as fraudulent. Recording the transactions carried out during this period allows the bank to assess the extent of the damage and its impact. In this analysis, I will examine the issue from three perspectives:
    - Actual Lost by Transaction Type
    - Actual Lost by Transaction Range
    - Actual Lost by Source & Channel

<img width="2161" height="1412" alt="Image" src="https://github.com/user-attachments/assets/f218e32c-224b-4827-8ebf-06845ab56ca0" />

<img width="2755" height="1695" alt="Image" src="https://github.com/user-attachments/assets/e1084315-a847-497e-88a0-613869380b4f" />

<img width="3215" height="1540" alt="Image" src="https://github.com/user-attachments/assets/60088699-454f-429c-afd5-2ed4217f4adb" />

<img width="1281" height="294" alt="Image" src="https://github.com/user-attachments/assets/6e94e490-c063-4d17-aa9d-56e830d97483" />

The results indicate that:

- The **DEPOSIT** group (OpenDeposit, TopUpAccount) and **PAYMENT** group (FacePay, BillPayment) account for the highest losses. Fraudsters typically target high-value transactions (**HIGH**) to maximize the amount they can exploit.
- Additionally, **RB** and **Telesale** are the two sources with the highest losses as well as the largest number of transactions (Telesale: 329 transactions, RB: 317 transactions), with the majority falling into the **HIGH** segment. Although **CASHBAG** recorded only 64 fraudulent transactions, it caused a relatively high loss (approximately VND 24.2 billion).
- These findings are concerning, as RB and Telesale initially demonstrated strong growth potential and, notably, were among the top revenue-generating sources for the bank.

### 2.3. Potential of Onboarding Journey

Over the course of the one-year campaign, the volume of onboarding activities steadily increased, with certain stages experiencing even sharper growth. This trend can be considered positive for the bank, as it demonstrates that the campaign has attracted significant attention. However, bottlenecks in the verification and assessment stages of the eKYC process have created challenges in accurately identifying which individuals are genuine customers of the bank.

<img width="2213" height="1095" alt="Image" src="https://github.com/user-attachments/assets/7ff0b155-4aa7-4ccf-add4-89bb98fe0e02" />

## 3. Build Fraud Prediction Model

After evaluating the effectiveness of the customer journey campaign, it is evident that the customer verification system has not been performing well in identifying non-compliant customers, resulting in significant losses. In the future, without measures to mitigate this risk, the organization could face more severe consequences, such as loss of reputation and customer trust, long-term negative impacts on business operations, or even violations of legal and compliance requirements. Therefore, developing a fraud prediction model is essential to minimize the risks posed by fraudulent actors.

In the final stage, I begin developing the model, with all components consolidated in the final report: [FRAUD_PREDICTION_FINAL](https://github.com/quachquoccuong2904/Customer-Journey/blob/main/CASE%204%20-%20FRAUD%20PREDICTION/FRAUD_PREDICTION_FINAL.ipynb), including the process description, data processing, algorithm selection, and final evaluation.




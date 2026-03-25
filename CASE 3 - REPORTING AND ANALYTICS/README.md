## 1. Introduction

After launching the campaign, our bank needs to measure overall performance by tracking key performance indicators (KPIs). This includes evaluating the effectiveness of each advertising channel in attracting new customers, analyzing the performance of the eKYC and post-eKYC systems to identify potential bottlenecks in the identity verification process, and conducting customer behavior analysis. These insights allow us to refine our targeting strategy, optimize marketing costs, enhance user experience, and improve the conversion rate throughout the onboarding journey.

## 2. Conversion Rate

- To evaluate the performance of each Source & Channel, I measure the conversion rate at key stages of the onboarding process. These stages are outlined in the table below for reference:

    | **Stage** | **Description** |
    | --- | --- |
    | Click_Ads | Total number of ad clicks recorded |
    | Install | Number of customers who downloaded the app /  Total number of ad clicks recorded |
    | eKYC | Number of customers who completed eKYC / Number of customers who downloaded the app |
    | Customer | Number of customers who successfully completed eKYC and became official customers / Number of customers who completed eKYC |
    | Account | Number of customers who opened an account / Number of official customers |
    | First Trans | Number of customers who made their first transaction / Number of customers who opened an account |
    | Current Active | Total number of customers who remained active within 2 months |
- The analysis indicates that:
    
    <img width="1683" height="406" alt="Image" src="https://github.com/user-attachments/assets/679c30c9-3261-4e87-8009-9a64ed0338b9" />
    
    - Telesale and RB are the two sources with the best performance, showing high and stable conversion rates across all stages, from ad clicks to active transacting customers. The Ecosystem group also maintains relatively good performance. Meanwhile, Digital Direct Sale channels (such as Facebook, Google, AccessTrade) have a large number of clicks but low conversion rates. Partnership channels like MOMO, FPT PLAY, and CASHBAG show weak performance, especially starting from the account opening stage.
    - Overall, the system recorded around 108,000 ad clicks, which then dropped by more than 16,000 users at the app installation step, and nearly 25,000 more at the eKYC step. The number continued to decline gradually, leaving only around 13,000 users who made their first transaction. The most significant drop occurred at the first two stages: *Click Ads → Install* and *Install → eKYC*. The later stages still experienced some decline, but at a slower rate, indicating that once users complete eKYC, they are relatively more likely to continue through the onboarding process and make an actual transaction.
    
    <img width="3794" height="1816" alt="Image" src="https://github.com/user-attachments/assets/8710ddaf-41e5-4a21-93fa-ba648d0acf58" />
    
- I also provided an additional analysis on Customer Flow, aiming to break down the conversion rate across each stage. This analysis is divided into three levels:
    - Easy: Gives an overall view of the customer journey.
    - Yearly Tracking: Measures performance across different periods within the year.
    - Detailed Stage Breakdown: Specifies how many customers were recorded at each stage within 30, 60, 90, or more than 90 days.

    <img width="983" height="533" alt="Image" src="https://github.com/user-attachments/assets/eca39d3a-4ea6-43a0-ab23-8fe2a098908b" />

- In addition, to assess the conversion time across different channels, I have compiled a summary table showing the latency (the time delay between each stage) and the SLAs (Service Level Agreements), as presented in the table below:

    <img width="1243" height="432" alt="Image" src="https://github.com/user-attachments/assets/7d12784b-6829-4044-98e9-74333580d368" />

## 3. Profit and Loss

- This analysis is measured on each Source & Channel, with calculation metrics defined and issued by the bank. I need to rely on those metrics to calculate profit and loss per channel.
- For revenue from each transaction, it is calculated based on the Net Interest Margin (NIM) of each Transaction Group.

    | **Transaction Group** | **NIM (%)** |
    | --- | --- |
    | TRANSFER | 1 |
    | PAYMENT | 5 |
    | DEPOSIT | 10 |
- The costs that the bank must pay for various sources include infrastructure costs and advertising costs corresponding to the current stage of the customer:
    
    <img width="682" height="386" alt="Image" src="https://github.com/user-attachments/assets/f00bf931-7e60-42bc-9e20-99328de5e1f5" />
    
- The information I need to review includes:
    
    
    | **Field** | **Description** |
    | --- | --- |
    | CRM_Source | Source |
    | CRM_Channel | Channel |
    | Total Profit | Total Profit |
    | Total Cost | Total Cost |
    | Net Profit | Total Profit - Total Cost |
    | ROI Rate | (Net Profit/ Total Cost) * 100% |
    | Active Customers | Total Customer have Transaction |
    | Cost per Active Customer | Total Cost/ Number of Active Customer |
    | Net Profit per Active Customer | Net Profit/ Number of Active Customer  |
    | Gross Margin Profit (GMP) | Net Profit/ Total Profit |
- The analysis indicates that:
    
    <img width="1563" height="277" alt="Image" src="https://github.com/user-attachments/assets/eaf66980-2c8f-46d7-9619-ad64ae6e3360" />
    
    - **RB** and **Telesale** are the two sources that deliver outstanding financial performance, with Net Profit reaching approximately **VND 54.5 billion** and **VND 51.1 billion**, respectively. Their ROIs are also very high (**RB**: 78.82%, **Telesale**: 52%). Although the investment costs for these two sources are not low, the high number of active customers (over 2,400) results in excellent profitability per customer. In contrast, sources such as **CASHBAG**, **FPT_PLAY**, **MOMO**, and **VNDIRECT** show significantly lower ROIs (around 12–14%), despite having relatively high total costs.
- Additionally, I compared performance based on **Net Profit, Cost per Customer**, and the **number of active customers per channel**, with key findings including:
    - **RB** continues to lead with the highest **net profit per customer** at approximately **VND 22.5 million**, while the **cost per customer** is only about **VND 287 thousand** - an extremely optimized level. Meanwhile, **CASHBAG** and **FPT_PLAY** have much higher **costs per customer** (VND 1.6–1.7 million), but their net profit is not proportionate (around VND 19–21 million), resulting in lower investment efficiency and making it difficult to scale sustainably without strategic adjustments.
    - It's also worth noting that the **Ecosystem** group, including BAMBOO, GOTADI, and VNDIRECT, has a moderate customer base (750-830 customers), but their **ROI and Net Profit per Customer** remain low. This suggests that **scaling customer volume must go hand-in-hand with cost optimization and quality targeting**, as simply attracting more customers doesn’t automatically translate to higher value for the bank.

    <img width="2780" height="1412" alt="Image" src="https://github.com/user-attachments/assets/f51a983d-3322-46dc-97c8-2313c111761f" />
    
    <img width="2782" height="1419" alt="Image" src="https://github.com/user-attachments/assets/f209f2e9-38b8-4dbb-be0a-f75ff22ccf22" />
    
    <img width="2801" height="1547" alt="Image" src="https://github.com/user-attachments/assets/dc7b5828-a0ab-4ef8-8b61-864858240430" />

## 4. Customer Lifetime Value - CLV

- **CLV (Customer Lifetime Value)** is the net profit that a customer contributes to the company over the entire duration of their relationship. It helps the bank identify:
    - How long the customer continues to bring value to the bank?
    - Which customer group they belong to, in order to tailor specific programs for them.
    - Which **touchpoints** represent the stages where the customer actually brings value to the bank?
- The formula is implemented as follows:
    
    <img width="431" height="99" alt="Image" src="https://github.com/user-attachments/assets/f138084e-058f-4033-9353-616d62fd737e" />
    
- Description of the values:
    
    <img width="663" height="378" alt="Image" src="https://github.com/user-attachments/assets/a0c2cf74-b6f3-496c-b29a-02a8fe1551e5" />
    
- To assess customer quality across each Source & Channel combination, I calculate the average CLV within each group and determine the deviation of each individual customer's CLV from that average. This approach allows me to accurately measure the variation in customer value within the same Source & Channel, thereby identifying which groups are attracting high-value or low-value customers. Here is results:
    
    <img width="891" height="221" alt="Image" src="https://github.com/user-attachments/assets/35bbe6fd-1783-4e18-b477-b534350f17e6" />
    
    <img width="2683" height="1574" alt="Image" src="https://github.com/user-attachments/assets/76b91956-4b03-40c4-92f4-e297682115ee" />

    <img width="2677" height="1630" alt="Image" src="https://github.com/user-attachments/assets/88a7ce5f-3c2b-4221-965b-7608f5e759c6" />

- Remarks:
    
    - As observed, most channels show a **positive CLV deviation**, with **RB** having the highest positive difference. This indicates that customers acquired through this channel tend to have CLV significantly higher than the group average. On the other hand, **Telesales** has a slightly **negative CLV deviation**, meaning customers in this group have CLV slightly below the average. However, this gap is minimal (~0) and unlikely to cause significant negative impact.
    - It is also important to note that although **Telesales** is one of the most valuable channels, the low deviation suggests that its value largely depends on a group of high-value customers. This indicates a heavy reliance on a specific customer segment, which could pose a risk if that segment's behavior changes.

## 5. Turn Over

- Next, I focus on analyzing **Turnover** and **Churn Rate** to evaluate customer retention performance and the return rate after the first transaction. The goal is to understand how long it takes for customers to make their next transaction, how long they stay active, and what the churn rate looks like across different sources/channels.
- The key time-based metrics I consider include:
    - During the campaign period, how many customers did each channel acquire?
    - What is their average **LIFE_SPAN** (in months)?
    - How many customers made their first transaction within the first three months (from account creation)?
    - How many made a follow-up transaction within 1 month (from the first transaction)?
    - How many continued to make transactions in the following 6 months?
- The results are as follows:

    <img width="1575" height="379" alt="Image" src="https://github.com/user-attachments/assets/95b312c8-25ea-4e45-af08-94f42b7afcf7" />
    
    <img width="1299" height="380" alt="Image" src="https://github.com/user-attachments/assets/f36e479f-3970-4dff-aa02-df340d8ce141" />

- Remarks:
    - The results show that the percentage of customers who made transactions within the first 3 months is very high across most Source & Channel groups (above 94%), indicating strong initial activation. However, the rate of follow-up transactions within 1 month after the first transaction varies — the lowest being **BAMBOO (9.06%)** and the highest being **GOTADI (13.37%)**. Notably, the transaction rate within 6 months after the first transaction is nearly zero for most sources, except for a few such as **VNDIRECT**, **Universities**, **RB**, and **Telesale**, which show slight retention (0.04–0.15%).
    - In addition, the majority of customers are concentrated in **RB (2,421)** and **Telesale (2,453)**, while other sources have around 600–800 customers. Although initial transaction volumes are high, the data shows that **AVG_LIFE_SPAN = 0** across all groups, suggesting that customers do not continue transacting over time or that the transaction lifespan is too short. These indicators raise concerns about a **high churn rate** and the **lack of effective customer retention strategies**.

## Recommended Actions:

After analyzing and consolidating the key performance indicators, I aim to identify which sources deliver exceptional results and are worth further investment, which sources should be maintained to ensure long-term revenue, and which require review and adjustment.

### Sources Worth Investing In:

- RB (Channel: RB):
    - This group shows outstanding performance: **highest Net Profit** (VND 54.47 billion) and **ROI ~79%**.
    - Strong conversion rate and high CLV.
    - Very efficient: low cost per customer (~VND 278,000) and high profit per customer (VND 22.5 million).
- Telesale (Channel: Telesale):
    - Ranked just behind RB, with high Net Profit and ROI.
    - Net Profit per customer reaches **VND 20.8 million**.
    - However, CLV is slightly below average, indicating a heavy reliance on high-value customer segments.

**⇒ Recommended Solutions:**

- Expand the customer base by replicating RB's successful touchpoints and leveraging affiliate partners.
- Focus on acquiring more high-value customer segments, especially for Telesale.
- Develop long-term nurturing and personalized engagement strategies to increase customer Lifetime Value.

### Sources to Maintain:

**ZaloAdtima, Facebook, Google (Digital Direct Sale):**

- Net Profit remains stable with relatively low customer acquisition costs (~VND 450,000–460,000).
- Consistent positive CLV deviation.
- Good initial conversion, but drop-off occurs in later stages.

**⇒ Recommended Solutions:**

- Optimize the **eKYC** and **initial transaction activation** stages, as analysis shows the highest drop-off happens after the click phase.
- Implement **re-targeting campaigns** for users who stopped at the installation stage or failed eKYC.

### Sources That Require Adjustment:

**CASHBAG, FPT_PLAY, MOMO, VNDIRECT (Partnership & Ecosystem):**

- While some sources under the Partnership & Ecosystem channels (like Universities, GOTADI, BAMBOO) show promising customer volume, average ROI, and decent short-term turnover rates (3-month and 1-month after first transaction), the remaining sources under these channels perform poorly.
- Low ROI (12–13%) combined with **high acquisition costs** and **unimpressive Net Profit per customer** highlight inefficiencies.
- Additionally, **CLV is not significant**, indicating poor cost-effectiveness.

**⇒ Recommended Solutions:**

- **Review the onboarding process**: Investigate why customers are not making second transactions — is it due to mismatched services or poor user experience?
- **Revise or suspend underperforming sources**: Consider renegotiating partnership terms or switching to more promising partners.

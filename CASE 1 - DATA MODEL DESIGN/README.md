## 1. Introduction:

In this project, the bank is implementing a digital process for customers using eKYC (electronic Know Your Customer) technology. This process involves customers going through the onboarding process, creating a digital account, and making transactions. Therefore, to ensure the eKYC process runs effectively and to monitor customer transaction behavior, we require a robust data warehouse (Datawarehouse) solution.

## 2. Understand Onboarding Journey:

<img width="1119" height="529" alt="Image" src="https://github.com/user-attachments/assets/871174fe-7372-4699-a03f-e3df667d1e60" />

### 2.1. Application Form: 
    
The customer begins by filling out an application form with their personal information and submitting the required documents. This step is essential for initiating the identity verification process.

### 2.2. eKYC Process: 

By executing the eKYC process, data will be collected and recorded into the data warehouse.

<img width="1183" height="452" alt="Image" src="https://github.com/user-attachments/assets/c0c6bb4b-dd24-46b1-9cc5-b5993eae3bf1" />

**Step 1: Identification:** 

- The customer uses a mobile device to capture images of the front and back of their national ID (e.g., ID card or passport), along with a selfie. These images serve as the input for the system's identity verification.
- The system uses facial recognition technology to verify whether the selfie matches the photo on the ID document. This ensures that the person undergoing eKYC is the actual document holder.
- The system applies OCR (Optical Character Recognition) to automatically extract key personal information from the ID, including full name, date of birth, region, and nationality.
    - The initially extracted data is stored in the `OCR_Information` table. 
    - If there are any errors or missing data, the customer is allowed to review and manually correct the information — the confirmed or edited data is stored in the `INPUT_Information` table.

**Step 2: Vertification:**

- The system sends a One-Time Password (OTP) or PIN code to the customer's registered email address and phone number via SMS. This step ensures that the contact information provided is valid and accessible by the customer.
- **Simultaneously, the system retrieves the National ID (NID) information that was previously extracted:**
    - **NID Data:** Personal information extracted from the ID document (e.g., full name, date of birth, nationality).
    - **NID Photo:** The portrait image taken from the ID.
- This step ensures that the person entering the OTP is the same individual whose identity was captured and verified through the provided ID document. By matching the OTP verification with official ID data and facial information, the system strengthens identity assurance and prevents impersonation or fraudulent onboarding.

**Step 3: Account Details:**

- The system re-displays the previously verified identity data, allowing the customer to clearly see which official information is being used for account opening — thereby enhancing transparency and reinforcing customer trust.
- After that, the customer is prompted to provide more details that are not usually present on the ID document.

**Step 4: Completed:**

- The customer reviews all provided data before submitting it for final processing.
- Once submitted, the eKYC process is complete, and the customer is ready for account activation.
### 2.3. Account Creation:

Once the verification is successful, a digital account is created and activated for the customer.

### 2.4. Transaction:

The customer can now perform financial transactions such as fund transfers, deposits, or purchases. This stage is critical for collecting behavioral data on the customer's financial activities.

### 2.5. Post eKYC Validation: 

After the account is created, the system enters the post-eKYC validation stage. At this point, customers may or may not perform actual transactions. Therefore, the system monitors not only transaction behavior but also customer engagement and account status. Based on this monitoring, customers are classified into different categories:

- **FRAUD**: Accounts showing suspicious patterns or mismatched information may be closed.
- **RISK**: Accounts flagged as high-risk based on various criteria will be subject to restrictions.
- **NORMAL**: Accounts with verified and compliant behavior, whether or not transactions occur, are considered normal and may be targeted for cross-sell and up-sell opportunities.

## 3. Identify Entities:

### 3.1 Customer:

Represent digital individuals who are engaging with our banking services. This includes basic information such as name, contact details, identification documents, and eKYC status.

### 3.2. Account:

Represents the accounts created by customers during the digital onboarding process. Accounts that are opened online are assigned **Category 1001** , and if the customer later completes KYC at a physical branch, the account is upgraded to **Category 1002**. Details include account number, category, creation date, and the customer it is linked to.

### 3.3. Transactions:

Represents the digital financial transactions conducted by customers. Transaction details include transaction ID, timestamp, amount, type, linked account, and customer information.

### 3.4. eKYC:

Represents the status of the eKYC process for each customer. It includes the progress of verification, such as pending, verified, or rejected. Each status change should be time-stamped to maintain a history of the process.

### 3.5. Post-eKYC:

Represents the customer’s fraud status after account creation. Each account is monitored for suspicious activity, and if flagged, the system prompts the customer to complete in-branch KYC. The record includes fraud type, verification timestamp, and follow-up actions. If customer complete successful verification, the account is upgraded to Category 1002.

## 4. Data Source:

| Source | Description |
| --- | --- |
| `CRM system` | Collect and tracking the customer's interactions with the application. |
| `Onboarding eKYC system` | Collect information about the customer's eKYC process |
| `Core T24 Account system` | Collect information about the customer's accounts and transactions. |
| `Post-eKYC tracking` | Provided by the operations teams to track the fraud types of the customer’s account |

## 5. Build Data Warehouse:

To improve scalability and maintainability, I adopt a 3-tier architecture in the Data Warehouse design. This structure separates the system into three layers: Source layer, Reconciled layer, and Data Warehouse layer. It allows for better data organization, easier debugging, and more efficient data processing and governance.

<img width="581" height="467" alt="Image" src="https://github.com/user-attachments/assets/c1e6cb62-cd81-4da1-8b9d-dae3bd8c0fc7" />


**1. Source Layer:** Includes raw data as listed in the Data Source table. At this stage, data is collected from various disparate sources. 

**2. Reconciled Layer:** Data from the Source Layer flows into this layer, where it goes through a data staging process and is filtered based on business rules defined by the Business Analyst.

**3. Data Warehouse Layer:** Stores the processed data from the Reconciled Layer in the form of Fact and Dimension tables.

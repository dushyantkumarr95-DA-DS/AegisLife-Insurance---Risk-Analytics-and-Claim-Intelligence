# AegisLife-Insurance - Risk Analytics and Claim Intelligence
### End-to-end Insurance Analytics using Excel &amp; MySQL

---

## Project Overview
AegisLife is an insurance company selling five product lines Health, Property, Term, Vehicle, and Whole through a network of agents across multiple regions.

This project brings these datasets together into a structured **MySQL relational database** and performs end to end business and data analysis. 

This project follows a practical data-analytical workflow:

**Data Collection -> Data Cleaning -> Database design -> Data Ingestion -> SQL Analysis -> Business Insights -> Recommendations. **

---

# Problem Statement:
The company's customer, policy, claims, fraud, agent and customer feedback information existed across separate datasets, making it difficult to obtain consolidated view of business performance and risk. AegisLife needs better visibility into the factors affecting its insurance portfolio.

---

# Dataset Overview:
| Dataset | Records | Description |
| --- | --- | --- |
| `customer_master` | 1648 | Customer demographics, occupation, smoking status, pre-existing illness and risk score |
| `agent_info` | 300 | Agent information and performance related metrics |
| `policy_details` | 2,828 | Policy type, premium, agent, policy status |
| `claim_history` | 1,406 | Claim amount, claim type, status, fraud flag |
| `customer_feedback_surveys` | 631 valid | Customer satisfaction and feedback information |

The raw feedback dataset originally contained 1,000 records. During data quality validation, 369 records were identified as orphan records because corresponding information was unavailable, leaving 631 valid feedback records for analysis.

---

# Tools & Technologies

### Data Cleaning
- Microsoft Excel

### Database
- MySQL
- SQL DDL
- Primary Keys
- Foreign Keys
- Relational database design

### Analysis
- SQL
- Aggregations
- `GROUP BY`
- `JOIN`
- `CASE`
- `CTEs`
- Window functions

### Documentation & Reporting
- Microsoft Word, PDF

---

# Project Workflow

```text

Raw CSV Files
      |
      ▼
Data Cleaning and Standardization in Excel
      |
      ▼
Data Quality Validation
      |
      ▼
MySQL Database Design
      |
      ▼
Data Ingestion LOAD DATA INFILE
      |
      ▼
Data Volume & Integrity Validation
      |
      ▼
SQL Exploratory & Diagnostic Analysis
      |
      |-- Customer & Acquisition Analysis
      |-- Customer Risk Analysis
      |-- Policy & Sales Analysis
      |-- Retention & Lapse Rate
      |-- Claim Analysis
      |-- Fraud Analysis
      |-- Agent Performance
      |-- Customer Satisfaction
      |
      ▼
Business Findings
      |
      ▼
Business Problem and Potential Solutions

```
# 1. Data Cleaning & Quality Validation
Before loading the data into MySQL, the five datasets were reviewed for common real-world data-quality issues.
A dedicated data-quality log was maintained to document the identified issues and action taken.
<img width="1146" height="363" alt="image" src="https://github.com/user-attachments/assets/949024e4-654a-4c56-bb38-15995fa373c3" />

---

# 2. Database Design & Data Ingestion
A relational MySQL database names `aegislife_risk_analytics` was created.
### Database design:
<img width="1090" height="1051" alt="image" src="https://github.com/user-attachments/assets/2cca7e03-66a8-4d3b-9bee-203f2345cc83" />

### Data Ingestion
Data was loaded into corresponding tables using `LOAD DATA INFILE`

---

# 3. Exploratory & Diagnostic Analysis
After ingestion SQL analysis was performed across eight major business areas: 
**Customer & Acquisition Analysis, Customer Risk Analysis, Policy & Sales Analysis, Retention & Lapse Rate, Claim Analysis, Fraud Analysis, Agent Performance, Customer Satisfaction.**

<img width="1085" height="575" alt="image" src="https://github.com/user-attachments/assets/95019fe4-2e65-4537-9952-056c4f4b9cae" />

<img width="1081" height="502" alt="image" src="https://github.com/user-attachments/assets/f02cff0e-b26f-46cb-893f-f34b1bdd974a" />

<img width="987" height="360" alt="image" src="https://github.com/user-attachments/assets/77b09893-83b4-468c-bcd3-b7a2a75c3033" />

<img width="986" height="615" alt="image" src="https://github.com/user-attachments/assets/fcfae4fc-53e5-4e15-96a3-be6ba8f0ba68" />

<img width="982" height="657" alt="image" src="https://github.com/user-attachments/assets/4bc2d2f1-95cd-4871-af59-2dfe5efeae7f" />

<img width="985" height="367" alt="image" src="https://github.com/user-attachments/assets/7700eee5-12be-4db5-9e42-ef77b1772947" />


---

# 4. Business Problems identified and Possible Solutions
### Problem 1: Premium do not reflect risk.
Average premium value remains nearly flat across risk bands, while claims and lapses climb sharply. Low-risk vs high-risk premium ₹28262.81/- vs ₹28349.59/- (↑0.3%); claim per policy 0.40 vs 0.56 (↑40%).
**Possible Solutions:**
- Introduce risk-based premiums, with surcharge for smoking and pre-existing illness.
- Reprice Health insurance first, where medical risk matters most.
- Offer non-smoker and wellness discounts to keep low-risk customers.

### Problem 2: Claims backlog and a poor claim experience.
482 claims (34.28%) are pending. Claimants satisfaction score 2.94 vs 3.35 for non-claimant, and “waited too long for approval” scores 1.40.
**Possible Solutions:**
- Collect all documents in one checklist during claim request.
- Fast-track low value, unflagged claims and reserve senior review for high-value or flagged ones.
- Send status update at each stage.

### Problem 3: Fraud and agent concentration.
₹0.96 Cr of approved payouts went to flagged claims, and 78 of 161 flags are still pending, so the money can still be stopped. <br>
AGT5001 has 9 of 14 claims flagged (64% fraud ratio) against an 11.45% base rate, and is the second largest seller (18 policies).  CUST10526 has 4 flagged claims. Risk score does not predict fraud.
**Possible Solutions:**
- Freeze payout on flagged claims.
- Audit the top-flagged agents and review their policy issuance.

### Problem 4: High policy lapse rate.
798 lapsed and 237 cancelled policies are associated with about ₹2.93 Cr or annual premium (₹2.26 Cr +₹ 0.67 Cr). <br>
High-risk customers lapse at 36.39%, students at 30.62%, Vehicle and Term at about 29-30%.
**Possible Solutions:**
- Payment reminders 30 and 7 days before due date, with auto debit and monthly or quarterly premium options for students.
- Retention calls for high-risk and Vehicle/term holders before payment.
- Win-back offers for recently lapsed policies.

### Problem 5: Inconsistent growth and an untapped customer pool.
Acquisition has been flat at about 280 customers a year since 2021, and 429 customers (26%) hold no policy. <br>
North-east conversion rate at 70.94% followed by South and Central. Existing policy holders average 2.32 policies, so cross-sell works.
**Possible Solutions:**
- Targeted offers to the 429 non-policy holders.
- Bundled policy offers.

### Problem 6: Death claims domination.
270 death claims carry ₹28.77 Cr and ₹4.05 Cr of the ₹7.5 Cr fraud exposure (54%).
**Possible Solution:**
- Set stricter documentation and investigation for Death claims

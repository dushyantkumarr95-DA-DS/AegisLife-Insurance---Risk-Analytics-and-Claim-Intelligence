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
The company's customer, policy, claims, fraud, agent and customer feedback information existed across separate datasets, making it difficult to obtain consolidated view of business performance and risk. AegusLife needs better visibility into the factors affecting its insurance portfolio.

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

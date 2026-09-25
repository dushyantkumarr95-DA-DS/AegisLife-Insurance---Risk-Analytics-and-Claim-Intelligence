-- =============================================================================================
-- AegisLife Insurance - Risk Analytics & Claim Intelligence
-- =============================================================================================

USE aegislife_risk_analytics;

-- Data Volume Validation:
SELECT 'customer_master' AS table_name, COUNT(*) AS row_count 
from customer_master
UNION ALL
SELECT 'policy_detais' AS table_name, COUNT(*) AS row_count
from policy_details
UNION ALL
SELECT 'claim_history' AS table_name, COUNT(*) AS row_count
from claim_history
UNION ALL
SELECT 'agent_info' AS table_name, COUNT(*) AS row_count
FROM agent_info
UNION ALL
SELECT 'customer_feedback_surveys' AS table_name, COUNT(*) AS row_count
FROM customer_feedback_surveys;

-- ============================================================================================
-- 1. CUSTOMER AND ACQUISITION ANALYSIS
-- ============================================================================================

-- Total Number of customers in AegisLife:
SELECT 
	COUNT(DISTINCT customer_id) AS total_customers 
FROM customer_master;
-- ============================================================================================

-- How is the customer base distributed across regions?
SELECT
	region AS Region,
    COUNT(DISTINCT customer_id) AS Customers
FROM customer_master
GROUP BY region
ORDER BY Customers DESC;
-- ============================================================================================

-- How is the customer base distributed across various age-groups?
WITH age_grouping AS (
SELECT *,
	CASE
		WHEN age BETWEEN 18 AND 25 THEN "18-25"
        WHEN age BETWEEN 26 AND 35 THEN "26-35"
        WHEN age BETWEEN 36 AND 45 THEN "36-45"
        WHEN age BETWEEN 46 AND 55 THEN "46-55"
        ELSE "55+"
	END AS age_group
FROM customer_master)
SELECT 
	age_group AS Age_Group,
    COUNT(customer_id) AS Customers,
    ROUND((COUNT(customer_id) / (SELECT COUNT(customer_id) FROM customer_master))*100, 2) AS Percentage
FROM age_grouping
GROUP BY age_group
ORDER BY age_group;
-- ============================================================================================

-- How is the customer base distributed across occupations?
SELECT
	occupation AS Occupation,
    COUNT(customer_id) as Customers,
    ROUND(COUNT(customer_id) / (SELECT COUNT(customer_id) FROM customer_master) * 100,2) AS Percentage
FROM customer_master
GROUP BY occupation
ORDER BY Customers DESC;
-- ============================================================================================

-- How has customer acquisition changed year-over-year?
WITH yearly_acquisition AS (
SELECT
	YEAR(date_joined) AS Year,
    COUNT(customer_id) AS New_Customers_Acquired
FROM customer_master
GROUP BY YEAR(date_joined)
ORDER BY Year),

growth AS (
SELECT 
	Year,
    New_Customers_Acquired,
    LAG(New_Customers_Acquired) OVER (ORDER BY Year) AS Previous_Customers
FROM yearly_acquisition)

SELECT 
	Year, 
    New_Customers_Acquired,
    ROUND(((New_Customers_Acquired - Previous_Customers) / Previous_Customers)*100, 2) AS Growth
FROM growth;

-- ======
--   OR
-- ======

WITH yearly_acquisition AS (
SELECT 
	YEAR(date_joined) AS Year,
    COUNT(customer_id) AS Customers_Acquired
FROM customer_master
GROUP BY YEAR(date_joined)
ORDER BY Year)

SELECT
	YEAR,
    Customers_Acquired,
    CONCAT(
    Round(((Customers_Acquired - LAG(Customers_Acquired)OVER(ORDER BY Year)) / 
		LAG(Customers_Acquired)OVER(ORDER BY Year)) * 100,2)," %") AS Growth
FROM yearly_acquisition;
-- ============================================================================================

-- Region-wise Yearly Customer Growth:

WITH yearly_acquisition AS (
SELECT
	region AS Region,
    YEAR(date_joined) AS Year,
    COUNT(customer_id) AS Customers_Acquired
FROM customer_master
GROUP BY region, YEAR(date_joined)
ORDER BY region DESC, YEAR)

SELECT 
	Region,
    Year,
    Customers_Acquired,
    ROUND(((Customers_Acquired - LAG(Customers_Acquired) OVER (PARTITION BY Region ORDER BY Year)) /  
		LAG(Customers_Acquired) OVER (PARTITION BY Region ORDER BY Year)) * 100, 2) AS Growth
FROM yearly_Acquisition;


-- ============================================================================================
-- 2. CUSTOMER RISK ANALYSIS
-- ============================================================================================

-- What is the overall average customer risk-score?
SELECT
	ROUND(AVG(risk_score), 2) AS Average_Risk_Score
FROM customer_master;
-- ============================================================================================

-- Which age-group has the highest average risk-score?
WITH age_grouping AS(
SELECT *,	
	CASE
		WHEN age BETWEEN 18 AND 25 THEN "18-25"
        WHEN age BETWEEN 26 AND 35 THEN "26-35"
        WHEN age BETWEEN 36 AND 45 THEN "36-45"
        WHEN age BETWEEN 46 AND 55 THEN "46-55"
        ELSE "55+"
	END AS Age_Group
FROM customer_master)
SELECT 
	Age_Group,
    ROUND(AVG(risk_score), 2) AS Average_Risk_Score
FROM age_grouping 
GROUP BY Age_Group
ORDER BY Age_Group;
-- ============================================================================================

-- Do smokers have higher risk-score than non-smokers?
SELECT
	smoking_status AS Smoking_Status,
    ROUND(AVG(risk_score),2) AS Average_Risk_Score
FROM customer_master
GROUP BY smoking_status;
-- ============================================================================================

-- Do customers with pre-existing illness have higher risk-score?
SELECT 
    pre_existing_illness AS Pre_Existing_Illness,
    ROUND(AVG(risk_score), 2) AS Average_Risk_Score
FROM
    customer_master
GROUP BY pre_existing_illness;
-- ============================================================================================

-- Does higher customer risk-score translate into higher premiums?
WITH customer_master AS (
SELECT *,
	CASE
		WHEN risk_score BETWEEN 0.0 AND 0.24 THEN "Low"
        WHEN risk_score BETWEEN 0.25 AND 0.49 THEN "Moderate"
        WHEN risk_score BETWEEN 0.50 AND 0.74 THEN "High"
        ELSE "Very high"
	END AS risk_bucket
FROM customer_master)
SELECT 
	c.risk_bucket AS Risk,
    ROUND(AVG(p.annual_premium), 2) AS Average_Annual_Premium
FROM customer_master c JOIN policy_details p 
USING(customer_id)
GROUP BY c.risk_bucket
ORDER BY Average_Annual_Premium;
-- ============================================================================================

-- Customers List whose risk_score is greater than 0.50:
SELECT 
	*
FROM customer_master
WHERE risk_score >= 0.50;


-- ============================================================================================
-- 3. POLICY AND SALES ANALYSIS
-- ============================================================================================

-- How many policies has AegisLife sold?
SELECT 
	COUNT(DISTINCT policy_id) AS Total_Policies_Sold
FROM policy_details;
-- ============================================================================================

-- How many policies does the average customer purchase?
SELECT
	ROUND(COUNT(policy_id) / COUNT(DISTINCT customer_id), 2) AS Average_Policy_Per_Customer
FROM policy_details;
-- ============================================================================================

-- What percentage of customers have no policy?
SELECT
	100 - (ROUND(COUNT(DISTINCT p.customer_id) / COUNT(DISTINCT c.customer_id) * 100, 2)) AS Percentage_of_customers_with_no_policy
FROM customer_master c LEFT JOIN policy_details p 
USING(customer_id);
-- ============================================================================================

-- Number of Customers Who doesn't bought any policy
SELECT COUNT(DISTINCT customer_id) AS Customers_without_policy
FROM (
SELECT
	c.customer_id AS Customer_ID,
    COUNT(p.policy_id) AS Policies_Bought
FROM customer_master c LEFT JOIN policy_details p
USING (customer_id)
GROUP BY c.customer_id
HAVING Policies_Bought < 1) AS no_policy;


-- ======
--   OR
-- ======

SELECT 
	COUNT(*) AS Customers_Without_Policy
FROM customer_master c
WHERE NOT EXISTS (
					SELECT 1
                    FROM policy_details p 
                    WHERE p.customer_id = c.customer_id);
-- ============================================================================================

-- Average Conversion Rate - 
SELECT
	COUNT(DISTINCT c.customer_id) AS Total_Customers,
    COUNT(DISTINCT p.customer_id) AS Customers_with_Policy,
    ROUND(COUNT(DISTINCT p.customer_id) / COUNT(DISTINCT c.customer_id) * 100,2) AS Conversion_Rate
FROM customer_master c LEFT JOIN policy_details p 
USING(customer_id);
-- =============================================================================================

-- Which customer segments have low conversion to policies?
SELECT
	c.region AS Region,
    COUNT(DISTINCT c.customer_id) AS Total_Customers,
    COUNT(DISTINCT p.customer_id) AS Customers_with_policies,
    COUNT(DISTINCT c.customer_id) - COUNT(DISTINCT p.customer_id) AS Unconverted_customers,
    ROUND(COUNT(DISTINCT p.customer_id) / COUNT(DISTINCT c.customer_id) * 100,2) AS Conversion_Rate
FROM customer_master c LEFT JOIN policy_details p 
USING(customer_id)
GROUP BY c.region
ORDER BY Conversion_Rate;
-- ============================================================================================

-- Policy Distribution by Product Type:
SELECT 
	product_type AS Product_Type,
    COUNT(policy_id) AS Policies_Sold,
    ROUND(COUNT(policy_id) / (SELECT COUNT(policy_id) FROM policy_details) * 100, 2) AS Percentage,
    ROUND(AVG(annual_premium),2) AS Average_Annual_Premium
FROM policy_details
GROUP BY product_type
ORDER BY Policies_Sold DESC;
-- ============================================================================================

-- Policy Distribution by Age-Group:
WITH customer_master AS (
SELECT *,
	CASE
		WHEN age BETWEEN 18 AND 25 THEN "18-25"
        WHEN age BETWEEN 26 AND 35 THEN "26-35"
        WHEN age BETWEEN 36 AND 45 THEN "36-45"
        WHEN age BETWEEN 46 AND 55 THEN "46-55"
        ELSE "55+"
	END AS age_group
FROM customer_master)

SELECT 
	c.age_group AS Age_Group,
    COUNT(p.policy_id) AS Policies_Sold
FROM customer_master c JOIN policy_details p 
USING(customer_id) 
GROUP BY c.age_group
ORDER BY Policies_Sold DESC;
-- ============================================================================================

-- Policy Distribution by Occupation:
SELECT
		c.occupation AS Occupation,
        COUNT(DISTINCT p.customer_id) AS customers_with_policies,
        COUNT(DISTINCT p.policy_id) AS Policies_Sold,
        ROUND(AVG(p.annual_premium),2) AS Average_Annual_Premium
FROM customer_master c JOIN policy_details p 
ON c.customer_id = p.customer_id 
GROUP BY c.occupation 
ORDER BY Policies_Sold DESC;
-- ============================================================================================

-- Policy Distribution by Region:
SELECT 
	c.region AS Region,
    COUNT(DISTINCT p.customer_id) AS Customers_with_Policies,
    COUNT(p.policy_id) AS Policies_Sold,
    ROUND(AVG(p.annual_premium),2) AS Average_Annual_Premium
FROM customer_master c INNER JOIN policy_details p
USING (customer_id)
GROUP BY c.region
ORDER BY Policies_Sold DESC;
-- ============================================================================================

-- What is the average annual premium per policy?
SELECT 
	ROUND(AVG(annual_premium), 2) AS Average_Annual_Premium
FROM policy_details;
-- ============================================================================================

-- How has the policy selling trend changed year-over-year?
WITH policy_trend AS (
SELECT 
	YEAR(policy_start_date) AS Year,
    COUNT(policy_id) AS Policies_Sold
FROM policy_details
GROUP BY YEAR(policy_start_date)
ORDER BY Year)

SELECT 
	Year,
    Policies_Sold,
    CONCAT(
    ROUND(((Policies_Sold - LAG(Policies_Sold)OVER(ORDER BY Year)) / 
		LAG(Policies_Sold)OVER(ORDER BY Year)) * 100, 2), " %") AS Growth
FROM policy_trend;


-- ============================================================================================
-- 4. POLICY RETENTION / LAPSE ANALYSIS
-- ============================================================================================

-- Policy Status Analysis:
SELECT
	status AS Policy_Status,
    COUNT(policy_id) AS Policies,
    CONCAT(
    ROUND((COUNT(policy_id) / (SELECT COUNT(policy_id) FROM policy_details))*100, 2), " %") AS Percentage,
    ROUND(AVG(annual_premium),2) AS Average_Annual_Premium
FROM policy_details
GROUP BY status;
-- ============================================================================================

-- What is the overall policy lapse rate?
SELECT
	COUNT(policy_id) AS Total_Policies,
    COUNT(CASE
			 WHEN status = 'Lapsed' THEN policy_id END) AS Lapsed_Policies,
	ROUND((COUNT(CASE 
				WHEN status='Lapsed' THEN policy_id END) / COUNT(policy_id))*100,2) AS Lapse_Rate
FROM policy_details;
-- ============================================================================================

-- Which products have the highest lapse rate?
SELECT
	product_type AS Product_Type,
    ROUND(COUNT(CASE WHEN status = 'Lapsed' THEN policy_id END) / 
    COUNT(policy_id) * 100, 2) AS Lapse_Rate,
    ROUND(COUNT(CASE WHEN status = 'Cancelled' THEN policy_id END) / 
    COUNT(policy_id) * 100, 2) AS cancellation_Rate
FROM policy_details 
GROUP BY product_type
ORDER BY Lapse_Rate DESC;
-- ============================================================================================

-- Which regions have the highest lapse rate?
SELECT 
	c.region AS Region,
    ROUND(COUNT(CASE WHEN p.status='Lapsed' THEN p.policy_id END) /
    COUNT(p.policy_id) * 100, 2) AS Lapse_Rate,
    ROUND(COUNT(CASE WHEN p.status='Cancelled' THEN p.policy_id END) /
    COUNT(p.policy_id) * 100, 2) AS Cancellation_Rate
FROM customer_master c JOIN policy_details p 
USING(customer_id)
GROUP BY c.region
ORDER BY Lapse_Rate DESC;
-- ============================================================================================

-- Which occupations have the highest lapse rate?
SELECT
	c.occupation AS Occupation,
    ROUND(COUNT(CASE WHEN p.status='Lapsed' THEN policy_id END) /
    COUNT(p.policy_id) * 100,2) AS Lapse_Rate,
    ROUND(COUNT(CASE WHEN p.status='Cancelled' THEN policy_id END) / 
    COUNT(p.policy_id) * 100,2) AS Cancellation_Rate
FROM customer_master c JOIN policy_details p 
USING(customer_id) 
GROUP BY c.occupation
ORDER BY Lapse_Rate DESC;
-- ============================================================================================

-- Which agents have the highest lapse rate?
SELECT 
	agent_id AS Agent_ID,
    COUNT(policy_id) AS Policies_Sold,
    COUNT(CASE WHEN status='Lapsed' THEN policy_id END) AS Lapsed_Policies, 
    ROUND(COUNT(CASE WHEN status='Lapsed' THEN policy_id END) / 
    COUNT(policy_id) * 100,2) AS Lapse_Rate,
    ROUND(COUNT(CASE WHEN status='Cancelled' THEN policy_id END) / 
    COUNT(policy_id) * 100,2) AS Cancellation_Rate
FROM policy_details 
GROUP BY agent_id 
HAVING Policies_Sold >= 10
ORDER BY Lapse_Rate DESC;
-- ============================================================================================

-- Are high-risk customers more likely to lapse?
WITH customer_master AS (
SELECT *,
	CASE
		WHEN risk_score BETWEEN 0.0 AND 0.24 THEN "Low"
        WHEN risk_score BETWEEN 0.25 AND 0.49 THEN "Moderate"
        WHEN risk_score BETWEEN 0.50 AND 0.74 THEN "High"
        ELSE "Very high"
	END AS risk_bucket 
FROM customer_master)
SELECT
	c.risk_bucket AS Risk,
    COUNT(p.policy_id) AS Total_Policies,
    COUNT(CASE WHEN p.status='Lapsed' THEN p.policy_id END) AS Lapsed_policies,
    ROUND(COUNT(CASE WHEN p.status='Lapsed' THEN policy_id END) / 
    COUNT(p.policy_id) * 100, 2) AS Lapse_Rate,
    ROUND(COUNT(CASE WHEN p.status='Cancelled' THEN policy_id END) / 
    COUNT(p.policy_id) * 100, 2) AS Cancellation_Rate 
FROM customer_master c JOIN policy_details p 
USING(customer_id) 
GROUP BY c.risk_bucket 
ORDER BY Lapse_Rate DESC;


-- ============================================================================================
-- 5. CLAIM ANALYSIS
-- ============================================================================================

-- How many claims are being filed and what is the fraud ratio?
SELECT 
	COUNT(claim_id) AS Total_Claims,
    SUM(fraud_flag = 'Yes') AS Fraud_Claims,
    CONCAT(
    ROUND(SUM(fraud_flag = 'Yes') / COUNT(claim_id) * 100, 2)," %") AS Fraud_Claim_Ratio,
    SUM(CASE
			WHEN fraud_flag = 'Yes' THEN claim_amount ELSE 0 END) AS Total_Fraud_Amount
FROM claim_history;
-- ============================================================================================

-- What is the claim frequency per policy?
SELECT
	COUNT(DISTINCT p.policy_id) AS Total_Policies,
    COUNT(c.claim_id) AS Total_Claims,
    ROUND(COUNT(c.claim_id) / COUNT(DISTINCT p.policy_id), 2) AS Claim_Frequency
FROM policy_details p LEFT JOIN claim_history c
USING(policy_id);
-- ============================================================================================

-- Which products have the highest claim frequency?
SELECT 
	p.product_type AS Product_Type,
    COUNT(DISTINCT p.policy_id) AS Total_Policies,
    COUNT(c.claim_id) AS Total_Claims,
    ROUND(COUNT(c.claim_id) / COUNT(DISTINCT p.policy_id), 2) AS Claim_Frequency
FROM policy_details p LEFT JOIN claim_history c
USING(policy_id) 
GROUP BY p.product_type
ORDER BY Claim_Frequency DESC;
-- ============================================================================================

-- Does smoking status correlate with claim frequency?
SELECT 
	c.smoking_status AS Smoking_Status,
    COUNT(DISTINCT p.policy_id) AS Total_Policies,
    COUNT(cl.claim_id) AS Total_Claims,
    ROUND(COUNT(cl.claim_id) / COUNT(DISTINCT p.policy_id), 2) AS Claim_Frequency
FROM customer_master c INNER JOIN policy_details p 
USING(customer_id) 
LEFT JOIN claim_history cl
USING(policy_id)
GROUP BY c.smoking_status 
ORDER BY Claim_Frequency DESC;
-- ============================================================================================

-- Does pre-existing illness correlate with claim frequency?
SELECT 
	c.pre_existing_illness,
    COUNT(DISTINCT p.policy_id) AS Total_Policies,
    COUNT(cl.claim_id) AS Total_Claims,
    ROUND(COUNT(cl.claim_id) / COUNT(DISTINCT p.policy_id), 2) AS Claim_Frequency
FROM customer_master c INNER JOIN policy_details p 
USING(customer_id) 
LEFT JOIN claim_history cl
USING(policy_id)
GROUP BY c.pre_existing_illness 
ORDER BY Claim_Frequency DESC;
-- ============================================================================================

-- How has claim volume change over time?
SELECT
	YEAR(claim_date) AS Year,
    COUNT(claim_id) AS Claims_Made,
    ROUND((COUNT(claim_id) - LAG(COUNT(claim_id)) OVER (ORDER BY Year(claim_date))) / LAG(COUNT(claim_id)) OVER (ORDER BY Year(claim_date))*100,2) AS YoY_claim_growth,
    SUM(fraud_flag = 'Yes') AS Fraud_Claims,
    ROUND(SUM(fraud_flag='Yes') / COUNT(claim_id) * 100, 2) AS Fraud_Ratio
FROM claim_history
GROUP BY YEAR(claim_date)
ORDER BY Year;
-- ============================================================================================

-- Claim Analysis by claim_type:
SELECT
	claim_type AS Claim_Type,
    COUNT(claim_id) AS Total_Claims,
    SUM(fraud_flag='Yes') AS Fraud_Claims,
    ROUND(SUM(fraud_flag='Yes') / COUNT(claim_id) * 100, 2) AS Fraud_Ratio,
    ROUND(SUM(claim_amount)/10000000, 2) AS Total_Claim_Amount_in_Cr,
    ROUND(SUM(CASE 
			WHEN fraud_flag='Yes' THEN claim_amount ELSE 0 END) / 10000000, 2) AS Fraud_Amount_in_Cr
FROM claim_history
GROUP BY claim_type
ORDER BY Total_Claims DESC;
-- ============================================================================================

-- Does higher customer risk translate into higher claim frequency?
WITH customer_master AS (
SELECT *,
	CASE 
		WHEN risk_score BETWEEN 0.0 AND 0.24 THEN "Low"
        WHEN risk_score BETWEEN 0.25 AND 0.49 THEN "Moderate"
        WHEN risk_score BETWEEN 0.50 AND 0.75 THEN "High"
        ELSE "Very high"
	END AS risk_bucket
FROM customer_master)
SELECT 
	c.risk_bucket AS Risk,
    COUNT(DISTINCT p.policy_id) AS Total_Policies,
    COUNT(cl.claim_id) AS Total_Claims,
    ROUND(COUNT(cl.claim_id) / COUNT(DISTINCT p.policy_id), 2) AS Claim_Frequency_in_pct
FROM customer_master c JOIN policy_details p 
USING(customer_id) 
LEFT JOIN claim_history cl USING(policy_id)
GROUP BY c.risk_bucket
ORDER BY Claim_Frequency_in_pct DESC;
-- ============================================================================================

-- Claim Status Analysis:
SELECT
	claim_status AS Claim_Status,
    COUNT(claim_id) AS Total_Claims,
    ROUND(COUNT(claim_id) / (SELECT COUNT(claim_id) FROM claim_history) * 100, 2) AS Percentage,
    ROUND(AVG(claim_amount),2) AS Average_Claim_Amount,
    ROUND(SUM(claim_amount)/ 10000000,2) AS Total_Claim_Amount_in_Cr,
    SUM(fraud_flag = 'Yes') AS Fraud_Claims,
    ROUND(SUM(fraud_flag='Yes') / COUNT(claim_id) * 100, 2) AS Fraud_Ratio
FROM claim_history
GROUP BY claim_status;


-- ============================================================================================
-- 6. FRAUD ANALYSIS
-- ============================================================================================

-- What percentage of claims are fraudulent and what is the total value of fraudulent claims?
SELECT 
	ROUND(SUM(fraud_flag='Yes') / COUNT(claim_id) * 100, 2) AS Fraud_Ratio,
    Round(SUM(CASE WHEN fraud_flag='Yes' THEN claim_amount ELSE 0 END) / 10000000,2) AS Total_Fraud_Amount_in_Cr
FROM claim_history;
-- ============================================================================================

-- Which product has the highest fraud-ratio?
SELECT 
	p.product_type AS Product_Type,
    COUNT(c.claim_id) AS Total_Claims,
    COUNT(CASE 
			WHEN c.fraud_flag='Yes' THEN claim_id END) AS Fraud_Claims,
	COUNT(DISTINCT CASE
						WHEN c.fraud_flag='Yes' THEN policy_id END) AS Policies_Involved_in_Fraud,
	ROUND(SUM(c.fraud_flag='Yes') / COUNT(c.claim_id) * 100, 2) AS Fraud_Ratio,
    ROUND(SUM(c.claim_amount)/10000000, 2) AS Total_Claim_Amount_in_Cr,
    ROUND(SUM(CASE 
			WHEN c.fraud_flag='Yes' THEN claim_amount ELSE 0 END)/10000000,2) AS Fraud_Claim_Amount_in_Cr
FROM policy_details p JOIN claim_history c 
USING(policy_id)
GROUP BY p.product_type 
ORDER BY Fraud_Claims DESC;
-- ============================================================================================

-- Of all the money AegisLife actually approved for claims,
--  what percentage was attributable to fraudulent claims?
SELECT
	ROUND(SUM(CASE WHEN claim_status='Approved' THEN claim_amount ELSE 0 END) / 10000000, 2) AS Total_Approved_Amount_in_Cr,
    ROUND(SUM(CASE WHEN claim_status='Approved' AND fraud_flag='Yes' THEN claim_amount ELSE 0 END) / 10000000,2) AS Total_Fraud_Amount_Approved_in_Cr,
    ROUND(SUM(CASE WHEN claim_status='Approved' AND fraud_flag='Yes' THEN claim_amount ELSE 0 END) /
    SUM(CASE WHEN claim_status='Approved' THEN claim_amount ELSE 0 END) * 100, 2) AS Fraud_Loss_Ratio
FROM claim_history;
-- ============================================================================================


-- Which agents are associated with the most fraudulent claims?
SELECT 
	p.agent_id AS Agent_ID,
    COUNT(DISTINCT p.policy_id) AS Policies_Sold,
    COUNT(c.claim_id) AS Total_Claims,
    COALESCE(SUM(c.fraud_flag='Yes'), 0) AS Fraud_Claims_Association,
    COUNT(DISTINCT CASE
						WHEN c.fraud_flag='Yes' THEN c.policy_id END) AS Poliicies_Involved_in_Fraud,
	COALESCE(ROUND(SUM(c.fraud_flag='Yes') / NULLIF(COUNT(c.claim_id), 0) * 100,2), 0) AS Fraud_Ratio,
    SUM(CASE
			WHEN c.fraud_flag='Yes' THEN claim_amount ELSE 0 END) AS Fraud_Amount
FROM policy_details p LEFT JOIN claim_history c 
USING(policy_id)
GROUP BY p.agent_id
HAVING Fraud_Claims_Association > 0
ORDER BY Fraud_Claims_Association DESC;
-- ============================================================================================

-- Which customers have fraudulent claims?
SELECT 
	c.customer_id AS Customer_ID,
    c.full_name AS Full_Name,
    COUNT(DISTINCT p.policy_id) AS Policies_Bought,
    COUNT(DISTINCT cl.claim_id) AS Total_Claims,
    COUNT(DISTINCT CASE WHEN cl.fraud_flag='Yes' THEN cl.claim_id END) AS Fraud_Claims,
    ROUND(COUNT(DISTINCT CASE WHEN cl.fraud_flag = 'Yes' THEN cl.claim_id END) * 100.0 /COUNT(DISTINCT cl.claim_id),2) AS Fraud_Ratio,
    SUM(CASE WHEN cl.fraud_flag='Yes' THEN cl.claim_amount ELSE 0 END) AS Total_Fraud_amount
FROM customer_master c LEFT JOIN policy_details p 
USING(customer_id)
LEFT JOIN claim_history cl 
USING(policy_id)
GROUP BY c.customer_id, c.full_name
HAVING Fraud_Claims > 0
ORDER BY Fraud_Claims DESC;
-- ============================================================================================

-- Which policies have the highest potential fraud exposure?
SELECT
	p.policy_id AS Policy_ID,
    p.product_type AS Product_Type,
    COUNT(c.claim_id) AS Total_Claims,
    SUM(CASE 
			WHEN c.fraud_flag='Yes' THEN 1 ELSE 0 END) AS Fraud_Claims
FROM policy_details p LEFT JOIN claim_history c 
USING(policy_id)
GROUP BY p.policy_id, p.product_type 
ORDER BY Fraud_Claims DESC;
-- ============================================================================================

-- Are fraudulent claims concentrated among specific customer risk segments?
WITH customer_master AS (
SELECT 
	customer_id,
    CASE 
		WHEN risk_score BETWEEN 0.0 AND 0.24 THEN 'Low'
        WHEN risk_score BETWEEN 0.25 AND 0.49 THEN 'Moderate'
        WHEN risk_score BETWEEN 0.50 AND 0.74 THEN 'High'
        ELSE 'Very high'
	END AS risk_bucket
FROM customer_master)
SELECT 
	c.risk_bucket AS Risk_Segment,
    COUNT(DISTINCT p.policy_id) AS Total_Policies,
    COUNT(cl.claim_id) AS Total_Claims,
    SUM(CASE WHEN cl.fraud_flag='Yes' THEN 1 ELSE 0 END) AS Fraud_Claims,
    ROUND(SUM(CASE WHEN cl.fraud_flag='Yes' THEN 1 ELSE 0 END) / COUNT(cl.claim_id) * 100, 2) AS Fraud_Ratio
FROM customer_master c JOIN policy_details p 
USING(customer_id)
LEFT JOIN claim_history cl USING(policy_id)
GROUP BY c.risk_bucket
ORDER BY Fraud_Ratio DESC;


-- ============================================================================================
-- 7. AGENT PERFORMANCE
-- ============================================================================================

-- Agent Performance Actual Vs Recorded:
WITH annual_premium AS(
SELECT
	agent_id,
    ROUND(AVG(annual_premium),0) AS avg_annual_premium
FROM policy_details
GROUP BY agent_id)

SELECT 
	a.agent_id AS Agent_ID,
    a.total_policies_sold AS Policies_Sold_Recorded,
    COUNT(DISTINCT p.policy_id) AS Policies_Sold_Calculated,
    a.fraud_association AS Fraud_Association_Recorded,
    COUNT(DISTINCT CASE WHEN c.fraud_flag='YES' THEN claim_id END) AS Fraud_Association_Calculated,
    a.lapsed_policies AS lapsed_policies_recorded,
    COUNT(DISTINCT CASE WHEN p.status='Lapsed' THEN policy_id END) AS Lapsed_Policies_Calculated,
    a.avg_premium_sold AS avg_premium_recorded,
    an.avg_annual_premium AS avg_premium_calculated
FROM agent_info a LEFT JOIN annual_premium an 
USING (agent_id)
LEFT JOIN policy_details p 
USING(agent_id)
LEFT JOIN claim_history c 
USING(policy_id)
GROUP BY a.agent_id, a.total_policies_sold, a.fraud_association, a.lapsed_policies, a.avg_premium_sold,an.avg_annual_premium;
-- ============================================================================================

-- Checking for discrepency in data if any:
WITH final_table AS (
WITH annual_premium AS(
SELECT
	agent_id,
    ROUND(AVG(annual_premium),0) AS avg_annual_premium
FROM policy_details
GROUP BY agent_id)

SELECT 
	a.agent_id AS Agent_ID,
    a.total_policies_sold AS Policies_Sold_Recorded,
    COUNT(DISTINCT p.policy_id) AS Policies_Sold_Calculated,
    a.fraud_association AS Fraud_Association_Recorded,
    COUNT(DISTINCT CASE WHEN c.fraud_flag='YES' THEN claim_id END) AS Fraud_Association_Calculated,
    a.lapsed_policies AS lapsed_policies_recorded,
    COUNT(DISTINCT CASE WHEN p.status='Lapsed' THEN policy_id END) AS Lapsed_Policies_Calculated,
    a.avg_premium_sold AS avg_premium_recorded,
    an.avg_annual_premium AS avg_premium_calculated
FROM agent_info a LEFT JOIN annual_premium an 
USING (agent_id)
LEFT JOIN policy_details p 
USING(agent_id)
LEFT JOIN claim_history c 
USING(policy_id)
GROUP BY a.agent_id, a.total_policies_sold, a.fraud_association, a.lapsed_policies, a.avg_premium_sold,an.avg_annual_premium)
SELECT * 
FROM final_table
WHERE policies_sold_recorded <> Policies_sold_calculated
OR Fraud_Association_Recorded <> Fraud_Association_Calculated
OR lapsed_policies_recorded <> lapsed_policies_calculated;
-- ============================================================================================

-- Which agents sell the most policies?
SELECT 
	agent_id AS Agent_ID,
    region AS Region,
    total_policies_sold AS Total_Policies_Sold
FROM agent_info 
ORDER BY Total_Policies_Sold DESC;
-- ============================================================================================

-- Which agents generate the highest average premium?
SELECT 
	agent_id AS Agent_ID,
    avg_premium_sold AS Average_Premium_Sold
FROM agent_info
ORDER BY avg_premium_sold DESC;
-- ============================================================================================

-- Which agents have the highest claim approval rate?
SELECT
	p.agent_id AS Agent_ID,
    COUNT(c.claim_id) AS Total_Claims,
    COUNT(CASE WHEN c.claim_status = 'Approved' THEN claim_id END) AS Approved_Claims,
    ROUND(COUNT(CASE WHEN c.claim_status='Approved' THEN claim_id END) / 
    COUNT(c.claim_id) *100, 2) AS Approval_Rate
FROM policy_details p JOIN claim_history c 
USING(policy_id)
GROUP BY p.agent_id
ORDER BY Approval_Rate DESC;


-- ============================================================================================
-- 8. CUSTOMER SATISFACTION
-- ============================================================================================

-- What is the overall customer satisfaction score?
SELECT
	ROUND(AVG(satisfaction_score), 2) AS Average_Satisfaction_Score
FROM customer_feedback_surveys;
-- ============================================================================================

-- Does satisfaction score differ by region?
SELECT
	c.region as Region,
    ROUND(AVG(f.satisfaction_score),2) AS Average_Satisfaction_Score
FROM customer_master c JOIN customer_feedback_surveys f 
USING(customer_id)
GROUP BY c.region
ORDER BY Average_Satisfaction_Score DESC;
-- ============================================================================================

-- Does satisfaction score differ by age-group?
WITH age_grouping AS
(
SELECT *,
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN "18-25"
        WHEN age BETWEEN 26 AND 35 THEN "26-35"
        WHEN age BETWEEN 36 AND 45 THEN "36-45"
        WHEN age BETWEEN 46 AND 55 THEN "46-55"
        ELSE "55+" 
	END AS age_group
FROM customer_master
)
SELECT 
	a.age_group AS Age_Group,
    COUNT(f.feedback_id) AS Number_of_Feedbacks,
    ROUND(AVG(f.satisfaction_score), 2) AS Avg_Satisfaction_Score
FROM age_grouping a JOIN customer_feedback_surveys f 
USING(customer_id)
GROUP BY a.age_group 
ORDER BY Avg_Satisfaction_Score DESC;
-- ===============================================================================================

-- Does contacting an agent has an impact on satisfaction?
SELECT
	contacted_agent AS Contacted_Agent,
    COUNT(feedback_id) AS Number_of_feedbacks,
    ROUND(AVG(satisfaction_score),2) AS Avg_Satisfaction_Score
FROM customer_feedback_surveys
GROUP BY contacted_agent
ORDER BY Avg_Satisfaction_Score DESC;
-- ===============================================================================================

-- Which feedback categories have the highest/lowest satisfaction?
SELECT 
	feedback_text AS Feedback_Text,
    COUNT(feedback_id) AS Number_of_Feedbacks,
    ROUND(AVG(satisfaction_score), 2) AS Avg_Satisfaction_Score
FROM customer_feedback_surveys 
GROUP BY feedback_text
ORDER BY Avg_Satisfaction_Score DESC;
-- ===============================================================================================

-- Are customers who filed claims less satisfied?
WITH claim_summary AS (
SELECT 
	customer_id,
    CASE
		WHEN Total_Policies = 0 THEN 'No Policy'
        WHEN Total_Claims > 0 THEN 'Claimed'
        ELSE 'No Claims'
	END AS claim_status
FROM(
SELECT
	c.customer_id,
    COUNT(DISTINCT p.policy_id) AS Total_Policies,
    COUNT(cl.claim_id) AS Total_Claims
FROM customer_master c LEFT JOIN policy_details p 
USING(customer_id)
LEFT JOIN claim_history cl USING(policy_id) 
GROUP BY c.customer_id) AS claim_summary)
SELECT
	c.claim_status as Claim_Status,
    ROUND(AVG(f.satisfaction_score),2) AS Average_Satisfaction_Score
FROM claim_summary c JOIN customer_feedback_surveys f
USING(customer_id) 
GROUP BY c.claim_status;
-- ===============================================================================================
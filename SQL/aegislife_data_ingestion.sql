-- =============================================================================
-- AegisLife Insurance - Risk Analytics and Claim Intelligence
-- =============================================================================
-- Data Ingestion Script: 
-- =======================

USE aegislife_risk_analytics;

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/Dushyant Kumar/OneDrive/Desktop/AegisLife Risk_Analytics/CSVs/customer_master.csv'
INTO TABLE customer_master
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Dushyant Kumar/OneDrive/Desktop/AegisLife Risk_Analytics/CSVs/agent_info.csv'
INTO TABLE agent_info 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Dushyant Kumar/OneDrive/Desktop/AegisLife Risk_Analytics/CSVs/policy_details.csv'
INTO TABLE policy_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Dushyant Kumar/OneDrive/Desktop/AegisLife Risk_Analytics/CSVs/claim_history.csv'
INTO TABLE claim_history
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Dushyant Kumar/OneDrive/Desktop/AegisLife Risk_Analytics/CSVs/customer_feedback_surveys.csv'
INTO TABLE customer_feedback_surveys
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
-- ==========================================================
-- AegisLife Insurance - Risk Analytics & Claim Intelligence
-- Database DDL Script
-- ==========================================================

CREATE DATABASE IF NOT EXISTS aegislife_risk_analytics;

USE aegislife_risk_analytics;


DROP TABLE IF EXISTS customer_feedback_surveys;
DROP TABLE IF EXISTS claim_history;
DROP TABLE IF EXISTS policy_details;
DROP TABLE IF EXISTS agent_info;
DROP TABLE IF EXISTS customer_master;



CREATE TABLE customer_master
(
	customer_id           VARCHAR(20) PRIMARY KEY,
    full_name             VARCHAR(25) NOT NULL,
    age                   INT         NOT NULL CHECK(age BETWEEN 18 AND 130),
    gender                VARCHAR(10) NOT NULL,
    marital_status        VARCHAR(15) NOT NULL,
    occupation            VARCHAR(15) NOT NULL,
    region                VARCHAR(20) NOT NULL,
    smoking_status        VARCHAR(3)  NOT NULL,
    pre_existing_illness  VARCHAR(3)  NOT NULL,
    risk_score            DECIMAL(4,2)         NOT NULL CHECK(risk_score BETWEEN 0 AND 1),
    date_joined           DATE        NOT NULL    
);


CREATE TABLE agent_info 
(
agent_id            VARCHAR(20) PRIMARY KEY,
region              VARCHAR(20) NOT NULL,
join_date           DATE        NOT NULL,
total_policies_sold INT         NOT NULL DEFAULT 0,
lapsed_policies     INT         NOT NULL DEFAULT 0,
avg_premium_sold    INT         NOT NULL DEFAULT 0,
fraud_association   INT         NOT NULL DEFAULT 0
);


CREATE TABLE policy_details
(
policy_id         VARCHAR(20) PRIMARY KEY,
customer_id       VARCHAR(20) NOT NULL,
product_type      VARCHAR(20) NOT NULL,
coverage_amount   INT         NOT NULL,
annual_premium    INT         NOT NULL,
policy_start_date DATE        NOT NULL,
policy_end_date   DATE        NOT NULL,
agent_id          VARCHAR(20) NOT NULL,
status            VARCHAR(15) NOT NULL,

CONSTRAINT policy_customer FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id),
CONSTRAINT policy_agent    FOREIGN KEY (agent_id) REFERENCES agent_info(agent_id)
);


CREATE TABLE claim_history
(
claim_id VARCHAR(20) PRIMARY KEY,
policy_id VARCHAR(20) NOT NULL,
claim_date DATE       NOT NULL,
claim_amount INT      NOT NULL,
claim_status VARCHAR(15) NOT NULL,
claim_type   VARCHAR(15) NOT NULL,
fraud_flag   VARCHAR(3)  NOT NULL,

CONSTRAINT claim_policy FOREIGN KEY (policy_id) REFERENCES policy_details(policy_id)
);


CREATE TABLE customer_feedback_surveys
(
feedback_id VARCHAR(20) PRIMARY KEY,
customer_id VARCHAR(20) NOT NULL,
date_submitted DATE     NOT NULL,
feedback_text  TEXT     NOT NULL,
satisfaction_score INT  NOT NULL CHECK(satisfaction_score BETWEEN 1 AND 5),
contacted_agent    VARCHAR(3) NOT NULL,
referred_claim     VARCHAR(3) NOT NULL,

CONSTRAINT feedback_customer FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);
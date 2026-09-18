USE esg_project_db;

-- 1. Create Tables
CREATE TABLE dim_companies (
    Company_ID VARCHAR(10) PRIMARY KEY,
    Company_Name VARCHAR(100),
    Ticker VARCHAR(20),
    Industry VARCHAR(50),
    ProfitMargin DOUBLE,
    MarketCap_Billions DOUBLE,
    GrowthRate DOUBLE
);

CREATE TABLE dim_esg_scores (
    Company_ID VARCHAR(10) PRIMARY KEY,
    ESG_Overall INT,
    WomenWorkforce_Pct DOUBLE,
    FOREIGN KEY (Company_ID) REFERENCES dim_companies(Company_ID)
);

CREATE TABLE fact_environmental (
    Fact_ID INT AUTO_INCREMENT PRIMARY KEY,
    Company_ID VARCHAR(10),
    CarbonEm_MT DOUBLE,
    WaterUsage_M3 DOUBLE,
    EnergyConsumption_MWh INT,
    FOREIGN KEY (Company_ID) REFERENCES dim_companies(Company_ID)
);

-- Import data using excel


USE esg_project_db;

-- Query 1: Calculate carbon intensity to compare companies fairly based on their financial size
SELECT 
    c.Company_Name,
    c.Industry,
    c.MarketCap_Billions,
    f.CarbonEm_MT,
    ROUND((f.CarbonEm_MT / c.MarketCap_Billions), 4) AS Carbon_Intensity_Ratio
FROM dim_companies c
JOIN fact_environmental f 
    ON c.Company_ID = f.Company_ID
ORDER BY Carbon_Intensity_Ratio DESC;


-- Query 2: Get sector averages for ESG scores, women workforce, and total carbon output
SELECT 
    c.Industry,
    COUNT(c.Company_ID) AS Total_Companies,
    ROUND(AVG(e.ESG_Overall), 2) AS Avg_Sector_ESG_Score,
    ROUND(AVG(e.WomenWorkforce_Pct) * 100, 2) AS Avg_Sector_Women_Workforce_Pct,
    ROUND(SUM(f.CarbonEm_MT), 2) AS Total_Sector_Carbon_MT
FROM dim_companies c
JOIN dim_esg_scores e 
    ON c.Company_ID = e.Company_ID
JOIN fact_environmental f 
    ON c.Company_ID = f.Company_ID
GROUP BY c.Industry
ORDER BY Avg_Sector_ESG_Score DESC;


-- Query 3: Find high-profit companies that have weak ESG scores (under 65)
SELECT 
    c.Company_Name,
    c.Industry,
    ROUND(c.ProfitMargin * 100, 2) AS Profit_Margin_Pct,
    e.ESG_Overall
FROM dim_companies c
JOIN dim_esg_scores e 
    ON c.Company_ID = e.Company_ID
WHERE c.ProfitMargin > 0.0500 AND e.ESG_Overall < 65
ORDER BY c.ProfitMargin DESC;


-- Query 4: Rank companies within their own industry by their female workforce percentage
SELECT 
    c.Company_Name,
    c.Industry,
    ROUND(e.WomenWorkforce_Pct * 100, 2) AS Workforce_Women_Pct,
    RANK() OVER (PARTITION BY c.Industry ORDER BY e.WomenWorkforce_Pct DESC) AS Sector_Diversity_Rank
FROM dim_companies c
JOIN dim_esg_scores e 
    ON c.Company_ID = e.Company_ID;



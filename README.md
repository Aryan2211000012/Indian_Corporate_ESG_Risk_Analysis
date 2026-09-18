# Indian_Corporate_ESG_Risk_Analysis

An end-to-end data analytics project establishing a relational data pipeline to evaluate corporate sustainability, workforce diversity, and climate risk exposure across 10 market-leading Indian corporate assets. This project spans data staging, SQL relational warehousing, advanced business logic querying, and an interactive Power BI executive reporting dashboard.

---

## Project Overview & Business Value
Investment committees and fund managers require scalable systems to evaluate corporate assets beyond traditional financial statements. This project transforms raw corporate data into interactive portfolio intelligence, allowing stakeholders to isolate compliance blind spots, evaluate sector performance benchmarks, and track social pillar metrics.

### Key Analytical Insights Established:
* **Normalized Climate Risk:** Evaluating carbon emissions against absolute financial scale reveals that while energy giants lead in total emissions volume, heavy engineering operations carry a significantly higher carbon footprint relative to their financial size.
* **Social Pillar Leadership:** The Technology sector establishes the core portfolio benchmark for workforce diversity, driven by technology assets leading with a 37.0% female workforce participation rate.
* **Regulatory Compliance Screening:** Highly profitable assets carrying a consolidated ESG compliance rating below 65 are isolated for active risk mitigation to protect the fund against emerging SEBI regulatory adjustments.

---

## Data Architecture & Relational Schema (Star Schema)
To eliminate data redundancy and mirror enterprise database standards, the data model was broken down from a flat spreadsheet format into a clean relational Star Schema structure connected via `Company_ID` keys. 

The raw source tables were staged in Excel and imported directly into a localized MySQL Server instance to establish the data warehouse:

* **`dim_companies` (Dimension Table):** Captures fixed organizational profiles including company identities, tickers, industry sectors, market valuation scale, and baseline profit margins.
* **`dim_esg_scores` (Dimension Table):** Tracks qualitative ESG ratings and quantitative human capital workforce metrics.

* **`fact_environmental` (Fact Table):** Houses continuous, heavy resource draw metrics including greenhouse gas emissions, water volume footprints, and utility
*
* power consumption.

---

## Phase 1: Database Setup & Data Engineering (SQL DDL)

The following relational schema structure was executed in MySQL Workbench to initialize the table containers and enforce relational database integrity via Primary Keys, Auto-Increments, and Foreign Keys prior to loading data tables via the source files:

```sql
CREATE DATABASE esg_project_db;
USE esg_project_db;

-- 1. Create Company Profile Dimension Table
CREATE TABLE dim_companies (
    Company_ID VARCHAR(10) PRIMARY KEY,
    Company_Name VARCHAR(100),
    Ticker VARCHAR(20),
    Industry VARCHAR(50),
    ProfitMargin DOUBLE,
    MarketCap_Billions DOUBLE,
    GrowthRate DOUBLE
);

-- 2. Create ESG and Social Dimension Table
CREATE TABLE dim_esg_scores (
    Company_ID VARCHAR(10) PRIMARY KEY,
    ESG_Overall INT,
    WomenWorkforce_Pct DOUBLE,
    FOREIGN KEY (Company_ID) REFERENCES dim_companies(Company_ID)
);

-- 3. Create Core Footprint Fact Table
CREATE TABLE fact_environmental (
    Fact_ID INT AUTO_INCREMENT PRIMARY KEY,
    Company_ID VARCHAR(10),
    CarbonEm_MT DOUBLE,
    WaterUsage_M3 DOUBLE,
    EnergyConsumption_MWh INT,
    FOREIGN KEY (Company_ID) REFERENCES dim_companies(Company_ID)
);
```

---

## Phase 2: Exploratory Data Analysis & Business Intelligence (SQL Queries)

Four specific analytical queries were engineered to synthesize data points across tables using explicit `JOIN` logic, mathematical groupings, and localized partition windows:

### Query 1: Normalizing Climate Risk via Carbon Intensity
*Calculates how much carbon a company emits relative to its market size, providing an apples-to-apples baseline comparing asset environmental efficiency.*
```sql
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
```

### Query 2: Cross-Pillar Sector Aggregations
*Groups individual corporate metrics to evaluate macroeconomic trends, overall scores, and baseline diversity numbers across distinct industry clusters.*
```sql
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
```

### Query 3: Strategic Portfolio Outlier Screening
*Identifies high-profit operations with weak sustainability ratings (scores under 65) that present substantial regulatory risk exposure to fund investors.*
```sql
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
```

### Query 4: Localized Industry Diversity Leaderboard (Window Function)
*Ranks companies by gender diversity purely within their own industry sectors using a localized window partition operation.*
```sql
SELECT 
    c.Company_Name,
    c.Industry,
    ROUND(e.WomenWorkforce_Pct * 100, 2) AS Workforce_Women_Pct,
    RANK() OVER (PARTITION BY c.Industry ORDER BY e.WomenWorkforce_Pct DESC) AS Sector_Diversity_Rank
FROM dim_companies c
JOIN dim_esg_scores e 
    ON c.Company_ID = e.Company_ID;
```

---

## Phase 3: Reporting & Visualization (Power BI Dashboard)

An interactive, custom-themed dashboard application was engineered using an executive-level layout style to deliver high-density data tracking across three layers:

1. **Executive KPI Layer (Macro Summary):** High-impact scorecard callout cards computing total portfolio financial value, average ESG compliance rating, and macro gender diversity rates.
2. **Distribution & Operations Layer (Middle Section):** A horizontal bar chart displaying financial scale tracking next to a customized donut chart demonstrating normalized carbon intensity shares across market segments.
3. **Advanced Risk-Return Visual (Right Panel):** A 4-Quadrant Scatter Chart mapping Corporate Profit Margins against ESG Compliance Scores to instantly segment premium safe-haven assets away from low-compliance liabilities.
4. **Granular Drill-Down Layer (Base Layer):** A comprehensive asset mapping report matrix detailing granular organizational data lines across E and S parameters.
5. **Data Modeling & Interactivity:** Features an advanced **DAX Calculated Column** utilizing relational links (`DIVIDE` with `RELATED`) to execute clean metrics calculations dynamically across a synchronized industry slicer button panel.

---

## Technical Competencies Demonstrated:
* **Database Modeling:** Star Schema Design, Data Normalization, Primary/Foreign Key Constraint Mapping.
* **SQL Operations:** Relational Multi-Table Connections, Aggregate Groupings, Window Partitioning Functions (`RANK() OVER`).
* **Power BI & Business Intelligence:** DAX Programming, Visual Framework Hierarchy, Interactive Slicing Controls, Theme Integration.

SELECT *
FROM WORKSPACE.DEFAULT.COVIDINFO
LIMIT 1000 ;

----------------------------------------------------------------------------
--EXPLORATORY DATA ANALYIS
--------------------------------------------------------------------------
---1.CHECKING DATE RANGE
----------------------------------------
---WHEN FIRST WAS THE DATA COLLECTED 
SELECT MIN(Date)AS start_date
FROM WORKSPACE.DEFAULT.COVIDINFO;

---WHEN DATA WAS LAST COLLECTED: 
SELECT MAX(Date)AS latest_date
FROM WORKSPACE.DEFAULT.COVIDINFO;
--------------------------------------------------------------------------
--2.FINDING DIFFERENT COUNTRIES
SELECT DISTINCT Country
FROM WORKSPACE.DEFAULT.COVIDINFO ;
----------------------------------------------------------------------------
--3.FINDING  DIFFERENT DOMINANT VARIANT
SELECT DISTINCT `Dominant Variant`
FROM WORKSPACE.DEFAULT.COVIDINFO ;
----------------------------------------------------------------------------
--4.FINDING  DIFFERENT COVID RESTRICTIONS LEVEL
SELECT DISTINCT `COVID Restrictions Level`
FROM WORKSPACE.DEFAULT.COVIDINFO ;

----------------------------------------------------------------------------
--5.LOOKING AT COUNTRY POPULATION
SELECT DISTINCT Country 
FROM WORKSPACE.DEFAULT.COVIDINFO 
WHERE Population <50000000 ;

SELECT DISTINCT Country
FROM WORKSPACE.DEFAULT.COVIDINFO 
WHERE Population BETWEEN 5000000 AND 10000000 ;

SELECT DISTINCT Country 
FROM WORKSPACE.DEFAULT.COVIDINFO 
WHERE Population >70000000 ;

SELECT DISTINCT Country
FROM WORKSPACE.DEFAULT.COVIDINFO 
WHERE Population BETWEEN 85000000 AND 100000000 ;

-----------------------------------------------------------------------------
--6. TOP 10 TOTAL DEATHS PER COUNTRY
SELECT
    Country,
    SUM(`New Deaths`) AS total_deaths
FROM WORKSPACE.DEFAULT.COVIDINFO 
GROUP BY Country
ORDER BY total_deaths DESC
LIMIT 10 ;
------------------------------------------------------------------------------
--7.DEATH RATE PER COUNTRY
SELECT
    Country,
    SUM(`New Deaths`) AS total_deaths,
    SUM(`New Cases`) AS total_cases,
    ROUND(
        SUM(`New Deaths`) * 100.0 / NULLIF(SUM(`New Cases`), 0),
        2
    ) AS death_rate_pct
FROM workspace.default.covidinfo
GROUP BY Country
ORDER BY death_rate_pct DESC;
------------------------------------------------------------------------------
--8.COUNTRIES WITH HIGHEST HOSPITAL ADMISSIONS
SELECT
    Country,
    SUM(`Hospital Admissions`) AS total_hospital_admissions
FROM workspace.default.covidinfo
GROUP BY Country
ORDER BY total_hospital_admissions DESC
LIMIT 10 ;

------------------------------------------------------------------------------
--9.COUNTRIES WITH THE HIGHEST ICU ADMISSIONS
SELECT
    Country,
    SUM(`ICU Admissions`) AS total_icu_admissions
FROM workspace.default.covidinfo
GROUP BY Country
ORDER BY total_icu_admissions DESC;
----------------------------------------------------------------------------
--10.COVID CASES PER MONTH
SELECT
    Month,
    `Month Name`,
    SUM(`New Cases`) AS total_cases
FROM workspace.default.covidinfo
GROUP BY Month, `Month Name`
ORDER BY Month;

---------------------------------------------------------------------------
--11.DEATHS PER MONTH
SELECT
    Month,
    `Month Name`,
    SUM(`New deaths`) AS total_deaths
FROM workspace.default.covidinfo
GROUP BY Month, `Month Name`
ORDER BY Month;
-------------------------------------------------------------------------
---DATA CLEANING
-------------------------------------------------------------------------
DESCRIBE workspace.default.covidinfo;

---REMOVING COLUMNS
ALTER TABLE workspace.default.covidinfo
DROP COLUMNS (
    `Positive Test Rate`,
    `First Dose Pct`,
    `Fully Vaccinated Pct`,
    `Booster Pct`,
    `Cases Per 100k`,
    `Deaths Per 100k`,
    `Hospital Bed Occupancy Pct`,
    `COVID Tests`
);

DESCRIBE workspace.default.covidinfo; --CHECKING IF THE COLUMNS WERE ACTUALLY DROPPED

--------------------------------------------------------------------------------------
--LOOKING FOR NULLS PER COLUMN
SELECT
    COUNT(*) AS `Total Rows`,

    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS `Date Nulls`,
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS `Country Nulls`,
    SUM(CASE WHEN Population IS NULL THEN 1 ELSE 0 END) AS `Population Nulls`,
    SUM(CASE WHEN `New Cases` IS NULL THEN 1 ELSE 0 END) AS `New Cases Nulls`,
    SUM(CASE WHEN `New Deaths` IS NULL THEN 1 ELSE 0 END) AS `New Deaths Nulls`,
    SUM(CASE WHEN `Hospital Admissions` IS NULL THEN 1 ELSE 0 END) AS `Hospital Admissions Nulls`,
    SUM(CASE WHEN `ICU Admissions` IS NULL THEN 1 ELSE 0 END) AS `ICU Admissions Nulls`,
    SUM(CASE WHEN `COVID Restrictions Level` IS NULL THEN 1 ELSE 0 END) AS `Restrictions Nulls`,
    SUM(CASE WHEN `Dominant Variant` IS NULL THEN 1 ELSE 0 END) AS `Variant Nulls`,
    SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS `Year Nulls`,
    SUM(CASE WHEN Month IS NULL THEN 1 ELSE 0 END) AS `Month Nulls`,
    SUM(CASE WHEN `Month Name` IS NULL THEN 1 ELSE 0 END) AS `Month Name Nulls`,
    SUM(CASE WHEN Quarter IS NULL THEN 1 ELSE 0 END) AS `Quarter Nulls`,
    SUM(CASE WHEN `Day Name` IS NULL THEN 1 ELSE 0 END) AS `Day Name Nulls`

FROM workspace.default.covidinfo;

--REPLACING NULLS
UPDATE workspace.default.covidinfo
SET `New Deaths` = 0
WHERE `New Deaths` IS NULL;

UPDATE workspace.default.covidinfo
SET `ICU Admissions` = 0
WHERE `ICU Admissions` IS NULL;

--CHECKING IF NULLS ARE REPLACED
SELECT
    SUM(CASE WHEN `New Deaths` IS NULL THEN 1 ELSE 0 END) AS `New Deaths Nulls`,
    SUM(CASE WHEN `ICU Admissions` IS NULL THEN 1 ELSE 0 END) AS `ICU Admissions Nulls`
FROM workspace.default.covidinfo;
-------------------------------------------------------------------------------------------
--LOOKING FOR DUPLICATES
SELECT
    *,
    COUNT(*) AS `Duplicate Count`
FROM workspace.default.covidinfo
GROUP BY
    Date,
    Country,
    Population,
    `New Cases`,
    `New Deaths`,
    `Hospital Admissions`,
    `ICU Admissions`,
    `COVID Restrictions Level`,
    `Dominant Variant`,
    Year,
    Month,
    `Month Name`,
    Quarter,
    `Day Name`
HAVING COUNT(*) > 1
ORDER BY `Duplicate Count` DESC;

--REMOVING DUPLICATES
DELETE FROM workspace.default.covidinfo
WHERE concat_ws('|', Date, Country, Population, `New Cases`, `New Deaths`,
       `Hospital Admissions`, `ICU Admissions`,
       `COVID Restrictions Level`, `Dominant Variant`,
       Year, Month, `Month Name`, Quarter, `Day Name`)
IN (
    SELECT concat_ws('|', Date, Country, Population, `New Cases`, `New Deaths`,
           `Hospital Admissions`, `ICU Admissions`,
           `COVID Restrictions Level`, `Dominant Variant`,
           Year, Month, `Month Name`, Quarter, `Day Name`)
    FROM workspace.default.covidinfo
    GROUP BY
        Date, Country, Population, `New Cases`, `New Deaths`,
        `Hospital Admissions`, `ICU Admissions`,
        `COVID Restrictions Level`, `Dominant Variant`,
        Year, Month, `Month Name`, Quarter, `Day Name`
    HAVING COUNT(*) > 1
);

SELECT *
FROM WORKSPACE.DEFAULT.COVIDINFO



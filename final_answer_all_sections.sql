----  CREATE DEFORESTATION VIEW ----
DROP VIEW IF EXISTS forestation;
CREATE VIEW forestation
AS
SELECT fa.country_code AS "country_code", 
		fa.country_name AS "country_name",
		fa.year AS "year",
		fa.forest_area_sqkm AS "forest_area",
		(la.total_area_sq_mi * 2.59 ) AS "total_area",
		rg.region AS "region",
		rg.income_group AS "income_group",
		ROUND((fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59 ) ) * 100 , 2) AS "percentage_forest"
FROM forest_area fa
	JOIN land_area la
		ON la.country_code = fa.country_code AND fa.year = la.year
 	JOIN regions as rg
		ON rg.country_code = la.country_code;


-- ################     GLOBAL SITUATION    ################

----  QUESTIONS ----

-- a. What was the total forest area (in sq km) of the world in 1990? 
-- Please keep in mind that you can use the country record denoted as “World" in the region table.

    SELECT fa.forest_area_sqkm
    FROM forest_area fa
        JOIN regions rg
        ON rg.country_code = fa.country_code

    WHERE rg.country_name = 'World' AND fa.year = 1990

    -- ANSWER = 41282694.9

        --- From View ---

    SELECT "forest_area"
    FROM forestation
    WHERE "country_name" = 'World' AND "year" = 1990

-- b. What was the total forest area (in sq km) of the world in 2016?
-- Please keep in mind that you can use the country record in the table is denoted as “World.”

    SELECT fa.forest_area_sqkm
    FROM forest_area fa
        JOIN regions rg
        ON rg.country_code = fa.country_code

    WHERE rg.country_name = 'World' AND fa.year = 2016
    
    -- ANSWER = 39958245.9

            --- Double-check ---

    SELECT SUM(fa.forest_area_sqkm)
    FROM forest_area fa
        JOIN regions rg
        ON rg.country_code = fa.country_code

    WHERE fa.year = 2016 AND rg.country_name != 'World'

        --- From View ---

    SELECT "forest_area"
    FROM forestation
    WHERE "country_name" = 'World' AND "year" = 2016

    -- ANSWER = 39867188.050510661 - checks

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?


SELECT	
	(SELECT fa.forest_area_sqkm AS total_1990
    	FROM forest_area fa
        	JOIN regions rg
        	ON rg.country_code = fa.country_code
		WHERE rg.country_name = 'World' AND fa.year = 1990)
		
	- (SELECT fa.forest_area_sqkm AS total_2016
    	FROM forest_area fa
        	JOIN regions rg
        	ON rg.country_code = fa.country_code
		WHERE rg.country_name = 'World' AND fa.year = 2016)

AS change_forest_area_sqkm

        --- From View ---

SELECT	
	(SELECT forest_area AS total_1990
    	FROM forestation   	
		WHERE country_name = 'World' AND year = 1990)
		
	- (SELECT forest_area 
    	FROM forestation
		WHERE country_name = 'World' AND year = 2016)

AS change_forest_area

-- d. What was the percent change in forest area of the world between 1990 and 2016?


SELECT	
    (
	(	
		(SELECT fa.forest_area_sqkm AS total_1990
    	FROM forest_area fa
        	JOIN regions rg
        	ON rg.country_code = fa.country_code
		WHERE rg.country_name = 'World' AND fa.year = 1990)
		
	- (SELECT fa.forest_area_sqkm AS total_2016
    	FROM forest_area fa
        	JOIN regions rg
        	ON rg.country_code = fa.country_code
		WHERE rg.country_name = 'World' AND fa.year = 2016)
	)/
	(
		(SELECT fa.forest_area_sqkm AS total_1990
    	FROM forest_area fa
        	JOIN regions rg
        	ON rg.country_code = fa.country_code
		WHERE rg.country_name = 'World' AND fa.year = 1990)
		
	) )* 100
AS percentage_change_forest_area_sqkm


-- e. If you compare the amount of forest area lost between 1990 and 2016, 
-- to which country's total area in 2016 is it closest to?

WITH change_forest_area_sqkm AS
	(SELECT	
	 (
	(SELECT fa.forest_area_sqkm AS total_1990
    	FROM forest_area fa
        	JOIN regions rg
        	ON rg.country_code = fa.country_code
		WHERE rg.country_name = 'World' AND fa.year = 1990)
		
	- (SELECT fa.forest_area_sqkm AS total_2016
    	FROM forest_area fa
        	JOIN regions rg
        	ON rg.country_code = fa.country_code
		WHERE rg.country_name = 'World' AND fa.year = 2016) 
		) / 2.59 AS difference
	),
	
	country_total_area AS 
	(
	SELECT country_name,
		total_area_sq_mi
	FROM land_area
	WHERE year = 2016
	)
	
SELECT country_name,
		ABS(total_area_sq_mi - 
	(select difference 
	FROM change_forest_area_sqkm)) AS substraction
FROM country_total_area
ORDER BY  substraction
LIMIT 1


-- Peru's forest are in 2016 - Check

SELECT * FROM forestation
WHERE fa_country_name = 'Peru' and fa_year = 2016



-- ################     REGIONAL OUTLOOK    ################


-- Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).
-- Innitital Table -- 

 -- TEST 
SELECT region,
		ROUND(SUM(forest_area), 2) AS forests,
		ROUND(SUM(total_area), 2) AS total_area, 
		ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
		"year"
FROM forestation
WHERE "year" IN (1990, 2016)
GROUP BY "year", "region"
ORDER BY "year";



SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" IN (1990, 2016) AND region != 'World'
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY region, year;


SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" IN (1990) AND region != 'World'
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY Regional_forest_percentage DESC;


    --- 2016 ---
-- In 2016, the percent of the total land area of the world designated as forest was

SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" = 2016 AND region = 'World'
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY region, year;


-- The region with the highest relative forestation was__________________, with __________________

SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" = 2016
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY  Regional_forest_percentage DESC
LIMIT 1;

-- and the region with the lowest relative forestation was __________________, with __________________% forestation.

SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" = 2016
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY  Regional_forest_percentage ASC
LIMIT 1;

   
    --- 1990 ---

-- In 1990, the percent of the total land area of the world designated as forest was __________________. 

SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" = 1990 AND region = 'World'
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY region, year;

-- The region with the highest relative forestation was__________________, with __________________%, 

SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" = 1990
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY  Regional_forest_percentage DESC
LIMIT 1

-- and the region with the lowest relative forestation was __________________, with __________________% forestation.

SELECT region, 
		SUM(forest_percentage) AS Regional_forest_percentage,
		"year"
FROM
	( 
	SELECT region,
			ROUND(SUM(forest_area) / SUM(total_area) * 100 , 2) AS forest_percentage,
			"year"
	FROM forestation
	WHERE "year" = 1990
	GROUP BY "year", "region"
	ORDER BY "year") AS "years_regions"
GROUP BY region, year
ORDER BY  Regional_forest_percentage ASC
LIMIT 1



--  ################ COUNTRY-LEVEL DETAIL   ################ 


-- Instructions:
-- a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?

SELECT 	f1.country_code,
		f1.forest_area,
		f2.country_name,
		f2.forest_area,
        f1.forest_area - f2.forest_area as forest_area_change
FROM forestation f1
	LEFT JOIN forestation f2
 		ON f1.country_code = f2.country_code
		AND f1.year = 1990
		AND f1.country_code != 'WLD'
		AND f2.year = 2016
		AND f2.country_name != 'World'
	WHERE f1.forest_area IS NOT NULL
		AND f2.forest_area IS NOT NULL
ORDER BY forest_area_change DESC
LIMIT 5


-- Country with the largest increase in forest area : answer China

SELECT 	f1.country_code,
		f1.forest_area,
		f2.country_name,
		f2.forest_area,
        f1.forest_area - f2.forest_area as forest_area_change
FROM forestation f1
	LEFT JOIN forestation f2
 		ON f1.country_code = f2.country_code
		AND f1.year = 1990
		AND f1.country_code != 'WLD'
		AND f2.year = 2016
		AND f2.country_name != 'World'
	WHERE f1.forest_area IS NOT NULL
		AND f2.forest_area IS NOT NULL
ORDER BY forest_area_change ASC
LIMIT 1



    -- LARGEST INCREASE 
-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?


SELECT f1.country_code,
		f1.percentage_forest, 
		f2.percentage_forest,
		f2.country_name,
        f1.percentage_forest - f2.percentage_forest as forest_area_change
FROM forestation f1
	LEFT JOIN forestation f2
 		ON f1.country_code = f2.country_code
		AND f1.year = 1990
		AND f2.year = 2016
	WHERE f1.percentage_forest IS NOT NULL
		AND f2.percentage_forest IS NOT NULL
ORDER BY forest_area_change DESC
LIMIT 5


--  country with largest incresae percentage-wise. Answer: Iceland

SELECT 	f2.country_name,
		f1.region,
        ((f2.forest_area - f1.forest_area) / f1.forest_area) * 100 as forest_area_change
FROM forestation f1
	LEFT JOIN forestation f2
 		ON f1.country_code = f2.country_code
		AND f1.year = 1990
		AND f1.country_code != 'WLD'
		AND f2.year = 2016
		AND f2.country_name != 'World'
	WHERE f1.forest_area IS NOT NULL
		AND f2.forest_area IS NOT NULL
ORDER BY forest_area_change DESC
LIMIT 1



-- Table 3.1 

SELECT 	f2.country_name,
		f1.region,
        f1.forest_area - f2.forest_area as forest_area_change
FROM forestation f1
	LEFT JOIN forestation f2
 		ON f1.country_code = f2.country_code
		AND f1.year = 1990
		AND f1.country_code != 'WLD'
		AND f2.year = 2016
		AND f2.country_name != 'World'
	WHERE f1.forest_area IS NOT NULL
		AND f2.forest_area IS NOT NULL
ORDER BY forest_area_change DESC
LIMIT 5


-- Table 3.2 

SELECT 	f2.country_name,
		f1.region,
        ((f2.forest_area - f1.forest_area) / f1.forest_area) * 100 as forest_area_change
FROM forestation f1
	LEFT JOIN forestation f2
 		ON f1.country_code = f2.country_code
		AND f1.year = 1990
		AND f1.country_code != 'WLD'
		AND f2.year = 2016
		AND f2.country_name != 'World'
	WHERE f1.forest_area IS NOT NULL
		AND f2.forest_area IS NOT NULL
ORDER BY forest_area_change ASC
LIMIT 5

-- c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

WITH 
	forest1 AS
	(SELECT *
	FROM forestation
	WHERE year = 2016
 		AND percentage_forest IS NOT NULL
		AND region != 'World'),

	quartile AS 
	(SELECT *,
	 CASE
	 	WHEN percentage_forest > 75
	 		THEN '4th'
	 	WHEN percentage_forest <= 75 AND percentage_forest > 50
	 		THEN '3rd'
	 	WHEN percentage_forest <= 50 AND percentage_forest > 25
	 		THEN '2nd'
	 	ELSE '1st'
	 	END AS quarter
	FROM forest1 )

SELECT quarter,
		COUNT(*)
FROM quartile
GROUP BY quarter
ORDER BY 2 DESC;


-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.



WITH 
	forest1 AS
	(SELECT *
	FROM forestation
	WHERE year = 2016
 		AND percentage_forest IS NOT NULL
		AND region != 'World'),

	quartile AS 
	(SELECT *,
	 CASE
	 	WHEN percentage_forest > 75
	 		THEN '4th'
	 	WHEN percentage_forest <= 75 AND percentage_forest > 50
	 		THEN '3rd'
	 	WHEN percentage_forest <= 50 AND percentage_forest > 25
	 		THEN '2nd'
	 	ELSE '1st'
	 	END AS quarter
	FROM forest1 )

SELECT country_name,
		region,
		percentage_forest 
FROM quartile
	WHERE quarter = '4th'
	ORDER BY percentage_forest DESC

-- e. How many countries had a percent forestation higher than the United States in 2016?

	--list the countries

SELECT country_name,
		percentage_forest
FROM forestation
WHERE percentage_forest >
		(SELECT percentage_forest 
		FROM forestation
		WHERE year = 2016
			AND country_code = 'USA')
	AND year = 2016	
ORDER BY percentage_forest DESC


-- count the countries

SELECT count(*)
FROM forestation
WHERE percentage_forest >
		(SELECT percentage_forest 
		FROM forestation
		WHERE year = 2016
			AND country_code = 'USA')
	AND year = 2016	


-- 94 countries

-- Table 3.3

WITH 
	forest1 AS
	(SELECT *
	FROM forestation
	WHERE year = 2016
 		AND percentage_forest IS NOT NULL
		AND region != 'World'),

	quartile AS 
	(SELECT *,
	 CASE
	 	WHEN percentage_forest > 75
	 		THEN '4th'
	 	WHEN percentage_forest <= 75 AND percentage_forest > 50
	 		THEN '3rd'
	 	WHEN percentage_forest <= 50 AND percentage_forest > 25
	 		THEN '2nd'
	 	ELSE '1st'
	 	END AS quarter
	FROM forest1 )

SELECT quarter,
		COUNT(*)
FROM quartile
GROUP BY quarter
ORDER BY quarter;



--table 3.4

WITH 
	forest1 AS
	(SELECT *
	FROM forestation
	WHERE year = 2016
 		AND percentage_forest IS NOT NULL
		AND region != 'World'),

	quartile AS 
	(SELECT *,
	 CASE
	 	WHEN percentage_forest > 75
	 		THEN '4th'
	 	WHEN percentage_forest <= 75 AND percentage_forest > 50
	 		THEN '3rd'
	 	WHEN percentage_forest <= 50 AND percentage_forest > 25
	 		THEN '2nd'
	 	ELSE '1st'
	 	END AS quarter
	FROM forest1 )

SELECT country_name,
		region,
		percentage_forest 
FROM quartile
	WHERE quarter = '4th'
	ORDER BY percentage_forest DESC
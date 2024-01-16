-- POPULATION ANALYSIS
-- A focus on county population, state population, and population density.

-- creating table
CREATE TABLE us_counties_2019 (
    state_fips text,
    county_fips text,
    region smallint,
    state_name text,
    county_name text,
    area_land bigint,
    area_water bigint,
    internal_point_lat numeric(10,7),
    internal_point_lon numeric(10,7),
    pop_est_2018 integer,
    pop_est_2019 integer,
    births_2019 integer,
    deaths_2019 integer,
    international_migr_2019 integer,
    domestic_migr_2019 integer,
    residual_2019 integer,
    CONSTRAINT counties_2019_key PRIMARY KEY (state_fips, county_fips));
		
-- import dataset
COPY us_counties_2019
FROM '/Users/tiffanyng/Desktop/census_analysis/us_counties_pop_est_2019.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM us_counties_2019;

-- Total Population by states - top 5, along with mean and median county populations for these states
SELECT state_name, SUM(pop_est_2019) AS state_population, 
	ROUND(AVG(pop_est_2019),0) AS avg_county_pop, 
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY pop_est_2019) AS median_county_pop
	FROM us_counties_2019
GROUP BY state_name
ORDER BY state_population DESC LIMIT 5;
-- California has the highest population out of all the states
-- California has a much higher average county population compared to other high population states!
-- California and Florida both have high median county populations
-- Texas has a MUCH lower average and median county population than California (and other top 5 states) despite being the second most populated state!


-- Does Texas have a much higher amount of counties than California, so the population is distributed over more counties?
-- Number of counties in Texas vs. California:
SELECT state_name, COUNT(county_name) FROM us_counties_2019
WHERE state_name = 'California' OR state_name = 'Texas'
GROUP BY state_name;
-- Texas has 254 counties compared to 58 in California. 
-- Texas has a low mean and median county population compared to California due to having more counties!

-- Why does Texas have more counties than California?
-- Closer look at total area in Texas compared to California
SELECT state_name, SUM(area_land + area_water) FROM us_counties_2019
WHERE state_name = 'California' OR state_name = 'Texas'
GROUP BY state_name;
-- Texas has a much larger total area than California. 
-- The higher amount of counties seems to be due to having much more total area.


-- COUNTY POPULATION ANALYSIS
-- finding mean and median population county population in 2019
SELECT ROUND(AVG(pop_est_2019),0), PERCENTILE_CONT(0.5)
WITHIN GROUP (ORDER BY pop_est_2019) FROM us_counties_2019;
-- the mean population is much higher than the median
-- this indicates that there are some counties that have very high populations, skewing the mean upwards

-- find average population of each county per state + DC
SELECT state_name, ROUND(AVG(pop_est_2019),0) AS avg_county_pop FROM us_counties_2019
GROUP BY (state_name)
ORDER BY avg_county_pop DESC;
-- District of Columbia has the highest average county population

-- Looking closer at the District of Columbia counties
SELECT state_name, county_name, pop_est_2019 FROM us_counties_2019
WHERE state_name = 'District of Columbia';
-- There is only one county in DC, hence the high population of that county.

-- Looking closer at California, the STATE with the highest average county population
SELECT state_name, county_name, pop_est_2019,  FROM us_counties_2019
WHERE state_name = 'California' 
ORDER BY pop_est_2019 DESC;

-- Identifying counties with populations above the average in california
SELECT state_name, county_name, pop_est_2019 FROM us_counties_2019
WHERE state_name = 'California' AND pop_est_2019 > (SELECT AVG(pop_est_2019) FROM us_counties_2019)
ORDER BY pop_est_2019 DESC;
-- 35 counties in California have a population above the US county average

-- percentage of counties in california above us county average
SELECT ((cali_counties_above_avg::numeric)/total_cali_counties)*100 FROM
	(SELECT COUNT(county_name) AS cali_counties_above_avg FROM us_counties_2019
	WHERE state_name = 'California' AND pop_est_2019 > (SELECT AVG(pop_est_2019) FROM us_counties_2019)),
	(SELECT COUNT(county_name) AS total_cali_counties FROM us_counties_2019
	WHERE state_name = 'California');
-- 60% counties in California are above the US county population average.


-- percentage of US counties above average in population being in California
SELECT ((cali_counties::numeric)/(us_counties))*100 FROM
	(SELECT COUNT(county_name) AS cali_counties FROM us_counties_2019
	WHERE state_name = 'California') AS cali,
	(SELECT COUNT(county_name) AS us_counties FROM us_counties_2019
	WHERE pop_est_2019 > (SELECT AVG(pop_est_2019) FROM us_counties_2019)) AS state;
-- 10% of the counties above the average US county population are in California.
-- California is contributing heavily to the skew in average county population compared to median county population in the US

-- Look into state with the lowest average county population:
SELECT state_name, AVG(pop_est_2019) AS avg_population FROM us_counties_2019
GROUP BY state_name
ORDER BY avg_population;
-- South Dakota has the lowest average county population

-- Looking closer at South Dakota counties
SELECT state_name, county_name, pop_est_2019 FROM us_counties_2019
WHERE state_name = 'South Dakota'
ORDER BY pop_est_2019 DESC;

-- South Dakota counties above US county population average
SELECT COUNT(county_name) FROM us_counties_2019
WHERE state_name = 'South Dakota' 
	AND pop_est_2019 > (SELECT AVG(pop_est_2019) FROM us_counties_2019);
-- Only two counties in South Dakota have populations above the US county population average

-- Percentage of counties in South Dakota above US county population average
SELECT ((sd_counties_above_avg::numeric)/(total_sd_counties))*100 FROM 
	(SELECT COUNT(county_name) AS sd_counties_above_avg FROM us_counties_2019
		WHERE state_name = 'South Dakota' 
		AND pop_est_2019 > (SELECT AVG(pop_est_2019) FROM us_counties_2019)),
	(SELECT COUNT(county_name) AS total_sd_counties FROM us_counties_2019
		WHERE state_name='South Dakota');
-- Only 3% of counties in South Dakota are above the US county average in comparison to 60% in California!


-- POPULATION DENSITY
-- identifying population/total area for every county in the US
SELECT * FROM us_counties_2019;

SELECT state_name, county_name, (pop_est_2019::numeric)/(area_land + area_water) AS population_density
FROM us_counties_2019
ORDER BY population_density DESC;
-- The top 4 highest population density counties are in the state of New York

-- Checking to see if New York state has the highest average county population density:
SELECT state_name, AVG((pop_est_2019::numeric)/(area_land + area_water)) AS avg_pop_density
FROM us_counties_2019
GROUP BY state_name
ORDER BY avg_pop_density DESC;
-- As expected, New York state is the state with the highest average county population density.

-- population density in each state as a whole
SELECT state_name, SUM(pop_est_2019) AS state_pop, SUM(area_land + area_water) AS total_area,
SUM(pop_est_2019)/SUM(area_land + area_water) AS pop_density
FROM us_counties_2019
GROUP BY state_name
ORDER BY pop_density DESC;
-- Despite New York State having the top 4 highest population density counties and having the highest average county population density,
-- there are 7 states with a higher state population density.
-- This indicates that New York states population is likely highly concentrated in those 4 counties.

-- Let's see the percentage of New York's total population from those 4 counties
SELECT county_name, (pop_est_2019::numeric)/(area_land + area_water) AS pop_density FROM us_counties_2019
WHERE state_name = 'New York'
ORDER By pop_density DESC;
-- 4 counties: New York County, Kings County, Bronx County, Queens County

SELECT ((counties_pop::numeric)/state_pop)*100 AS percent_pop
FROM (SELECT SUM(pop_est_2019) AS counties_pop FROM us_counties_2019
WHERE
	(county_name = 'New York County' OR 
	county_name ='Kings County' OR 
	county_name= 'Bronx County' OR 
	county_name= 'Queens County')) AS counties,
	
	(SELECT SUM(pop_est_2019) AS state_pop FROM us_counties_2019
	WHERE state_name = 'New York') AS state;
-- 41% of the population in New York State is within these 4 counties

-- Determining the percentage area of these 4 counties within New York State
-- It is evident that these 4 counties have a high population density but
-- I want to see the proportion of area these 4 counties encompass in New York State
SELECT ((counties_area::numeric)/state_area)*100 AS percent_area 
FROM (
	SELECT SUM(area_land + area_water) AS counties_area FROM us_counties_2019
	WHERE 
		(county_name = 'New York County' OR 
		county_name ='Kings County' OR 
		county_name= 'Bronx County' OR 
		county_name= 'Queens County')) AS counties,
	(SELECT SUM(area_land + area_water) AS state_area FROM us_counties_2019
	WHERE state_name = 'New York') AS state;
-- These 4 counties encompass 3.22% of the area of New York state but holds 41% of the population!

-- We can even look at just land area.
SELECT ((counties_land_area::numeric)/state_land_area)*100 AS percent_area 
FROM (
	SELECT SUM(area_land) AS counties_land_area FROM us_counties_2019
	WHERE 
		(county_name = 'New York County' OR 
		county_name ='Kings County' OR 
		county_name= 'Bronx County' OR 
		county_name= 'Queens County')) AS counties,
	(SELECT SUM(area_land) AS state_land_area FROM us_counties_2019
	WHERE state_name = 'New York') AS state;
-- Even when just considering land area, these 4 counties still only take up 3.47% of the land area in New York state.


-- Let's now look at the other extreme and look closer at the state with the lowest average county population density.
SELECT state_name, AVG((pop_est_2019::numeric)/(area_land + area_water)) AS avg_pop_density
FROM us_counties_2019
GROUP BY state_name
ORDER BY avg_pop_density;
-- Wyoming and Alaska are the states with the lowest average county population density

-- population density in each state as a whole
SELECT state_name, SUM(pop_est_2019) AS state_pop, SUM(area_land + area_water) AS total_area,
SUM(pop_est_2019)/SUM(area_land + area_water) AS pop_density
FROM us_counties_2019
GROUP BY state_name
ORDER BY pop_density;
-- Alaska has the lowest population density. Wyoming is the second lowest, but Alaska appears to be much lower.
-- This may be due to the total area encompassing both land and water.

-- Looking at population density with just land area:
SELECT state_name, SUM(pop_est_2019) AS state_pop, SUM(area_land) AS total_area,
SUM(pop_est_2019)/SUM(area_land) AS pop_density
FROM us_counties_2019
GROUP BY state_name
ORDER BY pop_density;
-- Alaska's population density is still much lower than Wyoming's.

-- Looking closer at components of population density: population and state area

-- population in alaska compared to other states
SELECT state_name, SUM(pop_est_2019) AS population, RANK() OVER(ORDER BY SUM(pop_est_2019)) FROM us_counties_2019
GROUP BY state_name;
-- Alaska has the 4th lowest population.

-- Looking closer at Alaskan area compared to other states
SELECT state_name, SUM(area_land + area_water) AS total_area, RANK() OVER(ORDER BY SUM(area_land + area_water) DESC) FROM us_counties_2019
GROUP BY state_name;
-- Alaska has by far the largest total area!

-- just land area:
SELECT state_name, SUM(area_land) AS total_area, RANK() OVER(ORDER BY SUM(area_land) DESC) FROM us_counties_2019
GROUP BY state_name;
-- Even when looking at just land area, Alaska still has a much higher area than the next state Texas.

-- Looking closer at Alaska population and area compared to US population:

--percentage of Alaskas total area compared to the US area:
SELECT ((alaska_area::numeric)/(us_area))*100 AS area_percentage
FROM
	(SELECT SUM(area_land + area_water) AS alaska_area FROM us_counties_2019
	WHERE state_name = 'Alaska'
	GROUP BY state_name),
	(SELECT SUM(area_land + area_water) AS us_area FROM us_counties_2019);
-- Alaska alone encompasses 17.5% of the US total area.

SELECT ((alaska_area::numeric)/(us_area))*100 AS area_percentage
FROM
	(SELECT SUM(area_land) AS alaska_area FROM us_counties_2019
	WHERE state_name = 'Alaska'
	GROUP BY state_name),
	(SELECT SUM(area_land) AS us_area FROM us_counties_2019);
-- Even removing water area, Alaska's area is still is 16% of the US area. 

-- percentage of US population in alaska:
SELECT ((alaska_pop::numeric)/(us_pop))*100 AS area_percentage
FROM
	(SELECT SUM(pop_est_2019) AS alaska_pop FROM us_counties_2019
	WHERE state_name = 'Alaska'
	GROUP BY state_name),
	(SELECT SUM(pop_est_2019) AS us_pop FROM us_counties_2019);
-- Alaska only has 0.2% of the population in the US while occupying 17.5% of the US total area!


-- Looking at state with the highest population density
SELECT state_name, SUM(pop_est_2019) AS state_pop, SUM(area_land + area_water) AS total_area,
SUM(pop_est_2019)/SUM(area_land + area_water) AS pop_density
FROM us_counties_2019
GROUP BY state_name
ORDER BY pop_density DESC;
-- New Jersey is the STATE with the highest population density. 
-- Even though New York has the top 4 highest density counties, New Jersey as a whole is more dense.

-- Population of each state
SELECT state_name, SUM(pop_est_2019) AS population, RANK() OVER(ORDER BY SUM(pop_est_2019) DESC) FROM us_counties_2019
GROUP BY state_name;
-- New Jersey has the 11th highest population.

-- Total area by state
SELECT state_name, SUM(area_land) AS total_area, RANK() OVER(ORDER BY SUM(area_land)) FROM us_counties_2019
GROUP BY state_name;
-- New Jersey has the 6th lowest total area.
-- Seems that the low total area compared to states with higher populations than New Jersey led to the highest population density.

-- Closer look at population density components: population and area in New Jersey:
--percentage of New Jersey's total area compared to the US area:
SELECT ((nj_area::numeric)/(us_area))*100 AS area_percentage
FROM
	(SELECT SUM(area_land + area_water) AS nj_area FROM us_counties_2019
	WHERE state_name = 'New Jersey'
	GROUP BY state_name),
	(SELECT SUM(area_land + area_water) AS us_area FROM us_counties_2019);
-- New Jersey encompasses 0.23 of the total area in the US.


-- percentage of US population in New Jersey:
SELECT ((nj_pop::numeric)/(us_pop))*100 AS area_percentage
FROM
	(SELECT SUM(pop_est_2019) AS nj_pop FROM us_counties_2019
	WHERE state_name = 'New Jersey'
	GROUP BY state_name),
	(SELECT SUM(pop_est_2019) AS us_pop FROM us_counties_2019);
-- New Jersey has 2.7% of the population in the US.
-- Even though there are states with a higher population or smaller area, it seems that the higher populated states are larger in area!




-- Takeaway points:
-- California is the most populated state
-- Texas has the second highest population by state 
	-- has much lower mean and median county populations compared to California, and states with the 3rd-5th highest populations
	-- this is due to having a much higher amount of counties to distribute the popualtion compared to California
-- California has the highest average county population, so a lot of counties that have high populations
	-- 60% (35/58) of counties in California are above the US county population average
	-- 10% of the counties with a population above the US county average are in California
-- South Dakota has the lowest average county population
	-- Only 3% (2/66) of counties have a population above the US county population average
-- New York State's population is heavily concentrated in 4 counties
	-- these 4 counties have the highest population density in the US
	-- 41% of the population reside in counties that take up less than 4% of the state's area
-- Alaska has the lowest population density
	-- Alaska has 17.5% of the total area in the US while having only 0.22% of the population
-- New Jersey has the highest population density
	-- New Jersey has 0.23% of the total area in the US while having 2.7% of the population



-- Comparing 2010 and 2019 US Population Census

-- creating table
CREATE TABLE us_counties_2010 (
    state_fips text, 
    county_fips text,
    region smallint,
    state_name text,
    county_name text,
    estimates_base_2010 integer,
    CONSTRAINT counties_2010_key PRIMARY KEY (state_fips, county_fips)
);

--inserting data
COPY us_counties_2010
FROM '/Users/tiffanyng/Documents/Data_Analytics/postgres/practical-sql-2-main/Chapter_07/us_counties_pop_est_2010.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM us_counties_2010;
SELECT * FROM us_counties_2019;

-- Looking at changes in county population between 2019 and 2010

-- raw change and percentage change ordered by raw change
SELECT c2019.state_name, c2019.county_name, c2010.estimates_base_2010,
	c2019.pop_est_2019, c2019.pop_est_2019 - c2010.estimates_base_2010 AS raw_change,
	RANK() OVER(ORDER BY c2019.pop_est_2019 - c2010.estimates_base_2010 DESC) AS raw_change_rank,
	ROUND(((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100,2) AS percent_growth,
	RANK() OVER(ORDER BY((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 DESC) 
	AS percent_growth_rank
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	ORDER BY raw_change DESC;
-- This table shows raw change and percent growth accompanied by the county's rankings for these categories
-- Maricopa County in Arizona and Harris County in Texas are experiencing highest raw increase in population
-- Wayne County in Michigan saw the largest raw decrease in population

-- raw change and percentage change ordered by percent growth
SELECT c2019.state_name, c2019.county_name, c2010.estimates_base_2010,
	c2019.pop_est_2019, c2019.pop_est_2019 - c2010.estimates_base_2010 AS raw_change,
	RANK() OVER(ORDER BY c2019.pop_est_2019 - c2010.estimates_base_2010 DESC) AS raw_change_rank,
	ROUND(((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100,2) AS percent_growth,
	RANK() OVER(ORDER BY((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 DESC) 
	AS percent_growth_rank
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	ORDER BY percent_growth;
-- McKenzie County in North Dakota and Loving County in Texas appear to have the highest percent growth
-- Concho County in Texas and Alexander County in Illinois have the lowest percent growth

-- Is there a relationship between high raw change or percent growth with greater county land area?
SELECT c2019.state_name, c2019.county_name, c2019.area_land,
	RANK() OVER(ORDER BY c2019.area_land) AS land_area_rank,
	c2019.pop_est_2019 - c2010.estimates_base_2010 AS raw_change,
	RANK() OVER(ORDER BY c2019.pop_est_2019 - c2010.estimates_base_2010 DESC) AS raw_change_rank
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	ORDER BY raw_change DESC LIMIT 10;
-- It appears that the 10 counties with highest raw change are ranked low in land area (>2000th)

SELECT c2019.state_name, c2019.county_name, c2019.area_land,
	RANK() OVER(ORDER BY c2019.area_land) AS land_area_rank,
	ROUND(((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100,2) AS percent_growth,
	RANK() OVER(ORDER BY((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 DESC) 
	AS percent_growth_rank
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	ORDER BY percent_growth DESC LIMIT 10;
-- It appears that the 10 counties with the highest percent growth are mainly ranked between 1000-2000th in land area 
-- Trousdale County in Tennessee is an exception (65th)

-- Comparing 2010 population size with raw change and percent growth:
SELECT c2019.state_name, c2019.county_name, c2010.estimates_base_2010,
	RANK() OVER(ORDER BY c2010.estimates_base_2010 DESC) AS pop_2010_rank,
	ROUND(((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100,2) AS percent_growth,
	RANK() OVER(ORDER BY((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 DESC) 
	AS percent_growth_rank
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	ORDER BY pop_2010_rank;
-- It does appear to an extent that areas with high 2010 populations tend to have seen decent population growth from 2010-2019
-- It is not completely clear from looking through the rows, but the top populated counties seem to mostly be in the top 1000th for percent growth.

-- Comparing 2010 population density with raw change and percent growth:
SELECT c2019.state_name, c2019.county_name, 
	((c2010.estimates_base_2010::numeric)/(c2019.area_land + c2019.area_water))*100 AS population_density,
	RANK() OVER(ORDER BY (ROUND(c2010.estimates_base_2010::numeric)/(c2019.area_land + c2019.area_water),2) DESC) 
		AS pop_density_2010_rank,
	ROUND(((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100,2) AS percent_growth,
	RANK() OVER(ORDER BY((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 DESC) 
	AS percent_growth_rank
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	ORDER BY pop_density_2010_rank;
	
-- It is unclear at a glance whether areas with a higher or lower population density tend to see greater percent growth in population.
-- People may move to less densely populated regions if there are many new developing neighbourhoods.
-- People would move to higher, more densely populated regions for friends/family or for work opportunities.

--Takeaways:
-- It is difficult to draw conclusions on relationships between statistical categories at a glance
-- Further analyses will be done on Python to compare relationships and correlations between land area, population density, percent growth, and raw growth




-- Brief raw population change and percent growth analyses between States:
-- population in 2010 vs 2019
SELECT c2019.state_name, SUM(c2010.estimates_base_2010) AS pop_2010,
	SUM(c2019.pop_est_2019) AS pop_2019,
	SUM(c2019.pop_est_2019 - c2010.estimates_base_2010) AS raw_change
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	GROUP BY c2019.state_name
	ORDER BY raw_change DESC;
-- Texas has the highest raw increase in population

-- raw change in population, percent growth
SELECT c2019.state_name, SUM(c2010.estimates_base_2010) AS pop_2010,
	SUM(c2019.pop_est_2019) AS pop_2019,
	SUM(c2019.pop_est_2019 - c2010.estimates_base_2010) AS raw_change,
	SUM((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 AS percent_growth
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	GROUP BY c2019.state_name
	ORDER BY percent_growth DESC;
-- Texas has the highest growth rate

-- Takeaways:
-- Texas has the highest growth rate and raw population change
-- Analysis will be done on Python to determine if there are correlations between different stat categories

-- TABLES TO EXPORT
-- Saving tables as a csv to analyze counties on Python
SELECT c2019.state_fips || c2019.county_fips AS fips, 
	c2019.state_name, c2019.county_name, 
	c2010.estimates_base_2010, c2019.pop_est_2019,
	c2019.internal_point_lat, c2019.internal_point_lon,
	c2019.area_land AS land_area,
	((c2010.estimates_base_2010::numeric)/(c2019.area_land + c2019.area_water))*100 AS population_density_2010,
	((c2019.pop_est_2019::numeric)/(c2019.area_land + c2019.area_water))*100 AS population_density_2019,
	c2019.pop_est_2019 - c2010.estimates_base_2010 AS raw_change,
	((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 AS percent_growth
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips;

-- save this table as a csv to do analyses between states on python
SELECT c2019.state_fips, c2019.state_name, SUM(c2010.estimates_base_2010) AS pop_2010,
	SUM(c2019.pop_est_2019) AS pop_2019,
	SUM(c2019.area_land) AS land_area,
	SUM((c2010.estimates_base_2010::numeric)/(c2019.area_land + c2019.area_water))*100 AS population_density_2010,
	SUM((c2019.pop_est_2019::numeric)/(c2019.area_land + c2019.area_water))*100 AS population_density_2019,
	SUM(c2019.pop_est_2019 - c2010.estimates_base_2010) AS raw_change,
	SUM((c2019.pop_est_2019 - c2010.estimates_base_2010)/(c2010.estimates_base_2010::numeric))*100 AS percent_growth
	FROM us_counties_2019 AS c2019
    JOIN us_counties_2010 AS c2010
	ON c2019.state_fips = c2010.state_fips
    AND c2019.county_fips = c2010.county_fips
	GROUP BY c2019.state_fips, c2019.state_name
	ORDER BY percent_growth DESC;
	

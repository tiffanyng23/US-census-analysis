-- Looking at Population Growth Rate Between 2018 and 2019:
SELECT * FROM us_counties_2019;


--POPULATION COUNT CHANGE
-- Looking at population change from 2018 to 2019 in counties:
SELECT state_name, county_name, pop_est_2018, pop_est_2019, 
	pop_est_2019 - pop_est_2018 AS population_change
FROM us_counties_2019
ORDER BY population_change DESC;
-- It appears that several counties in Texas were experiencing high increases in population count.

-- Population change from 2018 to 2019 in each State:
SELECT state_name, SUM(pop_est_2019 - pop_est_2018) AS population_change FROM us_counties_2019
GROUP BY state_name
ORDER BY population_change DESC;
-- As expected, Texas had by far the highest population change out of all the states.



-- GROWTH RATE
-- Growth rate accounts for growth relative to population size
-- Looking at growth rate per county: 
SELECT state_name, county_name, pop_est_2018, pop_est_2019, 
	((pop_est_2019 - pop_est_2018)/(pop_est_2018::numeric))*100 AS growth_rate
FROM us_counties_2019
ORDER BY growth_rate DESC;
-- Several counties in Texas were also showing very high growth rates.

-- Average COUNTY growth rate by state:
SELECT state_name, AVG(((pop_est_2019 - pop_est_2018)/(pop_est_2018::numeric))*100) AS growth_rate FROM us_counties_2019
GROUP BY state_name
ORDER BY growth_rate DESC;
-- Surprisingly, Texas did not have close to the highest average county growth rate out of the states (13th highest).
-- This is despite having several counties near the highest in population increase in the US.

-- Let's look at growth rate of each state:
SELECT state_name, ((SUM(pop_est_2019-pop_est_2018))/(SUM(pop_est_2018)::numeric))*100 AS state_growth_rate
FROM us_counties_2019
GROUP BY state_name
ORDER BY state_growth_rate DESC;
-- Idaho had the highest growth rate at 2.09%
-- Texas had the 5th highest state growth rate at 1.28%, but is much lower than the 4 states ranked higher.

-- Texas population:
SELECT state_name, SUM(pop_est_2018) AS pop_2018, SUM(pop_est_2019) AS pop_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY pop_2019 DESC;
-- Texas was the second most highly populated state, only behind California.
-- The increase in population count in Texas was the highest, but not enough to account for its high initial population to achieve the top growth rate


-- CLOSER LOOK AT IDAHO:
-- Idaho had by far the highest growth rate at 2.09%. 
SELECT state_name, SUM(pop_est_2018) AS pop_2018, SUM(pop_est_2019) AS pop_2019, SUM(pop_est_2019-pop_est_2018) FROM us_counties_2019
WHERE state_name = 'Idaho'
GROUP BY state_name
ORDER BY pop_2019 DESC;
-- Idaho's population grew by 36,529 from 2018 to 2019. Let's find out why!

-- Components of Growth Rate:
-- Birth rate: number of births per 1000 people
SELECT state_name, ((SUM(births_2019)::numeric)/SUM(pop_est_2019))*1000 AS birth_total_pop_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY birth_total_pop_2019 DESC;
-- Idaho had the 9th highest birth rate at 12.43/1000
-- Utah was the highest at 15.17/1000

-- Death rate: number of deaths per 1000 people
SELECT state_name, ((SUM(deaths_2019)::numeric)/SUM(pop_est_2019))*1000 AS death_total_pop_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY death_total_pop_2019;
-- Idaho had the 6th lowest death rate at 7.45/1000 
-- Utah had the lowest death rate at 5.44/1000

-- Idaho had a high birth rate and low death rate but Utah has the highest birth rate and lowest death rate.
-- Why doesn't Utah have the highest growth rate then?

--Utah population vs. Idaho population
SELECT state_name, SUM(pop_est_2018) AS pop_2018, SUM(pop_est_2019) AS pop_2019 FROM us_counties_2019
WHERE state_name = 'Idaho' OR state_name = 'Utah'
GROUP BY state_name;
-- Utah has a much higher population size than Idaho
-- Idaho's increase in population is greater relative to its population size compared to Utah.

-- International migration rate
SELECT state_name, SUM(international_migr_2019), ((SUM(international_migr_2019)::numeric)/SUM(pop_est_2019))*1000 AS international_migration_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY international_migration_2019 DESC;
-- Idaho had only has 0.093/1000 international migrants, so this cannot be contributing much to the growth rate.
-- Utah's was much higher at 1.74/1000.

-- Domestic migration rate
SELECT state_name, SUM(domestic_migr_2019), ((SUM(domestic_migr_2019)::numeric)/SUM(pop_est_2019))*1000 AS domestic_migration_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY domestic_migration_2019 DESC;
-- Idaho has the highest domestic migration rate with 15.31/1000. 



-- LOWEST GROWTH RATE: WEST VIRGINIA
SELECT state_name, ((SUM(pop_est_2019-pop_est_2018))/(SUM(pop_est_2018)::numeric))*100 AS state_growth_rate
FROM us_counties_2019
GROUP BY state_name
ORDER BY state_growth_rate;
-- West Virginia had the lowest growth rate

--Birth rate: 
SELECT state_name, ((SUM(births_2019)::numeric)/SUM(pop_est_2019))*1000 AS birth_total_pop_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY birth_total_pop_2019;
-- West Virginia had the 6th lowest birth rate at 8.83 births/1000 people

-- Death rate: 
SELECT state_name, ((SUM(deaths_2019)::numeric)/SUM(pop_est_2019))*1000 AS death_total_pop_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY death_total_pop_2019 DESC;
-- West Virginia had the highest death rate at 12.59 deaths/1000 people 

-- International migration rate
SELECT state_name, SUM(international_migr_2019), ((SUM(international_migr_2019)::numeric)/SUM(pop_est_2019))*1000 AS international_migration_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY international_migration_2019;
-- West Virginia had the second lowest international migration rate at -0.20/1000

-- Domestic migration rate
SELECT state_name, SUM(domestic_migr_2019), ((SUM(domestic_migr_2019)::numeric)/SUM(pop_est_2019))*1000 AS domestic_migration_2019 FROM us_counties_2019
GROUP BY state_name
ORDER BY domestic_migration_2019;
-- West Virginia had the 11th lowest domestic migration rate at -3.94/1000


-- Takeaway Points:
-- Texas as a state experienced the highest increase in population count from 2018-2019
	-- Texas did not have close to the highest growth rate due to being the second most populated state
-- Idaho had the highest growth rate and this is due to:
	-- A high birth rate (9th highest), low death rate (6th lowest), and the highest domestic migration rate
-- West Virginia had the lowest growth rate due to:
	-- low birth rate (6th lowest), highest death rate, second lowest international migration rate
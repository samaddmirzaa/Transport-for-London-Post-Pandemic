
-- Transport for London 
-- Analysis Queries


USE london_underground;



-- THE RECOVERY 
-- How far has the Tube recovered year by year?

SELECT 
    fin_year,
    ROUND(underground_total, 0) AS tube_journeys_m,
    ROUND(bus_total, 0) AS bus_journeys_m,
    tube_share_pct,
    bus_share_pct,
    ROUND(underground_total / 1384.6 * 100, 1) AS pct_of_2018_19_peak
FROM annual_mode_summary
ORDER BY fin_year;

-- Tube ridership crashed from 1,385m journeys (2018/19) to just 296m in 2020/21 (a 79% collapse). 
-- By 2024/25 it reached 1,218m, back to 88% of pre-COVID peak. 
-- Growth is slowing: the jump from 22/23 to 23/24 was 11%, but 23/24 to 24/25 was only 3%. The recovery has slowed down.




-- THE BUS vs TUBE DIVERGENCE
-- Has the bus recovered differently from the Tube?

SELECT 
    fin_year,
    ROUND(bus_total, 0) AS bus_m,
    ROUND(underground_total, 0) AS tube_m,
    bus_share_pct,
    tube_share_pct,
    ROUND(bus_total / underground_total, 2) AS bus_to_tube_ratio
FROM annual_mode_summary
ORDER BY fin_year;

-- Yes, Pre-COVID the bus was at 55% mode share and falling. 
-- During COVID it surged to 67% because essential workers relied on buses. 
-- Post-COVID, bus share has  dropped to 51%, its lowest ever while the Tube has clawed back to 34%.
-- Buses are losing share both to the Tube recovery and to cycling or walking.




-- STATION RECOVERY DISTRIBUTION
-- How many stations have fully recovered?

SELECT 
    recovery_category,
    COUNT(*) AS station_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM station_recovery WHERE Mode = 'LU'), 1) AS pct_of_stations,
    ROUND(AVG(recovery_pct_2024), 1) AS avg_recovery_pct
FROM station_recovery
WHERE Mode = 'LU'
GROUP BY recovery_category
ORDER BY avg_recovery_pct DESC;

-- Only 18 of 265 LU stations (7%) have fully recovered or grown beyond 2019 levels.
-- 138 stations (52%) are in partial recovery at 75-90%. 
-- 84 stations (32%) still have a significant shortfall below 75%.
-- The Tube network is operating well below its pre-pandemic capacity utilisation.



-- THE MONDAY EFFECT and HYBRID WORKING
-- Is Monday structurally weaker than other weekdays?

SELECT 
    Station,
    ROUND(monday_entry_2024, 0) AS monday_entries,
    ROUND(midweek_entry_2024, 0) AS tue_thu_entries,
    monday_vs_midweek_2024 AS monday_gap_pct
FROM station_recovery
WHERE Mode = 'LU'
    AND annual_2019 > 10000000
ORDER BY monday_vs_midweek_2024 ASC
LIMIT 20;

-- Yes. Across all LU stations, Monday entries are 12.4% lower than the Tuesday-Thursday average.
-- This shows evidence of hybrid working in London.
-- Some City stations show Monday gaps of 20%+ meaning one in five desks is empty on Mondays.



-- BIGGEST STATIONS THAT GREW
-- Which stations are busier now than before COVID?

SELECT 
    Station,
    ROUND(annual_2019 / 1000000, 1) AS annual_2019_m,
    ROUND(annual_2024 / 1000000, 1) AS annual_2024_m,
    recovery_pct_2024,
    recovery_category
FROM station_recovery
WHERE Mode = 'LU'
ORDER BY recovery_pct_2024 DESC
LIMIT 15;

-- Farringdon leads at 152% of 2019 levels which is entirely due to the Elizabeth line opening.
-- Tottenham Court Road (+42%) and Whitechapel (+34%) also benefited from Crossrail.
-- Richmond and Wimbledon grew 33-42%, showing outer London leisure/residential demand has grown.
-- The winners are Elizabeth line stations and residential hubs.



-- BIGGEST STATIONS STILL STRUGGLING
-- Which stations have lost the most passengers?

SELECT 
    Station,
    ROUND(annual_2019 / 1000000, 1) AS annual_2019_m,
    ROUND(annual_2024 / 1000000, 1) AS annual_2024_m,
    recovery_pct_2024,
    monday_vs_midweek_2024 AS monday_gap_pct,
    recovery_category
FROM station_recovery
WHERE Mode = 'LU'
    AND annual_2019 > 1000000
ORDER BY recovery_pct_2024 ASC
LIMIT 15;

-- Lancaster Gate (-55%), Chancery Lane (-52%), and Barbican (-51%) lead the declines
-- They are all City/office locations hit by hybrid working. 
-- Cannon Street (-42%) serves the financial district. Old Street (-42%) lost tech workers. 
-- Stations serving traditional office 
-- districts are the hardest hit.



-- WEEKEND vs WEEKDAY
-- Has leisure travel recovered faster than commuting?

SELECT 
    Station,
    recovery_pct_2024 AS overall_recovery,
    sat_recovery_pct AS saturday_recovery,
    ROUND(sat_recovery_pct - recovery_pct_2024, 1) AS weekend_premium,
    monday_vs_midweek_2024 AS monday_gap
FROM station_recovery
WHERE Mode = 'LU'
    AND annual_2019 > 5000000
    AND sat_recovery_pct IS NOT NULL
ORDER BY weekend_premium DESC
LIMIT 15;

-- Saturday ridership has recovered to a higher level than weekday at many stations.
-- Stations with Saturday recovery are above 100% but weekday recovery below 80% are the examples of the shift from commuter to leisure use.




-- THE COVID CRASH 
-- How dramatic was the collapse and how fast was the bounce?

SELECT 
    fin_year,
    period_num,
    period_start,
    ROUND(underground_m, 1) AS tube_m,
    ROUND(bus_m, 1) AS bus_m,
    ROUND(underground_m / 100 * 100, 1) AS tube_vs_100m_benchmark
FROM journeys_by_mode
WHERE fin_year >= '2019/20'
ORDER BY period_start;

-- Tube journeys fell from 100m per period to just 5.7m in period 1 of 2020/21 which is a 94% drop in one month. 
-- It took until 2022/23 to pass 75% recovery. 
-- The recovery curve shows a fast initial bounce, then a long plateau.




-- SEASONALITY & STRONGEST PERIODS?
-- "Is there a seasonal pattern in Tube usage?"

SELECT 
    period_num,
    ROUND(AVG(CASE WHEN fin_year BETWEEN '2017/18' AND '2018/19' THEN underground_daily_m END), 2) AS pre_covid_avg,
    ROUND(AVG(CASE WHEN fin_year BETWEEN '2023/24' AND '2024/25' THEN underground_daily_m END), 2) AS post_covid_avg,
    ROUND(
        AVG(CASE WHEN fin_year BETWEEN '2023/24' AND '2024/25' THEN underground_daily_m END) /
        AVG(CASE WHEN fin_year BETWEEN '2017/18' AND '2018/19' THEN underground_daily_m END) * 100
    , 1) AS recovery_pct
FROM journeys_by_mode
GROUP BY period_num
HAVING pre_covid_avg IS NOT NULL AND post_covid_avg IS NOT NULL
ORDER BY period_num;

-- Period 1 (April) and summer periods are consistently weaker. 
-- October/November periods are the strongest. December dips for Christmas.
-- This pattern has existed before and after COVID but the summer dips are deeper now.




-- LINE PERFORMANCE BEFORE COVID
-- Which lines were the best and worst run?

SELECT 
    line,
    ROUND(AVG(CASE WHEN metric = 'pct_schedule_operated' THEN value END) * 100, 1) AS avg_schedule_pct,
    ROUND(AVG(CASE WHEN metric = 'excess_journey_time_mins' THEN value END), 2) AS avg_excess_time,
    ROUND(AVG(CASE WHEN metric = 'customer_satisfaction' THEN value END), 1) AS avg_satisfaction,
    ROUND(AVG(CASE WHEN metric = 'lost_customer_hours' THEN value END), 0) AS avg_lost_hours
FROM line_performance
WHERE financial_year IN ('2015/16', '2016/17')
    AND line NOT IN ('NETWORK', 'NETWORK JOURNEYS', 'TOTAL ALL LINES', 'Network')
GROUP BY line
ORDER BY avg_schedule_pct DESC;

-- Victoria and Northern lines had the best reliability (98-99% schedule operated).
-- Circle & Hammersmith was the worst (95%).
-- The Jubilee line had the best customer satisfaction.
-- Network-wide excess journey time improved from 7+ minutes in 2004 to under 5 minutes by 2017, an improvement before COVID disruption.



-- NETWORK PERFORMANCE TREND
-- Was the Tube getting better before COVID hit?

SELECT 
    financial_year,
    ROUND(MAX(CASE WHEN line IN ('NETWORK','TOTAL ALL LINES','Network') 
        AND metric = 'pct_schedule_operated' THEN value * 100 END), 1) AS network_schedule_pct,
    ROUND(MAX(CASE WHEN line IN ('NETWORK','TOTAL ALL LINES','Network') 
        AND metric = 'excess_journey_time_mins' THEN value END), 2) AS network_excess_time,
    ROUND(MAX(CASE WHEN line IN ('NETWORK','TOTAL ALL LINES','Network') 
        AND metric = 'customer_satisfaction' THEN value END), 1) AS network_satisfaction
FROM line_performance
GROUP BY financial_year
ORDER BY financial_year;

-- Yes, clearly. Lost customer hours fell from 3.4m (2004/05) to 1.2m (2016/17).
-- Schedule reliability rose from 95% to 97.5%. Excess journey time halved. 
-- The network was on an improvement trajectory when COVID hit.




--  THE SIZE EFFECT
-- Are big stations recovering differently from small ones?

SELECT 
    CASE 
        WHEN annual_2019 >= 40000000 THEN 'Mega (40m+)'
        WHEN annual_2019 >= 20000000 THEN 'Large (20-40m)'
        WHEN annual_2019 >= 10000000 THEN 'Medium (10-20m)'
        WHEN annual_2019 >= 5000000  THEN 'Small (5-10m)'
        ELSE 'Minor (<5m)'
    END AS size_band,
    COUNT(*) AS stations,
    ROUND(AVG(recovery_pct_2024), 1) AS avg_recovery,
    ROUND(AVG(monday_vs_midweek_2024), 1) AS avg_monday_gap
FROM station_recovery
WHERE Mode = 'LU'
GROUP BY size_band
ORDER BY avg_recovery ASC;

-- Yes. The biggest stations have the weakest recovery because they're concentrated in Zone 1 office areas.
-- Smaller outer-zone stations are recovering faster because they serve areas less affected by hybrid working.


-- I LOVE LONDON

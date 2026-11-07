--DATA ANALYSIS--

-----1) TOP 10 BUSIEST STATIONS IN 2024?-----

select "Station",sum("EntryTapCount"+"ExitTapCount") as total_taps
from tfl_clean
group by "Station"
order by total_taps desc
limit 10;
-- INSIGHT:Kings Cross St Pancras is the busiest station in 2024 with 77.4 million total taps.Most of the top 10 are major rail terminals
-- and interchange hubs(victoria,liverpool street,stratford,london bridge,waterloo) which suggests that footfall is mainly driven
-- by commuters and line changes.Tottenham court road,oxford circus and bond street serve the shopping and West End area.
-- All station are in Zone 1 except Stratford(zone 2/3)
-- NOTE:Some station are recorded separately by network,so their real totals may be higher.


-----2)BUSIEST STATIONS ON WEEKDAYS VS WEEKENDS?-----

select "Station",round(avg("EntryTapCount"+"ExitTapCount")) as avg_weekend_taps
from tfl_clean
where "DayOfWeek" in ('Saturday','Sunday')
group by "Station"
order by avg_weekend_taps desc
limit 10;

select "Station",round(avg("EntryTapCount"+"ExitTapCount")) as avg_weekday_taps
from tfl_clean
where "DayOfWeek" not in ('Saturday','Sunday')
group by "Station"
order by avg_weekday_taps desc
limit 10;
-- INSIGHT: Kings Cross St Pancras is the busiest station on both weekdays (215,724 average daily taps) and weekends (200,970),
-- with only a 7% drop at weekends.On weekdays, commuter terminals such as Waterloo, Victoria and Liverpool Street rank near the top.
-- At weekends, Liverpool Street (−36%, 4th → 8th) and Waterloo (−25%, 2nd → 6th) fall, while Tottenham Court Road (5th → 2nd) and 
-- Stratford (7th → 3rd, only −4%) rise,kely driven by shopping and leisure. Farringdon drops out of the weekend top 10 and Leicester Square,
-- in the theatre and entertainment district, enters. All top 10 stations have lower average daily taps at weekends than on weekdays.


-----3)BUSIEST MONTH OF 2024?-----

select extract(month from "TravelDate") as month,round(avg("EntryTapCount"+"ExitTapCount")) as avg_taps
from tfl_clean
group by extract(month from "TravelDate")
order by avg_taps desc;
--INSIGHT:October is the busiest month (19,417 average daily taps per station) and January is the quietest (16,339), 
--a difference of about 19%. October and November have no major holidays and a full work and school routine.
--Summer shows a mixed picture: July ranks 3rd, but August is the second quietest month.This suggests that footfall is driven more
--by commuting than by tourism, as many workers and families go on holiday in August.December ranks only 6th despite the Christmas season, 
--and January is the lowest month,which is consistent with less commuting during holiday periods.
--NOTE: averages are per station per day; missing rows (such as Christmas Day) are not included.


-----4)OFFICE VS LEISURE STATIONS?-----
-- Weekend/weekday ratio of average daily taps: low ratio = office stations, high ratio = leisure stations.

with station_avg as (
select "Station",
round(avg(case when "DayOfWeek" in ('Saturday','Sunday')then "EntryTapCount"+"ExitTapCount" end))as weekend_tap,
round(avg(case when "DayOfWeek" not in ('Saturday','Sunday') then "EntryTapCount"+"ExitTapCount" end))as weekday_tap
from tfl_clean
group by "Station")

select "Station",
round(weekend_tap)as weekend_tap,
round(weekday_tap)as weekday_tap,
round(weekend_tap/weekday_tap,2) as weekend_weekday_ratio
from station_avg
order by  weekend_weekday_ratio desc
limit 10;
-----------------------------------------------------------------
with station_avg as(
select "Station",
round(avg(case when "DayOfWeek"in ('Saturday','Sunday') then "EntryTapCount"+"ExitTapCount" end)) as weekend_tap,
round(avg(case when "DayOfWeek" not in ('Saturday','Sunday') then "EntryTapCount"+"ExitTapCount" end)) as weekday_tap
from tfl_clean
group by "Station")

select "Station",
round(weekend_tap)as weekend_tap,
round(weekday_tap)as weekday_tap,
round(weekend_tap/weekday_tap,2)as weekend_weekday_ratio
from station_avg
order by weekend_weekday_ratio asc
limit 10;
-- INSIGHT: The weekend/weekday ratio clearly separates leisure and office stations.
-- The highest ratios are around stadiums, entertainment and event venues:
-- Pudding Mill Lane (1.41, 41% busier at weekends) and Hackney Wick near the Olympic Park,
-- Arsenal (1.27) at the Emirates Stadium, Leicester Square (1.21) and Covent Garden (1.14)
-- in the theatre district, Camden Town with its market, and North Greenwich with the O2 Arena.
-- The lowest ratios are in the City of London's financial and legal district:
-- Chancery Lane (0.26, 74% quieter at weekends), Bank (0.27), Moorgate (0.30),
-- Cannon Street (0.39) and Farringdon (0.40), which depend almost entirely on weekday office traffic.
-- NOTE:some stations, such as Cyprus and Emerson Park, have very low footfall; ratios based on small numbers are less reliable.


-----5)STATIONS WITH THE LARGEST ENTRY/EXIT GAP?-----
-- Rows with zero entries or exits are excluded (see cleaning step 3D).

--5A) MORE ENTRIES THAN EXITS
select "Station",sum("EntryTapCount")-sum("ExitTapCount") as gap_entry_exit
from tfl_clean
where "EntryTapCount"!=0 and "ExitTapCount"!=0
group by "Station"
order by gap_entry_exit desc
limit 10;

--5B) MORE EXITS THAN ENTRIES
select "Station",sum("ExitTapCount")-sum("EntryTapCount") as gap_exit_entry
from tfl_clean
where "EntryTapCount"!=0 and "ExitTapCount"!=0
group by "Station"
order by gap_exit_entry desc
limit 10;

--INSIGHT:Leicester Square has the largest surplus of entries over exits (+1.47 million),
-- while Oxford Circus has the largest surplus of exits over entries (+3.1 million).
-- The results show clear pairs of neighbouring stations: Covent Garden has more exits,
-- while nearby Leicester Square has more entries; Camden Town has more exits,
-- while nearby Mornington Crescent and Chalk Farm have more entries;
-- Oxford Circus and Bond Street have more exits, while Piccadilly Circus has more entries.
-- This suggests that many people arrive at one station, walk around the area,
-- and leave from another. Covent Garden being lift-only and Camden Town sometimes
-- being exit-only at busy times may support this pattern.
-- NOTE: the data only includes card taps; in-station interchanges and missed taps are not counted.



-------- SUMMARY --------
-- 1) Kings Cross St Pancras is the busiest station in 2024 (77.4 million taps).
-- 2) Commuter stations are busier on weekdays; shopping and leisure stations are busier at weekends.
-- 3) October is the busiest month and January is the quietest.
-- 4) Stadium and theatre areas are busy at weekends; City of London stations are quiet at weekends.
-- 5) Nearby stations show opposite entry/exit gaps: people often enter one station and leave from another.

-------- LIMITATIONS --------
-- 1) Tap counts are not unique people; one person can be counted more than once.
-- 2) Some rows are missing (e.g. Christmas Day, Colindale) and were not filled.
-- 3) Rows with zero entries or exits were excluded from the entry/exit gap analysis.
-- 4) Some stations are recorded separately by network, so their real totals may be higher.































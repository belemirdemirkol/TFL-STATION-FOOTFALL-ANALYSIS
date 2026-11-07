--DATA_CLEANING SECTION--

create table tfl_clean as
select*from stationfootfall;
--1)Created a copy of the raw table to keep the original data unchanged.


alter table tfl_clean
alter column "TravelDate" type date
using "TravelDate"::text::date;
--2)Converted traveldate from int to date (int-->text-->date).
select*from tfl_clean
limit 10;
--2B)Checked traveldate is now in date format(e.g. 2024-01-01).


select count(*) as entry_zero from tfl_clean
where "EntryTapCount"=0;

select count(*) as exit_zero from tfl_clean
where "ExitTapCount"=0;

select count(*) as entry_exit_zero from tfl_clean
where "EntryTapCount"=0 and "ExitTapCount"=0;
--3)Zero values:543 rows with entrytapcount=0, 346 rows with exittapcount=0.
--3B)No row has both values=0 so zeros are not full closure days.Possibly recording issues(to be checked by station).


select "Station",count(*) as zero_entry_days
from tfl_clean
where "EntryTapCount"=0
group by "Station"
order by zero_entry_days desc;

select "Station",count(*) as zero_exit_days
from tfl_clean
where "ExitTapCount"=0
group by "Station"
order by zero_exit_days desc;
--3C)Zero entries are spread across 183 stations (max 21 days, Wood Street),mostly on the Overground north-east branch.
--Zero exits are spread across 114 stations (max 19 days, Clapham High Street),mostly DLR stations (no gates, possible missed taps).
--3D)DECISION: zero rows are kept (only 0.6% of data, no imputation). They will be excluded from the entry/exit gap analysis.


select "Station",count(*)as days_present
from tfl_clean
group by "Station"
having count(*)<366
order by days_present desc;
--4)Missing rows: 401 of 434 stations have fewer than 366 days.
-- Most stations miss only 1 day (possibly Christmas Day, network closed).
-- Colindale has only 162 days (204 missing), possibly closed for a long period.
-- "Woolwich Arsenal" appears twice: possible name inconsistency (to be checked). -----CHECKED IN 4D: not a duplicate,different networks.
-- DECISION: missing rows are not filled (no data to impute).
-- Colindale will be noted in the analysis as a special case.

select count(*) from tfl_clean
where "TravelDate"='2024-12-25';
-- 4B) Christmas Day (2024-12-25): only 57 of 434 stations have a row, so 377 stations are missing that day (network largely closed).
-- This explains about 377 of the 1,849 missing rows

select count(distinct trim("Station"))
from tfl_clean;
-- 4C) count(distinct trim("Station")) = 434, same as before: no leading or trailing spaces in station names.


select distinct "Station",length("Station") as length_station
from tfl_clean
where "Station" like 'Woolwich%';
-- 4D) "Woolwich Arsenal" was not a duplicate: the names were cut off in the result grid.
-- They are separate entries for different networks (DLR, NR, Elizabeth line).
-- DECISION: kept as they are. Note: the same location can appear as more than one station.


-------- CLEANING SUMMARY --------
-- 1) Created tfl_clean as a copy of the raw table (stationfootfall kept unchanged).
-- 2) Converted TravelDate from int to date (int -> text -> date).
-- 3) Zero values: 543 zero entries and 346 zero exits; no row has both = 0.
--    Kept in the table; excluded from the entry/exit gap analysis.
-- 4) Missing rows: 1,849 station-days missing.
--    Christmas Day explains 377 of them; Colindale has only 162 days (special case).
--    Missing rows are not filled.
-- 5) No leading/trailing spaces in station names.
--    Woolwich Arsenal DLR / NR / Woolwich EL are separate entries, not duplicates.



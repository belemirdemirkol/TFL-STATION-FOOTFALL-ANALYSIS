-- DATA QUALITY CHECK --

-- 1) First look at the data
select * from stationfootfall
limit 20;
-- 5 columns: TravelDate, DayOfWeek, Station, EntryTapCount, ExitTapCount.

-- 2) Total number of rows
select count(*) as total_rows
from stationfootfall;
-- There are 156,995 rows.

-- 3) NULL and empty values
select
count(*) filter(where "TravelDate" is null) as traveldate_null,
count(*) filter(where "DayOfWeek" is null or trim("DayOfWeek") = '') as dayofweek_null,
count(*) filter(where "Station" is null or trim("Station") = '') as station_null,
count(*) filter(where "EntryTapCount" is null) as entrytap_null,
count(*) filter(where "ExitTapCount" is null) as exittap_null
from stationfootfall;
-- No NULL or empty values found.

-- 4) Min and max values for entry and exit counts
select max("EntryTapCount") as max_entry,
min("EntryTapCount") as min_entry,
max("ExitTapCount") as max_exit,
min("ExitTapCount") as min_exit
from stationfootfall;
-- No negative values. Min is 0 for both entry and exit (to be checked).
-- Max is ~142K, which is realistic for major stations.

-- 5) Distinct days of the week
select distinct "DayOfWeek" as distinct_day
from stationfootfall;
-- There are 7 distinct days of the week, all spelled correctly, as expected.

-- 6) Number of distinct stations
select count(distinct "Station") as distinct_station
from stationfootfall;
-- There are 434 different station names.
-- 434 stations x 366 days = 158,844 expected rows,
-- but there are 156,995 rows (1,849 missing).
-- Some stations do not have a row for every day (to be checked).

-- 7) Date range and number of distinct days
select count(distinct "TravelDate") as distinct_date,
max("TravelDate") as max_date,
min("TravelDate") as min_date
from stationfootfall;
-- There are 366 distinct travel dates, as expected (2024 is a leap year).
-- Dates range from 2024-01-01 to 2024-12-31 as expected,
-- but the column type is int; it will be converted to date type in the cleaning section.

-- 8) Duplicate rows (same station on the same date)
select count(*) as row_count, "TravelDate", "Station"
from stationfootfall
group by "TravelDate", "Station"
having count(*) > 1;
-- No duplicate rows: each station appears only once per day.

-------- SUMMARY --------
-- 1) There are 156,995 rows and 5 columns.
-- 2) There are no NULL or empty values.
-- 3) DayOfWeek has 7 distinct values, all spelled correctly.
-- 4) There are no negative values; min = 0 (to be checked).
-- 5) Max value is ~142K (realistic for major stations).
-- 6) There are 434 stations and 366 days; 1,849 rows are missing (to be checked).
-- 7) There are no duplicate rows.
-- 8) TravelDate column type is int; it will be converted to date type in the cleaning section.
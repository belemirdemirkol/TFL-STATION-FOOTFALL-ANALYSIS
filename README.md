# TfL Station Footfall Analysis (2024)

An end-to-end analysis of London station footfall in 2024 using **SQL (PostgreSQL)** and **Python**. The project looks at which stations are the busiest, how footfall changes between weekdays and weekends and across the year, and where entries and exits are unbalanced.

## Dataset
**Source:** Transport for London open data – [crowding.data.tfl.gov.uk](https://crowding.data.tfl.gov.uk/) (Network Demand → `StationFootfall_2024.csv`)

- 156,995 rows, 5 columns: `TravelDate`, `DayOfWeek`, `Station`, `EntryTapCount`, `ExitTapCount`
- 434 stations, every day of 2024 (daily entry and exit tap counts per station)

## Tools
- **PostgreSQL + DBeaver:** data quality check, cleaning and analysis queries
- **Python (pandas, matplotlib, seaborn):** feature engineering, analysis and visualisation
- **SQLAlchemy:** loading the clean table from PostgreSQL into Python

## Project Structure
```
DATA/      StationFootfall_2024.csv
SQL/       DATA_QUALITY_CHECK.sql, DATA_CLEANING.sql, DATA_ANALYSIS.sql
NOTEBOOK/  Notebook_tfl_analysis.ipynb
```

## Process
1. **Data quality check (SQL):** row count, NULL and empty values, min/max values, distinct stations and days, date range, duplicate rows.
2. **Cleaning (SQL):** created a clean copy of the table (`tfl_clean`), converted `TravelDate` from int to date, investigated zero values and missing station-days (e.g. Christmas Day, Colindale).
3. **Python:** loaded the clean table, added new features (`month`, `day_group`, `total_taps`) and answered the analysis questions with charts.

## Analysis Questions
1. Top 10 busiest stations in 2024
2. Busiest stations on weekdays vs weekends
3. Busiest month of 2024
4. Office vs leisure stations
5. Stations with the largest entry/exit gap

## Key Findings
1. Kings Cross St Pancras is the busiest station in 2024 (77.4 million taps).
2. Commuter stations are busier on weekdays; shopping and leisure stations are busier at weekends.
3. October is the busiest month and January is the quietest; footfall is driven more by commuting than tourism.
4. Stadium and theatre areas are busy at weekends; City of London stations are quiet at weekends.
5. Nearby stations show opposite entry/exit gaps: people often enter one station and leave from another.

## Limitations
1. Tap counts are not unique people; one person can be counted more than once.
2. Some rows are missing (e.g. Christmas Day, Colindale) and were not filled.
3. Rows with zero entries or exits were excluded from the entry/exit gap analysis.
4. Some stations are recorded separately by network, so their real totals may be higher.

## How to Run
1. Load `StationFootfall_2024.csv` into PostgreSQL and run the SQL files in order: quality check → cleaning → analysis.
2. In the notebook, replace `YOUR_PASSWORD` in the connection string with your own PostgreSQL password.

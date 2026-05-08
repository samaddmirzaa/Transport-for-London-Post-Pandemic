# Transport for London - Post-Pandemic Analysis

An analysis of how London Underground travel changed following the COVID-19 pandemic, using TfL open data to track ridership recovery across stations, lines, and transport modes. The project spans SQL-based data modelling and querying through to a Power BI dashboard and a written narrative report.

---

## Key Questions

- How did Underground journey volumes recover over time, and how does recovery compare to pre-pandemic baselines?
- Which stations and lines recovered fastest and which are still lagging?
- Has hybrid working permanently shifted weekday travel patterns, and is Monday demand structurally weaker?
- How has the pandemic changed London's transport mode share across bus, rail, and Underground?

---

## Findings

- Post-pandemic recovery across the Underground network has been **uneven** AS some stations returned to near pre-pandemic levels while others have not.
- Evidence of a **persistent Monday dip** in commuter journeys, consistent with structural changes in hybrid working patterns.
- **Mode share shifts** observed across the recovery period, with some transport modes recovering faster than others.
- Station-level analysis identifies both the strongest recovery performers and those furthest from pre-pandemic demand.

---

## How It Was Built

**SQL (database + queries)**
The raw TfL data was loaded into a relational database using `london_underground_database.sql`, which defines the schema and populates the tables. Analytical queries in `london_underground_analysis_queries.sql` handle aggregations, recovery rate calculations, and station/line comparisons.

**Power BI (dashboard)**
Query outputs were brought into Power BI to build an interactive dashboard covering journey trends, station recovery rankings, line performance, and mode share over time.

**PDF narrative report**
`TFL Story Post Pandemic.pdf` presents the key findings as a structured analytical story providing context, methodology, charts, and conclusions.

---

## Files

| File | Description |
|---|---|
| `london_underground_database.sql` | SQL schema and data load, defines tables and populates them from source data |
| `london_underground_analysis_queries.sql` | Analytical SQL queries, recovery rates, station rankings, line comparisons, trend aggregations |
| `Transport for London Dashboard.pbix` | Power BI dashboard, open in Power BI Desktop |
| `TFL Story Post Pandemic.pdf` | Written narrative report with charts and conclusions |
| `Data.zip` | Raw source data files, extract before running SQL scripts |

---

## Tools

- **SQL** - database schema design and analytical querying
- **Power BI Desktop** - dashboard and visualisation
- **TfL Open Data** - journey volume and station-level data

---

## Data Source

[TfL Open Data — Transport for London](https://tfl.gov.uk/info-for/open-data-users/)

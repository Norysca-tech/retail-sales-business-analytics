# End-to-End Business Analytics: Retail Sales

Raw retail sales data taken through the full analytics process: clean it in Excel, query it in SQL, model it in Power BI, and turn the results into recommendations for management.

![Executive dashboard](Report/Dashboard_Screenshot.png)

## Key results

- **€1,552,071** in sales from **11,971 orders** and **25 customers**, at **€129.65** per order.
- Sales fell 3.7% in 2023 and rose 6.8% in 2024. Over the two years the net change is +2.9%, so the business is stable, not growing.
- Categories differ by 13.5% and regions by 3.1%. No category, region or customer stands out as a risk.
- January is the peak month. Discounted orders are no larger than full-price orders.

## Recommendations in brief

1. Move customers to higher-priced items.
2. Lift order value in Milk Products and Patisserie.
3. Plan stock and staffing around the January peak.
4. Test whether discounts work.
5. Make item ID a required field at order entry.

## Project contents

| File | What it holds |
|---|---|
| `Excel/Raw_Data.xlsx` | The original dataset, 12,575 rows, unchanged |
| `Excel/Data_Analysis.xlsx` | Cleaned data, formula analysis, four pivot tables with charts and a business report |
| `SQL/Business_Analysis.sql` | Queries for sales, products, customers and regions, each with its result and interpretation |
| `SQL/retail_business.db` | The SQLite database the queries run against |
| `PowerBI/Business_Intelligence_Dashboard.pbix` | Data model, DAX measures and the one-page executive dashboard |
| `PowerBI/Norysca_DataAnalytics_Task5_SourceData.csv` | The cleaned source data loaded into Power BI |
| `Report/Final_Executive_Report.pdf` | Executive summary, findings, dashboard and five recommendations |
| `README/Project_Summary.pdf` | One-page project summary |

## How to open the files

GitHub does not preview Excel, Power BI or database files, so download them first.

- Excel files: open in Excel.
- `.pbix`: open in Power BI Desktop.
- SQL: open `retail_business.db` in DB Browser for SQLite, then run `Business_Analysis.sql` in the Execute SQL tab.

## Data

Public Kaggle dataset *Retail Store Sales: Dirty for Data Cleaning* (12,575 raw rows, 11,971 orders after cleaning). The data has no cost or margin, so profit is not measured.

## Tools

Microsoft Excel, SQLite, Power BI Desktop.

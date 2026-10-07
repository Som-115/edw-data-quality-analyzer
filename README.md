# EDW Investigation Assistant

A lightweight data engineering application for first-level investigation of
Enterprise Data Warehouse (EDW) tables.

The application brings together table metadata, data-quality checks,
health scoring, dependency analysis, and investigation summaries in one
place.

The goal is to reduce the repetitive manual effort involved in the initial
investigation of an EDW table or data issue.

---

## 🎯 Problem

When investigating an EDW table or a data-quality issue, engineers may need
to manually perform several checks:

- Identify the table structure
- Check row counts and columns
- Identify primary keys
- Check for NULL values
- Check for duplicate values
- Identify orphan records
- Understand table relationships
- Determine upstream and downstream dependencies
- Assess the overall health of a table
- Summarize the investigation findings

These checks are often performed using multiple SQL queries and tools.

The EDW Investigation Assistant brings these first-level investigation
activities into a single interface.

---

## 💡 Solution

The application allows an engineer to select an EDW table and automatically
view:

1. Table overview
2. Health score
3. Data-quality investigation results
4. Upstream and downstream dependencies
5. Investigation summary
6. Recommended investigation action

The tool is designed for **first-level investigation**.

It is not intended to replace developers or perform complete ETL lineage
or root-cause analysis.

---

## 🏗️ Architecture

```text
                    Fabric SQL Database
                            │
             ┌──────────────┴──────────────┐
             │                             │
        Table Metadata                DQResult
             │                             │
             └──────────────┬──────────────┘
                            │
                            ▼
                     Python / pyodbc
                            │
                            ▼
                     Streamlit App
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
     Table Health      Data Quality     Impact Analysis
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
                            ▼
                  Investigation Summary
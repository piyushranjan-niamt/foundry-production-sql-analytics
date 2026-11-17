# Foundry Production & Scrap Defect Analytics (SQL)

## Overview
A relational database and analytical SQL project modeled on real-world iron foundry operations. It tracks daily heat/batch output, shift efficiency, equipment downtime, and casting rejection defects (Blowholes, Shrinkage, Sand Inclusion, Cold Shut) to identify root causes of scrap and optimize yield.

## Database Schema (3NF Normalized)
1. **`Furnace_Lines`**: Master table of induction furnaces, capacities, and operational status.
2. **`Shifts`**: Shift schedules, supervisors, and assigned furnace lines.
3. **`Production_Batches`**: Daily batch production logs (planned vs. produced quantity, pouring temperature, downtime).
4. **`Defect_Logs`**: Granular rejection records linked to batches via foreign keys (supports multiple defect types per batch and zero-defect batches).

## Key Business Questions Answered
* What is the overall **Yield %** and **Scrap %** across different casting parts (Brake Drums, Engine Blocks, Flywheels, Axle Housings)?
* Which **defect types** contribute to over 60% of total foundry rejections (Pareto analysis)?
* How do **Morning, Evening, and Night shifts** compare on downtime and scrap efficiency?
* Which batches breached the **5% critical scrap threshold**, and was high pouring temperature a factor?
* What is the **rolling 3-batch scrap trend** across furnace lines?

## Tech Stack
* **Database:** MySQL 8.0+
* **SQL Concepts Used:** Primary/Foreign Key Constraints, `INNER JOIN`, `LEFT JOIN`, `GROUP BY`, `HAVING`, `CASE WHEN`, Common Table Expressions (CTEs), Window Functions (`RANK()`, `SUM() OVER`), and Correlated Subqueries.
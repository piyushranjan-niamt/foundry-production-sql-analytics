-- ============================================================================
-- FOUNDRY PRODUCTION & SCRAP DEFECT ANALYTICS
-- Author: Piyush Ranjan
-- Description: 3NF Relational Schema, Synthetic Foundry Dataset, & KPI Queries
-- ============================================================================

-- 1. SCHEMA DEFINITION
-- ----------------------------------------------------------------------------
CREATE TABLE Furnace_Lines (
    furnace_id INT PRIMARY KEY,
    furnace_code VARCHAR(15) UNIQUE NOT NULL,
    capacity_tons DECIMAL(4,1) NOT NULL,
    installation_year INT
);

CREATE TABLE Shifts (
    shift_id INT PRIMARY KEY,
    shift_name VARCHAR(20) NOT NULL,
    supervisor_name VARCHAR(50) NOT NULL,
    furnace_id INT,
    FOREIGN KEY (furnace_id) REFERENCES Furnace_Lines(furnace_id)
);

CREATE TABLE Production_Batches (
    batch_id INT PRIMARY KEY,
    batch_date DATE NOT NULL,
    shift_id INT NOT NULL,
    casting_part VARCHAR(50) NOT NULL,
    pouring_temp_c INT NOT NULL,
    planned_qty INT NOT NULL,
    produced_qty INT NOT NULL,
    downtime_mins INT DEFAULT 0,
    FOREIGN KEY (shift_id) REFERENCES Shifts(shift_id)
);

CREATE TABLE Defect_Logs (
    defect_id INT PRIMARY KEY,
    batch_id INT NOT NULL,
    defect_type VARCHAR(30) NOT NULL,
    rejected_qty INT NOT NULL CHECK (rejected_qty > 0),
    FOREIGN KEY (batch_id) REFERENCES Production_Batches(batch_id)
);

-- 2. DATA POPULATION (55+ Realistic Records)
-- ----------------------------------------------------------------------------
INSERT INTO Furnace_Lines VALUES
(1, 'IND-F01', 5.0, 2019),
(2, 'IND-F02', 5.0, 2021),
(3, 'IND-F03', 8.0, 2023);

INSERT INTO Shifts VALUES
(10, 'Morning', 'R. K. Sharma', 1),
(20, 'Evening', 'A. Verma', 1),
(30, 'Night', 'S. Mahato', 2),
(40, 'Morning', 'P. Das', 3),
(50, 'Evening', 'M. Tiwari', 3);

INSERT INTO Production_Batches VALUES
(1001, '2026-10-01', 10, 'Brake Drum', 1410, 500, 495, 10),
(1002, '2026-10-01', 20, 'Brake Drum', 1435, 500, 475, 35),
(1003, '2026-10-01', 30, 'Engine Block', 1390, 300, 285, 25),
(1004, '2026-10-01', 40, 'Axle Housing', 1415, 600, 595, 5),
(1005, '2026-10-02', 10, 'Flywheel', 1405, 450, 445, 15),
(1006, '2026-10-02', 20, 'Flywheel', 1440, 450, 420, 45),
(1007, '2026-10-02', 30, 'Brake Drum', 1385, 500, 470, 50),
(1008, '2026-10-02', 50, 'Axle Housing', 1420, 600, 580, 20),
(1009, '2026-10-03', 10, 'Engine Block', 1412, 320, 318, 0),   -- Zero defect batch
(1010, '2026-10-03', 20, 'Engine Block', 1445, 320, 295, 40),
(1011, '2026-10-03', 30, 'Flywheel', 1380, 450, 415, 60),
(1012, '2026-10-03', 40, 'Brake Drum', 1408, 650, 645, 10),
(1013, '2026-10-04', 10, 'Axle Housing', 1410, 550, 545, 10),
(1014, '2026-10-04', 20, 'Brake Drum', 1430, 500, 480, 30),
(1015, '2026-10-04', 30, 'Engine Block', 1395, 300, 280, 45),
(1016, '2026-10-04', 50, 'Flywheel', 1418, 500, 498, 5),    -- Zero defect batch
(1017, '2026-10-05', 10, 'Brake Drum', 1405, 520, 515, 10),
(1018, '2026-10-05', 30, 'Axle Housing', 1382, 550, 510, 55),
(1019, '2026-10-05', 40, 'Engine Block', 1410, 400, 395, 15),
(1020, '2026-10-05', 50, 'Brake Drum', 1425, 600, 585, 25);

INSERT INTO Defect_Logs VALUES
(1, 1001, 'Blowhole', 8),
(2, 1001, 'Sand Inclusion', 4),
(3, 1002, 'Blowhole', 22),
(4, 1002, 'Shrinkage', 14),
(5, 1003, 'Cold Shut', 19),
(6, 1003, 'Shrinkage', 7),
(7, 1004, 'Sand Inclusion', 11),
(8, 1005, 'Blowhole', 9),
(9, 1006, 'Shrinkage', 26),
(10, 1006, 'Blowhole', 15),
(11, 1007, 'Cold Shut', 24),
(12, 1007, 'Sand Inclusion', 12),
(13, 1008, 'Shrinkage', 16),
(14, 1010, 'Blowhole', 21),
(15, 1010, 'Shrinkage', 12),
(16, 1011, 'Cold Shut', 29),
(17, 1011, 'Blowhole', 11),
(18, 1012, 'Sand Inclusion', 10),
(19, 1013, 'Blowhole', 12),
(20, 1014, 'Blowhole', 18),
(21, 1014, 'Sand Inclusion', 9),
(22, 1015, 'Cold Shut', 22),
(23, 1015, 'Shrinkage', 8),
(24, 1017, 'Sand Inclusion', 7),
(25, 1018, 'Cold Shut', 31),
(26, 1018, 'Shrinkage', 14),
(27, 1019, 'Blowhole', 8),
(28, 1020, 'Sand Inclusion', 14),
(29, 1020, 'Blowhole', 6);


-- 3. ANALYTICAL SQL QUERIES
-- ----------------------------------------------------------------------------

-- Q1: Product-Wise Production, Net Good Output & Scrap Percentage
SELECT 
    pb.casting_part,
    COUNT(DISTINCT pb.batch_id) AS total_batches,
    SUM(pb.produced_qty) AS gross_produced,
    COALESCE(SUM(dl.rejected_qty), 0) AS total_rejected,
    SUM(pb.produced_qty) - COALESCE(SUM(dl.rejected_qty), 0) AS net_good_qty,
    ROUND((COALESCE(SUM(dl.rejected_qty), 0) * 100.0) / SUM(pb.produced_qty), 2) AS scrap_pct
FROM Production_Batches pb
LEFT JOIN Defect_Logs dl ON pb.batch_id = dl.batch_id
GROUP BY pb.casting_part
ORDER BY scrap_pct DESC;


-- Q2: Defect Pareto Analysis (Contribution % & Cumulative Share)
WITH DefectSummary AS (
    SELECT 
        defect_type,
        SUM(rejected_qty) AS defect_units
    FROM Defect_Logs
    GROUP BY defect_type
)
SELECT 
    defect_type,
    defect_units,
    ROUND(defect_units * 100.0 / SUM(defect_units) OVER(), 2) AS pct_share,
    ROUND(SUM(defect_units) OVER(ORDER BY defect_units DESC) * 100.0 / SUM(defect_units) OVER(), 2) AS cumulative_pct
FROM DefectSummary
ORDER BY defect_units DESC;


-- Q3: Shift & Supervisor Performance Ranking (Multi-Table Join + Window Function)
SELECT 
    s.shift_name,
    s.supervisor_name,
    fl.furnace_code,
    COUNT(DISTINCT pb.batch_id) AS batches_run,
    SUM(pb.downtime_mins) AS total_downtime_mins,
    ROUND((COALESCE(SUM(dl.rejected_qty), 0) * 100.0) / SUM(pb.produced_qty), 2) AS scrap_pct,
    RANK() OVER (ORDER BY (COALESCE(SUM(dl.rejected_qty), 0) * 100.0) / SUM(pb.produced_qty) ASC) AS quality_rank
FROM Shifts s
JOIN Furnace_Lines fl ON s.furnace_id = fl.furnace_id
JOIN Production_Batches pb ON s.shift_id = pb.shift_id
LEFT JOIN Defect_Logs dl ON pb.batch_id = dl.batch_id
GROUP BY s.shift_name, s.supervisor_name, fl.furnace_code;


-- Q4: High-Scrap Batch Alert System (> 5% Scrap Rate with Temperature Correlation)
SELECT 
    pb.batch_id,
    pb.batch_date,
    pb.casting_part,
    pb.pouring_temp_c,
    pb.produced_qty,
    SUM(dl.rejected_qty) AS rejected_qty,
    ROUND((SUM(dl.rejected_qty) * 100.0) / pb.produced_qty, 2) AS scrap_pct,
    CASE 
        WHEN pb.pouring_temp_c > 1425 THEN 'High Temp Risk (>1425C)'
        WHEN pb.pouring_temp_c < 1395 THEN 'Low Temp / Cold Shut Risk (<1395C)'
        ELSE 'Process / Mould Issue'
    END AS probable_root_cause
FROM Production_Batches pb
JOIN Defect_Logs dl ON pb.batch_id = dl.batch_id
GROUP BY pb.batch_id, pb.batch_date, pb.casting_part, pb.pouring_temp_c, pb.produced_qty
HAVING scrap_pct > 5.0
ORDER BY scrap_pct DESC;


-- Q5: Identify Zero-Defect ("First-Time-Right") Batches
SELECT 
    pb.batch_id,
    pb.batch_date,
    s.shift_name,
    pb.casting_part,
    pb.produced_qty
FROM Production_Batches pb
JOIN Shifts s ON pb.shift_id = s.shift_id
LEFT JOIN Defect_Logs dl ON pb.batch_id = dl.batch_id
WHERE dl.defect_id IS NULL;


-- Q6: Furnace Utilization & Capacity Efficiency
SELECT 
    fl.furnace_code,
    fl.capacity_tons,
    COUNT(pb.batch_id) AS total_heats,
    ROUND(AVG(pb.produced_qty * 100.0 / pb.planned_qty), 2) AS avg_plan_adherence_pct,
    ROUND(AVG(pb.downtime_mins), 1) AS avg_downtime_per_batch
FROM Furnace_Lines fl
JOIN Shifts s ON fl.furnace_id = s.furnace_id
JOIN Production_Batches pb ON s.shift_id = pb.shift_id
GROUP BY fl.furnace_code, fl.capacity_tons;
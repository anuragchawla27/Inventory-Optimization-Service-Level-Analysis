CREATE DATABASE inventory_project;
USE inventory_project;
SELECT * FROM inventory_transactions LIMIT 10;
-- total demand
SELECT SUM(Daily_Demand) AS Total_Demand
FROM inventory_transactions;
-- inventory turnover
SELECT SUM(Daily_Demand) / AVG((Opening_Stock + Closing_Stock)/2) AS Inventory_Turnover
FROM inventory_transactions;
-- total holding cost
SELECT SUM(Holding_Cost_INR) AS Total_Holding_Cost
FROM inventory_transactions;
-- stockout percentage
SELECT SUM(Stockout_Flag) * 100.0 / COUNT(*) AS Stockout_Percentage
FROM inventory_transactions;
-- dead stock records
SELECT COUNT(*) AS Dead_Stock_Records
FROM inventory_transactions
WHERE Daily_Demand = 0
AND Closing_Stock > 0;
-- Average Lead Time 
SELECT AVG(Lead_Time_Days) AS Avg_Lead_Time
FROM inventory_transactions ;
-- --overstock checking 
SELECT Product_ID,SUM(
        CASE 
            WHEN Closing_Stock > Reorder_Point 
            THEN Closing_Stock - Reorder_Point
            ELSE 0
        END
    ) AS Excess_Units
FROM inventory_transactions
GROUP BY Product_ID
ORDER BY Excess_Units DESC;
-- checking for stockouts
SELECT Delay_Flag,SUM(Stockout_Flag) AS Stockouts
FROM inventory_transactions
GROUP BY Delay_Flag;
-- Check demand variability
SELECT Product_ID,AVG(Daily_Demand) AS Avg_Demand,STDDEV(Daily_Demand) AS Demand_Variability
FROM inventory_transactions
GROUP BY Product_ID
ORDER BY Demand_Variability DESC;
-- redorder point
SELECT Product_ID,AVG(Daily_Demand) * AVG(Lead_Time_Days) + AVG(Safety_Stock) AS Suggested_Reorder_Point
FROM inventory_transactions
GROUP BY Product_ID;
-- Estimate Optimized Holding Cost
SELECT SUM(
        CASE 
            WHEN Closing_Stock > Reorder_Point
            THEN (Closing_Stock - Reorder_Point) 
            ELSE 0
        END
    ) AS Total_Excess_Units
FROM inventory_transactions;
-- estimate holding cost tied to excess stock
SELECT SUM(
        CASE 
            WHEN Closing_Stock > Reorder_Point
            THEN Holding_Cost_INR * ((Closing_Stock - Reorder_Point) / Closing_Stock)
            ELSE 0
        END
    ) AS Excess_Holding_Cost
FROM inventory_transactions;
-- Reduction %
SELECT ( SUM(
            CASE 
                WHEN Closing_Stock > Reorder_Point
                THEN Holding_Cost_INR *
                     ((Closing_Stock - Reorder_Point) / Closing_Stock)
                ELSE 0
            END
        )
        /
        SUM(Holding_Cost_INR)
    ) * 100 AS Holding_Cost_Reduction_Percentage
FROM inventory_transactions;
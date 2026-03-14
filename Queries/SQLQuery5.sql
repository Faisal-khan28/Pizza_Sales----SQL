SELECT * FROM order_details
SELECT * FROM orders
SELECT * FROM pizza_types
SELECT * FROM pizzas

--Basic:
--Q1.Retrieve the total number of orders placed.
--Ans1.
SELECT COUNT(order_id) AS Total_Number_Of_Orders
FROM orders;

--Q2.Calculate the total revenue generated from pizza sales.
--Ans2.
SELECT ROUND(SUM(od.quantity*p.price),2) as Total_Revenue
FROM order_details as od
JOIN pizzas as p ON OD.pizza_id = p.pizza_id;

--Q3.Identify the highest-priced pizza.
--Ans3.
SELECT TOP 1 pt.name, p.pizza_id, ROUND(p.price,2) as price
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC;

--Q4.Identify the most common pizza size ordered.
--Ans4.
SELECT TOP 1 p.size, SUM(od.quantity) AS Ordered_Quantity
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY Ordered_Quantity DESC;


--Q5.List the top 5 most ordered pizza types along with their quantities.
--Ans5.
SELECT TOP 5 pt.pizza_type_id, pt.name, SUM(od.quantity) AS Ordered_Quantity
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt on p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.pizza_type_id, pt.name
ORDER BY Ordered_Quantity DESC;


--Intermediate:
--Q6.Join the necessary tables to find the total quantity of each pizza category ordered.
--Ans6.
SELECT category, SUM(quantity) AS Total_order_quantity
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category
ORDER BY Total_order_quantity DESC;

--Q7.Determine the distribution of orders by hour of the day.
--Ans7.
SELECT DATEPART(HOUR,time) AS Hour, COUNT(order_id) AS Order_Count
FROM orders
GROUP BY DATEPART(HOUR,time)
ORDER BY COUNT(order_id) DESC;

--Q8.Join relevant tables to find the category-wise distribution of pizzas.
--Ans8.
SELECT category, COUNT(pizza_type_id) AS Type_of_Pizza
FROM pizza_types
GROUP BY category;

--Q9.Group the orders by date and calculate the average number of pizzas ordered per day.
--Ans9.
SELECT AVG(Daily_Orders) AS avg_pizzas_per_day
FROM
(
SELECT o.date, SUM(od.quantity) AS Daily_Orders
FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
GROUP BY date
) AS Total_Orders;

--Q10.Determine the top 3 most ordered pizza types based on revenue.
--Ans10.
SELECT TOP 3 pt.name, pt.pizza_type_id, SUM(od.quantity*p.price) AS Total_Revenue_of_Pizza
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name, pt.pizza_type_id
ORDER BY Total_Revenue_of_Pizza DESC;

--Advanced:
--Q11.Calculate the percentage contribution of each pizza type to total revenue.
--Ans11.
SELECT pt.category, 

       ROUND(SUM(od.quantity*p.price)/
	 ( SELECT ROUND(SUM(od.quantity*p.price),2) as Total_Revenue
       FROM order_details as od
       JOIN pizzas as p ON OD.pizza_id = p.pizza_id) * 100,2 ) AS Revenue_Percentage

FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

--2nd Approach
SELECT 
    pt.category,
    ROUND(
        SUM(od.quantity * p.price) * 100.0
        / SUM(SUM(od.quantity * p.price)) OVER()
    ,2) AS Revenue_Percentage
FROM pizza_types pt
JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

--Q12.Analyze the cumulative revenue generated over time.
--Ans12.
SELECT date, 
       SUM(revenue) OVER(ORDER BY date) AS Cum_Rev
FROM
(SELECT o.date, SUM(od.quantity * p.price) AS Revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
JOIN orders AS o ON o.order_id = od.order_id
GROUP BY o.date
) AS Daily_Revenue;

--Q13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
--Ans13.
SELECT * 
FROM
(
SELECT category, pizza_type_id, name, Revenue,
       RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS Rank
FROM
(
SELECT pt.category, pt.pizza_type_id, pt.name, ROUND(SUM(od.quantity * p.price),2) AS Revenue      
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category, pt.pizza_type_id, pt.name
) AS Total_Revenue
) AS b
WHERE Rank <=3;

--2nd Approach
WITH RevenuePerPizza AS
(
  SELECT pt.category, pt.pizza_type_id, pt.name, ROUND(SUM(od.quantity * p.price),2) AS Revenue
  FROM pizza_types AS pt
  JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
  JOIN order_details od ON p.pizza_id = od.pizza_id
  GROUP BY pt.category, pt.pizza_type_id, pt.name 
),
RankedPizza AS
(
SELECT category, pizza_type_id, name, Revenue,
       RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS Rank
FROM RevenuePerPizza
)
SELECT *
FROM RankedPizza
WHERE Rank <= 3;































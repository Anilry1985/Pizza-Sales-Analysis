Create database Pizzasales

Use Pizzasales

Create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id))

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id))

-- Questions
-- 1) Retrieve the total number of orders placed.
Select count(*) as total_orders from orders

-- 2) Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        INNER JOIN
    pizzas p ON od.pizza_id = p.pizza_id

-- 3) Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1

-- Identify the most common pizza size ordered.
SELECT 
    size, COUNT(od.order_details_id) AS total_count
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY total_count DESC


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, COUNT(od.quantity) AS total_count
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_count DESC
LIMIT 5


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, sum(od.quantity) AS total_count
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_count DESC
LIMIT 5

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) total_order
FROM
    orders
GROUP BY hour


-- Join relevant tables to find the category-wise distribution of pizzas.
Select category, count(name) from pizza_types
group by Category

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_quantity), 0) AS avg_quantity
FROM
    (SELECT 
        order_date, SUM(order_details.quantity) AS total_quantity
    FROM
        orders
    INNER JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quantity

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(p.price * od.quantity), 0) AS total_sales
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_sales DESC
LIMIT 3

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category, ROUND(SUM(p.price * od.quantity) / (SELECT 
    ROUND(SUM(p.price * od.quantity), 0) AS total_sales
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id) * 100,2)
 AS total_sales
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_sales DESC

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) Over(order by order_date) as cum_revnue
from
(select o.order_date, sum(od.quantity * p.price) as revenue from orders o inner join order_details od 
on o.order_id = od.order_id inner join pizzas p
on p.pizza_id = od.pizza_id
group by order_date) as sales

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue
from
(Select category, Name, revenue,
rank() Over(Partition by category order by revenue Desc) as rn
from
(Select pt.category, pt.name, round(sum(p.price * od.quantity),0) as revenue from pizzas p Inner Join order_details od
on p.pizza_id = od.pizza_id inner join
pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category, pt.name
order by revenue DESC) as a) as b
where rn <= 3
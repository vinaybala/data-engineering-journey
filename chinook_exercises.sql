-- 1. Tracks longer than 5 minutes, longest first
SELECT name, milliseconds
FROM track
WHERE milliseconds > 300000
ORDER BY milliseconds DESC;

-- 2. Customers from Germany or France
SELECT customer_id, first_name, last_name, country
FROM customer
WHERE country IN ('Germany', 'France');

-- 3. Every invoice with the customer's name
SELECT i.invoice_id, i.invoice_date, i.total, c.first_name, c.last_name
FROM invoice i
INNER JOIN customer c
    ON i.customer_id = c.customer_id;

-- 4. Track, album, artist (three-table join) — aliased to avoid duplicate column names
SELECT t.name AS track_name, a.title AS album_title, ar.name AS artist_name
FROM track t
INNER JOIN album a
    ON t.album_id = a.album_id
INNER JOIN artist ar
    ON a.artist_id = ar.artist_id;

-- 5. Customers who have never placed an order
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN invoice i
    ON c.customer_id = i.customer_id
WHERE i.customer_id IS NULL;


-- 6. Total revenue per country, highest first
SELECT billing_country, SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

-- 7. Top 5 best-selling tracks by quantity sold
SELECT t.track_id, t.name AS track_name, SUM(il.quantity) AS total_quantity_sold
FROM track t
INNER JOIN invoice_line il
    ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY total_quantity_sold DESC
LIMIT 5;


-- 8. Rank each customer's invoices by value, most expensive first
SELECT invoice_id, customer_id, total,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total DESC) AS rank_number
FROM invoice
ORDER BY customer_id, rank_number;



-- 9. Running total of revenue over time
SELECT invoice_date, total,
       SUM(total) OVER (
           ORDER BY invoice_date, invoice_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM invoice
ORDER BY invoice_date, invoice_id;




-- 10. Top 5 customers by revenue, per country
WITH cte_customer_total_revenue AS (
    SELECT c.customer_id, c.country, SUM(i.total) AS total_revenue,
           RANK() OVER (PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS revenue_rank
    FROM customer c
    INNER JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
)
SELECT customer_id, total_revenue, country, revenue_rank
FROM cte_customer_total_revenue
WHERE revenue_rank <= 5
ORDER BY country, revenue_rank;
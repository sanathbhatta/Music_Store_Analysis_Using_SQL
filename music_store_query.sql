/* Q1: Who is the senior most employee based on job title? */

SELECT
  *
FROM
  music_dataset.employee
ORDER BY
  levels DESC
LIMIT
  1



/* Q2: Which countries have the most Invoices? */

SELECT
  COUNT(*) AS no_of_invoices,
  billing_country
FROM
  music_dataset.invoice
GROUP BY
  billing_country
ORDER BY
  no_of_invoices DESC
LIMIT
  10



/* Q3: What are top 3 values of total invoice? */
  
SELECT
  total
FROM
  music_dataset.invoice
ORDER BY
  total DESC
LIMIT
  3



/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
  
SELECT
  billing_city,
  SUM(total) AS invoice_total
FROM
  music_dataset.invoice
GROUP BY
  billing_city
ORDER BY
  invoice_total DESC
LIMIT
  1



/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT
  c.customer_id,
  SUM(i.total) AS total_spent
FROM
  music_dataset.customer c
JOIN
  music_dataset.invoice i
ON
  c.customer_id = i.customer_id
GROUP BY
  c.customer_id
ORDER BY
  total_spent DESC



/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
  
SELECT
  DISTINCT c.email,
  c.first_name,
  c.last_name
FROM
  music_dataset.customer c
JOIN
  music_dataset.invoice i
ON
  c.customer_id = i.customer_id
JOIN
  music_dataset.invoice_line il
ON
  i.invoice_id = il.invoice_id
JOIN
  music_dataset.track t
ON
  il.track_id = t.track_id
JOIN
  music_dataset.genre g
ON
  t.genre_id = g.genre_id
WHERE
  g.name LIKE 'Rock'
ORDER BY
  c.email



/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT
  a.name,
  COUNT(*) AS ttl
FROM
  music_dataset.artist a
JOIN
  music_dataset.album ab
ON
  a.artist_id = ab.artist_id
JOIN
  music_dataset.track t
ON
  ab.album_id = t.album_id
JOIN
  music_dataset.genre g
ON
  t.genre_id = g.genre_id
WHERE
  g.name LIKE 'Rock'
GROUP BY
  a.name
ORDER BY
  ttl DESC
LIMIT
  10



/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
  
SELECT
  name,
  milliseconds
FROM
  music_dataset.track
WHERE
  milliseconds > (
  SELECT
    AVG(milliseconds)
  FROM
    music_dataset.track)
ORDER BY
  milliseconds DESC



/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT
  DISTINCT c.customer_id,
  c.first_name,
  a.name,
  SUM(il.unit_price*il.quantity) OVER(PARTITION BY c.customer_id, a.name) AS amount_spent
FROM
  music_dataset.customer c
JOIN
  music_dataset.invoice i
ON
  c.customer_id = i.customer_id
JOIN
  music_dataset.invoice_line il
ON
  i.invoice_id = il.invoice_id
JOIN
  music_dataset.track t
ON
  il.track_id = t.track_id
JOIN
  music_dataset.album ab
ON
  t.album_id = ab.album_id
JOIN
  music_dataset.artist a
ON
  ab.artist_id = a.artist_id
ORDER BY
  amount_spent DESC



/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH
  popular_genre_country AS (
  SELECT
    DISTINCT i.billing_country,
    g.name,
    SUM(quantity) OVER(PARTITION BY i.billing_country, g.genre_id) AS total_quantity
  FROM
    music_dataset.invoice i
  JOIN
    music_dataset.invoice_line il
  ON
    i.invoice_id = il.invoice_id
  JOIN
    music_dataset.track t
  ON
    il.track_id = t.track_id
  JOIN
    music_dataset.genre g
  ON
    t.genre_id = g.genre_id)
SELECT
  *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY total_quantity DESC) AS num
  FROM
    popular_genre_country)
WHERE
  num = 1
ORDER BY
  billing_country



/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
  
WITH
  customer_with_country AS (
  SELECT
    DISTINCT c.customer_id,
    c.first_name,
    i.billing_country,
    SUM(total) OVER(PARTITION BY c.customer_id) AS total_spent,
  FROM
    music_dataset.customer c
  JOIN
    music_dataset.invoice i
  ON
    c.customer_id = i.customer_id)
SELECT
  *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY total_spent DESC) AS num
  FROM
    customer_with_country) temp_table
WHERE
  num = 1
ORDER BY
  billing_country



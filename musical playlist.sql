

--who is the senior most employee based on job title -- 
select top (1)  *
from MusicalPlaylist.dbo.employee
order by levels desc

--which countries have the most invoices--
select billing_country,count(billing_country) as total_invoice
from MusicalPlaylist..invoice
group by billing_country
order by count(billing_country) desc

--what are the top 3 values of total invoice--
select top(3) invoice_id,total
from MusicalPlaylist..invoice
order by total desc

--which city has the best customers?returning city name with its sum of all invoice totals--
select billing_city,sum(total) sum_invoicetotal
from MusicalPlaylist..invoice
group by billing_city
order by sum_invoicetotal desc

--who is the best customer?--
select top(1) customer.customer_id,customer.first_name,customer.last_name,sum(total) as total
from MusicalPlaylist..customer customer
join MusicalPlaylist..invoice invoice
on customer.customer_id=invoice.customer_id
group by customer.customer_id ,first_name,last_name
order by total desc

--email, first name, last name of all rock music listeners--
--arranging them alphabatically by their email--
select distinct email,first_name,last_name
from MusicalPlaylist.dbo.customer customer
join MusicalPlaylist.dbo.invoice invoice on customer.customer_id=invoice.customer_id
join MusicalPlaylist..invoice_line$ invoice_lines on invoice.invoice_id=invoice_lines.invoice_id
where track_id in
      ( select tracks.track_id
	    from MusicalPlaylist..track$ tracks
		join MusicalPlaylist..genre genre
		on tracks.genre_id=genre.genre_id
		where genre.name like 'Rock' )
   order by email 

   --artist having most number of rock musics written

   select top(10) count(track_id) as total_tracks , artist.artist_id , artist.name
   from MusicalPlaylist..artist artist
   join MusicalPlaylist..album album on artist.artist_id=album.artist_id
   join MusicalPlaylist..track$ tracks on album.album_id=tracks.album_id
   where track_id in 
                  ( select track_id 
				    from MusicalPlaylist..track$ tracks 
					join MusicalPlaylist..genre genre
					on tracks.genre_id=genre.genre_id
					where genre.name = 'Rock' )

 group by artist.artist_id,artist.name
 order by count(track_id) desc
 

 --songs which have longer length than the average length--
 select name ,milliseconds 
 from MusicalPlaylist..track$ 
  where milliseconds >
     (select  avg(milliseconds) avg_length
	   from MusicalPlaylist..track$)
  order by milliseconds desc 


  --howmuch money spent by each customers on each artists 
  --return customer name,artist name , total spent
  select  customer.first_name as firstname,customer.last_name as lastname ,artist.name as artistname ,
  sum(invoice_lines.unit_price*invoice_lines.quantity) as total_spent
					  
  from MusicalPlaylist..customer customer 
  join MusicalPlaylist..invoice invoice ON customer.customer_id=invoice.customer_id
  join MusicalPlaylist..invoice_line$ invoice_lines ON invoice.invoice_id=invoice_lines.invoice_id
  join MusicalPlaylist..track$ tracks ON invoice_lines.track_id=tracks.track_id
  join MusicalPlaylist..album album ON tracks.album_id=album.album_id
  join MusicalPlaylist..artist artist ON album.artist_id=artist.artist_id
  group by customer.first_name,customer.last_name,artist.name
  order by total_spent desc

  --Finding most selling artist--
  --amount spent by the customers on the best selling artist --
  --returning name of the customer, name of artist, amount spent --
  
  With most_selling_artist AS
  (
  Select top(1) ar.name as artist , 
  Sum(il.unit_price*il.quantity) as total_sales
  From MusicalPlaylist..invoice_line$ il
  join MusicalPlaylist..track$ t ON il.track_id=t.track_id
  join MusicalPlaylist..album al ON t.album_id=al.album_id
  join MusicalPlaylist..artist ar ON al.artist_id=ar.artist_id
  Group by
  ar.name
  Order by 
  total_sales desc 
  )
  Select
  c.first_name AS firstname,
  c.last_name AS lastname,
  SUM(il.unit_price * il.quantity) AS total_spent,
  most_selling_artist.artist AS artist_name
FROM
  MusicalPlaylist..customer c
  JOIN MusicalPlaylist..invoice i ON c.customer_id = i.customer_id
  JOIN MusicalPlaylist..invoice_line$ il ON i.invoice_id = il.invoice_id
  JOIN MusicalPlaylist..track$ t ON il.track_id = t.track_id
  JOIN MusicalPlaylist..album al ON t.album_id = al.album_id
  JOIN MusicalPlaylist..artist ar ON al.artist_id = ar.artist_id
  JOIN most_selling_artist ON ar.name = most_selling_artist.artist
GROUP BY
 c.first_name, c.last_name, ar.name, most_selling_artist.artist
ORDER BY
  total_spent DESC;

 
 
 --popular genre in each country with the highest amount of spending-- 
 

 /* method 1 */
 Select  Temp.country as country , Temp.genre as Top_genre , Max(total_spent) AS HighestPurchase
 From
  ( 
    Select i.billing_country AS country,g.name AS genre , SUM(total) as total_spent
    FROM MusicalPlaylist..invoice i 
    JOIN MusicalPlaylist..invoice_line$ il ON i.invoice_id=il.invoice_id
    JOIN MusicalPlaylist..track$ t ON il.track_id=t.track_id
    JOIN MusicalPlaylist..genre g ON t.genre_id=g.genre_id
    Group by
    i.billing_country,g.name
	
  ) 
  as Temp
  Group by  Temp.country , Temp.genre ,Temp.total_spent
  order by Temp. total_spent Desc

  --Popular genre of each country by their number of purchases--

  With Popular_genre AS 
  (
    Select  i.billing_country AS Country, g.name AS Genre ,COUNT(il.quantity) AS Purchases,
	ROW_NUMBER() OVER (Partition By i.billing_country  Order By COUNT(il.quantity) Desc) AS Row_NO
    From MusicalPlaylist..customer c 
	JOIN MusicalPlaylist..invoice i ON c.customer_id=i.customer_id
    JOIN MusicalPlaylist..invoice_line$ il ON i.invoice_id=il.invoice_id
    JOIN MusicalPlaylist..track$ t ON il.track_id=t.track_id
    JOIN MusicalPlaylist..genre g ON t.genre_id=g.genre_id
	Group BY i.billing_country , g.name 
	
   )
Select *
From Popular_genre 
Where Row_NO<=1
Order BY Country Asc , Purchases Desc

/* method 2 */ --not working--

WITH  RECURSIVE
   salesCTE
   AS
   (
   SELECT COUNT(*) AS purchases_per_genre, c.country , g.name, g.genre_id
		 From MusicalPlaylist..customer c 
	     JOIN MusicalPlaylist..invoice i ON c.customer_id=i.customer_id
         JOIN MusicalPlaylist..invoice_line$ il ON i.invoice_id=il.invoice_id
         JOIN MusicalPlaylist..track$ t ON il.track_id=t.track_id
         JOIN MusicalPlaylist..genre g ON t.genre_id=g.genre_id
		 GROUP BY  c.country,g.name ,g.genre_id
		 ) ,
     maximum_genre 
	 AS
	 (
	 SELECT MAX(COUNT(*)) AS max_genre_number , country
	 From salesCTE
	 Group by country
	 )
SELECT *
FROM salesCTE
JOIN maximum_genre ON salesCTE.country=maximum_genre.country
WHERE salesCTE.purchases_per_genre=maximum_genre.max_genre_number


--popular customer of each country by their total spending on music--

WITH Popular_customer AS 
(
Select invoice.billing_country , customer.customer_id , customer.first_name ,customer.last_name , SUM(invoice.total) AS total_spending ,
ROW_NUMBER () OVER (PARTITION BY invoice.billing_country  ORDER BY SUM(total) DESC ) as rowNO
From MusicalPlaylist..customer
JOIN MusicalPlaylist..invoice ON customer.customer_id=invoice.customer_id 
Group by  invoice.billing_country,customer.first_name,customer.last_name ,customer.customer_id
)
  Select * 
  From Popular_customer
  Where rowNO <= 1
  Order by first_name ASC, total_spending DESC 

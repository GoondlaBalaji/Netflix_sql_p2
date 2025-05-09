-- Netflix project
DROP TABLE IF EXISTS netflix ;
CREATE TABLE netflix(
	show_id VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),	
	director VARCHAR(208),	
	casts VARCHAR(1000),
	country VARCHAR(150),	
	date_added VARCHAR(50),
	release_year INT,
	--release_year INT
	--This is correct and works in all databases (PostgreSQL, MySQL, SQL Server, etc.).
	--You store the year as a number like 2024, 2025, etc.
	
	-- release_year YEAR
	-- works only in Mysql
	
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;
SELECT COUNT(*) FROM netflix;

-- 15 Business Problems and Solutions

--1. Count the Number of Movies vs TV Shows
select 
type,
count(*) from netflix
group by 1;

--2. Find the Most Common Rating for Movies and TV Shows
select type,
rating from 

(
	SELECT 
	type,
	--max(rating)3. List All Movies Released in a Specific Year (e.g., 2020)
	rating,
	count(*) ,
	rank() over(partition by type order by count(*) desc) as ranking from netflix
	group by 1 , 2
) 
as t1
where ranking =1;

--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix;

SELECT title , release_year from netflix where release_year='2020'
group by 1,2

--4. Find the Top 5 Countries with the Most Content on Netflix
select country,
count (show_id)
from netflix
group by 1
order by 2 desc 

-- to seperate multiple countries in one row to seperate countries

SELECT * FROM
(
	select
	 unnest(string_to_array(country,',')) as new_country,
	 count(*) as total_count
	from netflix
	group by 1
) as t1 where new_country is NOT NULL
ORDER BY total_count DESC
LIMIT 5;


--5. Identify the Longest Movie
select * from netflix where type = 'Movie'
order by duration desc 

--6. Find Content Added in the Last 5 Years
select * from netflix
where to_date(date_added,'Month DD, YYYY')>=current_date-interval'5 years';

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
--only 'Rajiv Chilaka' created movies was shown
select type,title from netflix where director = 'Rajiv Chilaka'

--short form (prob: case sensitive)
select type,title from netflix where director like '%Rajiv Chilaka%'

--short form (not case sensitive)
select type,title from netflix where director ilike '%Rajiv Chilaka%'


--alternate method
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

--8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;


--9. Count the Number of Content Items in Each Genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

--10.Find each year and the average numbers of content release in India on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--11. List All Movies that are Documentaries
select * from netflix where listed_in LIKE '%Documentaries'

--12. Find All Content Without a Director
select * from netflix where director is NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Year
select * from netflix where casts ilike '%Salman khan%'
and release_year > extract(year from current_date) - 10;

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
--Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
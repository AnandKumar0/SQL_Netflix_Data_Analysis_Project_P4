--- >>> NETFLIX DATA ANALYSIS PROJECTS <<< ---

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
	show_id			VARCHAR(5),
	type			VARCHAR(10),
	title			TEXT,
	director		TEXT,
	casts			TEXT,
	country			TEXT,
	date_added		VARCHAR(55),
	release_year	INT,
	rating			VARCHAR(15),
	duration		VARCHAR(15),
	listed_in		TEXT,
	description		TEXT
);


--- >> IMPORT DATA << ---



--- >> VARIFY THE DATA << ---

SELECT * FROM netflix;


-- >> DATA VALIDATION <<--

-- Total Rows
SELECT COUNT (*) FROM netflix;

-- >> DUPLICATE CHECK << --

-- SHOW IDs
SELECT
	show_id,
	COUNT(*)
FROM netflix
GROUP BY show_id
HAVING COUNT(*) > 1;

-- TITLES ---> some duplicates are normal because diffferent movies or TV shows can share the same title.
SELECT
	title,
	COUNT(*)
FROM netflix
GROUP BY 1
HAVING COUNT(*) > 1;

-->> NULL COUNT <<<--

-- Using FILTER -->> filter counts NULL cells not rows (all individual cells) - output - 4307

SELECT
	COUNT(*) FILTER (WHERE show_id IS NULL) AS show_id,
	COUNT(*) FILTER (WHERE type IS NULL) AS type,
	COUNT(*) FILTER (WHERE title IS NULL) AS title,
	COUNT(*) FILTER (WHERE director IS NULL) AS director,			-- it has 2634
	COUNT(*) FILTER (WHERE casts IS NULL) AS casts,					-- it has 825
	COUNT(*) FILTER (WHERE country IS NULL) AS country,				-- it has 831
	COUNT(*) FILTER (WHERE date_added IS NULL) AS date_added,		-- it has 10
	COUNT(*) FILTER (WHERE release_year IS NULL) AS release_year,
	COUNT(*) FILTER (WHERE rating IS NULL) AS rating,				-- it has 4
	COUNT(*) FILTER (WHERE duration IS NULL) AS duration,			-- it has 3
	COUNT(*) FILTER (WHERE listed_in IS NULL) AS listed_in,
	COUNT(*) FILTER (WHERE description IS NULL) AS description
FROM netflix;

-- Using OR --->> each row is counted only once even if it has multiple NULL columns. - output - 3475

SELECT *
FROM netflix
WHERE show_id IS NULL
   OR type IS NULL
   OR title IS NULL
   OR director IS NULL
   OR casts IS NULL
   OR country IS NULL
   OR date_added IS NULL
   OR release_year IS NULL
   OR rating IS NULL
   OR duration IS NULL
   OR listed_in IS NULL
   OR description IS NULL;


-- >> BLANK VALUES << -- 

SELECT COUNT(*)
FROM netflix
WHERE director = '';	-- no blanks

SELECT COUNT(*)
FROM netflix
WHERE casts = '';	-- no blanks

SELECT COUNT(*)
FROM netflix
WHERE country = '';	-- no blank

-- >> DISTINCT TYPE << --

SELECT DISTINCT type 
FROM netflix;

-- >> DISTINCT RATING << --  look for unexpected values or blanks

SELECT DISTINCT rating
FROM netflix
ORDER BY rating;

-- >> RELEASE YEAR RANGE << --

SELECT
	MIN(release_year),
	MAX(release_year)
FROM netflix;

-- >> DATE ADDED << -- check for format

SELECT date_added
FROM netflix
LIMIT 20;

-- >> DURATION << -- check values how it looks

SELECT DISTINCT duration
FROM netflix
ORDER BY duration;

-- >> -- 15 Business Problems & Solutions
	
	-- 1. Count the number of Movies vs TV Shows
	-- 2. Find the most common rating for movies and TV shows
	-- 3. List all movies released in a specific year (e.g., 2020)
	-- 4. Find the top 5 countries with the most content on Netflix
	-- 5. Identify the longest movie
	-- 6. Find content added in the last 5 years
	-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
	-- 8. List all TV shows with more than 5 seasons
	-- 9. Count the number of content items in each genre
	-- 10.Find each year and the average numbers of content release in India on netflix. 
	-- 11. List all movies that are documentaries
	-- 12. Find all content without a director
	-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
	-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
	-- 15.
	-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
	-- the description field. Label content containing these keywords as 'Bad' and all other 
	-- content as 'Good'. Count how many items fall into each category.
	
-- - >> SOLUTION << --

-- 1. Count the number of Movies vs TV Shows
SELECT
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating
FROM
(
	SELECT
		type,
		rating,
		COUNT(*) AS rating_count,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1, 2
) t1
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = '2020';


-- 4. Find the top 5 countries with the most content on Netflix.

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT
	title,
	duration
FROM netflix
WHERE
	type = 'Movie' AND duration = (SELECT MAX(duration) FROM netflix);


-- 6. Find content added in the last 5 years.

SELECT
	type,
	title,
	date_added
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') = CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director = 'Rajiv Chilaka';			-- this query is not show all record where 'Rajiv Chilaka' direct with another person

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';		-- it filter all record where 'Rajiv Chilaka' exist in any rows


-- 8. List all TV shows with more than 5 seasons.

SELECT
	type,
	SPLIT_PART(duration, ' ', 1) AS sessions
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;

-- 9. Count the number of content items in each genre.

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;


-- 10. Find each year and the average numbers of content release in India on netflix. 

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS years,
	COUNT(*),
	ROUND(COUNT(*)::NUMERIC /(SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

-- 11. List all movies that are documentaries..

SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';


-- 12. Find all content without a director..

SELECT *
FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


SELECT *
FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(*) AS total_content	
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_category AS
(
	SELECT *,
		CASE
			WHEN description ILIKE '%kill%'
				OR
				description ILIKE '%violence%' THEN 'Bad_Content'
			ELSE 'Good_Content'
		END AS category
	FROM netflix
)
SELECT
	category,
	COUNT(*) AS total_content
FROM new_category
GROUP BY 1


--==>>> END THE PROJECT <<<===--


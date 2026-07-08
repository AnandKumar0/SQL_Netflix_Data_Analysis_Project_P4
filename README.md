# Netflix Data Analysis using PostgreSQL
![netflix_logo]()
## Project Overview

**Project Title:** Netflix Data Analysis

**Database:** `sql_project_p4`

**Tools Used:** PostgreSQL, SQL, GitHub

This project demonstrates SQL skills and techniques commonly used by Data Analysts to clean, validate, explore, and analyze Netflix's content catalog data (movies and TV shows).

The project covers the complete analytical workflow, including database setup, data validation, exploratory data analysis (EDA), and business-driven SQL analysis across 15 business problems.

## Objectives

**Database Setup**
Create a single, well-structured table to hold Netflix's content catalog (titles, cast, country, ratings, duration, genres, etc.).

**Data Validation**
Identify duplicate records, NULL values (both per-cell and per-row), blank strings, and unexpected/out-of-range values before analysis.

**Exploratory Data Analysis (EDA)**
Understand content types, rating categories, release year range, date formats, and duration formats.

**Business Analysis**
Answer 15 real-world business questions covering content distribution, ratings, genres, countries, directors, and actors.

## Project Structure

### 1. Database Setup

**Table Creation**

The project starts by creating a single raw `netflix` table.

```sql
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
```

**Verify the Data**

```sql
SELECT * FROM netflix;
```

### 2. Data Validation

**Total Row Count**

```sql
SELECT COUNT (*) FROM netflix;
```

**Duplicate Checks**

Checked `show_id` (should be unique) and `title` (duplicates expected here, since different movies/TV shows can share the same title).

```sql
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
```

**NULL Count**

Two approaches were compared — `FILTER` (counts NULL **cells**, so one row with multiple NULLs is counted multiple times) vs `OR` (counts NULL **rows**, so each row is counted once even with multiple NULL columns).

```sql
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
```

**Blank Values Check**

```sql
SELECT COUNT(*)
FROM netflix
WHERE director = '';	-- no blanks

SELECT COUNT(*)
FROM netflix
WHERE casts = '';	-- no blanks

SELECT COUNT(*)
FROM netflix
WHERE country = '';	-- no blank
```

### 3. Exploratory Data Analysis (EDA)

**Distinct Content Type**

```sql
SELECT DISTINCT type 
FROM netflix;
```

**Distinct Ratings** — look for unexpected values or blanks

```sql
SELECT DISTINCT rating
FROM netflix
ORDER BY rating;
```

**Release Year Range**

```sql
SELECT
	MIN(release_year),
	MAX(release_year)
FROM netflix;
```

**Date Added Format Check**

```sql
SELECT date_added
FROM netflix
LIMIT 20;
```

**Duration Format Check**

```sql
SELECT DISTINCT duration
FROM netflix
ORDER BY duration;
```

### 4. Business Problems & Solutions

15 business questions were identified and solved:

1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10. Find each year and the average number of content release in India on Netflix
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in over the last 10 years
14. Find the top 10 actors who have appeared in the highest number of movies produced in India
15. Categorize content as 'Good' or 'Bad' based on the keywords 'kill' and 'violence' in the description, and count each category

**Q1. Count the number of Movies vs TV Shows**

```sql
SELECT
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Q2. Find the most common rating for movies and TV shows**

```sql
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
```

**Q3. List all movies released in a specific year (e.g., 2020)**

```sql
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = '2020';
```

**Q4. Find the top 5 countries with the most content on Netflix**

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Q5. Identify the longest movie**

```sql
SELECT
	title,
	duration
FROM netflix
WHERE
	type = 'Movie' AND duration = (SELECT MAX(duration) FROM netflix);
```

**Q6. Find content added in the last 5 years**

```sql
SELECT
	type,
	title,
	date_added
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') = CURRENT_DATE - INTERVAL '5 years';
```

**Q7. Find all the movies/TV shows by director 'Rajiv Chilaka'**

```sql
SELECT *
FROM netflix
WHERE director = 'Rajiv Chilaka';			-- this query is not show all record where 'Rajiv Chilaka' direct with another person

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';		-- it filter all record where 'Rajiv Chilaka' exist in any rows
```

**Q8. List all TV shows with more than 5 seasons**

```sql
SELECT
	type,
	SPLIT_PART(duration, ' ', 1) AS sessions
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;
```

**Q9. Count the number of content items in each genre**

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;
```

**Q10. Find each year and the average numbers of content release in India on Netflix**

```sql
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS years,
	COUNT(*),
	ROUND(COUNT(*)::NUMERIC /(SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
```

**Q11. List all movies that are documentaries**

```sql
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';
```

**Q12. Find all content without a director**

```sql
SELECT *
FROM netflix
WHERE director IS NULL
```

**Q13. Find how many movies actor 'Salman Khan' appeared in last 10 years**

```sql
SELECT *
FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
;
```

**Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India**

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(*) AS total_content	
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Q15. Categorize content based on 'kill'/'violence' keywords in the description as 'Bad' or 'Good', and count each category**

```sql
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
```

## Findings

- **Content Mix** — The catalog is split between Movies and TV Shows, with movies typically making up the larger share.
- **Ratings** — A small set of ratings (e.g., TV-MA, TV-14) dominate across both content types.
- **Geographic Spread** — A handful of countries (led by the US and India) account for most of the content library.
- **Data Gaps** — A notable portion of records are missing `director`, `casts`, or `country` values, which is important context for any downstream analysis using those fields.
- **Genre Distribution** — Genres were normalized from comma-separated lists into individual rows for accurate counting.
- **Content Sensitivity** — A simple keyword-based classifier ('kill'/'violence') was used to flag potentially sensitive content — a lightweight, non-ML approach to content moderation tagging.

## Reports Generated

- Data validation report (duplicates, NULLs — cell-level vs row-level, blanks)
- Content type & rating distribution
- Country-wise and genre-wise content breakdown
- Director- and actor-specific filtering (e.g., Rajiv Chilaka, Salman Khan)
- India-specific yearly content trend and top actors
- Content categorization report (Good vs Bad based on keyword screening)

## SQL Concepts Used

- ✔ CREATE TABLE / DROP TABLE
- ✔ Data Validation (duplicates, NULLs, blanks)
- ✔ `COUNT(*) FILTER (WHERE ...)` vs `OR`-based NULL counting
- ✔ String Functions (`STRING_TO_ARRAY`, `UNNEST`, `TRIM`, `SPLIT_PART`)
- ✔ Pattern Matching (`ILIKE`)
- ✔ Date Functions (`TO_DATE`, `EXTRACT`, `CURRENT_DATE`)
- ✔ CASE WHEN
- ✔ CTEs (Common Table Expressions)
- ✔ Window Functions (`RANK`)
- ✔ Subqueries
- ✔ Business Analysis

## Conclusion

This project helped strengthen my practical SQL and PostgreSQL skills for analyzing semi-structured, real-world catalog data.

It demonstrates practical experience in:

- Data validation on messy, single-table datasets
- Handling comma-separated multi-value fields (genres, cast, country) using array functions
- Exploratory Data Analysis
- CTEs and window functions for advanced analytics
- Business problem solving around content strategy, ratings, and regional trends
- Lightweight content categorization using keyword screening

The insights generated from this project can support decision-making related to content acquisition strategy, regional content planning, and catalog quality monitoring.

## How To Use

1. Download or clone this repository.
2. Open PostgreSQL or pgAdmin.
3. Create a database:
   ```sql
   CREATE DATABASE sql_project_p4;
   ```
4. Execute the SQL script in sequence:
   - Database Setup
   - Data Validation
   - Exploratory Data Analysis
   - Business Analysis (Q1–Q15)
5. Review the query outputs and findings.

## Author

**Anand Kumar**

Aspiring Data Analyst

PostgreSQL | SQL | Data Analytics

This project is part of my Data Analytics portfolio showcasing SQL skills required for Data Analyst roles.

Feel free to connect, provide feedback, or collaborate on future projects.

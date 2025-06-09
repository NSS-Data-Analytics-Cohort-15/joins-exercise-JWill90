
SELECT * 
FROM public.distributors;

SELECT * 
FROM public.rating;

SELECT * 
FROM public.revenue;

SELECT * 
FROM public.specs;

-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.

SELECT 
	specs.film_title, 
	specs.release_year,
	revenue.worldwide_gross	
FROM specs
	LEFT JOIN revenue
	ON specs.movie_id = revenue.movie_id
ORDER BY worldwide_gross
LIMIT 1;

-- Answer: Name of Film Semi-Tough
		   Year 1977	
		   Lowest Gross: 37187139


-- 2. What year has the highest average imdb rating?

SELECT 
	specs.release_year,
	AVG (rating.imdb_rating) AS Avg_rating
FROM specs
JOIN rating
	ON specs.movie_id = rating.movie_id
GROUP BY specs.release_year
ORDER BY Avg_rating DESC
LIMIT 1;

-- Answer: (1991) avg_rating: 7.45


-- 3. What is the highest grossing G-rated movie? Which company distributed it?

SELECT
    MAX(revenue.worldwide_gross) AS highest_gross,
    specs.film_title,
	distributors.company_name	
FROM
    specs
JOIN
    distributors ON specs.domestic_distributor_id = distributors.distributor_id
JOIN
    revenue USING(movie_id)
WHERE
    specs.mpaa_rating = 'G'
GROUP BY specs.mpaa_rating, distributors.company_name, specs.film_title -- Why do I need to include specs.film_title (per Postgres) when I'm not looking to group by individual movie titles. The question is asking for the single highest-grossing G-rated movie overall.   
ORDER BY 1 DESC	
LIMIT 1; 

-- Answer: Toy Story 4, Walt Disney


-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

SELECT
    distributors.company_name,
    COUNT(specs.movie_id) AS number_of_movies -- To include NULL values in my result set for that row 
FROM
    distributors
LEFT JOIN
    specs 
ON distributors.distributor_id = specs.domestic_distributor_id
GROUP BY
    distributors.company_name, distributors.distributor_id 
ORDER BY 1;

-- 5. Write a query that returns the five distributors with the highest average movie budget.

SELECT
    distributors.company_name,
    AVG(revenue.film_budget) AS highest_avg_budget
FROM distributors 
JOIN specs 
	ON distributors.distributor_id = specs.domestic_distributor_id
JOIN revenue 
	USING(movie_id)
GROUP BY distributors.distributor_id,  distributors.company_name
ORDER BY 2 DESC
LIMIT 5;

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

-- a.
SELECT
    COUNT(DISTINCT specs.movie_id) AS total_movies_not_from_CA_distributor
FROM distributors 
	JOIN specs 
	ON distributors.distributor_id = specs.domestic_distributor_id
WHERE distributors.headquarters NOT LIKE '%CA%';

-- Using ILIKE 
SELECT
    COUNT(DISTINCT specs.movie_id) AS total_movies_not_from_CA_distributor
FROM distributors 
	JOIN specs 
	ON distributors.distributor_id = specs.domestic_distributor_id
WHERE distributors.headquarters NOT ILIKE '%CA%'; -- -- Different result using ILIKE. Discuss in class 

-- b.
SELECT
    specs.film_title,
    distributors.company_name,
    distributors.headquarters,
    rating.imdb_rating AS highest_imdb_rating_for_this_movie
FROM distributors 
	JOIN specs 
	ON distributors.distributor_id = specs.domestic_distributor_id
	JOIN rating 
	USING(movie_id)
WHERE distributors.headquarters NOT LIKE '%CA%'
ORDER BY 4 DESC
LIMIT 1;

-- Using ILIKE 

SELECT
    specs.film_title,
    distributors.company_name,
    distributors.headquarters,
    rating.imdb_rating AS highest_imdb_rating_for_this_movie
FROM distributors 
	JOIN specs 
	ON distributors.distributor_id = specs.domestic_distributor_id
	JOIN rating 
	USING(movie_id)
WHERE distributors.headquarters NOT ILIKE '%CA%'
ORDER BY 4 DESC
LIMIT 1;

-- Answer: (2) movies. Dirty Dancing had the highest imdb rating out of the (2) 


-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

SELECT 	
	specs.film_title, 
	specs.movie_id,
	specs.length_in_min,
	AVG(rating.imdb_rating) AS higher_avg_rating,
	rating.movie_id	
FROM specs
	JOIN rating
	USING(movie_id)
WHERE specs.length_in_min > 120 OR specs.length_in_min < 120
GROUP BY specs.film_title, specs.movie_id, specs.length_in_min, rating.movie_id	
ORDER BY 4 DESC;

-- I can see what I did wrong, I'm grouping by the movie vs the average rating per length. The question is not asking for the film title only the length in min.  

-- Answer: Listing the Top (3) Movies over 120 minutes with higher_avg_rating: The Dark Knight (9.0), Schindler's List (8.9), The Lord of the Rings: The Return of the King (8.9)
		   Listing the Top (3) Movies under 120 minutues with higher_avg_rating: The Silence of the Lambs (8.6), Back to the Future (8.5), The Lion King (8.5)

Recommended Formula -- Discuss in Class: 

SELECT
    CASE
        WHEN specs.length_in_min > 120 THEN 'Over 2 Hours'
        WHEN specs.length_in_min <= 120 THEN '2 Hours or Less' -- This includes movies exactly 120 mins. 
    END AS film_length_category, -- This creates a new column called film_length_category that assigns each movie to one of your desired categories based on its length 
    AVG(rating.imdb_rating) AS average_rating
FROM
    specs
JOIN
    rating ON specs.movie_id = rating.movie_id
GROUP BY
    film_length_category -- Grouping all movies belonging to 'Over 2 Hours' into one group and '2 Hours or Less' into another, allowing AVG() to calculate the average for each category.
ORDER BY 1 DESC;

-- Answer:  Movies over 2 hours (7.26)

	

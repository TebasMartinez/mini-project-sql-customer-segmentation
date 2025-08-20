USE customer_segmentation;

# Check table
SELECT * FROM customer_segmentation;

# Check unique values of categorical variables
SELECT DISTINCT gender FROM customer_segmentation;

SELECT DISTINCT preferred_category FROM customer_segmentation;

# Check avgs of all numerical variables
SELECT AVG(age),
	AVG(spending_score),
    AVG(membership_years),
    AVG(purchase_frequency),
    AVG(last_purchase_amount)
FROM customer_segmentation;

# Check avgs of numerical variables per each categorical variable
SELECT gender,
	AVG(age),
	AVG(spending_score),
    AVG(membership_years),
    AVG(purchase_frequency),
    AVG(last_purchase_amount)
FROM customer_segmentation
GROUP BY gender;

SELECT preferred_category,
	AVG(age),
	AVG(spending_score),
    AVG(membership_years),
    AVG(purchase_frequency),
    AVG(last_purchase_amount)
FROM customer_segmentation
GROUP BY preferred_category;

# Customer segmentation -> create views by gender
CREATE VIEW female_gender_cust AS
	SELECT *
    FROM customer_segmentation
    WHERE gender = "female";
    
CREATE VIEW male_gender_cust AS
	SELECT *
    FROM customer_segmentation
    WHERE gender = "male";
    
CREATE VIEW other_gender_cust AS
	SELECT *
    FROM customer_segmentation
    WHERE gender = "other";
    
# Customer segmentation -> create views by spending_score, creating four customer categories based on the spending score:
# Bad customers <- 0-25 spending score
# Medium customers <- 26-50 spending score
# Good customers <- 51-75 spending score
# Great customers <- 76-100 spending score

# Use CASE-WHEN to create a new column customer_categories
CREATE VIEW customer_categories AS
SELECT *,
	CASE
		WHEN spending_score > 0 AND spending_score < 26 THEN "Bad customer"
        WHEN spending_score >= 26 AND spending_score < 51 THEN "Medium customer"
        WHEN spending_score >= 51 AND spending_score < 76 THEN "Good customer"
        WHEN spending_score >=76 THEN "Great customer"
	END AS customer_category
FROM customer_segmentation;

# Create one view per each customer category
CREATE VIEW bad_customers AS
SELECT *
FROM customer_categories
WHERE customer_category = "Bad customer";

CREATE VIEW medium_customers AS
SELECT *
FROM customer_categories
WHERE customer_category = "Medium customer";

CREATE VIEW good_customers AS
SELECT *
FROM customer_categories
WHERE customer_category = "Good customer";

CREATE VIEW great_customers AS
SELECT *
FROM customer_categories
WHERE customer_category = "Great customer";

# Customer segmentation -> create views by age group
CREATE VIEW age_groups AS
SELECT *,
	CASE
		WHEN age < 18 THEN "Children"
        WHEN age >= 18 AND age < 30 THEN "Young adult"
        WHEN age >= 30 AND age < 40 THEN "Over-thirties"
        WHEN age >= 40 AND age < 50 THEN "Over-forties"
        WHEN age >= 50 AND age < 60 THEN "Over-fifties"
        WHEN age >= 50 THEN "Seniors"
	END AS age_group
FROM customer_segmentation;

SELECT * FROM age_groups;

# Count customers per age group
SELECT age_group, COUNT(*)
FROM age_groups
GROUP BY age_group;

# Create one view per each age group
CREATE VIEW young_adults AS
SELECT *
FROM age_groups
WHERE age_group = "Young adult";

CREATE VIEW over_thirties AS
SELECT *
FROM age_groups
WHERE age_group = "Over-thirties";

CREATE VIEW over_forties AS
SELECT *
FROM age_groups
WHERE age_group = "Over-forties";

CREATE VIEW over_fifties AS
SELECT *
FROM age_groups
WHERE age_group = "Over-fifties";

CREATE VIEW seniors AS
SELECT *
FROM age_groups
WHERE age_group = "Seniors";

# Customer segmentation -> create views by income group

# Check values
SELECT DISTINCT income
FROM customer_segmentation
ORDER BY income;

# Create segmentation
CREATE VIEW income_groups AS
SELECT *,
	CASE
		WHEN income >= 30000 AND income < 60000 THEN "Lower-Mid Income"
        WHEN income >= 60000 AND income < 90000 THEN "Middle Income"
        WHEN income >= 90000 AND income < 120000 THEN "Upper-Mid Income"
        WHEN income >= 120000 THEN "Affluent"
	END AS income_group
FROM customer_segmentation;

# Create one view per each age group
CREATE VIEW lower_mid_income AS
SELECT *
FROM income_groups
WHERE income_group = "Lower-Mid Income";

CREATE VIEW middle_income AS
SELECT *
FROM income_groups
WHERE income_group = "Middle Income";

CREATE VIEW upper_mid_income AS
SELECT *
FROM income_groups
WHERE income_group = "Upper-Mid Income";

CREATE VIEW affluent_income AS
SELECT *
FROM income_groups
WHERE income_group = "Affluent Income";

# Create temporary table with top 10% (100 of 1000) high-value customers based on spending score
CREATE TEMPORARY TABLE top10_spending_score AS (
SELECT *
FROM customer_categories
ORDER BY spending_score DESC
LIMIT 100);
SELECT * FROM top10_spending_score;

# Create temporary table with top 10% high-value customer based on ther last purchase amount
CREATE TEMPORARY TABLE top10_last_purchase_amount AS (
SELECT *
FROM customer_categories
ORDER BY last_purchase_amount DESC
LIMIT 100);
SELECT * FROM top10_last_purchase_amount;

# Out of top10_last_purchase_amount, check how many fall into each customer_category
SELECT customer_category, COUNT(*) AS n_customers_in_top10_last_purchase_amount
FROM top10_last_purchase_amount
GROUP BY customer_category;

# BUSINESS QUESTIONS

# WHAT ARE THE PREFERRED CATEGORIES PER CUSTOMER SEGMENT?
# The same query needs to be used for all segments, so it can be done with the following procedure:
DELIMITER //
CREATE PROCEDURE preferred_categories_per_segment(IN segment_view VARCHAR(45), IN segment_column VARCHAR(45))
BEGIN
	SET @sql = CONCAT(
		'WITH customers_per_segment AS (
			SELECT COUNT(*) AS n_cust, ',
				segment_column, '
			FROM ', segment_view, '
			GROUP BY ', segment_column, '
		),
		preferred_category_per_segment AS (
			SELECT ', segment_column, ',
			preferred_category, 
			COUNT(*) AS n_cat_per_segment
			FROM ', segment_view, '
			GROUP BY ', segment_column, ', preferred_category
			ORDER BY ', segment_column, ', COUNT(*) DESC
		)
		SELECT ', segment_column, ', 
			preferred_category, 
			n_cat_per_segment AS "Customers who prefer this category",
			CONCAT(ROUND(n_cat_per_segment / n_cust * 100, 2), "%") AS "Percentage"
		FROM customers_per_segment
		JOIN preferred_category_per_segment USING(', segment_column, ')
		ORDER BY ', segment_column, ', n_cat_per_segment DESC;'
	);
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//
DELIMITER ;

# Preferred categories per gender
CALL preferred_categories_per_segment("customer_segmentation", "gender");
# Preferred categories per age group
CALL preferred_categories_per_segment("age_groups", "age_group");
#Preferred categories per customer categories
CALL preferred_categories_per_segment("customer_categories", "customer_category");

# HIGH-VALUE SEGMENTS: WHICH DEMOGRAPHICS GENERATED THE MOST REVENUE IN THER LAST PURCHASE?

#Procedure to extract revenue per segment groups
DELIMITER //
CREATE PROCEDURE last_purchase_revenue_per_segment(IN segment_view VARCHAR(45), IN segment_column VARCHAR(45))
BEGIN
	SET @sql = CONCAT('
	SELECT ', segment_column, ',
		ROUND(SUM(last_purchase_amount), 2) AS "Revenue (last purchase per customer)"
	FROM ', segment_view ,'
	GROUP BY ', segment_column, '
    ORDER BY SUM(last_purchase_amount) DESC;'
    );
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//
DELIMITER ;

# Last purchase revenue per gender
CALL last_purchase_revenue_per_segment("customer_segmentation", "gender");
# Last purchase revenue per age group
CALL last_purchase_revenue_per_segment("age_groups", "age_group");
# Last purchase revenue per customer categories
CALL last_purchase_revenue_per_segment("customer_categories", "customer_category");

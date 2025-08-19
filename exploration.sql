# Check table
SELECT * FROM customer_segmentation;

# Check unique values of categorical variables
SELECT DISTINCT gender FROM customer_segmentation;

SELECT DISTINCT preferred_category FROM customer_segmentation;

# Check avgs of numerical variables

SELECT AVG(age),
	AVG(spending_score),
    AVG(membership_years),
    AVG(purchase_frequency),
    AVG(last_purchase_amount)
FROM customer_segmentation;

# Check avgs of numerical variables per categorical variables

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

SELECT *,
	CASE
		WHEN spending_score > 0 AND spending_score < 26 THEN "Bad customer"
        WHEN spending_score >= 26 AND spending_score < 51 THEN "Medium customer"
        WHEN spending_score >= 51 AND spending_score < 76 THEN "Good customer"
        WHEN spending_score >=76 THEN "Great customer"
	END AS customer_category
FROM customer_segmentation;

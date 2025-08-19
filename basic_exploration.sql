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

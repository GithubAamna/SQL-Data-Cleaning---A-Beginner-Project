/*
																   Data Cleaning 
---------------------------------------------------------------	A Beginner Project -----------------------------------------------------------------------------------------------------------------------------

 Follow these four steps
	1) Remove Duplicates
    2) Standarize the Data
    3) NULL Values or Blank Values
    4) Remove unwanted rows and columns
*/

Select *
FROM layoffs;

-- GOOD PRACTICE
-- Generating the copy of data incase we loose some important data -------------------------------------------------------------------------------------------------
CREATE TABLE layoffs_2
LIKE layoffs;

SELECT *
FROM layoffs_2;

INSERT layoffs_2
SELECT *
FROM layoffs;


-- STEP 1 : Remove Duplicates -----------------------------------------------------------------------------------------------------------------------------------------------

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,total_laid_off, percentage_laid_off,'date',stage, country, funds_raised_millions) AS row_num
FROM layoffs_2
)

SELECT*
FROM duplicate_cte
WHERE row_num>1;

SELECT *
FROM layoffs_2
WHERE company= 'CASPER';

/* Creating table with this name to keep in mind that duplicates have been removed. This table is used for further cleaning. */
CREATE TABLE `layoffs_duplicate_removal` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_duplicate_removal
WHERE row_num=2;

INSERT INTO layoffs_duplicate_removal
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,total_laid_off, percentage_laid_off,'date',stage, country, funds_raised_millions) AS row_num
FROM layoffs_2;

DELETE
FROM layoffs_duplicate_removal
WHERE row_num>1;

SELECT * 
FROM layoffs_duplicate_removal;

-- STEP 2: Standardizing data-----------------------------------------------------------------------------------------------------------------------------------
SELECT company, TRIM(company)
FROM layoffs_duplicate_removal;

UPDATE layoffs_duplicate_removal
SET company= TRIM(company);

SELECT DISTINCT industry
FROM layoffs_duplicate_removal
ORDER BY 1;

SELECT *
FROM layoffs_duplicate_removal
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_duplicate_removal
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_duplicate_removal;

SELECT DISTINCT country
FROM layoffs_duplicate_removal
ORDER BY 1;

UPDATE layoffs_duplicate_removal
SET country = 'United States'
WHERE country LIKE 'United States%';

/* Alternatively 
SELECT DISTINCT country, TRIM(Trailing '.' FROM country)  ---- This will also remove the trailing period from the United States-----
FROM layoffs_duplicate_removal
ORDER BY 1;

--Update it accordingly
*/

-- Updating the date column by changing its data type i.e. text to date format 
SELECT `date`
FROM layoffs_duplicate_removal;

UPDATE layoffs_duplicate_removal
SET `date`= STR_TO_DATE (`date`, '%m/%d/%Y');

ALTER TABLE layoffs_duplicate_removal
MODIFY COLUMN `date` DATE;

-- STEP 3: Finding NULL and BLANK spaces----------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM layoffs_duplicate_removal
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_duplicate_removal
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_duplicate_removal
WHERE industry is NULL;

SELECT *
FROM layoffs_duplicate_removal
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_duplicate_removal t1
JOIN layoffs_duplicate_removal t2
	ON t1.company = t2.company
WHERE (t1.industry is NULL)
AND t2.industry is NOT NULL;

UPDATE layoffs_duplicate_removal t1
JOIN layoffs_duplicate_removal t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry is NULL)
AND t2.industry is NOT NULL;

-- STEP 4 : Deleting unwanted rows and columns --------------------------------------------------------------------------------------------------------------------
DELETE
FROM layoffs_duplicate_removal
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_duplicate_removal;

ALTER TABLE layoffs_duplicate_removal
DROP COLUMN row_num;


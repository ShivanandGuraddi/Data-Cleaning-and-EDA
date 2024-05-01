select *
from copy2_layoffs ;

# Max layoffs in single time
select
max(total_laid_off) as Max_Layoffs
from copy2_layoffs ;

# Looking at Percentage to see how big these layoffs were
select
max(percentage_laid_off) as 'Max%_Layoffs'
,min(percentage_laid_off) as 'min%_Layoffs'
from copy2_layoffs
WHERE  percentage_laid_off IS NOT NULL ;

# Which companies had 1 which is basically 100 percent of they company laid off
select
company
from copy2_layoffs
where percentage_laid_off = 1 ;

# order by funds_raised_millions we can see how big some of these companies were

select * 
from copy2_layoffs
where percentage_laid_off = 1
order by funds_raised_millions desc ;

# Top 5 Companies with the biggest single Layoff
select
company
,total_laid_off
from copy2_layoffs
order by 2 desc
limit 5 ;

# Top 5 Companies with the most Total Layoffs
select
company
,sum(total_laid_off)
from copy2_layoffs
group by 1
order by 2 desc
limit 5 ;

# Top 5 Total Layoffs by location
select
location
,sum(total_laid_off)
from copy2_layoffs
group by 1
order by 2 desc
limit 5 ;

# Top 5 Total Layoffs by country
select
country
,sum(total_laid_off)
from copy2_layoffs
group by 1
order by 2 desc
limit 5 ;

# Total Layoffs by year
select
year(`date`) as Year
,sum(total_laid_off) as Total_layoffs
from copy2_layoffs
group by 1
order by 1 ;

# Top 5 Total Layoffs by industry
select
industry
,sum(total_laid_off) as Total_layoffs
from copy2_layoffs
group by 1
order by 2 desc
limit 5 ;

# Total Layoffs by industry
SELECT stage
,SUM(total_laid_off)
FROM copy2_layoffs
GROUP BY stage
ORDER BY 2 DESC;

# Total layoffs by company by yearwise and rankwise
WITH Company_Year AS 
(
  SELECT 
  company, 
  YEAR(date) AS years, 
  SUM(total_laid_off) AS total_laid_off
  FROM copy2_layoffs
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT 
  company, 
  years, 
  total_laid_off, 
  DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

# Rolling Total of Layoffs Per Month
SELECT 
SUBSTRING(date,1,7) as dates, 
SUM(total_laid_off) AS total_laid_off
FROM copy2_layoffs
GROUP BY dates
ORDER BY dates ASC;

#  now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT 
SUBSTRING(date,1,7) as dates, 
SUM(total_laid_off) AS total_laid_off
FROM copy2_layoffs
GROUP BY dates
ORDER BY dates ASC
)
SELECT 
dates, 
SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
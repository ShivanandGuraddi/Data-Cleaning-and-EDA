select * 
from layoffs ;

-- To avoide any human error while working with the row dataset, create the copy table and work on it

create table copy_layoffs
like layoffs ;

insert copy_layoffs
select * 
from layoffs ;

select * 
from copy_layoffs ;


# Remove Duplicate:
-- First let's check for duplicates

select *
,row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as R_no
from copy_layoffs ;

select *
from(select *
,row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions) as R_no
from copy_layoffs ) as cte
where R_no > 1 ;

-- The targate table cte of the DELETE is not updateable so create copy of it

CREATE TABLE `copy2_layoffs` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `R_no` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from copy2_layoffs ;

insert copy2_layoffs
select *
from(select *
,row_number() 
over(partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions) as R_no
from copy_layoffs ) as cte ;

set sql_safe_updates=0 ;

DELETE 
from copy2_layoffs 
where R_no > 1;

select * 
from copy2_layoffs ;


# Standardizing data

-- By looking at company column we can see extra space, trim the exctra space 
select
company
,trim(company)
from copy2_layoffs ;

update copy2_layoffs
set company = trim(company) ;

select distinct(industry)
from copy2_layoffs ;

-- Crypto industry is repeting with diff names
update copy2_layoffs
set industry = 'Crypto'
where industry like 'Crypto%' ;

-- with location
select distinct location
from copy2_layoffs
order by 1 ;

-- with country
select distinct country
from copy2_layoffs
order by 1 ;

-- United States is repeating with diff name
update copy2_layoffs
set country = 'United States'
where country like 'United States%' ;

select *
from copy2_layoffs ;

-- change date fromat from text to date
select
`date`
,str_to_date(`date`, '%m/%d/%Y')
from copy2_layoffs ;

update copy2_layoffs
set `date` = str_to_date(`date`, '%m/%d/%Y') ;

alter table copy2_layoffs
modify column `date` date ;


# Null values or Blank values

select distinct industry
from copy2_layoffs ;

-- Since we have null and blank values in industry for company which the industry is assigned will try to replace them
select *
from copy2_layoffs
where industry is null or industry = '';

-- update all blank values to null in column industry
update copy2_layoffs
set industry = null
where industry = '';

select t1.industry ,t2.industry
from copy2_layoffs t1 join copy2_layoffs t2 on t1.company = t2.company
where t1.industry is null
and t2.industry is not null ;

update copy2_layoffs t1 join copy2_layoffs t2 on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null ;

-- we can't populate the null values of total_laid_off and percentage_laid_off since we are not provide the total employee column


# Removing unwanted rows or column

-- since both total_laid_off and percentage_laid_off are null we can't perform EDA on this data so will remove this data
select *
from copy2_layoffs
where total_laid_off is null and percentage_laid_off is null ;

delete
from copy2_layoffs
where total_laid_off is null and percentage_laid_off is null ;

-- Removing unwanted column 
alter table copy2_layoffs
drop column R_no ;

select *
from copy2_layoffs
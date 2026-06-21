-- 1. Drop geographical text columns from fact table
ALTER TABLE dbo.saudi_real_estate_sale 
DROP COLUMN city, city_en, district, district_en, province;

-- 2. Drop scraping time and date columns
ALTER TABLE dbo.saudi_real_estate_sale 
DROP COLUMN createdAt, [month], week_day;

-- 3. Clean and set Primary Key for cities dimension table
WITH CTE_Cities AS (
    SELECT city_id, city, city_en,
           ROW_NUMBER() OVER (PARTITION BY city_id ORDER BY city_id) as rn
    FROM dbo.sa_cities
)
DELETE FROM CTE_Cities WHERE rn > 1;

ALTER TABLE dbo.sa_cities 
ALTER COLUMN city_id INT NOT NULL;

ALTER TABLE dbo.sa_cities 
ADD CONSTRAINT PK_sa_cities PRIMARY KEY (city_id);

-- 4. Clean and set Primary Key for districts dimension table
WITH CTE_Districts AS (
    SELECT district_id, district, district_en,
           ROW_NUMBER() OVER (PARTITION BY district_id ORDER BY district_id) as rn
    FROM dbo.sa_districts
)
DELETE FROM CTE_Districts WHERE rn > 1;

ALTER TABLE dbo.sa_districts 
ALTER COLUMN district_id INT NOT NULL;

ALTER TABLE dbo.sa_districts 
ADD CONSTRAINT PK_sa_districts PRIMARY KEY (district_id);

-- 5. Prepare foreign key columns in fact table
ALTER TABLE dbo.saudi_real_estate_sale 
ALTER COLUMN city_id INT NOT NULL;

ALTER TABLE dbo.saudi_real_estate_sale 
ALTER COLUMN district_id INT NOT NULL;

-- 6. Create Foreign Key relationships for Star Schema
ALTER TABLE dbo.saudi_real_estate_sale
ADD CONSTRAINT FK_saudi_real_estate_sale_cities
FOREIGN KEY (city_id) REFERENCES dbo.sa_cities (city_id);

ALTER TABLE dbo.saudi_real_estate_sale
ADD CONSTRAINT FK_saudi_real_estate_sale_districts
FOREIGN KEY (district_id) REFERENCES dbo.sa_districts (district_id);

select * from saudi_real_estate_sale
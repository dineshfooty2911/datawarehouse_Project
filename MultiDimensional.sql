--DimDate --TYPE 0 SCD
CREATE TABLE DimDate (
datekey NUMBER(10) NOT NULL,
DateValue DATE NOT NULL,
CYear NUMBER(10) NOT NULL,
CMonth NUMBER(2) NOT NULL,
DayNo NUMBER(2) NOT NULL,
CQtr NUMBER(1) NOT NULL,
StartOfMonth DATE NOT NULL,
EndOfMonth DATE NOT NULL,
MonthName VARCHAR2(9) NOT NULL,
DayOfWeekName VARCHAR2(9) NOT NULL,
CONSTRAINT PK_DimDate PRIMARY KEY ( datekey )
);

--DimLocation --Type 1 SCD
CREATE TABLE DimLocation(
locationKey NUMBER(6),
country_name VARCHAR2(40) NULL,
country_subregion VARCHAR2(30) NULL,
country_region VARCHAR2(20) NULL,
CONSTRAINT PK_DimLocation PRIMARY KEY ( locationKey )
);


--DimPromotions --Type 1 SCD
CREATE TABLE DimPromotions(
promotionKey NUMBER(6) NULL,
promo_name VARCHAR2(30) NULL,
promo_subcategory VARCHAR2(30) NULL,
promo_category VARCHAR2(30) NULL,
promo_cost NUMBER(10,2) NULL,
CONSTRAINT PK_DimPromotions PRIMARY KEY (promotionKey)
);



--DimCustomers -- Type 2 SCD
CREATE TABLE DimCustomers(
customerKey NUMBER(6),
cust_first_name VARCHAR2(20) NULL,
cust_last_name VARCHAR2(40) NULL,
cust_street_address VARCHAR2(40) NULL,
cust_postal_code VARCHAR2(10) NULL,
cust_city VARCHAR2(30) NULL,
cust_state_province VARCHAR2(40) NULL,
cust_main_phone_number   VARCHAR2(25) NULL,
cust_email VARCHAR2(50),
country_name VARCHAR2(40) NULL, 
country_subregion VARCHAR2(30) NULL, 
country_region VARCHAR2(20) NULL, 
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimCustomers PRIMARY KEY ( customerKey )
);

--DimProducts --Type 2 SCD
CREATE TABLE DimProducts(
productKey NUMBER(10),
prod_name VARCHAR2(50) NULL,
prod_subcategory VARCHAR2(50) NULL,
prod_category VARCHAR2(50) NULL,
prod_status  VARCHAR2(20) NULL,
prod_list_price NUMBER(8,2) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_DimProducts PRIMARY KEY ( productKey )
);

--FactSales
CREATE TABLE FactSales (
productKey NUMBER(6) NOT NULL,
customerKey NUMBER(6) NOT NULL,
locationKey NUMBER(6) NOT NULL,
promotionKey NUMBER(6)NOT NULL,
dateKey NUMBER(6) NOT NULL,
quantity_sold NUMBER(3) NOT NULL,
amount_sold NUMBER(10,2) NOT NULL,
unit_cost NUMBER(10,2) NOT NULL,
unit_price NUMBER(10,2) NOT NULL,
CONSTRAINT FK_FactSales_customerKey FOREIGN KEY (customerKey) REFERENCES DimCustomers (customerKey),
CONSTRAINT FK_FactSales_locationKey FOREIGN KEY (locationKey) REFERENCES DimLocation(locationKey),
CONSTRAINT FK_FactSales_productKey FOREIGN KEY (productKey) REFERENCES DimProducts (productKey),
CONSTRAINT FK_FactSales_promotionKey FOREIGN KEY (promotionKey) REFERENCES DimPromotions (promotionKey),
CONSTRAINT FK_FactSales_dateKey FOREIGN KEY (dateKey) REFERENCES DimDate (dateKey)
);


CREATE INDEX IX_FactSales_CustomerKey ON FactSales(customerKey);
CREATE INDEX IX_FactSales_ProductKey ON FactSales(productKey);
CREATE INDEX IX_FactSales_LocationKey ON FactSales(locationKey);
CREATE INDEX IX_FactSales_PromotionKey ON FactSales(promotionKey);
CREATE INDEX IX_FactSales_DateKey ON FactSales(dateKey);

CREATE OR REPLACE PROCEDURE DimDate_Load ( DateValue IN DATE )
IS
BEGIN
INSERT INTO DimDate
SELECT
EXTRACT(YEAR FROM DateValue) * 10000 + EXTRACT(Month FROM DateValue) * 100 + EXTRACT(Day FROM DateValue) DateKey
,DateValue DateValue
,EXTRACT(YEAR FROM DateValue) CYear
,EXTRACT(Month FROM DateValue) CMonth
,EXTRACT(Day FROM DateValue) "Day"
,CAST(TO_CHAR(DateValue, 'Q') AS INT) CQtr
,TRUNC(DateValue) - (TO_NUMBER (TO_CHAR(DateValue,'DD')) - 1) StartOfMonth
,ADD_Months(TRUNC(DateValue) - (TO_NUMBER(TO_CHAR(DateValue,'DD')) - 1), 1) -1 EndOfMonth
,TO_CHAR(DateValue, 'MONTH') MonthName
,TO_CHAR(DateValue, 'DY') DayOfWeekName
FROM dual;
END;


EXECUTE DimDate_Load('2017-12-01');

SELECT * FROM DimDate;


-- Customer Stage table and extract procedure
CREATE TABLE Customers_Stage(
cust_first_name VARCHAR2(20),
cust_last_name VARCHAR2(40),
cust_street_address VARCHAR2(40),
cust_postal_code VARCHAR2(10),
cust_city VARCHAR2(30),
cust_state_province VARCHAR2(40),
cust_main_phone_number   VARCHAR2(25),
cust_email VARCHAR2(50),
country_name VARCHAR2(40),
country_subregion VARCHAR2(30), 
country_region VARCHAR2(20)
);

CREATE OR REPLACE PROCEDURE Customers_Extract
IS
    RowCt NUMBER(10):=0;
    v_sql VARCHAR(255) := 'TRUNCATE TABLE saleshistory.Customers_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

INSERT INTO saleshistory.Customers_Stage (
cust_first_name,
cust_last_name,
cust_street_address,
cust_postal_code,
cust_city,
cust_state_province,
cust_main_phone_number,
cust_email,
country_name,
country_subregion,
country_region)
SELECT cust.cust_first_name,
cust.cust_last_name,
cust.cust_street_address,
cust.cust_postal_code,
cust.cust_city,
cust.cust_state_province,
cust.cust_main_phone_number,
cust.cust_email,
country_name,
country_subregion,
country_region
FROM sh.Customers cust
LEFT JOIN sh.Countries cou
ON cust.country_id = cou.country_id;
RowCt := SQL%ROWCOUNT;
DBMS_OUTPUT.PUT_LINE('Number of customers added: ' || TO_CHAR(SQL%ROWCOUNT));
END;

SET SERVEROUT ON;
EXECUTE Customers_Extract;
SELECT * FROM customers_stage;

-- Products Stage table and extract procedure
CREATE TABLE Products_Stage(
prod_name VARCHAR2(50),
prod_subcategory VARCHAR2(50),
prod_category VARCHAR2(50),
prod_status  VARCHAR2(20),
prod_list_price NUMBER(8,2)
);

CREATE OR REPLACE PROCEDURE Products_Extract AS
v_sql VARCHAR(255) := 'TRUNCATE TABLE saleshistory.Products_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO saleshistory.Products_Stage
    SELECT
    prod_name,
	prod_subcategory,
	prod_category,
	prod_status,
	prod_list_price
    FROM sh.products;

    DBMS_OUTPUT.PUT_LINE('Products data extracted and staged successfully.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

EXECUTE Products_Extract;
Select count(*) from Products_Stage;

-- Promotions Stage table and extract procedure

CREATE TABLE Promotions_Stage(
promo_name VARCHAR2(30),
promo_subcategory VARCHAR2(30),
promo_category VARCHAR2(30),
promo_cost NUMBER(10,2)
);

CREATE OR REPLACE PROCEDURE Promotions_Extract AS
    v_sql VARCHAR(255) := 'TRUNCATE TABLE Promotions_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    INSERT INTO Promotions_Stage(promo_name, promo_subcategory,promo_category,promo_cost)
    SELECT promo_name, promo_subcategory,promo_category,promo_cost
    FROM sh.Promotions;

    DBMS_OUTPUT.PUT_LINE('Promotions data extracted and staged successfully.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

EXECUTE Promotions_Extract;

Select * from Promotions_Stage;


--drop table sales_Stage;
-- Sales Stage table and extract procedure
CREATE TABLE Sales_Stage (
quantity_sold NUMBER(3),
amount_sold NUMBER(10,2),
unit_cost NUMBER(10,2),
unit_price NUMBER(10,2),
cust_first_name VARCHAR2(20),
cust_last_name VARCHAR2(40), 
cust_city VARCHAR2(30),
cust_state_province VARCHAR2(40),
prod_name VARCHAR2(50),
prod_eff_from DATE,
country_name VARCHAR2(40),
promo_name VARCHAR2(30)
);


CREATE OR REPLACE PROCEDURE Sales_Extract
IS
    RowCt NUMBER(10) :=0;
    v_sql VARCHAR(255) := 'TRUNCATE TABLE saleshistory.Sales_Stage DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
    
    INSERT INTO saleshistory.Sales_Stage 
    SELECT s.quantity_sold,
    s.amount_sold,
    co.unit_cost,
    co.unit_price,
    cu.cust_first_name,
    cu.cust_last_name, 
    cu.cust_city,
    cu.cust_state_province,
    prod.prod_name,
    prod.prod_eff_from,
    cou.country_name,
    promo.promo_name
    FROM sh.Sales s
        LEFT JOIN sh.Products prod
            ON s.prod_id = prod.prod_id
        LEFT JOIN sh.Costs co
            ON prod.prod_id = co.prod_id
        LEFT JOIN sh.Customers cu
            ON s.cust_id = cu.cust_id
        LEFT JOIN sh.Promotions promo
            ON s.promo_id = promo.promo_id
        LEFT JOIN sh.Countries cou
            ON cu.country_id = cou.country_id;
    
    RowCt := SQL%ROWCOUNT;
    IF sql%notfound THEN
       dbms_output.put_line('No records found. Check with source system.');
    ELSIF sql%found THEN
       dbms_output.put_line(TO_CHAR(RowCt) ||' Rows have been inserted!');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;

SET SERVEROUTPUT ON;
EXECUTE Sales_Extract; 
select count(*) from sales_stage;


-- Locations preload table and extract procedure
CREATE TABLE Locations_Preload (
	locationKey NUMBER(6) NOT NULL,
	country_name VARCHAR2(40) NULL,
	country_subregion VARCHAR2(30) NULL,
	country_region VARCHAR2(20) NULL,
    CONSTRAINT PK_Location_Preload PRIMARY KEY (LocationKey)
);


CREATE SEQUENCE LocationKey START WITH 1 CACHE 10;

CREATE OR REPLACE PROCEDURE Locations_Transform 
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Locations_Preload DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;
--BEGIN TRANSACTION;
    INSERT INTO Locations_Preload /* Column list excluded for brevity */
    SELECT locationKey.NEXTVAL,
           cu.country_name,
           cu.country_subregion,
           cu.country_region
    FROM Customers_Stage cu
    WHERE NOT EXISTS 
	( SELECT 1 
              FROM DimLocation loc
              WHERE cu.country_name = loc.country_name
                AND cu.country_subregion = loc.country_subregion
                AND cu.country_region = loc.country_region 
        );
        
    INSERT INTO Locations_Preload /* Column list excluded for brevity */
    SELECT loc.locationKey,
           cu.country_name,
           cu.country_subregion,
           cu.country_region
    FROM Customers_Stage cu
    JOIN DimLocation loc
        ON cu.country_name = loc.country_name
        AND cu.country_subregion = loc.country_subregion
        AND cu.country_region = loc.country_region;
--COMMIT TRANSACTION;
    RowCt := SQL%ROWCOUNT;
    
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END;

SET SERVEROUT ON;
EXECUTE Locations_Transform;
SELECT * FROM locations_preload ORDER BY locationkey;



--DROP TABLE CUSTOMERS_PRELOAD;
-- Customer preload and transform procedure
CREATE TABLE Customers_Preload (
customerKey NUMBER(6) NOT NULL,
cust_first_name VARCHAR2(20) NULL,
cust_last_name VARCHAR2(40) NULL,
cust_street_address VARCHAR2(40) NULL,
cust_postal_code VARCHAR2(10) NULL,
cust_city VARCHAR2(30) NULL,
cust_state_province VARCHAR2(40) NULL,
cust_main_phone_number   VARCHAR2(25) NULL,
cust_email VARCHAR2(50),
country_name VARCHAR2(40) NULL, 
country_subregion VARCHAR2(30) NULL, 
country_region VARCHAR2(20) NULL, 
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_Customers_Preload PRIMARY KEY ( customerKey )
);

CREATE SEQUENCE customerKey START WITH 1 CACHE 10;

CREATE OR REPLACE PROCEDURE Customers_Transform
AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Customers_Preload DROP STORAGE';
  StartDate DATE := SYSDATE; EndDate DATE := SYSDATE - INTERVAL '1' DAY;
BEGIN
    EXECUTE IMMEDIATE v_sql;
 --BEGIN TRANSACTION;
 -- Add updated records
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT customerKey.NEXTVAL,
    stg.cust_first_name,
	stg.cust_last_name,
	stg.cust_street_address,
	stg.cust_postal_code,
	stg.cust_city,
	stg.cust_state_province,
	stg.cust_main_phone_number,
	stg.cust_email,
	stg.country_name, 
	stg.country_subregion, 
	stg.country_region,
    StartDate,
    NULL
    FROM Customers_Stage stg
    JOIN DimCustomers cu
    ON stg.cust_first_name = cu.cust_first_name AND 
	stg.cust_last_name = cu.cust_last_name AND cu.EndDate IS NULL
          WHERE stg.cust_street_address <> cu.cust_street_address
          OR stg.cust_postal_code <> cu.cust_postal_code
          OR stg.cust_city <> cu.cust_city
          OR stg.cust_state_province <> cu.cust_state_province
          OR stg.cust_main_phone_number<> cu.cust_main_phone_number
          OR stg.cust_email <> cu.cust_email
          OR stg.country_name <> cu.country_name
	      OR stg.country_subregion <> cu.country_subregion
	      OR stg.country_region <> cu.country_region;

    -- Add existing records, and expire as necessary
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT cu.customerKey,
       cu.cust_first_name,
	   cu.cust_last_name,
	   cu.cust_street_address,
	   cu.cust_postal_code,
	   cu.cust_city,
	   cu.cust_state_province,
	   cu.cust_main_phone_number,
	   cu.cust_email,
	   cu.country_name, 
	   cu.country_subregion, 
	   cu.country_region,
       cu.StartDate,
           CASE 
               WHEN pl.cust_first_name IS NULL AND pl.cust_last_name IS NULL THEN NULL
               ELSE cu.EndDate
           END AS EndDate
    FROM DimCustomers cu
    LEFT JOIN Customers_Preload pl    
        ON pl.cust_first_name = cu.cust_first_name AND 
        pl.cust_last_name = cu.cust_last_name AND cu.EndDate IS NULL;
 -- Create new records
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT customerKey.NEXTVAL,
       stg.cust_first_name,
	   stg.cust_last_name,
	   stg.cust_street_address,
	   stg.cust_postal_code,
	   stg.cust_city,
	   stg.cust_state_province,
	   stg.cust_main_phone_number,
	   stg.cust_email,
	   stg.country_name, 
	   stg.country_subregion, 
	   stg.country_region,
       StartDate,
       NULL
    FROM Customers_Stage stg
    WHERE NOT EXISTS ( SELECT 1 FROM DimCustomers cu WHERE stg.cust_first_name = cu.cust_first_name 
    AND stg.cust_last_name = cu.cust_last_name);
    -- Expire missing records
    INSERT INTO Customers_Preload /* Column list excluded for brevity */
    SELECT cu.CustomerKey,
       cu.cust_first_name,
	   cu.cust_last_name,
	   cu.cust_street_address,
	   cu.cust_postal_code,
	   cu.cust_city,
	   cu.cust_state_province,
	   cu.cust_main_phone_number,
	   cu.cust_email,
	   cu.country_name, 
	   cu.country_subregion, 
	   cu.country_region,
       cu.StartDate,
       EndDate
    FROM DimCustomers cu
    WHERE NOT EXISTS ( SELECT 1 FROM Customers_Stage stg WHERE stg.cust_first_name = cu.cust_first_name 
    AND stg.cust_last_name = cu.cust_last_name )
          AND cu.EndDate IS NULL;

    RowCt := SQL%ROWCOUNT;
    dbms_output.put_line('Rows have been inserted!');
--COMMIT TRANSACTION;
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       dbms_output.put_line(v_sql);
END; 

SET SERVEROUT ON;
EXECUTE customers_transform;

SELECT * FROM customers_preload;

-- Product preload and transform procedure
CREATE TABLE Products_Preload(
productKey NUMBER(10) NOT NULL,
prod_name VARCHAR2(50) NULL,
prod_subcategory VARCHAR2(50) NULL,
prod_category VARCHAR2(50) NULL,
prod_status  VARCHAR2(20) NULL,
prod_list_price NUMBER(8,2) NULL,
StartDate DATE NOT NULL,
EndDate DATE NULL,
CONSTRAINT PK_Products_Preload PRIMARY KEY ( productKey )
);

CREATE SEQUENCE productKey START WITH 1 CACHE 10;

CREATE OR REPLACE PROCEDURE Products_Transform AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Products_Preload DROP STORAGE';
BEGIN
  EXECUTE IMMEDIATE v_sql;

  -- BEGIN TRANSACTION;

  -- Add updated records and expire as necessary
  INSERT INTO Products_Preload /* Column list excluded for brevity */
  SELECT dp.productKey,
        ps.prod_name,
	ps.prod_subcategory,
	ps.prod_category,
	ps.prod_status,
	ps.prod_list_price,
	dp.StartDate,
         CASE 
           WHEN dp.prod_name <> ps.prod_name
             OR dp.prod_subcategory <> ps.prod_subcategory
             OR dp.prod_category <> ps.prod_category
             OR dp.prod_status <> ps.prod_status
	     OR dp.prod_list_price <> ps.prod_list_price
           THEN SYSDATE -- Set the EndDate to the current date for updated records
           ELSE dp.EndDate -- Otherwise, keep the existing EndDate for unchanged records
         END AS EndDate
  FROM DimProducts dp
  JOIN Products_Stage ps ON dp.prod_name = ps.prod_name;

  -- Expire existing records with no match in the extract
  UPDATE Products_Preload /* Column list excluded for brevity */
  SET EndDate = SYSDATE
  WHERE NOT EXISTS (SELECT 1 FROM Products_Stage ps WHERE Products_Preload.prod_name = ps.prod_name AND Products_Preload.EndDate IS NULL);

  -- Create new records
  INSERT INTO Products_Preload /* Column list excluded for brevity */
  SELECT productKey.NEXTVAL,
         ps.prod_name,
	 ps.prod_subcategory,
	 ps.prod_category,
	 ps.prod_status,
	 ps.prod_list_price,
         SYSDATE AS StartDate,
         NULL AS EndDate
  FROM Products_Stage ps
  WHERE NOT EXISTS (SELECT 1 FROM DimProducts dp WHERE dp.prod_name = ps.prod_name);

  RowCt := SQL%ROWCOUNT;
  dbms_output.put_line(TO_CHAR(RowCt) || ' Rows have been inserted!');
  -- COMMIT TRANSACTION;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(v_sql);
END;

EXECUTE PRODUCTS_TRANSFORM;
SELECT * FROM Products_Preload;

-- Promotions preload and transform procedure

CREATE TABLE Promotions_Preload(
promotionKey NUMBER(6) NOT NULL,
promo_name VARCHAR2(30) NULL,
promo_subcategory VARCHAR2(30) NULL,
promo_category VARCHAR2(30) NULL,
promo_cost NUMBER(10,2) NULL,
CONSTRAINT PK_Promotions_Preload PRIMARY KEY (promotionKey)
);

CREATE SEQUENCE promotionKey START WITH 1 CACHE 10;

CREATE OR REPLACE PROCEDURE Promotions_Transform AS
  RowCt NUMBER(10);
  v_sql VARCHAR(255) := 'TRUNCATE TABLE Promotions_Preload DROP STORAGE';
BEGIN
  EXECUTE IMMEDIATE v_sql;

  -- Insert new records and update existing records
  INSERT INTO Promotions_Preload /* Column list excluded for brevity */
  SELECT 
    promotionkey.NEXTVAL,
    stg.promo_name, 
    stg.promo_subcategory,
    stg.promo_category,
    stg.promo_cost
  FROM 
    Promotions_Stage stg
    LEFT JOIN DimPromotions ds ON ds.promo_name = stg.promo_name;

  RowCt := SQL%ROWCOUNT;
  dbms_output.put_line(TO_CHAR(RowCt) || ' Rows have been inserted/updated!');
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(v_sql);
END;

EXECUTE PROMOTIONS_TRANSFORM;

SELECT * FROM promotions_preload;

-- Sales preload and transform procedure

CREATE TABLE Sales_Preload (
productKey NUMBER(6) NOT NULL,
customerKey NUMBER(6) NOT NULL,
locationKey NUMBER(6) NOT NULL,
promotionKey NUMBER(6)NOT NULL,
dateKey NUMBER(6) NOT NULL,
quantity_sold NUMBER(3) NOT NULL,
amount_sold NUMBER(10,2) NOT NULL,
unit_cost NUMBER(10,2) NOT NULL,
unit_price NUMBER(10,2) NOT NULL
);

CREATE OR REPLACE PROCEDURE Sales_Transform AS
    RowCt NUMBER(10);
    v_sql VARCHAR(255) := 'TRUNCATE TABLE Sales_Preload DROP STORAGE';
BEGIN
    EXECUTE IMMEDIATE v_sql;

    INSERT INTO Sales_Preload /* Columns excluded for brevity */
    SELECT pr.productKey,
    cu.customerKey,
    co.locationKey,
    promo.promotionKey,
    EXTRACT(YEAR FROM s.prod_eff_from)*10000 + EXTRACT(Month FROM s.prod_eff_from)*100 + EXTRACT(Day FROM s.prod_eff_from),
    SUM(s.quantity_sold) AS Quantity,
    SUM(s.amount_sold) AS SalesAmount,
    AVG(s.unit_cost) AS UnitCost,  
    AVG(s.unit_price) AS UnitPrice
    FROM Sales_Stage s
    JOIN Customers_Preload cu
    ON s.cust_first_name = cu.cust_first_name AND s.cust_last_name = cu.cust_last_name
    AND s.cust_state_province = cu.cust_state_province
    JOIN Locations_Preload co
    ON s.country_name = co.country_name
    JOIN Products_Preload pr
    ON s.prod_name = pr.prod_name
    JOIN Promotions_Preload promo
    ON s.promo_name = promo.promo_name
    GROUP BY
    pr.productKey,
    cu.customerKey,
    co.locationKey,
    promo.promotionKey,
    EXTRACT(YEAR FROM s.prod_eff_from)*10000 + EXTRACT(Month FROM s.prod_eff_from)*100 + EXTRACT(Day FROM s.prod_eff_from);

    RowCt := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Total Rows Inserted: ' || RowCt);
    
    IF RowCt = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No rows were inserted..');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE(v_sql);
END;

EXECUTE SALES_TRANSFORM;

SELECT * FROM sales_preload;

---Location Load
CREATE OR REPLACE PROCEDURE Load_DimLocation AS
BEGIN
    MERGE INTO DimLocation dst
    USING Locations_Preload src
    ON (dst.locationKey = src.locationKey)

    WHEN MATCHED THEN
        UPDATE SET
            dst.country_name = src.country_name,
            dst.country_subregion = src.country_subregion,
            dst.country_region = src.country_region 

    WHEN NOT MATCHED THEN
        INSERT (locationKey, country_name, country_subregion, country_region)
        VALUES (src.locationKey, src.country_name, src.country_subregion, src.country_region);

    DBMS_OUTPUT.PUT_LINE('DimLocations loaded successfully.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

EXECUTE Load_DimLocation;
select * from DimLocation;

---Customer Load
CREATE OR REPLACE PROCEDURE Load_DimCustomers
AS
BEGIN
    DELETE FROM DimCustomers cu
    WHERE EXISTS (
        SELECT 1
        FROM Customers_Preload pl
        WHERE cu.CustomerKey = pl.CustomerKey
    );
    INSERT INTO DimCustomers /* Columns excluded for brevity */
    SELECT * /* Columns excluded for brevity */
    FROM Customers_Preload;

    COMMIT;
END;

SET SERVEROUT ON;
EXECUTE Load_DimCustomers; 
SELECT * FROM DimCustomers;

--Products Load

CREATE OR REPLACE PROCEDURE Load_DimProducts AS
BEGIN
    MERGE INTO DimProducts dst
    USING Products_Preload src
    ON (dst.productKey = src.productKey)

    WHEN MATCHED THEN
        UPDATE SET
            dst.prod_name = src.prod_name,
            dst.prod_subcategory = src.prod_subcategory,
	        dst.prod_category = src.prod_category,
            dst.prod_status = src.prod_status,
            dst.prod_list_price = src.prod_list_price,
            dst.EndDate = src.EndDate
    WHEN NOT MATCHED THEN
        INSERT (productKey, prod_name, prod_subcategory, prod_category, 
        prod_status, prod_list_price, StartDate, EndDate)
        VALUES (src.productKey, src.prod_name, src.prod_subcategory, 
        src.prod_category, src.prod_status, src.prod_list_price, src.StartDate, src.EndDate);

    DBMS_OUTPUT.PUT_LINE('DimProducts loaded successfully.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

EXECUTE LOAD_DIMPRODUCTS;
select * from DimProducts;

--Promotions Load
CREATE OR REPLACE PROCEDURE Load_DimPromotions AS
BEGIN
    MERGE INTO DimPromotions dst
    USING Promotions_Preload src
    ON (dst.promotionKey = src.promotionKey)

    WHEN MATCHED THEN
        UPDATE SET
            dst.promo_name = src.promo_name, 
            dst.promo_subcategory = src.promo_subcategory,
            dst.promo_category = src.promo_category,
            dst.promo_cost = src.promo_cost

    WHEN NOT MATCHED THEN
        INSERT (promotionKey, promo_name, promo_subcategory,promo_category,promo_cost)
        VALUES (src.promotionKey,src.promo_name, src.promo_subcategory,src.promo_category, src.promo_cost);

    DBMS_OUTPUT.PUT_LINE('DimPromotions loaded successfully.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

EXECUTE LOAD_DIMPROMOTIONS;
select * from DimPromotions;

--Sales Load
CREATE OR REPLACE PROCEDURE Load_FactSales AS
BEGIN
    INSERT INTO FactSales (productKey,customerKey,locationKey,promotionKey,
	dateKey,quantity_sold,amount_sold,unit_cost,unit_price)
    SELECT productKey,customerKey,locationKey,promotionKey,dateKey,
	quantity_sold,amount_sold,unit_cost,unit_price
    FROM Sales_Preload;

    DBMS_OUTPUT.PUT_LINE('FactSales loaded successfully.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;


EXECUTE LOAD_FACTSALES;
SELECT * from FactSales;
